---
name: note
description: Append a timestamped tagged line (finding / decision / summary) to the session journal at .hook-state/session-journal.md, so a discovered fact, a settled choice, or a transient breadcrumb survives context compaction in a long writing session. Delegates to scripts/note.sh.
user-invocable: true
---

# Note

## Core Rule

A long writing session **will** compact. When it does, the conversation summary keeps the gist and drops the detail — the gotcha you found three hours ago, the reason you picked one framing over another, the exact key you decided not to cite. `/note` is the kit's defense: it writes one timestamped line to a durable-within-the-session journal *before* the detail is at risk, so `CLAUDE.md → After Compaction` can re-read it and restore what the summary lost.

This is **deterministic memory, not judgment** (`CLAUDE.md → Model vs Code`). Do not paraphrase a finding back into the chat and hope it survives — append it. The skill never reasons about the text; it timestamps and stores it. One line, one fact.

## When to Use

Invoke with `/note <tag> <text>` the moment something is worth not re-deriving:

- You discovered a fact or gotcha that cost you effort — a source's real scope, a notation collision, a compile quirk. Tag it `finding`.
- You made a choice with a reason — picked one term for a concept, settled a framing, decided a claim is the author's own and not citeable. Tag it `decision`.
- You want a transient breadcrumb for *this* working block — "left off mid-paragraph in Results §3.2, the CI still needs checking." Tag it `summary`.
- Proactively, when you sense a session is getting long and dense, before compaction takes the detail.

Do **not** use `/note` for things with a permanent home: a settled framing/scope/methods decision belongs in `tasks/decisions.md`; a recurring reviewer critique belongs in `tasks/reviews/`; an open task belongs in `tasks/todo.md`. The journal is short-term working memory, not the archive.

## The Three Tags

| Tag | Means | Survives to handoff? | Example |
|---|---|---|---|
| `finding` | A discovered fact or gotcha — something true you had to work out and don't want to re-derive | **Yes** — folded | `finding tooluse2023 is single-turn QA only; do NOT cite it for multi-turn agent claims` |
| `decision` | A choice made **and why** — the reasoning, so future-you doesn't reopen it | **Yes** — folded | `decision standardize on "tool-call accuracy" (not "success rate") across the draft — one term per concept` |
| `summary` | A transient breadcrumb for the current block — pure "where am I" state | **No** — discarded | `summary mid-rewrite of Discussion ¶2, softening the causal verbs flagged by /claim-check` |

The split is intentional: **findings and decisions are knowledge** worth carrying into the next session; a **summary is scaffolding** that is stale the moment the block is done. `journal-fold.sh` (below) folds the first two and discards summary-only journals — so over-tagging as `summary` silently loses the note. If it would matter tomorrow, it is a `finding` or a `decision`.

## Process

1. Pick the tag honestly against the table above. The tag is the only thing that decides whether the note survives — get it right.
2. Run the backing script (the skill does nothing else):
   ```bash
   ./scripts/note.sh <finding|decision|summary> "<text>"
   ```
   Keep `<text>` to one self-contained line — it must make sense with zero surrounding context, because post-compaction that is exactly the context it gets. Name the artifact it concerns (a `.bib` key, a `.tex` section, a quantity).
3. The script appends `<ISO-timestamp> [<tag>] <text>` to `.hook-state/session-journal.md` (creating the dir + its `.gitignore` on first use) and echoes back the line plus the running entry count.
4. Carry on writing. Do not stop to summarize the journal — it accumulates silently and is read only on demand (after compaction) or folded at session end.

An invalid tag or empty text exits non-zero with usage — fix the tag, do not invent a fourth.

### After compaction — reading the journal back

When you detect a compaction (a conversation summary appears; earlier detail is gone), `CLAUDE.md → After Compaction` step 5 has you **re-read `.hook-state/session-journal.md` if it exists**. That is the payoff for every `/note` you logged this session: the findings and decisions you journaled are still there verbatim, even though the chat summarized them away. Read it before resuming — do not draft on a half-restored context.

### Choosing the tag — worked examples

Tag choice is the load-bearing decision; these settle the common ambiguities:

