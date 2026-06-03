---
name: gap-finder
description: Breadth-first scan of a draft for unsupported and uncited claims and missing-evidence gaps — classify every claim, list what is UNCITED/UNSUPPORTED, and for true gaps emit search directions (keywords, venues, citation-chaining), never a fabricated source
user-invocable: true
---

# Gap Finder

## Core Rule

Every claim in a draft is one of three things: **cited**, **the author's own
reasoning/data**, or **common knowledge** for this audience. **Flag everything else.** For a
genuine evidence gap — a claim the argument needs but the library cannot support — the honest
output is a **search direction** (what to look for: keywords, likely venues/years, a
citation-chain to follow), **never a fabricated source** that pretends the gap is closed. "The
argument needs evidence on horizon-scaling of hallucinated tool calls and the library has
none — search ACL 2024–2025 for 'tool-call error rate task horizon'" is the right output; an
invented `\cite{halluc2025}` is the failure the whole kit forbids.

This is the **breadth-first** scan: *what is missing* across a whole draft, fast. It is
deliberately distinct from `/claim-check`, which deep-verifies each cited claim against its
source. Gap-finder finds the holes; claim-check checks the fillings.

## When to Use

Invoke with `/gap-finder` when:

- A full draft (or several sections) exists and you want a fast map of every uncited /
  unsupported claim before investing in line-by-line verification.
- Early in revision — to triage where sourcing work is needed before `/claim-check` goes deep.
- After heavy drafting, to catch claims that slipped in without a cite ("I'll find one later"
  is how fabrications enter — surface them now).
- Planning a literature-search session — the gaps it emits become the queries for
  `/lit-briefing` and `/literature-review`.

Scope it to a draft or a set of sections: `/gap-finder sections/`. Unlike `/claim-check`
(one section, deep), gap-finder is built to sweep wide — run it across the whole draft, then
hand the worst sections to `/claim-check`.

## Process

### Phase 1: Load the Argument and the Library Roster

1. **Read `MANUSCRIPT_MAP.md`** — the Thesis, the Contribution, the **Audience** (decides what
   counts as common knowledge), and **Key sources** (what the library already establishes, and
   the "do NOT overclaim it as" column).
2. **Scan `references.bib`** — the roster of available cite keys, so a flagged claim can be
   matched to evidence the library may already hold but the draft failed to cite.
3. **If a vault exists, read `vault/index.md`** — the maintained roster of summarized sources
   and the standing **Open gaps** list (`/lit-briefing` keeps it). A gap already known to the
   vault should reuse its recorded search direction, not a fresh guess.
4. **Read the target draft/sections** — fast pass for coverage, not the deep per-source read
   `/claim-check` does. You are mapping claims to status, not verifying each verb against a PDF.

### Phase 2: Scan and Classify Every Claim

Sweep the draft. For each **substantive claim** (a disputable assertion about the world, the
literature, or the results — skip transitions and definitions), assign one status:

| Status | Meaning | Action |
|---|---|---|
| **CITED** | Carries a `\cite{key}` resolving in `references.bib` | OK for this pass — hand to `/claim-check` to verify the cite licenses it |
| **AUTHOR'S-OWN** | The results/reasoning, framed as such ("we observe…") | OK if visibly framed and backed by Results |
| **COMMON-KNOWLEDGE** | Uncontested for *this* audience | OK if genuinely common for the venue's readership |
| **UNCITED** | Disputable, no cite, but evidence likely exists in/near the library | Flag — match to a `.bib` key, or emit a search direction |
| **UNSUPPORTED** | Disputable, no cite, no library evidence, not author's-own | Flag — true gap; emit a search direction (or rescope/cut) |

This is breadth-first: classify, do not yet verify. A CITED claim passing this scan is *not*
"verified" — it has a cite that resolves; whether the source *licenses* it is `/claim-check`'s
job. Be strict on the escape hatches: "obvious to me" is not common-knowledge-for-this-audience
(check `MANUSCRIPT_MAP → Audience`); an unframed assertion next to cited sentences reads as
cited — flag the ambiguity.

### Phase 3: Cross-Check the Library for Available Evidence

For each **UNCITED/UNSUPPORTED** claim, check whether the library *already* holds evidence the
draft simply failed to cite:

- Match against `references.bib` keys and (if present) vault summaries. A claim that maps to an
  existing key is an **easy fix** — cite it (and then `/claim-check` it), not a true gap.
- Distinguish **"evidence exists, just uncited"** (UNCITED — fixable now from the library) from
  **"no evidence in the library at all"** (UNSUPPORTED — a genuine gap needing a real search).

This separation is the value of the skill: it tells the author which flags are five-minute
citation fixes and which are go-find-a-paper research.

### Phase 4: Emit Search Directions for True Gaps

For every genuine gap (UNSUPPORTED with nothing in the library), emit a **search direction —
never a fabricated source**:

