# Writing Workflow & Section Planning

The expansion of `CLAUDE.md → The Core Loop`. Read this before drafting a section,
outlining a paper, or planning a revision. It turns the five-word loop
**Question → Evidence → Draft → Verify → Cite** into a procedure with templates.

The governing constraint never changes: you cannot write to a thesis you have not
read, and you cannot cite a source you do not have. Planning exists to surface the
missing evidence *before* you draft around it.

---

## The Core Loop, expanded

| Phase | What you actually do | Output | Failure if skipped |
|---|---|---|---|
| **Question** | Restate the section's job as a claim a reader could dispute. | One sentence in the section plan. | You write fluent prose that establishes nothing. |
| **Evidence** | Inventory the sources that support the claim, *from the library only* (`references.bib` + `sources/`). | An evidence table; a list of gaps. | You draft around a citation you "will find later" — a fabrication waiting to happen. |
| **Draft** | Write the smallest passage that makes the point, in the manuscript's voice. | `.tex` prose with `\cite{}` and honest placeholders. | Padding, throat-clearing, drift off-thesis. |
| **Verify** | Run `CLAUDE.md → Verification (Mandatory Order)`, steps 1–7. | A pass, or a `(sourced / placeholder / unverified)` count. | A draft that *looks* done with dangling cites and unverified numbers. |
| **Cite** | Confirm every non-trivial claim resolves to a real `.bib` entry with the right verb. | Clean `citation-gate.sh` verdict. | The #1 research failure: a real-looking citation with nothing behind it. |

If drafting goes sideways: **STOP, re-read the Question, re-plan.** A drifted
argument is the long-session failure mode (`CLAUDE.md → After Compaction`).

---

## When to write a section plan

Write a plan to `tasks/todo.md` (or a spec folder, below) when:

- The section makes a **load-bearing argument** (intro, discussion, abstract).
- You do not yet have all the evidence in the library.
- The section is **protected** under `CLAUDE.md → Protected Claims` (thesis, a
  reported quantity, methods, an argument-carrying citation, scope).
- You are unsure the claim is defensible.

For a one-sentence fix, a citation-format tidy, or a typo: just do it. Do not
ceremony-plan trivial edits.

---

## Section-plan template (copy-pasteable)

Paste into `tasks/todo.md`. One block per section under work.

```markdown
## Section: [Introduction / Methods / Discussion / …]  →  file: sections/<name>.tex

**Question (disputable claim this section must establish):**
> [One sentence. Not "write the intro" — "Establish that hallucinated tool calls in
>  multi-turn agents are understudied and that pre-execution gating closes that gap."]

**Word budget:** [from MANUSCRIPT_MAP.md → Structure table]   **Tense:** [intro present / methods past / results past]

### Evidence inventory (library only — references.bib + sources/)
| Claim in the section | Supporting source (`.bib` key) | What it licenses | Gap? |
|---|---|---|---|
| [sub-claim 1] | `tooluse2023` | 70% accuracy *in single-turn QA* | setting ≠ multi-turn agentic — do NOT overclaim |
| [sub-claim 2] | — | — | **[CITE] needed** — not in library |
| [sub-claim 3] | author's own data (`tab:toolacc`) | >40% fewer hallucinated calls, tested harness | reproducible? see methods |

### Draft plan (topic sentence per paragraph)
1. [P1 topic sentence — given→new]
2. [P2 topic sentence]
3. [P3 topic sentence]

### Verification checklist (CLAUDE.md mandatory order)
- [ ] Every `\cite{}` resolves in references.bib (citation-gate)
- [ ] Every quote verbatim + locator
- [ ] Each claim's verb/quantifier matches its source (no overclaim)
- [ ] Numbers match tables/abstract; units stated; N reported
- [ ] Cross-refs resolve (`\ref` ↔ `\label`); every display item cited in text
- [ ] Compiles clean (latexmk + biber, no undefined refs in .log)
- [ ] Gap count reported: (sourced / placeholder / unverified)

### Not Now (off-thesis, parked)
- [ ]
```

The **Question** line becomes the section's acceptance criterion: the section is
done when a skeptical Reviewer 2 would agree that one sentence is established and
nothing beyond it is claimed.

---

## Manuscript lifecycle

A paper moves through stages; the `Stage` field in `MANUSCRIPT_MAP.md → Status`
records where it is. Match your behavior to the stage.

```text
idea → outline → first draft → internal review → revision → submission → reviewer response → camera-ready
```

