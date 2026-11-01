# Changelog

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
