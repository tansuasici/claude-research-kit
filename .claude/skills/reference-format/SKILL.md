---
name: reference-format
description: Convert or normalize the bibliography's citation style via the toolchain (biblatex/biber, CSL via pandoc, bibtex .bst) — deterministic, presentation-only, never altering the underlying facts and never inventing a missing field
user-invocable: true
---

# Reference Format

## Core Rule

Reference formatting is **deterministic — route it to the bibliography toolchain, not to the model**. Switching APA → a numbered style, abbreviating journal names, reordering author/year/title: these have exactly one correct output, and a CSL processor or biber produces it. Do **not** hand-retype entries — typing a bibliography by hand burns tokens and injects errors into a path that has a single right answer (`CLAUDE.md → Model vs Code`).

Two facts the model must hold:

1. **Presentation only.** A style conversion changes how a fact is *displayed* — never the fact. The DOI, author list, year, title, and venue in `references.bib` are immutable; the style decides ordering, punctuation, and abbreviation around them. If a conversion would change a DOI or an author name, that is a bug, not a reformat.
2. **Never invent a missing field to satisfy a style.** If the target style requires page numbers or a DOI and an entry lacks them, you do **not** fabricate one to make the build clean — you **flag** it `[VALUE — verify]` (`agent_docs/citation-discipline.md → placeholder protocol`). A fabricated page range is the same cardinal-rule violation as a fabricated citation.

This skill configures and runs the conversion and reports what is missing. It does not write `.bib` field *values* by hand.

## When to Use

Invoke with `/reference-format` when:

- The manuscript's bibliography is in the wrong style for its target venue (drafted APA, the venue wants a numbered style).
- After retargeting (`/journal-fit` surfaced a style mismatch as a gap).
- Normalizing inconsistent formatting (mixed "Last, First" / "First Last", mixed full/abbreviated journal names) — a deterministic clean-up, not a content edit.

State the target if it differs from the map: `/reference-format ACL`. Otherwise read it from `MANUSCRIPT_MAP.md → Target journal`.

## Process

### Phase 1: Identify Current and Target Style

