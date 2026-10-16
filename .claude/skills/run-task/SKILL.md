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

## 2. Plan

Follow `.claude/skills/plan/SKILL.md`. Write `plan.md` in the run folder. Show the owner
the summary and ask one question: "Go ahead with this plan?" (recommended: yes). Wait for
the answer, then set `APPROVED:` and `PLANNING_MINUTES:` in the plan. If the owner said up front to go ahead
without stopping, set `APPROVED: yes (given up front), <time>` and continue.

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

## Lessons recorded
<the titles of the entries appended to workspace/lessons.md>

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
