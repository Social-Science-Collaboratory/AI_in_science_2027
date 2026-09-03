# checkin-workflow.R ------------------------------------------------------
#
# Figure package for the check-in workflow vignette used as Figure 2 of
# weeks/01-project-management-using.qmd.
#
# Three screenshots, laid out as a 2-row multipanel at the same 12in width the
# week-summary figure uses:
#
#   row 1   A  weekly check-ins committed to a shared repository
#           B  the LLM queried about those accumulated check-ins
#   row 2   C  the simulated figure sent back to the trainee
#
# Panels are placed with grid rather than composited into a bitmap, so the
# labels and the MOCK watermark stay vector in the PDF build. Only png and
# grid are needed; neither magick nor an ImageMagick CLI is required.

library(grid)

# Panel sources, in layout order. Paths are project-root relative because
# _quarto.yml sets execute-dir: project.
CHECKIN_PANELS <- c(
  A = "checkin-workflow/images/panel-a-checkin-repo.png",
  B = "checkin-workflow/images/panel-b-llm-query.png",
  C = "checkin-workflow/images/panel-c-simulated-figure.png"
)


#' Geometry for the multipanel, in inches
#'
#' Panel heights follow from the source aspect ratios, so the layout cannot
#' drift if a screenshot is later replaced with one of different proportions.
#' Every panel spans its full column; nothing is padded or centred, so the
#' figure has no white gutters.
checkin_workflow_layout <- function(width = 12,
                                    margin = 0.12,
                                    gap = 0.20,
                                    row_gap = 0.30,
                                    label_height = 0.26) {
  aspect <- vapply(CHECKIN_PANELS, function(p) {
    d <- dim(png::readPNG(p))       # rows (height) x cols (width) x channels
    d[2] / d[1]
  }, numeric(1))

  inner <- width - 2 * margin

  # Row 1: the two columns are split in proportion to the panels' aspect
  # ratios rather than given equal halves. Equal halves would leave the wider
  # screenshot (B) shorter than A and floating in white space; splitting by
  # aspect makes both panels exactly the same height with no padding, at the
  # cost of slightly unequal column widths.
  avail <- inner - gap
  w_a <- avail * aspect[["A"]] / (aspect[["A"]] + aspect[["B"]])
  w_b <- avail - w_a
  row1_image <- w_a / aspect[["A"]]

  # Row 2: panel C spans the full inner width, matching row 1. It is
  # regenerated at this aspect by R/panel-c-migration-varimp.R rather than
  # upscaled, so spanning the width costs no resolution.
  w_c <- inner
  h_c <- w_c / aspect[["C"]]

  height <- margin + label_height + row1_image + row_gap +
    label_height + h_c + margin

  list(
    width = width, height = height,
    margin = margin, gap = gap, row_gap = row_gap,
    label_height = label_height,
    row1_image = row1_image,
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
#' Images are drawn without a frame: every source already has its own light
#' background, and a hairline around each read as chart junk on the page.
draw_panel <- function(img, label, x, y, cell_w, img_w, img_h, label_height) {
  grid.text(
    label,
    x = unit(x, "in"), y = unit(y - label_height / 2, "in"),
    hjust = 0, vjust = 0.5,
    gp = gpar(fontface = "bold", fontsize = 13, col = "grey15")
  )

  img_x <- x + (cell_w - img_w) / 2
  img_y <- y - label_height - img_h

  grid.raster(
    img,
    x = unit(img_x, "in"), y = unit(img_y, "in"),
    width = unit(img_w, "in"), height = unit(img_h, "in"),
    hjust = 0, vjust = 0, interpolate = TRUE
  )
}


#' Single MOCK watermark across one panel's rectangle
#'
#' Scoped to a panel rather than the whole canvas: only panel C is simulated,
#' and marking A and B would wrongly imply the screenshots are fabricated too.
#' One mark laid diagonally across the panel, rather than a tiled lattice: the
#' lattice competed with the plotted points for attention, and the point of the
#' mark is to be read once and then ignored.
draw_mock_watermark <- function(x, y, width, height,
                                angle = 30, span = 0.70, alpha = 0.15) {
  # Size the word to the panel rather than to a hard-coded point size, so it
  # still fits if the panel is regenerated at another aspect. "MOCK FIGURE FOR
  # TRAINEE" in bold is about 14.2 em wide and 0.72 em tall; rotating that box
  # by `angle` spreads it over both axes, and the binding constraint is
  # whichever axis runs out first. Solving only for width (the obvious
  # version) overflows the short axis and clips the letters against the panel
  # edge.
  a <- angle * pi / 180
  em_w <- 14.2
  em_h <- 0.72
  fit_w <- span * width  / (em_w * cos(a) + em_h * sin(a))
  fit_h <- span * height / (em_w * sin(a) + em_h * cos(a))
  fontsize <- 72 * min(fit_w, fit_h)

  pushViewport(viewport(
    x = unit(x, "in"), y = unit(y, "in"),
    width = unit(width, "in"), height = unit(height, "in"),
    just = c("left", "bottom"), clip = "on"
  ))
  on.exit(popViewport())

  grid.text(
    "MOCK FIGURE FOR TRAINEE",
    x = unit(0.5, "npc"), y = unit(0.5, "npc"),
    rot = angle,
    gp = gpar(
      col = "grey45", alpha = alpha,
      fontface = "bold", fontsize = fontsize
    )
  )
}


#' Draw the check-in workflow multipanel
#'
#' @param width Figure width in inches; 12 matches the week-summary figure.
#' @param watermark Draw the MOCK overlay on panel C. TRUE for anything
#'   that leaves the seminar, since panel C is a simulated result rather than a
#'   finding. Panels A and B are real screenshots and are never marked.
#' @return Invisibly, the layout list (its `height` is the fig-height the
#'   calling chunk should declare).
checkin_workflow_plot <- function(width = 12, watermark = TRUE, ...) {
  lay <- checkin_workflow_layout(width = width, ...)
  imgs <- lapply(CHECKIN_PANELS, png::readPNG)

  grid.newpage()
  grid.rect(gp = gpar(fill = "white", col = NA))

  top <- lay$height - lay$margin

  draw_panel(
    imgs$A, "A",
    x = lay$margin, y = top,
    cell_w = lay$panel$A$w,
    img_w = lay$panel$A$w, img_h = lay$panel$A$h,
    label_height = lay$label_height
  )
  draw_panel(
    imgs$B, "B",
    x = lay$margin + lay$panel$A$w + lay$gap, y = top,
    cell_w = lay$panel$B$w,
    img_w = lay$panel$B$w, img_h = lay$panel$B$h,
    label_height = lay$label_height
  )

  row2_top <- top - lay$label_height - lay$row1_image - lay$row_gap
  draw_panel(
    imgs$C, "C",
    x = lay$margin, y = row2_top,
    cell_w = lay$panel$C$w,
    img_w = lay$panel$C$w, img_h = lay$panel$C$h,
    label_height = lay$label_height
  )

  if (watermark) {
    draw_mock_watermark(
      x = lay$margin,
      y = row2_top - lay$label_height - lay$panel$C$h,
      width = lay$panel$C$w, height = lay$panel$C$h
    )
  }

  invisible(lay)
}


#' Write standalone PNG and PDF copies into checkin-workflow/figures/
checkin_workflow_save <- function(width = 12, dir = "checkin-workflow/figures") {
  lay <- checkin_workflow_layout(width = width)
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)

  ragg::agg_png(
    file.path(dir, "checkin-workflow.png"),
    width = lay$width, height = lay$height, units = "in", res = 300
  )
  checkin_workflow_plot(width = width)
  dev.off()

  pdf(
    file.path(dir, "checkin-workflow.pdf"),
    width = lay$width, height = lay$height
  )
  checkin_workflow_plot(width = width)
  dev.off()

  invisible(lay)
}
