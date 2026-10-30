# Episode 2 rerun on PER kit v0.1.2

Run on 2026-10-29, 17:22 to 18:10 EDT.

## Bottom line

32 runs do not separate the arms: the v0.1.2 loop passed 15 of 16 and the direct prompt passed 14 of 16, a one-run gap that is well within chance.
The fix did what it was built to do (the loop held the bad invoice in 4 of 4 runs and got cheaper and faster on the offline tasks), but it still costs about 2.2 times the direct prompt on those tasks. Its one failure, like both of the direct prompt's, was a lead list that fell short of 25 rows.

## What changed between the two runs

| | v0.1.1 (yesterday) | v0.1.2 (today) |
|---|---|---|
| Kit commit | `d952b90` (PR #1 head) | `a57641046463a21be6eb025a29a47a5372061f3b` (draft PR #2, branch `v0.1.2-reflect-reconcile`) |
| Kit change | none | reflect checks every source record's arithmetic and traces every figure; one-step local tasks take a short path (one pass, one check script, one report) |
| Runs | 2 per task per arm, 16 total | **4 per task per arm, 32 total** |
| Tasks, inputs, grader | same | same (no task or sample file changed between the commits; same `grade.rb`) |
| Model and harness | Sonnet 5.5, headless Claude Code, same flags | same |

Arm B's prompt and files are the same in both versions, because B never sees the kit's loop. Today's B runs are fresh runs, so B's spread from day to day shows how much is noise.

## Pass rate per arm

| Arm | v0.1.1 | v0.1.2 |
|---|---|---|
| A, PER loop | 7 of 8 (88%) | **15 of 16 (94%)** |
| B, direct prompt | 7 of 8 (88%) | **14 of 16 (88%)** |

The kit's `verify.sh` passed all 32 runs, as it did all 16 yesterday. It checks the kit's own files and where outputs were written, not task results. Pass or fail comes from the DONE MEANS grader.

## Cost and minutes per task per arm

Mean per run. Cost is the dollar figure Claude Code reports; minutes are wall-clock. v0.1.1 is n=2 per cell, v0.1.2 is n=4.

| Task | Arm | v0.1.1 passed | v0.1.1 $/run | v0.1.1 min/run | v0.1.2 passed | v0.1.2 $/run | v0.1.2 min/run |
|---|---|---|---|---|---|---|---|
| invoice-follow-up | A loop | 1 of 2 | $0.24 | 4.8 | 4 of 4 | $0.22 | 3.2 |
| invoice-follow-up | B direct | 2 of 2 | $0.09 | 3.1 | 4 of 4 | $0.09 | 2.1 |
| inbox-triage | A loop | 2 of 2 | $0.21 | 4.6 | 4 of 4 | $0.21 | 3.3 |
| inbox-triage | B direct | 2 of 2 | $0.09 | 3.1 | 4 of 4 | $0.09 | 2.2 |
| content-repurposing | A loop | 2 of 2 | $0.22 | 3.2 | 4 of 4 | $0.18 | 3.1 |
| content-repurposing | B direct | 2 of 2 | $0.09 | 2.1 | 4 of 4 | $0.10 | 2.6 |
| lead-list-research | A loop | 2 of 2 | $1.00 | 7.5 | 3 of 4 | $1.24 | 8.2 |
| lead-list-research | B direct | 1 of 2 | $1.94 | 7.6 | 2 of 4 | $0.81 | 5.9 |

Offline tasks (invoice, inbox and content together):

| | v0.1.1 | v0.1.2 |
|---|---|---|
| Loop cost compared with the direct prompt | 2.5× ($1.33 vs $0.54, 6 runs each) | **2.2×** ($2.43 vs $1.11, 12 runs each) |
| Loop time compared with the direct prompt | 1.5× (25.2 vs 16.7 min) | **1.4×** (38.3 vs 27.9 min) |
| Loop pass rate | 5 of 6 | **12 of 12** |

Web searches per lead-list run in v0.1.2: loop 22, 18, 77 and 12; direct 9, 19, 15 and 37. Yesterday the direct prompt had the outlier (129 searches, $3.27). Today the loop did: 77 searches cost $2.41 on run A-3. Neither arm is the steadier one on research.

## Each failure, one line

v0.1.2:
- `lead-list-research-A-4` (loop): 12 rows of 25. Its notes say it stopped rather than pad the list with unverified firms.
- `lead-list-research-B-3` (direct): no `notes.md`, and two rows with a blank website. The duplicate check counts the blanks as a pair, so it fails too.
- `lead-list-research-B-4` (direct): 24 rows of 25.

v0.1.1, for comparison:
- `invoice-follow-up-A-1` (loop): drafted a reminder for INV-1042, whose balance does not equal amount minus paid. In v0.1.2 the loop held it in 4 of 4 runs.
- `lead-list-research-B-2` (direct): 11 rows of 25. It stopped and asked.

## What Episode 2 can say from this

- The loop's invoice error from v0.1.1 is fixed: 0 of 4 v0.1.2 loop runs drafted the bad invoice (rows `invoice-follow-up-A-1` to `A-4` in `v012/runs.tsv`).
- On simple offline tasks, the loop costs about twice as much as one prompt for the same result: 12 of 12 passed in each arm.
- 32 runs show no difference in pass rate. The lead-list task is where both arms fail, by coming up short on rows.

## Files

The per-run evidence behind these tables (each run folder, `runs.tsv` and `grades.json`) stayed with the experiment and is not part of the kit. The harness in this folder produces the same files for your own runs: see `README.md`.
