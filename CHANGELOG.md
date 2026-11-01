# Changelog

## v0.1.2 (unreleased)

From the Episode 2 experiment (2026-10-28): 16 headless runs of the four tasks, loop
against one direct prompt. The loop drafted a reminder for an invoice whose numbers do not
add up, and on the three offline tasks it cost 2.5 times the direct prompt.

- **reflect checks every figure (new Step 1).** A check script tests each source record's
  own arithmetic (amount minus paid equals balance, and so on), holds every record that
  does not reconcile, and traces every figure in every draft back to the source. A draft
  for a record that does not add up grades the milestone "not met". `execute` and `plan`
  apply the same rule up front.
- **run-task short path.** A task whose inputs are all local files and whose plan fits in
  one milestone runs in one pass with one check script and one report, instead of a
  plan, execute, reflect cycle per milestone.
- `CLAUDE.md` and `AGENTS.md` rules 3 and 4 name both changes.

## v0.1.1 (unreleased)

From timing the README's first run as a newcomer, once with Claude Code and once with Codex.

- **Fewer permission prompts in Claude Code.** New `.claude/settings.json` pre-approves
  `date`, creating the run folder, and writes inside `workspace/runs/` and to
  `workspace/lessons.md` and `workspace/preferences.md`. On v0.1.0 a first run stopped for
  about a dozen approvals; the agent's own check scripts still ask.
- **`run-task` creates the run folder with one plain `mkdir -p`** and keeps shell commands
  in the kit folder, so the pre-approved steps match.
- **README: separate first-run sections for Claude Code and Codex.** v0.1.0 put both
  commands in one block, so a copy and paste started both. Each section now says what the
  agent will ask (trust the folder, "Go ahead with this plan?") and how to skip the stop.
- **README: "What a run costs"**, with one measured run per harness: model, tokens in and
  out, dollar cost, and agent time.
- **README links the latest release** instead of a fixed version.
- **CI:** `.github/workflows/verify.yml` checks SHA256SUMS against the tracked files, runs
  `./verify.sh --strict`, and installs both ways on every pull request. It uses plain git
  and the kit's scripts, no third-party actions.

## v0.1.0 (2026-10-17)

First public release: the plan, execute, reflect skills, four business tasks with sample
data, `verify.sh`, and `install.sh`.
