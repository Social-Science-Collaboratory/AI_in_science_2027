# Week summary — the opening figure for every content chapter

Self-contained figure package living inside the 2027 UF Guide to AI in Science.
One figure that opens every content chapter (weeks 2–12); the preface and
epilogue do not use it.

## What it shows

Two panels, one per half of what a week produced.

**Left — "Top discussion points."** About five Polis statements as a diverging
bar: disagreement left of zero, agreement right. They are chosen for relevance
to the chapter (spanning consensus to disagreement), not by agreement rank, and
are drawn in CSV order, top to bottom.

**Right — "Top resources."** The three resources the seminar voted forward,
each with a QR code to the resource and a credit line naming the student who
surfaced it.

## How a chapter uses it

```r
source("figure-packages/week-summary/R/week-summary.R")            # setup chunk
week_summary_plot(week = 2, fig_width = 12, fig_height = 5.5)
```

Pass `week_summary_plot()` **the same width and height you give the chunk** —
both — or the QR codes render non-square.

The R resolves its own paths (`week_summary_root` in `R/week-summary.R`), so
`data/` and `figures/` work whether the script is sourced from the project root
or run from inside this folder.

## Adding a week

Drop two CSVs in `data/`, named by zero-padded week number. Nothing else — no
code changes, no new figure.

`week-NN-statements.csv`

| column | meaning |
| --- | --- |
| `statement` | the statement as put to the group |
| `agrees` | number of agree votes on that Polis statement |
| `disagrees` | number of disagree votes on that Polis statement |

Record the **counts**, not a percentage. The bar is `agrees / (agrees +
disagrees)`; passes are excluded.

`week-NN-resources.csv`

| column | meaning |
| --- | --- |
| `title` | the resource's real title (see "Resource titles are real titles"), drawn bold |
| `url` | encoded into the QR code — must be the real link |
| `body` | one or two sentences; wraps to the text column automatically |
| `credit` | the student who identified it, drawn as "Identified by …" |

The panel is built for **three** resources and **about five** statements;
past roughly six statements or four resources, labels and QR codes collide.

### Keep the CSV text ASCII

Use `-` and `:` rather than en/em dashes, and straight quotes rather than curly
ones; the PDF build's `pdf()` device cannot draw them. This applies only to the
CSVs, not to chapter prose.

## Contents

```
week-summary/
├─ R/week-summary.R                the figure, in ggplot2 + cowplot
├─ data/
│  ├─ week-NN-statements.csv       discussion points, weeks 02–12
│  ├─ week-NN-resources.csv        resources, weeks 02–12
│  └─ polis/                       de-identified Polis report data
└─ figures/
   └─ week-NN-summary.png          300 dpi raster, for proofing
```

## Where a week's data comes from

Both CSVs are transcriptions of two Polis sessions per week — one to discuss,
one to vote on resources — plus the shared sheet where students post what they
found. The sheet numbers its tabs one behind the book, so take the tab from the
table below.

