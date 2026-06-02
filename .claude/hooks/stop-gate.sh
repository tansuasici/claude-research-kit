#!/usr/bin/env bash
#
# stop-gate.sh — Stop hook
#
# Reads `.hook-state/last_quality_gate.json` and blocks completion (exit 2)
# when the last citation gate failed (dangling \cite or \ref). Turns the
# CLAUDE.md "Verification (Mandatory Order)" rule — which the agent can
# ignore — into deterministic enforcement.
#
# Escape hatch: set SKIP_QUALITY_GATE=1 (or CLAUDE_SKIP_QUALITY_GATE=1) for
# the session when the failure is unrelated to your change (e.g. a pre-existing
# dangling reference in a section you did not touch). Note the bypass in
# tasks/decisions.md or tasks/handoff.md.
#

set -euo pipefail

cat > /dev/null  # consume stdin (hook protocol)

HOOK_LIB="$(cd "$(dirname "$0")/lib" 2>/dev/null && pwd)"
source "$HOOK_LIB/state-counter.sh"

ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
STATE_FILE="$ROOT/.hook-state/last_quality_gate.json"

# No verdict → no manuscript edit happened → allow stop.
[ ! -f "$STATE_FILE" ] && exit 0

if [ "${CLAUDE_SKIP_QUALITY_GATE:-0}" = "1" ] || [ "${SKIP_QUALITY_GATE:-0}" = "1" ]; then
  bump_counter "$ROOT/.hook-state/quality-gate-history.json" "skip_gate_used"
  echo "stop-gate: bypassed via SKIP_QUALITY_GATE" >&2
  exit 0
fi

STATUS=""
DETAIL=""
if command -v python3 &>/dev/null; then
  STATUS=$(python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); print(d.get("status",""))' "$STATE_FILE" 2>/dev/null || true)
  DETAIL=$(python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); print(d.get("stderr_tail",""))' "$STATE_FILE" 2>/dev/null || true)
elif command -v jq &>/dev/null; then
  STATUS=$(jq -r '.status // ""' "$STATE_FILE" 2>/dev/null || true)
  DETAIL=$(jq -r '.stderr_tail // ""' "$STATE_FILE" 2>/dev/null || true)
else
  STATUS=$(grep -oE '"status"[[:space:]]*:[[:space:]]*"[^"]*"' "$STATE_FILE" | head -1 | sed 's/.*:[[:space:]]*"//;s/"$//' || true)
fi

if [ "$STATUS" = "failed" ]; then
  bump_counter "$ROOT/.hook-state/hook-firings.json" "stop-gate"
  cat <<EOF >&2
BLOCKED by stop-gate.sh: the manuscript has unresolved references.
$DETAIL
State: $STATE_FILE

Every \\cite must resolve in references.bib and every \\ref must have a \\label.
Fix the dangling key(s), or set SKIP_QUALITY_GATE=1 if the failure predates and
is unrelated to your change.
EOF
  exit 2
fi

exit 0
