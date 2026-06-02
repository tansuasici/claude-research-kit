# Citation & Sourcing Discipline

The deep guide to `CLAUDE.md → Source-Grounded Writing (the cardinal rule)`. This is
the rule the entire kit exists to enforce. Read it before any work touching
`references.bib`, `\cite`, quotations, or reported quantities.

**The one sentence:** every claim traces to a real source or to the author's stated
reasoning; a missing citation is a *flag*, never an *invention*.

---

## What counts as a fabrication

A fabrication is any reference artifact you produce that does not already exist in
the library (`references.bib` / `sources/`) and that you cannot point to in a real
source. "Plausible-looking" is exactly the danger — a fabrication is convincing by
construction. All of these are fabrications, equally forbidden:

| You invented... | Example | Why it is fabrication, not citation |
|---|---|---|
| a `\cite` **key** | `\cite{patel2020}` with no `patel2020` in any `.bib` | The key resolves to nothing. Caught by `citation-gate.sh`. |
| a **DOI** | `doi = {10.1234/2023.acl-long.42}` you did not read off the source | A real-shaped identifier pointing nowhere — the worst kind. |
| an **author** | "Patel et al. showed…" when no such paper is in the library | Misattribution; a reader cannot find it. |
| a **year / venue / volume / pages** | filling `year = {2023}` from your prior | Guessed metadata is still guessed. |
| an **arXiv ID** | `2103.04567` you did not verify | Same as DOI — fake-shaped identifier. |
| a **quote** | quotation marks around words the source does not contain | Quoting is a verbatim claim; a paraphrase in quotes is fabrication. |
| a **page/locator** | "(p. 412)" you did not check | A locator is a promise the reader can turn to that page. |
| a **quantity** | "tool-call accuracy reached 94%" with no source and no author data | A measured value you did not measure or read. |

None of these is acceptable "to be fixed later." The fix is the placeholder protocol
below, not a confident guess you intend to revisit.

---

## The placeholder protocol

When you lack the artifact, you **flag** rather than fabricate. Two placeholders, both
encouraged and never blocked by the hooks (they live in *prose*, not in a `.bib`
entry):

- **`[CITE]`** — a claim that needs a reference you do not have.
  > "Verification has been applied to single-turn tool use `[CITE]`, but the
  >  multi-turn agentic case is unaddressed."
  Annotate what is needed so the author (or a literature search) can resolve it:
  `[CITE — survey of tool-use verification, post-2023]`.

- **`[VALUE — verify]`** — a quantity you do not have from a source or from the
  author's own data.
  > "Tool-call accuracy reached `[VALUE — verify]`% at the long-horizon setting."
  Never substitute a guessed number to "make the sentence read better."

When you finish a draft, **count the placeholders** and report them as
`(sourced / placeholder / unverified)` (`CLAUDE.md → Verification`, step 7). A draft
with placeholders embedded is *not* complete — say so plainly, never bury them.

---

## "I think there's a paper that says X"

This is the highest-risk moment, because your prior is often *almost* right — right
enough to produce a convincing fake. The rule:

> A memory of a paper is not a citation. State the claim, flag it, and stop.

Do this:

```text
"I believe there is work showing self-correction underperforms on long-horizon tasks
 (possibly around 2022), but it is not in references.bib. I have left:
   'Self-correction degrades on long-horizon tasks [CITE — self-correction + long horizon, ~2022].'
 Add the source to the library and I will wire up the \cite."
```

Do **not** do this:

```text
✗ \cite{appleton2022}        ← a key you reconstructed from memory
✗ "Appleton et al. (2022) showed…"   ← an author + year you are not sure of
✗ doi = {10.1234/2022.emnlp-main.…}    ← a DOI shaped like the right venue
```

The agent's recalled bibliographic metadata is precisely what must never reach the
manuscript. Surface the lead; let a real lookup confirm it.

---

## When a claim needs a citation — and when it does not

Every sentence in the manuscript is exactly one of three things
(`CLAUDE.md → Source-Grounded Writing`). If it is none, it does not belong in the
draft yet.

| Category | Needs a `\cite`? | Test |
|---|---|---|
| **Sourced claim** | **Yes.** | "Where did I learn this?" → a specific source. e.g. a prior result, a regulatory limit, a method's reported performance. |
| **Author's own contribution / reasoning** | No — but mark it as such. | "This is *our* result / *our* inference." Stated as the authors' own (results from your data, an argument you are making). |
| **Common knowledge in the field** | No. | A specialist reader of the target venue would not ask for a source. e.g. "LLMs can produce ungrounded outputs." Calibrate to the *venue's* audience (`MANUSCRIPT_MAP.md → Audience`) — what is common knowledge at NeurIPS is not in a general venue. |

