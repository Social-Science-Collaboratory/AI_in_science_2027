# AI error-audit multipanel for weeks/12-ethics-what-should-count.qmd.
# Usage: error_audit_plot(width); error_audit_save() writes figures/.

library(grid)

# Panel sources (paths relative to the project root).
ERROR_AUDIT_PANELS <- c(
  A = "figure-packages/error-audit/images/panel-a-audit-post.png",
  B = "figure-packages/error-audit/images/panel-b-community-response.png",
  C = "figure-packages/error-audit/images/panel-c-supervisor-email.png"
)

# Panel titles, drawn beside each bold letter and wrapped to the column width.
ERROR_AUDIT_LABELS <- c(
  A = "Instructor's previous supervisor uses AI to audit every project for errors",
  B = "Community points out that open science reform enables such discoveries in the first place",
  C = "Instructor receives email from previous supervisor"
)

# Emoji PNGs drawn after each title.
ERROR_AUDIT_EMOJI <- c(
  A = "figure-packages/error-audit/images/emoji-a-scared.png",
  B = "figure-packages/error-audit/images/emoji-b-hands-raised.png",
  C = "figure-packages/error-audit/images/emoji-c-dead.png"
)

ERROR_AUDIT_FONTSIZE <- 13
ERROR_AUDIT_EMOJI_SIZE <- 0.28    # inches, square
ERROR_AUDIT_EMOJI_GAP <- 0.02     # inches between title text and emoji
ERROR_AUDIT_LINE_HEIGHT <- 0.24   # inches per title line at 13pt


# Greedily wrap `text` into lines no wider than `width` inches, leaving room
# for the bold letter on the first line. Needs an open device to measure text.
wrap_error_audit_title <- function(text, width, lead) {
  gp <- gpar(fontsize = ERROR_AUDIT_FONTSIZE)
  words <- strsplit(text, " ", fixed = TRUE)[[1]]
  lines <- character(0)
  current <- ""
  for (w in words) {
    trial <- if (nzchar(current)) paste(current, w) else w
    # Width left after the indent and the trailing emoji.
    avail <- width - lead - ERROR_AUDIT_EMOJI_GAP - ERROR_AUDIT_EMOJI_SIZE
    trial_w <- convertWidth(grobWidth(textGrob(trial, gp = gp)),
                            "in", valueOnly = TRUE)
    if (trial_w <= avail || !nzchar(current)) {
      current <- trial
    } else {
      lines <- c(lines, current)
      current <- w
    }
  }
  c(lines, current)
}


#' Geometry for the multipanel, in inches
#'
#' Title heights are measured, so this needs an open graphics device.
error_audit_layout <- function(width = 12, margin = 0.12, gap = 0.30,
                               row_gap = 0.30, title_pad = 0.08) {
  aspect <- vapply(ERROR_AUDIT_PANELS, function(p) {
    d <- dim(png::readPNG(p))
    d[2] / d[1]
  }, numeric(1))

  inner <- width - 2 * margin
  avail <- inner - gap
  w_a <- avail * aspect[["A"]] / (aspect[["A"]] + aspect[["B"]])
  w_b <- avail - w_a
  row1_img_h <- w_a / aspect[["A"]]
  row2_img_h <- inner / aspect[["C"]]

  lead <- convertWidth(
    grobWidth(textGrob("A. ", gp = gpar(fontsize = ERROR_AUDIT_FONTSIZE,
                                       fontface = "bold"))),
    "in", valueOnly = TRUE
  )
  lines <- list(
    A = wrap_error_audit_title(ERROR_AUDIT_LABELS[["A"]], w_a, lead),
    B = wrap_error_audit_title(ERROR_AUDIT_LABELS[["B"]], w_b, lead),
    C = wrap_error_audit_title(ERROR_AUDIT_LABELS[["C"]], inner, lead)
  )
  title_h <- function(n) n * ERROR_AUDIT_LINE_HEIGHT + title_pad
  row1_title_h <- title_h(max(length(lines$A), length(lines$B)))
  row2_title_h <- title_h(length(lines$C))

  height <- margin + row1_title_h + row1_img_h + row_gap +
    row2_title_h + row2_img_h + margin

  list(
    width = width, height = height, margin = margin, gap = gap,
    row_gap = row_gap, lead = lead, inner = inner, lines = lines,
    w = c(A = w_a, B = w_b, C = inner),
    row1_img_h = row1_img_h, row2_img_h = row2_img_h,
    row1_title_h = row1_title_h, row2_title_h = row2_title_h
  )
}


