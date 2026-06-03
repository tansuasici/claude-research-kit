---
name: submission-pipeline
description: Pre-submission review battery — runs the peer-reviewer, integrity-reviewer, and fact-checker agents plus the deterministic audits in parallel over the whole manuscript, dedupes, confidence-gates, and saves one go/no-go report.
user-invocable: true
---

# Submission Pipeline

## Core Rule

Before submission, run **every reviewer lens at once**, dedupe across them, keep only findings that survive a confidence gate, and produce a single go/no-go report with a submission checklist. This is breadth-first (the whole manuscript, all lenses) — distinct from `/peer-review` (one referee report) and `/claim-check` (depth on each claim). It reports; it does not edit. Fixing a flagged claim is the author's call (and a Protected Claim).

## When to Use

Invoke with `/submission-pipeline` when:

- The manuscript is draft-complete and you want a pre-submission sweep
- You want to pre-empt Reviewer 2 across rigor, integrity, and facts in one pass
- Running headless (`/submission-pipeline mode:headless`) to produce a report artifact

## Process

### Phase 1 — Scope
1. Read `MANUSCRIPT_MAP.md` (thesis, contribution, venue) and assemble the manuscript file set (`main.tex` + `\input` sections). Note the target venue for `/journal-fit`.

### Phase 2 — Parallel review (run together, don't serialize)
2. Dispatch in parallel:
   - **`peer-reviewer`** agent — novelty, soundness, claim↔evidence, structure, recommendation.
   - **`integrity-reviewer`** agent — overclaim, p-hacking/HARKing, citation misuse, missing limitations.
   - **`fact-checker`** agent — claim-by-claim Supported / Overstated / Unsupported / Uncited.
3. In parallel, run the deterministic + checklist audits and collect their results:
   - **`/citation-audit`** (dangling/orphan/malformed refs), current **compile-gate** verdict, **figure-orphan** state.
   - **`/stats-check`** (statistical reporting), **`/methods-review`** (reproducibility), **`/journal-fit`** (venue fit), **`/gap-finder`** (uncited/unsupported sweep).

### Phase 3 — Dedupe & merge
4. Many lenses will flag the same sentence (e.g. an overclaim caught by peer-reviewer, integrity-reviewer, and fact-checker). Merge by `(file, locator, claim)` into one finding that records which lenses raised it (agreement = signal).

### Phase 4 — Confidence gate
5. Keep a finding if **any** of:
   - a deterministic check produced it (dangling `\cite`, undefined ref, missing field) — always high-confidence;
   - **≥2 independent lenses** agree on it;
   - it is a single-lens finding rated high-severity by that lens (e.g. an unsupported central claim).
   Drop or mark **low-confidence** the single-lens, low-severity findings so the report is signal, not noise. Log what was dropped (no silent truncation).

### Phase 5 — Report
6. Write the report to `reports/submission-review-<date>.md` (and surface a summary). Include a **go / revise / no-go** recommendation tied to the findings, and a submission checklist.

## Output Format

```
# Submission Review — <title> → <venue>   (<date>)
Recommendation: GO | REVISE | NO-GO  — <one-line reason>

## Blocking (must fix before submission)
- [file:locator] <finding> — lenses: {peer, integrity, fact, deterministic} — fix: <…>

## Should-fix
- ...

## Consider
- ...  (low-confidence / single-lens — listed, not emphasized)

## Deterministic status
- citation-gate: <pass/FAIL>   compile-gate: <pass/skip/FAIL>   figure-orphan: <clean/N>
- citation-audit: <N issues>   stats: <N>   methods reproducibility: <PASS/GAP list>

## Submission checklist
- [ ] All \cite resolve · compile clean · no orphan floats
- [ ] Limitations section present · no causal overclaim · effect sizes + CIs
- [ ] Venue: length / reference style / display-item limits (confirm in author guidelines)
- [ ] Data/code availability statement · declarations
- [ ] Abstract numbers match the body

## Dropped (low-confidence, for transparency)
- <count> single-lens low-severity findings
```

## Pairs With

`peer-reviewer` / `integrity-reviewer` / `fact-checker` agents; `/peer-review`, `/citation-audit`, `/stats-check`, `/methods-review`, `/journal-fit`, `/gap-finder`; the `citation-gate` / `compile-gate` / `figure-orphan` hooks. Research analogue of the code kit's `/review-pipeline`.

## Notes

- **Headless** (`mode:headless`): emits the report artifact to `reports/` and a short summary; no interactive prompts.
- **Never auto-edits.** Every fix to a reported claim is a Protected Claim — the author decides. The pipeline's job is to find, dedupe, and rank.
- **No silent caps.** If coverage is bounded (e.g. only changed sections), say so in the report.
- Distinct from `/project-health`-style breadth: this is submission-readiness, gated on the venue and the cardinal rule.
