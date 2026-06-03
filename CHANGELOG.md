# Changelog

All notable changes to Claude Research Kit are documented here.
The format is based on [Keep a Changelog](https://keepachangelog.com/), and this
project adheres to [Semantic Versioning](https://semver.org/).

## [0.1.0] — 2026-06-03

First release — source-grounded academic writing for LaTeX + BibTeX, with deterministic enforcement proven by a 34-scenario bench.

### The discipline
- **CLAUDE.md** ruleset — the Question → Evidence → Draft → Verify → Cite loop, Source-Grounded Writing (the no-fabrication cardinal rule), Claim Discipline, Protected Claims, calibrated language, and the reviewer-feedback self-improvement loop.
- **MANUSCRIPT_MAP.md** — the Tier-1 map (thesis, contribution, venue, section budgets, key sources, terminology lock). Plus `STYLE.md`, `CLAUDE.project.md` overlay, and `tasks/reviews/` reviewer-feedback memory.

### 14 deterministic hooks (all wired) + ResearchKitBench (34 scenarios)
- `citation-gate` (`\cite`↔`.bib`, `\ref`↔`\label`), `compile-gate` (LaTeX `.log` undefined refs/cites/errors), `stop-gate` (blocks on either verdict).
- `block-fabrication` (placeholder DOIs, empty `.bib` fields), `protect-sources` (`sources/`, `data/raw/`, `submitted/` immutable).
- `prompt-router` (calibration reminders), `word-budget`, `figure-orphan`, `unicode-scan`, `branch-protect`, `block-dangerous-commands`.
- `session-start`/`session-end`/`journal-fold` (tiered boot, audit line, across-compaction memory).

### 5 agents · 23 skills
- Agents: `peer-reviewer`, `integrity-reviewer`, `fact-checker`, `outline-planner`, `vault-maintainer`.
- Audit/write skills: `/claim-check`, `/citation-audit`, `/peer-review`, `/outline`, `/journal-fit`, `/response-to-reviewers`, `/literature-review`, `/abstract`, `/stats-check`, `/methods-review`, `/gap-finder`, `/cover-letter`, `/reference-format`, `/plain-language-summary`.
- Orchestrators: `/manuscript-cycle`, `/submission-pipeline`.
- Memory/analytics: `/note`, `/scorecard`, `/retro`, `/review-resurface`.
- Vault: `/lit-ingest`, `/lit-lint`, `/lit-briefing`.

### Modules & docs
- **Literature Vault** (`VAULT.md` + `vault/`) — annotated bibliography from raw `sources/`; `/lit-ingest` proposes the `.bib` entry from the document, never fabricated.
- **HTML Artifacts** (`ARTIFACTS.md` + `artifacts/`) — shareable HTML side-outputs (response letters, submission checklists, results tables) while the manuscript stays LaTeX.
- **7 agent_docs** + **4 field overlays** (ai-ml, life-sciences, social-sciences, medicine).

### Distribution
- `crk` CLI (`init`/`doctor`/`skills`/`convert`/`bench`), `convert.sh` → cross-tool `AGENTS.md`, `sync-manifest.sh` (+ CI staleness gate), `test-install.sh` (install→doctor→upgrade→uninstall smoke test), plugin manifests, CI on ubuntu + macOS.
- Demo content themed around **LLM-agent research** (worked example `examples/llm-agent-minimal`).

[0.1.0]: https://github.com/tansuasici/ClaudeResearchKit/releases/tag/v0.1.0
