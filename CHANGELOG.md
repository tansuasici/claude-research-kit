# Changelog

All notable changes to Claude Research Kit are documented here.
The format is based on [Keep a Changelog](https://keepachangelog.com/), and this
project adheres to [Semantic Versioning](https://semver.org/).

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
- **7 agent_docs** — writing-workflow, citation-discipline, academic-style, statistics, reproducibility, peer-review, and the environmental-science field overlay.
- **Tooling** — `doctor.sh`, MIT license, plugin manifests, project overlay, reviewer-feedback memory (`tasks/reviews/`), ADR decisions log.

[0.1.0]: https://github.com/tansuasici/ClaudeResearchKit/releases/tag/v0.1.0
