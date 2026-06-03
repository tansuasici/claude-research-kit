# Field Overlay — Clinical / Medical Research

> A **field overlay**: it *supplements*, not replaces, the general `agent_docs`.
> Read it before discipline-specific writing. It encodes the conventions and
> reviewer expectations of clinical journals so the agent does not write
> basic-science prose into an *NEJM* submission, applies the right reporting
> guideline, and never overstates a benefit a trial does not support.
>
> Activate it in `CLAUDE.project.md → Field overlay`.

---

## Venues & where content goes

| Venue family | Notes |
|---|---|
| **Top general medical:** *NEJM*, *The Lancet*, *JAMA*, *BMJ* | strict word/figure caps; structured abstract; ICMJE rules; trial registration + reporting-guideline compliance enforced at submission |
| **Specialty:** *Circulation*, *J. Clin. Oncol.*, *Annals of Internal Medicine*, *Diabetes Care* | same standards; field-specific outcome conventions |
| **Methods/evidence:** *Cochrane*, *J. Clin. Epidemiol.* | systematic-review and methodology home; PRISMA central |
| **Preprint:** medRxiv | posting accepted by most journals; cite the *published* version once it exists |

- **Main text vs supplement:** the primary outcome analysis, the CONSORT/STROBE flow, and the key safety data go in the main text; the full protocol, statistical analysis plan (SAP), additional subgroups, and detailed adverse-event tables go to the supplementary appendix.
- **Mandatory at submission:** the **reporting-guideline checklist**, the **trial-registration number**, an **ethics/IRB statement**, and **conflict-of-interest + funding disclosures**. Editors desk-check these.

## Reporting guidelines (match the study type — EQUATOR network)

The single cheapest way to not miss a required element; journals require the completed checklist (`agent_docs/reproducibility.md`).

| Guideline | For |
|---|---|
| **CONSORT** | randomized controlled trials (+ extensions: cluster, non-inferiority, pilot) |
| **STROBE** | observational studies (cohort, case-control, cross-sectional) |
| **PRISMA 2020** | systematic reviews & meta-analyses (flow diagram + checklist) |
| **STARD** | diagnostic-accuracy studies |
| **SPIRIT** | clinical-trial **protocols** |
| **TRIPOD** | prediction-model development/validation |
| **CARE** | case reports |

These are *checklists*, not prose generators. Run the relevant one before submission; a missing item is a reviewer comment you can pre-empt.

## Structure (IMRaD + structured abstract)

A typical layout: **structured abstract → Introduction → Methods → Results → Discussion**.

- **Structured abstract:** Background, Methods, Results, Conclusions (journal-specific headings); the primary outcome with its effect estimate and CI appears here and **must match the body** (verification step 4, `CLAUDE.md`).
- **Methods** name the design, registration, setting, eligibility, intervention/exposure, the **prespecified primary outcome**, sample-size calculation, randomization/blinding, and the analysis plan (ITT). Written to enable appraisal and repetition (`agent_docs/reproducibility.md`).
- **Discussion** opens with the principal findings, then comparison with prior evidence, limitations, and a **calibrated** clinical implication — not a recommendation the data do not support.

## Trial registration (prospective — a hard gate)

ICMJE journals will not publish an unregistered trial.

- Register on **ClinicalTrials.gov**, ISRCTN, or a WHO-ICTRP primary registry **before enrolling the first participant** (prospective registration). State the registration number and date in the abstract and Methods.
- The **registered primary outcome is binding.** Report it as the primary outcome; any change from the registered/protocol outcome must be disclosed and justified. Switching the primary outcome to a "significant" secondary one is outcome-switching — a documented integrity problem reviewers and watchdogs check.
- The kit does not invent an NCT/ISRCTN number or registration date — `[VALUE — verify]` if unknown, never a plausible-looking ID (`CLAUDE.md → Source-Grounded Writing`).

## Ethics (state it explicitly)

- **IRB / research-ethics-committee approval** with the approving body and protocol number.
- **Informed consent** obtained (and the process for vulnerable populations / waivers).
- Conducted per the **Declaration of Helsinki** (and ICH-GCP for trials) — state it.
- The ethics statement is a dedicated Methods subsection; approval IDs follow the no-fabrication rule.

## Effect measures (report clinically, not just p)

A p-value is not a result; clinicians need the size and precision of the effect (`agent_docs/statistics.md`).

| Report | Why |
|---|---|
| **Absolute *and* relative effect** | a "50% relative risk reduction" can be a 2%→1% absolute change. Report **absolute risk reduction (ARR)** alongside **relative risk / RR / odds ratio / hazard ratio** — relative-only framing overstates benefit |
| **NNT / NNH** | number-needed-to-treat / -to-harm makes the absolute effect interpretable at the bedside |
| **Confidence intervals** | the 95% CI on every estimate — not just p. The CI carries magnitude and precision |
| **ITT vs per-protocol** | **intention-to-treat** is the primary analysis for superiority RCTs (preserves randomization); per-protocol is secondary/supportive. Name which analysis each number comes from; for non-inferiority, report both |
| **Time-to-event** | hazard ratios with CIs + Kaplan–Meier; state the proportional-hazards assumption |

Do not report a relative risk reduction without its absolute counterpart, and do not call a result "significant" as a synonym for "large" (`agent_docs/academic-style.md`).

## Bias & internal validity

