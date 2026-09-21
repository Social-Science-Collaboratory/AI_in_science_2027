# literature-review.R -----------------------------------------------------
#
# Figure package for the literature review vignette used as Figure 2 of
# weeks/04-literature-review-using.qmd.
#
# Two panels in a single row, at the same 12in width the week-summary figure
# uses:
#
#   A  the workflow diagram, drawn for the seminar
#   B  a screenshot of that workflow running
#
# Same construction as figure-packages/checkin-workflow/R/checkin-workflow.R:
# panels are placed with grid rather than composited into a bitmap, so the
# labels stay vector in the PDF build. Only png and grid are needed.

library(grid)

# Panel sources, in layout order. Paths are project-root relative because
# _quarto.yml sets execute-dir: project.
LITREVIEW_PANELS <- c(
  A = "figure-packages/literature-review/images/panel-a-workflow.png",
  B = "figure-packages/literature-review/images/panel-b-demo.png"
)

# Panel captions, drawn on the figure beside each bold letter. Kept here rather
# than inline in the draw calls so the wording lives next to the sources it
# describes.
LITREVIEW_LABELS <- c(
  A = "Overview of AI-assisted literature review workflow",
  B = "Demo of AI-assisted literature review workflow"
)


#' Geometry for the two-panel row, in inches
#'
#' Panel A is a near-square diagram and panel B a 16:9 screenshot, so equal
#' halves would leave A towering over B with white space beside it. Splitting
#' the row in proportion to the two aspect ratios instead makes both panels
#' exactly the same height with no padding, at the cost of unequal column
#' widths. Heights follow from the sources, so the layout cannot drift if a
#' panel is later replaced with one of different proportions.
literature_review_layout <- function(width = 12,
                                     margin = 0.12,
                                     gap = 0.20,
                                     label_height = 0.26) {
  aspect <- vapply(LITREVIEW_PANELS, function(p) {
    d <- dim(png::readPNG(p))       # rows (height) x cols (width) x channels
    d[2] / d[1]
  }, numeric(1))

  inner <- width - 2 * margin
  avail <- inner - gap

  w_a <- avail * aspect[["A"]] / (aspect[["A"]] + aspect[["B"]])
  w_b <- avail - w_a
  row_image <- w_a / aspect[["A"]]

  height <- margin + label_height + row_image + margin

  list(
    width = width, height = height,
    margin = margin, gap = gap,
    label_height = label_height,
    row_image = row_image,
    panel = list(
      A = list(w = w_a, h = row_image),
      B = list(w = w_b, h = row_image)
    )
  )
}


#' Draw one labelled panel at an absolute position on the canvas
#'
#' `x`/`y` are the inch coordinates of the cell's top-left corner; the image
#' hangs from the top so both panels share a baseline at the top. Images are
#' drawn without a frame: panel B is a screenshot that carries its own window
#' chrome, and a hairline around either read as chart junk on the page.
draw_litreview_panel <- function(img, label, desc, x, y, img_w, img_h,
                                 label_height) {
  letter <- paste0(label, ".")
  letter_gp <- gpar(fontface = "bold",  fontsize = 13, col = "grey15")
  desc_gp   <- gpar(fontface = "plain", fontsize = 13, col = "grey15")
  y_mid <- unit(y - label_height / 2, "in")

  grid.text(
    letter,
    x = unit(x, "in"), y = y_mid,
    hjust = 0, vjust = 0.5, gp = letter_gp
  )

  # The description starts past the bold letter and a word space. That offset
  # is measured off the rendered glyphs rather than guessed at, so the two runs
  # stay butted together if the fontsize ever changes; grid counts a trailing
  # space in a string's width, which is what makes this work.
  lead <- convertWidth(
    grobWidth(textGrob(paste0(letter, " "), gp = letter_gp)),
    "in", valueOnly = TRUE
  )
  grid.text(
    desc,
    x = unit(x + lead, "in"), y = y_mid,
    hjust = 0, vjust = 0.5, gp = desc_gp
  )

  grid.raster(
    img,
    x = unit(x, "in"), y = unit(y - label_height - img_h, "in"),
    width = unit(img_w, "in"), height = unit(img_h, "in"),
    hjust = 0, vjust = 0, interpolate = TRUE
  )
}


#' Draw the literature review multipanel
#'
#' @param width Figure width in inches; 12 matches the week-summary figure.
#' @return Invisibly, the layout list (its `height` is the fig-height the
#'   calling chunk should declare).
literature_review_plot <- function(width = 12, ...) {
  lay <- literature_review_layout(width = width, ...)
  imgs <- lapply(LITREVIEW_PANELS, png::readPNG)

  grid.newpage()
  # Panel A is a transparent PNG, so the canvas has to be painted white or the
  # diagram's dark text lands on whatever the device leaves behind.
  grid.rect(gp = gpar(fill = "white", col = NA))

  top <- lay$height - lay$margin

  draw_litreview_panel(
    imgs$A, "A", LITREVIEW_LABELS[["A"]],
    x = lay$margin, y = top,
    img_w = lay$panel$A$w, img_h = lay$panel$A$h,
    label_height = lay$label_height
  )
  draw_litreview_panel(
    imgs$B, "B", LITREVIEW_LABELS[["B"]],
    x = lay$margin + lay$panel$A$w + lay$gap, y = top,
    img_w = lay$panel$B$w, img_h = lay$panel$B$h,
    label_height = lay$label_height
  )

  invisible(lay)
}


#' Write standalone PNG and PDF copies into the package's figures/ folder
literature_review_save <- function(
    width = 12,
    dir = "figure-packages/literature-review/figures") {
  lay <- literature_review_layout(width = width)
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)

  ragg::agg_png(
    file.path(dir, "literature-review.png"),
    width = lay$width, height = lay$height, units = "in", res = 300
  )
  literature_review_plot(width = width)
  dev.off()

  pdf(
    file.path(dir, "literature-review.pdf"),
    width = lay$width, height = lay$height
  )
  literature_review_plot(width = width)
  dev.off()

  invisible(lay)
}
