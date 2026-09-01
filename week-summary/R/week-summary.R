## ---------------------------------------------------------------------------
## Week summary — the opening figure for every content chapter
##
## Two panels, one per half of what a week produced:
##
##   left   "Top discussion points"  the Polis statements, drawn as a diverging
##                                   bar: disagree runs left of zero, agree
##                                   right, so agreement and disagreement are
##                                   the same picture read in two directions.
##   right  "Top resources"          the three resources the seminar voted to
##                                   carry forward, each with a QR code to the
##                                   thing itself and a credit to the student
##                                   who found it.
##
## Every chapter calls the same function against its own two CSVs, so the
## figure is a template, not fifteen figures. Read top to bottom: paths, then
## settings, then data, then the two panels, then the composition.
## ---------------------------------------------------------------------------

library(ggplot2)
library(dplyr)
library(tidyr)
library(forcats)
library(readr)
library(cowplot)
library(grid)


# 0. Where am I? ------------------------------------------------------------
# Same trick as scale-ladder/R/scale-ladder.R: the book sources this from the
# project root, but `Rscript R/week-summary.R` runs it from inside this folder.
# Find this file and treat its parent as the package root so data/ and figures/
# resolve either way.

week_summary_root <- local({
  this <- NULL

  # sourced: the innermost source() frame carries the file it is reading
  for (i in seq_len(sys.nframe())) {
    ofile <- sys.frame(i)$ofile
    if (!is.null(ofile)) this <- ofile
  }

  # Rscript: the path arrives on the command line
  if (is.null(this)) {
    arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
    if (length(arg)) this <- sub("^--file=", "", arg[1])
  }

  if (is.null(this)) getwd() else dirname(dirname(normalizePath(this)))
})

week_summary_path <- function(...) file.path(week_summary_root, ...)


# 1. Settings ---------------------------------------------------------------

# Warm/cool pair rather than red/green: the two directions have to stay
# distinguishable for a red-green colourblind reader, since the whole left
# panel is one bar split into exactly these two colours.
response_colours <- c(disagree = "#D3877C", agree = "#7FA1C4")

# The composition. Panel widths are relative; the QR geometry below is solved
# against them, so changing one without the other is what makes the codes go
# oblong.
default_width  <- 12
default_height <- 5.5
panel_widths   <- c(1.25, 1)

qr_height <- 0.19   # QR side, as a fraction of figure height
qr_x      <- 0.015  # flush with the "Top resources" header's left edge
gutter    <- 0.04   # gap between a QR code and its text block


# 2. Data -------------------------------------------------------------------
# One pair of CSVs per week, named by zero-padded week number.
#
#   week-NN-statements.csv   statement, agree      (agree = percent agreeing)
#   week-NN-resources.csv    title, url, body, credit
#
# Statements are plotted in file order, top to bottom -- so the CSV is the
# running order, and sorting it by `agree` is what produces the wedge shape.

week_slug <- function(week) sprintf("week-%02d", as.integer(week))

read_statements <- function(week) {
  path <- week_summary_path("data", paste0(week_slug(week), "-statements.csv"))
  if (!file.exists(path)) stop("no statements file for week ", week, ": ", path)

  read_csv(path, show_col_types = FALSE) |>
    mutate(
      disagree  = 100 - agree,
      # fct_inorder keeps the CSV's order; fct_rev because ggplot draws the
      # first level at the BOTTOM of a discrete y axis.
      statement = fct_rev(fct_inorder(statement))
    )
}

read_resources <- function(week) {
  path <- week_summary_path("data", paste0(week_slug(week), "-resources.csv"))
  if (!file.exists(path)) stop("no resources file for week ", week, ": ", path)

  read_csv(path, show_col_types = FALSE)
}


# 3. Left panel: the discussion points --------------------------------------

statements_panel <- function(statements) {
  plot_dat <- statements |>
    pivot_longer(c(disagree, agree), names_to = "response", values_to = "pct") |>
    mutate(
      # Disagreement is drawn as a negative number purely so the two halves of
      # each bar land on opposite sides of zero. The axis labels take the
      # absolute value back off, so nothing reads as a negative percentage.
      signed   = if_else(response == "disagree", -pct, pct),
      response = factor(response, levels = c("disagree", "agree"))
    )

  ggplot(plot_dat, aes(x = signed, y = statement, fill = response)) +
    geom_col(width = 0.6) +
    geom_vline(xintercept = 0, linewidth = 0.4, colour = "grey30") +
    scale_fill_manual(values = response_colours, guide = "none") +
    scale_x_continuous(
      limits = c(-100, 100),
      breaks = c(-100, -50, 0, 50, 100),
      labels = function(x) paste0(abs(x), "%")
    ) +
    # ASCII arrows on purpose. The book's PDF format renders figures through
    # the stock pdf() device, which has no glyph for the unicode arrows on a
    # build without cairo -- the figure then fails to draw at all. "<-" and
    # "->" are safe on every device.
    labs(x = "<-  Disagree          Agree  ->", y = NULL) +
    theme_classic(base_size = 12) +
    theme(
      axis.line.y  = element_blank(),
      axis.ticks.y = element_blank(),
      axis.text.y  = element_text(hjust = 0),
      axis.title.x = element_text(margin = margin(t = 8)),
      plot.margin  = margin(28, 5, 10, 10)  # top margin clears the panel header
    )
}


# 4. Right panel: the resources ---------------------------------------------

# A QR code as a grob. qrcode::qr_code() returns a logical matrix, TRUE where a
# module is dark; rasterGrob draws it without interpolation so the modules stay
# crisp squares at any size.
qr_grob <- function(url) {
  m <- qrcode::qr_code(url)
  rasterGrob(
    matrix(ifelse(m, "black", "white"), nrow = nrow(m)),
    interpolate = FALSE,
    width = unit(1, "npc"), height = unit(1, "npc")
  )
}

