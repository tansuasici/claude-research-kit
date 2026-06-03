#!/usr/bin/env bash
#
# word-budget.sh — PostToolUse hook
#
# Warns (never blocks) when a section .tex grows past its word budget. Declare
# the budget at the top of the section file:
#
#     % budget: 800
#
# (mirror the budgets in MANUSCRIPT_MAP.md → Structure). Journals enforce length;
# this keeps a section from sprawling before you hit the limit. A 10% grace
# applies before warning. Uses `texcount` when available, else a built-in
# word counter. Always exits 0 — observability, like bash-budget in the code kit.
#

set -euo pipefail

INPUT=$(cat)
HOOK_LIB="$(cd "$(dirname "$0")/lib" 2>/dev/null && pwd)"
source "$HOOK_LIB/json-parse.sh"

TOOL_NAME=$(parse_json_field "tool_name")
case "$TOOL_NAME" in
  Edit|Write|NotebookEdit) ;;
  *) exit 0 ;;
esac

FILE_PATH=$(parse_json_field "file_path")
[ -z "$FILE_PATH" ] && exit 0
case "$FILE_PATH" in *.tex|*.ltx) ;; *) exit 0 ;; esac
[ -f "$FILE_PATH" ] || exit 0

# Budget declared as `% budget: NNN` (first 20 lines).
BUDGET=$(head -20 "$FILE_PATH" | grep -oiE '%[[:space:]]*budget:[[:space:]]*[0-9]+' | head -1 | grep -oE '[0-9]+' || true)
[ -z "$BUDGET" ] && exit 0

# Count words. Prefer texcount; fall back to a TeX-aware counter.
WORDS=""
if command -v texcount >/dev/null 2>&1; then
  WORDS=$(texcount -1 -sum -merge "$FILE_PATH" 2>/dev/null | grep -oE '^[0-9]+' | head -1 || true)
fi
if [ -z "$WORDS" ] && command -v python3 >/dev/null 2>&1; then
  WORDS=$(python3 - "$FILE_PATH" <<'PY' 2>/dev/null || true
import re, sys
s = open(sys.argv[1], encoding="utf-8", errors="replace").read()
# drop comments (unescaped %), then commands, then braces/math markers
s = re.sub(r'(?<!\\)%.*', '', s)
s = re.sub(r'\\[a-zA-Z@]+\*?', ' ', s)   # \commands
s = re.sub(r'[{}$&~^_\\]', ' ', s)
print(len(re.findall(r"[A-Za-z0-9][A-Za-z0-9'-]*", s)))
PY
)
fi
[ -z "$WORDS" ] && exit 0

# 10% grace.
THRESHOLD=$(( BUDGET + BUDGET / 10 ))
if [ "$WORDS" -gt "$THRESHOLD" ]; then
  ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
  if [ -f "$HOOK_LIB/state-counter.sh" ]; then
    source "$HOOK_LIB/state-counter.sh"
    bump_counter "$ROOT/.hook-state/hook-firings.json" "word-budget" 2>/dev/null || true
  fi
  echo "word-budget: $(basename "$FILE_PATH") is ${WORDS} words, budget ${BUDGET} (+10% grace = ${THRESHOLD}). Tighten it or raise the budget in MANUSCRIPT_MAP.md." >&2
fi

exit 0
