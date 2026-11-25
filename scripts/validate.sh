#!/usr/bin/env bash
#
# validate.sh — run the same checks as .github/workflows/validate.yml, locally.
#
#   ./scripts/validate.sh          # all checks
#   ./scripts/validate.sh --quick  # skip the slower install round-trip
#
# Maintainers run this before pushing (or wire it as a pre-push hook, see
# RELEASING.md). The public repo deliberately has no self-hosted CI runner, so
# this is the gate that replaces hosted CI when it is unavailable.
#
# Exit 0 = every check passed, 1 = at least one failed.
#
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

QUICK=0
[ "${1:-}" = "--quick" ] && QUICK=1

FAILED=()
run() {
  local name="$1"; shift
  echo "── $name"
  if "$@"; then
    echo "   ok"
  else
    echo "   FAILED: $name" >&2
    FAILED+=("$name")
  fi
}

lint_json() {
  local f
  for f in .claude/settings.json hooks/hooks.json .claude-plugin/plugin.json \
           .claude-plugin/marketplace.json bench/scenarios/*.json; do
    python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$f" || { echo "   bad JSON: $f" >&2; return 1; }
  done
}

run "Lint JSON"                lint_json
run "Manifest is fresh"        ./scripts/sync-manifest.sh --check
run "Plugin layer matches"     ./scripts/check-plugin-layer.sh
run "Installation health"      ./scripts/doctor.sh
run "Hook bench"               ./scripts/run-bench.sh
if [ "$QUICK" -eq 0 ]; then
  run "Install round-trip"     ./scripts/test-install.sh
  run "Install over other kit" bash tests/install-other-kit.test.sh
fi

echo
if [ "${#FAILED[@]}" -gt 0 ]; then
  echo "validate: ${#FAILED[@]} check(s) failed: ${FAILED[*]}" >&2
  exit 1
fi
echo "validate: all checks passed"
