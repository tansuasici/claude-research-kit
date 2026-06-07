#!/usr/bin/env bash
#
# ai-tell.sh — PostToolUse hook
#
# Flags VISIBLE machine-generated prose ("AI tells") in manuscript text, so the
# author can rewrite it in their own voice before a reviewer smells it. This is
# the visible-prose complement to unicode-scan.sh (which catches *invisible*
# characters); together they cover both halves of "this reads like an LLM wrote
# it." Scope: *.tex / *.ltx / *.md.
#
# It scans the PROSE only (TeX/Markdown markup, math, code, and \cite/\ref are
# stripped first) for:
#   - Overused lexis            — delve, tapestry, multifaceted, leverage, …
#   - Throat-clearing / filler  — "It is important to note", "When it comes to", …
#   - Meta-commentary           — "This section will discuss …" (vs. discussing)
#   - Em-dash density           — "—" used far above normal prose rate
#   - Monotonous pacing         — 5+ consecutive sentences of near-identical length
#
# Philosophy (per CLAUDE.md): it FLAGS, it never rewrites. AI-prose is a voice
# problem only the author can fix; a hook that silently "humanized" the text
# would be exactly the kind of fabrication the kit forbids. Style Calibration
# (/style-calibrate) is the constructive other half.
#
# Exit 0 = warn only (always). Tunables:
#   AITELL_MIN=N    minimum weighted score before warning (default 3)
#   AITELL_STRICT=1 lower the floor to 1 (flag even a single tell)
# Per-file silence: add "kit-allow-ai-tell" to the first 5 lines.
# Discipline terms: list them (one per line) — listed terms are never flagged —
# in either of these user-owned files (copy the shipped .example to start):
#   .claude/hooks/project/ai-tell-allow.txt   (project/ survives kit upgrades)  or
#   <project>/.ai-tell-allow.txt              (alternate project override)
# so legitimate jargon ("robust", "leverage", …) stops being flagged.
#

set -euo pipefail

INPUT=$(cat)
HOOK_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)"
HOOK_LIB="$HOOK_DIR/lib"
source "$HOOK_LIB/json-parse.sh"

TOOL_NAME=$(parse_json_field "tool_name")
case "$TOOL_NAME" in
  Edit|Write|NotebookEdit) ;;
  *) exit 0 ;;
esac

FILE_PATH=$(parse_json_field "file_path")
[ -z "$FILE_PATH" ] && exit 0
[ -f "$FILE_PATH" ] || exit 0

# Only lint manuscript prose.
case "$FILE_PATH" in
  *.tex|*.ltx|*.md) ;;
  *) exit 0 ;;
esac

# Per-file escape hatch (mirrors unicode-scan's kit-allow-unicode).
if head -5 "$FILE_PATH" | grep -q "kit-allow-ai-tell" 2>/dev/null; then
  exit 0
fi

# The analysis is parsing-heavy; do it in python3. Without python3 the hook
# degrades to a silent skip — never a false "clean".
command -v python3 >/dev/null 2>&1 || exit 0

ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
DEFAULT_ALLOW="$HOOK_DIR/project/ai-tell-allow.txt"
PROJECT_ALLOW="$ROOT/.ai-tell-allow.txt"

