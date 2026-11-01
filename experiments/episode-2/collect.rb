# Grades every finished cell and writes runs.tsv (one row per run) plus grades.json.
# Usage: /usr/bin/ruby collect.rb <out dir>   reads the cells in $PER_EXPERIMENT_CELLS
# Set PER_EXPERIMENT_EXPECTED_CELLS to the number of runs you started; collection stops
# with an error when any cell is incomplete or the count differs.
require "json"

CELLS = ENV.fetch("PER_EXPERIMENT_CELLS", "/tmp/per-kit-episode-2/cells")
out_dir = ARGV.fetch(0)
rows = []
grades = {}
cell_dirs = Dir["#{CELLS}/*"].select { |path| File.directory?(path) }.sort
incomplete = cell_dirs.reject { |cell| File.exist?("#{cell}/meta.json") }
abort "collect: cells without meta.json (run unfinished or failed): #{incomplete.map { |cell| File.basename(cell) }.join(' ')}" unless incomplete.empty?
expected = ENV["PER_EXPERIMENT_EXPECTED_CELLS"]
if expected && cell_dirs.size != expected.to_i
  abort "collect: expected #{expected} cells, found #{cell_dirs.size}"
end
cell_dirs.each do |cell|
  meta = JSON.parse(File.read("#{cell}/meta.json"))
  result = JSON.parse(File.read("#{cell}/result.json")) rescue {}
  grade_file = "#{cell}/grade.json"
  unless File.exist?(grade_file)
    graded = system("/usr/bin/ruby", "#{__dir__}/grade.rb", cell, out: grade_file)
    unless graded
      File.delete(grade_file) if File.exist?(grade_file)
      abort "collect: grade.rb failed for #{File.basename(cell)}"
    end
  end
  grade = JSON.parse(File.read(grade_file))
  grades[File.basename(cell)] = grade
  usage = (result["modelUsage"] || {}).values
  sum = ->(key) { usage.sum { |model| model[key].to_i } }
  failed = grade["checks"].reject { |item| item["ok"] }.map { |item| item["id"] }
  rows << {
    "run_id" => File.basename(cell), "task" => meta["task"], "arm" => meta["arm"] == "A" ? "A_per_skills" : "B_direct_prompt",
    "rep" => meta["rep"], "model" => meta["model"], "verify_sh" => meta["verify_pass"] ? "PASS" : "FAIL",
    "done_means_checks" => "#{grade['passed']}/#{grade['total']}",
    "task_pass" => (meta["verify_pass"] && failed.empty? && !meta["timed_out"] && !result["is_error"]) ? "PASS" : "FAIL",
    "wall_minutes" => meta["wall_minutes"], "turns" => result["num_turns"],
    "input_tokens" => sum.("inputTokens"), "output_tokens" => sum.("outputTokens"),
    "cache_read_tokens" => sum.("cacheReadInputTokens"), "cache_write_tokens" => sum.("cacheCreationInputTokens"), "web_searches" => sum.("webSearchRequests"),
    "reported_cost_usd" => result["total_cost_usd"]&.round(4), "timed_out" => meta["timed_out"],
    "cli_error" => result["is_error"] ? result["result"].to_s[0, 80] : "", "failed_checks" => failed.join(",")
  }
end
header = rows.first&.keys || []
File.write("#{out_dir}/runs.tsv", ([header.join("\t")] + rows.map { |row| header.map { |key| row[key].to_s.tr("\t\n", "  ") }.join("\t") }).join("\n") + "\n")
File.write("#{out_dir}/grades.json", JSON.pretty_generate(grades))
rows.each { |row| puts row.values_at("run_id", "verify_sh", "done_means_checks", "task_pass", "wall_minutes", "reported_cost_usd", "failed_checks").join("  ") }
