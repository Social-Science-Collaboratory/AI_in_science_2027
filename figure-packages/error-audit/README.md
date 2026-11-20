# error-audit — the AI error-audit figure for the "What Should Count?" chapter

Figure package for `weeks/12-ethics-what-should-count.qmd`: an AI audit of a
lab's past work, as the community saw it and as the instructor received it.

Like `outreach-agent/`, this is a figure package rather than a chapter:
`_quarto.yml` does not render anything here, and the chapter sources
`R/error-audit.R` by its project-root relative path.

## Layout

| Panel | Source | Title |
|---|---|---|
| A | `images/panel-a-audit-post.png` | Instructor's previous supervisor uses AI to audit every project for errors |
| B | `images/panel-b-community-response.png` | Community points out that open science reform enables such discoveries in the first place |
| C | `images/panel-c-supervisor-email.png` | Instructor receives email from previous supervisor |

A and B share the first row and C has the second row to itself, at 12in total
width to match `week_summary_plot()`. Row 1's columns are split in proportion
to A's and B's aspect ratios, so both screenshots are drawn at the same height.
Titles wrap to their column width (B's takes two lines), and the figure's
height is computed from the wrapped titles and the image sizes. All three
panels are screenshots: two Bluesky posts and one email.

Each title ends with an emoji (😱 A, 🙌 B, 💀 C). These are the
`images/emoji-*.png` files, rendered once from Apple Color Emoji and drawn as
images, because R's `pdf()` device cannot draw colour emoji as text. To swap
one, render a new transparent PNG the same way and save over the file.

## Using it in the chapter

Because the height depends on measured title widths, ask for it rather than
hard-coding it:

```r
source("figure-packages/error-audit/R/error-audit.R")
error_audit_height()   # about 8.70 at width = 12
```

and declare that value as the chunk's `fig-height` (with `fig-width: 12`),
calling `error_audit_plot()` in the chunk.

## Regenerating the standalone copies

```r
source("figure-packages/error-audit/R/error-audit.R")
error_audit_save()   # writes figures/error-audit.png and .pdf
```
