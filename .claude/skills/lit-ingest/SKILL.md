---
name: lit-ingest
description: Ingest ONE raw source (a sources/ PDF or .txt path, or pasted text) into the Literature Vault — read it, write a vault/summaries/<bibkey>.md annotated page with claims+locators and verbatim quotes, propose a references.bib entry extracted FROM the document (never fabricated), cross-reference concepts/entities, and update index + log. Never modifies sources/; flags uncertain metadata as [VALUE — verify].
user-invocable: true
---

# Lit-Ingest

## Core Rule

Ingest is **extraction, not authorship**. Everything in the summary and the proposed
`.bib` entry comes FROM the source document in front of you — never from your prior, never
from what a paper with this title "probably" says. A summary that asserts a finding the
source does not state, or a `.bib` entry with a guessed DOI, is a fabrication — the one
thing this kit exists to prevent. Metadata you cannot read with confidence is left as
`[VALUE — verify]`, never filled in. Quotes are **verbatim** and carry a locator. You read
one source and turn it into one `vault/summaries/<bibkey>.md` page plus a proposed
`references.bib` entry; you never invent a second source to go with it.

## When to Use

Invoke with `/lit-ingest <source>` when:

- You have added a paper to `sources/` (PDF/txt/md) and want it in the vault.
- You want to paste extracted text or notes for a source and have it summarized + linked.
- `/literature-review` reported a gap, you fetched a real paper to fill it, and now need it
  ingested so the next synthesis can use it.
- A `references.bib` entry exists as `status: metadata-only` and you now have the full text
  to upgrade its page.

`<source>` is a path under `sources/` (e.g. `/lit-ingest sources/doe2023-tooluse.pdf`) or
the word `paste` followed by the text. One source per invocation — batch ingests go through
the `vault-maintainer` agent so the main thread stays clean.

## Process

### Phase 1 — Read the source (never modify it)

1. Read `VAULT.md` (the schema) and `MANUSCRIPT_MAP.md → Thesis` so the summary's
   "Relevance to thesis" section is grounded in the actual argument.
2. Read the raw source from `sources/` (use the `pdf` skill for PDFs) or take the pasted
   text. **Treat it as immutable** — `protect-sources.sh` blocks edits to `sources/`; never
   try to "clean up" or rewrite the raw file.
3. If the text is unreadable (scanned image, OCR garbage, truncated paste), say so and stop
   — do not summarize a document you cannot actually read. An honest "cannot read this PDF"
   beats a confident summary of nothing.

### Phase 2 — Extract metadata & choose the cite key

From the document's own front matter (title block, author list, venue line, DOI on page 1):

- Pull title, authors, year, venue. For **any field you cannot read with confidence**, write
  `[VALUE — verify]` — never guess a year or a venue from the title.
- Choose a cite key as `firstauthorYEARkeyword` (e.g. `doe2023tooluse`). If the year is
  unknown, the key still needs to be stable — pick the keyword and flag the year. Keep it
  consistent with any existing scheme in `references.bib`.
- The page filename is exactly the cite key: `vault/summaries/<bibkey>.md`. One summary per
  `.bib` key (Rule 4 in `VAULT.md`).

### Phase 3 — Write the summary page

Create `vault/summaries/<bibkey>.md` from `vault/_templates/source.md`, filling every
section per the `VAULT.md` source-page schema:

- **Summary** — 2–4 sentences in your words, grounded in the text.
- **Key claims (with locators)** — each claim tagged with a page/§ locator and a strength
  verb (`shows` / `reports` / `suggests`). No locator → not a logged claim.
- **Method** — enough to judge the evidence's weight (design, sample, what was measured).
- **Findings** — the actual results **with numbers and locators**. Copy numbers exactly; if
  a number is unreadable, write `[VALUE — verify]`, never approximate one.
- **Limitations / scope** — what the source does NOT establish. This is the guardrail that
  stops a later draft from overclaiming it.
- **Relevance to thesis** — supports / contradicts / frames the current argument.
- **Quotes (verbatim + locator)** — exact wording with `p. <n>`. A quote you cannot place
  to a page does not go in.
- **Open questions / follow-ups** — citation-chaining leads (papers it cites worth
  fetching), things to verify.

Set `status:` honestly: `read` (full text digested), `skimmed` (read partially — flag what
you did not cover), or `metadata-only` (no full text — you may record its existence but must
NOT assert findings from it).

### Phase 4 — Propose the `references.bib` entry (extracted, not invented)

Propose a BibTeX entry built from the metadata you extracted in Phase 2:

