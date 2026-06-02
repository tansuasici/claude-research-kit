#!/usr/bin/env bash
#
# session-end.sh — SessionEnd hook
#
# Appends one JSON audit line to reports/session-audit.log: session id,
# duration, hook firings, citation-gate pass/fail counts. Feeds /scorecard.
# Best-effort; never blocks. Always exits 0.
#

set -euo pipefail

INPUT=$(cat)
HOOK_LIB="$(cd "$(dirname "$0")/lib" 2>/dev/null && pwd)"
source "$HOOK_LIB/json-parse.sh"

ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
STATE_DIR="$ROOT/.hook-state"
REPORTS_DIR="$ROOT/reports"
mkdir -p "$REPORTS_DIR" 2>/dev/null || true

SESSION_ID=$(parse_json_field "session_id" 2>/dev/null || true)
NOW_EPOCH=$(date +%s)
NOW_ISO=$(date -u +%Y-%m-%dT%H:%M:%SZ)

command -v python3 >/dev/null 2>&1 || exit 0

python3 - "$STATE_DIR" "$REPORTS_DIR/session-audit.log" "${SESSION_ID:-}" "$NOW_EPOCH" "$NOW_ISO" <<'PY' 2>/dev/null || true
import json, os, sys
state_dir, log_file, sid, now_epoch, now_iso = sys.argv[1], sys.argv[2], sys.argv[3], int(sys.argv[4]), sys.argv[5]

def load(name):
    try:
        with open(os.path.join(state_dir, name)) as fh:
            return json.load(fh)
    except (OSError, json.JSONDecodeError):
        return {}

meta = load("session-meta.json")
firings = load("hook-firings.json")
qg = load("quality-gate-history.json")

started = meta.get("started_at_epoch")
duration = (now_epoch - started) if isinstance(started, int) else None

line = {
    "session_id": sid or meta.get("session_id", ""),
    "ended_at": now_iso,
    "duration_seconds": duration,
    "hook_firings": firings if isinstance(firings, dict) else {},
    "citation_gate_runs": qg.get("runs", 0),
    "citation_gate_failures": qg.get("failures", 0),
    "skip_gate_used": qg.get("skip_gate_used", 0),
}
with open(log_file, "a") as fh:
    fh.write(json.dumps(line) + "\n")
PY

exit 0
