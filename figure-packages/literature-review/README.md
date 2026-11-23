# literature-review — Figure 2 of the Literature Review chapter

Self-contained figure package for `weeks/04-literature-review-using.qmd`. Same
construction as `checkin-workflow/`: two supplied PNGs placed side by side with
`grid`.

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

The columns are split in proportion to the two images' aspect ratios, so both
panels are the same height. Replacing a panel with an image of different
proportions needs no code change, but the chunk's `fig-height` must then equal
`literature_review_layout()$height`, and `fig-width` must stay the value the
layout was solved at.

## Regenerating

The book does not use `figures/` — it calls `literature_review_plot()` and lets
Quarto draw the figure at chunk size. They are for proofing and slides:

```r
source("figure-packages/literature-review/R/literature-review.R")
literature_review_save()      # writes figures/literature-review.{png,pdf}
```

Requires `png` and `grid`; `literature_review_save()` also needs `ragg`.
