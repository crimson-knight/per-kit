#!/bin/sh
# verify.sh: check that this copy of the PER kit matches the published file hashes.
#
# Usage: ./verify.sh
#
# Checks, in order:
#   1. A SHA-256 tool is available (sha256sum, or shasum -a 256).
#   2. Every file listed in SHA256SUMS exists and matches its hash. The two notes files
#      you are meant to edit (workspace/preferences.md, workspace/lessons.md) are
#      reported as "edited by you" when they differ; any other mismatch fails.
#   3. Every file outside workspace/ is listed in SHA256SUMS, so no unlisted skill,
#      script, or instruction file can ride along. (.claude/settings.local.json, which
#      Claude Code writes when you approve a permission, is reported and allowed.)
#   4. Each skill has a SKILL.md whose name matches its folder and that has a description.
#   5. Each shipped task has GOAL, INPUTS, DONE MEANS, and LIMITS.
#   6. If install.sh --codex was run, .agents/skills matches .claude/skills exactly.
#
# Exit status 0 means every check passed. Any failure exits 1 (fail closed).
# The kit downloads nothing and has no third-party dependencies; the only trust root is
# the SHA-256 of SHA256SUMS itself, printed at the end, which must match the release page.

set -u
LC_ALL=C
export LC_ALL

KIT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd) || exit 1
cd "$KIT_DIR" || exit 1

failures=0
pass() { printf 'PASS  %s\n' "$1"; }
note() { printf 'NOTE  %s\n' "$1"; }
fail() { printf 'FAIL  %s\n' "$1"; failures=$((failures + 1)); }

# 1. Hash tool
if command -v sha256sum >/dev/null 2>&1; then
  hash_file() { sha256sum "$1" | awk '{print $1}'; }
  pass "hash tool: sha256sum"
elif command -v shasum >/dev/null 2>&1; then
  hash_file() { shasum -a 256 "$1" | awk '{print $1}'; }
  pass "hash tool: shasum -a 256"
else
  fail "no SHA-256 tool found (need sha256sum or shasum)"
  printf '\nRESULT: FAIL (%s problem)\n' "$failures"
  exit 1
fi

# 2. Listed files
if [ ! -f SHA256SUMS ]; then
  fail "SHA256SUMS is missing"
  printf '\nRESULT: FAIL (%s problem)\n' "$failures"
  exit 1
fi

is_user_file() {
  case "$1" in
    workspace/preferences.md|workspace/lessons.md) return 0 ;;
    *) return 1 ;;
  esac
}

listed=0
bad_lines=0
while IFS= read -r line || [ -n "$line" ]; do
  [ -z "$line" ] && continue
  expected=$(printf '%s\n' "$line" | awk '{print $1}')
  path=$(printf '%s\n' "$line" | sed 's/^[0-9a-f]\{64\}  //')
  case "$expected" in
    *[!0-9a-f]*|'') bad_lines=$((bad_lines + 1)); continue ;;
  esac
  if [ ${#expected} -ne 64 ] || [ "$path" = "$line" ]; then
    bad_lines=$((bad_lines + 1)); continue
  fi
  listed=$((listed + 1))
  if [ ! -f "$path" ]; then
    fail "missing: $path"
    continue
  fi
  actual=$(hash_file "$path")
  if [ "$actual" = "$expected" ]; then
    :
  elif is_user_file "$path"; then
    note "edited by you (allowed): $path"
  else
    fail "hash mismatch: $path"
  fi
done < SHA256SUMS
if [ "$bad_lines" -gt 0 ]; then
  fail "SHA256SUMS has $bad_lines malformed line(s)"
fi
if [ "$listed" -eq 0 ]; then
  fail "SHA256SUMS lists no files"
else
  pass "checked $listed listed files against SHA256SUMS"
fi

# 3. Unlisted files outside workspace/
unlisted=$(find . -type f \
    ! -path './.git/*' ! -path './.agents/*' ! -path './workspace/*' \
    ! -name '.DS_Store' ! -name 'SHA256SUMS' -print | sed 's#^\./##' | sort |
  while IFS= read -r f; do
    if ! awk -v p="$f" 'substr($0, 67) == p { found = 1 } END { exit !found }' SHA256SUMS; then
      printf '%s\n' "$f"
    fi
  done)
if [ -n "$unlisted" ]; then
  printf '%s\n' "$unlisted" | while IFS= read -r f; do
    if [ "$f" = ".claude/settings.local.json" ]; then
      printf 'NOTE  %s\n' "your Claude Code permission choices (allowed): $f"
    else
      printf 'FAIL  %s\n' "unlisted file outside workspace/: $f"
    fi
  done
  extra=$(printf '%s\n' "$unlisted" | grep -vc '^\.claude/settings\.local\.json$')
  failures=$((failures + extra))
fi
[ -z "$unlisted" ] || [ "${extra:-0}" -eq 0 ] && pass "no unlisted files outside workspace/"

# 4. Skills
for name in plan execute reflect run-task; do
  f=".claude/skills/$name/SKILL.md"
  if [ ! -f "$f" ]; then fail "skill missing: $f"; continue; fi
  first=$(sed -n '1p' "$f")
  fm_name=$(awk 'NR == 1 { next } /^---$/ { exit } /^name:/ { sub(/^name:[ ]*/, ""); print }' "$f")
  fm_desc=$(awk 'NR == 1 { next } /^---$/ { exit } /^description:/ { sub(/^description:[ ]*/, ""); print }' "$f")
  if [ "$first" != "---" ] || [ "$fm_name" != "$name" ] || [ -z "$fm_desc" ]; then
    fail "skill frontmatter: $f (needs ---, name: $name, description:)"
  else
    pass "skill: $name"
  fi
done

# 5. Tasks
for t in invoice-follow-up lead-list-research content-repurposing inbox-triage; do
  f="workspace/tasks/$t/TASK.md"
  if [ ! -f "$f" ]; then fail "task missing: $f"; continue; fi
  missing=""
  for section in 'GOAL:' 'INPUTS:' 'DONE MEANS:' 'LIMITS:'; do
    grep -q "^$section" "$f" || missing="$missing $section"
  done
  if [ -n "$missing" ]; then fail "task $t lacks:$missing"; else pass "task: $t"; fi
done

# 6. Codex copies
if [ -d .agents/skills ]; then
  codex_before=$failures
  for name in plan execute reflect run-task; do
    if [ -f ".agents/skills/$name/SKILL.md" ] &&
       [ "$(hash_file ".agents/skills/$name/SKILL.md")" = "$(hash_file ".claude/skills/$name/SKILL.md")" ]; then
      :
    else
      fail "Codex skill copy differs or is missing: .agents/skills/$name/SKILL.md (rerun ./install.sh --codex)"
    fi
  done
  [ "$failures" -eq "$codex_before" ] && pass "Codex skill copies match .claude/skills"
fi

sums_hash=$(hash_file SHA256SUMS)
printf '\nSHA256SUMS sha256: %s\n' "$sums_hash"
printf 'Compare it with the value on the release page before you trust this copy.\n'
if [ "$failures" -eq 0 ]; then
  printf 'RESULT: PASS\n'
  exit 0
fi
printf 'RESULT: FAIL (%s problem(s)). Get a fresh copy of the kit.\n' "$failures"
exit 1
