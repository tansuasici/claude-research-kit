#!/usr/bin/env bash
#
# branch-protect.sh — PreToolUse hook
# Blocks direct pushes to main/master branch
#
# Reads tool input from stdin (JSON with tool_name and tool_input)
#

set -euo pipefail

INPUT=$(cat)
HOOK_LIB="$(cd "$(dirname "$0")/lib" 2>/dev/null && pwd || true)"
# Fail closed: a safety hook that can't load its library must block, not
# silently no-op. Empty HOOK_LIB → lib/ missing → exit 2 (CLA-47).
if [ -z "$HOOK_LIB" ] || [ ! -f "$HOOK_LIB/json-parse.sh" ]; then
  echo "BLOCKED: $(basename "$0") cannot load .claude/hooks/lib/ — refusing to run fail-open. Reinstall kit hooks (cck init --upgrade)." >&2
  exit 2
fi
source "$HOOK_LIB/json-parse.sh"
source "$HOOK_LIB/state-counter.sh"

ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"

bump_branch_block() {
  bump_counter "$ROOT/.hook-state/hook-firings.json" "branch-protect"
}

TOOL_NAME=$(parse_json_field "tool_name")

# Only check Bash tool
[ "$TOOL_NAME" != "Bash" ] && exit 0

COMMAND=$(parse_json_field "command")
[ -z "$COMMAND" ] && exit 0

# `git push` possibly preceded by global options like `git -c key=val push`.
# Matching the prefix means `git -c color.ui=always push origin main` can't slip by.
GIT_PUSH='git\s+(-c\s+\S+\s+)*push'

# Split the command into simple-command segments at `&&`, `||`, `;`, `|`, `&`
# and newlines, and judge each `git push` only on its OWN arguments. Before
# this, `git push -u origin feat/x && gh pr create --base main` was blocked:
# the patterns ran from `git push` to the end of the line and took the later
# `main` for a push target. (`2>&1` splits too; harmless, the push arguments
# stay in the left-hand segment.)
SEGMENTS="$COMMAND"
SEGMENTS="${SEGMENTS//&&/$'\n'}"
SEGMENTS="${SEGMENTS//||/$'\n'}"
SEGMENTS="${SEGMENTS//;/$'\n'}"
SEGMENTS="${SEGMENTS//|/$'\n'}"
SEGMENTS="${SEGMENTS//&/$'\n'}"

block_protected() {
  bump_branch_block
  echo "BLOCKED: $1"
  echo ""
  echo "Create a feature branch and open a PR instead:"
  echo "  git checkout -b feat/your-feature"
  echo "  git push -u origin feat/your-feature"
  exit 2
}

# $1 = one segment, cut so it starts at `git … push`.
check_push() {
  local PUSH="$1"

  # Force push: always block, regardless of branch. Allow --force-with-lease
  # (only overwrites if the remote matches expectations).
  if echo "$PUSH" | grep -qE -- "--force-with-lease"; then
    :
  elif echo "$PUSH" | grep -qE -- "\s--force\b|\s-f\b"; then
    bump_branch_block
    echo "BLOCKED: Force push detected"
    echo ""
    echo "Force pushing can overwrite remote history."
    echo "Consider using --force-with-lease for a safer alternative,"
    echo "or get explicit approval from the user before force pushing."
    exit 2
  fi

  # A protected branch named explicitly. Two shapes:
  #   1. main/master as a positional arg after any options:
  #      git push origin main | git push -u origin main |
  #      git push --set-upstream origin main
  #   2. a refspec whose DESTINATION is protected: HEAD:main | local:master |
  #      main:main. `git push origin main:feature` is allowed — that pushes
  #      local main to a feature branch, not to remote main.
  if echo "$PUSH" | grep -qE "^${GIT_PUSH}\s+(\S+\s+)*(main|master)(\s|$)" \
    || echo "$PUSH" | grep -qE ":(main|master)(\s|$)"; then
    block_protected "Direct push to main/master branch"
  fi

  # `git push <remote> HEAD`, or a bare `git push [-u] [origin]`, while on
  # main/master resolves to the protected branch.
  local ON_HEAD="" BARE="" CURRENT_BRANCH=""
  if echo "$PUSH" | grep -qE "^${GIT_PUSH}\s+\S+\s+HEAD\b"; then ON_HEAD=1; fi
  if echo "$PUSH" | grep -qE "^${GIT_PUSH}(\s+(-u|--set-upstream))?(\s+origin)?\s*$"; then BARE=1; fi
  [ -z "$ON_HEAD" ] && [ -z "$BARE" ] && return 0

  CURRENT_BRANCH=$(git branch --show-current 2>/dev/null) || CURRENT_BRANCH=""
  if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
    if [ -n "$ON_HEAD" ]; then
      block_protected "'git push <remote> HEAD' resolves to protected branch '$CURRENT_BRANCH'"
    fi
    block_protected "You are on '$CURRENT_BRANCH' — bare 'git push' would push to protected branch"
  fi
  return 0
}

while IFS= read -r SEGMENT; do
  PUSH_PART=$(echo "$SEGMENT" | grep -oE "${GIT_PUSH}(\s.*)?$" | head -n 1) || PUSH_PART=""
  [ -z "$PUSH_PART" ] && continue
  check_push "$PUSH_PART"
done <<< "$SEGMENTS"

exit 0
