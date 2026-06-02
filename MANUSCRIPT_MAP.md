# MANUSCRIPT_MAP.md

> The single most important file in the kit. Claude reads this first, every session.
> The more precise it is, the less the agent drifts, overclaims, or invents.
> Replace every `<...>` placeholder. Delete sections that do not apply.

---

## Thesis (one sentence)
<The single claim this manuscript exists to defend. If you cannot state it in one
sentence, the paper is not ready to draft. e.g. "Electrocoagulation removes
short-chain PFAS from landfill leachate at >90% efficiency, which existing
sorption methods do not achieve.">

## Contribution (what is new)
<What does the reader know after this paper that they did not before? Be specific.
Distinguish your contribution from prior work explicitly.>

## Status
- **Stage:** <idea / outline / first draft / revision / responding-to-reviewers / camera-ready>
- **Target journal/venue:** <e.g. Environmental Science & Technology — ACS reference style, ~7000 words, 6 display items>
- **Format:** LaTeX + BibTeX (`biber`/`bibtex`)
- **Main file:** <main.tex>
- **Bibliography:** <references.bib>
- **Deadline:** <date or "none">

## Audience
<Who reads this venue? What can you assume they know (skip it) vs. what must you
establish (cite it)? A specialist methods audience ≠ a broad-readership journal.>

---

## Structure (sections & budgets)
<The section plan. Word budgets keep sections from sprawling. Update as you draft.>

| Section | File | Purpose (claim it establishes) | Budget | Status |
|---|---|---|---|---|
| Abstract | `sections/abstract.tex` | <the whole paper in 200 words> | 200 w | <not started> |
| Introduction | `sections/intro.tex` | <gap + why it matters + what we do> | 800 w | <not started> |
| Methods | `sections/methods.tex` | <reproducible account of what was done> | 1500 w | <not started> |
| Results | `sections/results.tex` | <what the data show, no interpretation> | 1200 w | <not started> |
| Discussion | `sections/discussion.tex` | <interpretation, limits, implications> | 1500 w | <not started> |
| Conclusion | `sections/conclusion.tex` | <contribution restated, future work> | 300 w | <not started> |

## Key sources (the spine of the argument)
<The handful of references the paper stands on. Claude must never confuse these or
misattribute their claims. Cite keys must match references.bib exactly.>

| `.bib` key | What it establishes | Do NOT overclaim it as |
|---|---|---|
| `<smith2021>` | <method baseline, 70% removal in freshwater> | <evidence for leachate — different matrix> |
| `<jones2019>` | <regulatory limit context> | <a removal-efficiency benchmark> |

## Figures & tables (display items)
| ID | File | Shows | Referenced in |
|---|---|---|---|
| `fig:setup` | `figures/setup.pdf` | <experimental schematic> | Methods |
| `tab:removal` | inline | <removal efficiency by chain length> | Results |

---

## Data & reproducibility
- **Data location:** <path / repository / DOI>
- **Analysis code:** <path / repo>
- **What is reproducible vs. reported-only:** <state plainly>
- **Availability statement:** <where data/code will be deposited>

## Claims that need extra care (do not soften, do not inflate)
<Sentences a reviewer will attack. List them so the agent treats them as protected.>
- <Causal language is NOT licensed here — association only.>
- <Generalization beyond the tested matrix is out of scope.>

## Terminology (one term per concept)
<Lock the vocabulary so the draft does not alternate synonyms.>
- Use **"removal efficiency"** — not "elimination", "uptake", "reduction".
- Use **"short-chain PFAS"** — define once (C4–C7), then use consistently.

## Co-authors & roles
<Who owns which section / who must approve which claims.>

## Not Now (parked, off-thesis)
<Interesting but out of scope. Keep it here so it stays out of the draft.>
