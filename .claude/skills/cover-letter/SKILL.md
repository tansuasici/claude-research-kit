---
name: cover-letter
description: Draft a concise, honest editor cover letter from MANUSCRIPT_MAP — states the contribution, fit to the venue, and required declarations, with no fabricated significance or invented metrics
user-invocable: true
---

# Cover Letter

## Core Rule

A cover letter is an **honest, calibrated pitch to the editor**, not a sales sheet. It states what the paper contributes, why that fits *this* venue, and why it matters — using only what the manuscript actually establishes. **Never assert significance the paper does not establish.** "First study of X" is allowed only if the manuscript defends it; "a major advance," "dramatically outperforms," or a invented effect size is overclaim, and overclaim in the cover letter is the editor's first signal to distrust the paper.

Every number in the letter (tool-call accuracy, task-success delta, sample size) comes from the manuscript's own reported results — never your prior, never rounded up. If the manuscript flags a quantity as `[VALUE — verify]`, the letter does not quote it; it waits. The letter is downstream of the science, never ahead of it.

This skill drafts the letter. It does not change the thesis, the contribution, or any reported quantity — those are Protected Claims (`CLAUDE.md → Protected Claims`).

## When to Use

Invoke with `/cover-letter` when:

- A manuscript is submission-ready and the venue requires a cover letter to the editor.
- Resubmitting after rejection elsewhere, or submitting a revision that needs a fresh letter.
- You want the contribution and fit argument stated tightly before the final push.

State the venue if it differs from the map: `/cover-letter NeurIPS`. Otherwise read it from `MANUSCRIPT_MAP.md → Target journal`.

## Process

### Phase 1: Pull the Argument from MANUSCRIPT_MAP

1. **Read `MANUSCRIPT_MAP.md`** — Thesis, Contribution, Target journal (and handling editor if recorded), Audience, and the headline result. The letter is a compression of these; it introduces nothing not already in the map or the manuscript.
2. **Extract the one-sentence contribution** — what the paper establishes that was not established before. Example: "a pre-execution verification gate reduces hallucinated tool calls in multi-turn LLM agents." Keep it to what the results support.
3. **Pull the headline number from the manuscript's reported results**, with its scope intact ("on our benchmark," "in our sample"). Do not invent one and do not strengthen the scope.
4. **Identify required declarations** for the venue — conflicts of interest, prior/concurrent submission, data and code availability, ethics/dual-use where applicable, funding. If the map does not record these, ask the author rather than guessing.

### Phase 2: Draft the Letter

Keep it to roughly one page, in this order:

1. **Salutation** — the named editor if known; "Dear Editor" otherwise. Get the venue name and editor exactly right (a wrong journal name is a desk-reject signal).
2. **Submission sentence** — title, article type, target venue.
3. **Contribution (significance)** — one short paragraph: the problem, what the paper does, and the headline finding *as the manuscript states it*. Calibrate every verb — "reduces ... in our evaluation," not "solves."
4. **Fit to scope** — one or two sentences naming why this belongs in *this* venue and reaches *its* readership (the agents/tool-use community at NeurIPS/ACL, for instance). Reason from the venue's stated aims; do not invent an acceptance rate or impact factor to argue fit.
5. **Required declarations** — conflicts, prior-submission status, data/code availability, funding/ethics as the venue requires. State each plainly; if a fact is unknown, mark it `[CONFIRM with author]`, never assert it.
6. **Reviewers** — suggested or opposed reviewers **only if the user asks**. Do not volunteer names; if asked, the author supplies them — do not invent affiliations or emails.
7. **Close** — corresponding author and contact.

### Phase 3: Calibrate Every Claim

Before output, run each sentence through the cardinal rule (`CLAUDE.md → Source-Grounded Writing`):

