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

A and B share the top row, with columns split in proportion to their aspect
ratios so both are the same height; C spans the second row at full width.
Total width is 12in. Panel labels are held in `CHECKIN_LABELS`, next to
`CHECKIN_PANELS`.

Panel C is a simulated result, so a diagonal `MOCK` watermark is drawn over
panel C only. It is on by default; `checkin_workflow_plot(watermark = FALSE)`
turns it off.

## Usage

```r
source("figure-packages/checkin-workflow/R/checkin-workflow.R")
checkin_workflow_plot()          # draw into the current device
checkin_workflow_save()          # write figures/checkin-workflow.{png,pdf}
checkin_workflow_layout()$height # fig-height the calling chunk should declare
```

The chunk's `fig-height` must equal `checkin_workflow_layout()$height` (11.24in
at the default 12in width). Replacing a screenshot with one of different
proportions changes that number — re-run `checkin_workflow_layout()` and update
the chunk.

Requires `png` and `grid`; `checkin_workflow_save()` also needs `ragg`.
