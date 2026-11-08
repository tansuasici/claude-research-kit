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
#   - Negative parallelism      — "not only X but also Y", "is not X but Y"
#   - Trailing commentary       — ", highlighting …", ", underscoring …" at sentence end
#   - Turkish prose (auto-detected) — calques such as "kritik bir rol oynamaktadır",
#     "sadece X değil, aynı zamanda Y", and runs of the same sentence ending. Terms
#     that are ordinary in academic Turkish ("söz konusu", "bu bağlamda", "sonuç
#     olarak") are deliberately NOT flagged. See agent_docs/turkish-style.md.
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
import re, sys, unicodedata

# Findings quote non-ASCII text; a non-UTF-8 locale must not crash the hook silently.
sys.stdout.reconfigure(encoding="utf-8", errors="replace")

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

prose = unicodedata.normalize("NFC", strip_tex(raw) if is_tex else strip_md(raw))
# Unicode-aware, so non-ASCII letters (ı, ş, ğ, ï, …) do not fragment a word.
WORD = r"[^\W\d_](?:[^\W\d_]|['’-])+"
words = re.findall(WORD, prose)
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
# Inflected forms count toward their lemma. Left out on purpose because they are
# ordinary technical usage: "robustness" (statistics), "significantly" (statistics).
FORMS = {"tapestries": "tapestry", "testaments": "testament", "realms": "realm",
         "landscapes": "landscape", "seamlessly": "seamless", "intricately": "intricate",
         "meticulously": "meticulous", "crucially": "crucial", "profoundly": "profound",
         "remarkably": "remarkable"}
for verb in ("delve","showcase","unveil","unleash","boast","encapsulate","embark",
             "leverage","underscore","foster","bolster","garner","navigate"):
    if verb.endswith("e"):
        inflected = (verb + "s", verb + "d", verb[:-1] + "ing")
    elif verb.endswith("sh"):
        inflected = (verb + "es", verb + "ed", verb + "ing")
    else:
        inflected = (verb + "s", verb + "ed", verb + "ing")
    for form in inflected:
        FORMS[form] = verb
low = prose.lower()
counts = {}
for m in re.finditer(WORD, low):
    w = m.group(0)
    lemma = FORMS.get(w, w)
    if w in allow or lemma in allow:
        continue
    if lemma in HARD or lemma in SOFT:
        counts[lemma] = counts.get(lemma, 0) + 1
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
lens = [len(re.findall(WORD, s)) for s in sents]
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

# --- 6. Structural patterns ---
# Each is legitimate once, so a lone use in a long text only shows under
# AITELL_STRICT. They weigh more when they recur (3+ per 1000 words).
def add_structural(label, matches):
    if not matches:
        return
    n = len(matches)
    weight = min(3, n) if n * 1000.0 / nwords >= 3 else 1
    snip = re.sub(r"\s+", " ", matches[0])[:60]
    findings.append((weight, "%s x%d, e.g. \"%s…\"" % (label, n, snip)))

NEGATIVE_PARALLELISM = (
    r"\bnot (?:only|just|merely|simply)\b[^.!?;]{1,80}?\bbut\b"
    # No comma in the gap: "was not large, but it held" is plain contrast.
    r"|\b(?:is|are|was|were) not\b[^.!?;,]{1,60}?\bbut\b"
    r"|\b(?:is|are|was|were)n['’]t\b[^.!?;,]{1,60}?\bbut\b"
)
add_structural("negative parallelism (state the claim directly)",
               [m.group(0) for m in re.finditer(NEGATIVE_PARALLELISM, low)])
TRAILING = (
    r",\s+(?:thereby\s+)?(?:highlighting|underscoring|emphasi[sz]ing|showcasing|reflecting|"
    r"demonstrating|illustrating|signall?ing|reinforcing|cementing|solidifying|"
    r"paving the way|fostering|contributing to)\b[^.!?;]{0,120}[.!?]"
)
add_structural("trailing commentary clause (give the fact or cut it)",
               [m.group(0) for m in re.finditer(TRAILING, low)])

