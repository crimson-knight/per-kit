#!/bin/sh
# tools/make-sums.sh: for kit maintainers. Regenerate SHA256SUMS from the files Git tracks.
#
# Usage: tools/make-sums.sh   (from anywhere inside the repository)
#
# Writes one "<sha256>  <path>" line per tracked file, sorted by path, leaving out
# SHA256SUMS itself. Commit the result together with the files it describes, then run
# ./verify.sh, which must print RESULT: PASS.

set -eu
LC_ALL=C
export LC_ALL

root=$(git rev-parse --show-toplevel)
cd "$root"

if command -v sha256sum >/dev/null 2>&1; then
  hasher="sha256sum"
else
  hasher="shasum -a 256"
fi

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT
git ls-files | grep -v '^SHA256SUMS$' | sort | while IFS= read -r f; do
  $hasher "$f"
done > "$tmp"
mv "$tmp" SHA256SUMS
trap - EXIT
printf 'Wrote SHA256SUMS (%s files)\n' "$(wc -l < SHA256SUMS | tr -d ' ')"
