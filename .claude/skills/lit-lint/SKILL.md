---
name: lit-lint
description: Health-check the Literature Vault — find cross-source contradictions, orphan pages (a summary with no matching references.bib key, or a .bib key with no summary), broken [[wikilinks]], claims missing locators, metadata-only pages never upgraded, stale entries, and quotes without page numbers. Read-only/advisory — reports a categorized findings list with fixes; never edits sources or auto-rewrites the vault.
user-invocable: true
---

# Lit-Lint

## Core Rule

Lint **reports; it does not repair by inventing.** It surfaces where the vault has drifted —
orphans, broken links, claims without locators, quotes without page numbers — and names the
fix, but it never closes a gap by fabricating the missing piece. A summary missing a locator
gets flagged, not given a guessed page number. A `.bib` key with no summary gets flagged,
not given an imagined one. This is a read-only, advisory pass: it never modifies `sources/`
and never silently auto-edits the vault. The output is a worklist for the author or for
`/lit-ingest` to act on, not a set of edits.

## When to Use

Invoke with `/lit-lint` when:

- After a batch of `/lit-ingest` runs, to catch what slipped (orphans, missing locators).
- Before `/literature-review`, so the synthesis draws on a clean, consistent vault.
- Periodically, to find cross-source contradictions worth resolving before they reach the
  draft.
- After editing `references.bib` by hand, to re-check summary ↔ `.bib` alignment.

Read-only by default. With an explicit `--fix` argument it may propose (still not auto-apply)
mechanical repairs like adding a missing `[[wikilink]]` stub — but never a fabricated
locator, quote, finding, or DOI.

## Process

### Phase 1 — Inventory

Build the picture before judging it:

1. Read `VAULT.md` (the schema the vault must conform to).
2. List `vault/summaries/*.md`, the keys in `references.bib`, and every page under
   `vault/concepts/` and `vault/entities/`.
3. Collect every `[[wikilink]]` target across all pages, and every `\cite`-able key.
4. Read `vault/index.md` and `vault/log.md` to know what *should* be present.

### Phase 2 — Orphan & linkage checks

- **Summary without a `.bib` key** — a `vault/summaries/<key>.md` whose `<key>` has no entry
  in `references.bib`. Either the entry is missing or the filename is wrong.
- **`.bib` key without a summary** — an entry in `references.bib` with no
  `vault/summaries/<key>.md`. It may be legitimately `metadata-only`, but it should at least
  have a stub page; flag it.