```bibtex
@inproceedings{doe2023tooluse,
  title     = {Tool-augmented language models for single-turn QA},
  author    = {Doe, Jane and Roe, Richard},
  booktitle = {Proceedings of ExampleCL},
  year      = {2023},
  doi       = {[VALUE — verify]}
}
```

- **Never fabricate a DOI.** If page 1 carries no DOI, leave it `[VALUE — verify]` or omit
  the field. `block-fabrication.sh` rejects placeholder/fake-shaped DOIs (`10.xxxx`,
  `example.com`, `TODO`) — so a half-known reference surfaces for the author instead of
  slipping in as real. That is the system working, not a failure.
- Show the entry for the author to paste into `references.bib`; do not silently assume it is
  already there. (Writing the `.bib` is the author's call; `citation-gate.sh` later confirms
  the `\cite` resolves.)
- If the cite key already exists in `references.bib`, reconcile rather than duplicate — flag
  any mismatch between the existing entry and what the document says.

### Phase 5 — Cross-reference concepts & entities

Wire the new page into the vault with `[[wikilinks]]`:

- For each cross-source idea the source bears on, link/create `vault/concepts/<concept>.md`
  (from `vault/_templates/concept.md`) — e.g. `[[tool-call-hallucination]]`,
  `[[verification-gating]]`. Add this source to the concept's "Sources that bear on it" with
  its stance, and note any tension with sources already listed.
- For each benchmark / dataset / method / model / group, link/create
  `vault/entities/<entity>.md` (from `vault/_templates/entity.md`) — e.g.
  `[[NeurIPS-tooluse-benchmark]]`. Record how this source uses it and any caveat
  (contamination, version drift).
- A `[[link]]` to a page that does not exist yet is fine — it marks something worth writing.
  Do not invent the linked page's contents; create a stub and move on.

### Phase 6 — Update index + log (mandatory)

- Add a line to `vault/index.md → ## Sources (by cite key)`, newest first:
  `- [[doe2023tooluse]] — Tool-augmented LMs for single-turn QA (Doe & Roe, 2023) — read`.
  List any new concept/entity pages under their headings.
- Append one line to `vault/log.md` (append-only, newest at the bottom):
  `2026-06-03  ingest  doe2023tooluse  — created summary, proposed .bib entry, linked [[verification-gating]]`.

Never rewrite the log; never skip the index. Per `VAULT.md` Rule 3, no ingest is complete
without both.

## Output Format

1. **The summary page** — written to `vault/summaries/<bibkey>.md`, conforming to the schema.
2. **Proposed `.bib` entry** — shown in a fenced block for the author to paste; uncertain
   fields as `[VALUE — verify]`, no invented DOI.
3. **Cross-reference report** — which `concepts/` and `entities/` pages were created or
   touched, and the new `[[wikilinks]]`.
4. **Index + log diff** — the lines added.
5. **Flags** — every `[VALUE — verify]` left open, the `status:` set, and any source passage
   that was unreadable. End with the honest tally: `(claims logged / quotes captured /
   fields left to verify)`.

## Pairs With

- **`/literature-review`** — the consumer: it synthesizes from the summaries this skill
  writes. Ingest a fetched source here, then re-run the review to close the gap honestly.
- **`fact-checker` agent** — reads `sources/` (not the summary) for exact wording; the
  summary's locators tell it where to look.
- **`vault-maintainer` agent** — dispatch it for batch ingest / heavy cross-referencing so
  the main thread stays clean.
- **`block-fabrication.sh`** (PreToolUse) — rejects the proposed `.bib` entry if it carries a
  placeholder/fake DOI. Flag it `[VALUE — verify]`, do not invent one.
- **`citation-gate.sh`** (PostToolUse) — later confirms the `\cite{<bibkey>}` resolves once
  the entry is in `references.bib`.
- **`/lit-lint`** — run after a batch of ingests to catch orphans and missing locators.

## Notes

- **Never modify `sources/`.** Derive into `vault/`; the raw file is evidence and stays
  byte-for-byte intact (`protect-sources.sh` enforces this).
- The summary is a convenience layer, **never an override**: when `/literature-review` or
  `fact-checker` needs exact wording, they return to `sources/`, not the summary
  (`VAULT.md` Rule 5).
- `metadata-only` is a real, valid status — a citation without the content. Record the
  source's existence; do NOT assert its findings until the full text is ingested.
- Synthesis and judging relevance are Reasoner-tier work (see `CLAUDE.md → Model
  Selection`); mechanical metadata extraction is fine on the Drafter.
- If ingesting reveals the source contradicts a claim already in the manuscript, that is a
  finding — surface it; do not quietly smooth it over.
