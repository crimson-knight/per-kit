---
name: plan
description: Turn a goal or a TASK.md into a milestone plan that a fresh agent could carry out with no questions, with the owner's preferences and lessons applied as hard constraints. Use when starting any non-trivial task, before doing work, or when asked to /plan <goal>.
---

# plan (the P in PER)

A plan is clear when someone who was not part of the planning could carry it out with no
questions. That is the bar.

## Step 1: Restate the goal and what done means

- One sentence: the outcome we are after.
- Define done for this goal. The default: done means a person can use the result today,
  so "the file exists" is a step on the way to done.
- If the input is a `TASK.md`, copy its GOAL, DONE MEANS, and LIMITS word for word.

## Step 2: Read the owner's notes

1. Read `workspace/preferences.md` and `workspace/lessons.md` in full.
2. Pick every entry whose "Applies when:" line matches this task's situation.
3. Write each one into the plan's CONSTRAINTS list, citing the entry's heading. A plan
   with an empty CONSTRAINTS list has skipped this step; when nothing matches, write
   "none matched" and name the files you read.
4. When instructions disagree, the TASK.md wins (LIMITS first), then preferences.md, then the
   skills' default formats (for example, a preference about report order changes the
   run report's section order). Record each such call in CONSTRAINTS. If a preference
   conflicts with the goal itself, put it in OPEN_QUESTIONS.

## Step 3: Check before you ask

Before you ask the owner anything:

1. Look for the answer in preferences, lessons, and the task's own files.
2. If they settle it, decide, note the source in the plan, and continue.
3. Otherwise ask one question, with your recommended answer, so the owner can reply "yes".

Also scan the owner's recent messages for the "repeating myself" signal: phrases such as
"again", "like I said", "as I mentioned", or a correction that restates an earlier one.
On a hit, say so plainly ("I think I missed X; you said Y earlier"), fix the plan, and
save the resolution as a preference with an "Applies when:" line.

## Step 4: Break it into milestones

Each milestone is a unit one doer can finish and a checker can verify:

```
- id: M1
  goal: <one sentence>
  steps: [<ordered, concrete>]
  success_criteria: <testable, and usable by a person>
  doer: <you, or a sub-agent if your tool supports one>
  depends_on: [<milestone ids, or none>]
  assumptions: [<what you are assuming; reflect tests each one>]
  estimate_minutes: <your honest estimate of YOUR time, not a person's>
  status: todo
```

Three to five milestones suits most business tasks. The run report is written after the
last milestone's reflect check, so it is not a milestone of its own.

## Step 5: Self-check

- Stranger test: could a fresh agent carry out each milestone with only this file?
- Constraint test: does every milestone honor every CONSTRAINT and LIMIT?
- Done test: if every milestone meets its success criteria, can the owner use the result?

## Step 6: Write the plan file

Write it to the run folder (`workspace/runs/<task>-<YYYYMMDD-HHMM>/plan.md`), or to
`workspace/runs/<short-goal>-<YYYYMMDD-HHMM>/plan.md` for a goal with no task folder:

```
# PLAN: <goal>
STARTED: <date and time, from the `date` command>
PLANNING_MINUTES: <filled in after the owner answers: STARTED until you asked "Go ahead?">
APPROVED: <"yes, <time>" once the owner says go ahead; "pending" until then>
GOAL: <one sentence>
DONE_MEANS: <definition of done>
LIMITS: <from the TASK.md, or "none stated">
CONSTRAINTS:
  - <rule applied> (source: preferences.md "<heading>" or lessons.md "<heading>")
MANUAL_ESTIMATE_MINUTES: <how long a person would take by hand; use the TASK.md TIME line>
MILESTONES:
  <the milestone blocks from Step 4>
LEARNINGS:
  <empty; reflect fills this in>
OPEN_QUESTIONS:
  - <anything that needs the owner, or "none">
```

Show the owner the plan summary (goal, milestones with estimates, constraints, open
questions) and hand the file to `execute`. Keep the file: `reflect` updates it in place.
