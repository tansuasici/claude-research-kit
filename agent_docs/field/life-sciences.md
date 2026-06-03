# Field Overlay — Life Sciences / Biology (wet-lab, omics, animal & observational)

> A **field overlay**: it *supplements*, not replaces, the general `agent_docs`.
> Read it before discipline-specific writing. It encodes the conventions and
> reviewer expectations of life-science venues so the agent does not write
> ML-paper prose into a *Cell* submission, and does not skip the reporting
> standard a journal will desk-check.
>
> Activate it in `CLAUDE.project.md → Field overlay`.

---

## Venues & where content goes

| Venue family | Notes |
|---|---|
| **General high-impact:** *Nature*, *Science*, *Cell* | strict length caps; main text carries the narrative, methods often condensed with an expanded "Online Methods"; extended-data + supplementary figures expected |
| **Open / community:** *PLOS Biology*, *eLife*, *PLOS ONE*, *Nature Communications* | open access; *eLife* publishes the reviews; *PLOS ONE* judges rigor, not novelty; data-availability statement **mandatory** |
| **Society / subfield:** *J. Cell Biol.*, *EMBO J.*, *Genome Biol.*, *J. Immunol.* | discipline-specific reporting norms; many run automated image-integrity screening |
| **Preprint:** bioRxiv / medRxiv | norm to post; cite the *published* version once it exists |

- **Main text vs supplement:** the figures that carry the thesis and the key controls go in the main text. Replicate panels, full blots/gels, gating strategies, extended dose–response, and exhaustive tables go to supplementary / extended data — but the **uncropped originals** of every blot must be available.
- A **data-availability statement** and (for the relevant study type) the **reporting-standard checklist** are not optional — editors check for them before review.

## Structure (IMRaD, with field specifics)

A typical layout: **Introduction → Results → Discussion → Methods (often last/online) → References.** Differences to honor:

- **Results before Methods** is common; Methods may be a condensed main-text block plus a fuller "Online/Extended Methods." Write Methods to *enable repetition*, not to summarize (`agent_docs/reproducibility.md`).
- **Results and Discussion are usually separate.** Keep *what you observed* (Results, past tense) apart from *what it means* (Discussion, present tense for interpretation) — see `agent_docs/academic-style.md` tense table.
- **Figures carry the argument.** Each figure makes one point; the legend defines n, the statistical test, what the error bars are, and the scale bar. A claim in the text points to the panel that supports it.

## Reporting standards (match the study type)

Editors expect the right checklist; a missing item is a pre-emptable reviewer comment (`agent_docs/reproducibility.md`).

| Standard | For |
|---|---|
| **ARRIVE 2.0** | in-vivo animal experiments (study design, sample size, randomization, blinding, welfare) |
| **STROBE** | observational human studies (cohort / case-control / cross-sectional) |
| **PRISMA** | systematic reviews & meta-analyses (flow diagram + checklist) |
| **MIAME** | microarray data (the minimum information to interpret/reproduce an array experiment) |
| **MINSEQE** | high-throughput sequencing data (RNA-seq / ChIP-seq minimum information) |
| **MIQE** | quantitative PCR (qPCR) experiments |

These are *checklists*, not prose generators — they tell you what must be present, not what to claim. Run the relevant one before submission.

## Ethics & approvals (state them — reviewers and editors require it)

- **Human subjects:** an **IRB / research-ethics-committee** approval (with protocol number) and a statement that **informed consent** was obtained. Identifiable data requires consent for publication.
- **Animal work:** **IACUC** (or national equivalent, e.g. Home Office / AWERB) approval, the approved protocol number, and adherence to ARRIVE. State species, strain, sex, age/weight, housing, and humane endpoints.
- **Ethics statement placement:** a dedicated Methods subsection ("Ethics statement") naming the approving body and protocol ID. The kit does not invent an approval number — if you do not have it, write `[VALUE — verify]`, never a plausible-looking ID (`CLAUDE.md → Source-Grounded Writing`).

## Wet-lab reproducibility (the field's defining rigor bar)

State enough that a competent stranger could repeat the experiment (`agent_docs/reproducibility.md`):

