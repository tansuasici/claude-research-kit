# VAULT.md — Literature Vault schema & workflow

The vault is an incremental, interlinked **annotated bibliography** — the evidence
layer the kit's cardinal rule depends on. "Every claim traces to a real source" is
only as strong as how well your sources are organized. The vault is where
`/literature-review` and the `fact-checker` agent get grounded evidence.

Based on the Karpathy LLM-wiki pattern: Claude incrementally builds and maintains
the vault from raw sources. It compounds — every source you add makes the next
draft better-grounded.

> Read this file before any vault work (CLAUDE.md auto-points here when `VAULT.md`
> exists). Ingest model: **self-contained** — sources live in `sources/`; nothing
> is fetched from the network.

---

## Structure

```
sources/                     # RAW material — immutable (protect-sources.sh)
  <anything>.pdf / .txt / .md #   downloaded papers, extracted text, your notes
references.bib               # the bibliography (cite keys)
vault/                       # Claude-MAINTAINED knowledge base (derived from sources/)
  index.md                  #   navigation: every source, theme, entity
  log.md                    #   append-only activity log
  summaries/<bibkey>.md     #   one annotated page per source (the heart of the vault)
  concepts/<concept>.md     #   cross-source concept pages (e.g. tool-call-hallucination.md)
  entities/<entity>.md      #   benchmarks, datasets, methods, groups
  _templates/               #   page templates (source / concept / entity)
```

**The two `sources` are different and must not be confused:**
- `sources/` (top level) = **raw, immutable** material. Never edit it.
- `vault/summaries/` = **derived, maintained** annotated pages, one per source.

---

## The `.bib` linkage (self-contained)

Each `vault/summaries/<bibkey>.md` is named for and tied to a `references.bib` key.
`/lit-ingest` reads a raw source and **proposes the `.bib` entry from the document
itself** — never fabricated. Metadata it cannot read with confidence is left as
`[VALUE — verify]`, never guessed. `block-fabrication.sh` rejects placeholder DOIs,
so a half-known reference surfaces instead of slipping in as real.

The loop: `sources/<paper>.pdf` → `/lit-ingest` → `references.bib` entry +
`vault/summaries/<bibkey>.md` → `/literature-review` synthesizes from the vault →
`citation-gate.sh` confirms the `\cite` resolves.

---

## Source page schema (`vault/summaries/<bibkey>.md`)

```markdown
---
bibkey: tooluse2023
title: Tool-augmented language models for single-turn QA
authors: [Doe, Roe]
year: 2023
venue: ExampleCL
source_file: sources/doe2023-tooluse.pdf   # the raw file this derives from
ingested: <YYYY-MM-DD>
tags: [tool-use, agents, evaluation]
status: read | skimmed | metadata-only
---

## Summary
<2–4 sentences: what the source does and finds. Your words, grounded in the text.>

## Key claims (with locators)
- <claim> — p./§ <locator> — <strength: shows / reports / suggests>

## Method
<how they did it — enough to judge the evidence's weight>

## Findings
<the actual results, with numbers + locators>

## Limitations / scope
<what it does NOT establish — the over-claim guardrail for citing it later>

## Relevance to thesis
<how this supports / contradicts / frames the current manuscript's argument>

## Quotes (verbatim + locator)
> "<exact quote>" — p. <n>

## Open questions / follow-ups
<citation-chaining leads, things to verify>

## Links
- Concepts: [[tool-call-hallucination]]
- Entities: [[ExampleCL-benchmark]]
```

`status: metadata-only` means the page was created from a `.bib` entry without the
full text — you may cite the source's existence but must not assert findings from it.

---

## Concept & entity pages

- `vault/concepts/<concept>.md` — a cross-source idea (e.g. "verification gating").
  Lists the summaries that bear on it, the tensions between them, and the open gap.
- `vault/entities/<entity>.md` — a benchmark / dataset / method / research group.
  What it is, which sources use it, known caveats (e.g. contamination).

Link liberally with `[[wikilinks]]`. A `[[link]]` to a page that does not exist yet
is fine — it marks something worth writing.

---

## Operations

| Skill | Does |
|---|---|
| `/lit-ingest <source>` | Read a source from `sources/` (or pasted text) → summarize → extract claims with locators → create `vault/summaries/<bibkey>.md` → propose/link the `.bib` entry → cross-reference concepts/entities → update `index.md` + `log.md`. Never fabricates; flags uncertain metadata. |
| `/lit-lint` | Health check: cross-source contradictions, orphan pages, `.bib` keys with no summary (and vice versa), claims missing locators, stale entries. |
| `/lit-briefing` | "What changed since last time" — recent ingests, open threads, gaps relative to the thesis. |

The `vault-maintainer` agent does the heavy ingest / cross-reference work.

---

## Rules

1. **Never modify `sources/`.** It is raw evidence. Derive into `vault/`, never edit the source.
2. **Never fabricate metadata or a quote.** Extract from the document; flag `[VALUE — verify]` for anything uncertain. Quotes are verbatim with a locator.
3. **Always update `vault/index.md` and append to `vault/log.md`** after any operation.
4. **One summary per `.bib` key**; keep the filename = the cite key.
5. **The vault never overrides the source.** When `/literature-review` or `fact-checker` needs the exact wording, they go back to `sources/`, not the summary.
