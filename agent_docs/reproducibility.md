# Reproducibility & Data/Code Availability

The expansion of `MANUSCRIPT_MAP.md → Data & reproducibility` and the methods-rigor
lens of the `peer-reviewer` agent. Read this before drafting Methods, a data/code
availability statement, or any task the prompt-router flags as `[Methods]`.

The reproducibility test: **could a competent stranger, with your paper and your
deposited materials, regenerate your result?** Methods are written to pass that test —
not to summarize what you did, but to *enable repetition*. What cannot be repeated must
be labeled "reported only," not dressed up as reproducible.

---

## Reproducible vs reported-only — name which

State this plainly in `MANUSCRIPT_MAP.md → Data & reproducibility` and, where the venue
expects it, in the manuscript. Conflating the two is a quiet overclaim.

| | Definition | Obligation |
|---|---|---|
| **Reproducible** | Inputs (data) + procedure (code/protocol) are available; a third party can rerun and get the same result. | Deposit data + code; pin versions; document the run. |
| **Replicable** | An independent team, new data, same method, reaches a consistent conclusion. | Methods detailed enough to re-run from scratch. |
| **Reported-only** | A number/result the reader must take on trust (proprietary data, one-off field campaign, destructive assay). | **Say so.** Do not imply it can be regenerated when it cannot. |

If part of the work is reproducible and part reported-only, the availability statement
draws the line. "Computational results are reproducible from the deposited code; the
field measurements are reported only (samples consumed)" is honest; silence implies more
than the evidence supports.

---

## Methods written for reproduction

A Methods section is a recipe a stranger can follow. Vague methods are the most common
reason a reviewer cannot sign off. Specify, with exact values:

| Category | Specify | Vague (bad) → Reproducible (good) |
|---|---|---|
| **Quantities** | masses, volumes, concentrations, ratios, durations, temperatures | "a small amount of coagulant" → "0.50 g L⁻¹ Al³⁺ as AlCl₃·6H₂O" |
| **Instruments** | make, model, configuration | "measured by LC-MS" → "Agilent 1290 / 6470 LC-MS/MS, ESI−, MRM" |
| **Materials** | supplier, grade, CAS, lot where it matters | "PFOA standard" → "PFOA (Sigma-Aldrich, ≥95%, CAS 335-67-1)" |
| **Software** | name **and version**, key parameters, random seed | "analyzed in Python" → "Python 3.11, scipy 1.11.3; seed = 42" |
| **Settings** | every non-default parameter that affects the result | "default settings" → list them; "default" is not reproducible across versions |
| **Procedure** | order of operations, controls, replication (n), blanks | "samples were analyzed in triplicate (n = 3 analytical replicates)" |

The rule of thumb: **if changing it would change the result, report it.** Field-specific
reporting (LOD/LOQ, QA/QC, blanks, recovery) lives in
`agent_docs/field/<discipline>.md` — read it before discipline-specific methods.

Changing what the Methods *say was done* is a **Protected Claim** (`CLAUDE.md`) — it
alters the record of the experiment. Confirm with the author; record in
`tasks/decisions.md`.

---

## Raw data is immutable

`data/raw/` (and `sources/`, `submitted/`, `*.frozen.*`) are protected by
`protect-sources.sh` — edits are blocked unless `RESEARCH_APPROVED=1`. This is not
bureaucracy: if raw data can be edited in place, every downstream number is
unverifiable.

- **Never edit `data/raw/`.** Cleaning, transforming, excluding outliers → write to a
  *new* path (`data/processed/`, `data/derived/`) with a script that takes raw as input.
- The pipeline `raw → script → processed → result` must be re-runnable. The script is
  the record of every transformation; "I cleaned it in a spreadsheet" is not
  reproducible.
- **Document exclusions.** Any dropped sample/point is named, counted, and justified in
  Methods (ties to `agent_docs/statistics.md` — undisclosed exclusion is p-hacking).

---

## Data & code availability statements

Most venues now require one. State *what*, *where*, and *under what access*:

