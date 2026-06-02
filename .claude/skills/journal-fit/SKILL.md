---
name: journal-fit
description: Assess a manuscript's fit to a target journal/venue — scope, novelty bar, length & structure limits, reference style (ACS/IEEE/APA/Nature), audience, article types — and output a fit score with reasoning and a prioritized gap list
user-invocable: true
---

# Journal Fit

## Core Rule

Fit is a judgment from known conventions, not a fabricated metric. **Never invent a journal's specific numbers** — do not assert an impact factor, an acceptance rate, an exact word limit, or a precise display-item cap you cannot source. Reason from what is *stated* (in `MANUSCRIPT_MAP.md`), what is *broadly known* about the venue class (ACS / IEEE / APA / Nature-family conventions), and tell the author to **confirm the exact figures against the journal's current author guidelines**. A confidently-wrong "6000 word limit" is the same failure mode as a fabricated citation: a specific claim with nothing behind it.

This skill assesses fit and produces a gap list — it does not reshape the manuscript. Restructuring to fit is downstream work (`/outline`).

## When to Use

Invoke with `/journal-fit` when:

- Choosing where to submit, or sanity-checking a target before the final push.
- A draft is near-complete and you want the structure/length/style gaps surfaced before formatting.
- A desk-reject risk is in play — fit-to-scope is the #1 desk-reject reason; catch it early.
- Comparing two candidate venues (run the skill twice, compare gap lists).

State the target: `/journal-fit Environmental Science & Technology`. If no venue is given, read it from `MANUSCRIPT_MAP.md → Target journal`.

## Process

### Phase 1: Load the Manuscript's Self-Description

