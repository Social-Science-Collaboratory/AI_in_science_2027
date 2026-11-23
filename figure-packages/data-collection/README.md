# data-collection — Figure 2 of the Data Collection (Using) chapter

Figure package for `weeks/06-data-collection-using.qmd`: a grant proposal's
workflow (panel A, a supplied PNG) placed beside its title and abstract
(panel B, drawn as text) with `grid`, in the same construction as
`literature-review/`.

```r
source("figure-packages/data-collection/R/data-collection.R")   # setup chunk
data_collection_plot()                              # fig-width 12, fig-height 5.33
```

| panel | source | label drawn on the figure |
| --- | --- | --- |
| A | `images/panel-a-grant-workflow.png` | Visual summary of the proposed workflow |
| B | `data/grant-summary.txt` (set as text) | Technical summary of the grant |

Panel A is the five-step "science with AI in five easy steps" workflow. Panel B
sets `grant-summary.txt` at the largest font size that fits panel A's height.

Columns are split from panel A's aspect ratio and a fixed footprint for panel B
(`DATACOLL_B_ASPECT`). Replacing panel A with different proportions needs no
code change, but the chunk's `fig-height` must then equal
`data_collection_layout()$height`.

`data_collection_save()` writes `figures/data-collection.png` for proofing. It
needs `ragg`.
