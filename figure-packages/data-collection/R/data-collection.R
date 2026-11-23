# Grant case-study multipanel: Figure 2 of weeks/06-data-collection-using.qmd.
# Usage: data_collection_plot(width); data_collection_save() writes figures/.

library(grid)

# Panel sources, in layout order (paths relative to the project root).
DATACOLL_PANELS <- c(
  A = "figure-packages/data-collection/images/panel-a-grant-workflow.png"
)

# Panel B text: the grant's title and abstract, one paragraph each.
DATACOLL_TEXT <- "figure-packages/data-collection/data/grant-summary.txt"

# Aspect ratio of the panel B text box.
DATACOLL_B_ASPECT <- 2099 / 1640

# Panel captions, drawn beside each bold letter.
DATACOLL_LABELS <- c(
  A = "Visual summary of the proposed workflow",
  B = "Technical summary of the grant"
)


#' Geometry for the two-panel row, in inches
#'
#' Columns are split in proportion to the panels' aspect ratios.
data_collection_layout <- function(width = 12,
                                     margin = 0.12,
                                     gap = 0.20,
                                     label_height = 0.26) {
  d_a <- dim(png::readPNG(DATACOLL_PANELS[["A"]]))   # rows x cols x channels
  aspect <- c(A = d_a[2] / d_a[1], B = DATACOLL_B_ASPECT)

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
#' `x`/`y` are the inch coordinates of the cell's top-left corner.
draw_datacoll_panel <- function(img, label, desc, x, y, img_w, img_h,
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

  if (!is.null(img)) {
    grid.raster(
      img,
      x = unit(x, "in"), y = unit(y - label_height - img_h, "in"),
      width = unit(img_w, "in"), height = unit(img_h, "in"),
      hjust = 0, vjust = 0, interpolate = TRUE
    )
  }
}


#' Greedy word-wrap to a width in inches, measured off the rendered glyphs
wrap_to_width <- function(txt, width, gp) {
  words <- strsplit(txt, " ", fixed = TRUE)[[1]]
  w_of <- function(s) convertWidth(grobWidth(textGrob(s, gp = gp)), "in", valueOnly = TRUE)
  lines <- character(); cur <- ""
  for (w in words) {
    trial <- if (nzchar(cur)) paste(cur, w) else w
    if (nzchar(cur) && w_of(trial) > width) {
      lines <- c(lines, cur); cur <- w
    } else cur <- trial
  }
  c(lines, cur)
}


#' Draw the grant's title and abstract as text filling a box
#'
#' Uses the largest font size at which the wrapped text fits the box.
draw_datacoll_text <- function(x, y, w, h, label_height, pad = 0.04, drop = 0.1) {
  parts <- readLines(DATACOLL_TEXT, warn = FALSE)
  title <- parts[[1]]; body <- parts[[2]]
  top <- y - label_height
  inner_w <- w - pad; inner_h <- h - drop - pad
  fam <- "serif"

  layout_at <- function(fs) {
    t_gp <- gpar(fontfamily = fam, fontface = "bold", fontsize = fs * 1.15)
    b_gp <- gpar(fontfamily = fam, fontface = "plain", fontsize = fs)
    lh <- fs * 1.2 / 72                                    # line height, inches
    list(t_gp = t_gp, b_gp = b_gp, lh = lh,
         t = wrap_to_width(title, inner_w, t_gp),
         b = wrap_to_width(body, inner_w, b_gp))
  }
  height_of <- function(l) {
    (length(l$t) * 1.15 + 1.2 + length(l$b)) * l$lh       # title, heading, body
  }
  fs <- 14
  while (fs > 6 && height_of(layout_at(fs)) > inner_h) fs <- fs - 0.25
  l <- layout_at(fs)

  cur <- top - drop
  line <- function(txt, gp, step) {
    grid.text(txt, x = unit(x, "in"), y = unit(cur, "in"),
              hjust = 0, vjust = 1, gp = gp)
    cur <<- cur - step
  }
  for (ln in l$t) line(ln, l$t_gp, l$lh * 1.15)
  line("Abstract", l$t_gp, l$lh * 1.2)
  for (ln in l$b) line(ln, l$b_gp, l$lh)
}


#' Draw the data collection multipanel
#'
#' @param width Figure width in inches.
#' @return Invisibly, the layout list (its `height` is the fig-height the
#'   calling chunk should declare).
data_collection_plot <- function(width = 12, ...) {
  lay <- data_collection_layout(width = width, ...)
  img_a <- png::readPNG(DATACOLL_PANELS[["A"]])

  grid.newpage()
  grid.rect(gp = gpar(fill = "white", col = NA))

  top <- lay$height - lay$margin

  draw_datacoll_panel(
    img_a, "A", DATACOLL_LABELS[["A"]],
    x = lay$margin, y = top,
    img_w = lay$panel$A$w, img_h = lay$panel$A$h,
    label_height = lay$label_height
  )
  x_b <- lay$margin + lay$panel$A$w + lay$gap
  draw_datacoll_panel(
    NULL, "B", DATACOLL_LABELS[["B"]],
    x = x_b, y = top,
    img_w = lay$panel$B$w, img_h = lay$panel$B$h,
    label_height = lay$label_height
  )
  draw_datacoll_text(x_b, top, lay$panel$B$w, lay$panel$B$h, lay$label_height)

  invisible(lay)
}


#' Write a standalone PNG copy into the package's figures/ folder
data_collection_save <- function(
    width = 12,
    dir = "figure-packages/data-collection/figures") {
  lay <- data_collection_layout(width = width)
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)

  ragg::agg_png(
    file.path(dir, "data-collection.png"),
    width = lay$width, height = lay$height, units = "in", res = 300
  )
  data_collection_plot(width = width)
  dev.off()

  invisible(lay)
}
