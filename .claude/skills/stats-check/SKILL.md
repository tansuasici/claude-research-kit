---
name: stats-check
description: Run the agent_docs/statistics.md checklist over a Results section — flag bare p-values, missing N/effect-size/CI, causal overclaim on observational data, multiple-comparison issues, and numbers that disagree across text/tables/abstract
user-invocable: true
---

# Stats Check

## Core Rule

Every statistical claim must report **effect size + uncertainty (a CI), N, the named test,
and whether its assumptions hold**. "Significant" means *statistically* significant — never
"large" or "important". **Association is not causation**: correlational/observational designs
license "associated with / predicts", never "causes / drives / improves". And no
p-hacking / HARKing / selective reporting — the analysis you report is the analysis you
pre-specified, with exploratory results labeled exploratory. A bare p-value, a missing N, a
causal verb on an ablation, or a number that disagrees between the abstract and Table 2 are
the failures this skill exists to catch.

This is the deterministic, numbers-and-design half of verification, operationalizing
`agent_docs/statistics.md`. It **flags and proposes fixes — it does not change a reported
quantity** (a Protected Claim per `CLAUDE.md`); recomputing a number to reconcile text and
table is fine, *altering what was measured or which test was run* is not.

## When to Use

Invoke with `/stats-check` when:

- A Results section with statistics is "done" and you want it Reviewer-2-proof.
- A revision added or changed a number, test, or comparison.
- Before submission, on Results + the abstract + every table — the consistency check needs
  all three open at once.
- The prompt-router flagged the task `[Statistics]` or `[Causation]`.

Scope it: `/stats-check sections/results.tex`. Run the whole Results section *with its tables
and the abstract* in view — half the findings are cross-location number mismatches.

## Process

### Phase 1: Load the Checklist and the Numbers

1. **Read `agent_docs/statistics.md`** — the reporting checklist this skill runs. It is the
   source of truth; this skill is its executor.
2. **Read the target Results `.tex`**, plus every **table/figure** it summarizes and the
   **abstract**. Numbers must agree across all three (`statistics.md → text ↔ tables ↔
   abstract`); you cannot check consistency with only one open.
3. **Read `MANUSCRIPT_MAP.md`** — the **Data & reproducibility** line (was the design an RCT,
   an ablation, an observational comparison? — this decides what causal language is licensed)
   and **Claims that need extra care**.
4. For ML/agents work, **read `agent_docs/field/ai-ml.md`** — variance over seeds/rollouts,
   matched-budget comparison, and partial-vs-full success are field-specific statistics
   expectations.

If a number's *test* or *assumptions* are not stated and you cannot tell which was run, that
is a finding — do not infer the test. Which test was run is a Protected Claim; ask the author.

### Phase 2: Find Every Statistical Claim

Walk the section and extract each quantitative comparison or inferential statistic: every
p-value, CI, effect size, mean difference, correlation, regression coefficient, percentage,
ratio, and "significant"/"more"/"better" comparison. Record for each: the **point estimate**,
the **uncertainty** (CI/SE/SD, or none), the **N**, the **named test** (or none), the
**verb** (causes / is associated with / predicts), and the **scope** (which harness, which
task set, all vs subset).

### Phase 3: Check Each Claim Against the Checklist

Run every claim through `agent_docs/statistics.md`:

1. **Effect size + uncertainty, not just p.** A bare "p < 0.05" with no magnitude and no CI
   is **incomplete** — the reportable triplet is point estimate · interval · test (with N).
2. **"Significant" used correctly.** Flag "significant" deployed as a synonym for large /
   important / meaningful. Magnitude needs a *number*, stated separately.
3. **N, test, assumptions stated.** N for *that comparison* (not the study total); the test
   named; assumptions addressed (normality/variance for a t-test; linearity for Pearson r) and
   what was done if violated.
4. **Multiple comparisons.** A family of tests needs a correction (Bonferroni/Holm/BH-FDR) or
   a justification; all tests run must be disclosed, not just the winners. A subgroup
   "significant" after many slices is a hypothesis, not a finding.
5. **Causation vs association.** Check the verb against the **design** (Phase 1). A causal verb
   ("causes / drives / improves / the effect of") on a correlational comparison or an
   uncontrolled ablation is **OVERCLAIM**. RCT licenses causation within its population; a
   natural experiment does conditionally with the identifying assumption stated.
6. **p-hacking / HARKing signals.** Outcomes in Methods that vanish in Results (or appear in
   Results unannounced); p-values clustered just under 0.05; "trending toward significance";
   post-hoc results framed as a-priori hypotheses; undisclosed exclusions or optional stopping.
7. **Significant digits & units.** False precision ("94.732%" off a ±1% estimate); the last
   digit should be the first uncertain one; units present and consistent; **percentage points
   ≠ percent** (a 70→88 rise is 18 pp, ~26% relative).
8. **Cross-location consistency.** Recompute: every number matches across text, tables,
   figures, and abstract; N is the same everywhere; totals add up; derived numbers (a
   difference, ratio, percent change) recompute from the reported inputs.

### Phase 4: Report Findings and Fixes

