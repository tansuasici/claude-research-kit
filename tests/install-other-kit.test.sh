#!/usr/bin/env bash
#
# install-other-kit.test.sh — install.sh and uninstall.sh next to another Claude kit
#
# Usage: bash tests/install-other-kit.test.sh
#        OTHER_KITS=/dir bash tests/install-other-kit.test.sh
#
# The other kit is faked: the two files only it ships and a CLAUDE.md are all
# the check looks at, and all a refused run must leave alone.
#
# With OTHER_KITS set to a folder holding checkouts named marketing, code and
# design, the last section also runs their real installers, in both orders.
# CI doesn't, so its result doesn't depend on those repos' main branches.
#
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

KIT="$PWD"
pass=0; fail=0
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

ok()  { pass=$((pass + 1)); printf '  ok   %s\n' "$1"; }
bad() { fail=$((fail + 1)); printf '  FAIL %s\n%s\n' "$1" "$2"; }

fresh_dir() { mktemp -d "$work/repo.XXXXXX"; }

KITS=(marketing code design)

# add_other_kit DIR KIT → DIR now also holds the two files only that kit ships
add_other_kit() {
  mkdir -p "$1/.claude/hooks"
  case "$2" in
    marketing) printf 'x\n' | tee "$1/MARKETING_MAP.md" > "$1/.claude/hooks/claim-scan.sh" ;;
    code)      printf 'x\n' | tee "$1/.claude/hooks/secret-scan.sh" > "$1/.claude/hooks/commit-gate.sh" ;;
    design)  printf 'x\n' | tee "$1/DESIGN_MAP.md" > "$1/.claude/hooks/motion-gate.sh" ;;
  esac
}

# other_kit KIT → a folder that looks like another kit's install
other_kit() {
  local d; d=$(fresh_dir)
  add_other_kit "$d" "$1"
  printf 'other kit rules\n' > "$d/CLAUDE.md"
  printf 'other kit hook\n' > "$d/.claude/hooks/session-start.sh"
  printf '%s' "$d"
}

snapshot() { (cd "$1" && find . -type f -exec cksum {} + | LC_ALL=C sort); }

# refuses LABEL SCRIPT DIR [FLAGS…] → exit 2, the reason on stderr, the folder untouched
refuses() {
  local label="$1" script="$2" dir="$3"; shift 3
  local before out code
  before=$(snapshot "$dir")
  out=$(bash "$KIT/$script" "$dir" "$@" 2>&1 </dev/null); code=$?
  if [ "$code" -eq 2 ] && [[ "$out" == *"another Claude kit"* ]] && [ "$(snapshot "$dir")" = "$before" ]; then
    ok "$label"
  else
    bad "$label" "  exit=$code: $out"
  fi
}

