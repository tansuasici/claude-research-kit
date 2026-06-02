#!/usr/bin/env bash
#
# prompt-router.sh — UserPromptSubmit hook
#
# Inspects the user prompt and injects a research-discipline reminder when the
# task touches a high-risk inflection (overclaim, statistics, causal language,
# citations, reviewer response). Replaces "remember to calibrate" prompt rules
# the agent forgets. Emits nothing when no keyword matches. Always exits 0.
#

set -euo pipefail

INPUT=$(cat)

PROMPT=""
if command -v python3 &>/dev/null; then
  PROMPT=$(printf '%s' "$INPUT" | python3 -c 'import sys,json; d=json.load(sys.stdin); print(d.get("prompt",""))' 2>/dev/null || true)
elif command -v jq &>/dev/null; then
  PROMPT=$(printf '%s' "$INPUT" | jq -r '.prompt // ""' 2>/dev/null || true)
else
  PROMPT=$(printf '%s' "$INPUT" | grep -oE '"prompt"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*:[[:space:]]*"//;s/"$//' || true)
fi

[ -z "$PROMPT" ] && exit 0
LOWER=$(printf '%s' "$PROMPT" | tr '[:upper:]' '[:lower:]')

REMINDERS=""
append() { REMINDERS="${REMINDERS}${1}"$'\n'; }

# Stems without a trailing \b so inflections match (signific+ance/antly, caus+es/ation).

# Overclaim / results framing
if printf '%s' "$LOWER" | grep -qE '\b(result|finding|we (found|show|demonstrate|prove)|novel|first to|best|outperform|breakthrough|conclusi)'; then
  append "[Claim calibration] Match every verb and quantifier to what the evidence licenses. 'associated with' ≠ 'causes'; 'suggests' ≠ 'proves'; 'in our sample' ≠ 'in general'. Each results sentence is either cited, the authors' own data, or out. No claim of novelty/superiority without the comparison that establishes it."
fi

# Statistics / quantitative reporting
if printf '%s' "$LOWER" | grep -qE '\b(p-?value|signific|correlat|regress|confidence interval|sample size|effect size|t-?test|anova|odds ratio|stat)'; then
  append "[Statistics] Report effect size + uncertainty (CI), not just significance. State N, the test, and assumptions. 'Significant' means statistically significant — never use it to mean 'large' or 'important'. No p-hacking, no HARKing. See agent_docs/statistics.md."
fi

# Causal language
if printf '%s' "$LOWER" | grep -qE '\b(caus|effect of|impact of|leads? to|results? in|due to|because of|drives?)'; then
  append "[Causation] Observational evidence rarely licenses causal claims. Default to associational language unless the design (RCT, natural experiment, identified model) supports causation. State the assumption explicitly."
fi

# Citations / literature
if printf '%s' "$LOWER" | grep -qE '\b(cite|citation|reference|bibliograph|literature|prior work|related work|background)'; then
  append "[Sourcing] Never invent a citation, author, year, DOI, or page. Every \\cite must resolve in references.bib. If the source is not in the library, say so and leave a [CITE] placeholder — do not fabricate one. See agent_docs/citation-discipline.md."
fi

# Reviewer response / revision
if printf '%s' "$LOWER" | grep -qE '\b(reviewer|referee|rebuttal|response to|revision|resubmi|major revision|minor revision|r1|r2)'; then
  append "[Reviewer response] Address every point explicitly, quote the reviewer, state the change + where (section/line), and stay courteous. Do not claim a change you have not made. Log recurring critiques to tasks/reviews/. See agent_docs/peer-review.md."
fi

# Methods
if printf '%s' "$LOWER" | grep -qE '\b(method|protocol|procedure|experimental setup|materials and methods|reproducib)'; then
  append "[Methods] Write for reproduction: exact quantities, instruments, versions, settings, and analysis steps. Changing what the methods SAY was done is a protected change — confirm with the author."
fi

[ -z "$REMINDERS" ] && exit 0

if command -v python3 &>/dev/null; then
  printf '%s' "$REMINDERS" | python3 -c 'import json,sys; print(json.dumps({"additionalContext": sys.stdin.read().rstrip()}))'
elif command -v jq &>/dev/null; then
  printf '%s' "$REMINDERS" | jq -Rs '{additionalContext: (. | rtrimstr("\n"))}'
else
  ESCAPED=$(printf '%s' "$REMINDERS" | sed 's/\\/\\\\/g; s/"/\\"/g' | awk 'BEGIN{ORS=""} {print; printf "\\n"}')
  printf '{"additionalContext":"%s"}\n' "$ESCAPED"
fi

exit 0
