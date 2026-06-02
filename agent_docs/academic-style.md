# Academic Style & Calibrated Language

The expansion of `CLAUDE.md → Claim Discipline` and the "**Never overstate**" clause
of the cardinal rule. Read this before drafting prose, and before any task the
prompt-router flags as `[Claim calibration]`.

Calibration is not hedging-for-its-own-sake. It is matching the **strength of the
verb and quantifier** to the **strength of the evidence**, so a skeptical Reviewer 2
signs off on the sentence. Overclaiming is the most common way a true result becomes
an unsupportable one.

If `STYLE.md` exists, it is the manuscript's voice source of truth (tense, person,
terminology) — read it first; it overrides the defaults here.

---

## The verb ladder (strength of assertion)

Pick the **weakest verb the evidence supports**, not the strongest you can get away
with. Top = strongest claim; reserve it for the strongest evidence.

```text
proves            ← mathematical proof, or a deductively closed argument. Almost never
                    licensed by empirical data. Avoid in experimental work.
demonstrates      ← direct, controlled experimental evidence; the effect is shown, not inferred.
shows             ← clear, replicated empirical support. The workhorse for your own solid results.
establishes       ← shows + settles a previously open question.
indicates         ← the evidence points one way but is not decisive.
suggests          ← consistent with the claim; plausible but underdetermined.
is consistent with← the data do not contradict the claim (weakest positive — does NOT confirm it).
is associated with← a statistical relationship, no causal direction asserted. Default for observational data.
may / might / could← possibility only; flag for a hypothesis or a Discussion conjecture.
```

The quantifier ladder runs in parallel — calibrate scope as carefully as strength:

```text
all / every  >  most  >  many  >  some  >  a few  >  (none)
always       >  usually / typically  >  often  >  sometimes  >  occasionally
in general   >  across the tested conditions  >  in our sample  >  in this single case
```

**Rule:** "in our sample" is not "in general"; "is associated with" is not "causes";
"suggests" is not "proves" (`CLAUDE.md`). Do not climb the ladder to sound confident.

---

## Before → after: overclaim to calibrated

| Overclaim | Why it fails | Calibrated |
|---|---|---|
| "Our method **eliminates** PFAS contamination in groundwater." | Causal + total + wrong matrix. Data are >90% removal of short-chain PFAS in bench-scale leachate. | "Electrocoagulation removed >90% of short-chain PFAS in bench-scale leachate (`tab:removal`)." |
| "This **proves** that chain length **drives** removal efficiency." | "proves" + causal, from a correlation. | "Removal efficiency was associated with chain length across the tested congeners (`fig:chain`)." |
| "PFAS exposure **causes** elevated cholesterol." | Causal claim from observational data. | "PFAS exposure was associated with elevated cholesterol in this cohort." |
| "The treatment was **significantly** better, showing a large improvement." | "significant" used to mean "large"; "large" unquantified. | "The treatment improved removal by 18 percentage points (95% CI 11–25; *p* = 0.002)." |
| "Our results are **the first** to show X and **outperform all** prior methods." | Novelty + superiority with no comparison cited. | "We are not aware of prior reports of X for short-chain PFAS; under matched conditions, removal exceeded the sorption baseline of `\cite{smith2021}` by …" |
| "This **clearly demonstrates** the mechanism is electrostatic." | "clearly" is throat-clearing; mechanism not directly observed. | "The pH dependence is consistent with an electrostatic mechanism; direct confirmation would require [method]." |

Pattern: cut the intensifier, drop the verb one rung, bound the scope to what was
tested, and attach the number or the citation that licenses the claim.

---

## Hedge appropriately — neither flat nor mushy

Two failure modes, both wrong:

- **Under-hedged (overclaim):** every result stated flat-out. Reviewer 2 attacks the
  weakest one and the paper bleeds credibility.
- **Over-hedged (mush):** "it may possibly be the case that results could perhaps
  suggest…". Stacked hedges read as evasion and bury the finding.

**Hedge once, at the right rung.** One calibrated verb carries the uncertainty; do not
pile `may` + `suggests` + `possibly` on one clause. Where the evidence *is* strong
(your clean primary result), state it plainly — false modesty is its own miscalibration.

```text
✗ over-hedged:  "These data may possibly suggest that removal could be associated with pH."
✗ under-hedged: "pH determines removal."
✓ calibrated:   "Removal increased with pH across the tested range (fig:ph)."
```

---

## Tense conventions

The default scheme (a `STYLE.md` may override per venue):

