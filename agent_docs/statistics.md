# Statistics & Numerical Reporting

The expansion of `CLAUDE.md → Source-Grounded Writing` ("**Never invent a quantity**")
and the verification step "**Numbers are consistent**". Read this before any task the
prompt-router flags as `[Statistics]` or `[Causation]`.

A number in a manuscript is a claim. It comes from a source or the author's own data —
never from your prior. If you do not have it, write `[VALUE — verify]`
(`agent_docs/citation-discipline.md`); do not guess. Beyond honesty about *where*
numbers come from, this doc is about reporting them *correctly*.

---

## Report effect size + uncertainty, not just p

A p-value alone is almost never an adequate result. It answers "could this arise by
chance under the null?" — not "how big is the effect?" or "how sure are we?". Always
pair the estimate with its uncertainty.

```text
✗  "The treatment was significant (p < 0.05)."
✗  "Removal was higher in group B (p = 0.03)."
✓  "Removal was 18 percentage points higher in group B (95% CI 11–25 pp; p = 0.003, two-sample t-test, n = 24)."
```

The reportable triplet for any comparison: **point estimate · uncertainty interval ·
test (with N)**. The confidence interval carries the information a bare p-value hides —
the *magnitude* and *precision* of the effect. Where the CI crosses the null but the
point estimate is meaningful, say so; do not bury an imprecise estimate behind "n.s."

---

## "Significant" means statistically significant — only

This is the single most abused word in scientific writing and it collides with
calibrated language (`agent_docs/academic-style.md`).

- **"significant"** = the test rejected the null at the stated α. Nothing about
  importance or magnitude.
- For *large* / *important* / *meaningful*, use those words **plus a number** — never
  "significant" as a synonym.

```text
✗  "a significant improvement in removal"   (significant = large? or p < α? reader can't tell)
✓  "a 22-percentage-point improvement in removal (p = 0.001)"
✓  "a small but statistically significant difference (1.3 pp, 95% CI 0.4–2.2; p = 0.01)"
```

A statistically significant effect can be trivially small; a large effect can be
non-significant in a small sample. Report both dimensions and let the reader judge.

---

## State N, the test, and the assumptions

Every inferential statistic needs its scaffolding stated, or it is unverifiable:

- **N** — the sample size *for that specific comparison* (not the study total).
  Report it; verification step 4 (`CLAUDE.md`) checks that N is reported.
- **The test** — name it ("two-sample t-test", "Mann–Whitney U", "linear regression",
  "one-way ANOVA with Tukey HSD"). A number with no named test cannot be reproduced.
- **The assumptions** — and whether they hold. A t-test assumes approximate normality
  and (often) equal variance; Pearson r assumes linearity; OLS assumes the usual Gauss–
  Markov conditions. If the data violate them, say what you did (transform, switch to a
  rank/robust method) — do not report the parametric result silently.

If you are *writing up* numbers the author computed, do not invent the test or the
assumptions — ask which test was run. The methods description of an analysis is a
**Protected Claim** (`CLAUDE.md`): changing what test was reported changes what was done.

---

## Multiple comparisons

Running many tests inflates the false-positive rate: at α = 0.05, twenty independent
tests yield ~1 "significant" result by chance alone.

- If the analysis runs a family of tests, **report the correction** (Bonferroni,
  Holm, Benjamini–Hochberg FDR) or justify why none is needed.
- State **how many comparisons** were run, including the ones that were not
  significant. Reporting only the winners is selective reporting.
- A "significant" subgroup found after slicing the data many ways is a hypothesis to
  test on new data, not a finding.

---

## No p-hacking, no HARKing

These are integrity failures the kit will not help you commit, and that Reviewer 2
looks for:

- **p-hacking** — trying analyses, exclusions, or endpoints until *p* < α, then
  reporting only that path. Report the analysis you pre-specified; disclose deviations
  and exploratory analyses *as* exploratory.
