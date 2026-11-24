# Finding & Verifying Sources

The companion to `agent_docs/citation-discipline.md`. That guide says *never invent a
reference*; this one says *where to look* when you need to confirm one exists, read
its real metadata, or find a legal full-text copy.

**The one sentence:** a reference is verified only when you have read its metadata
from a real index or from the document itself — not from memory, and not because the
DOI "looks right."

---

## By purpose

Pick the source by what you need to know, not by habit.

| You need to know… | Use | Notes |
|---|---|---|
| **Does this work exist? What is its exact metadata?** | **Crossref** (crossref.org), **OpenAlex** (openalex.org), **Semantic Scholar** (semanticscholar.org) | Crossref is the DOI registration agency for most journals: authoritative for DOI, title, venue, year. OpenAlex and Semantic Scholar also cover works without a Crossref DOI (preprints, some proceedings). |
| **Is there a legal open-access copy?** | **Unpaywall** (unpaywall.org), **CORE** (core.ac.uk), **DOAJ** (doaj.org), **PubMed Central** (ncbi.nlm.nih.gov/pmc) | Unpaywall maps a DOI to its open-access versions (publisher, repository, preprint). DOAJ lists vetted open-access journals. |
| **A preprint** | **arXiv**, **bioRxiv / medRxiv**, **PsyArXiv**, **SSRN**, **OSF Preprints** | Cite the *published* version once one exists (`agent_docs/field/*.md`). |
| **A thesis or dissertation** | **OATD** (oatd.org), the awarding university's repository | Institutional repositories hold the authoritative copy. |
| **A dataset or software release** | **Zenodo** (zenodo.org), the field's data repository | Zenodo DOIs are real, citable `@misc` entries. |
| **Field-specific indexes** | the discipline's own index, e.g. **PubMed** (medicine, life sciences), **ERIC** (education), **PhilPapers** (philosophy) | Check `agent_docs/field/<discipline>.md` first when an overlay exists. |

Subscription databases (Web of Science, Scopus, JSTOR, EBSCO) are fine to use through
the author's institution. Do not assume access the author has not said they have.

---

## Lookups by identifier

When you have an identifier and network access, these return machine-readable
metadata you can compare field by field against the `.bib` entry:

```text
Crossref          https://api.crossref.org/works/<doi>
OpenAlex          https://api.openalex.org/works/https://doi.org/<doi>
Semantic Scholar  https://api.semanticscholar.org/graph/v1/paper/DOI:<doi>
arXiv             https://export.arxiv.org/api/query?id_list=<arxiv-id>
Unpaywall         https://api.unpaywall.org/v2/<doi>?email=<author's own email>
```

Unpaywall asks for a contact email. Use one the author provides; never invent one or
use someone else's.

A lookup that returns **404 / no result is a finding, not a typo to fix.** Report it
as an unverified reference. Do not "correct" the DOI to something that resolves.

---

## The verification rule

1. **Match, don't trust.** A resolving DOI proves *a* work exists, not that it is the
   one cited. Compare title, first author, and year against the entry. A DOI that
   resolves to a different paper is worse than no DOI.
2. **The document beats the index.** When `sources/` holds the PDF, read metadata
   from it (`/lit-ingest`). Indexes have errors too; when they disagree with the
   document, flag the disagreement.
3. **No lookup, no claim.** Without network access or a match, the reference stays
   **unverified**: leave `[CITE — …]` or note it in the audit. Never fill a field from
   recall (`agent_docs/citation-discipline.md → "I think there's a paper that says X"`).
4. **Report what you checked.** Name the source used ("verified against Crossref"),
   so the author can re-run it.

---

## What not to use

- **Shadow libraries** (Sci-Hub, LibGen, and tools built on them). They infringe
  copyright. Do not suggest them, link them, or fetch from them. When no legal copy
  exists, say so: the author can use interlibrary loan or email the corresponding
  author.
- **Upload-sharing sites as a metadata source** (ResearchGate, Academia.edu). The copy
  may be a draft, not the version of record. Fine for finding that a paper exists;
  confirm the metadata against an index above.
- **General web search results or an LLM's answer as proof of existence.** These lead
  to a lookup; they do not replace one.
