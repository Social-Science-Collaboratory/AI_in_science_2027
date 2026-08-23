# Verification log — author counts on flagship model reports

Every count in `frontier-model-authors.csv` was checked against a primary source
on **2026-08-23**. This file records what was checked, against what, and what
remains uncertain, so the provenance survives outside anyone's memory.

## Policy applied

- **Version:** the original release (arXiv v1), never a later revision. The
  `date` column matches the version counted.
- **Who counts:** unique named individuals. An institutional byline
  ("OpenAI", "Gemini Team", "DeepSeek-AI", "Kimi Team", "Qwen Team",
  "Llama Team") is not a person. Where the byline is institutional, the
  contributions appendix is what was counted. A name appearing twice counts once.

## Sources

Counts came from the arXiv v1 abstract page and, for the appendix-based rows,
the v1 PDF itself. Two sources were deliberately **not** trusted:

- **The arXiv API** emits stray single-token surnames on long lists — it splits
  parenthetical nicknames ("Dmitry (Dima) Lepikhin") into fragments. The abs
  page HTML and the PDF are correct; the API is not.
- **OpenAlex truncates.** It reports 100 authorships for GPT-4 and 50 for
  Llama 3. Unusable for the long lists.
- **Semantic Scholar** was rate-limited (HTTP 429) throughout. No data from it
  is used anywhere in this table.

DOIs are the plain arXiv DOI, confirmed resolving at DataCite and doi.org.
Version-pinned DOIs (`10.48550/arXiv.<id>v1`) **do not exist** — they 404 — so
the version is pinned through the `url` field instead.

There is no version-of-record DOI for Attention Is All You Need (NeurIPS 2017),
GPT-3 (NeurIPS 2020) or PaLM (JMLR v24); those landing pages carry none.

> **Trap, recorded so nobody falls into it twice.** OpenAlex attaches DOI
> `10.65215/2q58a426` to "Attention Is All You Need" with a correct-looking
> 8-author list. It resolves to a third-party re-post, not the NeurIPS paper.
> A title-matched DOI for GPT-3 leads to an unrelated book chapter. The arXiv
> DOI is canonical for all three.

## What changed on 2026-08-23

| model | was | now | why |
|---|---|---|---|
| Qwen3 | 60 | 176 | arXiv byline lists only the 60 Core Contributors and silently omits the 117 Contributors in section 6 |
| Gemini 1.0 | 1350 | 939 | 1350 was the May-2025 revision; v1 has 941 entries, 939 unique |
| Gemini 2.5 | 3435 | 3291 | 3435 was v6 via the API; v1 PDF has 3291 entries. Date also corrected 07-08 → 07-07 |
| Llama 3 | 559 | 529 | 559 matched no single source; v1 appendix has 531 entries, 529 unique |
| GPT-4 | 280 | 278 | old note's arithmetic was wrong; 278 is the v1 appendix (see caveat) |
| Kimi K2 | 199 | 168 | 199 belongs to a Feb-2026 revision; v1 Appendix A has 168 |
| Gemini 1.5 | 671 | 669 | 671 entries, 669 unique |
| DeepSeek-V3 | 200 | 197 | 200 counted the "DeepSeek-AI" byline as a person; 199 named, 197 unique |
| GPT-5 | 485 | 483 | 485 is the v2 metadata; v1 metadata has 483 (see caveat) |
| Gemini 1.0 date | 2023-12-06 | 2023-12-19 | actual arXiv v1 submission date |

Unchanged and confirmed from primary sources: Attention (8), GPT-1 (4),
GPT-2 (6), GPT-3 (31), PaLM (67), LLaMA (14), Llama 2 (68).

## Rows that still deserve a human eye

**GPT-5 System Card — the weakest row in the table.** The 61-page document
carries *no author list anywhere*; page 1 reads only "GPT-5 System Card /
OpenAI / August 13, 2025". The 483 names exist solely in arXiv's
submitter-entered metadata. Every other row's count comes from the document
itself; this one does not. It may be 482 — one byline entry, "Shuaiqi", is a
bare single token, likely half of a split nickname, and this cannot be checked
against a document that has no list. Three dates compete for this row: the
document says 2025-08-13, arXiv v1 says 2025-12-19, v2 says 2026-05-01.
The `2601` identifier against a December 2025 date is a genuine arXiv quirk,
not a sign of a bad reference — the stamp on page 1 of the PDF reads
`arXiv:2601.03267v1 [cs.CL] 19 Dec 2025`.

**GPT-4 (278) — derived, not directly counted.** The v1 PDF does carry the full
appendix, but its two-column, role-grouped layout repeats names across sections
and defeats direct enumeration. 278 comes from differencing the v1 and v6
appendix text against OpenAI's own 280-name v6 byline: exactly two people were
added after v1 (Ian Sohl, Sully Chen) and none removed. Well-evidenced, but
this is the one number worth spot-checking by hand.

**GPT-1 date.** The count of 4 is certain. The date is not: the PDF carries no
printed date and its only timestamp is 2018-06-08, which does not match the
2018-06-11 in the table. Neither could be confirmed from a primary source.

**Llama 3 duplicates.** Shaun Lindsay and Shuqiang Zhang each appear twice in
the appendix. Counted once each here, but these may be two distinct people who
share a name rather than duplicate entries.

**Gemini 1.0.** "Fan Yang" appears three times. The arXiv byline also carries a
typo, "Sabaer Fatehi", where the PDF reads "Saaber Fatehi".