| Where | Tense | Why |
|---|---|---|
| Introduction / background | **present** | Established knowledge is timeless: "PFAS are persistent." |
| Prior findings, attributed | present or past | "Smith reports…" (present) or "Smith found…" (past) — pick one and hold it. |
| Methods | **past** | What *was done*: "Samples were collected…". |
| Results | **past** | What the data *showed* on this occasion: "Removal reached 92%." |
| Discussion — your findings | past; **present** for interpretation/implications | "Removal was high (past); this suggests (present) that…". |
| Figure/table captions | present | "Figure 2 shows…". |

Methods and Results in the past tense, intro in the present, is the single most
load-bearing tense rule (`CLAUDE.md → Claim Discipline`). Tense drift inside a section
is an unrelated change — match the surrounding voice.

---

## Active vs passive

Use **active** when the agent matters and naming it adds information ("We collected…",
"The model predicts…"). Use **passive** in Methods where the actor is obvious and the
object is the focus ("Samples were filtered through 0.45 µm membranes") — the standard
register in chemistry and the life sciences. Do not contort prose to avoid "we" if the
venue accepts it; do not over-use passive until every sentence is actor-less fog.
Whatever the manuscript already does, match it.

---

## One term per concept

`CLAUDE.md → Claim Discipline`: do not alternate "removal efficiency" / "elimination
rate" / "uptake" / "reduction" for the same quantity. Synonym-rotation reads as
literary polish but in science it signals *different* quantities and confuses the
reader. Lock the vocabulary in `MANUSCRIPT_MAP.md → Terminology` (or `STYLE.md`), then
use the locked term every time. If two terms are genuinely in play, surface the
conflict and pick one — do not blend.

---

## Reader-first structure

- **Topic sentences.** The first sentence of each paragraph states the paragraph's
  claim. A reader skimming topic sentences should get the argument.
- **Given–new.** Open a sentence with information the reader already has (the *given*);
  end with the new information. This threads paragraphs and makes prose feel inevitable
  rather than listy.
- **One paragraph, one point.** If a paragraph makes two claims, split it.
- **Signposting, sparingly.** "First… second…" and "In contrast" earn their place when
  they track real logical structure; as decoration they are filler.

---

## Cut the AI slop and the throat-clearing

Calibrated academic prose is *terse*. Strip the tics that mark machine-generated or
padded writing:

| Cut | Why | Instead |
|---|---|---|
| "It is important to note that…" / "It is worth mentioning…" | Throat-clearing; says nothing. | State the thing. |
| "In today's world / In recent years, …" | Empty runway. | Open on the claim. |
| "plays a crucial/pivotal/vital role in" | Vague intensifier, no information. | Say *what* it does. |
| "a myriad of", "a plethora of", "delve into", "navigate the landscape of" | LLM register, not scientific register. | "many"; "examine"; plain verbs. |
| "Furthermore, Moreover, Additionally" stacked every paragraph | Mechanical connective tissue. | Connect only where logic connects. |
| "significant" meaning "large/important" | Collides with statistical significance. | Reserve "significant" for statistics; use "substantial/large" + a number otherwise (see `agent_docs/statistics.md`). |
| "robust", "comprehensive", "novel", "cutting-edge", "state-of-the-art" as self-praise | Unfalsifiable boosters; Reviewer 2 deletes them. | Let the result be novel; show it, don't assert it. |
| Triplets for rhythm ("clear, concise, and compelling") | Decorative; one adjective usually suffices. | Pick the one that's true. |
| Restating the question as the answer | Padding to hit a budget. | Cut; budgets are caps, not quotas. |

The unicode-scan hook flags smart quotes / non-ASCII punctuation that creep into LaTeX
source — keep source ASCII (`--`, `---`, `\%`, `\&`) unless the manuscript deliberately
uses unicode.

---

## Concision

Prefer the shorter form when meaning is preserved:
"in order to" → "to"; "due to the fact that" → "because"; "a number of" → "several" or
the actual count; "is able to" → "can"; "utilize" → "use"; "methodology" → "method"
(unless you mean the study *of* methods). Every word should survive the question
"does the section's claim still stand without it?" If yes, cut it.

---

## After any correction

A recurring style note from the author or reviewer ("you keep overclaiming in the
Discussion", "you keep rotating synonyms") is a rule. Log it under `tasks/reviews/`
(`_TEMPLATE.md`), tag `applies_to: [overclaim]` or `[voice]`, promote to `## Top Rules`
if it recurs (`CLAUDE.md → Self-Improvement Loop`).
