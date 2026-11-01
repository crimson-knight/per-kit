# The PER loop: plan, execute, reflect

You are working inside the PER kit. Every task here runs through the same loop, and these
rules hold for the whole session.

## The loop rules

1. **Plan before you do.** Read the task and its inputs, then write a plan with the `plan`
   skill before you produce anything. A plan is clear when a stranger could carry it out
   with no questions. Until the owner approves it, you write only `plan.md` in the run
   folder (and `report.md`, if a blocker stops the run). After approval, the run writes to
   its run folder, `workspace/lessons.md`, and, when the owner states a new standing rule,
   `workspace/preferences.md`. Nothing else.
2. **Read the owner's notes first.** Every plan starts by reading `workspace/preferences.md`
   and `workspace/lessons.md`. Entries whose "Applies when:" line matches the task become
   hard constraints in the plan, named by entry.
3. **One milestone at a time.** Run milestones in order with the `execute` skill. Finish
   and check one before you start the next. A small offline task whose plan fits in one
   milestone takes `run-task`'s short path: one pass, one check script, one report.
4. **A self-report is a claim.** "Done" means a person can use the result. Check each
   result by using it (open the file, recount the numbers, follow the link) with the
   `reflect` skill before you mark a milestone done. Every figure in a draft must trace to
   its source, and a record whose numbers do not add up is held, never drafted.
5. **Drafts only.** Nothing leaves this folder. Write emails, posts, and replies as files
   for the owner to review and send.
6. **Ask one question, with a recommended answer.** When you need a decision, check
   preferences and lessons first. If they do not settle it, ask one question and say what
   you would choose.
7. **Stuck twice, stop and write it down.** If the same problem fails two different
   approaches, stop. Tell the owner what happened, what you tried, your best guess at the
   cause, and what you need. Three distinct approaches is the ceiling. When one item in a
   batch fails twice (a website that will not load), drop that item, note it, and go on.
8. **Write down what you learned.** Every run leaves at least one lesson in
   `workspace/lessons.md`: a new entry, or a sharpened existing entry with a
   "Confirmed <YYYY-MM-DD>" line added. Each entry begins with an "Applies when:" line
   that describes the situation where it should fire again.
9. **Be honest about time.** Estimate each milestone when you plan it, record the actual
   time when it finishes, and report both.
10. **Every run ends with a report.** It goes in the run folder as `report.md`, is written
    after the last milestone's reflect check, and ends with "Estimated vs actual time"
    and then "What this run could not do".
11. **When instructions disagree,** the task's TASK.md wins (LIMITS first, then the rest
    of the file), then `workspace/preferences.md`, then the skills' default formats. Note each such call in the plan's CONSTRAINTS.

## Where things live

- Skills: `.claude/skills/plan`, `execute`, `reflect`, and `run-task` (chains all three).
- Tasks: `workspace/tasks/<task>/TASK.md`, each with GOAL, INPUTS, DONE MEANS, and LIMITS.
  An `output/...` path in a TASK.md means the run folder's `output/` folder.
- Your notes: `workspace/preferences.md` (standing rules) and `workspace/lessons.md`.
- Each run: `workspace/runs/<task>-<YYYYMMDD-HHMM>/` holds `plan.md`, `output/`, `report.md`.

## Start here

Run a task by typing: `run-task workspace/tasks/invoice-follow-up`

## For Codex and other agents that read AGENTS.md

The skills are plain Markdown files. When the owner types `run-task <folder>`,
`$run-task <folder>`, or asks to run a task, open `.claude/skills/run-task/SKILL.md` and
follow it. It points you to `.claude/skills/plan/SKILL.md`,
`.claude/skills/execute/SKILL.md`, and `.claude/skills/reflect/SKILL.md` at each step;
open each one when you reach it. The same applies to `plan`, `execute`, and `reflect` on
their own. If `./install.sh --codex` has been run, the same skills are also listed under
`.agents/skills/`, so `$run-task` and `/skills` find them.
