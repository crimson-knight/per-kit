#!/bin/sh
# Usage: sh batch.sh <rep> <task> <task> ...  runs arm A and arm B of each task in parallel.
# The log goes next to the cells: ${PER_EXPERIMENT_CELLS:-/tmp/per-kit-episode-2/cells}/../batch.log
here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd) || exit 1
cells=${PER_EXPERIMENT_CELLS:-/tmp/per-kit-episode-2/cells}
mkdir -p "$cells" || exit 1
log="$cells/../batch.log"
rep=$1; shift
for t in "$@"; do
  for a in A B; do /usr/bin/ruby "$here/run_one.rb" "$t" "$a" "$rep" >> "$log" 2>&1 & done
done
wait
echo "BATCH DONE rep=$rep $*" >> "$log"
