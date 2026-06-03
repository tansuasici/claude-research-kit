---
name: methods-review
description: Reproducibility check of the Method(s) section against agent_docs/reproducibility.md — enumerate what an independent team needs to rerun the work, check the section, and flag every missing ingredient as a pass/GAP checklist
user-invocable: true
---

# Methods Review

## Core Rule

A Methods section passes only if **a competent stranger, with the paper and the deposited
materials, could regenerate the result.** This skill enumerates every reproduction ingredient,
checks the section against it, and **flags each missing one** — it does not fill the gap by
inventing a value. The honest output for an unstated seed is "GAP — seed not reported", never
a plausible "seed = 42" written into the prose. And **changing what the Methods say was done is
a Protected Claim** (`CLAUDE.md`): it alters the record of the experiment, so this skill
*flags* gaps and proposes what the author must add — it never rewrites the procedure to make it
look more reproducible than it was.

This operationalizes `agent_docs/reproducibility.md`. A vague Methods section is the single
most common reason a reviewer cannot sign off; this catches the omissions before they do.

## When to Use

Invoke with `/methods-review` when:

- A Method(s) / Experimental-setup section is drafted and you want it reproducible before
  review.
- Before submission to a venue with a reproducibility checklist (NeurIPS/ICML/ICLR require
  one; ACL expects a responsible-NLP checklist) — pre-fill it from this output.
- A reviewer asked for "more detail" / "missing hyperparameters" / "no version reported" — run
  this to find *all* such gaps at once, not just the one flagged.
- The prompt-router flagged the task `[Methods]`.

Scope it: `/methods-review sections/method.tex` (include the experimental-setup subsection and
any appendix the Methods defer detail to — "see App. C" is only a pass if App. C exists).

## Process

### Phase 1: Load the Reproducibility Standard

1. **Read `agent_docs/reproducibility.md`** — the reproducible-vs-reported-only distinction,
   the "if changing it would change the result, report it" rule, and the reproducibility
   checklist this skill executes.
2. **Read `agent_docs/field/ai-ml.md`** for ML/agents work — the field's reproduction bar is
   high and specific (seeds, hyperparameter grid + selection criterion, compute, data
   splits/license, exact model checkpoint **and date**, decoding params + verbatim prompts,
   environment/harness version + commit). This is the per-item source for the ML checklist.
3. **Read `MANUSCRIPT_MAP.md → Data & reproducibility`** — what the authors have stated is
   reproducible vs reported-only, and where data/code live. The Methods must match this; a
   conflict is a finding.
4. **Read the target Methods `.tex`** in full, plus the appendix sections it defers to.

### Phase 2: Enumerate Reproduction Requirements

Build the requirement list *before* reading the section for what is present — otherwise you
only check what is there, not what is missing. For an LLM-agent paper, the requirements are:

- **Base model** — exact name, version/checkpoint, and **snapshot date** (closed APIs drift;
  an unpinned model is reported-only, not reproducible).
- **Data** — dataset/benchmark, version, the train/val/test **splits and how they were
  separated**, preprocessing, and **license**.
- **Hyperparameters** — the full grid searched, the selected values, and the **selection
  criterion** (chosen on val, reported on test once).
- **Seeds** — the random seeds, and how many runs/rollouts results are averaged over (a single
  run is not reproducible variance).
- **Compute** — hardware, GPU-hours / wall-clock — needed for fair-budget comparison and cost
  reporting.
- **Decoding parameters** — temperature, top-p, max tokens, stop conditions, and the **prompt
  templates verbatim** (in an appendix).
- **Eval harness** — the agent scaffold (e.g. ReAct loop, max steps), the **tool inventory**,
  the harness/environment **version + commit hash**, and the metric definitions (full vs
  partial task success, how "hallucinated tool call" is operationalized).
- **Code/data availability** — repository or archive, a pinned commit/tag, a **real minted
  DOI** (or `[VALUE — verify]` until the deposit exists — never a placeholder DOI), license,
  and a statement of what reproduces (which figures/tables).
- **Exclusions** — every dropped task/sample named, counted, justified.
- **Reproducible vs reported-only** — stated explicitly where the work mixes the two (e.g.
  offline eval reproducible; results against a proprietary closed-API model reported-only).

Drop or add rows to fit the actual study (a method with no learned component has no
hyperparameter grid) — but justify omissions; do not silently skip a required row.

### Phase 3: Check the Section Against Each Requirement

For every requirement, mark **PASS** (stated with a reproducible value), **PARTIAL** (mentioned
but underspecified — "default settings" is PARTIAL, since defaults drift across versions), or
**GAP** (absent). Quote the locator or note its absence. "Default settings", "a large model",
"standard preprocessing", "an agent loop" are GAP/PARTIAL — they are not reproducible.

When a requirement is genuinely **reported-only** and the section *says so*, that is a PASS for
honesty (it is correctly labeled), even though the result itself cannot be regenerated. Silence
that *implies* reproducibility for a reported-only result is a GAP.

### Phase 4: Report the Checklist and Fixes

Produce the pass/GAP checklist with the fix per item. The fix names what the *author* must add
(a value they hold, a deposit they must make). **Do not invent the missing value** — a seed, a
version, a DOI you write in is a fabrication, exactly the failure the kit forbids. A
`[VALUE — verify]` placeholder is the honest stand-in. Adding/altering procedure detail is a
Protected Claim — propose it, let the author confirm and record in `tasks/decisions.md`.

