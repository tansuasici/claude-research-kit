#!/usr/bin/env bash
#
# uninstall.sh — remove ClaudeResearchKit from a manuscript project
#
#   bash uninstall.sh [TARGET_DIR] [flags]
#
# Flags:
#   --dry-run        Show what would be removed; change nothing
#   --keep-reviews   Preserve tasks/ (reviews, decisions, todo)
#   --keep-project   Preserve overlay (CLAUDE.project.md, MANUSCRIPT_MAP.md, STYLE.md, agent_docs/field)
#   --force          Remove without confirmation
#
set -euo pipefail

TARGET="$PWD"; DRYRUN=0; KEEP_REVIEWS=0; KEEP_PROJECT=0; FORCE=0
while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRYRUN=1; shift ;;
    --keep-reviews) KEEP_REVIEWS=1; shift ;;
    --keep-project) KEEP_PROJECT=1; shift ;;
    --force) FORCE=1; shift ;;
    -h|--help) sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*) echo "Unknown flag: $1" >&2; exit 2 ;;
    *) TARGET="$1"; shift ;;
  esac
done

KIT_MANAGED=(
  "CLAUDE.md"
  ".claude/agents" ".claude/hooks" ".claude/skills" ".claude/settings.json"
  "agent_docs/writing-workflow.md" "agent_docs/citation-discipline.md"
  "agent_docs/academic-style.md" "agent_docs/statistics.md"
  "agent_docs/reproducibility.md" "agent_docs/peer-review.md"
  "scripts" "bench" ".hook-state" "reports"
)
OVERLAY=( "CLAUDE.project.md" "MANUSCRIPT_MAP.md" "STYLE.md" "agent_docs/field" )
REVIEWS=( "tasks" )

to_remove=( "${KIT_MANAGED[@]}" )
[ "$KEEP_PROJECT" = "0" ] && to_remove+=( "${OVERLAY[@]}" )
[ "$KEEP_REVIEWS" = "0" ] && to_remove+=( "${REVIEWS[@]}" )

echo ""
echo "ClaudeResearchKit uninstall → $TARGET"
[ "$DRYRUN" = "1" ] && echo "  (dry run)"
echo ""
for rel in "${to_remove[@]}"; do
  p="$TARGET/$rel"
  [ -e "$p" ] || continue
  echo "  remove  $rel"
done

if [ "$DRYRUN" = "1" ]; then echo ""; echo "Dry run — nothing removed."; exit 0; fi
if [ "$FORCE" = "0" ]; then
  printf "\nProceed? [y/N] "; read -r ans
  case "$ans" in y|Y|yes) ;; *) echo "Aborted."; exit 0 ;; esac
fi
for rel in "${to_remove[@]}"; do rm -rf "${TARGET:?}/$rel"; done
echo ""
echo "Removed. (agent_docs/ and tasks/ kept if you passed --keep-*.)"