- **Keywords / queries** to run (e.g. "constrained decoding tool use", "self-consistency
  verification LLM agents", "tool-call error rate task horizon").
- **Likely venues & years** (e.g. NeurIPS / ICLR / ACL 2023–2025) where such evidence would
  live.
- **Citation chaining** from a paper already in the library ("backward-cite from
  `tooluse2023` — it cites a multi-turn agent benchmark we lack"; or forward-cite to later
  work by an author already cited).
- Or, if no source is likely to exist, the honest alternative: **rescope, hedge, or reframe as
  the author's own observation** if Results support it.

These directions feed `/lit-briefing` and `/literature-review`. The loop stays honest: the
author searches → `/lit-ingest`s a real result → re-runs gap-finder; the skill never closes a
gap with an invented `\cite`.

### Phase 5: Report the Gap List and Tally

Produce the gap list (claim → status → fix or search-direction) and a tally. This skill
**reports; it does not edit** — adding a citation that carries an argument is a Protected Claim
(`CLAUDE.md`), and fabricating one is forbidden. Its only sourcing output is `[CITE]` flags and
search directions.

## Output Format

```markdown
# Gap Finder — sections/ (breadth-first)

## Tally
- Substantive claims scanned: 41
- Cited: 22 · Author's-own: 6 · Common-knowledge: 5
- UNCITED (evidence likely in library): 4
- UNSUPPORTED (true gap, needs a search): 4

## Flagged claims
| # | Locator | Claim (quoted) | Status | Fix or search direction |
|---|---|---|---|---|
| 1 | intro ¶2 | "tool-call hallucination is a leading agent failure mode" | UNCITED | Maps to `halluc2022` in references.bib — cite it, then /claim-check |
| 2 | rel ¶1 | "prior gating work is all post-hoc" | UNCITED | Maps to `tooluse2023` — cite; verify it actually supports "all post-hoc" |
| 3 | intro ¶3 | "hallucinated tool-call rate scales with task horizon" | UNSUPPORTED | True gap. Search: "tool-call error rate task horizon", ACL/NeurIPS 2023–2025; or reframe as our own result if Results show it |
| 4 | disc ¶2 | "pre-execution gating generalizes across agent harnesses" | UNSUPPORTED | True gap (one harness tested). Search: "cross-harness agent evaluation"; or rescope to the tested harness |
| 5 | disc ¶4 | "this is the first pre-execution gate for agent tool calls" | UNSUPPORTED | Novelty claim, no comparison shown. Search the related-work space to confirm "first"; else soften to "to our knowledge" |
| 6 | method ¶1 | "ReAct is a standard agent scaffold" | COMMON-KNOWLEDGE | OK for an ACL/agents audience (confirm vs MANUSCRIPT_MAP → Audience) |

## Easy fixes vs true gaps
- **Easy (cite from library):** #1 (`halluc2022`), #2 (`tooluse2023`) — fixable now, then verify with /claim-check.
- **True gaps (need a real search):** #3, #4, #5 — search directions above; none invented.

## Search directions (hand to /lit-briefing → /literature-review)
- "tool-call error rate task horizon" — ACL/NeurIPS 2023–2025 (claim 3).
- "cross-harness / multi-environment agent evaluation" (claim 4).
- Backward-cite from `tooluse2023` for a multi-turn agent benchmark (claims 3–4).

## Gaps in the library (relative to the thesis)
- No source on horizon-scaling of hallucinated tool calls (claim 3) — sources/ has nothing.
- No cross-harness generalization evidence (claim 4) — one harness in the library.
```

End with the tally `(cited / author's-own / common-knowledge / uncited / unsupported)` and the
count of true gaps. Never present a gap as closed by a source you cannot point to.

## Pairs With

- **`/claim-check`** — the deep partner: gap-finder is breadth-first ("what's missing"),
  claim-check is depth-first ("does this cite license this verb?"). Run gap-finder across the
  draft, then `/claim-check` the sections it flags heaviest. The classification taxonomy is
  shared on purpose.
- **`/literature-review`** & **`/lit-briefing`** — the consumers of the search directions: a
  true gap here becomes a query there; the vault's Open-gaps list and gap-finder's output are
  the same list seen from the draft vs the library.
- **`fact-checker` agent** — dispatch it to chase a batch of UNCITED claims against the vault
  to confirm which map to existing keys, before the author hand-fixes them.
- **`block-fabrication.sh`** (PreToolUse) — if a gap tempts you to stub a `.bib` entry to make
  the flag disappear, this hook blocks it. That is the system working: emit a search direction,
  do not fabricate.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll find a citation for this later" | Drafting around a citation you intend to find later is how fabrications enter. Flag it UNCITED/UNSUPPORTED now and emit a search direction. |
| "It's obviously true" | Obvious-to-you is not common-knowledge-for-this-audience. Cite it or it is UNSUPPORTED. |
| "Just invent a plausible reference to fill the gap" | A reference you cannot point to is a fabrication, not a fix — the cardinal rule. Emit a search direction instead. |
| "It's cited, so it's fine" | Gap-finder only confirms the cite *resolves*. Whether the source *supports* the claim is `/claim-check`'s job — do not call a CITED claim verified. |
| "This is the first to do X" | "First / SOTA" needs the comparison that establishes it. No comparison shown = UNSUPPORTED; soften to "to our knowledge" or do the search. |

## Notes

- This skill never writes a citation. Its only sourcing output is `[CITE]` flags and search
  directions — honest, per the cardinal rule in `CLAUDE.md`.
- Classifying claims and judging audience-relative common knowledge is Reasoner-tier
  (`CLAUDE.md → Model Selection`); the `.bib`/vault roster lookup is mechanical.
- It is breadth-first by design — do not let it slide into per-source verification (that is
  `/claim-check`). If it gets slow and deep, you are running the wrong skill.
- A recurring gap pattern (the author keeps leaving novelty/generalization claims unsupported)
  is a rule — log under `tasks/reviews/`, `applies_to: [citation, overclaim, scope]`, promote
  to `## Top Rules` if it recurs (`CLAUDE.md → Self-Improvement Loop`).
