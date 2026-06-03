---
name: abstract
description: Draft or tighten the abstract as a contract — every number and claim in it must appear identically in the body, within the venue's word limit, calibrated to what the paper actually shows
user-invocable: true
---

# Abstract

## Core Rule

**The abstract is a contract, not a teaser.** Every quantity and every claim in it must
appear *identically* in the body (Results) — same number, same scope, same calibrated
verb — fit within the venue's word/structure limit, and never assert anything the paper
does not show. An abstract is the most-read and least-checked part of a manuscript, which
is exactly why a number that drifts from the Results table, or a verb that outruns the
evidence, does the most damage. **Never introduce a number or a claim in the abstract that
is not already in the body.** If the body does not contain it, it does not go in the
abstract — you fix the body first (a Protected Claim) or you cut the line.

This skill drafts/tightens the abstract and reports a consistency check; it is not a
licence to invent a headline result the experiments did not produce.

## When to Use

Invoke with `/abstract` when:

- The Results are settled and you need a first abstract built from them.
- An existing abstract is over budget, or reads as a list of methods rather than findings.
- After a revision changed a reported number — the abstract must be re-reconciled to the
  body (a silent abstract/body mismatch is the classic submission embarrassment).
- Before submission, as the last consistency pass: every abstract number ↔ its body source.

State the venue if it sets the format: `/abstract NeurIPS` (unstructured, ~caps differ) vs a
journal that mandates a structured abstract. If none is given, read it from
`MANUSCRIPT_MAP.md → Target journal`.

## Process

### Phase 1: Pull the Contract Material

Before writing a word, gather what the abstract is allowed to say — all of it from inside
the manuscript:

1. **Read `MANUSCRIPT_MAP.md`** — the Thesis (one sentence), the Contribution (what is
   new), the Audience, the Target journal, and **Claims that need extra care** (the
   do-not-inflate list — these constrain the abstract hardest).
2. **Read the Results section** in full (and the primary table/figure). Every number you
   might put in the abstract must already live here. Note each headline result with its
   exact value, its uncertainty, and its scope (which harness, which task set).
3. **Read the Introduction's contribution statement** — the abstract's claims should be the
   contribution list compressed, not a new set of promises.
4. **Find the word/structure limit** — venue word cap and whether it is structured
   (Background / Methods / Results / Conclusions) or a single unstructured paragraph. Treat
   any exact cap as *verify against the current call* unless `MANUSCRIPT_MAP` quotes it.

If a number you want in the abstract is *not* in the body, stop: either it belongs in
Results first (raise it as a Protected Claim per `CLAUDE.md`), or it does not go in the
abstract. Do not let the abstract be where a quantity makes its debut.

### Phase 2: Draft Within Budget

Write the smallest abstract that carries thesis → gap → what-we-did → key result → what it
means. Structure to the venue:

- **Unstructured (most ML/NLP venues — NeurIPS/ACL):** one paragraph. Problem and gap (1–2
  sentences) → approach (1–2) → the headline quantitative result (1–2) → the takeaway (1).
- **Structured (many journals):** fill the mandated labels; keep each to its purpose.

Discipline while drafting:

- **Lead with the finding, not the machinery.** "We present a verification gate…" buries the
  result; "A pre-execution verification gate reduced the hallucinated tool-call rate by 18
  percentage points…" leads with it. (`MANUSCRIPT_MAP → Audience` wants the payoff up front.)
- **Use the locked term** for each concept (`MANUSCRIPT_MAP → Terminology`): "tool-call
  accuracy", "hallucinated tool-call rate", "task success", "task horizon" — do not alternate
  synonyms between abstract and body.
- **Carry uncertainty if the venue allows it.** "18 pp (95% CI 11–25)" is stronger and more
  honest than a bare point estimate; at minimum do not state a point estimate the Results
  qualify heavily.
- **No citations in the abstract** unless the venue explicitly permits — and even then, never
  introduce a `\cite` here that the body does not also carry.

### Phase 3: Verify Every Quantity Against the Body

This is the heart of the contract. For **each number in the draft abstract**, find its twin
in the body and confirm they are identical — recompute, do not eyeball
(`CLAUDE.md → Model vs Code`; `agent_docs/statistics.md → text ↔ tables ↔ abstract`):

- **Value** matches the Results sentence / table cell exactly (92% in the abstract is not 89%
  in Table 2).
- **Scope** matches — "across all tasks" in the abstract must not summarize a result the body
  reports for one task subset.
- **Units / percentage-vs-percentage-points** match the body's usage.
- **N and uncertainty**, if stated, match.

Any number with no body twin is a contract breach: cut it, or fix the body first. If you
cannot confirm a value against the body, mark it `[VALUE — verify]` in the consistency check —
do not ship an unverified abstract number.

### Phase 4: Calibrate the Verbs

Run each claim sentence against the evidence the body actually provides
(`agent_docs/academic-style.md → verb ladder`):

