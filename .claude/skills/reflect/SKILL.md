---
name: reflect
description: Verify a milestone's result against its success criteria by using it, record which assumptions broke and why, update the plan in place, write a lesson, and decide the next action. Use after execute, or when asked to /reflect.
---

# reflect (the R in PER)

This is the quality gate and the learning step. It is where "done means a person can use
it" gets enforced.

## Step 1: Reconcile every figure

Do this whenever the inputs or the outputs carry numbers (amounts, counts, quantities,
dates). Write a short check script in the run folder (for example `check.rb` or
`check.py`) and run it, so every record and every figure is checked, not a sample.

1. **Check each source record against itself.** List every relation its columns imply
   (amount minus paid equals balance; quantity times unit price equals the line total;
   line items add up to the total; an invoice date before its due date) and test each
   relation on every record.
2. **Hold every record whose numbers do not reconcile.** A held record gets no draft. It
   goes on the data-problems list with the figures that disagree and what the owner should
   check, and it is marked held wherever the outputs classify records. Holding is the
   answer even when one figure looks like the obvious typo: the owner decides which is
   right.
3. **Trace every figure in every draft to the source.** Each amount, count, ID, and date in
   a draft equals the source value for that same record. A figure with no source value (a
   computed total, a rounded number) fails unless the task asks for it.
4. **Write the counts into the evidence:** records checked, records held and why, figures
   traced, mismatches found. "0 mismatches in 37 figures; INV-1042 held: 2,100.00 minus
   500.00 is 1,600.00, the export says 1,800.00" is evidence; "numbers look right" is not.

A draft for a record that does not reconcile, or a figure that does not trace, grades the
milestone **not met**: remove the draft, hold the record, and check again.

## Step 2: Verify by using it

Check the result yourself, the way the owner would use it:
- Numbers: Step 1's script has checked them; read its output and act on every line.
- Drafts: open each one and check names, recipients, and tone against the input and the
  CONSTRAINTS.
- Research: open the cited source and confirm it says what the row claims.
- Claims in written content: find each one in the source text.

Confirm or refute each claim the doer made. Write down what you saw.

## Step 3: Grade against the success criteria

For the milestone: **met**, **partial**, or **not met**, with the evidence you saw (a count,
a quoted line, a mismatch), never only "the file exists".

## Step 4: Record what broke

For each assumption that did not hold, add a block under the plan's LEARNINGS:

```
ASSUMPTION: <what was assumed>
REALITY: <what actually happened>
WHY IT BROKE: <root cause>
```

## Step 5: Update the plan in place

- Set the milestone's `status:` to `done` or `blocked`, and add `grade:` and `evidence:`.
- Rewrite any later milestone that this learning changes.
- The updated plan is what a future run starts from.

## Step 6: Write a lesson

Every run leaves one to three lessons in `workspace/lessons.md`. When an assumption broke
or a check caught a mistake, decide whether it generalizes; fold related fixes into one
lesson. If no lesson has been written by the last milestone, write one there. Add a new
entry:

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

## Step 7: Decide the next action

- **Continue**: the milestone is met, so run `execute` on the next one.
- **Fix**: partial or not met with a clear cause, so fix it and reflect again.
- **Re-plan**: the learning breaks the approach, so go back to `plan` with the new
  constraint.
- **Stop and ask the owner**: the same problem failed two distinct approaches. Report what
  happened, what you tried, your root-cause guess, and what you need. Three distinct
  approaches is the ceiling.
