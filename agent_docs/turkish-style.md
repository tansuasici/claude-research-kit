# Turkish-Language Manuscripts

Read this before drafting or revising a manuscript whose `STYLE.md` sets
`**Language:** Turkish`. Everything in `agent_docs/academic-style.md` still applies: this
file adds what changes in Turkish. A venue's author guidelines override the conventions
below.

Rule content adapted from [turkish-anti-ai-skill](https://github.com/yucezerey/turkish-anti-ai-skill)
(MIT). The spelling and punctuation section follows TDK conventions; check the current
[TDK Yazım Kılavuzu](https://www.tdk.gov.tr/) when a case is not listed here.

---

## Calibration ladders

The certainty of the verb must match the evidence, as in English. Changing a verb's rung
changes the claim.

**Verbs, strongest to weakest:**

`göstermektedir / ortaya koymaktadır` > `işaret etmektedir` > `düşündürmektedir` >
`ile ilişkilidir` > `-ebilir`

**Quantifiers, largest to smallest:**

`tüm` > `çoğu` > `birçok` > `bazı` > `birkaç`

Do not move "bazı hastalarda" to "birçok hastada" to make a sentence read better. It is a
different claim.

---

## Academic register

- **Person:** neutral third person by default (`incelenmiştir`, `bulunmuştur`). Use the
  first person only if the venue or `STYLE.md` asks for it.
- **Word order:** verb last. Avoid inverted sentences (`devrik cümle`) in academic prose.
- **Branching:** Turkish is left-branching, so long modifiers pile up before the noun.
  If a modifier chain is hard to follow, split the sentence. Keep the topic sentence
  first in the paragraph.
- **Particles:** use `ise`, `nitekim` and `dolayısıyla` where the logic calls for them,
  and sparingly.
- **Terms:** prefer the established Turkish term when the field uses one (`veri tabanı`,
  `alan yazını`) and keep one term per concept. Give the English original in parentheses
  on first use if readers may need it.

---

## Sentence endings

`-mAktAdIr` is a normal academic form, so the goal is variety, not removal.

| Pattern | What to do |
|---|---|
| Three or more sentences in a row ending in `-mAktAdIr` | Vary with the aorist (`gösterir`, `sınırlar`) or restructure. Keep the certainty level. |
| Long runs of `-mIştIr` in Methods | Usually fine: Methods report completed actions. Vary only if it reads mechanically. |
| `-mAktAdIr` on nearly every verb | Often reads as translated or generated text. Change some, not all. |

Do not swap every instance for the same replacement. A text with `-ir` on every sentence
has the same problem as one with `-mAktAdIr` on every sentence.

---

## Cut the calques and clichés

| Cut | Why | Instead |
|---|---|---|
| `kritik bir rol oynamaktadır`, `kilit rol oynar`, `hayati bir öneme sahiptir`, `büyük önem arz etmektedir` | Vague intensifiers, often calqued from English. | Say what it does, with the result. |
| `günümüzün hızla değişen dünyasında`, `dijitalleşen çağımızda` | Empty runway. | Open on the claim. |
| `önemi yadsınamaz`, `inkâr edilemez` | Asserts instead of showing. | Give the evidence. |
| `belirtmek gerekir ki`, `unutulmamalıdır ki`, `vurgulamak gerekir ki` | Throat-clearing. | State the thing. |
| `göstermektedir ki` | English "shows that" word order. | `… olduğunu göstermektedir` |
| `sadece X değil, aynı zamanda Y`, `X yapmakla kalmayıp Y` | Negative parallelism, a frequent LLM frame. | `hem X hem Y`, or state Y. |
| `derinlemesine incelemek`, `geniş bir yelpaze`, `çığır açan`, `kusursuz bir şekilde`, `âdeta` | Promotional or figurative register. | A plain verb and a measured claim. |
| `dönüm noktası`, `bütüncül yaklaşım`, `paradigma değişimi` | Often empty, sometimes field terms. | Keep only if literal or a term of art. |

**Not tells.** These are ordinary academic Turkish, and the `ai-tell` hook does not flag
them: `söz konusu`, `bu bağlamda`, `sonuç olarak`, `öte yandan`, `bununla birlikte`,
`tarafından`. Removing them on sight makes the prose worse.

---

## Spelling and punctuation

| Topic | Rule | Example |
|---|---|---|
| Decimals | Comma | `3,14`; `%42,5`; `p = 0,04` |
| Thousands | Dot | `10.000` |
| Percent | Sign first, no space | `%25` |
| Clock time | Dot | `14.30` |
| Ranges | Hyphen, unless the venue says otherwise | `2024-2026`; `s. 12-45` |
| `ve`, `veya` | No comma before them | `yaş ve cinsiyet` |
| After converbs | No comma needed by default | `Veriler toplanınca analiz yapıldı.` |
| Asides | Commas or a pair of hyphens, not the em dash | `Bu sonuç -beklenenin aksine- zayıftı.` |
| Em dash | Reserved for dialogue | |
| Suffix on abbreviations | Follows pronunciation | `SQL'de`, `JSON'da` |
| Institution names | No apostrophe before the suffix | `Türk Dil Kurumundan` |
| Titles | Conjunctions stay lowercase | `Yöntem ve Bulgular` |
| `ki` | Separate as a conjunction | `Görüldü ki`; but `sanki`, `belki`, `çünkü` |

**Often misspelled:** `ön yargı`, `iş birliği`, `birçok`, `birkaç`, `bir şey`, `her şey`,
`art arda`, `yanı sıra`, `veri tabanı`, `fark etmek`, `kaydetmek`.

**Numbers are not free to change.** Converting `3.14` to `3,14` changes notation only.
Check that every value still matches its table, and leave code, data files and quoted
source text as they are.

---

## What the hook covers

`ai-tell` detects Turkish automatically and checks for the clichés above and for runs of
the same sentence ending. It does not check spelling or punctuation, so use this table
when revising.

The other prose checks in the kit, such as overclaim detection, are written for English.
In a Turkish manuscript, apply the ladders above by hand or run `/claim-check`.

The advice in `academic-style.md` to keep LaTeX source ASCII does not extend to Turkish
letters. Write them directly in UTF-8 source. `unicode-scan` only looks for invisible
characters, so it does not flag them.

If your field studies or quotes a flagged phrase, list the exact form that appears in the
text in `.claude/hooks/project/ai-tell-allow.txt`.
