#!/usr/bin/env bash
#
# convert.sh — export the kit ruleset to other AI coding tools.
#
#   ./scripts/convert.sh [all|agents-md|cursor|windsurf|aider]
#
# CLAUDE.md is the single source of truth. These outputs are ONE-WAY derived —
# never edit them by hand; re-run this after changing CLAUDE.md. Targets:
#   agents-md  → AGENTS.md                        (agents.md cross-tool standard)
#   cursor     → .cursor/rules/claude-research-kit.md
#   windsurf   → .windsurfrules
#   aider      → CONVENTIONS.md
#
set -euo pipefail

# Operate on the current directory: from the kit checkout this is the kit;
# via `crk convert` it is the user's manuscript project. CLAUDE.md is the source.
ROOT="$PWD"
SRC="$ROOT/CLAUDE.md"
[ -f "$SRC" ] || { echo "convert: CLAUDE.md not found in $ROOT — run this from a project with CLAUDE.md" >&2; exit 1; }

TARGET="${1:-all}"

banner() {
  cat <<EOF
<!--
  Generated from CLAUDE.md by scripts/convert.sh — DO NOT EDIT BY HAND.
  CLAUDE.md is the single source of truth for ClaudeResearchKit.
  Re-run: ./scripts/convert.sh $1
-->

EOF
}

emit() {  # emit <target-file> <self-name>
  local out="$1" name="$2"
  mkdir -p "$(dirname "$out")"
  { banner "$name"; cat "$SRC"; } > "$out"
  echo "convert: wrote $out"
}

case "$TARGET" in
  agents-md) emit "AGENTS.md" "agents-md" ;;
  cursor)    emit ".cursor/rules/claude-research-kit.md" "cursor" ;;
  windsurf)  emit ".windsurfrules" "windsurf" ;;
  aider)     emit "CONVENTIONS.md" "aider" ;;
  all)
    emit "AGENTS.md" "agents-md"
    emit ".cursor/rules/claude-research-kit.md" "cursor"
    emit ".windsurfrules" "windsurf"
    emit "CONVENTIONS.md" "aider"
    ;;
  *) echo "convert: unknown target '$TARGET' (use: all|agents-md|cursor|windsurf|aider)" >&2; exit 2 ;;
esac
