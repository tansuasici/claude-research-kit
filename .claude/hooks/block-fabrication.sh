#!/usr/bin/env bash
#
# block-fabrication.sh — PreToolUse hook
#
# Blocks the act of writing a fabricated reference. Inspects the content being
# written and refuses (exit 2) when it contains:
#   - a placeholder / fake-shaped DOI  (10.xxxx, 10.0000, example.com, TODO ...)
#   - a .bib entry with an empty REQUIRED field  (author = {}, title = {}, ...)
#
# Rationale: the cardinal research failure is a confident, real-looking citation
# with nothing behind it. citation-gate.sh catches \cite keys with no .bib entry
# AFTER the fact; this hook stops a fabricated .bib entry from being written in
# the FIRST place. Honest placeholders in PROSE ([CITE], [VALUE — verify]) are
# encouraged and never blocked — only fabricated *references* are.
#
# Escape hatch: RESEARCH_APPROVED=1 (or CLAUDE_APPROVED=1) — e.g. when migrating
# a legacy .bib you have independently verified.
#

set -euo pipefail

INPUT=$(cat)
HOOK_LIB="$(cd "$(dirname "$0")/lib" 2>/dev/null && pwd || true)"
# Fail closed: a safety hook that can't load its library must block, not no-op.
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

# Author-approved bypass (verified imports).
if [ "${RESEARCH_APPROVED:-0}" = "1" ] || [ "${CLAUDE_APPROVED:-0}" = "1" ]; then
  exit 0
fi

FILE_PATH=$(parse_json_field "file_path")
[ -z "$FILE_PATH" ] && exit 0

# Content being written: Write→content, Edit→new_string, Notebook→new_source.
CONTENT="$(parse_json_field "new_string")
$(parse_json_field "content")
$(parse_json_field "new_source")"
[ -z "${CONTENT// /}" ] && exit 0

BLOCKED=false
REASON=""

# --- Fake-shaped DOI (applies to any file: a fabricated DOI is always bad) ---
# Real DOIs are 10.<registrant>/<suffix>. These patterns only ever appear in a
# made-up one. Case-insensitive.
if printf '%s' "$CONTENT" | grep -qiE '10\.(x{2,}|n{3,}|0{4,}|9{4,}|_{2,}|\?{2,})(/|\b)'; then
  BLOCKED=true
  REASON="Placeholder DOI (10.xxxx / 10.0000 …) — a fabricated-looking identifier"
fi
if printf '%s' "$CONTENT" | grep -qiE 'doi[[:space:]=:{"]*(10\.[0-9]+/)?(example|placeholder|your[-_]?doi|todo|fixme|xxxx|tbd)\b'; then
  BLOCKED=true
  REASON="Placeholder DOI value (example/placeholder/your-doi/TODO …)"
fi
if printf '%s' "$CONTENT" | grep -qiE '(doi\.org/|doi[[:space:]]*=[[:space:]]*\{?)[^[:space:]}"]*example\.com'; then
  BLOCKED=true
  REASON="DOI/URL points at example.com — not a real reference"
fi

# --- Empty REQUIRED .bib field (a stub reference masquerading as real) ---
case "$FILE_PATH" in
  *.bib)
    if printf '%s' "$CONTENT" | grep -qiE '(author|editor|title|year|journal|booktitle|publisher)[[:space:]]*=[[:space:]]*\{[[:space:]]*\}'; then
      BLOCKED=true
      REASON="Empty required .bib field (author/title/year/… = {}) — fill it from the source or remove the entry"
    fi
    # Bare TODO/CITE markers inside a .bib field, committed as if real.
    if printf '%s' "$CONTENT" | grep -qiE '(author|title|year|journal)[[:space:]]*=[[:space:]]*\{[^}]*\b(TODO|FIXME|CITATION NEEDED|TBD|FILL IN)\b'; then
      BLOCKED=true
      REASON="Placeholder text inside a required .bib field"
    fi
    ;;
esac

if [ "$BLOCKED" = true ]; then
  bump_counter "$ROOT/.hook-state/hook-firings.json" "block-fabrication"
  echo "BLOCKED: $REASON"
  echo ""
  echo "File: $FILE_PATH"
  echo ""
  echo "Do not write a reference you cannot back with a real source. Either supply"
  echo "the verified metadata, or leave an honest prose placeholder ([CITE]) and"
  echo "tell the author what is missing. Bypass with RESEARCH_APPROVED=1 only for"
  echo "references you have independently verified."
  exit 2
fi

exit 0
