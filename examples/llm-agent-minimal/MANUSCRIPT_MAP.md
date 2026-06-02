# MANUSCRIPT_MAP.md

> A *filled* example map (illustrative). This is what the kit reads first.

## Thesis (one sentence)
A deterministic pre-execution verification gate reduces hallucinated tool calls in LLM agents without lowering task completion, which post-hoc self-correction does not reliably achieve.

## Contribution (what is new)
First demonstration (illustrative) of pre-execution gating for agent tool calls in a multi-turn harness, rather than post-hoc correction on single-turn QA.

## Status
- **Stage:** first draft
- **Target journal/venue:** ACL (illustrative) — numbered reference style
- **Format:** LaTeX + BibTeX (natbib, `plainnat`)
- **Main file:** main.tex
- **Bibliography:** references.bib

## Audience
ML / NLP researchers working on LLM agents. Assume familiarity with tool use; establish the multi-turn hallucination problem and the gap.

## Structure (sections & budgets)
| Section | File | Purpose (claim it establishes) | Budget | Status |
|---|---|---|---|---|
| Abstract | inline | whole paper in 200 words | 200 w | draft |
| Introduction | `sections/intro.tex` | gap (multi-turn tool-call hallucination) + why it matters | 800 w | draft |
| Method | `main.tex` | reproducible account of the agent + gate | 1500 w | stub |
| Experiments | — | tool-call accuracy by task horizon | 1200 w | not started |
| Discussion | — | interpretation, scope limits, implications | 1500 w | not started |

## Key sources (the spine)
| `.bib` key | What it establishes | Do NOT overclaim it as |
|---|---|---|
| `tooluse2023` | tool use works on single-turn QA | evidence for multi-turn agents |
| `halluc2022` | hallucination is prevalent in LLMs | a tool-call-specific benchmark |

## Claims that need extra care
- Causal language is NOT licensed by a correlational ablation — use "was associated with", not "causes".
- Do not generalize beyond the tested agent harness to "deployment" or "all agents".

## Terminology (one term per concept)
- Use **"tool-call accuracy"** — not "success rate" / "correctness".
- Use **"task horizon"** — define once (number of steps), then use consistently.
