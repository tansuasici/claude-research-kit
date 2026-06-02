---
name: citation-audit
description: Deep manual bibliography health check — dangling \cite keys, orphan .bib entries, duplicates, malformed/placeholder DOIs, missing required fields, inconsistent author/journal formatting, and \ref↔\label integrity
user-invocable: true
---

# Citation Audit

## Core Rule

The bibliography is deterministic infrastructure: a `\cite` either resolves or it does not; a DOI is either well-formed or it is not. Per `CLAUDE.md → Model vs Code`, do not eyeball what a parser can decide. This skill is the **deeper manual audit** that complements the live hook — it catches the structural problems the gate does not (orphans, duplicates, malformed metadata, formatting drift) and reasons about fixes.

For the live `\cite`↔`.bib` and `\ref`↔`\label` check, the **`citation-gate.sh`** hook already runs after every `.tex`/`.bib` edit and writes its verdict to `.hook-state/last_quality_gate.json`. Tell the user to rely on that hook for continuous coverage; run `/citation-audit` for a thorough sweep before submission or when inheriting a messy `.bib`.

**Never fix a dangling key by inventing a reference.** A `\cite{key}` with no entry is resolved either by supplying *verified* metadata or by flagging `[CITE]` in the prose and removing the dead key — never by writing a plausible stub. `block-fabrication.sh` will block the stub anyway.

## When to Use

Invoke with `/citation-audit` when:

- Preparing to submit — a clean bibliography is a Reviewer 2 freebie you should not give away.
- You merged a co-author's `.bib` and suspect duplicates or format drift.
- The `citation-gate` verdict shows dangling keys and you want the full structural picture, not just the first 25.
- Switching reference styles (ACS ↔ IEEE ↔ APA) and need to audit field completeness first.

## Process

### Phase 1: Inventory

Locate the manuscript root (nearest ancestor with a `.bib`, `main.tex`, or `MANUSCRIPT_MAP.md`) and inventory:

1. **All `.bib` files** — there may be more than one; the gate scans all of them.
2. **All `.tex`/`.ltx` files** — the sources of `\cite` and `\ref`.
3. **Reference style in force** — from `MANUSCRIPT_MAP.md → Target journal` (ACS / IEEE / APA / Nature). This sets which fields are required and the expected author/journal format.

Strip TeX comments before counting: a commented-out `% \cite{foo}` is not a real citation. (The gate does this; match its behaviour.)

### Phase 2: Resolution Integrity (\cite ↔ .bib)

The same check the hook runs, surfaced in full:

1. **Defined keys** — parse `@type{key,` from every `.bib` (skip `@string`/`@comment`/`@preamble`).
2. **Cited keys** — parse the full `\cite` family from every `.tex`: `\cite \citep \citet \citeauthor \autocite \textcite \parencite \footcite` and friends, including multi-key braces `{a,b,c}` and optional `[..]` arguments.
3. **Dangling cites** — cited but not defined → **ERROR**. Each is a fabrication risk: resolve with verified metadata or flag `[CITE]` and remove the key. Do NOT invent the entry.
4. **Orphan entries** — defined but never cited → **WARNING**. Dead weight; remove unless deliberately retained (e.g. a `\nocite{*}` data-availability list — note the exception).

### Phase 3: Duplicate Detection

Duplicates produce double-counted references and inconsistent keys:

1. **Same key twice** — a hard `.bib` error; biber/bibtex picks one silently. **ERROR**.
2. **Same work, different keys** — match on DOI, then on (normalized title + year + first author). Two keys for one paper means the manuscript cites it inconsistently. **WARNING** — merge to one key and update all `\cite` sites.
3. **Near-duplicate titles** — preprint vs published version of the same work. Flag for the author to pick the citeable version.

### Phase 4: DOI and Identifier Validity

1. **Placeholder / fake-shaped DOIs** — `10.xxxx`, `10.0000`, `10.nnnn`, `example.com`, `your-doi`, `TODO` → **ERROR**. (`block-fabrication.sh` blocks these on write; catch any that predate the hook.) Flag, never "complete" them.
2. **Malformed DOIs** — must match `10.<registrant>/<suffix>`. A DOI that is not shaped like one is suspect.
3. **arXiv / ISSN shape** — sanity-check format. Do not assert a DOI "resolves" unless you verified it against a real source — shape validity is not existence.

### Phase 5: Required-Field Completeness (per entry type)

Each `@type` has required fields; a missing one is a malformed reference. Check against the style in force:

| Entry type | Required (BibTeX core) |
|---|---|
| `@article` | author, title, journal, year, (volume) |
| `@book` | author/editor, title, publisher, year |
| `@incollection` | author, title, booktitle, publisher, year |
| `@inproceedings` | author, title, booktitle, year |
| `@phdthesis` | author, title, school, year |
| `@techreport` | author, title, institution, year |
| `@misc` | title + (howpublished/url/year) for datasets, software, preprints |

