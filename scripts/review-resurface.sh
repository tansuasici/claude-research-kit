#!/usr/bin/env bash
#
# review-resurface.sh — deterministic frontmatter scan + scoring for /review-resurface
#
# Backs the `/review-resurface` skill: scans tasks/reviews/ (+ _archive/), scores
# reviewer-feedback notes by `applies_to` topic overlap with the task summary,
# and prints the top-5 pointers (paths + frontmatter only — NEVER bodies). Lets
# a session recover a dormant reviewer rule without bloating Tier-1 boot.
#
# Usage:
#   ./scripts/review-resurface.sh "<task summary>"
#   REVIEW_QUERY="<task summary>" ./scripts/review-resurface.sh
#
# Exit codes:
#   0  matches found OR clean no-match (vocabulary miss)
#   1  tasks/reviews/ does not exist
#   2  usage error (no query supplied)
#
set -uo pipefail

QUERY="${1:-${REVIEW_QUERY:-}}"
ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
REVIEWS_DIR="$ROOT/tasks/reviews"
ARCHIVE_DIR="$REVIEWS_DIR/_archive"

[ -d "$REVIEWS_DIR" ] || { echo "review-resurface: $REVIEWS_DIR does not exist" >&2; exit 1; }
[ -n "$QUERY" ] || { echo "review-resurface: usage: $0 \"<task summary>\" (or set REVIEW_QUERY)" >&2; exit 2; }

# Extract a frontmatter field (YAML block between the first pair of --- markers).
get_field() {
  awk -v field="$2" '
    BEGIN { in_fm=0; count=0 }
    /^---$/ { count++; if (count==1){in_fm=1; next} if (count==2) exit }
    in_fm && $0 ~ "^" field ":" { sub("^" field ": *",""); print; exit }
  ' "$1"
}

list_reviews() {
  for f in "$REVIEWS_DIR"/*.md; do
    [ -f "$f" ] || continue
    local b; b=$(basename "$f")
    [ "$b" = "_TEMPLATE.md" ] && continue
    [ "$b" = "_index.md" ] && continue
    printf '%s\n' "$f"
  done
  if [ -d "$ARCHIVE_DIR" ]; then
    for f in "$ARCHIVE_DIR"/*.md; do [ -f "$f" ] && printf '%s\n' "$f"; done
  fi
}

# Phase 1 — build the applies_to vocabulary, match the query against it.
VOCAB=""
while IFS= read -r f; do
  raw=$(get_field "$f" "applies_to")
  [ -z "$raw" ] && continue
  VOCAB="${VOCAB}$(printf '%s' "$raw" | tr -d "[]\"'" | tr ',' '\n' | tr -d ' ')"$'\n'
done < <(list_reviews)
VOCAB=$(printf '%s' "$VOCAB" | grep -v '^$' | sort -u)

QUERY_LOWER=$(printf '%s' "$QUERY" | tr '[:upper:]' '[:lower:]')
MATCHED=""
while IFS= read -r topic; do
  [ -z "$topic" ] && continue
  printf '%s' "$QUERY_LOWER" | grep -q -- "$topic" && MATCHED="${MATCHED}${topic}"$'\n'
done <<<"$VOCAB"
MATCHED=$(printf '%s' "$MATCHED" | grep -v '^$' || true)

if [ -z "$MATCHED" ]; then
  echo "No matching topics in the reviews applies_to vocabulary; nothing to resurface."
  exit 0
fi
TOPICS_LIST=$(printf '%s' "$MATCHED" | tr '\n' ' ')

# Phase 2 — score: +3 per applies_to topic hit, +1 if top_rule:true.
SCORED=""
while IFS= read -r f; do
  applies_to=$(get_field "$f" "applies_to")
  top_rule=$(get_field "$f" "top_rule")
  title=$(get_field "$f" "title")
  date=$(get_field "$f" "date")
  applies_clean=" $(printf '%s' "$applies_to" | tr -d "[]\"'" | tr ',' ' ') "
  score=0
  for topic in $TOPICS_LIST; do
    printf '%s' "$applies_clean" | grep -wq -- "$topic" && score=$((score+3))
  done
  [ "$top_rule" = "true" ] && score=$((score+1))
  [ "$score" -gt 0 ] && SCORED="${SCORED}${score}"$'\t'"${f}"$'\t'"${applies_to}"$'\t'"${date}"$'\t'"${title}"$'\n'
done < <(list_reviews)

SCORED=$(printf '%s' "$SCORED" | grep -v '^$' | sort -t$'\t' -k1,1 -rn || true)
TOPICS_CSV=$(printf '%s' "$MATCHED" | tr '\n' ',' | sed 's/,$//; s/,/, /g')

if [ -z "$SCORED" ]; then
  printf 'No reviews match topics [%s]. Proceed with the Top Rules already in context.\n' "$TOPICS_CSV"
  exit 0
fi

# Phase 3 — emit top-5 pointers (paths + frontmatter only).
echo "Matched reviewer notes for topics [$TOPICS_CSV]:"
echo ""
TOTAL=$(printf '%s\n' "$SCORED" | grep -c '^' 2>/dev/null || echo 0); [ -z "$TOTAL" ] && TOTAL=0
COUNT=0
while IFS=$'\t' read -r score path applies_to date title; do
  [ -z "$path" ] && continue
  COUNT=$((COUNT+1)); [ "$COUNT" -gt 5 ] && break
  echo "$COUNT. ${path#$ROOT/}"
  echo "   applies_to: $applies_to"
  echo "   date: $date | title: $title"
  echo ""
done <<<"$SCORED"
[ "$TOTAL" -gt 5 ] && { echo "… $((TOTAL-5)) more matched (not shown)."; echo ""; }
echo "These are pointers, not content. Read any that look relevant; the bodies were intentionally NOT loaded."
exit 0
