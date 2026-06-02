---
name: literature-review
description: Synthesize a related-work / literature-review section from the project's OWN library (references.bib + sources/ + vault) — thematic, gap-driven, calibrated, real citations only. Proposes concrete search directions for gaps without fabricating a single source.
user-invocable: true
---

# Literature Review

## Core Rule

Synthesize only what is in the library. **Never invent a citation, author, year, finding, or quantity.** A literature review's deadliest failure is the model confidently asserting "prior work shows X \cite{plausible2021}" for a paper that does not exist. This skill works your `references.bib` + `sources/` (+ `vault/` if present) and nothing else. For what the library lacks, it emits **search directions** — what to look for — never a fabricated source to fill the hole.

## When to Use

Invoke with `/literature-review` when:

- Drafting or revising the Related Work / Background section
- Grounding the Introduction's gap claim in real prior work
- Positioning your contribution against the field before submission
- Checking whether your library actually covers the themes your argument needs

## Process

### Phase 1 — Inventory the library

Before synthesizing anything, take stock:

- Count `references.bib` entries; note which have full text or notes in `sources/` (or a summary in `vault/`).
- Flag **metadata-only** entries — you have the citation but not the content. You may cite their existence but must not assert specific findings without the source.
- Report coverage: `N references / M with readable source / K metadata-only`.

If the library is thin for the argument at hand, **say so** — do not paper over it with invented work. A 4-source "review" is a 4-source review.

### Phase 2 — Cluster thematically

A literature review is an *argument*, not an annotated list ("Smith said X. Jones said Y."). Group the real sources by **theme / method / finding / chronology** and build a map. Example clusters for an LLM-agent paper:

1. Tool-augmented agent frameworks
2. Hallucination & faithfulness in LLM outputs
3. Verification / self-correction methods
4. Agent evaluation benchmarks

### Phase 3 — Gap analysis (against the thesis)

Read `MANUSCRIPT_MAP.md → Thesis / Contribution`. Locate the gap the synthesis must set up: *"the literature establishes A and B but not C, which is our contribution."* Every theme should pull toward that gap. If a cluster does not serve the thesis, it is background, not related work.

### Phase 4 — Draft the synthesis

Write the section in LaTeX:

- Every non-trivial claim carries a real `\cite{key}` resolving in `references.bib`.
- **Calibrated verbs** — `\citet{ex2023b}` *reports* / *finds* / *observes*, not *proves*. Match the verb to what the source licenses (see `agent_docs/academic-style.md`).
- One paragraph per theme, each ending by advancing toward the gap.
- Metadata-only claims get a `[verify: source not read]` marker, never a confident assertion.

> Tool-augmented agents reliably decompose multi-step tasks \citep{ex2023a},
> yet their tool calls remain error-prone under distribution shift
> \citep{ex2023b}. Proposed remedies emphasise post-hoc self-correction
> \citep{ex2024c}; deterministic pre-execution gating remains unexplored.

### Phase 5 — Coverage + search-direction report

For every theme that is **thin or missing**, emit concrete search directions — *what to look for*, not a fabricated paper:

- **Keywords / queries** to run (e.g. "constrained decoding tool use", "self-consistency verification agents").
- **Venues & years** likely to hold it (e.g. NeurIPS / ICLR / ACL 2023–2025).
- **Citation chaining** — follow the references/citations of a paper you already have (e.g. "backward-cite from `\cite{ex2023b}`").
- **Author follow-ups** — later work by an author already in your library.

The loop stays honest: **you** fetch the result → ingest it (`/lit-ingest` if the vault module is installed, or add to `references.bib` + `sources/`) → re-run `/literature-review`. The skill never closes a gap by inventing a source.

### Phase 6 — Verify

- `citation-gate.sh` confirms every `\cite` resolves (run an edit, or check `.hook-state/last_quality_gate.json`).
- Spawn the `fact-checker` agent on the load-bearing claims to confirm the source supports the verb.
- Report the tally: `(synthesized from read sources / metadata-only / gaps with search directions)`.

## Output Format

1. **The drafted section** — LaTeX, real citations, calibrated, gap-directed.
2. **Coverage table** — theme → # sources → read vs metadata-only → strength.
3. **Search directions** — per thin/missing theme, the concrete leads above (no fabricated papers).
4. **Tally** — `(synthesized / metadata-only / gaps)`.

## Pairs With

- **`vault/` + `/lit-ingest`** (E1) — the ideal backing store; ingest fetched sources here, then re-run.
- **`fact-checker` agent** — verifies the synthesis against sources.
- **`citation-gate.sh`** — guarantees no dangling `\cite`.
- **`/gap-finder`** — surfaces uncited/unsupported claims in the draft.
- **`/claim-check`** — claim-by-claim audit once the section is written.

## Common Rationalizations (all rejected)

- *"I'm fairly sure there's a paper on X."* → Emit a **search direction**, not a `\cite`. Confidence is not a citation.
- *"The library is thin, I'll round it out with well-known work."* → No. Report the gap with search directions; let the author fetch real sources.
- *"This source probably says X."* → If you have not read it (metadata-only), mark `[verify]`; do not assert the finding.
- *"A review needs ~40 references, so I'll list plausible ones."* → A review needs the references you actually have; the gap report tells you how to get the rest.

## Notes

- Two modes: **vault-backed** (rich synthesis from `vault/` summaries + concepts) and **bib+sources-backed** (works `references.bib` + `sources/` notes; more metadata-only flags).
- This skill drafts and reports; changing the contribution framing is a Protected Claim — confirm with the author.
- Reasoner-tier work (synthesis across many sources) — see `CLAUDE.md → Model Selection`.
