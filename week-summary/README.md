# Week summary — the opening figure for every content chapter

Self-contained figure package living inside the 2027 Guide to AI in Science.
One figure, drawn fifteen times: it opens every content chapter (weeks 1–14),
and is deliberately *not* used by the preface or by the personal-AI-philosophy
chapter, neither of which has a Polis session or a resource vote behind it.

## What it shows

Two panels, one per half of what a week produced.

**Left — "Top discussion points."** The statements put to the group, as a
diverging bar: disagreement runs left of zero, agreement right. The two live in
one picture on purpose. A week's consensus and its fault lines are the same
vote read in two directions, and splitting them into two charts would let a
reader see one without the other. Statements are drawn in CSV order, top to
bottom, so sorting the CSV by `agree` is what produces the wedge.

**Right — "Top resources."** The three resources the seminar voted forward, each
with a QR code to the thing itself and a credit line naming the student who
surfaced it. The credit is not decoration: attribution to the person who found
the resource is part of what the seminar is documenting, so the figure always
draws it.

Colour is a warm/cool pair rather than red/green, because the entire left panel
is one bar split into exactly these two colours — red/green would collapse it
for a red-green colourblind reader.

## How a chapter uses it

```r
source("week-summary/R/week-summary.R")            # setup chunk
week_summary_plot(week = 1, fig_width = 12, fig_height = 5.5)
```

Pass `week_summary_plot()` **the same width and height you give the chunk**.
Both, not just the width. A QR code has to be square on the page, but it is
positioned in npc — a fraction of its panel — and the panel's width and height
differ, so the function converts one into the other using the figure's aspect
ratio. Give it dimensions that don't match the chunk and the codes render
oblong, which is the one failure here that still scans and so goes unnoticed.

Chunks run from the project root (`execute-dir: project` in `../_quarto.yml`),
so the root-relative `source()` path above works from `weeks/` as well as from
the root. The R also resolves its own paths (see `week_summary_root` at the top
of `R/week-summary.R`), so `data/` and `figures/` work whether the script is
sourced from the project root or run from inside this folder.

This folder is excluded from the book render via `project: render:` in
`../_quarto.yml`, so nothing here becomes a stray page.

## Adding a week

Drop two CSVs in `data/`, named by zero-padded week number. Nothing else — no
code changes, no new figure.

`week-NN-statements.csv`

| column | meaning |
| --- | --- |
| `statement` | the statement as put to the group |
| `agree` | percent agreeing (0–100); the bar's other half is `100 - agree` |

`week-NN-resources.csv`

| column | meaning |
| --- | --- |
| `title` | resource title, drawn bold |
| `url` | encoded into the QR code — must be the real link |
| `body` | one or two sentences; wraps to the text column automatically |
| `credit` | the student who identified it, drawn as "Identified by …" |

The panel is built for **three** resources and **about five** statements. It
will draw other counts — rows are spaced evenly into the band that the left
panel's plotting region occupies — but past roughly six statements the labels
crowd, and past four resources the QR codes start to collide with the wrapped
body text below them.

### Keep the CSV text ASCII

Use `-` and `:` rather than en/em dashes, and straight quotes rather than curly
ones. Text *inside a figure* is drawn by a graphics device, not by LaTeX, and
the book's PDF output goes through the stock `pdf()` device on any machine
without a working cairo — which silently substitutes `-` for every em dash and
warns about it. This constraint applies only to the CSVs; the chapter prose
around the figure is typeset by LaTeX and can use whatever punctuation it likes.

The same reasoning is why the x-axis title reads `<- Disagree   Agree ->` in
ASCII rather than with unicode arrows: on that device the unicode arrows have no
glyph at all.

## Contents

```
week-summary/
├─ R/week-summary.R                the figure, in ggplot2 + cowplot
├─ data/
│  ├─ week-01-statements.csv       week 1 discussion points  (PLACEHOLDER)
│  └─ week-01-resources.csv        week 1 resources          (PLACEHOLDER)
└─ figures/
   ├─ week-01-summary.png          300 dpi raster, for proofing
   └─ week-01-summary.pdf          vector twin
```

**Week 1's data is a wireframe.** The bars, titles, and names in
`data/week-01-*.csv` are bracketed layout stand-ins — `[Consensus statement 1]`,
`[Student name]` — chosen to be unmistakable as placeholders rather than
plausible as findings. The chapter carries a callout saying so. Replace the two
CSVs with the real Polis results and vote, and both the figure and the callout
should go.

## Regenerating

The book does not use the files in `figures/` — it calls `week_summary_plot()`
and lets Quarto draw the figure at chunk size. They are for proofing, slides,
and posters:

```
Rscript R/week-summary.R 1      # writes figures/week-01-summary.{png,pdf}
```

Requires `ggplot2`, `dplyr`, `tidyr`, `forcats`, `readr`, `cowplot`, and
`qrcode`.

The PDF export picks its device at runtime and does *not* trust
`capabilities("cairo")` — on a macOS R built against cairo but running without
XQuartz that reports `TRUE`, and `cairo_pdf()` then dies at open time with
"failed to load cairo DLL". `grSoftVersion()[["cairo"]]` reports the version
that actually loaded, so an empty string is the honest answer; quartz's PDF type
is the macOS fallback, and the stock device is last.

## Provenance

Grown from a layout mockup (`ai_figure_mockup.R`), whose geometry solution — the
npc-to-inches QR conversion, and reading the left panel's gtable to find the
band its plotting region occupies — is preserved here. The mockup's own
fabricated survey statements were **not** carried over; they read as real
findings, which is exactly what a wireframe must not do.