| Stage | Your job | Model (`CLAUDE.md → Model Selection`) | Watch for |
|---|---|---|---|
| **idea** | Help state the thesis as one disputable sentence + the contribution. If it won't fit in one sentence, the paper isn't ready to draft. | Reasoner | Vague theses; a "gap" manufactured by ignoring literature. |
| **outline** | Fill the `MANUSCRIPT_MAP.md → Structure` table: per-section claim + budget. Map key sources to the claims they support. | Reasoner | Sections with no stated claim; budgets missing. |
| **first draft** | Run the Core Loop section by section. Leave `[CITE]` / `[VALUE — verify]` rather than inventing. | Drafter (Reasoner for intro/discussion synthesis) | Drafting ahead of the evidence. |
| **internal review** | Dispatch the `peer-reviewer` sub-agent; self-critique against the verification order. | Reasoner | Agreeable self-review that finds no holes. |
| **revision** | Address each internal critique concretely; keep the thesis fixed unless approved. | Reasoner → Drafter | Scope creep; silent thesis drift. |
| **submission** | Freeze a snapshot into `submitted/` (immutable — `protect-sources.sh`). Final compile, final gap-count = 0. | Drafter | Placeholders still embedded; `.log` warnings. |
| **reviewer response** | Build the response letter (`agent_docs/peer-review.md`); log recurring critiques to `tasks/reviews/`. | Reasoner | Claiming a change you did not make. |
| **camera-ready** | Mechanical: proofs, formatting, final cross-refs. | Drafter | Re-opening settled claims. |

Stage transitions that change the thesis, a reported quantity, the methods, an
argument-carrying citation, or the scope are **Protected Claims** — request the
author's approval and record it in `tasks/decisions.md`.

---

## The MANUSCRIPT_MAP.md Structure-table workflow

`MANUSCRIPT_MAP.md` is the single most important file; the `Structure` table is its
operational core. Treat it as the plan-of-record for the whole paper.

1. **Before drafting a section**, read its row. The `Purpose (claim it establishes)`
   cell *is* the section's Question. If that cell still says `<...>`, stop and write
   the claim first — drafting to an unstated claim guarantees drift.
2. **One section per work unit.** Pick one row, run the Core Loop, finish it, update
   its `Status` cell (`not started → drafting → drafted → verified`). Do not draft
   three sections in one pass — context bleeds and the argument blurs.
3. **Honor the budget.** The `Budget` cell is a word cap. Use `texcount` to measure
   (`CLAUDE.md → Model vs Code` — never estimate). Over budget ⇒ cut, do not negotiate
   the budget silently.
4. **Cross-check Key sources.** The `Key sources` table lists the references the paper
   stands on and, crucially, what each must **not** be overclaimed as. Before citing
   one of these in a new context, confirm the matrix/population/scope matches.
5. **Update display items.** When you add a `\label`, add the figure/table to the
   `Figures & tables` row so the "referenced in" column stays true. Every display item
   must be cited in the text and vice versa (verification step 5).
6. **Park off-thesis material** in `MANUSCRIPT_MAP.md → Not Now` (or `tasks/todo.md →
   ## Not Now`), never in the draft.

A change to a Structure-table row that alters *what a section claims* is a scope
change — protected.

---

## Spec folders for multi-session sections

For a section that spans sessions (a contested discussion, a methods rewrite, a
response to a major revision), create a timestamped spec folder so the plan survives
`/clear` and compaction:

```text
tasks/specs/
  2026-06-03-discussion-rewrite/
    plan.md          # the section plan (template above)
    evidence.md      # the evidence inventory + gaps, kept current
    decisions.md     # framing/scope calls made along the way (mirror to tasks/decisions.md)
```

A fresh session reads the spec folder to recover *what was planned and why* without
re-deriving it. Use spec folders only when the work genuinely outlives one session;
otherwise a `tasks/todo.md` block is enough.

---

## Handoffs between sessions

Before `/clear` or at session end, write what the next session needs:
`tasks/handoff-*.md` (current section, open placeholders, gap count, the next
Question). The session-start hook points the next session at it. The clear is
destructive for in-memory state, not for files — so the files must carry the plan.

---

## Anti-patterns

| Anti-pattern | Why it fails | Do instead |
|---|---|---|
| Draft first, source later | The "later" citation gets invented or forgotten. | Evidence phase before Draft, always. |
| "Write the whole paper" | No section has a checkable claim; everything drifts. | One Structure-table row at a time. |
| Padding to hit a word count | Throat-clearing is not evidence. | Budgets are caps, not quotas. Cut. |
| Silent thesis edit while revising | Downstream sections now contradict the thesis. | Thesis change ⇒ approval ⇒ `tasks/decisions.md`. |
| Marking a section "done" with placeholders embedded | Looks complete; isn't. | Report `(sourced / placeholder / unverified)`; placeholders block "complete". |
