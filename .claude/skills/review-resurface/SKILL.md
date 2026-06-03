---
name: review-resurface
description: Surface dormant reviewer-feedback notes from tasks/reviews/ (and _archive/) whose applies_to topics match the current task, returning POINTERS ONLY — paths plus frontmatter, never bodies. Recovers a past reviewer rule relevant to the work at hand without bloating Tier-1 boot. Delegates the deterministic scan and scoring to scripts/review-resurface.sh.
user-invocable: true
---

# Review Resurface

## Core Rule

The kit's compounding memory lives in `tasks/reviews/` — every correction from the author or a referee, as a note (`CLAUDE.md → Self-Improvement Loop`). But only the highest-leverage handful are promoted to `_index.md → ## Top Rules` and read at every session boot. The rest go **dormant**: still true, still worth obeying, but not in context — and rightly so, because loading every review at boot would bloat Tier 1 and drown the active task.

`/review-resurface` recovers exactly the dormant rules that match what you are about to do. You are revising the Discussion; somewhere in `tasks/reviews/` is the note "you keep overclaiming in the discussion" that never made Top Rules — this surfaces it, *now*, when it is about to bite, and stays silent the rest of the time.

The contract is **pointers only**: paths plus frontmatter (`applies_to`, `title`, `date`), **never the bodies**. The skill tells you a relevant rule *exists and where*; **you** decide which to Read. This is deliberate — pulling N full review bodies into context to find the one that matters defeats the purpose. The agent reads selectively; the scan does not pre-load.

## When to Use

Invoke with `/review-resurface "<task summary>"` when:

- Starting work on a section a reviewer has historically flagged — before drafting, recover the rule so you do not re-earn the critique.
- A `/retro` is scanning recurring critiques and wants the dormant notes relevant to the upcoming focus.
- After a compaction, to re-surface the reviewer rules for the current task without re-reading the whole `tasks/reviews/` tree.
- Any time you think "haven't I been told something about this before?" — that instinct is what this skill answers.

Write the `<task summary>` in the **vocabulary of the manuscript**: the section, the claim type, the operation. "revising the discussion, tightening causal claims about agent tool-use" matches better than "fixing some sentences." Matching is by `applies_to` topic overlap — name the topics, even implicitly (mentioning "overclaim", "stats", "scope", "voice", "structure" lands the hit).

## Process

