#!/usr/bin/env bash
#
# install.sh — ClaudeResearchKit installer
#
# Copies the kit into a manuscript project. Run from inside a kit checkout:
#
#   bash install.sh [TARGET_DIR] [flags]
#
# Flags:
#   --upgrade     Update kit-managed files; never overwrite your overlay
#                 (CLAUDE.project.md, MANUSCRIPT_MAP.md, STYLE.md, tasks/, agent_docs/field, agent_docs/project)
#   --gitignore   Add kit files to the target's .gitignore (keep the kit local)
#   --dry-run     Print what would happen; change nothing
#   --force       Overwrite without prompting
#
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
TARGET="$PWD"
UPGRADE=0; GITIGNORE=0; DRYRUN=0; FORCE=0

while [ $# -gt 0 ]; do
  case "$1" in
    --upgrade) UPGRADE=1; shift ;;
    --gitignore) GITIGNORE=1; shift ;;
    --dry-run) DRYRUN=1; shift ;;
    --force) FORCE=1; shift ;;
    -h|--help) sed -n '2,17p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*) echo "Unknown flag: $1" >&2; exit 2 ;;
    *) TARGET="$1"; shift ;;
  esac
done

if [ "$SRC" = "$TARGET" ]; then
  echo "install: refusing to install the kit into itself ($SRC)." >&2
  echo "Run this from your manuscript project, pointing at a kit checkout:" >&2
  echo "  bash /path/to/ClaudeResearchKit/kit/install.sh \"\$PWD\"" >&2
  exit 2
fi

say() { printf '%s\n' "$1"; }
do_cp() {  # do_cp SRC_REL  (file or dir);  honors --upgrade overlay protection + --dry-run
  local rel="$1" overlay="${2:-0}"
  local from="$SRC/$rel" to="$TARGET/$rel"
  [ -e "$from" ] || return 0
  if [ "$overlay" = "1" ] && [ "$UPGRADE" = "1" ] && [ -e "$to" ]; then
    say "  skip (overlay, kept)   $rel"; return 0
  fi
  if [ -e "$to" ] && [ "$FORCE" = "0" ] && [ "$UPGRADE" = "0" ] && [ "$DRYRUN" = "0" ]; then
    say "  exists (use --force / --upgrade to replace)  $rel"; return 0
  fi
  if [ "$DRYRUN" = "1" ]; then say "  would copy  $rel"; return 0; fi
  mkdir -p "$(dirname "$to")"
  cp -R "$from" "$to"
  say "  copied  $rel"
}

say ""
say "ClaudeResearchKit → $TARGET"
say "  source: $SRC"
[ "$DRYRUN" = "1" ] && say "  (dry run — no changes)"
say ""

# Kit-managed (updated by --upgrade)
do_cp "CLAUDE.md"
do_cp ".claude/agents"
do_cp ".claude/hooks"
do_cp ".claude/skills"
do_cp ".claude/settings.json"
do_cp "agent_docs/writing-workflow.md"
do_cp "agent_docs/citation-discipline.md"
do_cp "agent_docs/academic-style.md"
do_cp "agent_docs/statistics.md"
do_cp "agent_docs/reproducibility.md"
do_cp "agent_docs/peer-review.md"
do_cp "scripts"
do_cp "bench"

# Project overlay (protected on --upgrade)
do_cp "CLAUDE.project.md" 1
do_cp "MANUSCRIPT_MAP.md" 1
do_cp "agent_docs/field" 1
do_cp "tasks" 1

# Hooks must stay executable
if [ "$DRYRUN" = "0" ] && [ -d "$TARGET/.claude/hooks" ]; then
  chmod +x "$TARGET"/.claude/hooks/*.sh 2>/dev/null || true
  chmod +x "$TARGET"/scripts/*.sh 2>/dev/null || true
fi

if [ "$GITIGNORE" = "1" ] && [ "$DRYRUN" = "0" ]; then
  GI="$TARGET/.gitignore"
  for line in "CLAUDE.md" ".claude/" "agent_docs/" "tasks/" "scripts/" "bench/" "MANUSCRIPT_MAP.md" "CLAUDE.project.md"; do
    grep -qxF "$line" "$GI" 2>/dev/null || echo "$line" >> "$GI"
  done
  # Always ignore transient state
  for line in ".hook-state/" "reports/"; do
    grep -qxF "$line" "$GI" 2>/dev/null || echo "$line" >> "$GI"
  done
  say "  updated .gitignore"
fi

say ""
say "Done. Next steps:"
say "  1. Fill in MANUSCRIPT_MAP.md (thesis, contribution, target venue, sections)."
say "  2. Start a Claude Code session — session-start.sh injects your map."
say "  3. Sanity-check the hooks:  ./scripts/run-bench.sh  &&  ./scripts/doctor.sh"
say ""
