---
name: plain-language-summary
description: Draft a lay / plain-language summary for a general audience, funder, or a journal's required PLS — accessible to a non-specialist without distorting the science, with a claim-by-claim fidelity check against the paper
user-invocable: true
---

# Plain-Language Summary

## Core Rule

A plain-language summary makes the work **accessible to a non-specialist without distorting the science**. Two failure modes, equally bad: jargon that locks the reader out, and *false simplification* that turns a calibrated finding into a stronger, cleaner claim than the paper makes. **Simpler wording must never become a stronger claim.** "reduces invalid tool calls on our benchmark" is allowed; "stops AI from making mistakes" is not — it dropped the scope, dropped the calibration, and overstated the result.

The PLS is bound by the same cardinal rule as the manuscript (`CLAUDE.md → Source-Grounded Writing`): every statement traces to what the paper actually establishes, with its scope intact. Removing the hedge to read smoothly is overclaim; inventing a relatable number ("works 9 times out of 10") the paper does not report is fabrication. Plain does not mean loose.

This skill rewrites for a general reader. It does not change the contribution or any reported quantity — those are fixed by the manuscript.

## When to Use

Invoke with `/plain-language-summary` when:

- A journal requires a plain-language summary, significance statement, or lay abstract.
- A funder, institutional press office, or grant report needs a non-specialist description.
- You want a general-audience version of the work that still passes a specialist's accuracy check.

State the audience if it matters: `/plain-language-summary funder`. The default is an educated general reader with no background in LLM agents.

## Process

### Phase 1: Extract the Core Finding and Why It Matters

1. **Read `MANUSCRIPT_MAP.md`** (Thesis, Contribution, headline result) and the **abstract** if drafted. These are the ground truth the PLS must stay faithful to — the summary introduces nothing not already established there.
2. **Name the one core finding** in a single sentence, keeping its scope: e.g. "a small checking step, run before an AI agent uses a tool, cut the number of invalid tool calls in our tests." Note the calibration words (*in our tests*, *reduced* not *eliminated*) — these survive the rewrite.
3. **Name why it matters**, grounded in what the paper supports — the real-world stake (more reliable AI assistants), not an inflated promise the paper does not back.
4. **List the jargon** to translate or cut: "tool-call hallucination," "multi-turn agent," "verification gate," "task-success rate." Each gets a plain rendering or an inline gloss.

### Phase 2: Rewrite at a General-Reader Level

1. **Open with the problem in concrete terms** — what goes wrong and why a reader should care, no acronyms. ("AI assistants that take actions — looking things up, running tools — sometimes try to use a tool that isn't there, or use it wrong.")
2. **State what the work did**, plainly. ("We added a quick check that confirms each action is valid before the assistant runs it.")
3. **State what was found, with the scope kept.** ("In our experiments, this reduced the number of invalid actions and improved how often the task was completed.") Do **not** quote a precise statistic unless the manuscript reports it; if you give a number, it is the paper's number with its scope — otherwise describe the direction ("reduced") without inventing a magnitude.
4. **Close with the grounded significance** — the realistic implication, calibrated. No "this will make AI safe"; rather "a simple, low-cost step toward more reliable AI assistants."
5. **Jargon discipline** — define on first use or remove. One plain term per concept (`CLAUDE.md → Claim Discipline`); do not swap synonyms that muddy the meaning. Short sentences. No citations, no equations.

### Phase 3: Fidelity Check (claim by claim)

This is the load-bearing phase. For **each sentence** of the PLS, find the paper's claim it rests on and confirm the plain version did not strengthen it:

- **Scope preserved?** "in our tests / on our benchmark" not silently dropped to imply "always."
- **Calibration preserved?** "reduced/suggests" not upgraded to "eliminated/proves."
- **No invented quantity?** Any number is the paper's, with scope; otherwise the direction is described, not a magnitude guessed.
- **No new claim?** The PLS says nothing the manuscript does not establish — no added benefit, no broadened population.

Anything that fails goes back to Phase 2. A smoother sentence that overstates is a defect, not a stylistic choice.

## Output Format

```markdown
# Plain-Language Summary — <manuscript>
> Audience: general reader.  Source of truth: MANUSCRIPT_MAP + abstract.
> Plain wording, same calibrated claims — scope and hedges preserved.

## Summary
AI assistants that take actions on your behalf — searching, running tools — can
go wrong by trying to use a tool that doesn't exist, or using it incorrectly. We
added a quick automatic check that confirms each action is valid *before* the
assistant carries it out. In our experiments, this reduced the number of invalid
actions and improved how often the assistant completed the task. The check is
simple and adds little delay, making it a practical step toward more reliable AI
assistants. (It reduces a known failure; it does not eliminate every error.)

## Fidelity check (claim by claim)
| Plain sentence | Rests on (paper) | Faithful? |
|---|---|---|
| "...try to use a tool that doesn't exist, or using it incorrectly" | The hallucinated/invalid tool-call problem [halluc2022] | Yes — describes, no overstatement |
| "a quick automatic check ... before the assistant carries it out" | The pre-execution verification gate (method) | Yes — plain restatement of the method |
| "reduced the number of invalid actions and improved how often the task was completed" | Reported improvement in tool-call accuracy / task-success **on our benchmark** | Yes — direction kept; scope kept; no invented magnitude |
| "a practical step toward more reliable AI assistants" | Discussion's calibrated implication | Yes — grounded; not "makes AI safe" |
| "does not eliminate every error" | Paper claims reduction, not elimination | Yes — preserves the hedge |

## Flags
- No precise statistic quoted (manuscript figure not restated here to avoid a
  scope-stripped number); say "reduced," or insert the paper's exact value WITH
  "in our benchmark" if a number is required.
```

## Pairs With

- **`/abstract`** — the abstract is the specialist version; the PLS is its plain-language sibling. Both must carry the same calibrated claim and scope — keep them consistent.
- **`agent_docs/academic-style.md`** — the calibrated-language reference; the PLS relaxes vocabulary but obeys the same calibration rules (verbs and quantifiers matched to evidence).
- **`MANUSCRIPT_MAP.md`** — Thesis and Contribution are the fidelity baseline; the PLS may not exceed them.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "Lay readers want a clean takeaway — drop 'in our tests'" | Scope is part of the claim, not specialist clutter. Dropping it overstates. Keep it in plain words: "in our experiments." |
| "'Stops AI mistakes' is punchier than 'reduces invalid tool calls'" | "Stops/eliminates" is a stronger claim than the paper makes. Punchy that overstates is wrong. Use "reduces." |
| "Add 'works 9 times out of 10' so it's relatable" | If the paper doesn't report that, it's fabricated. Describe the direction, or use the paper's exact figure with scope. |
| "Simplify 'associated with' to 'causes'" | That swaps a correlation for a cause — a hard overclaim. Plain language keeps the relationship the paper supports. |
| "Skip the 'does not eliminate every error' caveat — it weakens it" | The caveat is what makes the summary honest and accurate. Calibration is not optional in the PLS. |

## Notes

- The rewrite is plain; the **fidelity check is the rigor** — run it claim by claim, on the Reasoner model (`CLAUDE.md → Model Selection`), because judging "did this stay faithful?" is exactly the judgment the kit exists to protect.
- The single rule: **wording gets simpler, claims do not get stronger.** Strip jargon, keep scope and calibration.
- If a required PLS has a word cap, count with `texcount` (`CLAUDE.md → Model vs Code`), do not estimate.
