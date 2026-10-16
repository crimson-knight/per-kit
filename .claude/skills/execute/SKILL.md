---
name: execute
description: Carry out one milestone from a PER plan file, tracking which assumptions it tests, and hand the result to reflect. Use when running a milestone from a plan, or when asked to /execute.
---

# execute (the E in PER)

Run one milestone at a time. Finish it, hand it to `reflect`, then take the next.

## Step 1: Pick the milestone

Open the plan file. Take the first milestone with `status: todo` whose `depends_on` are all
`done`. Record the start time with `date`.

## Step 2: Choose the doer

The doer is you, or a sub-agent if your tool supports one and the milestone is large or
separable. Read the milestone, the plan's CONSTRAINTS and LIMITS, and every input file it
names before you start.

## Step 3: Brief the doer

When you hand the milestone to a sub-agent, give it this brief. When you do it yourself,
read the same brief back to yourself first.

```
ROLE: <one line, e.g. "accounts-receivable assistant drafting follow-up emails">
TASK: <the milestone goal>
CONTEXT: <input file paths, prior milestone outputs, the plan's CONSTRAINTS and LIMITS>
SUCCESS CRITERIA: <the milestone's success_criteria>
OUTPUT: <exact file paths under the run folder's output/>; end with a short report:
  what you produced, where, and anything you were unsure of.
If the same problem fails twice, stop, write down what happened and what you tried,
and report what you need to continue.
```

## Step 4: Do the work

- Write every output under the run folder's `output/` directory.
- Honor the LIMITS exactly. Drafts stay drafts: nothing is sent, posted, or submitted.
- Keep a short note of each assumption the work tested and what actually happened.

## Step 5: Capture, then hand off

- Record the finish time with `date`, and the actual minutes in the milestone block as
  `actual_minutes:`.
- Leave `status` for `reflect` to set. The doer's report is a claim until `reflect` has
  checked it.

Hand the milestone, its outputs, and the assumption notes to `reflect`.
