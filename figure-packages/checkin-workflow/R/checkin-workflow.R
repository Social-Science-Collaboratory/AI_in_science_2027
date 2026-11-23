# Check-in workflow multipanel: Figure 2 of weeks/02-project-management-using.qmd.
# Usage: checkin_workflow_plot(width); checkin_workflow_save() writes figures/.

library(grid)

# Panel sources, in layout order (paths relative to the project root).
CHECKIN_PANELS <- c(
  A = "figure-packages/checkin-workflow/images/panel-a-checkin-repo.png",
  B = "figure-packages/checkin-workflow/images/panel-b-llm-query.png",
  C = paste0("figure-packages/checkin-workflow/images/",
             "panel-c-mobility-prepost-mockup.png")
)

# Panel captions, drawn beside each bold letter.
CHECKIN_LABELS <- c(
  A = "Trainee submits update to shared folder",
  B = "Adviser uses Claude to summarize and plan next steps",
  C = "Adviser uses Claude to generate mock-up of future directions"
)


#' Geometry for the multipanel, in inches
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

  # Row 1: columns split in proportion to the panels' aspect ratios.
  avail <- inner - gap
  w_a <- avail * aspect[["A"]] / (aspect[["A"]] + aspect[["B"]])
  w_b <- avail - w_a
  row1_image <- w_a / aspect[["A"]]

  # Row 2: panel C spans the full inner width.
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
#' `x`/`y` are the inch coordinates of the cell's top-left corner.
draw_panel <- function(img, label, desc, x, y, cell_w, img_w, img_h,
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
draw_mock_watermark <- function(x, y, width, height,
                                angle = 30, span = 0.70, alpha = 0.15) {
  # Size the rotated text to fit within `span` of the panel on both axes.
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
#' @param width Figure width in inches.
#' @param watermark Draw the MOCK overlay on panel C.
#' @return Invisibly, the layout list (its `height` is the fig-height the
#'   calling chunk should declare).
checkin_workflow_plot <- function(width = 12, watermark = TRUE, ...) {
  lay <- checkin_workflow_layout(width = width, ...)
  imgs <- lapply(CHECKIN_PANELS, png::readPNG)

  grid.newpage()
  grid.rect(gp = gpar(fill = "white", col = NA))

  top <- lay$height - lay$margin

  draw_panel(
    imgs$A, "A", CHECKIN_LABELS[["A"]],
    x = lay$margin, y = top,
    cell_w = lay$panel$A$w,
    img_w = lay$panel$A$w, img_h = lay$panel$A$h,
    label_height = lay$label_height
  )
  draw_panel(
    imgs$B, "B", CHECKIN_LABELS[["B"]],
    x = lay$margin + lay$panel$A$w + lay$gap, y = top,
    cell_w = lay$panel$B$w,
    img_w = lay$panel$B$w, img_h = lay$panel$B$h,
    label_height = lay$label_height
  )

  row2_top <- top - lay$label_height - lay$row1_image - lay$row_gap
  draw_panel(
    imgs$C, "C", CHECKIN_LABELS[["C"]],
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


#' Write standalone PNG and PDF copies into the package's figures/ folder
checkin_workflow_save <- function(
    width = 12,
    dir = "figure-packages/checkin-workflow/figures") {
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
