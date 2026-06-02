# Field Overlay — Environmental Science & Chemistry

A **field overlay**: it *supplements* the general agent_docs, it does not replace them.
The cardinal rule (`CLAUDE.md → Source-Grounded Writing`), calibrated language
(`agent_docs/academic-style.md`), statistics (`agent_docs/statistics.md`), and
reproducibility (`agent_docs/reproducibility.md`) all still apply. This doc adds the
conventions, nomenclature, and reviewer expectations specific to environmental
chemistry — with PFAS as the running example.

Read this (per `CLAUDE.md → Session Boot` Tier 3) before discipline-specific writing.
If `STYLE.md` / `CLAUDE.project.md` set venue rules, they override this overlay.

---

## Venue & style cues (ACS / ES&T)

The center of gravity is the ACS family — *Environmental Science & Technology* (ES&T),
*ES&T Letters*, *Environmental Science: Processes & Impacts*, *Water Research*,
*Chemosphere*, *Journal of Hazardous Materials*.

- **Reference style:** ACS (numeric, cited as superscript or italic in-text numbers,
  numbered in citation order). BibTeX with `achemso` / a CSL ACS style — convert with
  the processor, never by hand (`CLAUDE.md → Model vs Code`).
- **Structure:** IMRaD, plus an **Abstract** and a graphical **TOC abstract** (a small
  figure + ~2-sentence synopsis). ES&T expects an **"Environmental Implications"**
  paragraph (often closing the Discussion) — why the finding matters for real
  environmental systems, not just the bench.
- **Supporting Information (SI):** extended methods, QA/QC tables, calibration data,
  raw chromatograms go to the SI; the main text carries the argument. The SI is part of
  the record — its numbers obey the same no-fabrication and consistency rules.
- **Length:** ES&T articles run ~6000–7000 words with a handful of display items; check
  the specific journal and put the cap in `MANUSCRIPT_MAP.md → Structure` budgets.

---

## Chemical nomenclature

Precision in naming is a sourcing issue: the wrong name is the wrong compound.

- **IUPAC names** for novel/uncommon compounds at first mention; the common acronym
  thereafter (one term per concept). Define every acronym on first use.
- **PFAS naming** (the running example):
  - **PFAS** = per- and polyfluoroalkyl substances (the class). Not "PFAs", not
    "PFCs" (deprecated).
  - Individual: **PFOA** (perfluorooctanoic acid, C8 carboxylate, CAS 335-67-1),
    **PFOS** (perfluorooctane**sulfonic** acid / sulfonate, C8, CAS 1763-23-1),
    **PFBA/PFBS** (C4), **PFHxA/PFHxS** (C6), **GenX** (HFPO-DA). Carboxylates
    (**PFCAs**) and sulfonates (**PFSAs**) are distinct families — do not conflate.
  - **"Short-chain" vs "long-chain"** has a specific, contested boundary — **define it
    once** (e.g. short-chain PFCAs ≤ C7 / PFSAs ≤ C5, per Buck et al.) and hold it
    (`MANUSCRIPT_MAP.md → Terminology`). Do not let the draft drift the cutoff.
  - Acid vs conjugate base matters at environmental pH (PFOA vs perfluorooctanoate);
    be consistent and correct.
