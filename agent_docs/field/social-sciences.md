# Field Overlay — Social Sciences (psychology, sociology, econ-adjacent)

> A **field overlay**: it *supplements*, not replaces, the general `agent_docs`.
> Read it before discipline-specific writing. It encodes the conventions and
> reviewer expectations of social-science venues so the agent does not write
> lab-science prose into a psychology submission, and respects APA style, the
> confirmatory/exploratory line, and the field's measurement standards.
>
> Activate it in `CLAUDE.project.md → Field overlay`.

---

## Venues & where content goes

| Venue family | Notes |
|---|---|
| **Psychology:** *Psychological Science*, *JPSP*, *Psychological Bulletin*, *JEP* | APA 7 style; many offer **Registered Reports**; open-science badges (preregistration, open data/materials) common |
| **Sociology:** *American Sociological Review*, *American Journal of Sociology*, *Social Forces* | ASA style (close to APA author–date); methods transparency for both quant and qual |
| **Econ-adjacent / quant policy:** *AEJ*, field journals; *PNAS* for interdisciplinary | identification strategy is the centerpiece; data + code deposit increasingly required |
| **Preprint / registry:** **OSF**, PsyArXiv, SSRN, AsPredicted | norm to preregister and post; cite the *published* version once it exists |

- **Main text vs supplement / OSM:** the confirmatory analyses that test the preregistered hypotheses go in the main text; robustness checks, full item wording, additional models, and exploratory analyses go to Online Supplementary Materials — clearly labeled.
- A **data-availability / open-practices statement** and, where applicable, the **preregistration link** are expected; reviewers check for them.

## Structure (APA-style IMRaD)

A typical layout: **Introduction → Method → Results → Discussion**, with a structured Method.

- **Method subsections:** Participants (and recruitment/eligibility), Materials/Measures, Procedure, Design, and an analysis plan. Enough detail to replicate (`agent_docs/reproducibility.md`).
- **Confirmatory vs exploratory is a structural divide**, not a footnote. If the study was preregistered, the Results report the registered tests first, *as* confirmatory; everything else is labeled exploratory in its own subsection.
- **Results past tense; Discussion present for interpretation** (`agent_docs/academic-style.md`). Keep observed effects apart from their interpretation and from limits on generalization.

## APA 7 style (the house style for much of the field)

- **In-text citation:** author–date — `(Smith & Jones, 2020)` or "Smith and Jones (2020) found…"; three+ authors use "et al." from first cite. Lock `natbib`/`apacite` or a CSL APA-7 style; do not hand-format (`CLAUDE.md → Model vs Code`).
- **Reference list:** hanging indent, alphabetical, DOIs as URLs. A CSL processor produces this — the model does not retype references.
- **Numbers & stats:** italic test statistics (*t*, *F*, *r*, *p*), report *df*; numbers below 10 spelled out in prose except with units/stats.
- **Bias-free language (APA ch. 5):** person-first or identity-first per community preference; specific, respectful descriptors for age, disability, gender, race/ethnicity, sexual orientation; avoid "subjects" for humans (use "participants"). This is a substantive APA requirement, not optional polish — but it never changes a reported finding (a **Protected Claim** if the meaning shifts, `CLAUDE.md`).

## Preregistration & the replication crisis

The field's central methodological reform; reviewers are primed for it.

- **Preregister the hypotheses, design, and analysis plan** (OSF / AsPredicted) before data collection. If preregistered, cite the registration and **flag every deviation** in Method — a silent deviation is worse than none (`agent_docs/reproducibility.md`).
- **Confirmatory ≠ exploratory.** A preregistered prediction tested as planned is confirmatory; anything decided after seeing data is exploratory and labeled so. The honest verb for exploratory results is "suggests" / "is consistent with."
- **No HARKing** (Hypothesizing After Results are Known) — do not present a post-hoc finding as an a-priori hypothesis (`agent_docs/statistics.md`).
- **Registered Reports** (peer-reviewed *before* data collection, in-principle acceptance) are the strongest format against publication bias — note if the manuscript is one.

## Construct validity & measurement

A finding is only as good as its operationalization — the heart of social-science rigor.

- **Operationalization:** state how each abstract construct (e.g. "implicit prejudice", "social capital", "wellbeing") was measured, and cite the validated instrument. A construct is not its label.
- **Reliability:** report internal consistency (**Cronbach's α** or McDonald's ω) for multi-item scales; test–retest where relevant. State the value and the scale it applies to — "α = .82 for the 6-item anxiety scale," not a bare "reliable."
- **Validity:** address content, convergent/discriminant, and criterion validity where the claim depends on it. A high α does not establish that the scale measures the intended construct.
- **Measurement invariance** when comparing groups — a scale must function equivalently across groups before mean differences are interpretable.

## Study design

- **Sampling:** describe the population, recruitment, eligibility, and the sampling frame; characterize the sample (and its limits — convenience/online panels constrain generalization). State who was excluded and why.
- **Power analysis:** an a-priori power analysis justifying N for the target effect size (e.g. via G*Power), stated with the assumed effect, α, and power. Underpowered designs are a leading reviewer objection.
- **IRB / ethics & consent:** approval (with protocol number) and informed consent stated; for deception or vulnerable populations, the safeguards. The kit does not invent an approval ID — `[VALUE — verify]` if unknown (`CLAUDE.md → Source-Grounded Writing`).
- **Attrition & manipulation checks:** report dropout and exclusions by condition; for experiments, report the manipulation check that shows the intervention did what it claimed. Differential attrition across conditions undermines randomization.

## Qualitative methods (held to their own rigor standard)