- **HARKing** (Hypothesizing After Results are Known) — presenting a post-hoc finding
  as if it were the a-priori hypothesis. An exploratory result is labeled exploratory,
  full stop.
- **Optional stopping** — peeking and stopping data collection when significant.
  Pre-specify N or use a sequential design with the right correction.

When a result is exploratory, the honest verb is "suggests" / "is consistent with"
(`agent_docs/academic-style.md`), and the Discussion calls for confirmation. Do not
launder an exploratory finding into a confirmatory claim.

---

## Association vs causation

Observational evidence rarely licenses a causal claim (`prompt-router → [Causation]`).
Default to **associational** language unless the design earns causation.

| Design | Causal claim licensed? |
|---|---|
| Randomized controlled trial | Yes (within its population/conditions). |
| Natural experiment / valid instrument / RDD / well-specified diff-in-diff | Conditionally — state the identifying assumption. |
| Cross-sectional / cohort / correlational | **No.** "associated with", "predicts", "correlates with" — not "causes", "drives", "leads to", "the effect of". |

State the assumption explicitly. "X causes Y" from a correlation is the canonical
overclaim a reviewer flags first.

---

## Significant digits & units

- Report **only the digits the measurement supports.** "94.732%" from an instrument
  good to ±1% is false precision — write "95%" (or "94.7 ± 1.0%").
- Match precision to the **uncertainty**: the last reported digit should be the first
  uncertain one. A CI of (11.3, 24.8) does not justify reporting the point estimate as
  18.42157.
- **Units, always**, with a space before the unit (SI) and consistent throughout
  (`MANUSCRIPT_MAP.md → Terminology` and `agent_docs/field/<discipline>.md` for field
  conventions — e.g. ng/L for trace environmental concentrations).
- **Percentage point** ≠ **percent.** A rise from 70% to 88% is 18 *percentage points*
  (~26% *relative* increase). Pick the one you mean and say which.
- Define every symbol/abbreviation once; one term per concept.

---

## Reproducible numbers (text ↔ tables ↔ abstract)

The same quantity must read the same everywhere it appears — abstract, text, tables,
figures, and the response letter. This is verification step 4 (`CLAUDE.md`) and a
classic silent failure: the abstract says 92%, the results table says 89%, and the
reader cannot tell which is real.

- Every number in the **abstract** must match its source in the **body**.
- Every number in the **text** must match the **table/figure** it summarizes.
- **Totals add up**; percentages of a stated denominator are consistent; N is the same
  number everywhere it is cited.
- Derived numbers (a difference, a ratio, a percent change) recompute correctly from
  the reported inputs.

This is deterministic work — recompute and cross-check, do not eyeball
(`CLAUDE.md → Model vs Code`). If a number changes, it changes *everywhere at once*;
a changed reported quantity is a **Protected Claim** requiring author approval.

---

## Reporting checklist

Before a Results or Methods section with statistics is "done":

- [ ] Every comparison reports **effect size + uncertainty (CI)**, not just p.
- [ ] **"significant"** used only for statistical significance; magnitude given separately with a number.
- [ ] **N** stated for each comparison; **test named**; **assumptions** addressed.
- [ ] **Multiple comparisons** corrected or justified; all tests run are disclosed.
- [ ] No undisclosed p-hacking / HARKing; exploratory results labeled exploratory.
- [ ] Causal language only where the **design** licenses it; else associational.
- [ ] **Significant digits** match the measurement's precision; **units** present and consistent.
- [ ] **Percentage vs percentage points** correct.
- [ ] Every number **matches across** abstract, text, tables, figures (recomputed, not eyeballed).
- [ ] Any number not from a source or the author's data is `[VALUE — verify]`, and the gap count is reported.

A recurring statistics slip (the author keeps correcting "significant", or bare
p-values) is a rule — log it under `tasks/reviews/`, `applies_to: [statistics]`,
promote to `## Top Rules` if it recurs (`CLAUDE.md → Self-Improvement Loop`).