- **Formulae & units:** subscripts/superscripts in proper math/chem markup
  (`\ce{}` from `mhchem`, or the venue's macro); isotopes and charges correct.

A misassigned CAS number, an invented compound name, or a wrong acronym expansion is a
fabrication in the same sense as a fake DOI — do not guess; verify against the source or
flag it.

---

## Reporting environmental measurements

Trace environmental analysis has its own reporting contract. These elements are what a
reviewer scans for first; missing ones are near-automatic comments.

- **Units & magnitude.** Trace aqueous concentrations in **ng/L** (sometimes ng/L ↔
  ppt — state which; avoid bare "ppt"); solids in **ng/g dry weight** (state dry vs wet
  — a major error source). Space before the unit; consistent throughout
  (`agent_docs/statistics.md`).
- **LOD / LOQ.** Report the **limit of detection** and **limit of quantification**, how
  they were derived (e.g. S/N = 3 and 10, or from low-level replicate SD), and **how
  non-detects were handled** (reported as `<LOQ`, substituted, or modeled — never
  silently set to zero, which biases means).
- **Blanks.** Field, method, and instrument **blanks** — PFAS especially are
  ubiquitous lab contaminants (PTFE, LC tubing). Report blank levels and any
  blank-subtraction or blank-based detection threshold. "No detectable contamination in
  blanks" is itself a reportable result.
- **Recovery & surrogates.** **Isotopically labeled internal standards** (e.g.
  ¹³C-PFOA) and **surrogate recoveries** (report the % range); matrix spike recoveries
  for each matrix. Quantification by isotope dilution where possible.
- **Replication.** Distinguish **analytical replicates** (same sample, re-injected)
  from **field/experimental replicates** (independent samples) — they support different
  inferences (`agent_docs/statistics.md`). Report n for each.
- **Instrumentation.** LC-MS/MS make/model, ionization mode (ESI−), MRM transitions
  (quantifier + qualifier), column, mobile phase, calibration range and r². These live
  in Methods/SI for reproduction (`agent_docs/reproducibility.md`).

---

## QA/QC expectations

QA/QC is the credibility spine of an environmental-chemistry paper. State, at minimum:

| Element | What to report |
|---|---|
| Calibration | range, levels, r² (or weighted fit), check standards |
| Blanks | field / method / instrument blank levels; subtraction rule |
| Recovery | surrogate/internal-standard recovery (% ± SD), matrix spikes per matrix |
| Precision | replicate RSD |
| Accuracy | reference material / proficiency sample if available |
| Detection | LOD, LOQ, derivation, non-detect handling |
| Carryover | solvent blanks after high standards (PFAS persist on the system) |

These map onto the reproducibility checklist (`agent_docs/reproducibility.md`); the
overlay just names the field-specific items. Put the QA/QC table in the SI and
reference it from Methods.

---

## Typical reviewer concerns in this field

Pre-empt these — they are the recurring Major/Minor issues an ES&T referee raises
(run the `peer-reviewer` sub-agent with these in mind):

- **Matrix effects.** A method validated in ultrapure or freshwater is *not* validated
  in leachate, wastewater, serum, or soil — matrix suppression/enhancement in ESI−,
  competing ions, DOC. The canonical overclaim is generalizing a freshwater result to a
  complex matrix (this is exactly the `MANUSCRIPT_MAP.md → Key sources` "do NOT
  overclaim as" trap). Calibrate the claim to the **tested matrix**.
- **Generalizability across matrices.** "Removes PFAS from water" from one leachate at
  bench scale is **bench-scale, one matrix** — say so. Transfer to field scale, other
  waters, or full scale is untested unless you tested it.
- **Environmental relevance.** Were tested concentrations environmentally realistic
  (ng/L–µg/L) or spiked orders of magnitude high for analytical convenience? A reviewer
  asks whether the result holds at real-world levels. State it.
- **Transformation products & mass balance.** For treatment/degradation work: did the
  parent disappear, or transform into shorter-chain (often more mobile) products? A PFAS
  removal claim without a **fluorine/defluorination mass balance** invites the question
  "removed, or just transformed?" Address it.
- **Speciation & bioavailability.** Total concentration ≠ bioavailable/free fraction;
  pH, sorption, and partitioning govern fate. Do not claim effects the speciation does
  not support.
- **Causation vs association in field data.** Observational field correlations
  (concentration vs distance from a source, vs a health endpoint) rarely license causal
  language (`agent_docs/statistics.md` → association vs causation). Default to
  associational.
- **Persistence/regulatory framing.** Be precise about regulatory thresholds (e.g. an
  EPA MCL, an advisory level) — cite the actual instrument; do not paraphrase a limit
  from memory. A regulatory number is a sourced quantity, not common knowledge.

---

## MANUSCRIPT_MAP.md additions for this field

When filling `MANUSCRIPT_MAP.md` for an environmental-chemistry paper, make these
field-specific entries explicit so the agent does not drift:

- **Terminology:** lock the analyte set and the short/long-chain cutoff; pick one of
  "removal efficiency" vs "removal" vs "elimination" and hold it.
- **Key sources → do NOT overclaim as:** flag every freshwater/clean-matrix reference so
  it is never cited as evidence for a complex matrix.
- **Claims that need extra care:** matrix transfer, scale transfer, parent-vs-products,
  and any causal reading of field correlations — list them as protected.
- **Data & reproducibility:** instrument + method, LOD/LOQ, QA/QC location (SI), and the
  data/code availability deposit (real DOI or `[VALUE — verify]`).

---

## After any correction

A recurring field-specific critique (a reviewer keeps flagging matrix
overgeneralization, missing blanks, or a transformation-products gap) is a rule — log it
under `tasks/reviews/`, tag `applies_to: [overclaim, methods, scope]`, and promote to
`## Top Rules` if it recurs (`CLAUDE.md → Self-Improvement Loop`). The next PFAS paper
should not re-earn the same comment.
