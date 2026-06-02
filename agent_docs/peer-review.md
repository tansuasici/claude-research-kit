# Peer-Review Simulation & Response

Two jobs, both expanded here: (1) **simulate** peer review to find the holes before a
real reviewer does, and (2) **respond** to a real review so every point is addressed,
honestly, in the language editors expect. Read this before internal review, before any
task the prompt-router flags as `[Reviewer response]`, and whenever you handle a
referee report.

The kit ships a `peer-reviewer` sub-agent (`.claude/agents/peer-reviewer.md`,
Reasoner/Opus). This doc is how *you* drive it and what to do with its output.

---

## Simulating review — the Reviewer-2 mindset

Reviewer 2 is the tough-but-fair referee who reads a junior author's submission and
finds the holes the author cannot see. Adopt the stance before submission:

- **Evidence-bound, never inventing.** A simulated reviewer flags a gap; it does **not**
  supply a citation or statistic to "fix" it. If a cited source is not in
  `references.bib` / `sources/`, the support is *unverifiable* — not right, not wrong
  (`.claude/agents/peer-reviewer.md`).
- **Quote before you criticize.** Every issue points at a specific sentence + locator.
  "The discussion overclaims" is useless; "Discussion ¶3: 'eliminates hallucinated tool
  calls' — causal+general from one agent harness" is actionable.
- **Find the load-bearing inference.** Locate the single claim the paper stands on and
  test whether the evidence licenses it. A broken *central* claim is Major revision at
  best — never escalate a calibration nit to a reject, never demote a broken thesis to
  "minor."
- **Calibrate the verdict.** Distinguish "wrong" from "unsupported as written" from
  "unverifiable here." An invented/misattributed citation ⇒ never Accept until resolved.

### How to run it

```text
Dispatch the peer-reviewer sub-agent on sections/discussion.tex (+ abstract).
```

It reads `MANUSCRIPT_MAP.md → Thesis / Contribution / Audience`, reviews against the
contribution *you claim* (not one it invents), and returns Summary → Major Issues →
Minor Issues → Recommendation, each issue with a quote/locator and a required fix. It
writes a ≤5-line handoff to `.hook-state/agent-handoff.md`.

Run it section-by-section (one clean review beats a sprawling one), in a separate
context so the critique does not pollute the drafting thread, and *before* you call a
section done — it is the human-judgment half of verification steps 2–4 that no hook can
perform.

### The review lens (what to interrogate)

| Lens | The question |
|---|---|
| Novelty & contribution | Is the contribution explicit and actually new vs. cited prior work — or a restatement? Is the "gap" real or manufactured by ignoring literature? |
| Soundness | Does each claim follow from what precedes it? Any conclusion with no supporting result? |
| Claim ↔ evidence | Does the cited evidence license the **verb and quantifier**? "causes" on observational data; "in general" from one sample; "proves" from "suggests"? |
| Methods rigor | Reproducible from Methods alone? Confounders, controls? Stats carry effect size + uncertainty, not a bare p? |
| Limitations honesty | Are the real threats named — or buried, softened, absent? |
| Structure (IMRaD) | Results report without interpreting; Discussion interpret without new data; Abstract faithful to body? |

---

## Reading a critique charitably

A real review arrives. Before responding, read it *for the strongest version* of each
point — the charitable reading is also the most useful one.

1. **Assume the reviewer is right until proven otherwise.** Even a misreading usually
   signals a real ambiguity in *your* text — if the expert misread it, a reader will.
   The fix is often to clarify, even when you were "technically correct."
2. **Translate tone into substance.** Strip the curtness; extract the technical ask.
   "The authors seem unaware of the entire self-correction literature" → "cite and position
   against prior self-correction work."
3. **Separate disagreement from misunderstanding.** Some points you fix; some you
   clarify; a few you respectfully rebut with evidence. All three are legitimate — a
   blanket "we agree and have changed X" to a point you actually dispute is dishonest.
4. **Cluster duplicate concerns.** Two reviewers flagging the same overclaim is one
   root issue — fix it once, reference the fix in both responses.

---

## The response-letter protocol

The response letter is itself a document the editor scores. Five non-negotiables
(`prompt-router → [Reviewer response]`):