1. **Read `MANUSCRIPT_MAP.md → Target journal`** to fix the target style. Map venue → style class: NeurIPS/ACL → numbered (author–year in text via the venue style file, ISO-4 abbreviations); IEEE → numbered `[1]`; APA → author–date with DOIs; Nature-family → superscript numerics.
2. **Detect the current mechanism** in the project:
   - **biblatex + biber** — look for `\usepackage[style=...]{biblatex}` and `\addbibresource`. Conversion = change `style=`.
   - **natbib / classic bibtex** — look for `\bibliographystyle{...}` and `\bibliography{}`. Conversion = swap the `.bst` (e.g. the venue's provided style file).
   - **pandoc + CSL** — Markdown source compiled with `--citeproc`. Conversion = swap the `--csl` file.
3. **Confirm the venue's required style file exists** — many venues (NeurIPS, ACL) ship a `.bst` or class with the kit/submission template. Use the venue's own file rather than a generic approximation.

### Phase 2: Apply the Conversion via the Tool

Pick the mechanism the project already uses; do not migrate engines unless asked.

- **biblatex/biber** — change the package option, e.g. `\usepackage[style=numeric-comp,sorting=none]{biblatex}` for a numbered venue; rerun `biber` then `latexmk`.
- **classic bibtex** — set `\bibliographystyle{<venue>}` (the provided `.bst`); rerun `bibtex` then `pdflatex`.
- **pandoc/CSL** — pass the target CSL, e.g. `pandoc paper.md --citeproc --csl=<venue>.csl --bibliography=references.bib -o paper.pdf`.

In every case the engine rereads `references.bib` and re-renders. **You do not edit the rendered output.** If a field is genuinely missing (the entry has no `doi` and the target needs one), that is a Phase 3 flag — not something you type in.

### Phase 3: Verify — Nothing Lost, Nothing Altered, Required Fields Present

After the tool runs:

1. **Entry count is conserved** — the rendered bibliography lists the same number of works as before. A dropped entry usually means a malformed `.bib` record the engine skipped — surface it.
2. **Facts unchanged** — spot-check that DOIs, author lists, years, and titles match `references.bib`. The style changed; the data did not.
3. **Required fields for the TARGET style are present, per entry.** Different styles demand different fields:

   | Target style class | Commonly required fields |
   |---|---|
   | APA (author–date) | author, year, title, journal/venue, **DOI**; pages for articles |
   | IEEE / numbered | author, title, venue, year; **pages**; volume/number for journals |
   | Nature-family | author, title, journal, year, volume, **pages** |
   | NeurIPS/ACL numbered | author, title, venue/booktitle, year; pages for proceedings |

   For each entry missing a required field, record it — do **not** fill it from your prior.
4. **No fabrication to satisfy the style** — every gap from step 3 becomes a `[VALUE — verify]` flag in the report, never an invented value.

## Output Format

```markdown
# Reference Format — APA → ACL (numbered)
> Mechanism: biblatex + biber (detected \usepackage[style=apa]{biblatex}).
> Deterministic conversion — presentation only; no .bib field values edited by hand.

## Config / command to apply
Change the package option:
  \usepackage[style=numeric-comp,sorting=none]{biblatex}   % was style=apa
Then rebuild:
  biber paper && latexmk -pdf paper.tex
(Use the ACL-provided .bst/style file if submitting via the ACL template.)

## Verification summary
- Entries before: 42  ·  rendered after: 42  ·  none dropped.
- Facts spot-checked: DOIs / authors / years unchanged (style-only re-render).

## Fields missing for the TARGET style (flag — do NOT invent)
| Bib key      | Missing required field | Action |
|--------------|------------------------|--------|
| tooluse2023  | pages                  | [VALUE — verify] — get from the published proceedings |
| halluc2022   | pages, volume          | [VALUE — verify] — confirm against the source PDF |

## Notes
- 2 entries need page numbers for the numbered style; flagged, not fabricated.
- If staying on classic bibtex instead: \bibliographystyle{acl_natbib} + bibtex run.
```

## Pairs With

- **`/citation-audit`** — run after the conversion; it re-checks dangling keys, duplicates, malformed DOIs, and `\ref`↔`\label` integrity against the new style. The audit reads the bibliography; this skill re-styles it.
- **`citation-gate`** (`.claude/hooks/citation-gate.sh`) — fires after every `.tex`/`.bib` edit; confirms every `\cite` still resolves after the style swap. If it fails, a key broke in conversion.
- **`MANUSCRIPT_MAP.md`** — the `Target journal` field is the source of the target style; read it first.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll just retype the entries in the new style" | One correct output exists — let biber/CSL produce it. Hand-typing injects errors into a deterministic path. |
| "The style needs a DOI; I'll add a plausible one" | A fabricated DOI is a cardinal-rule violation. Flag `[VALUE — verify]`; never invent it. |
| "This entry has no page numbers — I'll estimate the range" | Estimated pages are invented quantities. Flag and source them; the build can wait. |
| "I'll also fix a wrong author name while I'm here" | A wrong fact is a content fix, a Protected-Claim concern — not part of a style conversion. Surface it separately. |
| "Switch it to biblatex while reformatting" | Engine migration is a separate, larger change. Convert *within* the project's existing mechanism unless the author asks to migrate. |

## Notes

- This is a Drafter-model / tooling task (`CLAUDE.md → Model Selection`) — the model's only job is to pick the right config and read the missing-field report; the engine does the formatting.
- The cardinal-rule edge case to hold: a missing required field is a *flag*, never a *fill*. Styles are satisfied by sourcing the field or by flagging it — never by invention.
- Keep facts and presentation strictly separate. If an edit changes a DOI, year, or author, you left "formatting" and entered "altering the record" — stop.
