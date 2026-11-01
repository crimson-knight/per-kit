#!/bin/sh
# Usage: sh batch.sh <rep> <task> <task> ...  runs arm A and arm B of each task in parallel.
# The log goes next to the cells: ${PER_EXPERIMENT_CELLS:-/tmp/per-kit-episode-2/cells}/../batch.log
# Exits non-zero, and logs BATCH FAILED, when any run exits non-zero.
here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd) || exit 1
cells=${PER_EXPERIMENT_CELLS:-/tmp/per-kit-episode-2/cells}
mkdir -p "$cells" || exit 1
log="$cells/../batch.log"
if [ "$#" -lt 2 ]; then
  echo "usage: sh batch.sh <rep> <task> [<task> ...]" >&2
  exit 2
fi
rep=$1; shift
pids=""
for t in "$@"; do
  for a in A B; do
    /usr/bin/ruby "$here/run_one.rb" "$t" "$a" "$rep" >> "$log" 2>&1 &
    pids="$pids $!:$t/$a"
  done
done
failed=""
for entry in $pids; do
  pid=${entry%%:*}
  if ! wait "$pid"; then failed="$failed ${entry#*:}"; fi
done
if [ -n "$failed" ]; then
  echo "BATCH FAILED rep=$rep runs:$failed" >> "$log"
  exit 1
fi
echo "BATCH DONE rep=$rep $*" >> "$log"