- The abstract's verb must not exceed the body's. If Results show an association, the abstract
  says "was associated with", not "caused". If one harness was tested, the abstract does not
  say "in deployment" or "in general".
- Cross-check every claim against `MANUSCRIPT_MAP → Claims that need extra care`. A
  "first / SOTA / general" claim in the abstract needs the comparison in the body that earns
  it — if the body does not establish it, soften or cut.
- Hedge once, at the right rung — an over-hedged abstract buries the finding as badly as an
  over-claimed one misrepresents it.

### Phase 5: Report

Output the abstract, the word count against budget, and the consistency check (every abstract
number ↔ its body source). **Do not change a reported quantity to make the abstract "work"** —
that is a Protected Claim; surface the mismatch and let the author resolve it in the body.

## Output Format

```markdown
# Abstract — <manuscript> → ACL (unstructured, verify ~150-word cap)

## Draft
A pre-execution verification gate for LLM-agent tool calls is proposed to curb
hallucinated tool calls on long-horizon tasks. Across 512 held-out tasks on a ReAct
harness, the gate raised tool-call accuracy by 18 percentage points (95% CI 11–25)
and reduced the hallucinated tool-call rate from 21% to 6%, with task success
unchanged. The effect grew with task horizon, consistent with grounding each call
before execution. The gate is model-agnostic and adds one verification step per call.

Word count: 71 / ~150 (CONFIRM exact cap against the current ACL call)

## Consistency check (every abstract number ↔ body source)
| Abstract claim / number | Body source | Match? |
|---|---|---|
| "18 percentage points (95% CI 11–25)" | Results ¶2 / Table 2 row "gate vs base" | OK |
| "hallucinated tool-call rate from 21% to 6%" | Results ¶3 / Table 2 | OK |
| "512 held-out tasks" | Methods ¶1 | OK |
| "task success unchanged" | Results ¶4 ("no significant change, p = 0.41") | OK — verb calibrated |
| "grew with task horizon" | Results ¶5 / fig:horizon | OK |
| "model-agnostic" | — | GAP — body tests one model; soften to "in the tested setting" or cut |

## Calibration notes
- "consistent with grounding each call" — correct hedge; the mechanism is inferred, not
  shown (matches MANUSCRIPT_MAP → Claims that need extra care).
- "model-agnostic" exceeds the evidence (one model tested) — flagged above.

## Flags
- [Protected] "model-agnostic" has no body support — do not assert in the abstract until
  the body shows it. Cut or rescope; needs author decision.
- Confirm the ~150-word cap against the current ACL call for papers.
```

End with the contract tally: `(numbers matched / mismatched / unverified)` and the word
count vs budget. Never report an abstract "done" while a number lacks a body twin or a
`[VALUE — verify]` remains.

## Pairs With

- **`/claim-check`** — run it on the abstract's claim sentences for the deep verb/quantifier
  pass; `/abstract` checks the abstract↔body contract, `/claim-check` checks each claim
  against its source.
- **`citation-gate.sh`** (PostToolUse) — if the venue allows abstract citations, this proves
  any `\cite` resolves; the abstract must not introduce a key the body lacks.
- **`agent_docs/academic-style.md`** — the verb/quantifier ladder the calibration phase
  applies; read it for the strength/scope rungs.
- **`/journal-fit`** — for the venue's abstract format and length convention before drafting.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The abstract can round 89% up to ~90%" | The abstract must match the body's number, not a friendlier version of it. 89% in Table 2 is 89% in the abstract. |
| "This result is so strong I'll lead with the stronger framing" | The abstract's verb may not exceed the body's. Calibrate to what Results show, not to what would impress. |
| "I'll add the headline number; the body basically has it" | "Basically" is a contract breach. If the exact number is not in the body, put it there first (Protected Claim) or cut it. |
| "It's just the abstract, reviewers read the paper" | The abstract is the most-read part and the one editors screen on. A mismatch here is the first thing a careful reviewer flags. |
| "Over budget, but every sentence matters" | A 200-word abstract in a 150-word venue gets truncated or bounced. Cut the machinery sentence, keep the finding. |

## Notes

- This skill never invents a result to headline. Its only sourcing output is the consistency
  check and `[VALUE — verify]` flags — honest, per the cardinal rule in `CLAUDE.md`.
- Reconciling the abstract to the body and calibrating verbs is judgment work — run on the
  Reasoner model (`CLAUDE.md → Model Selection`); the word count is `texcount`, not estimation.
- A recurring abstract/body mismatch (the author keeps catching drifted numbers) is a rule —
  log it under `tasks/reviews/`, `applies_to: [abstract, statistics]`, promote to
  `## Top Rules` if it recurs (`CLAUDE.md → Self-Improvement Loop`).
- Changing a reported quantity to reconcile the two is a **Protected Claim** — fix the body
  with author sign-off; never silently edit the abstract to a number the Results do not show.
