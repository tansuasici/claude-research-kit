#!/usr/bin/env bash
#
# figure-orphan.sh — PostToolUse hook
#
# Warns (never blocks) about display-item hygiene that static \ref↔\label
# checking misses — the REVERSE direction and the asset files:
#   - orphan floats   : a \label{fig:/tab:} that is never \ref'd in the text
#   - unused assets   : a file in figures/ that no \includegraphics uses
#   - missing graphics: an \includegraphics{X} whose file does not exist
#
# Reviewers reject papers with an unreferenced figure or a broken include.
# Always exits 0 — observability.
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
case "$FILE_PATH" in *.tex|*.ltx) ;; *) exit 0 ;; esac

DIR=$(dirname "$FILE_PATH")
ROOT="$DIR"
while [ "$ROOT" != "/" ]; do
  if ls "$ROOT"/*.bib >/dev/null 2>&1 || [ -f "$ROOT/main.tex" ] || [ -d "$ROOT/.git" ] || [ -f "$ROOT/MANUSCRIPT_MAP.md" ]; then
    break
  fi
  ROOT=$(dirname "$ROOT")
done
[ "$ROOT" = "/" ] && exit 0

command -v python3 >/dev/null 2>&1 || exit 0

WARN=$(python3 - "$ROOT" <<'PY' 2>/dev/null || true
import os, re, sys
root = sys.argv[1]
SKIP = {'.git', '.hook-state', '_minted', 'build', 'out', 'node_modules'}
IMG = ('.pdf', '.png', '.jpg', '.jpeg', '.eps', '.svg', '.tikz')

def walk(ext):
    for dp, dns, fns in os.walk(root):
        dns[:] = [d for d in dns if d not in SKIP]
        for fn in fns:
            if fn.endswith(ext):
                yield os.path.join(dp, fn)

def strip_comments(s):
    out = []
    for line in s.splitlines():
        i, esc, cut = 0, False, len(line)
        while i < len(line):
            c = line[i]
            if c == '\\': esc = not esc
            elif c == '%' and not esc: cut = i; break
            else: esc = False
            i += 1
        out.append(line[:cut])
    return '\n'.join(out)

float_label_re = re.compile(r'\\label\s*\{\s*((?:fig|tab|alg|lst):[^}]+)\}')
ref_re = re.compile(r'\\(?:ref|eqref|autoref|pageref|vref|cref|Cref|nameref|labelcref)\*?\s*\{([^}]*)\}')
inc_re = re.compile(r'\\includegraphics(?:\s*\[[^\]]*\])?\s*\{([^}]+)\}')

labels, refs, includes = set(), set(), set()
for tf in list(walk('.tex')) + list(walk('.ltx')):
    try:
        body = strip_comments(open(tf, encoding='utf-8', errors='replace').read())
    except OSError:
        continue
    labels |= {m.group(1).strip() for m in float_label_re.finditer(body)}
    for m in ref_re.finditer(body):
        refs |= {k.strip() for k in m.group(1).split(',') if k.strip()}
    includes |= {m.group(1).strip() for m in inc_re.finditer(body)}

problems = []

orphans = sorted(l for l in labels if l not in refs)
if orphans:
    problems.append("orphan float(s) — labeled but never \\ref'd: " + ", ".join(orphans[:15]))

# Missing graphics: each include path must resolve to a file (try as-is + extensions).
def resolves(p):
    cands = [p] + [p + e for e in IMG]
    for c in cands:
        if os.path.isabs(c) and os.path.isfile(c):
            return True
        if os.path.isfile(os.path.join(root, c)):
            return True
    return False

missing = sorted(p for p in includes if not resolves(p))
if missing:
    problems.append("missing graphic file(s): " + ", ".join(missing[:15]))

# Unused assets in figures/ — basename (no ext) referenced by no include.
inc_basenames = {os.path.splitext(os.path.basename(p))[0] for p in includes}
figdirs = [os.path.join(root, d) for d in ('figures', 'fig', 'images', 'img') if os.path.isdir(os.path.join(root, d))]
unused = []
for fd in figdirs:
    for fn in os.listdir(fd):
        stem, ext = os.path.splitext(fn)
        if ext.lower() in IMG and stem not in inc_basenames:
            unused.append(os.path.relpath(os.path.join(fd, fn), root))
if unused:
    problems.append("unused asset(s) in figures/ (never \\includegraphics'd): " + ", ".join(sorted(unused)[:15]))

if problems:
    print("\n".join(problems))
PY
)

if [ -n "$WARN" ]; then
  ROOTDIR="${CLAUDE_PROJECT_DIR:-$ROOT}"
  if [ -f "$HOOK_LIB/state-counter.sh" ]; then
    source "$HOOK_LIB/state-counter.sh"
    bump_counter "$ROOTDIR/.hook-state/hook-firings.json" "figure-orphan" 2>/dev/null || true
  fi
  echo "figure-orphan:" >&2
  printf '%s\n' "$WARN" | sed 's/^/  - /' >&2
fi

exit 0