## Output Format

```markdown
# Methods Review — sections/method.tex (reproducibility)

## Verdict
A competent stranger could NOT currently rerun this work: 4 GAPs (model date, seeds,
decoding params, code availability) block reproduction. 3 PARTIALs need tightening.

## Reproducibility checklist
| Requirement | Status | Locator / note | Fix (author action) |
|---|---|---|---|
| Base model + version + **date** | GAP | "we use a large LLM" — no name/version/date | Name the model + checkpoint + snapshot date; if closed API, label reported-only |
| Data: benchmark + version + splits + license | PARTIAL | benchmark named; splits + license absent | State how train/val/test were separated; add the license |
| Hyperparameters: grid + selected + criterion | PARTIAL | selected τ = 0.7 given; no grid, no criterion | Add the searched grid and "selected on val by X" |
| Seeds + #runs | GAP | single run implied; no seeds | Report seeds and average over ≥3 runs/rollouts with CIs |
| Compute (hardware, GPU-hours / wall-clock) | GAP | not reported | Add hardware + wall-clock (also needed for fair-budget claim) |
| Decoding: temp, top-p, max tokens, **prompts verbatim** | GAP | none stated | Add decoding params; put prompt templates verbatim in an appendix |
| Eval harness: scaffold + tools + version + commit | PARTIAL | "ReAct agent" named; no max-steps, tool list, or commit | Add max steps, tool inventory, harness version + commit hash |
| Metric definitions (full vs partial success; "hallucinated call") | PASS | sec:setup ¶2 defines all three | — |
| Code/data availability + DOI + commit + license | GAP | no statement | Add an availability statement; deposit + pin commit; DOI is `[VALUE — verify]` until minted — do NOT fabricate |
| Exclusions named/counted/justified | PASS | "12 malformed tasks dropped (see App. B)" | — |
| Reproducible vs reported-only stated | GAP | not drawn | State the line: offline eval reproducible; proprietary-model results reported-only |

## Summary
- PASS: 2 · PARTIAL: 3 · GAP: 6

## Priority fixes (block reproduction first)
1. **[GAP]** Model name + version + **date** — without it nothing else reproduces. If closed API, say so and label those results reported-only.
2. **[GAP]** Seeds + multiple runs + CIs — a single run gives no variance (ties to /stats-check).
3. **[GAP]** Decoding params + verbatim prompts — agent behavior is undefined without them.
4. **[GAP]** Code/data availability — add the statement; DOI `[VALUE — verify]`, never a placeholder.

## Notes for the author
- Every "Fix" adds a value YOU hold — I did not invent seeds, versions, or a DOI.
- Adding procedure detail changes what the Methods say was done = Protected Claim. Confirm each addition; record in tasks/decisions.md.
```

End with `(PASS / PARTIAL / GAP)` counts and the single gap that most blocks reproduction.
Never report Methods "reproducible" while a result-affecting ingredient is a GAP.

## Pairs With

- **`agent_docs/reproducibility.md`** — the standard this skill executes (reproducible vs
  reported-only, the availability-statement and FAIR-deposit rules, the master checklist).
- **`agent_docs/field/ai-ml.md`** — the per-item ML/agents reproduction requirements (seeds,
  grid, compute, model date, decoding, harness version) the enumeration draws from.
- **`integrity-reviewer` agent** — escalate when missing methods detail co-occurs with
  overclaim or selective reporting; it scans the whole manuscript for integrity risk, this
  skill verifies the Methods recipe.
- **`/stats-check`** — the seeds/runs/variance GAPs found here feed directly into the
  statistics pass; reproducible variance and reported uncertainty are two views of the same
  requirement.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "We used default settings" | Defaults change across versions and harnesses. "Default" is not reproducible — list the actual values, PARTIAL until you do. |
| "The model is obvious from context" | A closed API drifts; without name + version + date the result is reported-only at best. Pin it. |
| "I'll put seed = 42, that's standard" | If you did not record the seed, writing one in is a fabrication. Flag GAP; report the real seed or label the run reported-only. |
| "Code will be released, that's enough" | "Will be released" without a pinned commit/tag and (eventually) a real DOI is not yet reproducible. State the plan; DOI stays `[VALUE — verify]`. |
| "The prompts are in the text roughly" | "Roughly" is not verbatim. Agent behavior hinges on exact prompts — deposit them verbatim in an appendix. |
| "Reviewers don't need the compute budget" | A method that wins on 10× compute owes the budget for a fair comparison. Report hardware + wall-clock. |

## Notes

- This skill never invents a missing value. A seed/version/DOI you cannot point to is a
  fabrication; the honest output is GAP + `[VALUE — verify]` — per the cardinal rule in
  `CLAUDE.md`.
- Enumerating requirements and judging reproducible-vs-reported-only is Reasoner-tier
  (`CLAUDE.md → Model Selection`).
- `block-fabrication.sh` (PreToolUse) blocks a fake-shaped DOI if you try to write one into an
  availability statement — that is the system working: flag `[VALUE — verify]`, do not
  fabricate.
- A recurring reproducibility gap (reviewer keeps asking for versions or the availability
  statement) is a rule — log under `tasks/reviews/`, `applies_to: [reproducibility, methods]`,
  promote to `## Top Rules` if it recurs (`CLAUDE.md → Self-Improvement Loop`).
