#!/usr/bin/env bash
#
# compile-gate.sh — PostToolUse hook
#
# The "real build" gate. citation-gate.sh checks \cite↔.bib and \ref↔\label
# STATICALLY; compile-gate reads what LaTeX itself reported. After a .tex/.bib
# edit it parses the newest `*.log` in the manuscript root for undefined
# citations / references and compile errors, and records a verdict in
# `.hook-state/last_compile_gate.json` (stop-gate.sh blocks on it).
#
# Default mode: parse the existing log (from your own `latexmk` run). No TeX
# install needed, no slow compile — it surfaces what your last build said. If
# no log exists yet, it no-ops.
#
# Opt-in refresh: set CCK_COMPILE_GATE=1 and, when `latexmk` is available, the
# hook runs it first (timeout 120s) so the log is fresh on every edit.
#
# Never blocks here (always exits 0). Enforcement is in stop-gate.sh.
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
case "$FILE_PATH" in
  *.tex|*.bib|*.ltx) ;;
  *) exit 0 ;;
esac

# Find manuscript root (same markers as citation-gate.sh).
DIR=$(dirname "$FILE_PATH")
ROOT="$DIR"
while [ "$ROOT" != "/" ]; do
  if ls "$ROOT"/*.bib >/dev/null 2>&1 || [ -f "$ROOT/main.tex" ] || [ -d "$ROOT/.git" ] || [ -f "$ROOT/MANUSCRIPT_MAP.md" ]; then
    break
  fi
  ROOT=$(dirname "$ROOT")
done
[ "$ROOT" = "/" ] && exit 0

STATE_DIR="$ROOT/.hook-state"
mkdir -p "$STATE_DIR" 2>/dev/null || true
[ -f "$STATE_DIR/.gitignore" ] || printf '*\n!.gitignore\n' >"$STATE_DIR/.gitignore" 2>/dev/null || true

# Opt-in: refresh the log with latexmk before parsing.
run_with_timeout() {
  if command -v gtimeout >/dev/null 2>&1; then gtimeout 120 "$@"
  elif command -v timeout >/dev/null 2>&1; then timeout 120 "$@"
  else "$@"; fi
}
if [ "${CCK_COMPILE_GATE:-0}" = "1" ] && command -v latexmk >/dev/null 2>&1; then
  MAIN="$ROOT/main.tex"
  [ -f "$MAIN" ] || MAIN=$(ls "$ROOT"/*.tex 2>/dev/null | head -1 || true)
  if [ -n "${MAIN:-}" ] && [ -f "$MAIN" ]; then
    ( cd "$ROOT" && run_with_timeout latexmk -interaction=nonstopmode -halt-on-error -pdf "$(basename "$MAIN")" >/dev/null 2>&1 ) || true
  fi
fi

command -v python3 >/dev/null 2>&1 || exit 0

python3 - "$ROOT" "$STATE_DIR/last_compile_gate.json" "$FILE_PATH" <<'PY' 2>/dev/null || exit 0
import json, os, re, sys, glob

root, state_file, edited = sys.argv[1], sys.argv[2], sys.argv[3]

# Newest *.log in the root (skip nested build dirs we don't own).
logs = [p for p in glob.glob(os.path.join(root, "*.log"))]
if not logs:
    # No compile log yet → nothing to gate. Leave any prior verdict untouched.
    sys.exit(0)
log = max(logs, key=lambda p: os.path.getmtime(p))

try:
    with open(log, encoding="utf-8", errors="replace") as fh:
        text = fh.read()
except OSError:
    sys.exit(0)

problems = []

undef_cite = sorted(set(re.findall(r"Citation [`'\"]([^'\"]+)['\"] (?:on page \d+ )?undefined", text)))
undef_ref  = sorted(set(re.findall(r"Reference [`'\"]([^'\"]+)['\"] (?:on page \d+ )?undefined", text)))
if undef_cite:
    problems.append("undefined citation(s): " + ", ".join(undef_cite[:25]))
if undef_ref:
    problems.append("undefined reference(s): " + ", ".join(undef_ref[:25]))

# Hard LaTeX errors (lines beginning with "! ").
errors = [ln.strip() for ln in text.splitlines() if ln.startswith("! ")]
if errors:
    problems.append("LaTeX error: " + errors[0].lstrip("! ").strip()[:160])

# Generic catch-all the engine prints at end of run.
if "There were undefined references" in text and not (undef_cite or undef_ref):
    problems.append("there were undefined references (see the .log)")

status = "failed" if problems else "passed"
verdict = {
    "status": status,
    "exit_code": 1 if problems else 0,
    "tool": "compile-gate",
    "log_file": os.path.basename(log),
    "undefined_citations": undef_cite[:50],
    "undefined_references": undef_ref[:50],
    "stderr_tail": " | ".join(problems),
}
tmp = state_file + ".tmp"
with open(tmp, "w") as fh:
    json.dump(verdict, fh, indent=2)
os.replace(tmp, state_file)

if problems:
    sys.stderr.write("Compile gate FAILED (" + os.path.basename(log) + "): " + " | ".join(problems) + "\n")
    sys.stderr.write("Completion will be blocked by stop-gate.sh until the log is clean.\n")
PY

exit 0
