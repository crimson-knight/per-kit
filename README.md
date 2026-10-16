# PER kit

Plan, execute, reflect: a loop that makes Claude Code or Codex plan before it acts, check
its own work by using it, and write down what it learned. Four everyday business tasks
ship with sample data, so the first run needs no accounts and takes about 10 minutes.

**Needs:** Claude Code or the Codex CLI, signed in; `sh`; `sha256sum` or `shasum`. Nothing
else is downloaded or installed, and nothing phones home.

## Install

```sh
shasum -a 256 SHA256SUMS      # must match the value on the release page
./verify.sh                   # every file checked against SHA256SUMS; ends RESULT: PASS
./install.sh ~/per-kit        # optional: copy a verified kit to a working folder
./install.sh --codex          # Codex only: add the skills to .agents/skills (also with a folder)
```

## First run

```sh
cd ~/per-kit                  # or wherever the kit lives
claude                        # then type: /run-task workspace/tasks/invoice-follow-up
codex "run-task workspace/tasks/invoice-follow-up"     # the Codex equivalent
```

The agent writes a plan, asks "go ahead?", runs each milestone, checks every draft against
the CSV, appends a lesson, and writes a report. Results land in
`workspace/runs/invoice-follow-up-<timestamp>/`: `plan.md`, `output/`, `report.md`.

## What you get

| Path | What it is |
|---|---|
| `CLAUDE.md`, `AGENTS.md` | the loop rules, for Claude Code and for Codex |
| `.claude/skills/` | `plan`, `execute`, `reflect`, and `run-task`, which chains them |
| `workspace/preferences.md` | your standing rules; edit the three examples first |
| `workspace/lessons.md` | grows by one or more "Applies when:" entries per run |
| `workspace/tasks/` | invoice follow-up, lead list research (needs web access), content repurposing, inbox triage, and `_template/` for your own |
| `NEXT-STEPS.md` | connecting real systems, scheduled runs, panel planning |

Your own data: replace a task's sample file, or copy `_template/`. Every report ends with
estimated vs actual time and what the run could not do.
