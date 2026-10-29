---
name: run-task
description: Run one task folder end to end through the PER loop (plan, execute, reflect), then write a run report with estimated vs actual time and what the run could not do. Use when asked to /run-task <task folder>, or to "run the invoice task" or any task under workspace/tasks.
---

# run-task: one task, the whole loop

Argument: a task folder, such as `workspace/tasks/invoice-follow-up`. With no argument,
list the folders in `workspace/tasks/` (skip `_template`) and ask which one to run.

## 1. Set up the run

1. Run `date` first and keep the result: it is the run's STARTED time, and planning time
   counts from here.
2. Read `<task>/TASK.md` and every input file it names. Dates inside the task (such as an
   AS-OF DATE) govern the work; the real date from `date` governs file names, the
   lessons, and the report's times.
3. Run `date "+%Y%m%d-%H%M"` and create `workspace/runs/<task-name>-<that stamp>/` with
   an `output/` folder inside it. Every `output/...` path in the TASK.md lives there.
   Create it with `mkdir -p workspace/runs/<task-name>-<that stamp>/output` as a command of
   its own, with the stamp typed out. Run every shell command from the kit folder, using
   paths relative to it. The kit's `.claude/settings.json` pre-approves exactly these
   steps (`date`, this `mkdir`, and writes inside `workspace/runs/` and to the two notes
   files), so a first run asks the owner far less often.

## 2. Plan

First pick the path. Take the **short path** when all three hold:
- every input is a file already in the task folder (no web research, no outside system);
- one doer can write every output in one sitting, in one milestone;
- nothing needs an owner decision before the work can start.

Otherwise take the full path below. On the short path:
- **Plan:** the same plan.md header (GOAL, DONE_MEANS, LIMITS word for word, CONSTRAINTS
  from preferences and lessons), `PATH: short`, and one milestone M1 whose success
  criteria are the TASK.md DONE MEANS. Ask "Go ahead?" as below, unless approval was given
  up front.
- **Execute M1 in one pass:** read each input once, write each output file once, then fix
  with small edits.
- **Reflect once, with one script:** write a single check script in the run folder that
  runs reflect Step 1 (every figure reconciled, records that do not add up held) and
  tests every DONE MEANS line it can. Run it, fix what it finds, run it again until it is
  clean. Update the plan once, at the end, with M1's status, grade, evidence, and
  `actual_minutes`.
- **Lesson and report:** write one lesson (or confirm one) and the report below, with a
  single milestone row in the time table.

Full path: follow `.claude/skills/plan/SKILL.md`. Write `plan.md` in the run folder. Show the owner
the summary and ask one question: "Go ahead with this plan?" (recommended: yes). Wait for
the answer, then set `APPROVED:` and `PLANNING_MINUTES:` in the plan. If the owner said up front to go ahead
without stopping, set `APPROVED: yes (given up front), <time>` and continue.

If something stops the run before it starts (no web access for a web task, a missing
input file), write `report.md` now: the blocker under "Needs your decision", "none" for
the outputs, and the last two sections as usual. Then tell the owner and stop.

## 3. Execute and reflect, milestone by milestone

For each milestone in order: follow `.claude/skills/execute/SKILL.md`, then
`.claude/skills/reflect/SKILL.md`. Continue only on a met grade. Follow reflect's
next-action ladder on anything else.

## 4. Write the report

After the last milestone's reflect check, run `date` for the finish time and write
`report.md` in the run folder. Every time in the report comes from a `date` you ran. Fill in
every section and leave nothing as a placeholder. Apply preferences.md to the order and
length of the opening sections; the last two sections always stay at the end, in this
order:

```
# Run report: <task name>
Run folder: <path>    Started: <time>    Finished: <time>

## Needs your decision
<the items the owner must decide or confirm before acting, most important first>

## What you got
<each output file, one line each: path and what it is for>

## Checks performed
<each reflect check: what was checked, how, and the result, with counts>

## Lessons added or confirmed
<the titles of the entries added to, or confirmed in, workspace/lessons.md>

## Estimated vs actual time
| Step | Agent estimate (min) | Agent actual (min) |
|---|---|---|
| Planning | n/a | <PLANNING_MINUTES> |
| M1 ... | | |
| Total agent time | <sum of milestone estimates> | <planning plus milestones> |

Record minutes to one decimal place (0.5) so short runs still show a difference.
A person doing this by hand: about <MANUAL_ESTIMATE_MINUTES> minutes (from TASK.md).
Agent time excludes waiting for the owner's "go ahead".

<one sentence: the gap between the estimate and the actual, and why>

## What this run could not do
- <each real-world step this run left for a person, specific to this task: the systems
  it could not read from, the messages it could not send, the schedule it could not keep>
- <whether it could run again next week with no one present: no, because ...>

Next steps for connecting real systems, scheduled runs, and panel planning: NEXT-STEPS.md
```

## 5. Close out

Tell the owner, in under ten lines: where the report is, the two or three things that need
their eyes, and the total actual time. Then suggest they run the same task on their own
file by replacing the sample input.
