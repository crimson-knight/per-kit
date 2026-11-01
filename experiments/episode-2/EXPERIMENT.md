# Episode 2 experiment: does the PER loop beat one direct prompt?

Run on 2026-10-28, 17:28 to 17:56 EDT.

## Bottom line

On the kit's four tasks, the loop and the direct prompt tied: **each arm passed 7 of 8 runs (88%)**.
With 8 runs per arm, a tie is the honest reading; a sample this small cannot separate them.

The difference shows up in cost and in how each arm fails:

- On the three offline tasks, the loop cost **2.5 times as much** ($1.33 vs $0.54) and took **1.5 times as long** (25.3 vs 16.7 minutes) for the same or lower pass rate (5 of 6 vs 6 of 6).
- On the one web-research task, the loop was **cheaper and steadier**: $0.87 and $1.13 with 13 and 25 web searches, against $3.27 and $0.62 with 129 and 16 searches for the direct prompt.
- Each arm's one failure was different. The loop drafted a reminder for an invoice whose numbers do not add up. The direct prompt returned 11 leads of the 25 requested, and said so.

## The question

Does the free kit's plan → execute → reflect loop (the `run-task` skill) produce better results than giving the same task text to Claude Code as one direct prompt?

## Method

- **Kit:** github.com/crimson-knight/per-kit, PR #1 branch head, commit `d952b90b87a04c46b7d873a41bd82f7861fc1c8b` (v0.1.1).
- **Tasks:** the kit's four shipped tasks: invoice-follow-up, inbox-triage, content-repurposing, lead-list-research.
- **Arms:**
  - **A (PER loop):** a fresh copy of the kit with its CLAUDE.md and skills, prompted `/run-task workspace/tasks/<task>` plus "Go ahead without stopping: you have my approval of the plan up front." This is the up-front approval form that run-task supports.
  - **B (direct prompt):** a fresh copy of the kit with CLAUDE.md, AGENTS.md, `.claude/` and the kit docs moved out. It got one prompt: "Do this task now, in this folder," the full TASK.md text, where the inputs and preferences.md are, and where to write outputs. B kept the same inputs and the same preferences.md.
- **Runs:** 4 tasks × 2 arms × 2 repetitions = 16 runs, 4 at a time (one task pair, both arms, per batch).
- **Harness, identical for both arms:** Claude Code 2.1.312 headless (`claude -p`), model `claude-sonnet-5-5`, permission mode `acceptEdits`, the same allowed tools (Bash, Read, Write, Edit, Glob, Grep, WebSearch, WebFetch, Skill) and a 40-minute timeout. Owner-specific context was switched off: project settings only, the user CLAUDE.md excluded, auto-memory off, and no MCP servers. A probe run confirmed that none of Seth's personal instructions reached the model.
- **Measures:** wall-clock minutes timed from outside the CLI. Turns, tokens, web searches and cost come from Claude Code's JSON result. Tokens are summed across models, because web pages are read by Haiku. Cost is the API-equivalent dollar figure Claude Code reports. On the subscription, the real charge is the weekly-limit share.

### Grading: verify.sh plus a DONE MEANS check