```text
Data availability — The processed datasets supporting this study are openly available
at <repository> under DOI <10.xxxxx/...> [a REAL minted DOI — never fabricate it;
leave [VALUE — verify] until the deposit exists]. Raw LC-MS files are available from
the corresponding author on reasonable request owing to file size.

Code availability — Analysis code is archived at <Zenodo/OSF DOI> and mirrored at
<github.com/...> (commit <hash>). It reproduces all figures and Tables 1–3 from the
deposited processed data.
```

Discipline:

- The deposit **DOI is a real, minted identifier** off the repository — subject to the
  same no-fabrication rule as any citation (`agent_docs/citation-discipline.md`;
  `block-fabrication.sh` blocks fake-shaped DOIs). If the deposit does not exist yet,
  write `[VALUE — verify]` / `[CITE]`, not a placeholder DOI.
- **"Available on request"** is the weakest form; prefer a public, versioned, DOI-bearing
  archive. If access is restricted, state the *reason* (privacy, size, third-party
  licence) — not as a default dodge.
- Pin a **commit hash or release tag** so "the code" means a specific, frozen state.

---

## Pre-registration

Where the design supports it (trials, prospective studies, confirmatory analyses),
pre-registration separates confirmatory from exploratory claims and is the strongest
defense against HARKing (`agent_docs/statistics.md`).

- If the study **was** pre-registered: cite the registration (OSF / ClinicalTrials.gov /
  AsPredicted ID), and **flag any deviation** from the registered plan in Methods. A
  silent deviation is worse than no registration.
- Analyses **not** in the registration are **exploratory** — label them as such; the
  honest verb is "suggests."
- The kit does not invent a registration ID any more than a DOI — if you do not have it,
  flag it.

---

## FAIR data

Aim for deposits that are **F**indable, **A**ccessible, **I**nteroperable, **R**eusable:

- **Findable** — a persistent identifier (DOI) and rich metadata.
- **Accessible** — retrievable by the identifier over a standard protocol; access
  conditions stated even when restricted.
- **Interoperable** — open, non-proprietary formats (CSV/NetCDF over a vendor binary)
  with documented variables and units.
- **Reusable** — a clear licence (CC-BY, CC0), provenance, and a data dictionary so the
  columns mean something to a stranger.

A spreadsheet with cryptic column names and no units is technically "available" and
practically unusable. Reusable means a stranger can *understand* it.

---

## Reporting standards (use the field's checklist)

Many fields have a community reporting standard; following one is the cheapest way to
not miss a required element, and reviewers expect it. Examples (use the one that fits;
check `agent_docs/field/<discipline>.md`):

| Standard | For |
|---|---|
| **PRISMA** | systematic reviews & meta-analyses (flow diagram + checklist) |
| **CONSORT** | randomized controlled trials |
| **STROBE** | observational epidemiology (cohort/case-control/cross-sectional) |
| **ARRIVE** | animal research |
| **MIAME / MINSEQE** | microarray / sequencing data |
| **TOP guidelines** | journal-level transparency & openness |

These are *checklists*, not prose generators — they tell you what must be present, not
what to claim. Run the relevant one before submission; a missing item is a reviewer
comment you can pre-empt.

---

## Reproducibility checklist

Before Methods / a results pipeline / submission is "done":

- [ ] Methods specify every result-affecting **quantity, instrument, material, version, setting** — a stranger could re-run.
- [ ] **Software versions** (and random seed) pinned; non-default parameters listed.
- [ ] `data/raw/` **untouched**; all transforms in a re-runnable script (`raw → processed → result`).
- [ ] Every **exclusion** named, counted, justified.
- [ ] **Reproducible vs reported-only** stated explicitly; no implied reproducibility.
- [ ] **Data + code availability** statements present; deposit **DOIs real** (or `[VALUE — verify]` until minted), commit/tag pinned.
- [ ] Deposit is **FAIR** — persistent ID, open format, licence, data dictionary with units.
- [ ] **Pre-registration** cited and deviations flagged (if applicable); exploratory analyses labeled.
- [ ] Relevant **reporting standard** (PRISMA/CONSORT/…) checklist completed.
- [ ] Figures/tables regenerable from deposited data + code.

A recurring reproducibility gap (reviewer keeps asking for versions, or for the
availability statement) is a rule — log under `tasks/reviews/`,
`applies_to: [reproducibility, methods]`, promote to `## Top Rules` if it recurs
(`CLAUDE.md → Self-Improvement Loop`).