| Report | Why / example |
|---|---|
| **Reagents with RRIDs** | antibodies, cell lines, model organisms, plasmids, key software cited by **Research Resource Identifier** (e.g. `RRID:AB_xxxxxx`) so the exact reagent is unambiguous |
| **Antibody validation** | clone, host, catalog + lot, dilution, and the validation (KO/knockdown control, or vendor validation) — "anti-X antibody" alone is not reproducible |
| **Cell-line authentication** | STR-profile authentication and **mycoplasma testing**; note passage number and source. Misidentified/contaminated lines are a known retraction cause |
| **n = biological vs technical replicates** | state which. *Biological* replicates (independent samples/animals/cultures) support inference; *technical* replicates (re-measures of one sample) quantify measurement noise, **not** biological variability. Reviewers ask this first |
| **Blinding & randomization** | for animal and many cell experiments: were group allocation and outcome assessment blinded? Were animals randomized? State it (ARRIVE requires it) |
| **Sample size justification** | a priori power analysis or a stated rationale; pre-specified inclusion/exclusion criteria |

`data/raw/` is immutable (enforced by `protect-sources.sh`) — derive processed tables into new files, never edit raw instrument output in place.

## Statistics (see `agent_docs/statistics.md`)

- **Appropriate test for the data.** Match the test to design and distribution: t-test/ANOVA for approximately normal data, Mann–Whitney / Kruskal–Wallis for non-normal, paired tests for paired designs. Name the test in the legend; do not default to a t-test on skewed counts.
- **Multiple comparisons:** correct (Tukey, Holm, Benjamini–Hochberg FDR) when running a family of tests. **Omics is the extreme case** — thousands of genes/features demand FDR control; report *adjusted* p / q-values, not raw p.
- **Define the error bars.** SD, SEM, or 95% CI — and *which* in every legend. SEM is not SD; reporting SEM because it is smaller is misleading. Report effect size + uncertainty, not just "p < 0.05."
- **n is the number of independent units**, stated per comparison. Pseudoreplication (treating technical replicates or cells-from-one-animal as independent n) inflates significance — a classic reviewer catch.
- **Show the data, not just bars.** For small n, prefer dot/scatter plots over bar charts that hide the distribution; reviewers increasingly require individual data points overlaid. A bar with an error whisker over n = 3 conceals more than it shows.
- **Pre-specify exclusions.** Outlier removal and inclusion criteria are stated before unblinding and documented in Methods; undisclosed exclusion is p-hacking (`agent_docs/statistics.md`).

## Figure integrity (a real journal/reviewer concern — do not gloss it)

Journals run automated image-forensics screening; violations trigger correction or retraction.

- **No inappropriate image manipulation.** Adjustments (brightness/contrast) must be linear and applied to the *whole* image, disclosed in the legend. **Never** splice lanes/bands, clone-stamp, erase, or selectively enhance a feature.
- **Disclose splicing.** If non-adjacent gel lanes are shown together, a dividing line and a note are mandatory; provide the uncropped original.
- **Quantify blots from raw, unsaturated images**, not from the figure JPEG; state how densitometry was normalized (loading control).
- The kit writes *about* figures; it does not fabricate a panel, a band, or a representative image that was not produced (`CLAUDE.md → Source-Grounded Writing`). A "representative" image must be genuinely representative of the quantified n.

## Calibration in this field (overclaim → calibrated)

The verb/scope ladder of `agent_docs/academic-style.md`, applied to biology:

| Overclaim | Why it fails | Calibrated |
|---|---|---|
| "Knockdown of *GENEX* **causes** apoptosis." | causal from a single perturbation, off-target not excluded | "*GENEX* knockdown increased apoptosis (rescued by re-expression), consistent with a requirement for *GENEX*." |
| "This pathway **drives** tumor growth **in patients**." | in-vitro/mouse result extrapolated to humans | "In this xenograft model, pathway inhibition reduced tumor volume (`fig:x`); the clinical relevance is untested." |
| "The drug **is effective** against the disease." | unbounded; cell-line data only | "Compound X reduced viability in three cell lines (IC50 in `tab:y`); efficacy in vivo was not assessed." |

