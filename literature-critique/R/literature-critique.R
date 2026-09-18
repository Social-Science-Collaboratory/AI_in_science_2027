# literature-critique.R ---------------------------------------------------
#
# Figure package for the illustrations used as Figure 2 of
# weeks/05-literature-review-critiquing.qmd.
#
# Three illustrations, laid out as a 2-row multipanel at the same 12in width
# the week-summary figure uses:
#
#   row 1   A  insights generated faster than anyone can read them
#           B  the hazards between a literature search and the truth
#   row 2   C  the exchange between AI and the literature it is fed
#
# Same construction as checkin-workflow/R/checkin-workflow.R: panels are placed
# with grid rather than composited into a bitmap, so the labels stay vector in
# the PDF build. Only png and grid are needed.

library(grid)

# Panel sources, in layout order. Paths are project-root relative because
# _quarto.yml sets execute-dir: project.
LITCRITIQUE_PANELS <- c(
  A = "literature-critique/images/panel-a-insight-mountain.png",
  B = "literature-critique/images/panel-b-path-to-truth.png",
  C = "literature-critique/images/panel-c-hand-that-feeds.png"
)

# Panel captions, drawn on the figure beside each bold letter. Kept here rather
# than inline in the draw calls so the wording lives next to the sources it
# describes, and so a reader can check the two lists agree panel by panel.
LITCRITIQUE_LABELS <- c(
  A = "Bracing for an onslaught of AI-generated insight",
  B = "Hazards on the path to the truth",
  C = "The hand that feeds us is the hand we feed"
)


#' Geometry for the multipanel, in inches
#'
#' Panel heights follow from the source aspect ratios, so the layout cannot
#' drift if an illustration is later replaced with one of different
#' proportions.
literature_critique_layout <- function(width = 12,
                                       margin = 0.12,
                                       gap = 0.20,
                                       row_gap = 0.30,
                                       label_height = 0.26) {
  aspect <- vapply(LITCRITIQUE_PANELS, function(p) {
    d <- dim(png::readPNG(p))       # rows (height) x cols (width) x channels
    d[2] / d[1]
  }, numeric(1))

  inner <- width - 2 * margin

  # Row 1: the two columns are split in proportion to the panels' aspect
  # ratios rather than given equal halves. A is near-square and B is portrait,
  # so equal halves would leave B towering over A; splitting by aspect makes
  # both panels exactly the same height with no padding, at the cost of
  # unequal column widths (about 7.3in against 4.2in).
  avail <- inner - gap
  w_a <- avail * aspect[["A"]] / (aspect[["A"]] + aspect[["B"]])
  w_b <- avail - w_a
  row1_image <- w_a / aspect[["A"]]

  # Row 2: panel C is centred at row 1's height rather than spanning the inner
  # width the way checkin-workflow's panel C does. That panel was 16:9; this
  # one is 1.28:1, so spanning 11.76in would draw it 9.2in tall - half again
  # as tall as the whole first row, and the figure would read as one big image
  # with two thumbnails above it. Matching row 1's height instead costs a white
  # gutter either side but keeps the three panels weighted alike.
  h_c <- row1_image
  w_c <- min(h_c * aspect[["C"]], inner)
  h_c <- w_c / aspect[["C"]]

  height <- margin + label_height + row1_image + row_gap +
    label_height + h_c + margin

  list(
    width = width, height = height,
    margin = margin, gap = gap, row_gap = row_gap,
    label_height = label_height,
    row1_image = row1_image,
    inner = inner,
    panel = list(
      A = list(w = w_a, h = row1_image),
      B = list(w = w_b, h = row1_image),
      C = list(w = w_c, h = h_c)
    )
  )
}