1. **Read `MANUSCRIPT_MAP.md`** — Thesis, Contribution, Audience, target venue, the Structure table (sections + budgets → current length), Figures & tables count, and the reference style noted there.
2. **Estimate current length** — sum the section budgets / use `texcount` on the drafted `.tex` (deterministic — don't eyeball; `CLAUDE.md → Model vs Code`). Count display items against `MANUSCRIPT_MAP → Figures & tables`.
3. **Identify the article type** the manuscript is — full research article, letter/communication, review, methods/protocol, perspective. Venues accept different types with different limits.

### Phase 2: Establish the Venue's Known Conventions

Reason from the venue *class*, and be explicit about confidence:

1. **Reference style** — the deterministic, knowable axis:
   - **ACS** (Chem, ES&T): numbered, ISO-4 journal abbreviations, sentence-case titles.
   - **IEEE** (engineering/CS): numbered `[1]` in brackets, abbreviated, specific field order.
   - **APA** (psych/social/education): author–date, full journal names, DOI required.
   - **Nature-family**: superscript numbers, highly compressed, strict display-item limits.
   Mismatched style is a concrete, fixable gap — name the required style.
2. **Scope & audience** — is the topic in the journal's stated aims? Is the framing pitched at its readership (specialist vs broad)? This is the highest-weight, most-judgment axis.
3. **Novelty bar** — broad-impact venues (Nature/Science family, top field journals) demand a larger contribution delta than solid specialist journals. Calibrate the manuscript's contribution (from `MANUSCRIPT_MAP`) against the bar — *qualitatively*. Do not invent an acceptance rate to quantify it.
4. **Length & structure** — typical limits for the article type. **State these as conventions to verify, not facts.** "ACS full articles commonly run ~7000 words with ~6 display items — confirm the exact cap in the current author guidelines."
5. **Article types accepted** — does the venue publish the type this manuscript is?

For anything you cannot source — exact word count, exact figure cap, impact factor, acceptance rate — say "confirm in author guidelines," never a fabricated number.

### Phase 3: Score Each Axis

Rate fit per axis, with the reasoning that drives the score:

| Axis | What "good fit" looks like | Weight |
|---|---|---|
| **Scope match** | Topic squarely in the venue's aims; framing matches readership | High |
| **Novelty bar** | Contribution clears the venue's typical significance threshold | High |
| **Audience** | Background level + terminology pitched at this readership | Medium |
| **Length** | Within the type's typical limits (confirm exact) | Medium |
| **Structure** | Matches expected section format (IMRaD / structured abstract / merged R&D) | Medium |
| **Reference style** | Matches required style, or a known mechanical conversion away | Low (fixable) |
| **Article type** | The venue publishes this type | Gate |

Weight scope, novelty, and audience highest — they decide desk-reject. Reference style is low-weight because it is a deterministic conversion (`biber`/CSL), not a fundamental misfit.

### Phase 4: Produce the Fit Verdict and Gap List

1. **Overall fit** — Strong / Moderate / Weak, with one-paragraph reasoning that names the deciding axes. Not a fabricated percentage — a calibrated judgment.
2. **Gap list** — what to change to fit, ordered by effort × impact: scope/framing gaps first (hardest, highest-stakes), mechanical gaps (style, length trim) last.
3. **Alternative venues** — if fit is Weak, suggest venue *classes* that fit better (e.g. "a specialist methods journal rather than a broad-impact one"), without inventing their metrics.

## Output Format

```markdown
# Journal Fit — <manuscript> → Environmental Science & Technology
> Source of venue conventions: known ACS/ES&T conventions + MANUSCRIPT_MAP.
> CONFIRM all exact limits against the current ES&T author guidelines — figures below are conventions, not quoted policy.

## Overall fit: Moderate
The topic (PFAS removal from leachate) sits squarely in ES&T's scope and the
contribution is a genuine matrix-extension delta, so scope and novelty fit well.
The main risks are length (currently ~8200 w against a commonly ~7000 w norm —
verify) and a reference style mismatch (drafted APA; ES&T uses ACS). Structure
is standard IMRaD, which fits.

## Axis scores
| Axis | Fit | Reasoning |
|---|---|---|
| Scope | Strong | Leachate PFAS treatment is in ES&T aims |
| Novelty | Strong | First leachate-matrix demonstration; clears a solid-specialist bar |
| Audience | Strong | Environmental-engineering readership; terminology matches |
| Length | Weak | ~8200 w; ES&T full articles commonly ~7000 w — CONFIRM and trim |
| Structure | Strong | IMRaD as expected |
| Reference style | Weak (fixable) | Drafted APA; ACS required — mechanical conversion |
| Article type | Pass | Full research article — published by ES&T |

## Gap list (ordered by effort × impact)
1. **[Length]** Trim ~1200 w to reach the ~7000 w norm (CONFIRM exact cap). Target the Discussion. — high effort
2. **[Style]** Convert APA → ACS (numbered, ISO-4 abbreviations) via biber/CSL — do not retype. — low effort, deterministic
3. **[Display items]** 7 figures + 2 tables = 9; ES&T commonly caps ~6 — CONFIRM, then move surplus to SI. — medium
4. **[Framing]** Abstract leads with method, not impact; ES&T readers want the environmental significance up front. — low effort, high payoff

## Before you submit
- Pull the CURRENT ES&T author guidelines and replace every "CONFIRM" above with the quoted limit.
- Run /citation-audit after the style conversion.
- Consider /peer-review against the novelty bar.

## If fit were Weak
A specialist water-treatment journal would impose a lower novelty bar and looser
length limits than a broad-impact venue — consider that venue class. (No metrics
invented; confirm any specific journal's guidelines directly.)
```

## Pairs With

- **`MANUSCRIPT_MAP.md`** — the source of the manuscript's scope, length, and current style; the fit check reads it first.
- **`/outline`** — if structure/length gaps are large, re-outline to the venue's shape.
- **`/citation-audit`** — run after a reference-style conversion to verify field completeness for the new style.
- **`/peer-review`** — pair when the question includes "does the contribution clear the bar?" — the novelty-bar axis is exactly what a referee judges.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The word limit is 6000" (unsourced) | If you cannot point to the author guidelines, that number is a fabrication. Say "confirm exact limit." |
| "High impact factor, worth a shot" | A fabricated or stale impact factor is not a fit argument. Fit is scope + novelty + audience, sourced from aims. |
| "Reference style is easy, ignore it for now" | Right that it's low-stakes (it's a CSL conversion) — but still list it so it isn't forgotten at submission. |
| "Close enough on scope" | Scope mismatch is the #1 desk-reject. "Close enough" gets bounced before review. Be honest about the gap. |
| "I'll just trim later" | A 30%-over manuscript needs structural cuts, not later polish. Surface the trim target now. |

## Notes

- Fit assessment is judgment from conventions — run on the Reasoner model (`CLAUDE.md → Model Selection`).
- The single rule that matters: known conventions in, "confirm in author guidelines" for anything exact, zero invented metrics.
- A "Weak" verdict is a service — re-targeting before submission beats a desk-reject after.