wrap_text <- function(x, width) paste(strwrap(x, width = width), collapse = "\n")

resources_panel <- function(resources, statements_grob,
                            fig_width, fig_height) {
  n <- nrow(resources)

  # A QR code has to be square on the page, but it is positioned in npc -- a
  # fraction of the panel, whose width and height differ. Convert the height
  # fraction into the width fraction that draws the same number of inches.
  right_width <- fig_width * panel_widths[2] / sum(panel_widths)
  qr_width    <- qr_height * fig_height / right_width
  text_x      <- qr_x + qr_width + gutter

  # Confine the rows to the vertical band that panel A's plotting region
  # occupies, so the bottom QR code does not hang below panel A's x axis. The
  # left panel's gtable gives the fixed (non-null) heights above and below its
  # panel row; everything else is the panel itself.
  layout    <- statements_grob$layout
  panel_row <- layout$t[layout$name == "panel"]
  heights   <- convertHeight(statements_grob$heights, "in", valueOnly = TRUE)

  band_top <- 1 - sum(heights[seq_len(panel_row - 1)]) / fig_height
  band_bot <- sum(heights[(panel_row + 1):length(heights)]) / fig_height

  # n evenly spaced rows, centred in the band: for n = 3 this is 5/6, 3/6, 1/6.
  row_y <- band_bot + (band_top - band_bot) * (seq(2 * n - 1, 1, by = -2) / (2 * n))

  # Wrap to the text column's actual width. ~11 characters per inch at 10.5pt.
  wrap_at <- max(24, floor((1 - text_x) * right_width * 11))

  panel <- ggdraw()
  for (i in seq_len(n)) {
    r <- resources[i, ]

    panel <- panel +
      draw_grob(qr_grob(r$url),
                x = qr_x, y = row_y[i] - qr_height / 2,
                width = qr_width, height = qr_height) +
      draw_label(r$title, x = text_x, y = row_y[i] + 0.075,
                 hjust = 0, vjust = 1, size = 12, fontface = "bold") +
      draw_label(wrap_text(r$body, wrap_at), x = text_x, y = row_y[i] + 0.010,
                 hjust = 0, vjust = 1, size = 10.5, lineheight = 1.2,
                 colour = "grey25")

    # The credit line is the point of the exercise -- resources are attributed
    # to the student who surfaced them -- so it is always drawn, and drawn last
    # so it sits below however many lines the body wrapped to.
    if (!is.na(r$credit) && nzchar(r$credit)) {
      body_lines <- length(strsplit(wrap_text(r$body, wrap_at), "\n")[[1]])
      credit_y   <- row_y[i] + 0.010 - body_lines * 0.036 - 0.012

      panel <- panel +
        draw_label(paste("Identified by", r$credit),
                   x = text_x, y = credit_y,
                   hjust = 0, vjust = 1, size = 9.5,
                   fontface = "italic", colour = "grey45")
    }
  }

  panel
}


# 5. The figure -------------------------------------------------------------

#' Draw the opening figure for a content chapter.
#'
#' @param week        week number; picks up data/week-NN-*.csv
#' @param fig_width   inches -- pass the same value as the chunk's fig-width
#' @param fig_height  inches -- pass the same value as the chunk's fig-height
#'
#' Both dimensions must match the chunk, because the QR codes are sized from
#' the figure's aspect ratio (see resources_panel) rather than by the device.
week_summary_plot <- function(week,
                              fig_width  = default_width,
                              fig_height = default_height) {
  statements <- read_statements(week)
  resources  <- read_resources(week)

  left       <- statements_panel(statements)
  left_grob  <- ggplotGrob(left)
  right      <- resources_panel(resources, left_grob, fig_width, fig_height)

  plot_grid(
    left, right, nrow = 1, rel_widths = panel_widths,
    labels = c("Top discussion points", "Top resources"),
    label_size = 16, label_fontface = "bold",
    label_x = 0.015, hjust = 0, vjust = 1.4
  )
}


# 6. Standalone export ------------------------------------------------------
# `Rscript R/week-summary.R [week]` writes figures/week-NN-summary.{png,pdf}.
# The book does not use these -- it calls week_summary_plot() and lets Quarto
# draw the figure -- so they are for proofing, slides, and posters.

# Pick a PDF device that can actually draw text.
#
# `capabilities("cairo")` is NOT the test: on a macOS R built against cairo but
# running without XQuartz it reports TRUE, and cairo_pdf then dies at open time
# with "failed to load cairo DLL". grSoftVersion() reports the version string of
# the cairo that actually loaded, so an empty string is the honest answer.
# quartz's PDF type is the native macOS fallback; the stock device is last.
vector_pdf_device <- function() {
  cairo_ok <- suppressWarnings(
    tryCatch(nzchar(grSoftVersion()[["cairo"]]), error = function(e) FALSE)
  )
  if (isTRUE(cairo_ok)) return(grDevices::cairo_pdf)

  if (isTRUE(capabilities("aqua"))) {
    return(function(filename, width, height, ...) {
      grDevices::quartz(file = filename, type = "pdf",
                        width = width, height = height, bg = "white")
    })
  }

  grDevices::pdf
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  week <- if (length(args)) as.integer(args[1]) else 2L

  fig  <- week_summary_plot(week)
  stem <- week_summary_path("figures", paste0(week_slug(week), "-summary"))

  ggsave(paste0(stem, ".png"), fig,
         width = default_width, height = default_height, dpi = 300, bg = "white")

  ggsave(paste0(stem, ".pdf"), fig,
         width = default_width, height = default_height, device = vector_pdf_device())

  message("wrote ", stem, ".png and .pdf")
}
