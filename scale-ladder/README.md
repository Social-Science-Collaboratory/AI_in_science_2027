# Scale ladder — co-authors on flagship AI model reports

Self-contained figure package for the AI Race Observatory, living inside the
2027 UF Guide to AI in Science book.

## How the book uses it

`index.qmd` sources the R and calls the plot function directly:

```r
source("scale-ladder/R/scale-ladder.R")   # setup chunk
scale_ladder_plot(fig_width = 7.5)        # chunk labelled fig-scale-ladder
```

Pass `scale_ladder_plot()` the same width you give the chunk's `fig-width`. The
label spacing is solved against it — the labels are a fixed size in inches, the
dot blocks a fixed size in data units, and `coord_fixed` ties the two together —
so a mismatch is what makes names collide. Narrow it too far and the names stop fitting,
and the layout warns and tells you by how much.

The width is also the legibility knob. The book scales the figure to the column,
so a *smaller* `fig_width` renders the text proportionally larger -- at the cost
of the dot blocks, which shrink with it. 7.5in is the balance point where GPT-1
and GPT-2 are still visible as blocks.

Height matters too, and not as a free choice: `coord_fixed` scales the drawing to
whichever of the two axes runs out first, so a height that is too small letterboxes
the figure and leaves a white margin down both sides. 7.5 x 2.4in is the pair that
fills the frame in both directions -- recheck it if you change the label text, since
that moves the aspect ratio.

The R resolves its own paths (see `scale_ladder_root` at the top of
`R/scale-ladder.R`), so `data/` and `figures/` work whether the script is
sourced from the project root or run from inside this folder.

This folder is excluded from the book render via `project: render:` in
`../_quarto.yml`, so `figure-scale-ladder.qmd` does not become a stray page.

**The bibliography is deliberately not wired in.** `figure_references_for_review.bib`
is held separate from the book's `references.bib` pending a source review, which
is why the figure caption in `index.qmd` carries no citations yet. Merging it in
is what unlocks the cited prose drafted in `figure-scale-ladder.qmd`.

## Contents

```
scale-ladder/
├─ R/scale-ladder.R                     the figure, in ggplot2
├─ build-figure.js                      the same figure, in HTML/CSS
├─ figure-scale-ladder.qmd              working Quarto chunk + draft body copy
├─ figure_references_for_review.bib     every source, plus ATLAS/LIGO anchors
│                                      (held out of the book's bibliography)
├─ data/
│  ├─ frontier-model-authors.csv        the plotted data
│  └─ frontier-model-blanks.csv         labs that publish no author list
└─ figures/
   ├─ scale-ladder.png                  6560×1364 raster (≈600 dpi at 11in)
   └─ scale-ladder-figure.html          HTML render, output of build-figure.js
```

## The figure

One small square = one credited co-author. Each report is drawn as a near-square
block, so **block area is proportional to the author count** — four times the people is
four times the ink. There is no y axis on purpose: the y positions are rows
inside a block, not a measured quantity, so an axis would invite a false
reading. The printed count under each block carries the value.

Colour is the lab, using Okabe–Ito hues (colourblind-safe, and still distinct at
1 px mark size). Each square is sized as a fraction of its grid cell (`mark_fill`)
rather than in millimetres, so the grid keeps reading as separate marks at any
figure width.

## Regenerating

R, for the book:

```r
source("R/scale-ladder.R")   # defines scale_ladder_plot()
scale_ladder_plot(fig_width = 7.5)
```

Run the file directly (`Rscript R/scale-ladder.R`) and it writes both
`figures/scale-ladder.png` at 600 dpi and `figures/scale-ladder.pdf` as vector.
The book does not use either — it calls the plot function and lets Quarto draw
the figure — so these are for proofing and for reuse in slides and posters.
The PDF prefers `cairo_pdf` and falls back to the stock device on a build
without a working cairo (macOS without XQuartz).

Requires `ggplot2`, `dplyr`, `readr`, and `ragg` for the raster export.

HTML, for the web version:

```
node build-figure.js
```

Edit the `REPORTS` table at the top of `build-figure.js` or the CSV for R — the
two encode the same data, so keep them in step.

**The two have drifted.** The R is what the book renders, and it has since moved
to square marks, dropped the 2017 Transformer row and the open-weight labs, and
gone to year-only labels. `build-figure.js` still draws circles and the full
series. Bring it back in line before using the HTML version anywhere.

## Counting policy

Two questions decide every number in this table, and the answers have to be the
same for every row or the series measures two different things at once.

**Which version?** The original release — arXiv v1, or the published version of
record. Never a later revision. Several of these reports have grown by hundreds
of names in revisions posted years after launch, so a table that mixes v1 for
some rows and the current revision for others, while showing the original date
throughout, plots a trend that partly reflects when each list was last edited.
The `date` column always matches the version that was counted.

**Who counts as an author?** Named individual people. An institutional byline --
"OpenAI", "Gemini Team", "DeepSeek-AI", "Kimi Team" -- is not a person and is
not counted. Where the byline is institutional and the real credit list lives in
a contributions appendix, the appendix is what gets counted. Names appearing
twice in one list are counted once.

## Data provenance

Every row in `data/frontier-model-authors.csv` carries a `bibkey`, a `doi` where
one exists, an arXiv id, a note on where in the document the count was read
from, and a `verified` date. `data/verification-log.md` records what was checked
against which source.

`frontier-model-blanks.csv` holds the labs that still publish nothing
nameable — Anthropic, xAI, Gemini 3. They can't be plotted, which is itself part
of the argument.
