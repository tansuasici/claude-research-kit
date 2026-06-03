---
name: retro
description: Windowed retrospective on the writing process — what shipped (sections drafted, commits over the window), recurring reviewer critiques (tasks/reviews/ by applies_to frequency), what was learned (journal findings folded into handoffs), and what is still open (tasks/todo.md). Saves a timestamped retro to tasks/ as persistent history. Process, not telemetry.
user-invocable: true
---

# Retro

## Core Rule

A retrospective answers four questions over a window of time: **what shipped, what keeps going wrong, what was learned, and what is still open.** It is *process* reflection — the narrative `/scorecard`'s numbers cannot give you. Where scorecard says "citation-gate failed 14 times," retro says "the failures cluster in the Discussion, where I keep drafting claims before the source is in `references.bib` — that is the same root cause Reviewer 2 flagged twice; encode it as a Top Rule."

The retro's most valuable output is the **recurring-critique scan**: the patterns to fix, ranked by how often a reviewer has hit them. A one-off critique is a fix; a *recurring* one is a rule (`CLAUDE.md → Self-Improvement Loop`). Retro is how those rules get surfaced and promoted. It is honest, not flattering — a retro that lists only wins is broken.

## When to Use

Invoke with `/retro` when:

- Closing out a working week or a manuscript milestone (a section finished, a draft sent to a co-author, a revision returned).
- After a `/scorecard` shows a trend you want to *understand and act on*, not just observe.
- Before a heavy revision push — to load the recurring reviewer critiques into context so you do not re-make the same mistakes in the new prose.
- Whenever the same correction has come back more than once and you want it encoded as a rule rather than re-explained.

Scope the window with an argument: `/retro` defaults to the last 7 days; `/retro 14` or `/retro since 2026-05-20` widens it. Keep the window tight enough that "what shipped" is concrete — a month-long retro blurs the specifics that make the patterns legible.

## Process

### Phase 0 — Set the window
1. Resolve the window (default last 7 days). Everything below is filtered to it.
2. Optionally run **`/scorecard`** first (or read its last output) so the retro is anchored on hard numbers — pass rates, hook firings, bypasses. Retro *interprets*; scorecard *measures*.

### Phase 1 — What shipped
3. Run `git log --since=<window> --oneline --stat` (and `git diff --stat <window-start>..HEAD` if useful) to see commits, sections touched, and rough volume. Read it through the manuscript's lens: which **arguments** advanced, not just which files changed.
4. Cross-check against `MANUSCRIPT_MAP.md → Structure` — which sections moved from not-started → drafted → review-ready over the window. Name the arguments that got established, not the line counts.
5. Note what shipped *clean* vs what shipped with `[CITE]` / `[VALUE — verify]` placeholders still embedded — a drafted-but-unsourced section is not "shipped," it is parked. Report it honestly per `CLAUDE.md → Verification` step 7: `(sourced / placeholder / unverified)`.

### Phase 2 — Recurring reviewer critiques (the heart of it)
6. Scan `tasks/reviews/` — the reviewer-feedback notes added per `CLAUDE.md → Self-Improvement Loop`. For each, read the frontmatter `applies_to` topics (`citation`, `overclaim`, `structure`, `voice`, `methods`, `statistics`, `figures`, `scope`, `reviewer-response`, `formatting`, `reproducibility`).
7. **Tally by `applies_to` frequency** across the reviews — which topics recur most. A topic that appears in three review files is a *pattern*, not three incidents. This frequency ranking is the prioritized list of habits to fix.
8. Cross-reference `tasks/reviews/_index.md → ## Top Rules`: is each high-frequency topic already promoted to a Top Rule? If a topic recurs but is **not** yet a Top Rule, that is the retro's key recommendation — promote it (set `top_rule: true` and add it to the index). If it *is* a Top Rule and still recurring, the rule exists but is not being followed — name that gap.
9. For the current writing focus, **`/review-resurface "<what you are working on>"`** can pull the dormant reviewer notes whose `applies_to` matches — pointers to the specific rules most likely to bite the work ahead, without loading every review body.

### Phase 3 — What was learned
10. Read the `## Journal` blocks that `journal-fold.sh` folded into the window's `tasks/handoff-*.md` files — the `[finding]` and `[decision]` lines journaled with `/note` during those sessions. These are the session-level discoveries (a source's real scope, a notation decision, a compile gotcha). Surface the ones that generalize beyond their session.
11. A finding that recurs, or that cost real effort, is a candidate to **encode**: into `STYLE.md`, into `MANUSCRIPT_MAP.md → Claims that need extra care`, or as a fresh `tasks/reviews/` note. Learning that stays in a handoff is forgotten by the session after next — promote it.