Qualitative work is not "soft" — it has explicit quality criteria reviewers apply.

- **Coding & analysis:** name the approach (thematic analysis, grounded theory, IPA, framework analysis) and describe how codes were developed (inductive/deductive) and applied.
- **Inter-rater reliability** for coded categorical data: **Cohen's κ** (two coders) or Fleiss' κ / Krippendorff's α (more), reported with the value; or, for interpretive traditions, describe consensus-coding instead — and say which.
- **Reflexivity:** state the researcher's position and how it may shape interpretation; this is expected, not optional, in much qualitative reporting.
- **Saturation:** justify sample size by data/thematic saturation rather than power.
- **Trustworthiness** (Lincoln & Guba): credibility, transferability, dependability, confirmability — the qualitative analogues of validity/reliability; address the ones the claims rest on. Use an audit trail and member checking where appropriate.

## Statistics (see `agent_docs/statistics.md`)

- **Effect sizes always**, with confidence intervals — Cohen's *d*, *r*, η², odds ratios — not bare significance. APA expects effect sizes reported alongside tests.
- **CIs over bare p.** Report the estimate and its interval; "*p* < .05" alone hides magnitude and precision. The reportable triplet: estimate · CI · test (with N).
- **No p-hacking:** disclose all measured variables, conditions, and exclusions; report the analysis you preregistered and label deviations. Correct for multiple comparisons or justify why not.
- **Causal-inference caution:** observational / cross-sectional / correlational data **do not** license "causes", "leads to", "the effect of." Default to "is associated with", "predicts", "is related to." Causal language requires a design that earns it (experiment, valid instrument, RDD, well-specified diff-in-diff) — and the identifying assumption stated (`agent_docs/statistics.md`).
- **Mediation/moderation:** a mediation model on cross-sectional data tests a causal pathway it cannot establish; report it as the conditional association it is, and note that temporal precedence is unobserved.
- **Model specification:** state covariates and why; do not present the one specification that reached significance out of many (`agent_docs/statistics.md` — disclose the specification curve or the robustness set).

## Citations & notation

- **Style:** APA-7 author–date via `apacite`/CSL; cite the **published** version, not a working paper, once one exists. A theoretical construct's origin is cited to its source, not to a textbook restatement (`CLAUDE.md → Source-Grounded Writing`).
- **Common knowledge** for the subfield needs no citation; a specific empirical estimate (an effect size, a prevalence) always does.
- Brace-protect acronyms in BibTeX titles so casing survives — `{IRT}`, `{SEM}`, `{COVID-19}`.

## Calibration in this field (overclaim → calibrated)

The verb/scope ladder of `agent_docs/academic-style.md`, applied to social science:

| Overclaim | Why it fails | Calibrated |
|---|---|---|
| "Social-media use **causes** depression in adolescents." | causal from cross-sectional survey data | "Greater self-reported social-media use was associated with higher depression scores (*r* = .21, 95% CI [.14, .28]); the design does not establish direction." |
| "The intervention **works** to reduce prejudice." | unbounded; one sample, one outcome | "The intervention reduced scores on the explicit-bias measure (*d* = 0.34, 95% CI [0.12, 0.56]) in this student sample; effects on behavior were not tested." |
| "These results **prove** the theory." | "prove" from a single confirmatory study | "These results are consistent with the theory's prediction (preregistered); replication in a more diverse sample is needed." |

Pattern: scope to the sample, report effect size + CI, and use associational verbs unless the design earns causation.

## Data & code sharing

- Deposit de-identified data and analysis code on **OSF** / a DOI-bearing archive (Zenodo, Dryad); cite full materials (stimuli, survey instruments, code) so the study is reproducible. Open-data/open-materials badges follow.
- **Human-data privacy:** de-identify before sharing; restricted access for sensitive data with the reason stated, not as a default dodge. The deposit **DOI is real** — `[VALUE — verify]` until minted, never fabricated (`block-fabrication.sh`).

## Typical reviewer concerns (pre-empt them)

| Concern | What it looks like | Pre-empt by |
|---|---|---|
| Underpowered | small N, no power analysis | a-priori power analysis with assumptions stated |
| Causal overreach | "X causes Y" from survey data | associational language; design-justified causal claims only |
| HARKing / p-hacking | post-hoc framed as a priori; only "significant" results | preregistration; confirmatory/exploratory split; disclose all DVs |
| Weak measurement | unvalidated scale, no reliability | cite validated instrument; report α/ω and validity |
| Bare p-values | "p < .05", no effect size | effect size + CI for every test |
| Generalization | claims beyond a convenience sample | scope to the sampled population; state limits |
| Qual rigor unstated | themes with no method/IRR/reflexivity | name approach, report κ or consensus, reflexivity, saturation |
| No open practices | no data/materials/preregistration | OSF deposit + preregistration link |
| APA/bias-language | "subjects"; non-inclusive descriptors | participants; bias-free language (APA ch. 5) |

## MANUSCRIPT_MAP.md additions for social-science papers

Add to your map's **Claims that need extra care**:
- Observational/correlational findings are associational unless the design licenses causation — state the identifying assumption.
- A reliable scale (high α) is not necessarily a valid measure of the named construct — keep reliability and validity claims separate.
- Results from a convenience/online sample do not generalize to the broader population unless shown.
- An exploratory result is labeled exploratory; it does not become confirmatory because it was predicted post hoc.

Add to **Data & reproducibility**: preregistration ID/link (or `[VALUE — verify]`) and whether it is a Registered Report, IRB approval and consent statement, the validated instruments with reliability, and the OSF/DOI deposit for de-identified data + materials + code.
