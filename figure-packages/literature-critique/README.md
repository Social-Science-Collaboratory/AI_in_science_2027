# literature-critique — Figure 2 of the Literature Review (Critiquing) chapter

Figure package for Figure 2 of `weeks/05-literature-review-critiquing.qmd` — the
three illustrations of what AI-assisted literature review costs the literature
itself.

Like `week-summary/`, `literature-review/` and `checkin-workflow/`, this is a
figure package rather than a chapter: `_quarto.yml` does not render anything
here, and the chapter sources `R/literature-critique.R` by its project-root
relative path.

## Layout

| Panel | Source | Shows |
|---|---|---|
| A | `images/panel-a-insight-mountain.png` | Insights generated faster than anyone can read them, posted to Bluesky |
| B | `images/panel-b-path-to-truth.png` | A reader picking a path to the truth past hallucinations, fake citations, synthetic sources and AI slop |
| C | `images/panel-c-hand-that-feeds.png` | The loop between AI and the literature — the hand that feeds us is the hand we feed |

A and B share the top row, with columns split in proportion to their aspect
ratios so both are the same height. C sits alone in the second row, centred at
row 1's image height. Total width is 12in.

Panel labels are held in `LITCRITIQUE_LABELS`, next to `LITCRITIQUE_PANELS`.
`check_litcritique_labels()` warns at draw time if a label is wider than its
column; panel B's column is narrow (about 4.24in), so keep its label short.

## Usage

```r
source("figure-packages/literature-critique/R/literature-critique.R")
literature_critique_plot()            # fig-width 12, fig-height 13.77
literature_critique_save()            # writes figures/literature-critique.{png,pdf}
literature_critique_layout()$height   # fig-height the calling chunk should declare
```

The chunk's `fig-height` must equal `literature_critique_layout()$height`
(13.77in at the default 12in width). Replacing an illustration with one of
different proportions changes that number — re-run
`literature_critique_layout()` and update the chunk.

The chunk sets `fig-dpi: 100`, which roughly matches the sources' own
resolution; revisit it if a panel is replaced with a higher-resolution image.

Requires `png` and `grid`; `literature_critique_save()` also needs `ragg`.