#' Draw one labelled panel at an absolute position on the canvas
#'
#' `x`/`y` are the inch coordinates of the cell's top-left corner; the image is
#' centred horizontally within a cell `cell_w` wide and hangs from the top so
#' panels in the same row share a baseline at the top rather than the bottom.
#' The label sits at the cell's left edge, not over the centred image, so the
#' three letters line up down the page. Images are drawn without a frame: each
#' source already carries its own white background, and a hairline around every
#' panel read as chart junk.
draw_litcritique_panel <- function(img, label, desc, x, y, cell_w, img_w, img_h,
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
  # stay butted together if the fontsize or the letter ever changes; grid
  # counts a trailing space in a string's width, which is what makes this work.
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
    x = unit(x + (cell_w - img_w) / 2, "in"),
    y = unit(y - label_height - img_h, "in"),
    width = unit(img_w, "in"), height = unit(img_h, "in"),
    hjust = 0, vjust = 0, interpolate = TRUE
  )
}


#' Warn if any label is wider than the column it sits over
#'
#' Panel B's column is only about 4in, which is narrow enough that a label of
#' ordinary length overflows it and eats into the figure's right margin. The
#' overflow is invisible in the layout arithmetic - grid just draws past the
#' cell - so it is checked here rather than left for someone to notice on the
#' rendered page. Measuring needs an open device, so this is a no-op if there
#' is none.
check_litcritique_labels <- function(lay) {
  if (dev.cur() == 1L) return(invisible(NULL))
  for (k in names(LITCRITIQUE_PANELS)) {
    txt <- paste0(k, ". ", LITCRITIQUE_LABELS[[k]])
    w <- convertWidth(
      grobWidth(textGrob(txt, gp = gpar(fontsize = 13))), "in", valueOnly = TRUE
    )
    cell <- if (k == "C") lay$inner else lay$panel[[k]]$w
    if (w > cell) {
      warning(sprintf(
        "panel %s label is %.2fin wide over a %.2fin column - shorten it",
        k, w, cell
      ), call. = FALSE)
    }
  }
  invisible(NULL)
}


#' Draw the literature critique multipanel
#'
#' @param width Figure width in inches; 12 matches the week-summary figure.
#' @return Invisibly, the layout list (its `height` is the fig-height the
#'   calling chunk should declare).
literature_critique_plot <- function(width = 12, ...) {
  lay <- literature_critique_layout(width = width, ...)
  imgs <- lapply(LITCRITIQUE_PANELS, png::readPNG)

  grid.newpage()
  check_litcritique_labels(lay)
  # Panel C carries transparent corners, so the canvas has to be painted white
  # or its dark text lands on whatever the device leaves behind.
  grid.rect(gp = gpar(fill = "white", col = NA))

  top <- lay$height - lay$margin

  draw_litcritique_panel(
    imgs$A, "A", LITCRITIQUE_LABELS[["A"]],
    x = lay$margin, y = top,
    cell_w = lay$panel$A$w,
    img_w = lay$panel$A$w, img_h = lay$panel$A$h,
    label_height = lay$label_height
  )
  draw_litcritique_panel(
    imgs$B, "B", LITCRITIQUE_LABELS[["B"]],
    x = lay$margin + lay$panel$A$w + lay$gap, y = top,
    cell_w = lay$panel$B$w,
    img_w = lay$panel$B$w, img_h = lay$panel$B$h,
    label_height = lay$label_height
  )

  row2_top <- top - lay$label_height - lay$row1_image - lay$row_gap
  draw_litcritique_panel(
    imgs$C, "C", LITCRITIQUE_LABELS[["C"]],
    x = lay$margin, y = row2_top,
    cell_w = lay$inner,
    img_w = lay$panel$C$w, img_h = lay$panel$C$h,
    label_height = lay$label_height
  )

  invisible(lay)
}


#' Write standalone PNG and PDF copies into literature-critique/figures/
literature_critique_save <- function(width = 12,
                                     dir = "literature-critique/figures") {
  lay <- literature_critique_layout(width = width)
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)

  ragg::agg_png(
    file.path(dir, "literature-critique.png"),
    width = lay$width, height = lay$height, units = "in", res = 300
  )
  literature_critique_plot(width = width)
  dev.off()

  pdf(
    file.path(dir, "literature-critique.pdf"),
    width = lay$width, height = lay$height
  )
  literature_critique_plot(width = width)
  dev.off()

  invisible(lay)
}
