# outreach-agent — Figure 2 of the Outreach and Dissemination chapter

Figure package for `@fig-week-11-outreach-agent` in `weeks/11-outreach.qmd`:
what an AI outreach agent does, set beside what it costs the people on the
receiving end.

Like `literature-critique/`, this is a figure package rather than a chapter:
`_quarto.yml` does not render anything here, and the chapter sources
`R/outreach-agent.R` by its project-root relative path.

## Layout

| Panel | Source | Shows |
|---|---|---|
| A | `images/panel-a-outreach-agent-workflow.png` | The agent's loop: review the research portfolio, build an outreach list, send personalized outreach, brief the PI, and the researcher adjusts |
| B | `images/panel-b-ai-overload.png` | A researcher buried in AI-generated messages, missing the humans trying to reach them |

The two panels sit side by side at 12in total width, with columns split in
proportion to the images' aspect ratios so both are drawn at the same height.
The chunk's `fig-height` must equal `outreach_agent_layout()$height`.

## Where the panels come from

**Panel A** is drawn in draw.io. Its source is **not** in this folder: it is
the `Wk11_Outreach` tab of `figure-packages/class-structure/class-structure.drawio`,
alongside the seminar-structure diagram. To edit it, open that file, switch to
the `Wk11_Outreach` tab, then **File → Export as → PNG** and save over
`images/panel-a-outreach-agent-workflow.png`.

**Panel B** was generated with ChatGPT. There is no source beyond the PNG;
replacing it means generating a new image and saving it over
`images/panel-b-ai-overload.png`.

## Regenerating the standalone copies

The chapter draws the figure live, so `figures/` is only a convenience copy
for review or for use outside the book:

```r
source("figure-packages/outreach-agent/R/outreach-agent.R")
outreach_agent_save()   # writes figures/outreach-agent.png and .pdf
```