An **empty** required field (`author = {}`) is a stub masquerading as real → **ERROR** (the hook blocks writing these). A **missing** required field → **WARNING**. Supply the value only from the actual source.

### Phase 6: Formatting Consistency

Drift here is what a copy-editor (and Reviewer 2) flags:

1. **Author name format** — one convention throughout (`Last, First` vs `First Last`; initials with/without periods; `and` separators). List the outliers.
2. **Journal names** — full vs abbreviated, consistently. ACS/IEEE expect ISO-4 abbreviations; APA/Nature expect full titles. Match the style.
3. **Title case** — sentence case vs title case per style; brace-protection on proper nouns/acronyms (`{LLM}`, `{API}`) so they aren't down-cased.
4. **Page ranges** — `--` en-dash, consistent.
5. **Capitalization protection** — model names, acronyms, proper nouns wrapped in `{}`.

Do not silently rewrite all of these — reference style conversion is a deterministic job for a CSL processor / `biber` (`CLAUDE.md → Model vs Code`). Report the inconsistencies and the rule; mechanical reformat belongs in tooling, not hand-retyping that injects errors.

### Phase 7: Cross-Reference Integrity (\ref ↔ \label)

1. **Dangling refs** — `\ref \eqref \autoref \cref \Cref \pageref \nameref` keys with no matching `\label` → **ERROR**.
2. **Orphan labels** — `\label` never referenced → **WARNING** (often harmless, but flag stale ones).
3. **Display-item coverage** — every figure/table is referenced in the text and vice versa (cross-check `MANUSCRIPT_MAP.md → Figures & tables`). An unreferenced figure or a "see Fig 3" with no Fig 3 is a defect.

## Output Format

```markdown
# Citation Audit — references.bib (+ 1 other .bib), 6 .tex files

> Live check: citation-gate.sh (runs on every .tex/.bib edit). This is the deep manual sweep.
> Reference style in force: ACL (numbered, ISO-4 abbreviations, sentence-case titles).

## ERRORS (block submission)
| Category | Item | Fix |
|---|---|---|
| Dangling \cite | `smith2022` cited in results.tex:88, not in any .bib | Supply verified entry OR flag [CITE] and remove key — do not invent |
| Duplicate key | `halluc2022` defined twice in references.bib | Merge; keep the complete entry |
| Placeholder DOI | `kumar2020`: doi = {10.xxxx/abcd} | Replace with real DOI from source, or drop the field |
| Empty field | `lee2018`: author = {} | Fill author from source or remove entry |
| Dangling \ref | `\ref{fig:horizon}` in discussion.tex:40, no \label | Add \label or fix the reference |

## WARNINGS (fix before submission)
| Category | Item | Fix |
|---|---|---|
| Orphan entry | `garcia2015` defined, never cited | Remove unless intentionally retained |
| Same work, 2 keys | `wang2021a` / `wang2021b` share DOI 10.18653/... | Merge to one key; update \cite sites |
| Author format | 3 entries use "First Last", rest "Last, First" | Normalize via biber, not by hand |
| Journal abbrev | `nguyen2020` uses full journal name; ACL wants ISO-4 | Abbreviate per ACL |
| Unreferenced figure | fig:appendixB has \label, never \ref'd | Reference it in text or move to appendix |

## Counts
- Cite keys: 47 cited / 52 defined → 5 orphans, 1 dangling
- DOIs: 41 present / 1 placeholder / 6 missing
- Cross-refs: 19 \ref / 19 \label → 1 dangling, 2 orphan labels

## Recommended fix order
1. Resolve the dangling \cite and \ref (blocks compile + the stop-gate).
2. Merge duplicate/same-work keys.
3. Replace placeholder DOI; fill empty required fields from sources.
4. Run biber/CSL to normalize author + journal formatting (deterministic — don't hand-edit).
```

## Pairs With

- **`citation-gate.sh`** — the live, every-edit check (Phases 2 + 7). This skill goes deeper (Phases 3–6) and explains fixes. Read its verdict at `.hook-state/last_quality_gate.json`.
- **`stop-gate.sh`** — blocks turn completion while the last gate failed. A clean audit clears it. Bypass only with `SKIP_QUALITY_GATE=1` for a pre-existing, unrelated dangling key.
- **`block-fabrication.sh`** — blocks writing placeholder DOIs / empty `.bib` fields. If a "fix" trips it, the fix was a fabrication.
- **`/claim-check`** — structural integrity here ≠ a cite *licensing* its claim. Run claim-check for the source-reading layer.

## Notes

- Counting and key-resolution are deterministic — prefer a quick `python3` parse over reasoning about which keys match. Reserve judgment for "are these two entries the same work?" and "is this orphan intentional?"
- Never assert a DOI is valid because it is well-shaped — shape ≠ existence. Verification against the real source is a separate, manual step.
- When converting reference styles, route the mechanical work through `biber`/a CSL processor; this skill audits, it does not retype the bibliography.
