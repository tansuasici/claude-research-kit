# ResearchKitBench

Reproducible eval harness for the kit's behavioural claims.

The kit makes deterministic-enforcement promises — *"a `\cite` with no `.bib` entry is caught"*, *"a fabricated DOI cannot be written"*, *"raw sources are immutable"*, *"completion is gated on unresolved references"*. ResearchKitBench turns each promise into a pass/fail scenario verified on every PR — no LLM, no network, no hand-waving.

## Run it

```bash
./scripts/run-bench.sh                  # all scenarios
./scripts/run-bench.sh --scenario s01   # one
./scripts/run-bench.sh --filter citation # name contains
./scripts/run-bench.sh --verbose        # print stdout/stderr per scenario
./scripts/run-bench.sh --json           # machine-readable summary
```

Exit codes: `0` all pass, `1` one or more fail, `2` runner error. Each scenario runs in a **fresh temp directory** — no shared state.

## What's covered (32 scenarios)

| # | Scenario | What it asserts |
|---|---|---|
| s01 | `citation-gate-fails-on-dangling-cite` | `\cite{ghost}` with no `.bib` entry → verdict `failed` |
| s02 | `citation-gate-passes-on-resolved-cite` | `\cite{real}` with a matching `@article{real,` → verdict `passed` |
| s03 | `citation-gate-fails-on-dangling-ref` | `\ref{fig:x}` with no `\label{fig:x}` → verdict `failed` |
| s04 | `citation-gate-ignores-commented-cite` | a `\cite` inside a `%` TeX comment does NOT count → `passed` *(regression: comment stripping)* |
| s05 | `citation-gate-fails-on-multikey-partial` | `\citep{real,ghost}` where one key is undefined → `failed` |
| s06 | `stop-gate-blocks-on-failed-verdict` | last verdict `failed` → exit 2 |
| s07 | `stop-gate-allows-on-passed-verdict` | last verdict `passed` → exit 0 |
| s08 | `stop-gate-bypassed-with-skip-env` | `SKIP_QUALITY_GATE=1` + failed verdict → exit 0 |
| s09 | `block-fabrication-blocks-placeholder-doi` | writing `doi = {10.xxxx/…}` → exit 2 |
| s10 | `block-fabrication-blocks-empty-required-field` | `.bib` entry with `author = {}` → exit 2 |
| s11 | `block-fabrication-allows-real-entry` | a fully-filled entry with a real DOI → exit 0 |
| s12 | `block-fabrication-allows-prose-placeholder` | honest `[CITE]` / `[VALUE — verify]` in prose → exit 0 *(the correct behavior — never block it)* |
| s13 | `block-fabrication-bypassed-with-approved` | `RESEARCH_APPROVED=1` + placeholder DOI → exit 0 |
| s14 | `protect-sources-blocks-sources-dir` | edit to `sources/…` → exit 2 |
| s15 | `protect-sources-blocks-data-raw` | edit to `data/raw/…` → exit 2 |
| s16 | `protect-sources-allows-section-edit` | edit to `sections/intro.tex` → exit 0 |
| s17 | `protect-sources-bypassed-with-approved` | `RESEARCH_APPROVED=1` + `sources/` → exit 0 |
| s18 | `prompt-router-injects-on-overclaim` | "we proved … first … novel … outperforms" → calibration reminder |
| s19 | `prompt-router-injects-on-citation` | "add citations for related work" → sourcing reminder |
| s20 | `prompt-router-quiet-on-neutral` | a neutral prompt → empty stdout |
| s21 | `session-start-injects-thesis` | `MANUSCRIPT_MAP.md` present → injects map pointer + thesis |
| s22 | `session-end-writes-audit-line` | appends one line to `reports/session-audit.log` |
| s23 | `branch-protect-blocks-push-main` | `git push origin main` → exit 2 |
| s24 | `block-dangerous-blocks-rm-rf-root` | `rm -rf /` → exit 2 |
| s25 | `compile-gate-fails-on-undefined-cite-log` | a LaTeX `.log` with `Citation … undefined` → compile verdict `failed` |
| s26 | `compile-gate-passes-on-clean-log` | a clean `.log` → compile verdict `passed` |
| s27 | `compile-gate-noop-without-log` | no `.log` yet → no verdict written (don't gate an uncompiled project) |
| s28 | `stop-gate-blocks-on-failed-compile` | failed `last_compile_gate.json` → exit 2 (stop-gate checks both gates) |
| s29 | `word-budget-warns-over-budget` | `% budget: 5` + a long section → `word-budget` warning |
| s30 | `word-budget-quiet-under-budget` | `% budget: 500` + a short section → silent |
| s31 | `figure-orphan-warns-orphan-label` | `\label{fig:x}` never `\ref`'d → orphan warning |
| s32 | `figure-orphan-quiet-when-referenced` | `\label{fig:x}` with a matching `\ref` → silent |

## Add a scenario

Drop a JSON object (or a list of them) in `bench/scenarios/<name>.json`:

```json
{
  "name": "sNN-short-slug",
  "hook": ".claude/hooks/<hook>.sh",
  "setup_files": { "<relpath>": "<content>" },
  "env": { "VAR": "value" },
  "payload": { "tool_name": "Edit", "tool_input": { "file_path": "{TMPROOT}/x.tex" } },
  "expect": {
    "exit_code": 2,
    "stdout_contains": ["BLOCKED"],
    "state": [ { "file": ".hook-state/last_quality_gate.json", "field": "status", "equals": "failed" } ],
    "file_grew": ["reports/session-audit.log"]
  },
  "notes": "Optional context — especially for regression scenarios."
}
```

Variables: `{TMPROOT}` (the per-scenario temp dir), `{KIT_ROOT}` (the kit checkout). All `expect.*` keys are optional; the minimum useful assertion is `exit_code`.

## What it deliberately does not do

- **No LLM-graded evals.** Hooks are deterministic shell scripts; their behaviour is grounded in exit codes and state-file content.
- **No source-content verification.** The bench checks that `\cite` keys *resolve*; it does not (and cannot, deterministically) check that a source *supports* a claim — that is the job of `/claim-check` and the `fact-checker` agent.
- **No full-session replay.** One hook at a time, not a whole Claude Code session.

## Why this exists

The kit's commitment is *deterministic enforcement of citation discipline*. Without a bench, that commitment is a vibe. ResearchKitBench makes it a contract — every PR that touches a hook re-asserts it.
