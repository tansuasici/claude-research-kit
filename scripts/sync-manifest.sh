#!/usr/bin/env bash
#
# sync-manifest.sh — regenerate .kit-manifest (the list of kit-managed files)
#
#   ./scripts/sync-manifest.sh            # rewrite .kit-manifest
#   ./scripts/sync-manifest.sh --check    # exit 1 if .kit-manifest is stale (CI)
#
# The manifest tracks which files the kit owns, so `install.sh --upgrade` knows
# what to update. web/ (site assets) is intentionally excluded — it is not
# installed into a manuscript.
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

generate() {
  {
    find .claude agent_docs scripts bench bin tasks vault artifacts assets -type f \
      ! -path '*/.hook-state/*' ! -name '.DS_Store' 2>/dev/null
    for f in \
      CLAUDE.md CLAUDE.project.md MANUSCRIPT_MAP.md STYLE.md VAULT.md ARTIFACTS.md \
      AGENTS.md README.md CHANGELOG.md LICENSE VERSION \
      package.json install.sh uninstall.sh .gitignore \
      .claude-plugin/plugin.json .claude-plugin/marketplace.json \
      .github/workflows/validate.yml; do
      [ -f "$f" ] && echo "$f"
    done
  } | LC_ALL=C sort -u
}

if [ "${1:-}" = "--check" ]; then
  if diff -q <(generate) .kit-manifest >/dev/null 2>&1; then
    echo "sync-manifest: .kit-manifest is up to date ($(wc -l < .kit-manifest | tr -d ' ') entries)"
    exit 0
  fi
  echo "sync-manifest: .kit-manifest is STALE. Run ./scripts/sync-manifest.sh and commit." >&2
  echo "--- diff (expected vs committed) ---" >&2
  diff <(generate) .kit-manifest >&2 || true
  exit 1
fi

generate > .kit-manifest
echo "sync-manifest: wrote .kit-manifest ($(wc -l < .kit-manifest | tr -d ' ') entries)"