### Phase 4 — What is still open
12. Read `tasks/todo.md` — active tasks and the `## Not Now` parking lot. List what remains, flagging anything blocked (e.g. waiting on a co-author's data, a source not yet in the library).
13. Note open items that have been open across *several* windows — a task that never moves is either mis-scoped or quietly abandoned; surface it for a decision.

### Phase 5 — Write it down
14. Assemble the retro and **save it to `tasks/retro-<YYYY-MM-DD>.md`** (timestamped, so retros accumulate as a process timeline — distinct from `/scorecard`, which is regenerated, not archived). The persistent history is the point: next retro can compare against this one and see whether a flagged pattern actually got fixed.

## Output Format

Save to `tasks/retro-<YYYY-MM-DD>.md` and echo a brief version to the user:

```markdown
# Retro — 2026-05-27 → 2026-06-03

## What shipped
- Drafted Introduction (review-ready) and Methods §2 (sourced, clean).
- Results §3.2 drafted but **parked**: 2 [VALUE — verify] in Table 2 — (sourced 14 / placeholder 2 / unverified 0).
- 11 commits; the contribution claim in the Intro is now established with 3 cited sources.

## Recurring critiques (tasks/reviews/, by applies_to)
| Topic | Reviews | Top Rule? | Read |
|---|---|---|---|
| overclaim | 3 | yes | causal verbs still creeping into Discussion despite the rule |
| citation | 2 | yes | drafting ahead of references.bib — same root cause as the gate failures |
| statistics | 2 | **no** | → PROMOTE: N + test + effect size missing twice; not yet a Top Rule |
| structure | 1 | no | one-off, leave |

**Action:** promote `statistics` to a Top Rule (set top_rule:true, add to _index.md).

## What was learned (folded /note findings)
- finding: tooluse2023 is single-turn QA — must not back multi-turn agent claims. → encode in MANUSCRIPT_MAP "Claims that need extra care".
- decision: standardized on "tool-call accuracy" project-wide (one term per concept).

## Still open (tasks/todo.md)
- [ ] Source the horizon-scaling claim in Discussion (open 2 windows — decide: find source or cut).
- [ ] Co-author to supply the ablation numbers for Table 3 (blocked).
- (Not Now: reframe limitations as future work.)

## For next window
1. Fix the recurring overclaim in Discussion — the rule exists; follow it.
2. Gather Results evidence before drafting (close the citation-gate failure cluster).
3. Promote the statistics rule; resolve the 2 parked [VALUE — verify].
```

## Pairs With

- **`/scorecard`** — the numbers behind the narrative. Scorecard counts citation-gate failures and bypasses; retro explains *why* they happened and what to change. Run scorecard first; retro consumes its output.
- **`/review-resurface "<task>"`** — pulls the dormant reviewer rules (pointers only) relevant to the work ahead, so Phase 2's recurring-critique scan can target what is about to bite.
- **`tasks/reviews/`** + **`tasks/reviews/_index.md`** — the source for the recurring-critique scan and the destination for promoted Top Rules. Retro is the loop that turns repeated critiques into rules (`CLAUDE.md → Self-Improvement Loop`).
- **`journal-fold.sh`** / **`/note`** — supply the "what was learned" material: findings/decisions journaled mid-session and folded into the window's handoffs.
- **`tasks/todo.md`** — the open-items source for Phase 4.

## Notes

- Retro is **process, scorecard is telemetry, `/project-health-report`-style sweeps are whole-project.** Keep the lanes clean: retro does not recompute pass rates (cite scorecard), and it does not re-audit the bibliography (cite `/citation-audit`).
- The recurring-critique frequency tally is the highest-leverage output — it is how a one-off correction becomes an encoded rule instead of a mistake you make a fourth time. Do not skip Phase 2 to save time.
- Retro reports and recommends; it does **not** silently edit the manuscript. Promoting a Top Rule (editing `_index.md`) or encoding a finding into `STYLE.md` is fine; rewriting a claim is a Protected Claim and needs author sign-off (`CLAUDE.md → Protected Claims`).
- `headless`-friendly (`mode:headless`): in an unattended run, `/retro` produces the saved `tasks/retro-<date>.md` autonomously — but flag (do not auto-apply) any Protected-Claim-adjacent recommendation for the author to confirm.
- Honesty over comfort: a retro that surfaces no recurring critique and no parked placeholder, on a window where real drafting happened, is probably not looking hard enough. The point is to find the pattern, not to pass.
