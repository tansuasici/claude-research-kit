---
name: scorecard
description: Aggregate reports/session-audit.log (one JSON line per session, written by the SessionEnd hook) into a per-session table plus a windowed summary — citation-gate pass rate, which guardrail hooks fired, SKIP_QUALITY_GATE bypasses, and session durations. Pure telemetry; flags trends, does not judge process.
user-invocable: true
---

# Scorecard

## Core Rule

Scorecard reports **numbers, not narrative**. It reads the audit log the `session-end.sh` hook writes — one JSON line per session — and arithmetic-aggregates it: how often the citation-gate ran versus failed, which guardrail hooks fired, how many times `SKIP_QUALITY_GATE=1` was used, how long sessions ran. It does **not** read your prose, judge your decisions, or recommend process changes. That is `/retro`. Scorecard is the instrument panel; the interpretation lives elsewhere.

Per `CLAUDE.md → Model vs Code`, aggregating a JSONL telemetry log is deterministic — count, sum, divide. Do not estimate a pass rate from memory; compute it from the log. The model's only judgment here is **trend flagging**: noticing that citation-gate failures are climbing week over week is a signal worth surfacing, but the underlying counts must be exact.

## When to Use

Invoke with `/scorecard` when:

- You want a quick health read on the writing process — "are the gates passing, or am I fighting them?"
- A `/retro` is about to run and wants the hard telemetry to anchor its qualitative review.
- Citation-gate failures *feel* frequent and you want to confirm with numbers whether you are drafting ahead of your evidence.
- You suspect `SKIP_QUALITY_GATE` is being reached for too readily — the log counts every bypass.
- Periodically, to watch the guardrail-firing mix drift over a project's life.

Scope the window with an argument: `/scorecard` defaults to the last ~10 sessions; `/scorecard 30` widens it; `/scorecard all` reads the whole log. A wider window smooths noise but blurs a recent regression — default narrow, widen to confirm a trend.

## The Data Source

Every session, `.claude/hooks/session-end.sh` appends one JSON object to `reports/session-audit.log` (gitignored — local telemetry, not a committed artifact). The fields, exactly:

| Field | Type | Meaning |
|---|---|---|
| `session_id` | string | the session identifier (or empty) |
| `ended_at` | ISO-8601 string | when the session ended |
| `duration_seconds` | int or null | wall-clock session length (null if the start was not recorded) |
| `hook_firings` | object | per-hook fire counts this session, e.g. `{"block-fabrication": 2, "protect-sources": 1, "stop-gate": 3}` |
| `citation_gate_runs` | int | times `citation-gate.sh` ran (every `.tex`/`.bib` edit) |
| `citation_gate_failures` | int | of those runs, how many reported a dangling `\cite`/`\ref` |
| `skip_gate_used` | int | times `SKIP_QUALITY_GATE=1` bypassed the stop-gate |

Read these names off the log; do not invent metrics the hook does not emit. If a field is missing or null in a line (older sessions, no start timestamp), treat it as absent — count what is there, note the gap, never fabricate a value to fill a column.

## Process

### Phase 1 — Read the log
1. Locate `reports/session-audit.log`. If it does not exist, report "no sessions audited yet" — the hook writes it at the first SessionEnd; an empty/absent log is a clean no-data state, not an error.
2. Parse it as **JSONL** — one JSON object per line. Skip any malformed line rather than aborting (the log is append-only and best-effort); note how many lines were unparseable.
3. Select the window: the last N sessions (default ~10) by line order, or all.

### Phase 2 — Per-session rows
For each session in the window, emit a row with the load-bearing numbers:
- `citation_gate_failures / citation_gate_runs` and the derived **pass rate** (`(runs − failures) / runs`, shown as a percentage; if `runs == 0`, show `—` — no edits, no rate).
- the `hook_firings` for that session, compacted (e.g. `fab:2 src:1 stop:3`), so a session that tripped a guardrail is visible at a glance.
- `skip_gate_used` — surface any non-zero count prominently; a bypass is the one number a reviewer of the *process* cares about.
- `duration_seconds`, rendered human-readable (e.g. `1h12m`); `—` if null.

### Phase 3 — Windowed summary
Aggregate across the window:
- **Citation-gate pass rate (windowed):** total `(Σruns − Σfailures) / Σruns`. This is the headline number.
- **Hook-firing totals:** sum each hook across sessions — which guardrails fired most. Name them by role so the table is legible: `block-fabrication` (stub/empty-field `.bib` blocked), `protect-sources` (an edit to `sources/` or frozen `submitted/` blocked), `stop-gate` (completion blocked on a failed gate), `citation-gate` (the resolution check itself), `session-start` (boot pointer injection).
- **Total `SKIP_QUALITY_GATE` bypasses** in the window, and in how many distinct sessions.
- **Duration stats:** median and total over the window (skip nulls).

