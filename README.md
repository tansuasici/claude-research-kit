<h1 align="center">Claude Research Kit</h1>

<p align="center">Drop-in templates that make Claude Code behave like a rigorous co-author instead of an eager intern — for scholarly writing in LaTeX&nbsp;+&nbsp;BibTeX.</p>

## The Problem

Out of the box, Claude Code writes *fluent* academic prose — which is exactly the danger. It will:
- Invent a citation, DOI, author, or page number that looks real but isn't
- State a statistic or measured value it doesn't actually have
- Overclaim — "causes" where the evidence only licenses "is associated with"
- Drift off the thesis and pad sections with plausible filler
- Quote a source it never read, with no locator

In code, a hallucination breaks the build and you find out. In a manuscript, a hallucinated citation **looks correct** — and survives to peer review, or print.

## The Solution

This kit provides a `CLAUDE.md` instruction set, **deterministic hooks**, review agents, and skills that enforce one discipline:

**Question → Evidence → Draft → Verify → Cite** — every time.

The cardinal rule the whole kit exists to enforce: **every claim traces to a real source; never invent a citation, DOI, quote, or quantity; never overclaim beyond the evidence.**

## Quick Start

```bash
# clone into your manuscript repo
git clone --depth 1 https://github.com/tansuasici/ClaudeResearchKit.git /tmp/crk
cp /tmp/crk/kit/CLAUDE.md /tmp/crk/kit/MANUSCRIPT_MAP.md /tmp/crk/kit/CLAUDE.project.md .
cp -r /tmp/crk/kit/.claude /tmp/crk/kit/agent_docs /tmp/crk/kit/tasks .
rm -rf /tmp/crk
```

Then **fill in `MANUSCRIPT_MAP.md`** with your thesis, contribution, target venue, and section plan — it is the single most important file, read first every session — and start a Claude Code session.

Or with the CLI (once published to npm):

```bash
npx @tansuasici/claude-research-kit init      # install into the current dir
npx @tansuasici/claude-research-kit doctor     # check installation health
npx @tansuasici/claude-research-kit skills      # list the /skills
npx @tansuasici/claude-research-kit convert     # export CLAUDE.md → AGENTS.md (+ Cursor/Windsurf/Aider)
```

> The CLI and installers work today from a clone; the npm-published `npx` package and the plugin-marketplace listing are pending a release. See the roadmap.

## What CLAUDE.md Enforces

| Rule | What it does |
|------|-------------|
| **Tiered Session Boot** | Loads the manuscript map, thesis, venue, and active task first — not the whole corpus |
| **Source-Grounded Writing** | The cardinal rule: no invented citations, DOIs, quotes, or quantities — ever |
| **Claim Discipline** | Every sentence is cited, the author's own argument, or common knowledge — nothing else |
| **Protected Claims** | Stops for approval before changing the thesis, a reported number, methods, or an argument-bearing citation |
| **Verification** | Citations resolve → quotes match → claims supported → numbers consistent → cross-refs → compiles |
| **Calibrated Language** | Matches verbs and quantifiers to what the evidence licenses (`suggests` ≠ `proves`) |
| **Reviewer Memory** | Logs recurring reviewer feedback to `tasks/reviews/` and reviews the Top Rules each session |

## Hooks

Hooks are shell scripts that run automatically — unlike CLAUDE.md rules (advisory), hooks are **deterministic**. The kit ships **13** hooks, all wired by default.

**Guardrails — block on violation (PreToolUse / Stop):**

| Hook | Event | What it does |
|------|------|-------------|
| `block-fabrication` | PreToolUse | Blocks writing a fabricated reference — placeholder/fake-shaped DOIs (`10.xxxx`, `example.com`) and empty required `.bib` fields. Honest prose placeholders (`[CITE]`) are never blocked |
| `protect-sources` | PreToolUse | Blocks edits to `sources/` (raw evidence), `data/raw/`, and frozen `submitted/` snapshots |
| `branch-protect` | PreToolUse | Blocks push to `main`/`master` and force pushes |
| `block-dangerous-commands` | PreToolUse | Blocks `rm -rf /`, `git reset --hard`, etc. |
| `citation-gate` | PostToolUse | After a `.tex`/`.bib` edit: every `\cite` must resolve in `references.bib`; every `\ref` must have a `\label`. Records the verdict |
| `compile-gate` | PostToolUse | Parses the LaTeX `.log` for undefined citations/references and errors; records a verdict (opt-in `CCK_COMPILE_GATE=1` refreshes via `latexmk`) |
| `stop-gate` | Stop | Blocks completion when the last citation **or** compile gate failed (bypass: `SKIP_QUALITY_GATE=1`) |