Pattern: bound the claim to the model system, attach the control that licenses it, and drop the verb to what the design supports.

## Data availability (deposit + accession)

Most venues require deposition in a community repository *before* acceptance, with the accession in the paper:

| Data type | Repository / accession |
|---|---|
| Microarray / functional genomics | **GEO** (`GSExxxxx`) or ArrayExpress |
| Raw sequencing reads | **SRA** / ENA (`SRPxxxxxx` / `PRJNAxxxxxx`) |
| Mass-spec proteomics | **PRIDE** / ProteomeXchange (`PXDxxxxxx`) |
| Macromolecular structures | **PDB** (`xxxx`); EMDB for cryo-EM maps |
| Processed data / general | Zenodo / Dryad / Figshare with a minted **DOI** |

The accession **is a real identifier** off the deposit — subject to the no-fabrication rule (`block-fabrication.sh` blocks fake-shaped DOIs). If the deposit does not exist yet, write `[VALUE — verify]`, never an invented `GSE`/`PXD`/DOI.

## Citations, terminology & nomenclature

- **Cite the primary source**, not a review, for a specific experimental claim; reserve reviews for background and synthesis. A mechanistic assertion traces to the paper that showed it (`CLAUDE.md → Source-Grounded Writing`).
- **Style:** numbered (Vancouver, common in *Cell*/*Nature*) or author–year per venue. Cite the **published** version when one exists, not just the bioRxiv id.
- **Lock vocabulary per `MANUSCRIPT_MAP.md → Terminology`.** One term per concept — do not alternate "knockdown" / "silencing" / "depletion" for the same intervention if they imply different mechanisms (RNAi vs CRISPRi vs degron).
- **Gene/protein conventions:** human genes italic uppercase (*TP53*), protein roman (TP53/p53); mouse genes italic initial-cap (*Trp53*). Follow the organism's nomenclature authority (HGNC, MGI). Define non-obvious gene symbols on first use.
- **Species names** italic, genus capitalized, binomial spelled out at first use then abbreviated (*Drosophila melanogaster* → *D. melanogaster*).
- **Common knowledge** for this audience needs no citation (e.g. "DNA is transcribed to RNA"); calibrate to the venue's readership.
- **Units & symbols** per `agent_docs/statistics.md`; brace-protect acronyms/gene symbols in BibTeX titles so casing survives — `{DNA}`, `{CRISPR}`, `{TP53}`.

## Typical reviewer concerns (pre-empt them)

| Concern | What it looks like | Pre-empt by |
|---|---|---|
| Pseudoreplication | n = wells/cells from one experiment | report biological n; define replicate type |
| Missing controls | no vehicle / isotype / KO control | include and show the relevant control |
| Antibody/cell-line rigor | unvalidated antibody; unauthenticated line | RRIDs, validation, STR + mycoplasma |
| Underpowered | small n, no justification | power analysis or stated rationale |
| No multiple-comparison correction | many tests, raw p | FDR/Holm; report adjusted values |
| Undefined error bars | "± error" unlabeled | state SD/SEM/CI in every legend |
| Image manipulation | spliced/over-processed blot | linear whole-image adjustment, disclosed, originals available |
| No data deposit | "data available on request" | GEO/SRA/PRIDE accession or DOI |
| Overclaim | "proves", causal claim from correlation | calibrate to the design (`agent_docs/academic-style.md`) |

## MANUSCRIPT_MAP.md additions for life-science papers

Add to your map's **Claims that need extra care**:
- An in-vitro / cell-line result does not license an in-vivo or clinical claim — state the model and its limits.
- A correlation across samples (expression vs phenotype) does not license a causal/mechanistic claim without a perturbation experiment.
- A "representative" image must reflect the full quantified n, not the best field of view.
- Generalization beyond the tested species/strain/cell line/condition is out of scope unless shown.

Add to **Data & reproducibility**: the reporting standard in force (ARRIVE / STROBE / PRISMA / MIAME / MINSEQE), ethics-approval IDs (or `[VALUE — verify]`), replicate definition (biological vs technical) and n, and the deposition target with accession (or `[VALUE — verify]` until minted).