1. **Quote the reviewer's point** verbatim before responding to it. No paraphrase that
   softens the ask.
2. **State the change** concretely — what you did, not "we have addressed this."
3. **Give the location** — section, page, line, or the revised text quoted — so the
   editor can verify without hunting.
4. **Stay courteous**, even when rebutting. "We thank the reviewer; we respectfully
   disagree, because…" beats defensiveness.
5. **Never claim a change you have not made.** This is the cardinal rule applied to the
   letter: a response asserting an edit that is not in the manuscript is a fabrication,
   and the editor *will* check. If you say "changed," the change must be in the revision.

### Per-point template

```markdown
> **Reviewer 2, Comment 3:** "The claim that the method eliminates hallucinated tool
> calls in general is not supported; the data are from a single agent harness."

**Response.** We agree and have removed the overclaim. The sentence now reads:
"the verification gate reduced the hallucinated tool-call rate by >40% on multi-turn
agentic tasks (Table 2)," with no extrapolation beyond the tested harness. We added a
limitation noting that transfer to other harnesses remains untested.
**Changes:** Discussion ¶2 (p. 8, lines 211–215); new limitation, p. 9, lines 240–243.
```

For a point you rebut:

```markdown
> **Reviewer 1, Comment 5:** "A baseline without the gate is missing."

**Response.** We respectfully note the no-gate baseline is reported in Methods
(§2.3, p. 4) and plotted as the open series in Figure 3. We have revised the caption
to label it explicitly ("baseline, no gate") to remove the ambiguity.
**Changes:** Figure 3 caption (p. 6).
```

Even a rebuttal usually ends in a *change* (a clarification) — because if the reviewer
missed it, the text was unclear.

### Coverage discipline

- **Every** numbered point gets a response — none skipped, none merged-away silently.
- Open the letter with a brief, genuine thank-you and a one-paragraph summary of the
  major changes; then go point by point in the reviewers' numbering.
- If a requested change would alter the **thesis, a reported quantity, the methods, an
  argument-carrying citation, or the scope**, it is a **Protected Claim** — get the
  author's approval before making it (`CLAUDE.md`), and record the call in
  `tasks/decisions.md`.

---

## Major vs minor revision

Match the response effort and the recommendation logic to the severity
(`.claude/agents/peer-reviewer.md → decision discipline`):

| Verdict | Means | Your response posture |
|---|---|---|
| **Accept** | Ready as-is. | Rare. Do not over-edit. |
| **Minor revision** | Sound; calibration nits, missing locators, clarity, formatting. | Fix each precisely; quick turnaround. |
| **Major revision** | A central claim is unsupported as written, a method is non-reproducible, or a limitation is missing. | Substantive: re-run analyses, add evidence, re-calibrate claims, possibly re-frame the contribution. Do not paper over with wording. |
| **Reject** | The contribution does not hold, or an invented/misattributed citation is unresolved. | Reframe or redirect; do not resubmit unchanged. |

A paper with an unsupported *central* claim is never "minor" — the recommendation must
follow from the issue list, not from optimism.

---

## Logging recurring critiques

Peer-review feedback is the kit's richest source of durable rules
(`CLAUDE.md → Self-Improvement Loop`).

- After **any** review (simulated or real), log each substantive critique under
  `tasks/reviews/` using `tasks/reviews/_TEMPLATE.md` — file `<YYYY-MM-DD>-<slug>.md`,
  frontmatter + **Feedback → Root Cause → Rule**.
- Tag `applies_to:` with the lens: `overclaim`, `citation`, `methods`, `statistics`,
  `structure`, `scope`, `reviewer-response`, `figures`, `reproducibility`.
- **Promote recurring critiques** to `tasks/reviews/_index.md → ## Top Rules`
  (`top_rule: true`). Read the Top Rules at every session start (Tier 3) and after
  compaction — a reviewer's *repeated* complaint ("you keep overclaiming the
  Discussion", "you keep citing single-turn QA results for multi-turn agentic claims") is a rule, not a
  one-off fix. Encode it so the next draft does not re-earn the same comment.

The point of logging is that the *second* version of the paper, and the *next* paper,
do not reproduce the critique. A review you fixed but did not encode will return.
