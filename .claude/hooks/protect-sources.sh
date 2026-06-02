#!/usr/bin/env bash
#
# protect-sources.sh — PreToolUse hook
#
# Blocks edits to immutable research material:
#   - sources/      raw source material (downloaded PDFs, extracted quotes, notes)
#   - submitted/    frozen snapshots of a submitted/published version
#   - *.frozen.*    any file explicitly frozen
#   - data/raw/     raw measurement data (never edit in place)
#
# Raw sources are evidence. If the agent could rewrite the PDF text it quotes
# from, the citation chain is worthless. Edits here require the author.
#
# Escape hatch: RESEARCH_APPROVED=1 (or CLAUDE_APPROVED=1).
#

set -euo pipefail

INPUT=$(cat)
HOOK_LIB="$(cd "$(dirname "$0")/lib" 2>/dev/null && pwd || true)"
# Fail closed: a safety hook that can't load its library must block.
if [ -z "$HOOK_LIB" ] || [ ! -f "$HOOK_LIB/json-parse.sh" ]; then
  echo "BLOCKED: $(basename "$0") cannot load .claude/hooks/lib/ — refusing to run fail-open. Reinstall kit hooks." >&2
  exit 2
fi
source "$HOOK_LIB/json-parse.sh"
source "$HOOK_LIB/state-counter.sh"

ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"

TOOL_NAME=$(parse_json_field "tool_name")
case "$TOOL_NAME" in
  Edit|Write|NotebookEdit) ;;
  *) exit 0 ;;
esac

if [ "${RESEARCH_APPROVED:-0}" = "1" ] || [ "${CLAUDE_APPROVED:-0}" = "1" ]; then
  exit 0
fi

FILE_PATH=$(parse_json_field "file_path")
[ -z "$FILE_PATH" ] && exit 0

BASENAME=$(basename "$FILE_PATH")
BLOCKED=false
REASON=""

# Directory-based protection — match the path segment anywhere in the path.
case "/$FILE_PATH/" in
  */sources/*)
    BLOCKED=true; REASON="Raw source material (sources/) is immutable evidence" ;;
  */submitted/*)
    BLOCKED=true; REASON="Frozen submission snapshot (submitted/) must not change" ;;
  */data/raw/*)
    BLOCKED=true; REASON="Raw data (data/raw/) must never be edited in place" ;;
esac

# Filename-based protection.
case "$BASENAME" in
  *.frozen.*|*.frozen)
    BLOCKED=true; REASON="File is explicitly frozen (*.frozen.*)" ;;
esac

if [ "$BLOCKED" = true ]; then
  bump_counter "$ROOT/.hook-state/hook-firings.json" "protect-sources"
  echo "BLOCKED: $REASON — $FILE_PATH"
  echo ""
  echo "This is immutable research material. To derive from it, write to a NEW file"
  echo "(e.g. notes/, vault/) instead of editing the source. If you genuinely must"
  echo "change it, ask the author or set RESEARCH_APPROVED=1."
  exit 2
fi

exit 0