**Context & observability — inject or warn, never block:**

| Hook | Event | What it does |
|------|------|-------------|
| `session-start` | SessionStart | Injects the manuscript-map pointer, thesis, stage, top reviewer rules, active task, branch + dirty tree; resets stale session state |
| `prompt-router` | UserPromptSubmit | Injects a calibration reminder when a prompt touches an inflection (overclaim, statistics, causation, citations, reviewer response, methods) |
| `unicode-scan` | PostToolUse | Detects invisible Unicode (rife in copy-pasted PDF text) |
| `word-budget` | PostToolUse | Warns when a section `.tex` exceeds its `% budget: NNN` (mirrors MANUSCRIPT_MAP) — uses `texcount` if present |
| `figure-orphan` | PostToolUse | Warns on orphan floats (labeled, never `\ref`'d), unused `figures/` assets, and missing `\includegraphics` files |
| `session-end` | SessionEnd | Writes a session audit line for the scorecard |

> The `RESEARCH_APPROVED=1` escape hatch bypasses `protect-sources` and `block-fabrication` (e.g. importing a `.bib` you have independently verified).

### ResearchKitBench — the hooks are tested

The hooks aren't documentation, they're a contract. The kit ships [`bench/`](bench/README.md): a reproducible eval harness with **32 deterministic scenarios** (no LLM, no network) covering every blocking hook, plus regressions (a `\cite` inside a TeX comment must not count; honest `[CITE]` prose placeholders must not be blocked). Run it with `./scripts/run-bench.sh`; CI runs it on every PR (ubuntu + macOS).

```text
ResearchKitBench
========================================
  s01-citation-gate-fails-on-dangling-cite        PASS
  s09-block-fabrication-blocks-placeholder-doi     PASS
  s14-protect-sources-blocks-sources-dir           PASS
  ...                                              PASS
========================================
  32/32 PASS  0 FAIL
```

## Agents

Built-in reviewers (Reasoner-tier) for pre-submission rigor:

| Agent | What it does |
|-------|-------------|
| `peer-reviewer` | Simulates a tough-but-fair Reviewer 2 — novelty, soundness, claim↔evidence support, recommendation |
| `integrity-reviewer` | Research-integrity scan — overclaim, p-hacking/HARKing, citation misuse, missing limitations |
| `fact-checker` | Claim-by-claim verification against sources — Supported / Overstated / Unsupported / Uncited |
| `outline-planner` | Turns a thesis into a claim-driven IMRaD outline with evidence + word budgets |

## Skills

User-invocable — run with `/skill-name`:

| Skill | What it does |
|-------|-------------|
| `/claim-check` | Walks every claim, classifies cited / own / unsupported, checks the citation licenses the verb |
| `/citation-audit` | Bibliography health — dangling cites, orphan entries, malformed DOIs, `\ref`↔`\label` |
| `/peer-review` | Full simulated referee report (runs peer-reviewer + integrity-reviewer) |
| `/outline` | Thesis → claim-driven IMRaD outline ready for `MANUSCRIPT_MAP.md` |
| `/journal-fit` | Assesses fit to a target venue — scope, novelty bar, length, reference style |
| `/response-to-reviewers` | Point-by-point response letter — quote, change, location, never claim an unmade change |
| `/literature-review` | Synthesize related work from your own library (`.bib` + `sources/` + vault); thematic, gap-driven, real citations only; proposes search directions for gaps |
| `/abstract` | Draft/tighten the abstract — every number must match the body, calibrated to the venue's limit |
| `/stats-check` | Run the statistics checklist — effect size + CI, N, test; flags causal overclaim and p-hacking |
| `/methods-review` | Reproducibility check of the methods — flags every missing ingredient to reproduce |
| `/gap-finder` | Breadth-first scan for uncited/unsupported claims; proposes search directions for true gaps |
| `/cover-letter` | Editor cover letter from `MANUSCRIPT_MAP` — contribution, fit, no fabricated significance |
| `/reference-format` | Convert citation style deterministically (biber/CSL); never invents a missing field |
| `/plain-language-summary` | Lay summary that stays faithful — simpler wording never becomes a stronger claim |
| `/manuscript-cycle` | **Orchestrator** — runs the whole lifecycle for a section (outline → ground → draft → verify → review → revise), halting on any gate failure |
| `/submission-pipeline` | **Orchestrator** — parallel pre-submission battery (peer + integrity + fact-checker + audits), deduped, confidence-gated go/no-go report |

## Field Overlays

The analogue of stack templates — discipline-specific conventions that supplement the general docs:

| Overlay | Covers |
|---------|--------|
| `agent_docs/field/ai-ml.md` | ML/NLP venue cues (NeurIPS/ICML/ACL/EMNLP), reproducibility (seeds, compute, decoding params), baselines & ablations, significance over seeds, eval contamination, LLM-agent reviewer concerns |
| `agent_docs/field/life-sciences.md` | ARRIVE/STROBE/PRISMA/MIAME standards, IRB/IACUC ethics, wet-lab reproducibility (RRIDs, cell-line authentication, biological vs technical replicates), figure integrity, GEO/SRA deposition |
| `agent_docs/field/social-sciences.md` | APA 7, preregistration & the replication crisis (OSF, registered reports, no HARKing), construct validity (Cronbach's α), qualitative coding (Cohen's κ, reflexivity), effect sizes over bare p |
| `agent_docs/field/medicine.md` | CONSORT/STROBE/STARD/SPIRIT, prospective trial registration + registered primary outcome, effect measures (ARR, NNT, ITT), bias (allocation concealment, blinding), COI disclosure |

## Literature Vault (module)

An incremental, interlinked **annotated bibliography** — the evidence layer the cardinal rule depends on ("every claim traces to a real source" is only as strong as how well your sources are organized). Based on the Karpathy LLM-wiki pattern: Claude builds and maintains the vault from your raw sources, self-contained and offline.

- `sources/` holds raw, **immutable** material (PDFs, notes); `vault/` is the maintained knowledge base (`summaries/<bibkey>.md`, `concepts/`, `entities/`).
- `/lit-ingest` reads a source → writes an annotated summary (claims with locators, limitations, quotes) → **proposes the `references.bib` entry from the document itself** (never fabricated) → cross-references concepts/entities.
- `/lit-lint` health-checks (contradictions, orphans, missing locators); `/lit-briefing` reports what's new and what gaps remain vs your thesis; the `vault-maintainer` agent does the heavy work.
- It compounds with `/literature-review` and the `fact-checker` agent, which read the vault for grounded evidence. Schema: [`VAULT.md`](VAULT.md).

## What's Inside

```text
ClaudeResearchKit/kit/
  CLAUDE.md                     # Core agent ruleset (kit-managed)
  CLAUDE.project.md             # Project overlay (yours, never overwritten)
  MANUSCRIPT_MAP.md             # The map — thesis, contribution, venue, sections
  agent_docs/                   # writing-workflow, citation-discipline, academic-style,
    field/                      #   statistics, reproducibility, peer-review + field overlays
  tasks/
    todo.md, decisions.md
    reviews/                    # reviewer-feedback memory (_index Top Rules + per-file)
  .claude/
    settings.json               # hook wiring + LaTeX-toolchain permissions
    agents/                     # peer-reviewer, integrity-reviewer, fact-checker, outline-planner
    hooks/                      # 10 deterministic hooks (+ lib/ shared helpers)
    skills/                     # claim-check, citation-audit, peer-review, outline, journal-fit, response-to-reviewers
  bench/                        # ResearchKitBench — 24 scenarios
  scripts/                      # run-bench.sh, doctor.sh
```

## Customization

1. **Fill in `MANUSCRIPT_MAP.md`** — thesis, contribution, venue, section budgets, key sources. The more precise, the less the agent drifts.
2. **Add a `STYLE.md`** — your manuscript's voice and formatting source of truth (optional; the agent reads it before drafting).
3. **Customize `CLAUDE.project.md`** — venue constraints (blind review, word limits) that override kit defaults.
4. **Track reviewer feedback** — `tasks/reviews/` compounds over time; recurring critiques become Top Rules.

## Status & Roadmap

**Current.** The deterministic spine — **13 hooks**, bench-proven (**32 scenarios**) — plus the CLAUDE.md ruleset, **5 agents**, **19 skills** (incl. 2 orchestrators), 7 agent_docs, **4 field overlays** (ai-ml, life/social sciences, medicine), and the **Literature Vault** module.

**AGENTS.md export** — `scripts/convert.sh` derives a cross-tool [AGENTS.md](AGENTS.md) (and Cursor / Windsurf / Aider configs) from `CLAUDE.md`, the single source of truth. **Install lifecycle** (`install` → `doctor` → `upgrade` → `uninstall`) and `.kit-manifest` freshness are smoke-tested in CI on ubuntu + macOS.

Planned: **npm publish** of the `npx` package + plugin-marketplace listing (needs the maintainer's npm token + 2FA), a documentation site, and an HTML-artifacts module.

## License

MIT
