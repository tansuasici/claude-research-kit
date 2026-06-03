# ARTIFACTS.md — HTML Artifact Conventions

This file configures Claude to produce **HTML artifacts** — not markdown — for the
*read-only, shareable* outputs of research work: response-to-reviewer letters,
submission checklists, results tables, pre-submission review reports, and
literature maps. The manuscript itself stays in **LaTeX**; these are the
side-artifacts you hand to a co-author, an editor, or yourself.

Background: HTML carries far more signal than markdown (tables, color severity,
SVG, "copy as text" buttons) and is trivially shareable (upload + link). The
manuscript is `.tex`; hand-edited tracking files stay markdown; the things you
only *read and share* become HTML.

> **Mental model:** Markdown for agents only. HTML for agents *and* humans.
> The moment a co-author or editor enters the loop, switch to HTML.

**Minimum invocation:** end your prompt with `"structure this as HTML"`. No skill, no scaffolding.

---

## When HTML, when Markdown / LaTeX

Prefer **HTML** when one or more is true:
- The reader is someone other than you (co-author, editor, reviewer)
- The content is a table or comparison (reviewer responses, results, checklists)
- Severity / status color helps (blocking vs should-fix; supported vs overstated)
- You want an SVG diagram (a literature map, an argument tree) over ASCII

Keep **LaTeX** for: the manuscript, sections, figures, the bibliography — anything submitted.
Keep **markdown** for: `tasks/todo.md`, `tasks/decisions.md`, `tasks/reviews/`, `tasks/handoff-*.md`, `vault/` — anything edited by hand or grepped.

---

## Directory

```text
artifacts/
  index.html              # Catalog — links to every artifact, kept current
  design-system.html      # Reference tokens (color, type, spacing) — Claude mirrors this
  YYYY-MM-DD-<slug>.html   # Generated artifacts
```

---

## Conventions

- File names: date prefix + kebab-case slug → `2026-06-03-response-to-reviewers.html`
- Every artifact mirrors `design-system.html`'s tokens (read it before generating)
- After creating an artifact, append a row to `index.html` (date · type · title · link · purpose)
- **Standalone files** — embed CSS/JS inline. No external deps, no build step. It must work when uploaded and opened by a co-author.
- Inline SVG for diagrams, never ASCII
- **The cardinal rule still applies.** An HTML artifact must not invent a citation, a number, or a reviewer comment. A results-table artifact mirrors the manuscript's reported values — it never introduces a figure not in the `.tex`/data. Flag `[VALUE — verify]` here too.

---

## Artifact Types

| Type                   | Use for                                              | Key elements                                          |
|------------------------|------------------------------------------------------|-------------------------------------------------------|
| `response-letter`      | Point-by-point reply to reviewers                    | Reviewer quote → response → change + location; status chips |
| `submission-checklist` | Pre-submission go/no-go (from `/submission-pipeline`) | Checklist with pass/blocking color; venue limits      |
| `review-report`        | Pre-submission review battery output                 | Findings by severity, lens agreement, recommendation  |
| `results-table`        | A clean results/ablation table to share              | Sortable table, effect size + CI, mirrors the `.tex`  |
| `lit-map`              | Literature landscape / argument structure            | SVG nodes (themes, sources, the gap), links to vault  |
| `figure-draft`         | A figure mockup before committing to the real plot   | SVG/canvas sketch, caption draft, `[VALUE — verify]`  |

---

## Two-way Interaction

When an artifact accepts input, it **must** include an export button so the
user's edits return to Claude Code as paste-able text:

| Artifact              | Required button                                  |
|-----------------------|--------------------------------------------------|
| Response-letter draft | `Copy as LaTeX` / `Copy as markdown`             |
| Checklist (ticked)    | `Copy remaining items`                           |
| Results-table editor  | `Copy as LaTeX tabular`                           |
| Lit-map               | `Copy as outline`                                 |

Implementation: one button → `navigator.clipboard.writeText(...)`. No frameworks.

---

## Sharing

Upload the standalone file and send the link, or `open artifacts/<file>.html`
(macOS) for local viewing. No build pipeline — every artifact is self-contained.

---

## Anti-patterns

- **No generic `/html` skill** — let the prompt's intent drive the artifact type
- **No multi-file artifacts** — one file, one purpose
- **No build tooling** — no React, no bundlers, no npm install
- **No omitting `design-system.html`** — artifacts drift in style otherwise
- **No putting the manuscript in HTML** — the paper is LaTeX; artifacts are side outputs
- **No inventing data** — an artifact mirrors the manuscript's real values, never new ones

---

## Index Maintenance

After creating any artifact, update `artifacts/index.html`:
1. Add a row: date · type · title · link · one-line purpose (newest at top)
2. Mark a superseded artifact's row as superseded — don't delete (history matters)
3. If `index.html` is stale, regenerate from the `artifacts/*.html` `<title>` + `<meta name="artifact-*">` tags

---

## Artifact Metadata

Every artifact declares itself in `<head>`:

```html
<title>Response to Reviewers — 2026-06-03</title>
<meta name="artifact-type" content="response-letter">
<meta name="artifact-date" content="2026-06-03">
<meta name="artifact-purpose" content="Point-by-point reply to R1/R2 for the ACL submission">
```
