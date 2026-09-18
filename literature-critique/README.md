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

A and B share the top row; C sits alone in the second row. Total width is 12in,
matching `week_summary_plot()` so the two figures in the chapter align.

Row 1's two columns are split in proportion to the illustrations' aspect ratios
rather than given equal halves. A is near-square (1168x1014) and B is portrait
(1024x1536), so equal halves would leave B towering over A; splitting by aspect
makes both panels exactly the same height with no padding, at the cost of
unequal column widths (7.32in against 4.24in).

The pairing is what fixes the letters. The Bluesky post is the roundest of the
three, so it costs the least height beside the portrait, and the widest image —
the hand — is the one that earns a row of its own. Panel order therefore follows
the geometry, not the order the chapter discusses them in; the prose cites C, B,
then A.

## Why panel C does not span the width

`checkin-workflow`'s panel C spans the full inner width because it is a 16:9
export. This one is 1.28:1 (1417x1110), and spanning 11.76in would draw it
9.21in tall — half again as tall as the entire first row. The figure would then
read as one big image with two thumbnails above it.

Panel C is instead centred at **row 1's image height**, which lands it at
8.11in wide. That costs a white gutter either side but keeps the three panels
weighted alike. Panel letters stay at their cell's left edge, so A and C line up
down the page even though C's image is centred.

## Panel labels

Each panel carries a bold letter followed by a plain-weight description, held in
`LITCRITIQUE_LABELS` next to `LITCRITIQUE_PANELS` so the two lists can be
checked against each other panel by panel. The description is offset by the
*measured* width of the bold letter plus a space rather than a guessed indent,
so the two runs stay butted together if the fontsize changes.

Panel B's column is only 4.24in wide — narrow enough that a label of ordinary
length overflows it and eats the figure's right margin, which the layout
arithmetic cannot see because grid simply draws past the cell.
`check_litcritique_labels()` measures each label against its column at draw time
and warns rather than leaving it to be spotted on the rendered page. It is why
panel B's label is the terse one of the three.

## Usage

```r
source("literature-critique/R/literature-critique.R")
literature_critique_plot()            # fig-width 12, fig-height 13.77
literature_critique_save()            # writes figures/literature-critique.{png,pdf}
literature_critique_layout()$height   # fig-height the calling chunk should declare
```

The chunk's `fig-height` must match `literature_critique_layout()$height` (13.77in
at the default 12in width), or grid will stretch the panels. Replacing an
illustration with one of different proportions changes that number — re-run
`literature_critique_layout()` and update the chunk.

## Why the chunk sets fig-dpi: 100

Unlike the other figure packages, these three panels are illustrations rather
than screenshots, and they are small — 1024 to 1417px wide. The book's
`fig-dpi: 300` is doubled by HTML's `fig-retina: 2`, so the chunk would
rasterise the figure at an effective 600dpi, upscaling every panel about 3x and
landing a **33MB PNG** on the page — seven times the heaviest figure elsewhere
in the book. The chunk therefore sets `fig-dpi: 100`, an effective 200dpi, which
is about the sources' own resolution and renders at 7.0MB.

If a panel is ever replaced with a higher-resolution source, that number is
worth revisiting; nothing is gained by rendering above what the sources carry.

Panels are placed with `grid` and `png::readPNG` rather than composited into a
bitmap, so the labels stay vector in the PDF build. No `magick` package or
ImageMagick CLI is required. `literature_critique_save()` also needs `ragg`.

Panel images are drawn without a frame — each source already carries its own
white background — and the canvas is painted white first, because panel C has
transparent corners.
