#!/usr/bin/env bash
#
# session-start.sh — SessionStart hook
#
# Injects minimal Tier 1 context at session start (manuscript map pointer,
# thesis, stage/target venue, top reviewer rules, active task, branch + dirty
# tree). Replaces the CLAUDE.md "Session Boot" rule, which depends on the agent
# voluntarily following it. Output: JSON with `additionalContext`. Exits 0.
#

set -euo pipefail

INPUT=$(cat)
HOOK_LIB="$(cd "$(dirname "$0")/lib" 2>/dev/null && pwd)"
source "$HOOK_LIB/json-parse.sh"
source "$HOOK_LIB/state-counter.sh"

ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
STATE_DIR="$ROOT/.hook-state"
mkdir -p "$STATE_DIR" 2>/dev/null || true
[ -f "$STATE_DIR/.gitignore" ] || printf '*\n!.gitignore\n' >"$STATE_DIR/.gitignore" 2>/dev/null || true

# Reset transient session counters from any prior session.
reset_state "$STATE_DIR/hook-firings.json"
reset_state "$STATE_DIR/quality-gate-history.json"
# Clear the verdict stop-gate.sh reads: citation-gate only overwrites it on a
# .tex/.bib edit, so a "failed" verdict from a prior session would otherwise
# persist and block a new session that makes no manuscript edit.
reset_state "$STATE_DIR/last_quality_gate.json"

# Session metadata for session-end.sh.
SESSION_ID=$(parse_json_field "session_id" 2>/dev/null || true)
NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)
NOW_EPOCH=$(date +%s)
if command -v python3 &>/dev/null; then
  python3 - "$STATE_DIR/session-meta.json" "${SESSION_ID:-}" "$NOW" "$NOW_EPOCH" <<'PY' 2>/dev/null || true
import json, os, sys
f, sid, now_iso, now_epoch = sys.argv[1], sys.argv[2], sys.argv[3], int(sys.argv[4])
tmp = f + ".tmp"
with open(tmp, "w") as fh:
    json.dump({"session_id": sid, "started_at": now_iso, "started_at_epoch": now_epoch}, fh, indent=2)
os.replace(tmp, f)
PY
fi

CONTEXT=""
append_line() { CONTEXT="${CONTEXT}${1}"$'\n'; }

append_line "[Auto-injected by session-start.sh]"
append_line ""

# 1. Manuscript map + thesis
if [ -f "$ROOT/MANUSCRIPT_MAP.md" ]; then
  append_line "Manuscript map: MANUSCRIPT_MAP.md is present. Read it before drafting."
  THESIS=$(awk '/^## Thesis/{f=1;next} f && /^## /{exit} f && NF && $0 !~ /^>/ {print; exit}' "$ROOT/MANUSCRIPT_MAP.md" 2>/dev/null || true)
  if [ -n "$THESIS" ] && ! printf '%s' "$THESIS" | grep -q '<'; then
    append_line "Thesis → $THESIS"
  fi
  STAGE=$(grep -iE '^\*\*Stage:' "$ROOT/MANUSCRIPT_MAP.md" 2>/dev/null | head -1 | sed 's/^[*]*[Ss]tage:[*]*[[:space:]]*//' || true)
  [ -n "$STAGE" ] && ! printf '%s' "$STAGE" | grep -q '<' && append_line "Stage → $STAGE"
fi
[ -f "$ROOT/CLAUDE.project.md" ] && append_line "Project overlay: CLAUDE.project.md present — project rules override kit defaults."
[ -f "$ROOT/STYLE.md" ] && append_line "Style guide: STYLE.md present — match its voice and formatting."

# 2. Top reviewer rules (recurring feedback)
REVIEWS_INDEX="$ROOT/tasks/reviews/_index.md"
if [ -f "$REVIEWS_INDEX" ]; then
  TOP_RULES=$(awk '/^## Top Rules/{f=1;next} f && /^## /{exit} f && NF{print; n++; if(n>=8) exit}' "$REVIEWS_INDEX" 2>/dev/null || true)
  if [ -n "$TOP_RULES" ]; then
    append_line ""
    append_line "Top rules from prior reviewer feedback:"
    append_line "$TOP_RULES"
  fi
fi

# 3. Active task
TODO="$ROOT/tasks/todo.md"
if [ -f "$TODO" ]; then
  ACTIVE=$(awk '/^## In Progress/{f=1;next} f && /^## /{exit} f && /^### /{print; exit}' "$TODO" 2>/dev/null || true)
  [ -n "$ACTIVE" ] && { append_line ""; append_line "Active task in tasks/todo.md → $ACTIVE"; }
fi

# 4. Branch + dirty tree
if command -v git &>/dev/null && [ -d "$ROOT/.git" ]; then
  BRANCH=$(git -C "$ROOT" branch --show-current 2>/dev/null || true)
  [ -n "$BRANCH" ] && { append_line ""; append_line "Branch: $BRANCH"; }
  PORCELAIN=$(git -C "$ROOT" status --porcelain 2>/dev/null || true)
  if [ -n "$PORCELAIN" ]; then
    MOD_COUNT=$(printf '%s\n' "$PORCELAIN" | grep -cE '^( M|M |MM|AM| A| D| R)' 2>/dev/null || true)
    UNT_COUNT=$(printf '%s\n' "$PORCELAIN" | grep -cE '^\?\?' 2>/dev/null || true)
    append_line ""
    append_line "Working tree (uncommitted):"
    [ "${MOD_COUNT:-0}" -gt 0 ] && append_line "- ${MOD_COUNT} modified file(s)"
    [ "${UNT_COUNT:-0}" -gt 0 ] && append_line "- ${UNT_COUNT} untracked file(s)"
    append_line "- Are these part of the active task? If not, flag before proceeding."
  fi
fi

NONEMPTY=$(printf '%s' "$CONTEXT" | grep -cE '^[^[:space:]]' || true)
if [ "${NONEMPTY:-0}" -lt 3 ]; then
  exit 0
fi

if command -v python3 &>/dev/null; then
  printf '%s' "$CONTEXT" | python3 -c 'import json,sys; print(json.dumps({"additionalContext": sys.stdin.read()}))'
elif command -v jq &>/dev/null; then
  printf '%s' "$CONTEXT" | jq -Rs '{additionalContext: .}'
else
  ESCAPED=$(printf '%s' "$CONTEXT" | sed 's/\\/\\\\/g; s/"/\\"/g' | awk 'BEGIN{ORS=""} {print; printf "\\n"}')
  printf '{"additionalContext":"%s"}\n' "$ESCAPED"
fi

exit 0