RESULT=$(python3 - "$FILE_PATH" "$DEFAULT_ALLOW" "$PROJECT_ALLOW" <<'PY' 2>/dev/null || true
import re, sys

path = sys.argv[1]
allow_paths = sys.argv[2:]

# --- discipline allowlist (lowercased terms that must NOT be flagged) ---
allow = set()
for ap in allow_paths:
    try:
        with open(ap, encoding="utf-8", errors="ignore") as fh:
            for line in fh:
                t = line.split("#", 1)[0].strip().lower()
                if t:
                    allow.add(t)
    except OSError:
        pass

try:
    raw = open(path, encoding="utf-8", errors="replace").read()
except OSError:
    sys.exit(0)

is_tex = path.endswith((".tex", ".ltx"))

def strip_tex(s):
    s = re.sub(r'(?<!\\)%.*', '', s)                                   # comments
    s = re.sub(r'\\begin\{(equation|align|gather|multline|figure|table|'
               r'tabular|lstlisting|verbatim|minted|tikzpicture|algorithmic)\*?\}'
               r'.*?\\end\{\1\*?\}', ' ', s, flags=re.S)               # non-prose envs
    s = re.sub(r'\$\$.*?\$\$', ' ', s, flags=re.S)                     # display math
    s = re.sub(r'\$[^$]*\$', ' ', s)                                   # inline math
    s = re.sub(r'\\(?:cite|citep|citet|citeauthor|autocite|textcite|parencite|'
               r'ref|eqref|autoref|cref|Cref|nameref|label)\w*\s*'
               r'(?:\[[^\]]*\])*\s*\{[^}]*\}', ' ', s)                 # refs/labels
    s = re.sub(r'\\[a-zA-Z@]+\*?(?:\[[^\]]*\])*', ' ', s)              # other commands
    s = re.sub(r'[{}$&~^_\\]', ' ', s)
    return s

def strip_md(s):
    s = re.sub(r'```.*?```', ' ', s, flags=re.S)                       # fenced code
    s = re.sub(r'`[^`]*`', ' ', s)                                     # inline code
    s = re.sub(r'!?\[([^\]]*)\]\([^)]*\)', r'\1', s)                   # links → text
    s = re.sub(r'^\s{0,3}#{1,6}\s+', '', s, flags=re.M)               # heading markers
    s = re.sub(r'[*_>#`]', ' ', s)
    return s

prose = strip_tex(raw) if is_tex else strip_md(raw)
words = re.findall(r"[A-Za-z][A-Za-z'-]+", prose)
nwords = len(words)
if nwords < 40:
    sys.exit(0)   # too short to judge rhythm/density meaningfully

findings = []   # (weight, text)

# --- 1. Overused lexis (figurative / LLM-favored). Discipline terms excluded. ---
HARD = {"delve","tapestry","multifaceted","seamless","showcase","unveil","unleash",
        "testament","boast","myriad","plethora","intricate","meticulous","realm",
        "interplay","tapestries","encapsulate","embark"}
SOFT = {"leverage","pivotal","underscore","foster","bolster","garner","navigate",
        "landscape","robust","crucial","vital","paramount","notably","comprehensive",
        "nuanced","profound","remarkable","significant","essential"}
low = prose.lower()
counts = {}
for m in re.finditer(r"[a-z][a-z'-]+", low):
    w = m.group(0)
    if w in allow:
        continue
    if w in HARD or w in SOFT:
        counts[w] = counts.get(w, 0) + 1
hard_terms = sorted(t for t in counts if t in HARD)
soft_terms = sorted(t for t in counts if t in SOFT)
for t in hard_terms:
    findings.append((2 if counts[t] < 3 else 3, "lexis (overused): \"%s\" x%d" % (t, counts[t])))
# Soft terms only count in aggregate, and only past a small floor (they are often legit).
soft_total = sum(counts[t] for t in soft_terms)
if soft_total >= 4:
    shown = ", ".join("%s x%d" % (t, counts[t]) for t in soft_terms)
    findings.append((min(2, soft_total // 4), "lexis (often-AI, verify in context): " + shown))

# --- 2. Throat-clearing / filler openers ---
FILLER = [
    r"it is (?:important|worth|interesting|crucial|essential) to note",
    r"it should be noted that",
    r"it is worth (?:noting|mentioning) that",
    r"needless to say",
    r"in the realm of",
    r"when it comes to",
    r"it is well known that",
    r"in today'?s (?:world|society|era|digital age)",
    r"in the world of",
    r"at the end of the day",
    r"plays? a (?:pivotal|crucial|vital|key|significant|central) role",
    r"a (?:rich )?tapestry of",
    r"stands? as a testament to",
]
for pat in FILLER:
    for m in re.finditer(pat, low):
        findings.append((2, "filler/throat-clearing: \"%s\"" % m.group(0).strip()))

# --- 3. Meta-commentary (announcing instead of doing) ---
META = [
    r"this (?:section|chapter|paper|study|article|essay) (?:will|aims to|seeks to) "
    r"(?:discuss|present|explore|examine|investigate|delve)",
    r"in this (?:section|chapter|paper),? we will",
    r"we will now (?:discuss|present|turn|explore|examine)",
    r"having (?:discussed|examined|explored) .{0,40}? we (?:now )?turn",
]
for pat in META:
    for m in re.finditer(pat, low):
        snip = re.sub(r"\s+", " ", m.group(0))[:60]
        findings.append((1, "meta-commentary: \"%s…\"" % snip))

# --- 4. Em-dash density ---
em = raw.count("—") + len(re.findall(r"(?<!-)---(?!-)", raw))   # — and LaTeX ---
if nwords:
    density = em * 1000.0 / nwords
    if em >= 4 and density > 8:
        findings.append((2, "em-dash density: %d em-dashes (%.1f / 1000 words; >8 is high)" % (em, density)))

# --- 5. Monotonous pacing: 5+ consecutive sentences of near-equal length ---
sents = [s for s in re.split(r"(?<=[.!?])\s+", prose) if s.strip()]
lens = [len(re.findall(r"[A-Za-z][A-Za-z'-]+", s)) for s in sents]
run_start = 0
i = 1
worst = 0
while i <= len(lens):
    if i < len(lens) and lens[i] >= 5 and abs(lens[i] - lens[run_start]) <= 3 and max(lens[run_start:i+1]) - min(lens[run_start:i+1]) <= 3:
        i += 1
        continue
    run_len = i - run_start
    if run_len >= 5 and min(lens[run_start:i]) >= 5:
        worst = max(worst, run_len)
    run_start = i
    i += 1
if worst >= 5:
    findings.append((2, "monotonous pacing: %d consecutive sentences of near-identical length (vary the rhythm)" % worst))

if not findings:
    sys.exit(0)

score = sum(w for w, _ in findings)
print(score)
# Strongest findings first, capped.
for w, text in sorted(findings, key=lambda x: -x[0])[:12]:
    print(text)
PY
)

[ -z "$RESULT" ] && exit 0

SCORE=$(printf '%s\n' "$RESULT" | head -1)
case "$SCORE" in ''|*[!0-9]*) exit 0 ;; esac
FINDINGS=$(printf '%s\n' "$RESULT" | tail -n +2)

FLOOR="${AITELL_MIN:-3}"
[ "${AITELL_STRICT:-0}" = "1" ] && FLOOR=1

if [ "$SCORE" -ge "$FLOOR" ]; then
  if [ -f "$HOOK_LIB/state-counter.sh" ]; then
    source "$HOOK_LIB/state-counter.sh"
    bump_counter "$ROOT/.hook-state/hook-firings.json" "ai-tell" 2>/dev/null || true
  fi
  {
    echo "ai-tell: $(basename "$FILE_PATH") reads like machine-generated prose (score ${SCORE}). Rewrite the flagged spans in your own voice:"
    printf '%s\n' "$FINDINGS" | sed 's/^/  - /'
    echo ""
    echo "These are advisory — the kit flags, it does not rewrite. Fix them by hand."
    echo "Legit jargon? add the term to .claude/hooks/project/ai-tell-allow.txt"
    echo "Silence this file? add 'kit-allow-ai-tell' to its first 5 lines."
  } >&2
fi

exit 0
