# Field Overlay — AI / ML / NLP (with an LLM-agents emphasis)

> A **field overlay**: it *supplements*, not replaces, the general `agent_docs`.
> Read it before discipline-specific writing. It encodes the conventions and
> reviewer expectations of machine-learning venues so the agent does not write
> chemistry-paper prose into a NeurIPS submission.
>
> Activate it in `CLAUDE.project.md → Field overlay`.

---

## Venues & where content goes

| Venue family | Notes |
|---|---|
| **ML:** NeurIPS, ICML, ICLR, AAAI, COLM | ~8–10 pages + unlimited appendix; double-blind; rebuttal phase; reproducibility checklist required |
| **NLP:** ACL, EMNLP, NAACL, COLING | ACL Rolling Review; *Limitations* section is **mandatory** and unnumbered; responsible-NLP checklist |
| **Preprint:** arXiv | Norm to post early; cite the *published* version once it exists |

- **Main paper vs appendix:** core claims, primary results, and the ablation that supports the thesis go in the main paper. Hyperparameter grids, extra seeds, prompts, and proofs go to the appendix.
- **Reproducibility statement / checklist** and (for NLP) a **Limitations** section are not optional — reviewers check for them.

## Structure (often not strict IMRaD)

A typical layout: **Introduction → Related Work → Method → Experiments (setup, results, ablations, analysis) → (Limitations) → Conclusion.** Differences from IMRaD to honor:

- "Method" replaces "Materials and Methods"; describe the model/algorithm precisely enough to reimplement.
- "Experiments" carries setup + results + analysis together; separate *what you measured* from *what it means*.
- Contributions are usually stated as an explicit bulleted list at the end of the Introduction.

## Reproducibility (the bar is high here)

State enough to reproduce — this is the field's defining review criterion:

| Report | Example |
|---|---|
| Random seeds | "results averaged over 5 seeds; seeds listed in App. C" |
| Hyperparameters | full grid + selected values; selection criterion (val set) |
| Compute | hardware, GPU-hours, wall-clock — for fair-comparison and carbon reporting |
| Data | version, splits, preprocessing, license; **how** train/val/test were separated |
| Model | exact checkpoint / API model **and date** (API models drift — pin the version) |
| Decoding (for LLMs) | temperature, top-p, max tokens, stop conditions, prompt templates (verbatim, in App.) |
| Code/data release | repository or "will be released"; tie to `agent_docs/reproducibility.md` |

`data/raw/` is immutable (enforced by `protect-sources.sh`) — derive splits into new files, never edit raw in place.

## Baselines & ablations (reviewers attack these first)

- **Fair comparison:** matched compute / parameter / data budgets. A win under unequal budgets is not a win — state the budgets.
- **Strong baselines:** include the obvious strong method, not just weak ones. A missing obvious baseline is the most common desk-reject reason.
- **Ablations:** remove each component of *your* method to show it carries weight. "We add A, B, C and it's better" is not a result; "A alone gives X, +B gives Y, +C gives Z" is.
- **Variance:** report over multiple seeds/runs with error bars or CIs — never a single run. See `agent_docs/statistics.md`.

## Evaluation hygiene

- **Contamination / leakage:** check that test data (or its sources) did not appear in pretraining or in your tuning. State how you checked. For LLMs, benchmark contamination is a first-order reviewer concern.
- **Held-out discipline:** tune on val, report on test once. No test-set peeking, no selecting the seed that looks best.
- **Human eval (when used):** protocol, number of annotators, inter-annotator agreement (e.g. Cohen's κ), and the rubric belong in the paper.
- **Benchmark saturation:** if a benchmark is near-ceiling, a small gain may be noise — argue significance.

## LLM-agent specifics

- **Vocabulary (lock per `MANUSCRIPT_MAP.md → Terminology`):** agent, tool, *tool call*, trajectory / rollout, episode, step, *task horizon*, policy, scaffold. Pick one term per concept — e.g. **"tool-call accuracy"**, not alternating "success rate" / "correctness".
- **Environment versioning:** agent benchmarks change; pin the environment/harness version and commit hash.
- **Non-determinism:** API models and sampling make runs non-reproducible — report multiple rollouts, temperature, and the model snapshot date.
- **Cost & latency:** report tokens / API cost / wall-clock — agentic methods that "win" by spending 10× compute must say so.
- **Partial credit:** distinguish full task success from partial / sub-goal completion; define the metric precisely.

## Citations & notation

- **Style:** numbered (ACL/IEEE) or author–year (`natbib`) per venue. Cite the **published** version when one exists, not just the arXiv id.
- **Notation:** define every symbol on first use; brace-protect acronyms in BibTeX titles so they survive casing — `{LLM}`, `{API}`, `{RAG}`.
- **Common knowledge** for this audience needs no citation (e.g. "LLMs can produce ungrounded outputs"); calibrate to the *venue's* readership.

## Typical reviewer concerns (pre-empt them)

| Concern | What it looks like | Pre-empt by |
|---|---|---|
| Missing baseline | "why not compare to X?" | include the obvious strong baseline |
| Cherry-picking | only nice qualitative examples | random samples + failure cases |
| No significance | single-run SOTA | multiple seeds + CIs / tests |
| Unfair comparison | more compute/data than baselines | matched budgets, stated |
| Contamination | test seen in pretraining | a stated contamination check |
| Irreproducible | API model, no version | pin model + date + decoding params |
| Overclaim | "general", "SOTA", "solves" | calibrate to the tested settings (`agent_docs/academic-style.md`) |
| No limitations | absent / perfunctory | a genuine Limitations section |

## MANUSCRIPT_MAP.md additions for ML papers

Add to your map's **Claims that need extra care**:
- Generalization beyond the tested benchmarks/harness is out of scope unless shown.
- A correlational ablation does not license a causal claim ("more tools *causes* higher success").
- "SOTA" / "first" / "best" require the comparison that establishes them, under matched budgets.
