# Episode 2: the PER loop against one direct prompt

This experiment asks whether the kit's plan, execute, reflect loop (`run-task`) does better
than giving Claude Code the same task as one direct prompt. Each run is graded by a script
against its TASK.md's DONE MEANS.

- `EXPERIMENT.md`: the first run, on v0.1.1 (16 runs, 2026-10-28).
- `RERUN_v012.md`: the rerun on v0.1.2 (32 runs, 2026-10-29).

## What the harness does

- `run_one.rb <task> <A|B> <rep>` runs one cell:
  - It copies the files listed in SHA256SUMS into a fresh folder and checks the copy with
    `verify.sh --strict`.
  - It moves this `experiments/` folder out of sight, then runs `claude -p` headless.
  - Arm A gets `/run-task workspace/tasks/<task>`, with approval given up front.
  - Arm B gets the TASK.md text as one prompt, with the loop files moved out of the copy.
  - Afterward it puts every moved file back and runs `verify.sh` on the result.
- `batch.sh <rep> <task> ...` runs arm A and arm B of each named task at the same time.
- `grade.rb <cell>` checks one cell's outputs against its task's DONE MEANS and LIMITS. It
  prints JSON with one entry per check.
- `collect.rb <out dir>` grades every cell again (set `PER_EXPERIMENT_EXPECTED_CELLS` to the
  number of runs; it stops on a missing, unfinished or failed cell). It writes `runs.tsv` (one row per run,
  with cost, minutes, tokens and checks) and `grades.json`.

## Rerun it

You need Claude Code signed in, `/usr/bin/ruby` (any Ruby 2.6 or later works), and a fresh
copy of the kit: `run_one.rb` stops if the copy differs from SHA256SUMS.

```sh
cd experiments/episode-2
export PER_EXPERIMENT_CELLS=/tmp/per-kit-episode-2/cells   # the default; keep it outside ~/.claude
sh batch.sh 1 invoice-follow-up inbox-triage               # 4 runs: both tasks, both arms, rep 1
sh batch.sh 2 invoice-follow-up inbox-triage               # rep 2
PER_EXPERIMENT_EXPECTED_CELLS=8 /usr/bin/ruby collect.rb /tmp/per-kit-episode-2   # 8 runs above; writes runs.tsv and grades.json there
```

- The four task names are `invoice-follow-up`, `inbox-triage`, `content-repurposing` and
  `lead-list-research`. The last one needs web access.
- The model defaults to `claude-sonnet-5-5`. Set `PER_EXPERIMENT_MODEL` to try another.
- Each run's progress goes to `batch.log`, next to the cells folder.
- Cost: on Sonnet 5.5, an offline run cost about $0.10 (direct prompt) to $0.25 (loop). A
  lead-list run cost $0.60 to $3.30. These are the API-equivalent figures Claude Code
  reports; on a subscription, runs count toward your usage limits instead.
- Each run passes `--setting-sources project` and excludes `~/.claude/**` from CLAUDE.md
  loading, with auto-memory and MCP servers off. Your own instructions do not reach the
  model, so the result measures the kit and not your setup.
