# Scale ladder — co-authors on flagship AI model reports

Figure package for `@fig-scale-ladder` in `index.qmd`: credited co-authors on
flagship model reports from OpenAI, Google, and Meta, 2018–2025. One square is
one credited person; each report is a near-square block, so block area is
proportional to its author count. Colour is the lab.

## Usage

```r
source("figure-packages/scale-ladder/R/scale-ladder.R")   # setup chunk
scale_ladder_plot(fig_width = 7.5)    # chunk: fig-width 7.5, fig-height 2.4
```

Pass `scale_ladder_plot()` the chunk's `fig-width`; label spacing is solved
against it, and the function warns if the labels no longer fit. If you change the
width or the label text, recheck that the chunk's `fig-height` still fills the
frame without white margins.

## Contents

```
scale-ladder/
├─ R/scale-ladder.R                  the figure, in ggplot2
├─ data/
│  └─ frontier-model-authors.csv     one row per plotted report
└─ figures/
   ├─ scale-ladder.png               600 dpi export, for proofing
   └─ scale-ladder.pdf               vector export
```

Each CSV row carries the count, the `bibkey` of its entry in the book's
`references.bib` (the figure caption cites all of them), the DOI and arXiv id,
a note on where in the document the count was read, and the date it was verified.

## Counting policy

- **Version:** the original release (arXiv v1, or the original PDF where there is
  no arXiv record), never a later revision. The `date` column matches the version
  counted.
- **Who counts:** unique named individuals. An institutional byline ("OpenAI",
  "Gemini Team") is not a person; where the byline is institutional, the
  contributions appendix is what is counted.

## Regenerating

```
Rscript R/scale-ladder.R     # writes figures/scale-ladder.png and .pdf
```

Requires `ggplot2`, `dplyr`, `readr`, and `ragg`.
