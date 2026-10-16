# PER kit

Plan, execute, reflect: a loop that makes Claude Code or Codex plan before it acts, check
its own work by using it, and write down what it learned. Four everyday business tasks
ship with sample data, so the first run needs no accounts and takes about 10 minutes.

**Needs:** Claude Code or the Codex CLI, signed in; `sh`; `sha256sum` or `shasum`. Nothing
else is downloaded or installed, and nothing phones home.

## Install

Release page, with the commit and hashes: https://github.com/crimson-knight/per-kit/releases/tag/v0.1.0

```sh
sha256sum SHA256SUMS    # or: shasum -a 256 SHA256SUMS. Must match the release page.
./verify.sh             # checks every file against SHA256SUMS; must end RESULT: PASS
```

Then pick one. Each verifies again before and after it copies:

```sh
./install.sh ~/per-kit            # Claude Code: a verified working copy (or work in place)
./install.sh --codex ~/per-kit    # Codex: the same, plus the skills in .agents/skills
```

## First run

```sh
cd ~/per-kit
claude                                                # then type: /run-task workspace/tasks/invoice-follow-up
codex "run-task workspace/tasks/invoice-follow-up"    # Codex
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
| `verify.sh`, `install.sh` | integrity check and installer |
| `LICENSE`, `RELEASE.md` | MIT license; how maintainers publish a release |

Your own data: set your name and sign-off in `preferences.md`, then replace a task's
sample file and follow the note in its TASK.md, or copy `_template/`. Every report ends with
estimated vs actual time and what the run could not do.