#' Draw one titled panel with its top-left corner at (`x`, `y`) inches
draw_error_audit_panel <- function(img, emoji, letter, lines, x, y, img_w,
                                   img_h, title_h, lead) {
  letter_gp <- gpar(fontface = "bold",  fontsize = ERROR_AUDIT_FONTSIZE,
                    col = "grey15")
  desc_gp   <- gpar(fontface = "plain", fontsize = ERROR_AUDIT_FONTSIZE,
                    col = "grey15")
  first_mid <- y - ERROR_AUDIT_LINE_HEIGHT / 2

  grid.text(paste0(letter, "."), x = unit(x, "in"), y = unit(first_mid, "in"),
            hjust = 0, vjust = 0.5, gp = letter_gp)
  for (i in seq_along(lines)) {
    grid.text(lines[[i]], x = unit(x + lead, "in"),
              y = unit(first_mid - (i - 1) * ERROR_AUDIT_LINE_HEIGHT, "in"),
              hjust = 0, vjust = 0.5, gp = desc_gp)
  }

  last <- length(lines)
  last_w <- convertWidth(grobWidth(textGrob(lines[[last]], gp = desc_gp)),
                         "in", valueOnly = TRUE)
  grid.raster(
    emoji,
    x = unit(x + lead + last_w + ERROR_AUDIT_EMOJI_GAP, "in"),
    y = unit(first_mid - (last - 1) * ERROR_AUDIT_LINE_HEIGHT, "in"),
    width = unit(ERROR_AUDIT_EMOJI_SIZE, "in"),
    height = unit(ERROR_AUDIT_EMOJI_SIZE, "in"),
    hjust = 0, vjust = 0.5, interpolate = TRUE
  )

  grid.raster(
    img,
    x = unit(x, "in"), y = unit(y - title_h - img_h, "in"),
    width = unit(img_w, "in"), height = unit(img_h, "in"),
    hjust = 0, vjust = 0, interpolate = TRUE
  )
  # Hairline frame around the screenshot.
  grid.rect(x = unit(x, "in"), y = unit(y - title_h - img_h, "in"),
            width = unit(img_w, "in"), height = unit(img_h, "in"),
            hjust = 0, vjust = 0, gp = gpar(fill = NA, col = "grey75", lwd = 0.6))
}


#' Draw the error-audit multipanel
#'
#' @return Invisibly, the layout list (its `height` is the fig-height the
#'   calling chunk should declare).
error_audit_plot <- function(width = 12, ...) {
  grid.newpage()
  lay <- error_audit_layout(width = width, ...)
  imgs <- lapply(ERROR_AUDIT_PANELS, png::readPNG)
  emoji <- lapply(ERROR_AUDIT_EMOJI, png::readPNG)

  grid.rect(gp = gpar(fill = "white", col = NA))

  top <- lay$height - lay$margin
  draw_error_audit_panel(imgs$A, emoji$A, "A", lay$lines$A,
                         x = lay$margin, y = top,
                         img_w = lay$w[["A"]], img_h = lay$row1_img_h,
                         title_h = lay$row1_title_h, lead = lay$lead)
  draw_error_audit_panel(imgs$B, emoji$B, "B", lay$lines$B,
                         x = lay$margin + lay$w[["A"]] + lay$gap, y = top,
                         img_w = lay$w[["B"]], img_h = lay$row1_img_h,
                         title_h = lay$row1_title_h, lead = lay$lead)

  top2 <- top - lay$row1_title_h - lay$row1_img_h - lay$row_gap
  draw_error_audit_panel(imgs$C, emoji$C, "C", lay$lines$C,
                         x = lay$margin, y = top2,
                         img_w = lay$w[["C"]], img_h = lay$row2_img_h,
                         title_h = lay$row2_title_h, lead = lay$lead)

  invisible(lay)
}


#' Figure height for a given width, measured on a throwaway device
error_audit_height <- function(width = 12) {
  pdf(NULL, width = width, height = 10)
  on.exit(dev.off())
  error_audit_layout(width = width)$height
}


#' Write standalone PNG and PDF copies into the package's figures/ folder
error_audit_save <- function(width = 12,
                             dir = "figure-packages/error-audit/figures") {
  h <- error_audit_height(width)
  dir.create(dir, showWarnings = FALSE, recursive = TRUE)

  ragg::agg_png(file.path(dir, "error-audit.png"),
                width = width, height = h, units = "in", res = 300)
  error_audit_plot(width = width)
  dev.off()

  pdf(file.path(dir, "error-audit.pdf"), width = width, height = h)
  error_audit_plot(width = width)
  dev.off()

  invisible(h)
}
