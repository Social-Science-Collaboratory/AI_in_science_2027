# Literature critique multipanel: Figure 2 of
# weeks/05-literature-review-critiquing.qmd.
# Usage: literature_critique_plot(width); literature_critique_save() writes figures/.

library(grid)

# Panel sources, in layout order (paths relative to the project root).
LITCRITIQUE_PANELS <- c(
  A = "figure-packages/literature-critique/images/panel-a-insight-mountain.png",
  B = "figure-packages/literature-critique/images/panel-b-path-to-truth.png",
  C = "figure-packages/literature-critique/images/panel-c-hand-that-feeds.png"
)

# Panel captions, drawn beside each bold letter.
LITCRITIQUE_LABELS <- c(
  A = "Bracing for an onslaught of AI-generated insight",
  B = "Hazards on the path to the truth",
  C = "The hand that feeds us is the hand we feed"
)


#' Geometry for the multipanel, in inches
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

  # Row 1: columns split in proportion to the panels' aspect ratios.
  avail <- inner - gap
  w_a <- avail * aspect[["A"]] / (aspect[["A"]] + aspect[["B"]])
  w_b <- avail - w_a
  row1_image <- w_a / aspect[["A"]]

  # Row 2: panel C at row 1's height, centred in the inner width.
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
#' `x`/`y` are the inch coordinates of the cell's top-left corner; the image
#' is centred within a cell `cell_w` wide.
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

  # Offset the description by the rendered width of the letter and a space.
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
#' Measuring needs an open device, so this is a no-op if there is none.
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
#' @param width Figure width in inches.
#' @return Invisibly, the layout list (its `height` is the fig-height the
#'   calling chunk should declare).
literature_critique_plot <- function(width = 12, ...) {
  lay <- literature_critique_layout(width = width, ...)
  imgs <- lapply(LITCRITIQUE_PANELS, png::readPNG)

  grid.newpage()
  check_litcritique_labels(lay)
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


#' Write standalone PNG and PDF copies into the package's figures/ folder
literature_critique_save <- function(
    width = 12,
    dir = "figure-packages/literature-critique/figures") {
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