- **Broken `[[wikilinks]]`** — a link whose target page does not exist. (A deliberate stub is
  fine per `VAULT.md` — distinguish "not written yet, intentional" from "typo / renamed
  page".)
- **Index drift** — a summary that exists on disk but is missing from `vault/index.md`, or an
  index line pointing to a page that is gone.
- **Filename ≠ cite key** — the page's `bibkey:` frontmatter must equal its filename and its
  `.bib` key (`VAULT.md` Rule 4).

### Phase 3 — Claim & quote hygiene

Per summary page:

- **Claims missing locators** — a bullet under "Key claims" with no `p./§` locator. A claim
  the vault cannot point to a page for is not yet citable.
- **Quotes without page numbers** — a `>` quote with no `— p. <n>`. Floating quotes are a
  cardinal-rule violation waiting to happen; flag every one.
- **Findings without numbers/locators** — a "Findings" section that asserts a result with no
  figure/locator to anchor it.
- **`[VALUE — verify]` still open** — surface every unresolved placeholder (in summaries and
  in the proposed `.bib` metadata) so the author knows what still needs reading. These are
  honest flags, not errors — but they are open work.

### Phase 4 — Cross-source contradiction scan

Compare claims across summaries (and within each `concepts/` page's "Tensions" section) for
sources that disagree — e.g. one reporting a verification gate **eliminates** hallucinated
tool calls while another reports only a **partial reduction**. Report these as *contradictions
to resolve*, with both locators. Do **not** adjudicate which source is right — that is the
author's call (and a Protected Claim if it changes the argument); lint only surfaces the
seam. A genuine disagreement between real sources is a finding, often the seam a contribution
exploits — note it, do not erase it.

### Phase 5 — Staleness & status

- **`metadata-only` never upgraded** — a page still `status: metadata-only` whose full text is
  now in `sources/`. Candidate for `/lit-ingest` to upgrade.
- **Stale entries** — a summary whose `source_file:` no longer exists in `sources/`, or whose
  `ingested:` date long predates a changed source.
- **`skimmed` pages** — flag pages marked `skimmed` so the author knows coverage is partial
  before citing them.

### Phase 6 — Report

Produce the categorized findings list (below). Each finding: locator + the precise fix.
Nothing is auto-applied. Append one line to `vault/log.md`
(`2026-06-03  lint  — N findings (orphans 2, missing-locators 4, broken-links 1)`) so the
health check is part of the record — this is the one write lint makes.

## Output Format

```markdown
# Lit-Lint — Vault Health Report

## Summary
- Summaries: 12 · references.bib keys: 14 · concepts: 5 · entities: 7
- Findings: 11  (Orphans 3 · Missing locators 4 · Broken links 1 · Contradictions 1 · Stale 2)

## Orphans
| # | Item | Problem | Fix |
|---|------|---------|-----|
| 1 | references.bib `halluc2022` | no vault/summaries/halluc2022.md | ingest it, or add a metadata-only stub |
| 2 | vault/summaries/tooluse2023.md | no `tooluse2023` in references.bib | add the .bib entry, or rename the page |

## Broken [[wikilinks]]
| # | Source page | Link | Likely cause |
|---|-------------|------|--------------|
| 1 | summaries/tooluse2023.md | [[verification-gateing]] | typo → [[verification-gating]] |

## Claims missing locators / quotes without pages
| # | Page | Item | Fix |
|---|------|------|-----|
| 1 | summaries/halluc2022.md | claim "hallucination is prevalent" | add p./§ locator from source |
| 2 | summaries/halluc2022.md | quote "models confabulate freely" | add — p. <n> or remove |

## Cross-source contradictions (resolve — do not auto-edit)
| # | Source A (locator) | Source B (locator) | The disagreement |
|---|--------------------|--------------------|------------------|
| 1 | tooluse2023 p.4: gate "eliminates" hallucinated calls | halluc2022 p.7: only "reduced" | strength mismatch — pick the calibrated claim |

## Stale / status
| # | Page | Issue | Fix |
|---|------|-------|-----|
| 1 | summaries/halluc2022.md | metadata-only, full text now in sources/ | run /lit-ingest to upgrade |

## Open [VALUE — verify]
- summaries/tooluse2023.md — DOI still [VALUE — verify]
```

End with the tally `(clean / findings / open placeholders)`. Never report the vault "clean"
while orphans, broken links, missing locators, or open `[VALUE — verify]` markers remain.

## Pairs With

- **`/lit-ingest`** — the fixer for most findings: re-ingest to upgrade a `metadata-only`
  page, add a missing locator, or create a missing summary.
- **`/lit-briefing`** — consumes a clean vault; run lint first so the briefing's gap analysis
  is not muddied by orphans.
- **`vault-maintainer` agent** — dispatch it to work through a long findings list (re-ingest,
  re-link) so the main thread stays clean.
- **`citation-gate.sh`** — the `.tex`-side analogue: it proves `\cite` keys resolve in
  `references.bib`; lint proves the vault layer behind them is consistent.
- **`/citation-audit`** — the structural `.bib` health pass; complementary to lint's
  vault-page focus.

## Notes

- **Read-only / advisory.** Lint never edits `sources/` and never auto-rewrites a vault page;
  its only write is the one-line `vault/log.md` entry recording the run.
- It **flags, never fabricates** — a missing locator/quote/DOI is reported, never guessed.
  This is the cardinal rule applied to vault maintenance.
- A contradiction between two real sources is a *finding*, not a defect to paper over — often
  the seam a contribution exploits. Resolving it (which to believe, how to frame it) is the
  author's call.
- The cross-source contradiction scan is Reasoner-tier judgment (see `CLAUDE.md → Model
  Selection`); the orphan/link/locator checks are mechanical.
- A high "open `[VALUE — verify]`" count is a finding about *reading backlog*, not a defect in
  the vault — report it as such.
