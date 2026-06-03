#!/usr/bin/env bash
#
# stop-gate.sh — Stop hook
#
# Blocks completion (exit 2) when the last verification verdict failed:
#   - .hook-state/last_quality_gate.json   (citation-gate.sh — static \cite/\ref)
#   - .hook-state/last_compile_gate.json   (compile-gate.sh — LaTeX .log)
# Either failing blocks. Turns the CLAUDE.md "Verification" rule — which the
# agent can ignore — into deterministic enforcement.
#
# Escape hatch: SKIP_QUALITY_GATE=1 (or CLAUDE_SKIP_QUALITY_GATE=1) for the
# session when the failure is unrelated to your change (e.g. a pre-existing
# dangling reference in a section you did not touch). Note it in
# tasks/decisions.md or tasks/handoff.md.
#

set -euo pipefail

cat > /dev/null  # consume stdin (hook protocol)

HOOK_LIB="$(cd "$(dirname "$0")/lib" 2>/dev/null && pwd)"
source "$HOOK_LIB/state-counter.sh"

ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
STATE_DIR="$ROOT/.hook-state"

# Read "status" and "stderr_tail" from a verdict file. Echoes "STATUS|DETAIL".
read_verdict() {
  local f="$1"
  [ -f "$f" ] || return 0
  if command -v python3 &>/dev/null; then
    python3 -c 'import json,sys
try:
    d=json.load(open(sys.argv[1]))
    print((d.get("status","") or "")+"|"+(d.get("stderr_tail","") or ""))
except Exception:
    pass' "$f" 2>/dev/null || true
  elif command -v jq &>/dev/null; then
    echo "$(jq -r '.status // ""' "$f" 2>/dev/null)|$(jq -r '.stderr_tail // ""' "$f" 2>/dev/null)"
  else
    echo "$(grep -oE '"status"[[:space:]]*:[[:space:]]*"[^"]*"' "$f" | head -1 | sed 's/.*:[[:space:]]*"//;s/"$//')|"
  fi
}

QUALITY="$STATE_DIR/last_quality_gate.json"
COMPILE="$STATE_DIR/last_compile_gate.json"

# No verdicts at all → nothing edited (or hooks unwired) → allow stop.
[ ! -f "$QUALITY" ] && [ ! -f "$COMPILE" ] && exit 0

# Escape hatch.
if [ "${CLAUDE_SKIP_QUALITY_GATE:-0}" = "1" ] || [ "${SKIP_QUALITY_GATE:-0}" = "1" ]; then
  bump_counter "$STATE_DIR/quality-gate-history.json" "skip_gate_used"
  echo "stop-gate: bypassed via SKIP_QUALITY_GATE" >&2
  exit 0
fi

FAILED=0
DETAILS=""
for f in "$QUALITY" "$COMPILE"; do
  v=$(read_verdict "$f")
  st="${v%%|*}"
  detail="${v#*|}"
  if [ "$st" = "failed" ]; then
    FAILED=1
    DETAILS="${DETAILS}- $(basename "$f"): ${detail:-failed}"$'\n'
  fi
done

if [ "$FAILED" = "1" ]; then
  bump_counter "$STATE_DIR/hook-firings.json" "stop-gate"
  cat <<EOF >&2
BLOCKED by stop-gate.sh: the manuscript did not pass verification.
${DETAILS}
Every \\cite must resolve in references.bib, every \\ref must have a \\label, and
the LaTeX log must be free of undefined references and errors. Fix it, or set
SKIP_QUALITY_GATE=1 if the failure predates and is unrelated to your change.
EOF
  exit 2
fi

exit 0