Produce the findings table (claim → issue → fix), severity-ordered. The fix says what the
*author* must do. **Do not edit reported quantities here** — flag the mismatch, propose the
calibration. Reconciling a text number to a table (a clerical correction) can be proposed;
changing what was measured or which test was run is a Protected Claim needing sign-off.

## Output Format

```markdown
# Stats Check — sections/results.tex

## Summary
- Statistical claims examined: 12
- Clean: 6
- Issues: 6  (2 causal overclaim · 1 bare-p · 1 missing-N · 1 mult-comparison · 1 cross-location mismatch)

## Findings (claim → issue → fix)
| # | Locator | Claim (quoted) | Issue | Fix (author action) |
|---|---|---|---|---|
| 1 | res ¶2 | "the gate caused an 18-pp gain in tool-call accuracy" | Causal verb on an uncontrolled ablation (MANUSCRIPT_MAP: not an RCT) | Soften to "was associated with an 18-pp gain"; or justify a causal design |
| 2 | res ¶3 | "tool-call accuracy was significantly higher (p = 0.03)" | Bare p; no effect size, no CI | Add point estimate + 95% CI + named test + N: "X pp (95% CI a–b; two-sample t-test, n = …)" |
| 3 | res ¶3 | "the gate reduced hallucinated tool calls (p = 0.02)" | N not stated for this comparison | State N for the comparison |
| 4 | res ¶5 | "the gate helped on 3 of 8 task subsets" | 8 subgroup tests, no correction, winners only | Report all 8; apply BH-FDR or justify; label exploratory if post-hoc |
| 5 | res ¶2 vs Table 2 | "21% → 6%" in text; Table 2 shows "21% → 8%" | Cross-location number mismatch | Reconcile to the real value; fix everywhere at once (Protected — confirm which is correct) |
| 6 | res ¶4 | "a significant improvement" | "significant" as a synonym for large | Give the magnitude with a number; reserve "significant" for the test result |

## Causation flags (design vs verb)
- Design per MANUSCRIPT_MAP: ablation comparison (not randomized at the unit of inference).
- Licensed: "associated with", "predicts", "co-occurs with". NOT: "causes", "drives", "the effect of".
- Finding 1 violates this — highest priority.

## Cross-location consistency
- Hallucinated-call rate: text 6% vs Table 2 8% — MISMATCH (finding 5).
- N: text "512 tasks" vs Methods "512 held-out" — consistent.
- 18-pp gain recomputes from Table 2 (39% → 57%) — OK.

## Notes for the author
- Findings 1, 5 are Protected (causal claim / changed number) — need your sign-off, not a silent edit.
- Confirm which test produced each p-value; I did not infer any (that would change what was reported).
```

End with the tally `(clean / issues)` and a one-line worst-risk. Never report a Results
section "clean" while a bare p-value, a causal overclaim, or a cross-location mismatch stands.

## Pairs With

- **`agent_docs/statistics.md`** — the checklist this skill executes; read it first, it is the
  authority for every rule above.
- **`integrity-reviewer` agent** — escalate when the signals look like patterned
  selective-reporting/HARKing across the whole manuscript, not isolated reporting gaps; it
  scans breadth, `/stats-check` verifies each number.
- **`/claim-check`** — run alongside: claim-check verifies verbs against *cited sources*,
  stats-check verifies numbers against *the data and the design*. Together they cover claims +
  quantities.
- **`citation-gate.sh`** (PostToolUse) — orthogonal (it checks `\cite` resolution), but run it
  so the Results section is structurally clean before the numerical pass.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "p < 0.05 is the result; the effect size is obvious from the means" | A bare p hides magnitude and precision. Report the estimate + CI explicitly; do not make the reader reconstruct it. |
| "It's a significant improvement" | "significant" ≠ large. State the magnitude with a number; keep "significant" for the test. |
| "The gate improved accuracy" (from an ablation) | "improved" smuggles causation. An uncontrolled ablation licenses "was associated with". Match the verb to the design. |
| "I only report the comparisons that worked" | Reporting winners only is selective reporting. Disclose every test run; correct for the family. |
| "The abstract says 92%, the table says 89%, close enough" | A cross-location mismatch is a hard finding. The same quantity reads the same everywhere — recompute, do not eyeball. |
| "I'll just change the number to match" | Reconciling a clerical typo is fine; changing what was measured is a Protected Claim. Flag it, get sign-off. |

## Notes

- This skill never invents a number, a test, or an assumption. A missing value is
  `[VALUE — verify]`; an unknown test is a question for the author — per the cardinal rule in
  `CLAUDE.md`.
- Causation-vs-association and selective-reporting judgments are Reasoner-tier
  (`CLAUDE.md → Model Selection`); the cross-location number-matching is deterministic —
  recompute, do not estimate (`CLAUDE.md → Model vs Code`).
- A recurring statistics slip (the author keeps correcting "significant", or bare p-values) is
  a rule — log under `tasks/reviews/`, `applies_to: [statistics]`, promote to `## Top Rules`
  if it recurs (`CLAUDE.md → Self-Improvement Loop`).
