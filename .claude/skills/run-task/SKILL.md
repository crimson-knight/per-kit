---
name: run-task
description: Run one task folder end to end through the PER loop (plan, execute, reflect), then write a run report with estimated vs actual time and what the run could not do. Use when asked to /run-task <task folder>, or to "run the invoice task" or any task under workspace/tasks.
---

# run-task: one task, the whole loop

Argument: a task folder, such as `workspace/tasks/invoice-follow-up`. With no argument,
list the folders in `workspace/tasks/` (skip `_template`) and ask which one to run.

## 1. Set up the run

1. Read `<task>/TASK.md` and every input file it names.
2. Run `date "+%Y%m%d-%H%M"` and create `workspace/runs/<task-name>-<that stamp>/` with
   an `output/` folder inside it. Record the full start time with `date`.

## 2. Plan

Follow `.claude/skills/plan/SKILL.md`. Write `plan.md` in the run folder. Show the owner
the summary and ask one question: "Go ahead with this plan?" (recommended: yes). Wait for
the answer. If the owner said up front to go ahead without stopping, note that in the plan
and continue.

## 3. Execute and reflect, milestone by milestone

For each milestone in order: follow `.claude/skills/execute/SKILL.md`, then
`.claude/skills/reflect/SKILL.md`. Continue only on a met grade. Follow reflect's
next-action ladder on anything else.

## 4. Write the report

Write `report.md` in the run folder. Fill in every section. Leave nothing as a
placeholder. The last two sections appear in this order, at the end:

```
# Run report: <task name>
Run folder: <path>    Started: <time>    Finished: <time>

## What you got
<each output file, one line each: path and what it is for>

## Checks performed
<each reflect check: what was checked, how, and the result, with counts>

## Things that need your eyes
<data problems, judgment calls, anything the owner should confirm before acting>

## Lessons recorded
<the titles of the entries appended to workspace/lessons.md>

## Estimated vs actual time
| Milestone | Estimated (min) | Actual (min) |
|---|---|---|
| M1 ... | | |
| Total agent time | | |
| A person doing this by hand (estimate) | <MANUAL_ESTIMATE_MINUTES> | |

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
