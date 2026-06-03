# Changelog

All notable changes to Claude Research Kit are documented here.
The format is based on [Keep a Changelog](https://keepachangelog.com/), and this
project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- **Literature Vault module** (TAN-3609) — `VAULT.md` schema + `vault/` annotated bibliography (`summaries/<bibkey>.md`, `concepts/`, `entities/`). `/lit-ingest` (a source → annotated summary + a `references.bib` entry *extracted from the document*, never fabricated), `/lit-lint`, `/lit-briefing`, and the `vault-maintainer` agent. Self-contained, offline; raw `sources/` immutable.
- **8 manuscript skills** (TAN-3610) — `/literature-review`, `/abstract`, `/stats-check`, `/methods-review`, `/gap-finder`, `/cover-letter`, `/reference-format`, `/plain-language-summary`. Brings the kit to **17 skills, 5 agents**.
- **Distribution tooling** (TAN-3614) — `crk` CLI gains `skills` (list `/skills`) and `convert` (export `CLAUDE.md` → `AGENTS.md` + Cursor/Windsurf/Aider). `scripts/convert.sh`, `scripts/sync-manifest.sh` (+ `--check` CI staleness gate), `scripts/test-install.sh` (install → doctor → upgrade → uninstall smoke test, CI on ubuntu + macOS), and a generated `AGENTS.md`. *(npm publish + marketplace listing pending the maintainer's token.)*
- **3 field overlays** (TAN-3612) — `life-sciences` (ARRIVE/STROBE/PRISMA, IRB/IACUC, wet-lab reproducibility, figure integrity), `social-sciences` (APA 7, preregistration/replication, construct validity, qualitative coding), `medicine` (CONSORT/STROBE/SPIRIT, trial registration, ARR/NNT, bias). Joins `ai-ml` — **4 overlays**.
- **2 orchestrators** (TAN-3613) — `/manuscript-cycle` (end-to-end lifecycle for a section: outline → ground → draft → verify → review → revise, halting on any gate) and `/submission-pipeline` (parallel peer + integrity + fact-checker + audits, deduped + confidence-gated go/no-go report). Both `mode:headless`-capable. Kit → **19 skills**.
- **3 deterministic hooks** (TAN-3611) — `compile-gate` (parses the LaTeX `.log` for undefined citations/references and errors → its own verdict; `stop-gate` now blocks on the citation **or** compile gate), `word-budget` (warns past a section's `% budget: NNN`, `texcount`-optional), `figure-orphan` (orphan floats, unused/missing figure assets). **13 hooks**; ResearchKitBench → **32 scenarios**.

### Changed
- Re-themed all demo content from environmental chemistry to **LLM-agent research** — the worked example (`examples/llm-agent-minimal`), the field overlay (`environmental-science` → `ai-ml`), and scattered illustrative examples across skills / agents / agent_docs. The public repo no longer carries a specific personal research domain. (TAN-3608)

## [0.1.0] — 2026-06-03

Foundation release. The deterministic spine, proven by a 24-scenario bench.

### Added
- **CLAUDE.md** — source-grounded research ruleset: the Question → Evidence → Draft → Verify → Cite loop, Source-Grounded Writing (the no-fabrication cardinal rule), Claim Discipline, Protected Claims, calibrated language, and the reviewer-feedback self-improvement loop.
- **MANUSCRIPT_MAP.md** — the Tier-1 project map (thesis, contribution, target venue, section budgets, key sources, terminology lock).
- **10 deterministic hooks**, all wired:
  - `citation-gate` — every `\cite` resolves in `references.bib`; every `\ref` has a `\label`.
  - `block-fabrication` — refuses placeholder/fake-shaped DOIs and empty required `.bib` fields; allows honest `[CITE]` prose placeholders.
  - `protect-sources` — `sources/`, `data/raw/`, and frozen `submitted/` are immutable.
  - `stop-gate` — blocks completion on a failed citation verdict.
  - `prompt-router` — calibration reminders on overclaim / statistics / causation / citation / reviewer / methods inflections.
  - `session-start` / `session-end` — tiered boot + audit line.
  - Reused from the code-kit lineage: `branch-protect`, `block-dangerous-commands`, `unicode-scan`, plus the `lib/` helpers.
- **ResearchKitBench** — 24 deterministic scenarios (`bench/`) + `run-bench.sh`; CI on ubuntu + macOS.
- **4 agents** — `peer-reviewer`, `integrity-reviewer`, `fact-checker`, `outline-planner`.
- **6 skills** — `/claim-check`, `/citation-audit`, `/peer-review`, `/outline`, `/journal-fit`, `/response-to-reviewers`.
- **7 agent_docs** — writing-workflow, citation-discipline, academic-style, statistics, reproducibility, peer-review, and the ai-ml field overlay.
- **Tooling** — `doctor.sh`, MIT license, plugin manifests, project overlay, reviewer-feedback memory (`tasks/reviews/`), ADR decisions log.

[0.1.0]: https://github.com/tansuasici/ClaudeResearchKit/releases/tag/v0.1.0
