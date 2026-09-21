# literature-review — Figure 2 of the Literature Review chapter

Self-contained figure package for `weeks/04-literature-review-using.qmd`. Same
construction as `checkin-workflow/`: two supplied PNGs placed side by side with
`grid`, rather than composited into a bitmap, so the panel labels stay vector in
the book's PDF build.

```r
source("figure-packages/literature-review/R/literature-review.R")   # setup chunk
literature_review_plot()                            # fig-width 12, fig-height 4.59
```

## The two panels

| panel | source | label drawn on the figure |
| --- | --- | --- |
| A | `images/panel-a-workflow.png` | Overview of AI-assisted literature review workflow |
| B | `images/panel-b-demo.png` | Demo of AI-assisted literature review workflow |

Panel A is the workflow diagram drawn for the seminar; panel B is a screenshot
of that same loop running against a working project.

## Why the columns are unequal

Panel A is near-square (2028x1928) and panel B is 16:9 (3200x1800). Equal halves
would leave A towering over B with white space beside it, so the row is split in
proportion to the two aspect ratios instead: both panels then come out exactly
the same height with no padding, and the columns land at about 4.30in and
7.26in of a 12in figure.

Heights are derived from the sources at draw time, so **replacing a panel with
an image of different proportions needs no code change** — but it does change
the figure's height, and the chunk's `fig-height` has to be updated to match.
`literature_review_layout()$height` is the number to use; `fig-width` must stay
the value the layout was solved at.

Panel A is a transparent PNG, which is why `literature_review_plot()` paints the
canvas white before drawing. Without it the diagram's dark text lands on
whatever the device leaves behind.

## Regenerating

The book does not use `figures/` — it calls `literature_review_plot()` and lets
Quarto draw the figure at chunk size. They are for proofing and slides:

```r
source("figure-packages/literature-review/R/literature-review.R")
literature_review_save()      # writes figures/literature-review.{png,pdf}
```

Requires `png` and `grid`; `literature_review_save()` also needs `ragg`.