- **Randomization & allocation concealment:** describe the sequence generation *and* that allocation was concealed (concealment ≠ blinding) — inadequate concealment exaggerates effects.
- **Blinding:** who was blinded (participants, clinicians, outcome assessors, analysts); if open-label, how outcome assessment was protected.
- **Attrition & missing data:** report dropout by arm and how missing data were handled (e.g. multiple imputation); differential attrition threatens validity.
- **CONSORT flow diagram:** enrollment → allocation → follow-up → analysis, with numbers and reasons for loss at each stage. Mandatory for RCTs; the numbers must reconcile with the text (verification step 4, `CLAUDE.md`).
- For observational designs, address confounding (adjustment, matching, sensitivity analyses) — and do not let adjustment masquerade as causal proof.
- **Subgroups are prespecified or exploratory.** A treatment effect in a subgroup is interpretable only if the subgroup was prespecified and tested with an interaction term; a post-hoc subgroup "win" is hypothesis-generating, not confirmatory (`agent_docs/statistics.md`). State how many subgroups were examined.
- **Multiplicity:** with multiple endpoints or interim analyses, report the alpha-spending or correction; do not present the one endpoint that crossed significance as if it stood alone.

## Calibration in this field (overclaim → calibrated)

The verb/scope ladder of `agent_docs/academic-style.md`, applied to clinical writing:

| Overclaim | Why it fails | Calibrated |
|---|---|---|
| "Drug A **reduces mortality by 50%**." | relative-only; no absolute, no CI, no population | "Drug A reduced all-cause mortality from 8.0% to 4.2% over 12 months (ARR 3.8%, 95% CI 1.9–5.7; HR 0.52, 95% CI 0.38–0.71; NNT 26)." |
| "The treatment **is safe and effective**." | unbounded safety claim from a finite trial | "In this trial, the primary efficacy outcome favored treatment (above); serious adverse events occurred in 4.1% vs 3.8% (no significant difference at this sample size)." |
| "A secondary endpoint **proves** benefit on quality of life." | "proves" from a secondary/exploratory outcome | "An exploratory secondary outcome suggested a quality-of-life benefit (`tab:x`); this is hypothesis-generating and requires confirmation." |

Pattern: pair relative with absolute effects and CIs, scope to the trial population/outcome, and never call a secondary or subgroup result confirmatory.

## Conflicts of interest, funding & data privacy

- **COI + funding disclosure:** all financial and non-financial conflicts and the funding source, with the funder's role in design/analysis/reporting (ICMJE form). Required, not optional.
- **Patient-data privacy:** de-identify; no identifying details/images without explicit consent for publication; comply with HIPAA/GDPR as applicable. Individual-participant-data sharing per a stated plan (ICMJE data-sharing statement).
- Trial data/SAP deposit where required; the deposit/registration identifiers are **real** — `[VALUE — verify]` until they exist (`block-fabrication.sh`).

## Evidence hierarchy & terminology

- **Calibrate the claim to the design.** Ascending strength: case report < case series < cross-sectional < case-control < cohort < RCT < systematic review/meta-analysis of RCTs. A single observational study does not license a treatment recommendation.
- **One term per concept** (`MANUSCRIPT_MAP.md → Terminology`): do not alternate "adverse event" / "side effect" / "complication" if they are defined differently; fix "efficacy" (ideal conditions) vs "effectiveness" (real-world) and hold it.
- **Units & symbols** per `agent_docs/statistics.md`; brace-protect acronyms in BibTeX titles — `{RCT}`, `{COVID-19}`, `{HbA1c}`.
- **Citation style:** Vancouver/ICMJE numbered references is the norm; cite the **published** trial report and its **registration**, and cite primary trials rather than reviews for a specific efficacy claim (`CLAUDE.md → Source-Grounded Writing`).
- **Common knowledge** for a clinical readership needs no citation; calibrate to the journal's audience.
- **Outcome definitions** are stated and held constant — a composite endpoint lists its components, and "response" / "remission" carry their prespecified thresholds, used identically throughout.

## Typical reviewer concerns (pre-empt them)

| Concern | What it looks like | Pre-empt by |
|---|---|---|
| Not registered / outcome-switched | no NCT; primary outcome differs from registry | prospective registration; report the registered primary outcome, disclose changes |
| Relative-only effect | "50% reduction" without absolutes | report ARR + RR/HR with CIs; NNT |
| Bare p-values | "p < 0.05", no estimate | effect estimate + 95% CI for every comparison |
| Inadequate blinding/concealment | allocation/assessment unprotected | describe sequence generation, concealment, blinding |
| Attrition bias | unexplained dropout | CONSORT flow; dropout by arm; missing-data method |
| ITT not used | analysis excludes non-adherers | ITT as primary; per-protocol supportive |
| Underpowered / no SAP | no sample-size calc | a-priori power calculation; prespecified analysis plan |
| Undisclosed COI/funding | absent disclosure | full COI + funding + funder role |
| Causal overreach | observational study → "treatment X works" | associational language; recommendation matched to evidence level |
| Overclaim | "proves safe and effective" | calibrate to the trial's population/outcomes (`agent_docs/academic-style.md`) |

## MANUSCRIPT_MAP.md additions for medical papers

Add to your map's **Claims that need extra care**:
- A statistically significant secondary or subgroup outcome is hypothesis-generating, not confirmatory — do not promote it to the headline finding.
- A relative effect without its absolute counterpart (and CI) overstates clinical benefit.
- Efficacy in a trial population does not establish effectiveness or safety in routine care or untested populations — scope the claim.
- An observational association does not license a causal or treatment-recommendation claim regardless of adjustment.

Add to **Data & reproducibility**: the reporting guideline in force (CONSORT / STROBE / PRISMA / STARD / SPIRIT), the trial-registration number and date (or `[VALUE — verify]`), the prespecified primary outcome and analysis (ITT), IRB approval + consent + Declaration of Helsinki, COI/funding disclosures, and the data-sharing statement.
