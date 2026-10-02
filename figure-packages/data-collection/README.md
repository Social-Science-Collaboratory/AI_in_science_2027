# data-collection — Figure 2 of the Data Collection (Using) chapter

Figure package for `weeks/06-data-collection-using.qmd`: two supplied PNGs placed
side by side with `grid`, in the same construction as `literature-review/`.
Panel A is a supplied PNG; panel B is the grant's title and abstract drawn as
text, so everything but panel A stays vector.

```r
source("figure-packages/data-collection/R/data-collection.R")   # setup chunk
data_collection_plot()                              # fig-width 12, fig-height 5.33
```

| panel | source | label drawn on the figure |
| --- | --- | --- |
| A | `images/panel-a-grant-workflow.png` | Visual summary of the proposed workflow |
| B | `data/grant-summary.txt` (set as text) | Technical summary of the grant |

Panel A is the five-step "science with AI in five easy steps" workflow. Panel B
is the grant's title and abstract, set in a serif face with no frame. The
proposal's PI, department and funding-request lines are not in
`grant-summary.txt`, so nothing needs to be blocked out. The font size is the
largest that fits the wrapped text to panel A's height.

Columns are split in proportion to panel A's aspect ratio and a fixed footprint
for panel B (`DATACOLL_B_ASPECT`), so both come out the same height. Replacing
panel A with different proportions needs no code change, but the chunk's
`fig-height` must then match `data_collection_layout()$height`.

`data_collection_save()` writes `figures/data-collection.png` for proofing. It
needs `ragg`.