| week | discussion report | resource vote report | resource sheet tab |
| --- | --- | --- | --- |
| 2 | [r8mvdhhepjcxwkyyf52cs](https://pol.is/report/r8mvdhhepjcxwkyyf52cs) | [r44s8jkj3fwapwdmbjxsx](https://pol.is/report/r44s8jkj3fwapwdmbjxsx) | [gid=2097835206](https://docs.google.com/spreadsheets/d/1ANIdsjrg5aG4lP4E491NaluIDMXhNLgp/edit?gid=2097835206) |
| 3 | [r9z3jc52kbd6ux7vhdeu5](https://pol.is/report/r9z3jc52kbd6ux7vhdeu5) | not yet published | [gid=506079777](https://docs.google.com/spreadsheets/d/1ANIdsjrg5aG4lP4E491NaluIDMXhNLgp/edit?gid=506079777) |
| 4 | [r3ufehuivwarjk7rex96d](https://pol.is/report/r3ufehuivwarjk7rex96d) | not yet published | [gid=21606442](https://docs.google.com/spreadsheets/d/1ANIdsjrg5aG4lP4E491NaluIDMXhNLgp/edit?gid=21606442) |
| 5 | [r8v6s8jef4cjctcmncfna](https://pol.is/report/r8v6s8jef4cjctcmncfna) | not yet published | [gid=1933270104](https://docs.google.com/spreadsheets/d/1ANIdsjrg5aG4lP4E491NaluIDMXhNLgp/edit?gid=1933270104) |
| 6 | [pol.is/6ncmz42nce](https://pol.is/6ncmz42nce) (no report yet) | [pol.is/3fetjrsr3d](https://pol.is/3fetjrsr3d) (no report yet) | tab "Wk 5 Use Data" |
| 7 | [r8rav2rbxe8r9renuku3x](https://pol.is/report/r8rav2rbxe8r9renuku3x) | [pol.is/6kzczb6kwn](https://pol.is/6kzczb6kwn) (no report yet) | [gid=1379349204](https://docs.google.com/spreadsheets/d/1ANIdsjrg5aG4lP4E491NaluIDMXhNLgp/edit?gid=1379349204) |
| 8 | [r7fvae9dcbkdnhhuafdrc](https://pol.is/report/r7fvae9dcbkdnhhuafdrc) | [pol.is/2cvhhymema](https://pol.is/2cvhhymema) (no report yet) | [gid=43677910](https://docs.google.com/spreadsheets/d/1ANIdsjrg5aG4lP4E491NaluIDMXhNLgp/edit?gid=43677910) |
| 9 | [r7pxadfkedbhnjn8b5bbe](https://pol.is/report/r7pxadfkedbhnjn8b5bbe) | [pol.is/9yf9fdaktc](https://pol.is/9yf9fdaktc) (no report yet) | [gid=805361559](https://docs.google.com/spreadsheets/d/1ANIdsjrg5aG4lP4E491NaluIDMXhNLgp/edit?gid=805361559) |
| 10 | [r5dc7afbm2yhaesnhkm24](https://pol.is/report/r5dc7afbm2yhaesnhkm24) | [pol.is/3b4n7axwww](https://pol.is/3b4n7axwww) (no report yet) | tab "Wk 9 Writing" |
| 11 | [pol.is/664ek97mr8](https://pol.is/664ek97mr8) (no report yet) | [pol.is/8mhxriwktf](https://pol.is/8mhxriwktf) (no report yet) | tab "Wk 10 Outreach" |
| 12 | [r74m3redt5rwrmdcjzukw](https://pol.is/report/r74m3redt5rwrmdcjzukw) | [pol.is/6rdypxykvw](https://pol.is/6rdypxykvw) (no report yet) | [gid=403063907](https://docs.google.com/spreadsheets/d/1ANIdsjrg5aG4lP4E491NaluIDMXhNLgp/edit?gid=403063907) |

De-identified copies of the published reports are in `data/polis/`
(`week-NN-discussion.csv`, and `week-02-resource-vote.csv`), one row per Polis
statement: `comment_id`, `agrees`, `disagrees`, `passes`, `moderated`,
`statement`. Author and voter IDs and timestamps are dropped. They were built
from these exports, which Polis serves without a login:

```
https://pol.is/api/v3/reportExport/<report-id>/comments.csv   # per-statement agree/disagree
https://pol.is/api/v3/reportExport/<report-id>/votes.csv      # one row per vote, incl. passes
https://pol.is/api/v3/reportExport/<report-id>/summary.csv    # n voters, n statements, n groups
```

`agrees` and `disagrees` are copied straight from `comments.csv` (a tally of
`votes.csv` should match). The bar is the **agree share of agree-and-disagree
votes** — passes are excluded, not counted as disagreement. A chapter quoting a
percentage in prose should give the counts with it.

### Ranking resources uses raw agree counts

The three resources drawn are the three with the most agree votes (not the
highest agree share). They are drawn in CSV order, and the CSV lists them in
the order the chapter prose first discusses them; a resource the prose never
mentions goes last.

### Statements are rephrased and wrapped

The CSV may rephrase a statement for clarity, keeping the claim the group
voted on; the original wording is in `data/polis/`.

The left panel does no wrapping of its own: put literal newlines inside the
quoted field, wrapping at about 46 characters, to no more than three lines.

### Resource titles are real titles

Resource `title` is the resource's **real title**, looked up from the DOI,
arXiv record, or page itself, never the title a student wrote in the resource
sheet. Drop a subtitle after a colon. The title wraps at about 41 characters,
and the body and credit move down beneath it. If the real title would still take
**more than two lines**, write a short descriptive title in its place, kept
close to the real title's own wording, and give the full title in the chapter
prose.

The `body` wraps automatically; keep it near 100 characters (about three
lines). Each title-body-credit stack is centred on its QR code, and the script
warns if a stack runs into the one above it.

## Regenerating

The book does not use the files in `figures/` — it calls `week_summary_plot()`
at chunk size. They are for proofing:

```
Rscript R/week-summary.R 2      # writes figures/week-02-summary.png
```

Requires `ggplot2`, `dplyr`, `tidyr`, `forcats`, `readr`, `cowplot`, and
`qrcode`.
