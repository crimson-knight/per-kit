# Runs one experiment cell: a task, an arm (A = PER skills, B = one direct prompt), a rep.
# Usage: /usr/bin/ruby run_one.rb <task> <A|B> <rep>
# Writes <cells>/<task>-<arm>-<rep>/ with kit/, result.json, meta.json, verify.txt.
# Cells go to $PER_EXPERIMENT_CELLS (default /tmp/per-kit-episode-2/cells); keep them out of
# ~/.claude, which Claude Code treats as protected. The model is $PER_EXPERIMENT_MODEL.
require "json"
require "fileutils"
require "time"

KIT = File.expand_path("../..", __dir__)
CELLS = ENV.fetch("PER_EXPERIMENT_CELLS", "/tmp/per-kit-episode-2/cells")
MODEL = ENV.fetch("PER_EXPERIMENT_MODEL", "claude-sonnet-5-5")
TIMEOUT_S = 40 * 60
TOOLS = %w[Bash Read Write Edit Glob Grep WebSearch WebFetch Skill]
# Arm B sees the task inputs and the owner's notes, and none of the loop instructions.
LOOP_FILES = %w[CLAUDE.md AGENTS.md .claude README.md NEXT-STEPS.md RELEASE.md CHANGELOG.md
                install.sh verify.sh SHA256SUMS LICENSE .github .gitignore]
# Neither arm sees this folder: it holds the answer key and the published results.
HIDDEN = %w[experiments]

task, arm, rep = ARGV
abort "usage: run_one.rb <task> <A|B> <rep>" unless task && %w[A B].include?(arm) && rep
abort "no task folder: #{KIT}/workspace/tasks/#{task}" unless File.directory?("#{KIT}/workspace/tasks/#{task}")
cell = "#{CELLS}/#{task}-#{arm}-#{rep}"
abort "cell exists: #{cell}" if File.exist?(cell)
kit = "#{cell}/kit"
stash = "#{cell}/stash"
hidden = "#{cell}/hidden"
FileUtils.mkdir_p(cell)

# Copy only the files the kit publishes, as install.sh does, so earlier runs and local
# edits stay behind; then require the copy to match the published hashes exactly.
File.readlines("#{KIT}/SHA256SUMS", chomp: true).each do |line|
  path = line.sub(/\A\h{64}  /, "")
  FileUtils.mkdir_p(File.dirname("#{kit}/#{path}"))
  FileUtils.cp("#{KIT}/#{path}", "#{kit}/#{path}", preserve: true)
end
FileUtils.cp("#{KIT}/SHA256SUMS", "#{kit}/SHA256SUMS")
FileUtils.mkdir_p("#{kit}/workspace/runs")
pre_verify = `cd #{kit} && ./verify.sh --strict 2>&1`
abort "the kit copy does not match SHA256SUMS; start from a fresh kit\n#{pre_verify}" unless $?.success?

FileUtils.mkdir_p(hidden)
HIDDEN.each { |hidden_file| FileUtils.mv("#{kit}/#{hidden_file}", "#{hidden}/#{hidden_file}") if File.exist?("#{kit}/#{hidden_file}") }

if arm == "A"
  prompt = "/run-task workspace/tasks/#{task}\n\nGo ahead without stopping: you have my approval of the plan up front."
else
  FileUtils.mkdir_p(stash)
  LOOP_FILES.each { |loop_file| FileUtils.mv("#{kit}/#{loop_file}", "#{stash}/#{loop_file}") if File.exist?("#{kit}/#{loop_file}") }
  task_text = File.read("#{kit}/workspace/tasks/#{task}/TASK.md")
  prompt = <<~P
    Do this task now, in this folder.

    #{task_text}
    The input files are in workspace/tasks/#{task}/. My standing preferences are in workspace/preferences.md. Write every output/... path above inside workspace/runs/#{task}-direct/output/.
  P
end

cmd = ["claude", "-p", prompt, "--model", MODEL, "--setting-sources", "project",
       "--settings", JSON.generate("claudeMdExcludes" => ["#{Dir.home}/.claude/**"]),
       "--strict-mcp-config", "--no-chrome", "--no-session-persistence",
       "--permission-mode", "acceptEdits", "--allowedTools", *TOOLS,
       "--output-format", "json"]
env = { "CLAUDE_CODE_DISABLE_AUTO_MEMORY" => "1" }
started = Time.now
out_path = "#{cell}/result.json"
pid = Process.spawn(env, *cmd, chdir: kit, out: out_path, err: "#{cell}/stderr.txt", in: File::NULL)
timed_out = false
deadline = started + TIMEOUT_S
loop do
  break if Process.wait(pid, Process::WNOHANG)
  if Time.now > deadline
    timed_out = true
    Process.kill("TERM", pid) rescue nil
    Process.wait(pid) rescue nil
    break
  end
  sleep 2
end
finished = Time.now

# Put the moved files back so verify.sh judges both arms' folders by the same rules.
collisions = []
put_back = ->(from, names) do
  names.each do |moved_name|
    next unless File.exist?("#{from}/#{moved_name}")
    if File.exist?("#{kit}/#{moved_name}")
      collisions << moved_name
      FileUtils.rm_rf("#{kit}/#{moved_name}")
    end
    FileUtils.mv("#{from}/#{moved_name}", "#{kit}/#{moved_name}")
  end
  FileUtils.rm_rf(from)
end
put_back.call(stash, LOOP_FILES) if arm == "B"
put_back.call(hidden, HIDDEN)
verify_out = `cd #{kit} && ./verify.sh 2>&1`
verify_pass = $?.success?
File.write("#{cell}/verify.txt", verify_out)

meta = { task: task, arm: arm, rep: rep.to_i, model: MODEL, started: started.iso8601,
         finished: finished.iso8601, wall_minutes: ((finished - started) / 60.0).round(2),
         timed_out: timed_out, verify_pass: verify_pass, arm_b_collisions: collisions,
         prompt: prompt }
File.write("#{cell}/meta.json", JSON.pretty_generate(meta))
puts JSON.generate(meta.reject { |k, _| k == :prompt })
