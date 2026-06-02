---
name: peer-review
description: Run a full simulated peer review — dispatch the peer-reviewer and integrity-reviewer agents over the manuscript, dedupe their findings, and produce a referee report with a recommendation. Pre-empt Reviewer 2 before submission
user-invocable: true
---

# Peer Review

## Core Rule

Simulate the referee you fear, before the journal assigns one. This skill runs an **adversarial, evidence-bound** review: it surfaces what a skeptical reviewer would attack — overclaim, unsupported assertions, scope creep, methods gaps, statistical sins — and produces a referee report you can act on. The review **reports**; it does not silently edit the manuscript. Fixes that touch the thesis, a quantity, methods, or an argument-carrying citation are Protected Claims (`CLAUDE.md`) and need author sign-off.

The reviewers are bound by the same cardinal rule as the writer: a critique must point at real text and a real problem. No invented weaknesses, no citations the reviewer "expects to see" that don't exist as a demand — every issue cites a section/line.

## When to Use

Invoke with `/peer-review` when:

- A draft is complete and you want a referee report before submission.
- A major section (Discussion, Methods) is settled and you want it stress-tested.
- You are deciding readiness for a target venue (pair with `/journal-fit`).
- A reviser wants to know which Reviewer-2 objections are still open.

Scope it: `/peer-review` for the whole manuscript, or `/peer-review sections/methods.tex` for one section.

## Process

### Phase 1: Load the Manuscript and Its Contract

1. **Read `MANUSCRIPT_MAP.md`** — Thesis, Contribution, Audience, target venue, Key sources, "Claims that need extra care," and the Structure table. The review judges the manuscript *against its own stated thesis and scope* — a reviewer's first question is "did they deliver what they claimed?"
2. **Read the manuscript** — every section file in the Structure table (or the scoped file).
3. **Read `tasks/reviews/_index.md → ## Top Rules`** — recurring prior critiques. If a reviewer already flagged "you overclaim in the discussion," check it has been addressed; an unfixed Top Rule is a Major issue.
4. **Note the field overlay** in `agent_docs/field/` if one exists — discipline-specific reporting standards the reviewer will hold you to.

### Phase 2: Dispatch the Reviewer Agents

Run two specialist agents in parallel — they read the manuscript independently and return findings:

1. **`peer-reviewer` agent** — the scholarly referee. Judges:
   - **Significance & novelty** — is the contribution real and clearly distinguished from prior work?
   - **Soundness** — do the methods support the claims? Is the analysis appropriate?
   - **Claim calibration** — does every results/discussion sentence stay within what the evidence licenses? (verb + quantifier + scope)
   - **Clarity & structure** — does each section establish the one claim it owes (`MANUSCRIPT_MAP → Structure`)?
   - **Statistics** — effect size + uncertainty reported, not just significance; N, test, and assumptions stated (`agent_docs/statistics.md`).

2. **`integrity-reviewer` agent** — the research-integrity referee. Judges:
   - **Sourcing** — every substantive claim is cited, the author's own, or common knowledge; no UNSUPPORTED assertions.
   - **No fabrication** — no invented-looking citation, DOI, quantity, or quote; placeholders (`[CITE]`, `[VALUE — verify]`) surfaced, not hidden.
   - **Quote fidelity** — quotations verbatim with locators.
   - **Reproducibility** — data/code availability stated; methods sufficient to reproduce (`agent_docs/reproducibility.md`).
   - **Scope honesty** — generalization claims match the tested population/matrix.

If the agents are unavailable in this environment, run both review lenses yourself sequentially — but keep them as **separate passes** (scholarly soundness vs integrity), because they catch different failures.

### Phase 3: Dedupe and Triage

The two agents will overlap (an overclaim is both a soundness and an integrity issue). Merge:

