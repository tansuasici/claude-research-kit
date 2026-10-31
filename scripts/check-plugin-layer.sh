#!/usr/bin/env bash
#
# check-plugin-layer.sh — fail if the plugin's root copies drift from .claude/
#
#   ./scripts/check-plugin-layer.sh       # exit 1 on drift (CI)
#
# Installed as a plugin, Claude Code (measured on 2.1.316) ignores an `agents`
# key in plugin.json and loads agents only from a root agents/ directory, and
# reads hooks only from hooks/hooks.json. Both are copies of what install.sh
# ships from .claude/, and nothing but this check stops them drifting.
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fails=0

if diff -rq .claude/agents agents >/dev/null 2>&1; then
  echo "✓ agents/ matches .claude/agents/"
else
  echo "✗ agents/ has drifted from .claude/agents/ — run: rm -rf agents && cp -R .claude/agents agents" >&2
  diff -rq .claude/agents agents 2>&1 | sed 's/^/    /' >&2 || true
  fails=$((fails + 1))
fi

# Every hook .claude/settings.json wires must be in hooks/hooks.json with the
# same event and matcher, rooted through ${CLAUDE_PLUGIN_ROOT}: an unrooted
# command resolves against the user's project in plugin mode and does nothing.
if python3 - <<'EOF'
import json, sys

ROOTED = '"${CLAUDE_PLUGIN_ROOT}"/'

def commands(path):
    hooks = json.load(open(path)).get("hooks", {})
    return [
        (event, group.get("matcher", ""), hook["command"])
        for event, groups in hooks.items()
        for group in groups
        for hook in group.get("hooks", [])
    ]

plugin = commands("hooks/hooks.json")
settings = set(commands(".claude/settings.json"))
problems = [f"not rooted through ${{CLAUDE_PLUGIN_ROOT}}: {c[2]}" for c in plugin if not c[2].startswith(ROOTED)]
stripped = {(e, m, c[len(ROOTED):] if c.startswith(ROOTED) else c) for e, m, c in plugin}
problems += [f"in settings.json only: {e} {m} {c}" for e, m, c in sorted(settings - stripped)]
problems += [f"in hooks/hooks.json only: {e} {m} {c}" for e, m, c in sorted(stripped - settings)]
for p in problems:
    print("    " + p, file=sys.stderr)
sys.exit(1 if problems else 0)
EOF
then
  echo "✓ hooks/hooks.json matches the hooks block of .claude/settings.json"
else
  echo "✗ hooks/hooks.json has drifted from .claude/settings.json" >&2
  fails=$((fails + 1))
fi

# A `hooks` key would load hooks/hooks.json a second time; an `agents` key is
# ignored by the loader and only hides that agents/ is what ships.
for key in agents hooks; do
  if python3 -c "import json,sys; sys.exit(0 if '$key' in json.load(open('.claude-plugin/plugin.json')) else 1)"; then
    echo "✗ .claude-plugin/plugin.json declares '$key' — remove it" >&2
    fails=$((fails + 1))
  fi
done

[ "$fails" -eq 0 ] || exit 1