1. Frame the task in one line, in manuscript vocabulary (see above). This string is the entire query — its words are what the scan matches against the reviews' `applies_to` topics.
2. Run the backing script (the deterministic scan and scoring are *not* the model's job — `CLAUDE.md → Model vs Code`):
   ```bash
   ./scripts/review-resurface.sh "<task summary>"
   ```
   What it does, deterministically:
   - Lists `tasks/reviews/*.md` **and** `tasks/reviews/_archive/*.md` (so superseded/archived rules are recoverable too), skipping `_TEMPLATE.md` and `_index.md`.
   - Builds the `applies_to` vocabulary across all reviews and matches your task string (case-insensitive) against it.
   - **Scores** each review: **+3 per `applies_to` topic that hits**, **+1 if `top_rule: true`**. Sorts descending.
   - Emits the **top 5** as pointers — path (project-relative), `applies_to`, `date`, `title` — and a count of any further matches not shown.
3. Read the printed pointers. **Decide which, if any, to `Read`** — the bodies (Feedback → Root Cause → Rule) were intentionally not loaded. Pull only the rule(s) that bear on the task; ignore a weak/tangential match.
4. Apply the recovered rule to the work. If a resurfaced critique is recurring and *not* yet a Top Rule, that is a signal to promote it (`CLAUDE.md → Self-Improvement Loop`) — but that is a follow-up action, not part of this scan.

### The no-match cases (both clean, not errors)

- **Vocabulary miss** — your task words overlap no review's `applies_to`: `No matching topics in the reviews applies_to vocabulary; nothing to resurface.` Either there genuinely is no past rule for this, or rephrase the task in topic vocabulary and retry.
- **Topics matched but no review scored** — rare; the script reports it and tells you to proceed with the Top Rules already in context.

Either way the script exits cleanly. A no-match is information ("no dormant rule governs this"), not a failure. (The script exits non-zero only if `tasks/reviews/` does not exist, or no query was supplied.)

### How the ranking works (worked example)

Reading the scores tells you how strongly a pointer matches, so you can decide what to Read. For the query *"revising the discussion, tightening causal claims about agent tool-use"* — which hits the topics `overclaim` and `methods`:

| Review | `applies_to` | top_rule | Score | Why |
|---|---|---|---|---|
| causal-verbs-discussion | `[overclaim, methods]` | true | **7** | both topics hit (+3+3) and it is a Top Rule (+1) |
| generalization-scope | `[scope, overclaim]` | false | **3** | only `overclaim` hits (+3); `scope` not in the query |
| figure-captions | `[figures, formatting]` | false | **0** | no topic overlap — not emitted |

Higher score = more `applies_to` topics overlap (each worth +3), with a +1 nudge for already-promoted Top Rules. A 7 is a near-certain Read; a 3 is a judgment call (one topic in common — relevant only if that topic is your actual focus); a 0 never appears. The Top-Rule +1 is a tiebreaker, not a multiplier — a single-topic non-Top-Rule (3) still outranks nothing, but a two-topic hit (6) always beats a one-topic Top Rule (4).

## Output Format

The script prints the pointers; relay them as-is and add your read decision. Example:

```text
Matched reviewer notes for topics [overclaim, scope]:

1. tasks/reviews/2026-05-19-causal-verbs-discussion.md
   applies_to: [overclaim, methods]
   date: 2026-05-19 | title: Causal verbs in the discussion

2. tasks/reviews/_archive/2026-04-02-generalization-scope.md
   applies_to: [scope, overclaim]
   date: 2026-04-02 | title: Overstated generalization beyond the tested harness

These are pointers, not content. Read any that look relevant; the bodies were intentionally NOT loaded.
```

Then state your decision, e.g.: "Reading #1 — it governs the exact verbs I'm about to write in the Discussion. Skipping #2 (archived; the scope claim isn't in scope for this pass)."

Never paste a review body you have not actually `Read` — and never *summarize from the title* as if you read the rule. The pointer is a filename and frontmatter; the rule is in the file.

## Pairs With

- **`scripts/review-resurface.sh`** — the deterministic engine. The skill is its driver; all scanning, vocabulary-building, and scoring happen there, not in the prompt. Keep the boundary: the script finds candidates, the model judges relevance.
- **`tasks/reviews/`** + **`_archive/`** + **`_index.md`** — the corpus this reads. The Self-Improvement Loop (`CLAUDE.md`) fills it; `_index.md → Top Rules` is the always-on subset; resurface recovers the dormant remainder on demand.
- **`/retro`** — uses resurface in its recurring-critique scan to pull the dormant rules relevant to the upcoming window's focus.
- **`/claim-check`** — a resurfaced overclaim rule is exactly the lens to bring to a claim-check pass; surface the rule first, then run the check with it in mind.
- **`CLAUDE.md → After Compaction`** — pairs naturally: after restoring context, resurface the reviewer rules for the current task without re-reading the whole reviews tree.

## Notes

- **Pointer-only is the contract, not an optimization.** The whole value is recovering a relevant rule *without* loading the bodies of every review. Do not work around it by asking the script for bodies (it does not emit them) or by `Read`-ing all five pointers reflexively — read the one or two that match, which is the point.
- This is **recovery, not boot.** Top Rules are the always-loaded floor (read every session). Resurface is the on-demand layer above it: the rules too specific to keep in Tier 1 but exactly right for *this* task. The two together give full coverage without full cost.
- Match quality tracks your task wording: vague tasks miss, topic-named tasks hit. If you expected a hit and got none, the fix is usually the query, not the corpus — rephrase in `applies_to` vocabulary (`overclaim`, `statistics`, `scope`, `voice`, `structure`, `citation`, …) and retry.
- `headless`-friendly (`mode:headless`): in an unattended pass, run resurface at the top of each section's work to auto-load the relevant dormant rules; in headless mode, `Read` the top-scoring pointer(s) without waiting for a human to choose, since there is no one to ask — but still only the ones that score, never all five.
- The skill never writes — it reads pointers and (optionally) you Read the bodies. Promoting a resurfaced rule to a Top Rule or fixing the manuscript are separate, deliberate actions, not side effects of the scan.
