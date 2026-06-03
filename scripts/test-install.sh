#!/usr/bin/env bash
#
# test-install.sh — smoke-test install → doctor → upgrade → uninstall on a
# throwaway directory. Proves the installer wires a usable kit and the
# uninstaller removes it cleanly. CI runs this on ubuntu + macOS.
#
# Exit 0 = all steps passed, 1 = a step failed.
#
set -uo pipefail

KIT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d 2>/dev/null || mktemp -d -t crk-test)"
trap 'rm -rf "$TMP"' EXIT

fail() { echo "  ✗ $1" >&2; exit 1; }
ok()   { echo "  ✓ $1"; }

echo "test-install: target $TMP"
# A manuscript project needs a project marker for the hooks' root-finding.
( cd "$TMP" && git init -q 2>/dev/null || true )

echo "[1/5] install"
bash "$KIT/install.sh" "$TMP" --force >/dev/null 2>&1 || fail "install.sh failed"
for f in CLAUDE.md MANUSCRIPT_MAP.md .claude/settings.json .claude/hooks/citation-gate.sh agent_docs/writing-workflow.md scripts/doctor.sh bench/scenarios; do
  [ -e "$TMP/$f" ] || fail "missing after install: $f"
done
[ -x "$TMP/.claude/hooks/citation-gate.sh" ] || fail "hook not executable after install"
ok "installed; key files present + hooks executable"

echo "[2/5] doctor"
bash "$TMP/scripts/doctor.sh" "$TMP" >/dev/null 2>&1 || fail "doctor reported failures on a fresh install"
ok "doctor healthy"

echo "[3/5] citation-gate works in the installed copy"
printf '@article{real,author={X},title={Y},year={2020}}\n' > "$TMP/references.bib"
printf '\\documentclass{article}\\begin{document}\\cite{ghost}\\end{document}\n' > "$TMP/main.tex"
echo "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$TMP/main.tex\"}}" \
  | CLAUDE_PROJECT_DIR="$TMP" bash "$TMP/.claude/hooks/citation-gate.sh" >/dev/null 2>&1 || true
ST=$(python3 -c 'import json,sys;print(json.load(open(sys.argv[1])).get("status",""))' "$TMP/.hook-state/last_quality_gate.json" 2>/dev/null || echo "")
[ "$ST" = "failed" ] || fail "citation-gate did not flag a dangling \\cite (got: '$ST')"
ok "citation-gate flagged the dangling cite"

echo "[4/5] upgrade (idempotent; keeps overlay)"
echo "MY PROJECT RULE" >> "$TMP/CLAUDE.project.md" 2>/dev/null || echo "MY PROJECT RULE" > "$TMP/CLAUDE.project.md"
bash "$KIT/install.sh" "$TMP" --upgrade >/dev/null 2>&1 || fail "upgrade failed"
grep -q "MY PROJECT RULE" "$TMP/CLAUDE.project.md" || fail "upgrade clobbered the project overlay"
ok "upgrade preserved the overlay"

echo "[5/5] uninstall"
bash "$KIT/uninstall.sh" "$TMP" --force >/dev/null 2>&1 || fail "uninstall failed"
[ -e "$TMP/CLAUDE.md" ] && fail "CLAUDE.md still present after uninstall"
[ -e "$TMP/.claude/hooks" ] && fail ".claude/hooks still present after uninstall"
ok "uninstalled cleanly"

echo "test-install: PASS"
exit 0
