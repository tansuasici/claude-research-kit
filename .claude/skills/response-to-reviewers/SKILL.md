---
name: response-to-reviewers
description: Draft a point-by-point response letter — quote each reviewer comment, state the change made and its exact location, stay courteous, and NEVER claim a change not actually made. Produces the letter plus an edit checklist, logging recurring critiques to tasks/reviews/
user-invocable: true
---

# Response to Reviewers

## Core Rule

A response letter is a **promise to the editor that the manuscript now matches what you wrote**. Therefore: **never claim a change you have not made.** Every "we have revised X" must point to a real edit at a real location (section + line, or quoted new text). If a change is intended but not yet applied, the letter says so honestly ("we will revise…") or — better — the edit is made first and then described. A response that overstates the revision is the same integrity failure as a fabricated citation, and the editor *will* check.

Address every point. Quote it. State the change and where. Stay courteous even when the reviewer is wrong — disagreement is fine, dismissiveness is not. The letter reports edits; making the edits (especially to thesis/quantities/methods/argument-citations) is Protected work that needs the author.

## When to Use

Invoke with `/response-to-reviewers` when:

- A decision letter arrived (major/minor revision) and you need a point-by-point response.
- You have applied (or planned) revisions and need the letter that maps each to a reviewer comment.
- Preparing a rebuttal where you must defend a choice the reviewer questioned, with evidence.

Provide the reviews: paste the decision letter, or point to the file. If the manuscript was revised already, the skill verifies each claimed change against the actual diff.

## Process

### Phase 1: Parse the Decision Letter

1. **Read the reviews** — split into individual, numbered comments per reviewer (R1.1, R1.2, R2.1…). A single paragraph often contains two distinct asks — split them so none is missed.
2. **Read `MANUSCRIPT_MAP.md`** — Thesis, Contribution, "Claims that need extra care." A reviewer ask that would change the thesis, a reported quantity, or the methods is a **Protected Claim** — flag it; the author decides whether to comply, not the agent.
3. **Read `tasks/reviews/_index.md → ## Top Rules`** — if a reviewer is flagging something you have been told before, this is a recurring critique to log (Phase 5).

### Phase 2: Classify Each Comment

For every comment, decide the response posture:

| Posture | When | What the letter does |
|---|---|---|
| **Agree + changed** | The point is right and fixable | State the change + exact location |
| **Agree + clarified** | A misreading caused by unclear text | Point to the clarifying edit (the fix is usually in the manuscript, not just the letter) |
| **Partially agree** | Right in part | Make the warranted change; explain the boundary courteously |
| **Respectfully disagree** | The reviewer is mistaken or asks beyond scope | Defend with evidence/citation; concede nothing you cannot support, claim nothing you cannot either |
| **Cannot do (scope/data)** | Out of scope or data unavailable | Explain honestly; offer what you *can* do (e.g. acknowledge as a limitation) |

A disagreement still gets a courteous, evidence-bound reply — never silence, never dismissal.

### Phase 3: Verify Every Claimed Change Against the Manuscript

This is the integrity gate of the skill. For each "we changed X":

1. **Locate the actual edit** — the section/line or the new text in the `.tex`. If the manuscript was revised, diff old vs new and confirm the change exists.
2. **If the change is NOT in the manuscript**, you have two honest options: (a) make the edit now (if it is not a Protected Claim — those need author sign-off), then describe it; or (b) write "we will revise…" / surface it on the edit checklist as *pending*. **Do not write "we have revised" for an edit that is not there.**
3. **Quote new text accurately** — if the letter quotes the revised sentence, it must be verbatim from the manuscript (same fidelity rule as a source quotation).
4. **Cite honestly** — if the response adds a citation to satisfy a reviewer, that `\cite` must resolve in `references.bib` to a real source. Never invent one to look responsive (`block-fabrication.sh` will block the stub; the cardinal rule forbids it regardless).

### Phase 4: Draft the Letter

Write the point-by-point letter. Conventions:

1. **Open** with a brief, genuine thanks to the editor and reviewers and a one-line summary of the revision's scope.
2. **Per comment**: quote the reviewer verbatim (blockquote/italic), then the response, then the precise location and — where useful — the quoted new text. Use a stable numbering (R1.1, R2.3) the editor can follow.
3. **Courteous register** throughout — "We thank the reviewer for…", "We agree…", "We respectfully note…". Calibrated, not defensive, not obsequious.
4. **Close** with a short statement that all points have been addressed.

### Phase 5: Emit the Edit Checklist and Log Recurring Critiques

