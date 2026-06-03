---
name: manuscript-cycle
description: End-to-end orchestrator — runs the whole CLAUDE.md research lifecycle for a section or manuscript as one command (outline → ground → draft → verify → review → revise), halting on any gate failure.
user-invocable: true
---

# Manuscript Cycle

## Core Rule

Run the Question → Evidence → Draft → Verify → Cite lifecycle end-to-end, and **halt at the first gate that fails** — never draft past an unresolved citation, an unsupported claim, or a failed compile. This skill orchestrates the kit's existing skills and agents; it does not bypass any of their rules. A clean cycle means: every `\cite` resolves, every claim is sourced and calibrated, the log compiles, and a simulated reviewer would sign off.

## When to Use

Invoke with `/manuscript-cycle [section]` when:

- Taking a section from outline to review-ready in one pass
- You want the full discipline loop run for you, with the gates enforced
- Running headless (`/manuscript-cycle mode:headless`) over a spec for an unattended draft pass

Scope it: `/manuscript-cycle introduction` works one section; `/manuscript-cycle` reads the next not-started section from `MANUSCRIPT_MAP.md → Structure`.

## Process

### Phase 0 — Load & scope
1. Read `MANUSCRIPT_MAP.md` (thesis, contribution, venue, the Structure table) and `CLAUDE.project.md` / `STYLE.md` if present.
2. Pick the target section (argument) and restate it as **a claim a reader could dispute** (the section's Question).
3. Confirm the scope with the author **unless** `mode:headless` (then proceed and report).

### Phase 1 — Outline (argument architecture)
4. If the section's claim/evidence plan is missing from the map, run **`/outline`** for it (or dispatch the `outline-planner` agent). Each section states the one claim it establishes, the evidence it needs, and a word budget.
5. **GATE — evidence availability:** if the outline flags evidence not in the library (`references.bib` / `sources/` / vault), surface it. Run **`/lit-briefing`** for gaps and propose search directions. Do **not** draft around a citation you intend to "find later." Halt for the author if a load-bearing source is missing (headless: mark the gap and skip that claim).

### Phase 2 — Ground
6. Pull the supporting evidence for each claim from the vault (`/literature-review` for related work; read `vault/summaries/` for specifics). Confirm each intended `\cite` key exists in `references.bib`.

### Phase 3 — Draft
7. Write the smallest passage that makes each point, matching the manuscript's voice (`STYLE.md`). Every non-trivial claim carries a real `\cite`; unknowns get `[CITE]` / `[VALUE — verify]` — never a fabrication.

### Phase 4 — Verify (the hard gate)
8. The hooks run on each edit. Before proceeding, confirm:
   - **citation-gate** passed (no dangling `\cite`/`\ref`) — `.hook-state/last_quality_gate.json`.
   - **compile-gate** clean if a `.log` exists.
   - Run **`/claim-check`** on the draft: every claim cited / author's-own / common-knowledge; verbs calibrated to the evidence.
9. **GATE:** if citation-gate, compile-gate, or `/claim-check` reports a failure, **stop and fix** before any review. Do not advance with `[CITE]` placeholders silently embedded — report `(sourced / placeholder / unverified)`.

### Phase 5 — Review
10. Run **`/peer-review`** (dispatches `peer-reviewer` + `integrity-reviewer`). For numeric/empirical sections also run **`/stats-check`**; for methods, **`/methods-review`**.
11. Triage findings: address every **Major** issue now (re-entering Phase 3–4 as needed); list Minor issues for the author.

### Phase 6 — Revise / respond
12. Apply the fixes. If this cycle is answering real reviewers, run **`/response-to-reviewers`** (quote → change → location; never claim an unmade change). Log any recurring critique to `tasks/reviews/`.

### Phase 7 — Report
13. Produce the cycle report (below). In `mode:headless`, write it to `tasks/` and stop at the first hard gate rather than asking.

## Output Format

```
# Manuscript Cycle — <section> (<date>)
Thesis: <one line>     Stage: <from MANUSCRIPT_MAP>

Phase results
- Outline ......... <ok | evidence gaps: N>
- Ground .......... <sources used: keys>
- Draft ........... <words / budget>
- Verify .......... citation-gate <pass/FAIL> · compile-gate <pass/skip/FAIL> · claim-check (sourced/placeholder/unverified)
- Review .......... Major: N · Minor: N  (recommendation)
- Revise .......... <fixes applied / response letter>

HALTED AT: <phase + reason>          # if any gate failed
Open for author: <minor issues, evidence gaps, decisions>
```

## Pairs With

`/outline` · `/literature-review` · `/lit-briefing` · `/claim-check` · `/stats-check` · `/methods-review` · `/peer-review` · `/response-to-reviewers`; gated by `citation-gate.sh` / `compile-gate.sh` / `stop-gate.sh`. It is the research analogue of the code kit's `/feature-cycle`.

## Common Rationalizations (rejected)

- *"Draft now, find the citation later."* → Phase 1 gate forbids it. Surface the gap.
- *"Skip review, it's a small section."* → Major issues hide in small sections; Phase 5 runs.
- *"The placeholder is fine for now."* → Only if reported in the tally; never silently shipped past Phase 4.

## Notes

- **Headless** (`mode:headless`): no interactive confirmations — proceed with stated assumptions, halt at the first hard gate, and write the report to `tasks/`. Use for an unattended first-draft pass; a human still reviews before submission.
- This skill never relaxes a gate. If a gate is wrong (broken infra), the author sets `SKIP_QUALITY_GATE=1` deliberately and records why — the cycle does not bypass it on its own.
- Reasoner-tier for outline/review phases, Drafter-tier for the draft phase (`CLAUDE.md → Model Selection`).
