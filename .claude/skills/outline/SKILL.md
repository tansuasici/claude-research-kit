---
name: outline
description: Turn a thesis + target venue into a claim-driven IMRaD outline — each section is the one claim it establishes plus the evidence needed and a word budget — ready for MANUSCRIPT_MAP.md, flagging evidence missing from the library
user-invocable: true
---

# Outline

## Core Rule

A section is not a topic — it is **one claim** the manuscript must establish, plus the **evidence** that establishes it. Outline by claim, not by heading. Every section in the plan answers: *what disputable point does this establish, and what evidence (cited or our own) supports it?* If a section's claim has no evidence in the library, the outline says so — it does not paper over the gap with a heading. You cannot outline to a thesis you have not read, and you must never assume a source exists to fill a slot.

The output is structured to drop into `MANUSCRIPT_MAP.md → Structure` so the plan-of-record and the outline are the same artifact.

## When to Use

Invoke with `/outline` when:

- Starting a manuscript — you have a thesis and a target venue and need a section plan.
- The argument has drifted and you need to re-derive the structure from the thesis.
- Adding a major section and want it to carry exactly one claim with a budget.
- Before drafting any section, to confirm the evidence exists before you write around it.

If the thesis is not yet one sentence, stop and sharpen it first — an outline built on a fuzzy thesis inherits the fuzziness.

## Process

### Phase 1: Lock the Thesis and Contribution

1. **Read `MANUSCRIPT_MAP.md`** — the Thesis (one sentence), Contribution, Audience, target venue. If the Thesis is still a `<placeholder>`, the manuscript is not ready to outline — surface that and ask the author for the one-sentence claim.
2. **Restate the thesis as a claim a reader could dispute.** "A paper about PFAS removal" is a topic; "Electrocoagulation removes short-chain PFAS from landfill leachate at >90%, which sorption does not achieve" is a claim. The whole outline serves *this* sentence.
3. **State the contribution delta** — what the reader knows after this paper that they did not before, distinguished from prior work. Every section either builds toward this delta or is off-thesis.

### Phase 2: Read the Venue's Shape

1. **Target venue conventions** — from `MANUSCRIPT_MAP.md` and (if it exists) the field overlay in `agent_docs/field/`. IMRaD is the default, but venues vary: some merge Results+Discussion, some want a structured abstract, some cap sections. Note length and display-item limits.
2. **Audience calibration** — what the readership already knows (skip it) vs. what must be established (cite it). This decides how much the Introduction must do. A specialist methods venue needs less background than a broad-readership journal.

### Phase 3: Derive Sections from the Argument

For a standard IMRaD manuscript, assign each section the **one claim** it establishes:

| Section | The single claim it establishes |
|---|---|
| **Abstract** | The whole argument in ~200 words: gap → what we did → what we found → why it matters. |
| **Introduction** | "This gap exists, it matters, and we close it." Establish the gap (cited), its importance (cited), and the contribution (ours). |
| **Methods** | "Here is exactly what we did — reproducibly." No claims about results; an account a reader could replicate. |
| **Results** | "This is what the data show." Observations only — no interpretation, no causal language. |
| **Discussion** | "Here is what it means, where it is limited, and what follows." Interpretation calibrated to the evidence; limits stated honestly. |
| **Conclusion** | "The contribution, restated; here is the future work." No new claims. |

Adapt to the venue's actual structure — but every section still owes exactly one claim. If a section owes two, split it; if two sections owe the same claim, merge them.

### Phase 4: Attach Evidence and Budgets

For each section, specify:

1. **Evidence needed** — the specific support for its claim:
   - **Cited** — which references establish it. Check they exist in `references.bib`. Name the keys.
   - **Our own** — which result/figure/table/data (cross-ref `MANUSCRIPT_MAP → Figures & tables`).
   - **Common knowledge** — what needs no cite for this audience.
2. **Word budget** — a number that keeps the section from sprawling. Budgets sum toward the venue's length limit. Use `texcount` for live counts later; estimate here (`CLAUDE.md → Model vs Code` — counting is deterministic, don't guess once drafting starts).
3. **Evidence status** — for each piece of cited evidence: **in library** / **MISSING**. A claim whose support is not in `references.bib` + `sources/` gets a **GAP** flag. Do not assume a source exists — if you cannot point to it, it is missing.

### Phase 5: Flag Gaps — Never Fabricate to Fill Them

The most valuable outline output: **what evidence the argument needs that the library does not have.**