1. **Edit checklist** — every change the letter claims, with its status: **done** (verified in the manuscript) or **PENDING** (must be applied before submission). Flag Protected Claims for author approval. The letter and the manuscript must be reconciled before the response goes out — a PENDING item means the letter is not yet truthful.
2. **Log recurring critiques** — for any comment that repeats prior feedback, add a note under `tasks/reviews/` (`<YYYY-MM-DD>-<slug>.md`, template `tasks/reviews/_TEMPLATE.md`): Feedback → Root Cause → Rule, tagged `applies_to: [reviewer-response, ...]`. Promote to `_index.md → ## Top Rules` if it has recurred. A reviewer's repeated complaint is a rule, not a one-off.

## Output Format

```markdown
# Response to Reviewers — <manuscript title>

We thank the editor and both reviewers for their careful reading. We have revised
the manuscript to address all points; changes are summarized below and marked in
the revised file. [1–2 lines on the revision's scope.]

---

## Reviewer 1

**R1.1** — *"The causal language in the Discussion overstates an associational result."*

We agree. We have changed "the gate causes higher accuracy" to "the gate is
associated with higher accuracy" throughout the Discussion (discussion.tex §4 ¶3,
and the abstract). The revised sentence reads: "The verification gate was
associated with >90% removal of hallucinated tool calls on the tested agent
harness." *(Verified in manuscript.)*

**R1.2** — *"Effect sizes are not reported alongside p-values."*

We agree. We now report effect sizes with 95% CIs in Table 2 and the Results text
(results.tex §3.2). *(Verified.)*

**R1.3** — *"Consider generalizing the claim to other agent settings."*

We respectfully note this is beyond the tested scope: our data cover the tested
agent harness only. Rather than generalize unsupported, we have added a sentence in
the Limitations (discussion.tex §4 ¶6) noting that extension to other settings
requires further study. *(Verified.)*

## Reviewer 2

**R2.1** — *"Where is the baseline hallucination rate sourced?"*

We thank the reviewer for catching this. The 23% baseline rate is now cited to the
relevant survey (halluc2022) at results.tex §3.1. *(Verified — halluc2022 resolves
in references.bib.)*

---

We believe the revisions address all reviewer comments and have improved the
manuscript. We are happy to make further changes if needed.

## Edit Checklist (reconcile BEFORE sending — letter must match manuscript)
- [x] Discussion + abstract: causal → associational (R1.1) — done [PROTECTED: was confirmed by author]
- [x] Table 2 + Results: add effect sizes + CIs (R1.2) — done
- [x] Limitations: harness-scope caveat (R1.3) — done
- [x] Results: cite halluc2022 for 23% baseline rate (R2.1) — done
- [ ] R2.2 (add an ablation experiment) — PENDING author decision: out of current data; propose acknowledging as limitation. NOT yet claimed as done in the letter.

## Logged to tasks/reviews/
- 2026-06-03-overclaim-discussion-causal.md (applies_to: [overclaim, reviewer-response]) — recurrence of a prior Top Rule; promoted.
```

## Pairs With

- **`prompt-router.sh`** — fires the reviewer-response reminder on revision keywords (quote the reviewer, state change + location, courteous, never claim an unmade change). This skill operationalizes that reminder.
- **`/claim-check`** — run on any section where a reviewer flagged overclaim, to confirm the revised verb/quantifier now matches the evidence before you claim the fix.
- **`/citation-audit`** — run if the response added citations, to confirm they resolve and are well-formed.
- **`block-fabrication.sh`** — blocks adding a stub citation to look responsive. If it fires, the "fix" was a fabrication.
- **`tasks/reviews/`** — recurring critiques are logged here (Phase 5); `agent_docs/peer-review.md` documents the response methodology.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "Say we changed it; I'll edit it before sending" | The letter and manuscript must match when sent. Mark it PENDING, not "done." Editors diff the revision. |
| "Add a citation so the response looks thorough" | A citation must resolve to a real source. Inventing one to look responsive is fabrication — forbidden and hook-blocked. |
| "The reviewer is wrong, I'll ignore that point" | Every point gets a courteous, evidence-bound reply. Silence reads as evasion and risks the resubmission. |
| "Just generalize the claim like R2 asked" | If the data don't support generalization, don't. Explain the scope and offer a limitation — overclaiming to please a reviewer is still overclaiming. |
| "We can drop the hedge to sound more confident" | The reviewer asked for calibration. Match certainty to evidence; confidence is not the goal, defensibility is. |

## Notes

- Drafting the framing and judging disagreements is Reasoner work; mechanical letter formatting is Drafter work (`CLAUDE.md → Model Selection`).
- The non-negotiable: the letter never claims a change the manuscript does not contain. Reconcile the edit checklist to zero PENDING-but-claimed items before sending.
- Changes to thesis/quantities/methods/argument-citations remain Protected — confirm with the author and record in `tasks/decisions.md` before describing them as done.
