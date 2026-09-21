# 2027 UF Guide to AI in Science

Source for the book published at
<https://social-science-collaboratory.github.io/AI_in_science_2027/>.

In Fall 2026, faculty, graduate students, and postdocs across several
departments at the University of Florida ran a seminar — *Collective
\[Artificial\] Intelligence in Science* — documenting how AI is changing each
component of the research workflow. Each week paired a zealot's reading of one
stage of the pipeline with a critic's, then put resources and takeaways to a
Delphi vote. This repository is the write-up of that seminar: a Quarto book,
one chapter per seminar week.

## Layout

```
_quarto.yml          book config: chapter order, format, theme wiring
index.qmd            the preface (sidebar label "Preface")
weeks/NN-*.qmd       one chapter per seminar week; NN is the syllabus week
weeks/images/        one-off images used by a single chapter
references.qmd       the bibliography page
references.bib       the book's bibliography, cited from the chapters
nature.csl           citation style
figure-packages/     self-contained packages that draw the chapters' figures
theme/               SCSS and the HTML partials _quarto.yml pulls in
media/               audio served by the site itself (podcast episodes)
cover.png            book cover art (not currently wired into the build)
```

Chapter files are numbered by their **seminar week**, so the numbering starts
at `02`: week 1 was the Foundations session, which the preface covers.
`weeks/NN-` therefore always equals syllabus week NN.

## Figure packages

Every non-trivial figure in the book lives in its own folder under
`figure-packages/`, with its own README explaining what the figure shows and
why it is drawn the way it is. They are *not* chapters — `project: render:` in
`_quarto.yml` lists only `index.qmd`, `weeks/*.qmd` and `references.qmd`, so
nothing in here becomes a stray page.

| Package | Draws |
| --- | --- |
| `week-summary/` | The opening figure of every content chapter: the week's Delphi vote and its top three resources |
| `scale-ladder/` | Preface: credited co-authors on flagship AI model reports, 2018–2025 |
| `class-structure/` | Preface: the draw.io diagram of how a seminar week ran |
| `checkin-workflow/` | Week 2, Figure 2: the AI-assisted check-in workflow |
| `literature-review/` | Week 4, Figure 2: an AI-assisted literature review, start to finish |
| `literature-critique/` | Week 5, Figure 2: the illustrations the seminar drew to voice its concerns |

A chapter uses one by sourcing its R from the **project root** — chunks run
with `execute-dir: project`, so the path is the same one `index.qmd` uses:

```r
source("figure-packages/week-summary/R/week-summary.R")   # setup chunk
week_summary_plot(week = 5, fig_width = 12, fig_height = 5.5)
```

Read the package's README before changing a figure. Several of them require
the calling chunk's `fig-width`/`fig-height` to match what the draw function is
told, and say so for a reason.

## Building

```sh
quarto preview     # live-reloading local build
quarto render      # full build into _book/ (HTML + PDF)
```

The figure packages need R with `ggplot2`, `ggtext`, `cowplot`, `dplyr`,
`tidyr`, `forcats`, `readr`, `png`, `ragg` and `qrcode`; the PDF build needs a
TeX install. `_book/` and `.quarto/` are build output and are not committed.
