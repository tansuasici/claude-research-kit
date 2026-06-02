#!/usr/bin/env bash
#
# citation-gate.sh — PostToolUse hook
#
# After a .tex/.bib edit, runs deterministic manuscript verification:
#   1. Every \cite-family key resolves to an entry in a .bib file.
#   2. Every \ref-family key has a matching \label.
# Writes the verdict to `.hook-state/last_quality_gate.json` so stop-gate.sh
# can decide whether the agent may finish the turn.
#
# Does NOT block (always exits 0). Blocking happens in stop-gate.sh based on
# the persisted verdict — the quality-gate / stop-gate split mirrors the
# code kit: every edit records a verdict, only Stop enforces it.
#
# This catches the #1 research failure mode mechanically: a \cite{key} the
# agent introduced that has no real reference behind it.
#

set -euo pipefail

INPUT=$(cat)
HOOK_LIB="$(cd "$(dirname "$0")/lib" 2>/dev/null && pwd)"
source "$HOOK_LIB/json-parse.sh"

TOOL_NAME=$(parse_json_field "tool_name")
case "$TOOL_NAME" in
  Edit|Write|NotebookEdit) ;;
  *) exit 0 ;;
esac

FILE_PATH=$(parse_json_field "file_path")
[ -z "$FILE_PATH" ] && exit 0

# Only gate manuscript files.
case "$FILE_PATH" in
  *.tex|*.bib|*.ltx) ;;
  *) exit 0 ;;
esac

# Find manuscript root: nearest ancestor with a .bib, a main .tex, or .git.
DIR=$(dirname "$FILE_PATH")
ROOT="$DIR"
while [ "$ROOT" != "/" ]; do
  if ls "$ROOT"/*.bib >/dev/null 2>&1 || [ -f "$ROOT/main.tex" ] || [ -d "$ROOT/.git" ] || [ -f "$ROOT/MANUSCRIPT_MAP.md" ]; then
    break
  fi
  ROOT=$(dirname "$ROOT")
done
[ "$ROOT" = "/" ] && exit 0

STATE_DIR="$ROOT/.hook-state"
mkdir -p "$STATE_DIR" 2>/dev/null || true
[ -f "$STATE_DIR/.gitignore" ] || printf '*\n!.gitignore\n' >"$STATE_DIR/.gitignore" 2>/dev/null || true

STATE_FILE="$STATE_DIR/last_quality_gate.json"
START=$(date +%s)

# The check is parsing-heavy; do it in python3 when available. Without python3
# the gate degrades to "skipped" (never a false "passed") — fail-open here is
# acceptable because stop-gate only blocks on an explicit "failed" verdict.
if ! command -v python3 >/dev/null 2>&1; then
  exit 0
fi

python3 - "$ROOT" "$STATE_FILE" "$FILE_PATH" "$START" <<'PY' 2>/dev/null || exit 0
import json, os, re, sys, glob

root, state_file, edited, start = sys.argv[1], sys.argv[2], sys.argv[3], int(sys.argv[4])

SKIP_DIRS = {'.git', '.hook-state', '_minted', 'build', 'out', 'node_modules', '.texpadtmp'}

def walk(ext):
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        for fn in filenames:
            if fn.endswith(ext):
                yield os.path.join(dirpath, fn)

def read(p):
    try:
        with open(p, encoding='utf-8', errors='replace') as fh:
            return fh.read()
    except OSError:
        return ''

# Strip TeX comments (unescaped %) so commented-out \cite{...} don't count.
def strip_comments(s):
    out = []
    for line in s.splitlines():
        i, esc = 0, False
        cut = len(line)
        while i < len(line):
            c = line[i]
            if c == '\\':
                esc = not esc
            elif c == '%' and not esc:
                cut = i
                break
            else:
                esc = False
            i += 1
        out.append(line[:cut])
    return '\n'.join(out)

tex_files = list(walk('.tex')) + list(walk('.ltx'))
bib_files = list(walk('.bib'))

# 1. Defined bib keys: @type{key,  (skip @string/@comment/@preamble)
defined = set()
bibkey_re = re.compile(r'@(\w+)\s*\{\s*([^,\s]+)\s*,')
for bf in bib_files:
    for m in bibkey_re.finditer(read(bf)):
        if m.group(1).lower() not in ('string', 'comment', 'preamble'):
            defined.add(m.group(2))

# 2. Cited keys across all .tex. Handles \cite \citep \citet \citeauthor
#    \autocite \textcite \parencite \footcite \cite* and optional [..] args,
#    plus multi-key braces {a,b,c}.
cite_re = re.compile(
    r'\\(?:cite|citep|citet|citeauthor|citeyear|citenum|autocite|textcite|'
    r'parencite|footcite|smartcite|cites|fullcite|citealt|citealp)\*?'
    r'(?:\s*\[[^\]]*\])*\s*\{([^}]*)\}')
label_re = re.compile(r'\\label\s*\{([^}]*)\}')
ref_re = re.compile(
    r'\\(?:ref|eqref|autoref|pageref|vref|cref|Cref|crefrange|Crefrange|'
    r'nameref|labelcref)\*?\s*\{([^}]*)\}')

cited, labels, refs = set(), set(), set()
for tf in tex_files:
    body = strip_comments(read(tf))
    for m in cite_re.finditer(body):
        for k in m.group(1).split(','):
            k = k.strip()
            if k:
                cited.add(k)
    for m in label_re.finditer(body):
        labels.add(m.group(1).strip())
    for m in ref_re.finditer(body):
        for k in m.group(1).split(','):
            k = k.strip()
            if k:
                refs.add(k)

dangling_cites = sorted(c for c in cited if c not in defined)
dangling_refs = sorted(r for r in refs if r not in labels)

problems = []
if dangling_cites:
    problems.append("undefined \\cite keys (not in any .bib): " + ", ".join(dangling_cites[:25]))
if dangling_refs:
    problems.append("undefined \\ref keys (no matching \\label): " + ", ".join(dangling_refs[:25]))

status = "failed" if problems else "passed"
detail = " | ".join(problems)

verdict = {
    "status": status,
    "exit_code": 1 if problems else 0,
    "tool": "citation-gate",
    "edited_file": edited,
    "duration_seconds": 0,
    "cited_count": len(cited),
    "defined_count": len(defined),
    "dangling_cites": dangling_cites[:50],
    "dangling_refs": dangling_refs[:50],
    "stderr_tail": detail,
}
tmp = state_file + ".tmp"
with open(tmp, "w") as fh:
    json.dump(verdict, fh, indent=2)
os.replace(tmp, state_file)

if problems:
    sys.stderr.write("Citation gate FAILED: " + detail + "\n")
    sys.stderr.write("Completion will be blocked by stop-gate.sh until resolved.\n")
PY

exit 0
