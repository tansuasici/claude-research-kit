---
name: lit-briefing
description: A short "since last time" briefing from vault/log.md + vault/index.md — recently ingested sources, open follow-ups and citation-chaining leads, and gaps relative to MANUSCRIPT_MAP.md → Thesis (themes the argument needs that the library lacks). Read-only; outputs a tight briefing whose gaps become search directions for /literature-review. Never fabricates a source to fill a gap.
user-invocable: true
---

# Lit-Briefing

## Core Rule

A briefing reports the **state of the library against the argument** — what came in, what is
still open, and where the thesis outruns the evidence. The gaps it names are *search
directions* (themes to go find real sources for), **never** fabricated sources to fill the
hole. "The argument needs work on horizon-scaling of hallucinated tool calls and the library
has none" is the honest output — not an invented citation that pretends the gap is closed.
This is a read-only synthesis of `vault/log.md`, `vault/index.md`, and the summaries; it
writes nothing except (optionally) the maintained gap list in the index.

## When to Use

Invoke with `/lit-briefing` when:

- Resuming work after time away — "what did I ingest, what was I chasing?"
- Before a `/literature-review` session, to know which themes the synthesis can support and
  which it must flag as gaps.
- Planning a literature-search session — the gaps become the search queries.
- After a run of `/lit-ingest`, to step back and see whether the new sources actually moved
  the argument forward.

Read-only. The one persistent side effect is maintaining
`vault/index.md → ## Open gaps (relative to the thesis)` so the gap list survives between
sessions.

## Process

### Phase 1 — Load the argument and the timeline

1. Read `MANUSCRIPT_MAP.md → Thesis`, **Contribution**, and **Key sources** — the argument
   the library exists to support, and the spine references it must not misattribute.
2. Read `vault/log.md` — the append-only activity record. Identify the most recent entries
   (ingests, lints, prior briefings) since the last briefing, or over a sensible recent
   window.
3. Read `vault/index.md` — the current roster of sources, concepts, entities, and the
   standing "Open gaps" list.

### Phase 2 — "Since last time": recent activity

From the tail of `vault/log.md`:

- **Recently ingested sources** — list them with cite key + one-line "what it establishes",
  pulled from each summary's `## Summary`. Note `status:` (a fresh `metadata-only` page is an
  ingest that still needs the full text).
- **Recent lint findings** — if a `/lit-lint` ran, surface any unresolved orphans or
  contradictions it logged.
- Keep it to what actually changed — this is a "since last time" delta, not a full inventory
  (that is `/lit-lint`'s job).

### Phase 3 — Open follow-ups & citation-chaining leads

Sweep the **Open questions / follow-ups** sections of recently touched summaries (and any
`concepts/` "Open gap" fields):

- **Citation-chaining leads** — papers a source cites that are worth fetching ("backward-cite
  from `[[doe2023tooluse]]`"), or later work by an author already in the vault.
- **Verification debts** — `[VALUE — verify]` fields and `metadata-only` pages still awaiting
  full text.
- **Threads** — questions an ingest raised that no current source answers.

Each lead is a concrete next action, not a vague "read more."

### Phase 4 — Gap analysis against the thesis

This is the heart of the briefing. For each theme the **argument** needs (derived from
`MANUSCRIPT_MAP.md → Thesis / Contribution / Key sources`), check whether the library
actually covers it:

- **Covered** — a read source in the vault supports it (name the cite key).
- **Thin** — only a `metadata-only` / `skimmed` page, or a single source carrying more weight
  than it can bear.
- **Missing** — no source in the library bears on it at all.

For every **thin or missing** theme, emit a **search direction** — what to look for, never a
fabricated paper:

- Keywords / queries to run (e.g. "constrained decoding tool use", "self-consistency
  verification agents").
- Venues & years likely to hold it (e.g. NeurIPS / ICLR / ACL 2023–2025).
- Citation chaining from a paper already in the vault.

Maintain these in `vault/index.md → ## Open gaps (relative to the thesis)` so they persist.
The loop stays honest: **you** fetch a result → `/lit-ingest` it → re-run the briefing; the
skill never closes a gap by inventing a source.

### Phase 5 — Assemble the briefing

Produce the tight briefing below. Keep it short — a briefing is read in under a minute. The
gaps are formatted so they can be handed straight to `/literature-review` as search
directions.

## Output Format

```markdown
# Lit-Briefing — 2026-06-03

## Since last time (3 ingests)
- [[doe2023tooluse]] — tool use works on single-turn QA (read)
- [[halluc2022]] — hallucination prevalent in LLMs (metadata-only — full text still needed)
- [[gate2024]] — pre-execution gate reduces hallucinated tool calls, one harness (read)

## Open follow-ups & citation-chaining leads
- Backward-cite from [[gate2024]] — it cites a multi-turn agent benchmark we lack.
- [[halluc2022]] is metadata-only — fetch the PDF to license its findings.
- Thread: does any source measure hallucinated-call rate vs. task horizon? (none yet)

## Gaps relative to the thesis
| Theme the argument needs | Library status | Search direction |
|--------------------------|----------------|------------------|
| Multi-turn agentic tool-call evaluation | missing | "multi-turn agent benchmark tool use", NeurIPS/ICLR 2023–2025 |
| Pre-execution vs. post-hoc verification | thin (gate2024 only) | "self-correction LLM agents", backward-cite from [[gate2024]] |
| Hallucinated-call rate vs. horizon | missing | "tool-call error rate task horizon", ACL 2024–2025 |

## Suggested next move
Fetch a multi-turn agentic eval benchmark (biggest unmet need for the thesis), /lit-ingest it,
then re-run /literature-review.
```

End by noting the count `(covered / thin / missing)` themes — the same honest gap framing
`/literature-review` reports. Never present a gap as closed by a source you cannot point to.

## Pairs With

- **`/literature-review`** — the direct consumer: the briefing's gaps become its search
  directions, and a covered theme tells it what it can synthesize from read sources.
- **`/lit-ingest`** — the action a follow-up or gap implies: fetch the real source, ingest it,
  re-brief.
- **`/lit-lint`** — run before briefing so orphans/contradictions do not pollute the gap
  picture; lint = structural health, briefing = argument coverage.
- **`MANUSCRIPT_MAP.md`** — the source of truth for the thesis the gaps are measured against;
  if the thesis shifts, the gaps shift.

## Notes

- **Read-only**, save for maintaining `vault/index.md → ## Open gaps`. The briefing reads the
  log and index; it does not ingest, lint, or edit `sources/`.
- A gap is a **search direction, never a fabricated source**. The cardinal rule applies: the
  honest output is "the library lacks X — here is how to find it," not an invented `\cite`.
- Distinguish three coverage states plainly — **covered / thin / missing** — so the author
  knows which themes the draft can lean on and which it must flag.
- Gap analysis against the thesis is Reasoner-tier synthesis (see `CLAUDE.md → Model
  Selection`); reading the log tail is mechanical.
- If the thesis itself has drifted (the gaps no longer match the argument), that is a finding
  worth surfacing — the briefing measures the library against `MANUSCRIPT_MAP.md`, so stale
  gaps can mean a stale map.
