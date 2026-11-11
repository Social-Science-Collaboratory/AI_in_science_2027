# outreach-agent.R ---------------------------------------------------------
#
# Figure package for Figure 2 of weeks/11-outreach.qmd.
#
# Two panels side by side at the same 12in width the week-summary figure uses:
#
#   A  the workflow of an AI outreach agent (draw.io export)
#   B  the cost of that workflow: inboxes full of AI, human messages ignored
#      (generated with ChatGPT)
#
# Same construction as figure-packages/literature-critique/R/literature-critique.R:
# panels are placed with grid rather than composited into a bitmap, so the
# labels stay vector in the PDF build. Only png and grid are needed.

library(grid)

# Panel sources, in layout order. Paths are project-root relative because
# _quarto.yml sets execute-dir: project.
OUTREACH_PANELS <- c(
  A = "figure-packages/outreach-agent/images/panel-a-outreach-agent-workflow.png",
  B = "figure-packages/outreach-agent/images/panel-b-ai-overload.png"
)

# Panel captions, drawn on the figure beside each bold letter.
OUTREACH_LABELS <- c(
  A = "An AI outreach agent's workflow",
  B = "AI overload, human messages ignored"
)


#' Geometry for the multipanel, in inches
#'
#' The two columns are split in proportion to the panels' aspect ratios, so
#' both images are drawn at exactly the same height with no padding. A is
#' near-square (2028x1928) and B is 3:2 (1536x1024), so A's column is the
#' narrower one (about 4.8in against 6.8in).
outreach_agent_layout <- function(width = 12,
                                  margin = 0.12,
                                  gap = 0.30,
                                  label_height = 0.26) {
  aspect <- vapply(OUTREACH_PANELS, function(p) {
    d <- dim(png::readPNG(p))       # rows (height) x cols (width) x channels
    d[2] / d[1]
  }, numeric(1))

  inner <- width - 2 * margin
  avail <- inner - gap
  w_a <- avail * aspect[["A"]] / (aspect[["A"]] + aspect[["B"]])
  w_b <- avail - w_a
  img_h <- w_a / aspect[["A"]]

  height <- margin + label_height + img_h + margin

  list(
    width = width, height = height,
    margin = margin, gap = gap, label_height = label_height,
    img_h = img_h,
    panel = list(A = list(w = w_a), B = list(w = w_b))
  )
}


#' Draw one labelled panel with its top-left corner at (`x`, `y`) inches
draw_outreach_panel <- function(img, label, desc, x, y, img_w, img_h,
                                label_height) {
  letter <- paste0(label, ".")
  letter_gp <- gpar(fontface = "bold",  fontsize = 13, col = "grey15")
  desc_gp   <- gpar(fontface = "plain", fontsize = 13, col = "grey15")
  y_mid <- unit(y - label_height / 2, "in")

  grid.text(letter, x = unit(x, "in"), y = y_mid,
            hjust = 0, vjust = 0.5, gp = letter_gp)

  # Offset the description by the measured width of the bold letter plus a
  # space, so the two runs stay butted together if the fontsize changes.
  lead <- convertWidth(
    grobWidth(textGrob(paste0(letter, " "), gp = letter_gp)),
    "in", valueOnly = TRUE
  )
  grid.text(desc, x = unit(x + lead, "in"), y = y_mid,
            hjust = 0, vjust = 0.5, gp = desc_gp)

  grid.raster(
    img,
    x = unit(x, "in"), y = unit(y - label_height - img_h, "in"),
    width = unit(img_w, "in"), height = unit(img_h, "in"),
    hjust = 0, vjust = 0, interpolate = TRUE
  )
}


#' Draw the outreach multipanel
#'
#' @param width Figure width in inches; 12 matches the week-summary figure.
#' @return Invisibly, the layout list (its `height` is the fig-height the
#'   calling chunk should declare).
outreach_agent_plot <- function(width = 12, ...) {
  lay <- outreach_agent_layout(width = width, ...)
  imgs <- lapply(OUTREACH_PANELS, png::readPNG)

  grid.newpage()
  # The draw.io export has a transparent background, so the canvas has to be
  # painted white or its grey text lands on whatever the device leaves behind.
  grid.rect(gp = gpar(fill = "white", col = NA))

  top <- lay$height - lay$margin

  draw_outreach_panel(
    imgs$A, "A", OUTREACH_LABELS[["A"]],
    x = lay$margin, y = top,
    img_w = lay$panel$A$w, img_h = lay$img_h,
    label_height = lay$label_height
  )
  draw_outreach_panel(
    imgs$B, "B", OUTREACH_LABELS[["B"]],
    x = lay$margin + lay$panel$A$w + lay$gap, y = top,
    img_w = lay$panel$B$w, img_h = lay$img_h,
    label_height = lay$label_height
  )

  invisible(lay)
}


#' Write standalone PNG and PDF copies into the package's figures/ folder
outreach_agent_save <- function(width = 12,
                                dir = "figure-packages/outreach-agent/figures") {
  lay <- outreach_agent_layout(width = width)
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)

  ragg::agg_png(file.path(dir, "outreach-agent.png"),
                width = lay$width, height = lay$height, units = "in", res = 300)
  outreach_agent_plot(width = width)
  dev.off()

  pdf(file.path(dir, "outreach-agent.pdf"),
      width = lay$width, height = lay$height)
  outreach_agent_plot(width = width)
  dev.off()

  invisible(lay)
}