Borderline calls default to citing. A specific number, a named prior method, a
"first to" or "unlike prior work" claim, and any comparison **always** need a source
(or the author's data). When unsure whether something is common knowledge, ask — do
not silently promote a recalled fact to "common knowledge."

---

## BibTeX entry hygiene

A `.bib` entry is only as good as its weakest required field. `block-fabrication.sh`
**blocks** entries with an empty required field (`author = {}`, `title = {}`, …) or
placeholder text inside one (`TODO`, `FIXME`, `CITATION NEEDED`, `TBD`) — fill it
from the source or remove the entry.

**Required fields by entry type** (minimum to be a real, findable reference):

| Type | Required | Common optional |
|---|---|---|
| `@article` | `author`, `title`, `journal`, `year` | `volume`, `number`, `pages`, `doi` |
| `@book` | `author`/`editor`, `title`, `publisher`, `year` | `edition`, `isbn` |
| `@inproceedings` | `author`, `title`, `booktitle`, `year` | `pages`, `publisher`, `doi` |
| `@techreport` | `author`, `title`, `institution`, `year` | `number`, `url` |
| `@phdthesis` | `author`, `title`, `school`, `year` | `type` |
| `@misc` (datasets, preprints, web) | `author`/`title`, `year`, `howpublished`/`url` | `doi`, `note`, `urldate` |

**DOI format.** A real DOI is `10.<registrant>/<suffix>` and goes in the bare `doi`
field, not as a URL. `block-fabrication.sh` blocks fake-shaped DOIs — `10.xxxx`,
`10.0000`, `10.9999`, `example.com`, and `your-doi`/`placeholder`/`TODO` values. If
you do not have the DOI, **omit the field**; do not approximate one.

```bibtex
% good
@inproceedings{tooluse2023,
  author    = {Smith, J. A. and Doe, R.},
  title     = {Verified tool use for single-turn question answering},
  booktitle = {Proceedings of ACL},
  year      = {2023},
  pages     = {1234--1242}
}

% blocked: empty required field, fake DOI
@article{patel2022,
  author = {},                       % ← block-fabrication.sh: empty required field
  title  = {Some agent paper},
  year   = {2022},
  doi    = {10.xxxx/placeholder}     % ← block-fabrication.sh: placeholder DOI
}
```

**Key naming.** Use a stable, collision-free convention and apply it consistently
(one term per concept — `CLAUDE.md → Claim Discipline`). The common convention is
`<firstauthorlastname><year><disambiguator>`: `tooluse2023`, `tooluse2023a`. Do not
rename keys casually — a key rename ripples through every `\cite` and is an edit to
the citation graph.

---

## Quoting & locators

A quotation is a **verbatim** claim about a source. Two non-negotiables
(`CLAUDE.md → Source-Grounded Writing`):

1. **Verbatim.** The quoted words appear exactly in the source. If you change wording,
   it is a paraphrase — drop the quotation marks. Mark elisions with `…`/`\dots` and
   editorial insertions with `[brackets]`; do not silently alter.
2. **Locator.** Every quote carries a page or section: `(Smith 2023, p. 1238)` /
   `\cite[p.~1238]{tooluse2023}`. A floating quote with no locator is unverifiable — it
   reads like fabrication even when it is not.

Verification step 2 (`CLAUDE.md`) checks quotes against the source. A hook cannot read
the source PDF for you — this step is yours or `/claim-check`'s. If `sources/` holds
the PDF, the quote is checkable; treat `sources/` as immutable evidence
(`protect-sources.sh`) so the chain stays trustworthy.

---

## How the hooks enforce this

The discipline is prompt-side; two hooks make the cardinal rule mechanical.

| Hook | When | What it does |
|---|---|---|
| `block-fabrication.sh` | PreToolUse (Edit/Write) | **Blocks** writing a fabricated reference: fake-shaped DOI, empty/placeholder required `.bib` field. Stops the bad entry before it lands. Honest prose placeholders (`[CITE]`, `[VALUE — verify]`) are never blocked. |
| `citation-gate.sh` | PostToolUse (`.tex`/`.bib`) | After the fact: every `\cite`-family key must resolve to a `.bib` entry; every `\ref` must have a `\label`. Records the verdict to `.hook-state/last_quality_gate.json`. |
| `stop-gate.sh` | Stop | Blocks finishing the turn when the last gate verdict was `failed` (a dangling `\cite` or `\ref`). |

The split is deliberate: `block-fabrication` stops a fake reference being *written*;
`citation-gate` catches a `\cite` with no entry *after* the edit; `stop-gate` refuses
to let you call it done. Bypass with `RESEARCH_APPROVED=1` (verified legacy imports
only) or `SKIP_QUALITY_GATE=1` (a dangling reference that predates and is unrelated to
your change) — and note the bypass in `tasks/decisions.md`.

What the hooks **cannot** do: read the source PDF to confirm a quote is verbatim, a
locator is correct, or a verb matches what the source actually says (verification
steps 2–4). Those need a human or `/claim-check`. The hooks guarantee the citation
*resolves*; only judgment guarantees it is *honest*.

---

## After any correction

If the author or a reviewer catches a sourcing slip (an overclaimed citation, a
missing locator, a near-fabrication), log it under `tasks/reviews/` using
`_TEMPLATE.md`, tag `applies_to: [citation]`, and promote it to `## Top Rules` if it
recurs (`CLAUDE.md → Self-Improvement Loop`). "You keep citing single-turn QA results for
multi-turn agentic claims" is a rule, not a one-off.