- For every section whose claim depends on a source not in the library, emit a **GAP**: the claim, the kind of source needed, and where to look. This is honest scaffolding (`[CITE]` in spirit), not a fabricated citation.
- If the thesis depends on a claim with no available evidence at all, say so plainly — that may mean the thesis is not yet supportable, which the author needs to know before drafting, not after.

### Phase 6: Emit the Outline for MANUSCRIPT_MAP

Produce the outline in the `MANUSCRIPT_MAP.md → Structure` table shape plus a per-section claim+evidence block and a consolidated gap list. Do not overwrite `MANUSCRIPT_MAP.md` unless the author asks — present the outline for them to merge.

## Output Format

```markdown
# Outline — <manuscript title>
> Target venue: Environmental Science & Technology (~7000 w, 6 display items, ACS style)
> Thesis: EC removes short-chain PFAS from landfill leachate at >90%, which sorption does not achieve.
> Contribution: first leachate-matrix demonstration; prior work is freshwater only.

## Structure (drops into MANUSCRIPT_MAP.md)
| Section | File | Claim it establishes | Budget | Status |
|---|---|---|---|---|
| Abstract | sections/abstract.tex | whole argument in 200 w | 200 w | not started |
| Introduction | sections/intro.tex | leachate PFAS removal is understudied; we close the gap | 800 w | not started |
| Methods | sections/methods.tex | reproducible account of the EC setup + analysis | 1500 w | not started |
| Results | sections/results.tex | removal efficiency by chain length (data only) | 1200 w | not started |
| Discussion | sections/discussion.tex | interpretation, limits, implications | 1500 w | not started |
| Conclusion | sections/conclusion.tex | contribution restated, future work | 300 w | not started |

## Section detail
### Introduction — "leachate PFAS removal is understudied; we close the gap" (800 w)
- Evidence (cited): PFAS persistence/regulation — `jones2019` (in library); sorption
  baseline is freshwater-only — `smith2021` (in library, do NOT overclaim as leachate).
- Evidence (ours): the contribution statement.
- GAP: need a source establishing that *leachate* PFAS removal specifically is
  understudied. Nothing in references.bib covers this. → search recent reviews;
  leave [CITE] until found. Do not assert "no prior work" without it.

### Results — "removal efficiency by chain length" (1200 w)
- Evidence (ours): Tab:removal (by chain length), Fig:flux. Confirm both exist.
- No citations — observations only. No causal language here (that's Discussion).

[... one block per section ...]

## Evidence Gaps (fill before drafting the dependent section)
1. **[Intro]** "leachate removal understudied" — no supporting review in library. (blocks the gap framing)
2. **[Discussion]** chain-length mechanism — no mechanistic source. (blocks interpretation ¶2)
3. **[Methods]** instrument citation for the analyzer — not in references.bib.

## Off-thesis (parked → MANUSCRIPT_MAP → Not Now)
- Cost analysis of EC vs sorption — interesting, but not what the thesis defends.
```

## Pairs With

- **`MANUSCRIPT_MAP.md`** — the outline's `Structure` block is authored *for* this file; keep them in sync.
- **`/journal-fit`** — run first or alongside to confirm the venue shape (length, structure, style) the outline must obey.
- **`/claim-check`** — after drafting a section, verify the claims the outline promised are the claims actually made (and supported).
- **`agent_docs/writing-workflow.md`** — the full outline template and the Question→Evidence→Draft→Verify→Cite loop this skill front-loads.
- **`block-fabrication.sh`** — if you try to satisfy a GAP by writing a stub reference, this blocks it. The GAP stays a GAP until a real source fills it.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll find sources for the gaps while drafting" | Drafting around a source you intend to find is how fabrications and dead `[CITE]`s ship. Find it first or flag the GAP. |
| "This section is obviously needed" | Every section must establish a disputable claim toward the thesis. "Obviously needed" with no claim is padding. |
| "Budgets are guesses, skip them" | A section with no budget sprawls and crowds out the section that carries the contribution. Budget it. |
| "The thesis is roughly X" | A roughly-stated thesis produces a roughly-argued paper. Sharpen to one disputable sentence before outlining. |

## Notes

- Outlining is argument architecture — run on the Reasoner model (`CLAUDE.md → Model Selection`).
- A GAP is not a failure of the outline; it is the outline doing its job — telling you what to source before you write.
- Keep off-thesis ideas in `Not Now`, not smuggled into a section. Scope discipline starts at the outline.