- *"I just realized `halluc2022` reports a 23% rate, not 32% — I had it backwards."* → `finding`. A corrected fact you must not re-confuse; it has to survive to the next session.
- *"We're going with IEEE style, not APA — the target journal requires it."* → `decision` (the why is the venue requirement). Then promote it to `tasks/decisions.md` if it is a settled manuscript-level choice — the `/note` is the short-term capture, `decisions.md` is the durable home.
- *"Currently rewriting Discussion ¶3 to soften the causal verbs; will re-run `/claim-check` after."* → `summary`. Pure where-am-I state; stale once ¶3 is done. Folding it to handoff would be noise.
- *"latexmk needs `-shell-escape` for the `minted` blocks or the compile-gate fails."* → `finding`. A non-obvious build gotcha worth not rediscovering — exactly what a folded handoff should carry.
- *"Decided the horizon-scaling sentence is the author's own observation, not a citeable claim — Results §3.2 supports it."* → `decision`. A sourcing judgment with a reason; future-you should not reopen it.

The test in every case: *would this matter to a session that starts tomorrow with none of today's chat?* Yes → `finding`/`decision`. Only-right-now → `summary`.

## Output Format

The script reports the appended line and the journal's new size:

```text
Noted: 2026-06-03T14:22:05Z [finding] tooluse2023 is single-turn QA only; do NOT cite it for multi-turn agent claims
→ .hook-state/session-journal.md (4 entries)
```

There is no manuscript output and nothing to commit — the journal is gitignored (same lifetime as the rest of `.hook-state/`). Its only durable trace is what `journal-fold.sh` carries into the handoff.

## Lifecycle — where notes go

- **Within the session:** the journal lives at `.hook-state/session-journal.md`, gitignored, accumulating one line per `/note`. It is the across-compaction memory described above.
- **At session end:** `.claude/hooks/journal-fold.sh` (a SessionEnd hook) reads the journal and **folds `[finding]` and `[decision]` lines into `tasks/handoff-<session-id>.md`** — appending them under a `## Journal` block with per-tag counts, so the next session's Tier-2 boot (`CLAUDE.md → Session Boot`, "read the latest `tasks/handoff-*.md`") inherits them. **`[summary]`-only journals are discarded** — a journal with no findings or decisions is deleted unfolded. Then the journal is cleared so the next session starts clean.

So a `finding` is a promise that survives twice — across compaction (re-read) and across sessions (folded to handoff). A `summary` survives neither; it is honestly transient.

## Pairs With

- **`.claude/hooks/journal-fold.sh`** (SessionEnd) — the consumer: folds findings + decisions into the handoff, discards summary-only. Runs alongside `session-end.sh` (the `/scorecard` audit hook).
- **`CLAUDE.md → After Compaction`** — the reader: step 5 re-reads the journal to recover pre-compaction findings. `/note` exists so that step has something to recover.
- **`tasks/handoff-*.md`** — the destination for folded findings/decisions; read at session boot when continuing work.
- **`tasks/decisions.md`** — for a *durable, manuscript-level* decision (framing, scope, methods, an approved Protected Claim). A `/note decision` is its short-term cousin; promote it here if it will outlive the session.
- **`/retro`** — reads the folded journal findings out of the handoffs when assembling the "what was learned" section of a windowed retrospective.

## Notes

- One fact per note. Two findings in one line means one of them gets lost when you skim the journal post-compaction.
- Write the note as if the reader has no memory of this session — because after compaction, they don't.
- This is a `headless`-friendly operation (`mode:headless`): in an unattended pass, journaling each non-obvious finding/decision as you go is how an autonomous run leaves a trail the next session can pick up — there is no human watching the chat to remember it for you.
- The journal is **append-only** through this skill; there is no `/note` edit or delete. A superseded note is corrected by adding a newer one, not by rewriting history — the timestamps are the record.
- Tagging discipline is the whole game: the difference between "carried to the next session" and "silently dropped" is one word. When unsure whether something is durable, tag it `finding` or `decision` — folding a slightly-too-trivial note costs nothing; losing a load-bearing one costs a re-derivation.