# --- 7. Turkish prose ---
# Runs only when the text is at least 1% ı/ğ/ş. Those letters are absent from English
# and frequent in Turkish, so English manuscripts with Turkish names stay out of scope.
# Patterns adapted from turkish-anti-ai-skill (MIT), https://github.com/yucezerey/turkish-anti-ai-skill
letters = re.findall(r"[^\W\d_]", prose)
tr_letters = sum(1 for c in letters if c in "ıİğĞşŞ")
if letters and tr_letters / float(len(letters)) >= 0.01:
    tr_low = prose.replace("İ", "i").replace("I", "ı").lower()
    TR_TELLS = [
        (2, r"\byadsınamaz\w*|\binkar\s+edilemez\w*"),
        (2, r"\b[aâ]deta\b"),
        (2, r"\bderinlemesine\s+(?:in(?:mek|elim|iyor|er|di)|incele)\w*|\bmercek\s+altına\s+al\w*"),
        (2, r"\b(?:kritik|kilit|hayati)\s+(?:bir\s+)?(?:rol\s+(?:oyna|üstlen)\w*|öneme\s+sahip\w*)"),
        (2, r"\bgeniş\s+bir\s+yelpaze\w*|\bzengin\s+bir\s+(?:doku|mozaik)\w*"),
        (2, r"\bgünümüzün\s+hızla\s+değişen\b|\bdijitalleşen\s+çağımızda\b"),
        (2, r"\bçığır\s+aç\w*"),
        (2, r"\bpotansiyelini\s+ortaya\s+çıkar\w*|\bbir\s+üst\s+seviyeye\s+taşı\w*"),
        (2, r"\ben\s+büyük\s+(?:kanıtı|göstergesi)\w*"),
        (2, r"\b(?:kusursuz|pürüzsüz)\s+bir\s+şekilde\b"),
        (2, r"\bbelirtmek\s+gerekir\s+ki\b|\bunutulmamalıdır\s+ki\b|\bvurgulamak\s+(?:gerekir|önemlidir)\s+ki\b"),
        (2, r"\b(?:göstermektedir|belirtmektedir|kanıtlamaktadır|ortaya\s+koymaktadır)\s+ki\b"),
        # Often figurative here, but each has a literal or field-specific use.
        (1, r"\bdönüm\s+noktası\w*|\bkilometre\s+taşı\w*"),
        (1, r"\bbütüncül\s+(?:bir\s+)?yaklaşım\w*|\bparadigma\s+değişimi\w*|\bsinerji\s+yarat\w*"),
        (1, r"\bgözler\s+önüne\s+ser\w*|\bönemini\s+bir\s+kez\s+daha\s+\w+"),
        (1, r"\bbu\s+(?:bölümde|yazıda|makalede|çalışmada)\b[^.!?]{0,80}?\b(?:ele\s+alınacaktır|incelenecektir|tartışılacaktır|ele\s+alacağız|inceleyeceğiz)\b"),
    ]
    for weight, pat in TR_TELLS:
        for m in re.finditer(pat, tr_low):
            term = re.sub(r"\s+", " ", m.group(0))
            if term not in allow:
                findings.append((weight, "Turkish cliché/calque: \"%s\"" % term[:60]))
    TR_PARALLELISM = (
        r"\b(?:sadece|yalnızca)\s[^.!?]{1,80}?\bdeğil\b[^.!?]{0,40}?\baynı\s+zamanda\b"
        r"|\b\w+m[ae]kl[ae]\s+kalma\w*"
    )
    add_structural("Turkish negative parallelism (hem X hem Y, or state Y)",
                   [m.group(0) for m in re.finditer(TR_PARALLELISM, tr_low)])

    # Repeated sentence endings. A run of -mIştIr is normal in Methods, so it needs a
    # longer run and weighs less than -mAktAdIr.
    def tr_ending(sentence):
        s = re.sub(r"(?:\s*\([^()]*\))*[\s.!?…\"'”’)]*$", "", sentence)
        last = s.split()[-1] if s.split() else ""
        if re.search(r"(?:makta|mekte)d[ıi]r(?:lar|ler)?$", last):
            return "maktadir"
        if re.search(r"m[ıiuü]şt[ıiuü]r(?:lar|ler)?$", last):
            return "mistir"
        return None
    best = {"maktadir": 0, "mistir": 0}
    previous, run = None, 0
    for sentence in re.split(r"(?<=[.!?])\s+", tr_low):
        ending = tr_ending(sentence)
        run = run + 1 if ending and ending == previous else (1 if ending else 0)
        previous = ending
        if ending:
            best[ending] = max(best[ending], run)
    if best["maktadir"] >= 3:
        findings.append((2, "Turkish rhythm: %d consecutive sentences end in -mAktAdIr (vary with the aorist or restructure)" % best["maktadir"]))
    if best["mistir"] >= 5:
        findings.append((1, "Turkish rhythm: %d consecutive sentences end in -mIştIr (usual in Methods; vary only if it reads mechanical)" % best["mistir"]))

    # Advisory ceiling, not a corpus-calibrated threshold.
    n_maktadir = len(re.findall(r"\w+(?:makta|mekte)d[ıi]r(?:lar|ler)?\b", tr_low))
    density = n_maktadir * 100.0 / nwords
    if n_maktadir >= 3 and density > 2.5:
        findings.append((1, "Turkish rhythm: -mAktAdIr x%d (%.1f / 100 words; above 2.5 is often heavy, advisory only)" % (n_maktadir, density)))

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
