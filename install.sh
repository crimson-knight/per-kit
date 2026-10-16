#!/bin/sh
# install.sh: optional. Verify the kit, copy it to a working folder, and set it up for Codex.
#
# Usage:
#   ./install.sh --codex                 set up this folder for Codex
#   ./install.sh <new-folder>            copy the verified kit into <new-folder>
#   ./install.sh --codex <new-folder>    both
#
# Claude Code users can also skip it and work in place: ./verify.sh, then `claude` here.
#
# --codex copies the four skills into .agents/skills/ inside the kit folder, where Codex
# looks for project skills. Nothing is written to your home folder or global settings.
# Every step runs ./verify.sh first and stops on any failure (fail closed).

set -eu

SRC_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
codex=0
dest=""

for arg in "$@"; do
  case "$arg" in
    --codex) codex=1 ;;
    -h|--help) sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*) printf 'install.sh: unknown option %s\n' "$arg" >&2; exit 2 ;;
    *)
      if [ -n "$dest" ]; then printf 'install.sh: one folder only\n' >&2; exit 2; fi
      dest="$arg" ;;
  esac
done

if [ "$codex" -eq 0 ] && [ -z "$dest" ]; then
  sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'
  exit 2
fi

printf '== Verifying the kit in %s\n' "$SRC_DIR"
"$SRC_DIR/verify.sh"

target="$SRC_DIR"
if [ -n "$dest" ]; then
  if [ -e "$dest" ] && [ -n "$(ls -A "$dest" 2>/dev/null)" ]; then
    printf 'install.sh: %s exists and is not empty; choose a new folder\n' "$dest" >&2
    exit 1
  fi
  mkdir -p "$dest"
  target=$(CDPATH= cd -- "$dest" && pwd)
  printf '== Copying the listed files into %s\n' "$target"
  # Copy exactly the files named in SHA256SUMS, plus SHA256SUMS itself.
  sed 's/^[0-9a-f]\{64\}  //' "$SRC_DIR/SHA256SUMS" | while IFS= read -r path; do
    [ -n "$path" ] || continue
    mkdir -p "$target/$(dirname -- "$path")"
    cp -p "$SRC_DIR/$path" "$target/$path"
  done
  cp -p "$SRC_DIR/SHA256SUMS" "$target/SHA256SUMS"
  mkdir -p "$target/workspace/runs"
fi

if [ "$codex" -eq 1 ]; then
  printf '== Copying skills into %s/.agents/skills for Codex\n' "$target"
  for name in plan execute reflect run-task; do
    mkdir -p "$target/.agents/skills/$name"
    cp -p "$target/.claude/skills/$name/SKILL.md" "$target/.agents/skills/$name/SKILL.md"
  done
fi

printf '== Verifying the installed copy\n'
"$target/verify.sh"

printf '\nReady. Next:\n  cd %s\n' "$target"
if [ "$codex" -eq 1 ]; then
  printf '  codex "run-task workspace/tasks/invoice-follow-up"\n'
else
  printf '  claude    then type: /run-task workspace/tasks/invoice-follow-up\n'
fi