- **`verify.sh` (the kit's own check), run on every run folder:** 16 of 16 PASS. verify.sh checks that the kit's files still match SHA256SUMS and that nothing was written outside `workspace/`. It does not read task output, so on its own it cannot tell a good run from a bad one. For arm B, the loop files were put back before verify.sh ran, so both arms faced the same rules. No arm B run wrote over a kit file.
- **DONE MEANS check (`grade.rb` in this folder; the runs used it from a scratch folder named `evidence/harness/`):** one scripted check per testable line in each task's DONE MEANS and LIMITS, applied the same way to both arms. Invoice has 17 checks, inbox 16, content 9 and leads 10.
  - Invoice: every row in the right tier, the bad rows held, no draft for held, grace or not-due customers, every dollar figure copied from the CSV (no totals), the sign-off, and dates written out. The shipped `grade.rb` is stricter than the one these runs used: each draft figure must now come from the row of an invoice that draft cites, matching the reconcile rule in v0.1.2.
  - Inbox: the leak, the HOA and the permit marked reply-today, one reply per reply-today message, nothing urgent archived, and no prices.
  - Content: word and character limits, no number that is not in the source, and every dollar figure in the claims table.
  - Leads: exactly 25 rows, exact columns, no duplicates, a source on every row, and at least 90% of source URLs reachable. I also checked the lead cities by hand: all are in Sacramento County or a neighboring county.
- **A run PASSES** when verify.sh passes and every DONE MEANS check passes.
- **Not checked by script:** the video script's spoken word count (130 to 160) and the quality of the writing.

## Results by task and arm

Cost is the dollar figure Claude Code reports; minutes are wall-clock.

| Task | Arm | Runs passed | Checks | Minutes (run 1, run 2) | Cost (run 1, run 2) | Web searches |
|---|---|---|---|---|---|---|
| invoice-follow-up | A loop | 1 of 2 | 31/34 | 4.87, 4.74 | $0.27, $0.20 | 0 |
| invoice-follow-up | B direct | 2 of 2 | 34/34 | 2.57, 3.70 | $0.09, $0.10 | 0 |
| inbox-triage | A loop | 2 of 2 | 32/32 | 4.24, 5.00 | $0.21, $0.21 | 0 |
| inbox-triage | B direct | 2 of 2 | 32/32 | 2.50, 3.70 | $0.09, $0.09 | 0 |
| content-repurposing | A loop | 2 of 2 | 18/18 | 1.63, 4.77 | $0.23, $0.20 | 0 |
| content-repurposing | B direct | 2 of 2 | 18/18 | 1.03, 3.17 | $0.11, $0.08 | 0 |
| lead-list-research | A loop | 2 of 2 | 20/20 | 6.01, 9.01 | $0.87, $1.13 | 13, 25 |
| lead-list-research | B direct | 1 of 2 | 19/20 | 8.31, 6.91 | $3.27, $0.62 | 129, 16 |

| Totals | Runs passed | Checks | Minutes | Cost | Output tokens |
|---|---|---|---|---|---|
| A loop | 7 of 8 (88%) | 101/104 | 40.3 | $3.33 | 241,745 |
| B direct | 7 of 8 (88%) | 103/104 | 31.9 | $4.42 | 338,371 |
| A loop, offline tasks only | 5 of 6 | 81/84 | 25.3 | $1.33 | 57,109 |
| B direct, offline tasks only | 6 of 6 | 84/84 | 16.7 | $0.54 | 25,866 |

### The two failures

- **invoice-follow-up-A-1 (loop):** INV-1042 shows a $1,800.00 balance on a $2,100.00 invoice with $500.00 paid, which should leave $1,600.00. The loop graded it "friendly" and drafted a reminder to Pinecrest Realty. Both direct runs held it as a data problem. The loop's run 2 caught it. Three checks failed.
- **lead-list-research-B-2 (direct):** it returned 11 rows of the 25 required. Its notes say it stopped rather than add rows it could not source, and it asked whether to keep searching. The output is honest, but it does not meet DONE MEANS.

## Three one-sentence on-screen claims

Each claim is backed by the named rows of `runs.tsv`.

1. "Given one research prompt and no loop, Claude ran 129 web searches and spent $3.27; with the loop, the same task took 13 searches and $0.87." (rows `lead-list-research-B-1`, `lead-list-research-A-1`)
2. "With the same model and the same invoices, the plain prompt caught a $200 error in the export that the looped run missed." (rows `invoice-follow-up-B-1`, `invoice-follow-up-A-1`)
3. "Asked for 25 sourced leads, the plain prompt found 11 and stopped to ask rather than make up the rest." (row `lead-list-research-B-2`)

## Limits of this result

- Eight runs per arm. A one-run difference in either direction is noise, so read the tie as "no difference shown," not "proven equal."
- One model (Sonnet 5.5). Opus or Haiku may behave differently.
- The DONE MEANS checks are mostly structural and exact-value checks, and both arms score near the ceiling. The loop's extra artifacts (plan, report, lessons file) are not scored, because the task does not ask for them.
- The runs went 4 at a time, so wall-clock includes shared load. Both arms ran side by side in every batch, so the load was the same for both.
- The lessons the loop writes help most on a second run of the same kit copy. Each run here started fresh, which measures a first run only.

## Harness note: the invalid first batch

The first attempt at batch 1 put the run folders under `~/.claude/jobs/…`. Claude Code treats that path as protected, so it refused arm A's `mkdir`, and both arm A runs stopped at setup. That was my harness, not the kit. The batch was set aside (kept in `evidence/invalid_batch1_protected_path/`) and rerun from `/tmp`. Only the rerun counts.

While grading I fixed three grader bugs before finalizing; every run was regraded with the final script:

- The attachment check missed the phrase "not in the export."
- A dollar-figure pattern included a trailing comma.
- My invoice answer key had INV-1042 as friendly. Arm B's run showed it is a data problem, so the key now matches the CSV.

## Files

The per-run evidence behind these tables (each run folder, `runs.tsv` and `grades.json`) stayed with the experiment and is not part of the kit. The harness in this folder produces the same files for your own runs: see `README.md`.
