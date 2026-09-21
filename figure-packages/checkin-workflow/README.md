# checkin-workflow

Figure package for Figure 2 of `weeks/02-project-management-using.qmd` — the
worked example of a lab that commits weekly trainee check-ins to a shared
repository and then queries an LLM against the accumulated record.

Like `week-summary/` and `scale-ladder/`, this is a figure package rather than
a chapter: `_quarto.yml` does not render anything here, and the chapter sources
`R/checkin-workflow.R` by its project-root-relative path.

## Layout

| Panel | Source | Shows |
|---|---|---|
| A | `images/panel-a-checkin-repo.png` | The check-in repository: one `.qmd` per week per trainee, with the PI's inline comments in the margin |
| B | `images/panel-b-llm-query.png` | The LLM queried about the accumulated check-ins, reading across all 19 of one trainee's entries at once |
| C | `images/panel-c-mobility-prepost-mockup.png` | The mock-up figure produced in that conversation and sent back to the trainee to convey next steps |

A and B share the top row; C spans the second row at full width. Total width is
12in, matching `week_summary_plot()` so the two figures in the chapter align.

Row 1's two columns are split in proportion to the screenshots' aspect ratios
rather than given equal halves. Equal halves left B — the wider image — shorter
than A and floating in white space. Splitting by aspect makes both panels
exactly the same height with no padding, at the cost of slightly unequal
column widths (5.51in vs 6.05in), which reads as the lesser flaw.

## Panel labels

Each panel carries a bold letter followed by a plain-weight description, held in
`CHECKIN_LABELS` next to `CHECKIN_PANELS` so the two lists can be checked against
each other panel by panel. The description is offset by the *measured* width of
the bold letter plus a space rather than a guessed indent, so the two runs stay
butted together if the fontsize changes. At 13pt the longest label is about
5.2in against panel C's 11.76in, so none of the three crowds its column.

## Panel C

Panel C is a supplied 4800 x 2700 export
(`images/panel-c-mobility-prepost-mockup.png`), drawn at the figure's full inner
width of 11.76in — about 408 dpi, so nothing is upscaled.

It replaced an earlier variable-importance mockup. That predecessor and its
generator (`images/panel-c-simulated-figure.png` and
`R/panel-c-migration-varimp.R`) are still in the tree but no longer referenced
by `checkin-workflow.R`; delete both if the old panel is not coming back.

## The MOCK watermark

Panel C is a *simulated* result — a figure generated to communicate an intended
analysis, not to report one that was run. The `MOCK` overlay is clipped to
panel C alone: A and B are genuine screenshots, and marking them would wrongly
imply the whole workflow was staged. It is a single word laid diagonally across
the panel — an earlier tiled version competed with the plotted points for
attention. It is on by default; `checkin_workflow_plot(watermark = FALSE)`
turns it off.

The word is sized to the panel rather than to a fixed point size, fitting the
rotated text box against *both* axes; solving for width alone overflows the
short axis and clips the M and K against the panel edge.

## Usage

```r
source("figure-packages/checkin-workflow/R/checkin-workflow.R")
checkin_workflow_plot()          # draw into the current device
checkin_workflow_save()          # write figures/checkin-workflow.{png,pdf}
checkin_workflow_layout()$height # fig-height the calling chunk should declare
```

The chunk's `fig-height` must match `checkin_workflow_layout()$height` (11.24in
at the default 12in width), or grid will stretch the panels. Replacing a
screenshot with one of different proportions changes that number — re-run
`checkin_workflow_layout()` and update the chunk. Panel C's swap is what moved
it from 11.63in to 11.24in.

Panels are placed with `grid` and `png::readPNG` rather than composited into a
bitmap, so the labels and the watermark stay vector in the PDF build. No
`magick` package or ImageMagick CLI is required.

Panel images are drawn without a frame. Each source already carries its own
light background, so a hairline around every panel read as chart junk.
