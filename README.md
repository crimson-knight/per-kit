# PER kit

Plan, execute, reflect: a loop that makes Claude Code or Codex plan before it acts, check
its own work by using it, and write down what it learned. Four everyday business tasks
ship with sample data, so the first run needs no accounts and takes about 10 minutes.

**Needs:** Claude Code or the Codex CLI, signed in; `sh`; `sha256sum` or `shasum`. Nothing
else is downloaded or installed, and nothing phones home.

## Install

Release page, with the commit and hashes: https://github.com/crimson-knight/per-kit/releases/latest

Download the `per-kit-<version>.zip` listed on that page (for example `per-kit-v0.1.1.zip`),
then, with your version in place of `v0.1.1`:

```sh
shasum -a 256 per-kit-v0.1.1.zip    # or sha256sum; must match the zip hash on the page
unzip per-kit-v0.1.1.zip && cd per-kit
shasum -a 256 SHA256SUMS            # must match the SHA256SUMS hash on the page
./verify.sh --strict                # every file exactly as published; ends RESULT: PASS
```

Then pick one. Each verifies again before and after it copies, and takes a few seconds:

```sh
./install.sh ~/per-kit            # Claude Code: a verified working copy (or work in place)
./install.sh --codex ~/per-kit    # Codex: the same, plus the skills in .agents/skills
```

## First run with Claude Code

```sh
cd ~/per-kit
claude
```

Then type `/run-task workspace/tasks/invoice-follow-up`.

1. Claude Code asks whether you trust the folder. Say yes: the kit's
   `.claude/settings.json` takes effect only in a trusted folder. It pre-approves `date`,
   creating the run folder, and writing inside `workspace/runs/` and to your two notes
   files, and nothing else.
2. The agent reads the task, writes `plan.md`, and asks "Go ahead with this plan?". Answer
   yes. To skip that stop, type `/run-task workspace/tasks/invoice-follow-up go ahead
   without stopping` instead.
3. It runs each milestone and checks every draft against the CSV. When it wants to run a
   check script it wrote, Claude Code shows you the script and asks; read it and allow it.

## First run with Codex

```sh
cd ~/per-kit
codex "run-task workspace/tasks/invoice-follow-up"
```

Codex asks whether to trust the folder; say yes. Codex's default mode lets the agent write
inside this folder without asking, so the only stop is "Go ahead with this plan?": answer
yes in the same session. To run without the interactive screen:
`codex exec --skip-git-repo-check -s workspace-write "run-task workspace/tasks/invoice-follow-up, go ahead without stopping"`.

## What a run gives you

Any task runs the same way: `/run-task workspace/tasks/<name>` (Claude Code) or
`run-task workspace/tasks/<name>` (Codex). Any new folder works in place of `~/per-kit`.
The agent writes a plan, asks "go ahead?", runs each milestone, checks every draft against
the CSV, appends a lesson, and writes a report. Results land in
`workspace/runs/invoice-follow-up-<timestamp>/`: `plan.md`, `output/`, `report.md`.

## What a run costs

One measured first run of the invoice task, from the v0.1.0 release, on 2026-10-28:

| Harness | Model | Tokens in | Tokens out | Cost | Agent time |
|---|---|---|---|---|---|
| Claude Code 2.1.312 | claude-opus-5-5 | 786,245 (740,320 of them cache reads) | 20,597 | $0.93 at API list price, as Claude Code reported it | 3 min 56 s |
| Codex CLI 0.155.1 | gpt-6-astra (its default with a ChatGPT sign-in) | 494,737 (437,760 of them cached) | 9,372 | included in the ChatGPT plan | 5 min 11 s |

Agent time is the two turns (plan, then execute after "yes"), measured from outside the
CLI; it excludes the time you take to read the plan. On a subscription, a run counts toward
your plan's usage limits instead of costing dollars. Each run's `report.md` records its own
estimated and actual time.

## What you get

| Path | What it is |
|---|---|
| `CLAUDE.md`, `AGENTS.md` | the loop rules, for Claude Code and for Codex |
| `.claude/skills/` | `plan`, `execute`, `reflect`, and `run-task`, which chains them |
| `.claude/settings.json` | the few Claude Code permissions a run needs, listed above |
| `workspace/preferences.md` | your standing rules; edit the three examples first |
| `workspace/lessons.md` | grows by one or more "Applies when:" entries per run |
| `workspace/tasks/` | invoice follow-up, lead list research (needs web access), content repurposing, inbox triage, and `_template/` for your own |
| `NEXT-STEPS.md` | connecting real systems, scheduled runs, panel planning |
| `verify.sh`, `install.sh` | integrity check and installer |
| `CHANGELOG.md` | what changed in each release |
| `LICENSE`, `RELEASE.md` | MIT license; how maintainers publish a release |

Your own data: set your name and sign-off in `preferences.md`, then replace a task's
sample file and follow the note in its TASK.md, or copy `_template/`. Every report ends with
estimated vs actual time and what the run could not do.