# passes LABEL EXIT OUTPUT [TEST…] → EXIT is 0 and the test command, if any, holds
passes() {
  local label="$1" code="$2" output="$3"; shift 3
  if [ "$code" -eq 0 ] && { [ $# -eq 0 ] || "$@"; }; then ok "$label"; else bad "$label" "  exit=$code: $output"; fi
}
has()     { [ -e "$1" ]; }
gone()    { [ ! -e "$1" ]; }
is_mine() { [ "$(cat "$1")" = "mine" ]; }

echo "install refuses another kit's folder"
for kit in "${KITS[@]}"; do
  refuses "install: $kit" install.sh "$(other_kit "$kit")"
done
refuses "install --force"   install.sh "$(other_kit marketing)" --force
refuses "install --upgrade" install.sh "$(other_kit marketing)" --upgrade
refuses "install --dry-run" install.sh "$(other_kit marketing)" --dry-run

echo "uninstall refuses another kit's folder"
for kit in "${KITS[@]}"; do
  refuses "uninstall: $kit" uninstall.sh "$(other_kit "$kit")" --force
done
refuses "uninstall --dry-run"      uninstall.sh "$(other_kit marketing)" --dry-run
refuses "uninstall --keep-project" uninstall.sh "$(other_kit marketing)" --force --keep-project

echo "uninstall and upgrade refuse when both kits are here"
for kit in "${KITS[@]}"; do
  d=$(fresh_dir); bash "$KIT/install.sh" "$d" >/dev/null 2>&1; add_other_kit "$d" "$kit"
  refuses "uninstall: this kit and $kit" uninstall.sh "$d" --force
  refuses "upgrade: this kit and $kit"   install.sh   "$d" --upgrade
done

echo "not another kit: a map or a hook alone"
for map in MARKETING_MAP.md CODEBASE_MAP.md DESIGN_MAP.md; do
  d=$(fresh_dir); printf 'mine\n' > "$d/$map"
  out=$(bash "$KIT/install.sh" "$d" 2>&1); code=$?
  passes "a repo's own $map installs" "$code" "$out" has "$d/MANUSCRIPT_MAP.md"
  out=$(bash "$KIT/install.sh" "$d" --upgrade 2>&1); code=$?
  passes "and this kit upgrades next to it" "$code" "$out"
  out=$(bash "$KIT/uninstall.sh" "$d" --force 2>&1); code=$?
  passes "and uninstalls next to it" "$code" "$out" gone "$d/MANUSCRIPT_MAP.md"
  passes "and it stays" 0 "" is_mine "$d/$map"
done

d=$(fresh_dir); mkdir -p "$d/.claude/hooks"; printf 'mine\n' > "$d/.claude/hooks/session-start.sh"
out=$(bash "$KIT/install.sh" "$d" 2>&1); code=$?
passes "a repo's own session-start hook installs" "$code" "$out" has "$d/MANUSCRIPT_MAP.md"
passes "and stays" 0 "" is_mine "$d/.claude/hooks/session-start.sh"

echo "the subfolder the message points at"
d=$(other_kit marketing); before=$(snapshot "$d")
msg=$(bash "$KIT/install.sh" "$d" 2>&1)
if [[ "$msg" == *"$d/research"* ]]; then ok "the refusal names the subfolder"; else bad "the refusal names the subfolder" "  $msg"; fi
out=$(bash "$KIT/install.sh" "$d/research" 2>&1); code=$?
passes "installs into the subfolder" "$code" "$out" has "$d/research/.claude/hooks/citation-gate.sh"
out=$(bash "$KIT/install.sh" "$d/research" --upgrade 2>&1); code=$?
passes "upgrades in the subfolder" "$code" "$out"
out=$(bash "$KIT/uninstall.sh" "$d/research" --force 2>&1); code=$?
passes "uninstalls from the subfolder" "$code" "$out" gone "$d/research/CLAUDE.md"
rm -rf "$d/research"
if [ "$(snapshot "$d")" = "$before" ]; then ok "the root kit is untouched"; else bad "the root kit is untouched" "  root changed"; fi

echo "this kit alone still installs, upgrades and uninstalls"
d=$(fresh_dir)
out=$(bash "$KIT/install.sh" "$d" 2>&1); code=$?
passes "install" "$code" "$out" has "$d/CLAUDE.md"
out=$(bash "$KIT/install.sh" "$d" --upgrade 2>&1); code=$?
passes "upgrade" "$code" "$out"
out=$(bash "$KIT/uninstall.sh" "$d" --force 2>&1); code=$?
passes "uninstall" "$code" "$out" gone "$d/MANUSCRIPT_MAP.md"

echo "the way out the uninstall message gives"
d=$(other_kit marketing)
mv "$d/MARKETING_MAP.md" "$work/moved.md"
out=$(bash "$KIT/uninstall.sh" "$d" --force --keep-project --keep-reviews 2>&1); code=$?
mv "$work/moved.md" "$d/MARKETING_MAP.md"
passes "moving the map aside lets it run" "$code" "$out" has "$d/MARKETING_MAP.md"

if [ -z "${OTHER_KITS:-}" ]; then
  echo "real kits: skipped, OTHER_KITS is not set"
else
  # install_other KIT[:PROFILE] DIR. The Code Kit installs into the current folder.
  install_other() {  # KIT[:PROFILE] DIR [FLAGS…]
    local kit="$1" dir="$2"; shift 2
    case "$kit" in
      code:*) (cd "$dir" && bash "$OTHER_KITS/code/install.sh" --local "$OTHER_KITS/code" --profile "${kit#code:}" "$@") ;;
      *)      bash "$OTHER_KITS/$kit/install.sh" "$dir" "$@" ;;
    esac </dev/null >/dev/null 2>&1
  }
  restore_flag() { case "$1" in code:*) echo --upgrade ;; *) echo --force ;; esac; }
  # marker KIT → the file of that kit's pair the refusal names first
  marker() {
    case "$1" in
      marketing) echo MARKETING_MAP.md ;;
      code:*)    echo .claude/hooks/secret-scan.sh ;;
      design)  echo DESIGN_MAP.md ;;
    esac
  }

  echo "real kits, in both orders"
  for kit in marketing code:minimal code:standard code:strict design; do
    d=$(fresh_dir); git -C "$d" init -q
    if ! install_other "$kit" "$d"; then bad "$kit installs" "  exit=$?"; continue; fi
    refuses "$kit first: install"         install.sh "$d"
    refuses "$kit first: install --force" install.sh "$d" --force
    refuses "$kit first: uninstall"       uninstall.sh "$d" --force

    d=$(fresh_dir); git -C "$d" init -q; bash "$KIT/install.sh" "$d" >/dev/null 2>&1
    before=$(snapshot "$d")
    install_other "$kit" "$d"; code=$?
    if [ "$code" -eq 2 ] && [ "$(snapshot "$d")" = "$before" ]; then
      ok "this kit first: $kit refuses and changes nothing"
    else
      bad "this kit first: $kit refuses and changes nothing" "  exit=$code"
    fi

    # Two kits in one folder, as an installer without this check left them. The
    # overlay and task files are the first kit's: installers keep those.
    d=$(fresh_dir); git -C "$d" init -q; install_other "$kit" "$d"
    before=$(snapshot "$d")
    mine=$(fresh_dir); bash "$KIT/install.sh" "$mine" >/dev/null 2>&1
    rsync -a --exclude CLAUDE.project.md --exclude linear.md --exclude tasks "$mine/" "$d/"
    refuses "$kit and this kit: uninstall" uninstall.sh "$d" --force
    refuses "$kit and this kit: upgrade"   install.sh   "$d" --upgrade

    # The way out the message gives, followed to the end.
    mark=$(marker "$kit")
    mv "$d/$mark" "$work/moved"
    out=$(bash "$KIT/uninstall.sh" "$d" --force --keep-project --keep-reviews 2>&1); code=$?
    mkdir -p "$(dirname "$d/$mark")"; mv "$work/moved" "$d/$mark"
    passes "$kit and this kit: the way out removes this kit" "$code" "$out" gone "$d/.claude/hooks/citation-gate.sh"
    install_other "$kit" "$d" "$(restore_flag "$kit")"; code=$?
    missing=$(LC_ALL=C comm -13 <(snapshot "$d") <(printf '%s\n' "$before"))
    if [ "$code" -eq 0 ] && [ -z "$missing" ]; then
      ok "$kit and this kit: rerunning $kit's installer restores all its files"
    else
      bad "$kit and this kit: rerunning $kit's installer restores all its files" "  exit=$code, missing or changed: $missing"
    fi
  done
fi

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
