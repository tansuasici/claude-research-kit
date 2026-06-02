#!/usr/bin/env bash
#
# doctor.sh — ClaudeResearchKit installation health check
#
# Verifies the kit is correctly installed: required files present, hooks
# executable and wired in settings.json, MANUSCRIPT_MAP filled in, bench runnable.
#
# Exit 0 if healthy (warnings allowed), 1 if any hard failure.
#

set -uo pipefail

ROOT="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT" || { echo "doctor: cannot cd to $ROOT" >&2; exit 1; }

G='\033[0;32m'; Y='\033[1;33m'; R='\033[0;31m'; B='\033[0;34m'; N='\033[0m'
pass=0; fail=0; warn=0
ok()   { printf "  ${G}✓${N} %s\n" "$1"; pass=$((pass+1)); }
bad()  { printf "  ${R}✗${N} %s\n" "$1"; fail=$((fail+1)); }
note() { printf "  ${Y}!${N} %s\n" "$1"; warn=$((warn+1)); }
info() { printf "  ${B}—${N} %s\n" "$1"; }

echo ""
echo "ClaudeResearchKit Doctor"
echo "========================"

echo ""
echo "  Core files"
echo "  ----------"
for f in CLAUDE.md MANUSCRIPT_MAP.md .claude/settings.json; do
  [ -f "$f" ] && ok "$f present" || bad "$f MISSING"
done

echo ""
echo "  Hooks"
echo "  -----"
HOOK_DIR=".claude/hooks"
if [ -d "$HOOK_DIR" ]; then
  for h in "$HOOK_DIR"/*.sh; do
    [ -e "$h" ] || continue
    name=$(basename "$h")
    [ -x "$h" ] || note "$name is not executable (run: chmod +x $h)"
  done
  # lib present?
  if [ -f "$HOOK_DIR/lib/json-parse.sh" ] && [ -f "$HOOK_DIR/lib/state-counter.sh" ]; then
    ok "hook lib/ present (json-parse, state-counter)"
  else
    bad "hook lib/ incomplete — safety hooks fail closed without it"
  fi
  # Each hook referenced in settings.json?
  SETTINGS=".claude/settings.json"
  if [ -f "$SETTINGS" ]; then
    for h in "$HOOK_DIR"/*.sh; do
      [ -e "$h" ] || continue
      name=$(basename "$h")
      if grep -q "$name" "$SETTINGS"; then
        ok "$name wired in settings.json"
      else
        note "$name exists but is NOT in settings.json (orphan / opt-in hook)"
      fi
    done
  fi
else
  bad "$HOOK_DIR missing"
fi

echo ""
echo "  settings.json"
echo "  -------------"
if command -v python3 >/dev/null 2>&1; then
  if python3 -c 'import json,sys; json.load(open(".claude/settings.json"))' 2>/dev/null; then
    ok "settings.json is valid JSON"
  else
    bad "settings.json is INVALID JSON"
  fi
else
  info "python3 not found — skipped JSON validation"
fi

echo ""
echo "  MANUSCRIPT_MAP"
echo "  --------------"
if [ -f MANUSCRIPT_MAP.md ]; then
  THESIS=$(awk '/^## Thesis/{f=1;next} f && /^## /{exit} f && NF && $0 !~ /^>/ {print; exit}' MANUSCRIPT_MAP.md 2>/dev/null || true)
  if [ -z "$THESIS" ] || printf '%s' "$THESIS" | grep -q '<'; then
    note "MANUSCRIPT_MAP.md Thesis is still a placeholder — fill it in (the agent reads it first)"
  else
    ok "MANUSCRIPT_MAP.md Thesis is filled in"
  fi
fi

echo ""
echo "  Agents & Skills"
echo "  ---------------"
if [ -d .claude/agents ]; then
  AC=$(find .claude/agents -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
  ok ".claude/agents/ exists ($AC agents)"
else
  note ".claude/agents/ missing"
fi
if [ -d .claude/skills ]; then
  SC=$(find .claude/skills -name 'SKILL.md' 2>/dev/null | wc -l | tr -d ' ')
  ok ".claude/skills/ exists ($SC skills)"
else
  note ".claude/skills/ missing"
fi

echo ""
echo "  Bench"
echo "  -----"
if [ -x scripts/run-bench.sh ] && [ -d bench/scenarios ]; then
  SCN=$(find bench/scenarios -name '*.json' 2>/dev/null | wc -l | tr -d ' ')
  ok "ResearchKitBench present ($SCN scenario file(s)) — run ./scripts/run-bench.sh"
else
  note "bench not found or runner not executable"
fi

echo ""
echo "  Summary"
echo "  -------"
printf "  ${G}%d passed${N}, ${R}%d failed${N}, ${Y}%d warnings${N}\n" "$pass" "$fail" "$warn"
echo ""
if [ "$fail" -gt 0 ]; then
  echo "  Installation has problems — see ✗ above."
  exit 1
fi
echo "  Installation looks healthy!"
exit 0
