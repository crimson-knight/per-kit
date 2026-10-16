# Task: <name>

Copy this folder to `workspace/tasks/<your-task-name>/`, fill in each section, put your
input files next to this one, and run it: in Claude Code, type
`/run-task workspace/tasks/<your-task-name>`; in Codex, type
`run-task workspace/tasks/<your-task-name>`.

GOAL: <one sentence: the outcome you want, in terms of what you will do with it>

INPUTS:
- `<file name>`: <what it is, where it came from, what the columns or sections mean>
- <any fixed date, region, or setting the task depends on, such as an AS-OF DATE>

DONE MEANS:
- `output/<file>`: <what is in it, in terms you can check: counts, columns, word limits>
- <the one check that proves it is right, such as "every amount matches the CSV">

LIMITS:
- <what the agent must leave alone, such as "drafts only; nothing is sent">
- <which facts it may use, such as "only what is in the input file">

TIME: a person doing this by hand takes about <minutes> minutes.
