---
name: reflect
description: Verify a milestone's result against its success criteria by using it, record which assumptions broke and why, update the plan in place, write a lesson, and decide the next action. Use after execute, or when asked to /reflect.
---

# reflect (the R in PER)

This is the quality gate and the learning step. It is where "done means a person can use
it" gets enforced.

## Step 1: Verify by using it

Check the result yourself, the way the owner would use it:
- Numbers: recompute them from the input file and compare line by line.
- Drafts: open each one and check names, amounts, dates, and tone against the input and
  the CONSTRAINTS.
- Research: open the cited source and confirm it says what the row claims.
- Claims in written content: find each one in the source text.

Confirm or refute each claim the doer made. Write down what you saw.

## Step 2: Grade against the success criteria

For the milestone: **met**, **partial**, or **not met**, with the evidence you saw (a count,
a quoted line, a mismatch), never only "the file exists".

## Step 3: Record what broke

For each assumption that did not hold, add a block under the plan's LEARNINGS:

```
ASSUMPTION: <what was assumed>
REALITY: <what actually happened>
WHY IT BROKE: <root cause>
```

## Step 4: Update the plan in place

- Set the milestone's `status:` to `done` or `blocked`, and add `grade:` and `evidence:`.
- Rewrite any later milestone that this learning changes.
- The updated plan is what a future run starts from.

## Step 5: Write a lesson

Every run leaves at least one lesson in `workspace/lessons.md`. Write it when an
assumption broke or a check caught a mistake, and in any case at the last milestone, so a
run adds one to three entries in all. Add a new entry:

```
## <short title> (<YYYY-MM-DD>)
Applies when: <the situation that should trigger this, e.g. "drafting payment reminders
from a CSV export where one customer has several open invoices">
<what to do, in one to three sentences, and why>
```

Describe the situation in the "Applies when:" line, so a future plan finds it by
matching its own situation. When the lesson is already in the file, sharpen that entry
in place and add a line "Confirmed <YYYY-MM-DD>" under it; that counts as this run's
lesson.

## Step 6: Decide the next action

- **Continue**: the milestone is met, so run `execute` on the next one.
- **Fix**: partial or not met with a clear cause, so fix it and reflect again.
- **Re-plan**: the learning breaks the approach, so go back to `plan` with the new
  constraint.
- **Stop and ask the owner**: the same problem failed two distinct approaches. Report what
  happened, what you tried, your root-cause guess, and what you need. Three distinct
  approaches is the ceiling.
