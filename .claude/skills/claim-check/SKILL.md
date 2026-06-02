---
name: claim-check
description: Walk every substantive claim in a section, classify it (cited / author's-own / common-knowledge / UNSUPPORTED), verify the citation licenses the claim's verb and quantifier, and report supported/overstated/uncited counts
user-invocable: true
---

# Claim Check

## Core Rule

Every substantive claim is one of four things: **cited**, **the author's own reasoning/data** (stated as such), **common knowledge** in the field, or **UNSUPPORTED**. A claim that is none of these does not belong in the manuscript yet. Never fabricate a citation to "fix" an uncited claim — flag it with `[CITE]` and tell the author what is missing. A plausible-looking reference you cannot point to is a fabrication, not a fix.

This is the flagship skill. It is the manual, source-reading half of verification that a hook cannot do: `citation-gate.sh` proves a `\cite` key *resolves* to a `.bib` entry; only a reader can prove the entry *licenses* the sentence.

## When to Use

Invoke with `/claim-check` when:

- A section draft is "done" and you want to know what a skeptical Reviewer 2 would attack.
- You inherited prose (yours or a co-author's) and need to know which sentences are load-bearing but unsourced.
- Before submission, on the Introduction, Results, and Discussion — the three sections where overclaim hides.
- After a revision that added claims, to confirm none slipped in uncited.

Scope it: `/claim-check sections/discussion.tex` for one section, or name a paragraph. Checking a whole manuscript at once produces a table too long to act on — go section by section.

## Process

### Phase 1: Establish Ground Truth

Before reading a single claim, load what the section is allowed to assert:

1. **Read `MANUSCRIPT_MAP.md`** — the Thesis, the Key sources table (what each `.bib` key establishes and what it must NOT be overclaimed as), and "Claims that need extra care."
2. **Read the target `.tex` file** in full. Do not skim — every declarative sentence is a candidate claim.
3. **Read `references.bib`** for the keys this section cites. Note each entry's actual scope: population, matrix, method, sample size, and the strength of its own language (did the source say "associated with" or "causes"?).
4. **Open the sources** in `sources/` for the spine references. If a source PDF/note is not in the library, you cannot verify a claim against it — record that gap; do not assume the claim holds.

If `MANUSCRIPT_MAP.md → Key sources` says a reference must not be overclaimed a certain way (e.g. "freshwater baseline — NOT evidence for leachate"), that is a hard constraint for this pass.

### Phase 2: Enumerate Claims

Walk the section sentence by sentence. A **substantive claim** asserts a fact about the world, the literature, or your results that a reader could dispute. Skip pure transitions, definitions you established, and signposting.

For each claim, record: the verb (asserts / shows / suggests / proves / causes / is associated with), the quantifier (all / most / often / in our sample / generally), and any number. Verb and quantifier are where overclaim lives — capture them precisely.

### Phase 3: Classify Each Claim

Assign exactly one class:

| Class | Definition | Action |
|---|---|---|
| **CITED** | Carries a `\cite{key}` resolving to `references.bib` | Verify in Phase 4 |
| **AUTHOR'S-OWN** | Your data, reasoning, or contribution, stated as such | Check it matches your Results/data; no external cite needed |
| **COMMON-KNOWLEDGE** | Uncontested in this venue's audience; needs no cite | Confirm it is genuinely common for *this* audience (see MANUSCRIPT_MAP → Audience) |
| **UNSUPPORTED** | Disputable, not cited, not your data, not common knowledge | Flag `[CITE]` — needs a source or must be cut/hedged |

Discipline on the easy escape hatches:
- "Common knowledge" is audience-relative. For a specialist methods venue, a basic mechanism may be common; for a broad-readership journal it must be cited. When in doubt, it is not common knowledge.
- "Author's-own" must be visibly framed as such ("We observe…", "Our data indicate…"). An unframed assertion sitting next to cited sentences reads as cited — that is a sourcing ambiguity, flag it.

### Phase 4: Verify Each CITED Claim Against Its Source

For every cited claim, check the citation actually **licenses the verb and the quantifier**:

1. **Verb strength** — the source must support the claim's verb. If the source reports an association and the sentence says "causes," that is **OVERSTATED**. "suggests" ≠ "proves"; "is consistent with" ≠ "demonstrates."
2. **Quantifier / scope** — "in general" needs evidence beyond one sample/matrix/population. A freshwater result does not license a leachate claim. Scope creep is **OVERSTATED**.
3. **Quantity** — any number must match the source exactly. A misremembered statistic is a fabrication even with a real cite. If you cannot confirm the number against the source, mark it `[VALUE — verify]`; do not let it pass.
4. **Attribution direction** — the cite must support *this* claim, not a neighbouring one. Watch for a `\cite` that backs the first half of a sentence while the second half (the actual claim) rides along unsupported.

Outcome per cited claim: **SUPPORTED** (verb + quantifier + number all licensed) or **OVERSTATED** (calibrate down).

### Phase 5: Report and Prioritize Fixes

Produce the table and a prioritized fix list. **Do not edit the manuscript in this skill** unless the user asked — claim-check reports; fixing claims (especially adding/removing a cite that carries an argument) is a Protected Claim and needs author sign-off per `CLAUDE.md`.

## Output Format

```markdown
# Claim Check — sections/discussion.tex

## Summary
- Claims examined: 18
- Supported: 11
- Overstated: 4   (verb/quantifier exceeds the cited evidence)
- Uncited:    3   (UNSUPPORTED — flagged [CITE], NOT fabricated)

## Claim Table
| # | Claim (verb / quantifier) | Class | Cite | Verdict | Note |
|---|---|---|---|---|---|
| 1 | "EC removes short-chain PFAS (in our sample)" | author's-own | — | SUPPORTED | matches Results Tab 2 |
| 2 | "sorption fails for C4 (causes)" | cited | smith2021 | OVERSTATED | source shows association, not causation |
| 3 | "this is the first leachate study" | author's-own | — | OVERSTATED | novelty claim with no comparison shown |
| 4 | "PFAS are persistent" | common-knowledge | — | OK | uncontested for this audience |
| 5 | ">90% efficiency generally" | cited | jones2019 | OVERSTATED | jones is freshwater; scope creep to leachate |
| 6 | "regulatory limit is 70 ng/L" | cited | epa2016 | [VALUE — verify] | number not confirmed against source |
| 7 | "removal scales with chain length" | UNSUPPORTED | — | [CITE] | disputable, no source, not our data |

## Prioritized Fixes
1. **[Overclaim — Protected]** Claim 2: change "causes" → "is associated with" (smith2021 reports association). Needs author approval — verb change on a spine source.
2. **[Overclaim — scope]** Claim 5: restrict to "in freshwater systems (jones2019)" or cite a leachate source. MANUSCRIPT_MAP flags jones2019 as NOT a leachate benchmark.
3. **[Uncited]** Claim 7: locate a source for chain-length scaling, or reframe as our own observation if Results support it. Left as [CITE] — not invented.
4. **[Number]** Claim 6: confirm 70 ng/L against epa2016 p.X; resolve [VALUE — verify].
5. **[Novelty]** Claim 3: either show the comparison that establishes "first," or soften to "to our knowledge."

## Gaps in the library
- No source on chain-length scaling (Claim 7) — sources/ has nothing on this.
```

End with the calibrated gap count: `(supported / overstated / uncited)`. Never report a section "clean" while `[CITE]` or `[VALUE — verify]` markers remain — surface them.

## Pairs With

- **`citation-gate.sh`** (PostToolUse) — proves cite keys resolve; run it first so claim-check is not chasing dangling keys. claim-check is the deeper, source-reading layer it cannot reach.
- **`fact-checker` agent** — delegate Phase 4 source-reading for a long section: dispatch it to verify a batch of cited claims against `sources/`, then fold its findings into the table.
- **`block-fabrication.sh`** (PreToolUse) — if you try to "fix" an uncited claim by writing a stub `.bib` entry, this hook blocks it. That is the system working: flag `[CITE]`, do not fabricate.
- **`/citation-audit`** — run after claim-check if you touched the bibliography, for the structural `.bib` health pass.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "It's obviously true, no cite needed" | Obvious-to-you is not common-knowledge-for-this-audience. Cite it or it's UNSUPPORTED. |
| "I'll find a citation for this later" | Drafting around a citation you intend to find later is how fabrications enter. Flag `[CITE]` now. |
| "The source basically says this" | "Basically" is where overclaim lives. The verb and quantifier must match, not the gist. |
| "It's my result, so I can state it strongly" | Your sample does not license "in general." Calibrate the quantifier to what you measured. |
| "Reviewer won't check this one" | Reviewer 2 checks exactly the sentence you hoped they'd skip. Assume every claim is read adversarially. |

## Notes

- This skill never writes a citation. Its only sourcing output is `[CITE]` / `[VALUE — verify]` placeholders — honest flags, per the cardinal rule in `CLAUDE.md`.
- Verb/quantifier calibration is judgment work — run it on the Reasoner model (see `CLAUDE.md → Model Selection`).
- Log a recurring overclaim pattern ("you keep using causal verbs in the discussion") to `tasks/reviews/` so it becomes a rule, not a one-off fix.