### Phase 4 — Flag trends (the only judgment)
Compare the recent half of the window to the earlier half and flag movement — bounded, factual, no prescriptions:
- **Rising citation-gate failure rate** → you are drafting ahead of your evidence (writing claims whose `\cite` keys are not yet in `references.bib`). The cardinal rule (`CLAUDE.md → Source-Grounded Writing`) says gather evidence *before* drafting; a climbing failure rate is that rule being strained.
- **Rising `block-fabrication` firings** → more attempts to write placeholder/stub `.bib` entries — the system catching fabrication, but a pattern worth naming.
- **Any `skip_gate_used > 0`** → bypasses happened; `SKIP_QUALITY_GATE` is for *unrelated* infra failures only (`CLAUDE.md → Verification`). Surface it for `/retro` to interrogate.
- **`protect-sources` firings** → edits to immutable `sources/` / `submitted/` were attempted; usually benign (blocked as designed), but a spike may mean a workflow is fighting the freeze.

State each flag as the number and its plain reading. Do **not** prescribe a fix — that is `/retro`'s job. Scorecard points at the gauge; it does not turn the wheel.

## Output Format

```markdown
# Scorecard — last 8 sessions (2026-05-27 → 2026-06-03)

## Per-Session
| Session | Ended | Dur | Cite gate (fail/run) | Pass% | Hook firings | Skip |
|---|---|---|---|---|---|---|
| 7f3a… | 06-03 | 1h12m | 1 / 22 | 95% | fab:1 stop:1 | 0 |
| a91c… | 06-02 | 48m   | 4 / 18 | 78% | fab:3 stop:4 | 1 |
| 22de… | 06-01 | 2h05m | 0 / 31 | 100% | src:1 | 0 |
| …     |       |       |        |     |             |   |

## Windowed Summary
- Citation-gate pass rate: **91%** (14 failures / 152 runs)
- Hook firings (total): block-fabrication 7 · stop-gate 9 · protect-sources 2 · citation-gate 152
- SKIP_QUALITY_GATE bypasses: **1** (in 1 session)
- Session duration: median 1h04m · total 9h20m · (1 session had no start timestamp)

## Trends
- ▲ Citation-gate failure rate rose 4% → 22% in the two most recent sessions — drafting is running ahead of the evidence (claims cited before keys exist in references.bib).
- ▲ block-fabrication fired 6 of 7 times in the recent half — more stub-.bib attempts being blocked.
- ⚠ 1 SKIP_QUALITY_GATE bypass — confirm it was an unrelated infra failure, not a silenced gate. (For /retro.)

_(2 log lines unparseable — skipped.)_
```

Keep it compact: a table a human scans in seconds, plus the windowed numbers, plus at most a handful of flags. If the window is clean, say so in one line — no manufactured concern.

## Pairs With

- **`.claude/hooks/session-end.sh`** (SessionEnd) — the producer. Scorecard is the reader of the JSONL it writes; the two are a closed telemetry loop. (`journal-fold.sh` runs at the same SessionEnd but feeds `/note`, not this.)
- **`/retro`** — the qualitative counterpart. Scorecard hands `/retro` the hard numbers (pass rates, bypass counts); `/retro` supplies the *why* and the corrective. Run `/scorecard` first, then `/retro`.
- **`citation-gate.sh` / `stop-gate.sh` / `block-fabrication.sh` / `protect-sources.sh`** — the hooks whose firings this report counts. The scorecard is their aggregate diary.

## Notes

- Scorecard never reads or edits the manuscript, the `.bib`, or `sources/`. It touches one file, read-only: `reports/session-audit.log`. Nothing here can change a claim.
- It is **telemetry, not a verdict**: a 100% pass rate means the gate resolved every `\cite`, not that the prose is true — `citation-gate.sh` proves keys *resolve*, not that sources *license* the claims (that is `/claim-check`). Do not read a green scorecard as "the manuscript is sound."
- `headless`-friendly (`mode:headless`): in an unattended or scheduled run, `/scorecard` is the natural periodic health snapshot — pure numbers, no interaction needed, safe to emit into a log.
- The log is append-only and gitignored; scorecard is a derived view, never a source of truth to commit. Regenerate it any time from the log.
- If two SessionEnd lines share a `session_id` (a resumed session), report both rows and note the duplicate rather than silently merging — the arithmetic should be inspectable, not magic.