1. **Collapse duplicates** — same sentence flagged by both → one issue, noting both lenses.
2. **Classify severity**:
   - **Major** — threatens a central claim, the contribution, soundness, or integrity. Would justify "major revision" or rejection. (Unsupported thesis-level claim, methods that don't support the result, fabrication risk, unaddressed prior Top Rule.)
   - **Minor** — does not threaten the conclusion but should be fixed. (Local overclaim, a missing cite on a secondary claim, an undefined cross-reference, a clarity issue.)
3. **Order by impact** — Major issues first, most central first. A reviewer leads with the objection that decides the paper.

### Phase 4: Write the Referee Report

Produce a report in the shape a journal referee submits: a Summary that proves you understood the contribution, then Major and Minor issues, then a recommendation. Keep the reviewer's professional, specific voice — every point names a location and states the fix or the question.

### Phase 5: Hand Off, Do Not Auto-Fix

End with a checklist of edits the author can apply. **Do not apply them in this skill.** Surface Protected Claims explicitly (thesis/quantity/methods/argument-citation changes) so the author decides. Offer to run `/claim-check` on flagged overclaims and `/citation-audit` on flagged bibliography issues as the follow-up.

## Output Format

```markdown
# Referee Report — <manuscript title> (simulated)

## Summary (reviewer's understanding)
This manuscript argues <thesis, in the reviewer's words>. The contribution is
<X>, established via <method>. [2–4 sentences showing the contribution was understood.]

## Recommendation
Major revision  (Major: 3, Minor: 6)

## Major Issues
1. **[Soundness]** §Discussion ¶3 (discussion.tex:41): The claim "EC causes
   removal across matrices" is causal and general, but the design tests one
   matrix and shows association. The conclusion overreaches the evidence.
   → Restrict to the tested matrix and to associational language, or supply the
   comparison/identification that licenses the stronger claim. (Protected: verb +
   scope change on the central claim.)
2. **[Integrity]** §Results (results.tex:62): "70 ng/L regulatory limit" carries
   no citation and is not in the data. UNSUPPORTED. → Cite the regulation or flag
   [CITE]; do not assert it bare.
3. **[Prior Top Rule]** tasks/reviews flagged overclaim in the discussion before;
   §Discussion ¶5 repeats the pattern. → Apply the existing rule.

## Minor Issues
1. **[Statistics]** §Results: p-values reported without effect sizes or CIs. Add both.
2. **[Clarity]** §Intro ¶2: the gap is stated twice; the contribution once. Invert.
3. **[Cross-ref]** discussion.tex:40: \ref{fig:flux} has no \label.
4. **[Terminology]** "removal efficiency" and "uptake" used interchangeably — lock one (MANUSCRIPT_MAP → Terminology).
5. **[Sourcing]** §Intro: "widely reported" needs at least one cite or reframing.
6. **[Reproducibility]** No data-availability statement.

## Edit Checklist (for the author — not auto-applied)
- [ ] Discussion ¶3: calibrate verb + scope (PROTECTED — confirm)
- [ ] Results: resolve [CITE] on regulatory limit
- [ ] Results: add effect sizes + CIs
- [ ] Fix \ref{fig:flux}
- [ ] Add data-availability statement
- [ ] Lock terminology to "removal efficiency"

## Suggested follow-ups
- /claim-check sections/discussion.tex  (the overclaim cluster)
- /citation-audit                       (sourcing + cross-ref issues)
```

## Pairs With

- **`peer-reviewer` agent** + **`integrity-reviewer` agent** — the two lenses this skill orchestrates (Phase 2). Defined in `.claude/agents/`; methodology in `agent_docs/peer-review.md`.
- **`/claim-check`** — the targeted follow-up for flagged overclaims (verb/quantifier verification against sources).
- **`/citation-audit`** — the follow-up for flagged bibliography/cross-reference issues.
- **`/journal-fit`** — run alongside when the question is also "is this the right venue?"
- **`tasks/reviews/`** — recurring critiques live here; an unaddressed Top Rule is automatically a Major issue.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "My co-authors already read it" | Co-authors share your blind spots and your investment. Simulate the hostile stranger. |
| "Reviewer 2 is just mean" | Reviewer 2 is reading adversarially — which is the correct way to read your strongest claims. Pre-empt them. |
| "These are nitpicks" | A pile of minor issues reads as carelessness and primes the referee to doubt the major claims too. |
| "Let the journal find the problems" | The journal finding them costs you a rejection or a revision cycle. Find them now. |
| "Just fix the issues for me" | Fixes to the thesis/quantities/methods/argument-citations are Protected — they need the author, not the agent. |

## Notes

- Reviewing is judgment-heavy — run on the Reasoner model (`CLAUDE.md → Model Selection`).
- Feed the outcome back: a critique you keep receiving is a rule. Log it to `tasks/reviews/` and promote to Top Rules if it recurs.
- This is a *simulation* — it pre-empts likely objections; it does not guarantee acceptance. Its job is to leave Reviewer 2 with less to say.