- **Significance check** — does the manuscript actually establish each significance claim? Downgrade anything it does not: "advances" → "contributes," "proves" → "provides evidence that," "outperforms" → "outperforms on our benchmark."
- **Number check** — every quantity traces to the manuscript's reported results, with scope. No rounding up, no invented deltas.
- **Novelty check** — a "first to ..." claim is defensible only if the paper defends it; otherwise soften to "to our knowledge."
- **Declaration check** — no required declaration is silently omitted; no unknown fact is asserted.

## Output Format

```markdown
# Cover Letter — <manuscript> → NeurIPS
> Source: MANUSCRIPT_MAP (thesis, contribution, headline result) + venue aims.
> Every quantity below is the manuscript's own reported value; nothing strengthened.

Dear Dr. <Editor> [CONFIRM name],

We submit our manuscript, "A Pre-Execution Verification Gate Reduces Hallucinated
Tool Calls in Multi-Turn LLM Agents," as a full research paper for consideration
at NeurIPS.

Multi-turn LLM agents frequently issue tool calls to functions that do not exist or
with malformed arguments; this failure is well documented for single-turn use
[halluc2022] but understudied across multi-step horizons. We introduce a lightweight
gate that validates each proposed call against the tool schema before execution. On
our benchmark, the gate improves tool-call accuracy and task-success rate relative to
an ungated baseline [report the manuscript's exact figures — do not invent]. The
method is model-agnostic and adds negligible latency.

This work fits NeurIPS's scope in agents and tool use, and addresses a deployment
concern — fewer invalid tool calls — of direct interest to that readership.

Declarations: The authors declare no competing interests [CONFIRM]. This manuscript
is not under consideration elsewhere [CONFIRM]. Code and the benchmark are available
at <repo> [CONFIRM / mark "available on request" if not yet public].

Sincerely,
<Corresponding author>, <affiliation>, <email>

---

## Pre-send checklist
- [ ] Venue name and editor spelled correctly (NeurIPS; editor confirmed).
- [ ] Every significance claim is one the manuscript establishes — no "major advance" / "solves."
- [ ] Every number matches the manuscript's reported results, with scope ("on our benchmark").
- [ ] No quantity quoted that is still [VALUE — verify] in the draft.
- [ ] Required declarations present: conflicts, prior submission, data/code, funding/ethics.
- [ ] Reviewer suggestions included only because the author asked; names supplied by the author.
- [ ] Title matches the manuscript title exactly.
```

## Pairs With

- **`MANUSCRIPT_MAP.md`** — the single source for thesis, contribution, venue, and the headline result; the letter is its compression.
- **`/journal-fit`** — run first; the fit verdict and scope reasoning feed the "fit to scope" paragraph. If fit is Weak, fix that before writing the letter.
- **`/abstract`** — the abstract and the cover letter share the contribution and headline number; keep them consistent (same calibrated claim, same scope).

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "Editors expect enthusiasm — say it's a major advance" | Editors expect accuracy. Unsupported significance is the first credibility hit. State what the paper establishes. |
| "Round 91.6% to 'over 90%' — cleaner" | Quote the manuscript's exact figure with its scope. Reshaping a number in the letter is the same failure as inventing one. |
| "Call it the first such method" | Only if the paper defends that claim. Otherwise "to our knowledge." |
| "Add a strong reviewer to help it along" | Suggested reviewers go in only if the author asks and supplies them. Do not invent names or affiliations. |
| "Skip the data-availability line, we'll sort it later" | A required declaration omitted is a real gap. Mark it [CONFIRM], do not drop it. |

## Notes

- The letter is judgment about framing and calibration — draft on the Reasoner model (`CLAUDE.md → Model Selection`); the editor reads tone as a proxy for rigor.
- Changing the contribution or a reported quantity to make the letter punchier is a Protected Claim — stop and ask the author; do not edit the science to fit the pitch.
- One page, honest, calibrated. A cover letter that overclaims invites the skeptical read; one that states the contribution plainly earns the fair one.
