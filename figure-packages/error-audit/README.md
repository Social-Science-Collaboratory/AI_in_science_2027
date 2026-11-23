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

All three panels are screenshots: two Bluesky posts and one email. A and B
share the first row, with columns split in proportion to their aspect ratios;
C has the second row to itself. Total width is 12in. Titles wrap to their
column width, and the figure's height is computed from the wrapped titles and
the image sizes.

Each title ends with an emoji (😱 A, 🙌 B, 💀 C), drawn from the
`images/emoji-*.png` files (rendered from Apple Color Emoji). To swap one, save
a new transparent PNG over the file.

## Using it in the chapter

The chunk's `fig-height` must equal `error_audit_height()`:

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
