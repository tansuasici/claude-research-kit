# MANUSCRIPT_MAP.md

> A *filled* example map (illustrative). This is what the kit reads first.

## Thesis (one sentence)
Electrocoagulation removes short-chain PFAS from landfill leachate at high efficiency, which existing sorption methods do not reliably achieve.

## Contribution (what is new)
First demonstration (illustrative) of electrocoagulation applied to the short-chain (C4–C7) fraction in a real leachate matrix, rather than spiked freshwater.

## Status
- **Stage:** first draft
- **Target journal/venue:** Environmental Science & Technology (illustrative) — ACS reference style, numbered citations
- **Format:** LaTeX + BibTeX (natbib, `plainnat`)
- **Main file:** main.tex
- **Bibliography:** references.bib

## Audience
Environmental-chemistry specialists. Assume PFAS background; establish the leachate-matrix challenge and the short-chain gap.

## Structure (sections & budgets)
| Section | File | Purpose (claim it establishes) | Budget | Status |
|---|---|---|---|---|
| Abstract | inline | whole paper in 200 words | 200 w | draft |
| Introduction | `sections/intro.tex` | gap (short-chain + real matrix) + why it matters | 800 w | draft |
| Methods | `main.tex` | reproducible account of the EC protocol | 1500 w | stub |
| Results | — | removal efficiency by chain length | 1200 w | not started |
| Discussion | — | interpretation, matrix limits, implications | 1500 w | not started |

## Key sources (the spine)
| `.bib` key | What it establishes | Do NOT overclaim it as |
|---|---|---|
| `example2020` | sorption under-performs on short-chain | evidence for electrocoagulation |
| `example2019` | tightening regulatory limits | a removal benchmark |

## Claims that need extra care
- Causal language is NOT licensed by batch data — use "removed" for observed, not "causes removal of".
- Do not generalize beyond the tested leachate matrix.

## Terminology (one term per concept)
- Use **"removal efficiency"** — not "uptake" / "elimination".
- Use **"short-chain PFAS"** — define once as C4–C7, then use consistently.
