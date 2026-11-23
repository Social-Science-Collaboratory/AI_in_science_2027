## Week summary: the opening figure for each content chapter (weeks 2-12).
## Usage: week_summary_plot(week, fig_width, fig_height), with the chunk's own
## fig-width and fig-height. See ../README.md.

library(ggplot2)
library(dplyr)
library(tidyr)
library(forcats)
library(readr)
library(cowplot)
library(grid)


# Paths ---------------------------------------------------------------------

week_summary_root <- local({
  this <- NULL
  for (i in seq_len(sys.nframe())) {
    ofile <- sys.frame(i)$ofile
    if (!is.null(ofile)) this <- ofile
  }
  if (is.null(this)) {
    arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
    if (length(arg)) this <- sub("^--file=", "", arg[1])
  }
  if (is.null(this)) getwd() else dirname(dirname(normalizePath(this)))
})

week_data <- function(week, kind) {
  path <- file.path(week_summary_root, "data",
                    sprintf("week-%02d-%s.csv", as.integer(week), kind))
  if (!file.exists(path)) stop("missing data file: ", path)
  read_csv(path, show_col_types = FALSE)
}


# Settings ------------------------------------------------------------------

response_colours <- c(disagree = "#D3877C", agree = "#7FA1C4")

default_width  <- 12
default_height <- 5.5
panel_widths   <- c(1.25, 1)

qr_height <- 0.19
qr_x      <- 0.015
gutter    <- 0.04


# Left panel: statements ----------------------------------------------------

read_statements <- function(week) {
  statements <- week_data(week, "statements")
  if (any(statements$agrees + statements$disagrees == 0)) {
    stop("week ", week, ": a statement has no agree or disagree votes")
  }
  statements |>
    mutate(
      agree     = 100 * agrees / (agrees + disagrees),
      disagree  = 100 - agree,
      statement = fct_rev(fct_inorder(statement))
    )
}

statements_panel <- function(statements) {
  plot_dat <- statements |>
    pivot_longer(c(disagree, agree), names_to = "response", values_to = "pct") |>
    mutate(signed = if_else(response == "disagree", -pct, pct))

  ggplot(plot_dat, aes(signed, statement, fill = response)) +
    geom_col(width = 0.6) +
    geom_vline(xintercept = 0, linewidth = 0.4, colour = "grey30") +
    scale_fill_manual(values = response_colours, guide = "none") +
    scale_x_continuous(
      limits = c(-100, 100),
      breaks = seq(-100, 100, 50),
      labels = \(x) paste0(abs(x), "%")
    ) +
    labs(x = "<-  Disagree          Agree  ->", y = NULL) +
    theme_classic(base_size = 12) +
    theme(
      axis.line.y  = element_blank(),
      axis.ticks.y = element_blank(),
      axis.text.y  = element_text(hjust = 0),
      axis.title.x = element_text(margin = margin(t = 8)),
      plot.margin  = margin(28, 5, 10, 10)
    )
}


# Right panel: resources ----------------------------------------------------

qr_grob <- function(url) {
  m <- qrcode::qr_code(url)
  rasterGrob(matrix(ifelse(m, "black", "white"), nrow = nrow(m)),
             interpolate = FALSE,
             width = unit(1, "npc"), height = unit(1, "npc"))
}

wrap_text <- function(x, width) paste(strwrap(x, width = width), collapse = "\n")
n_lines   <- function(x) lengths(strsplit(x, "\n", fixed = TRUE))
has_text  <- function(x) !is.na(x) & nzchar(x)

# Vertical extent, in figure npc, of the left panel's plotting region.
panel_band <- function(grob, fig_height) {
  row     <- grob$layout$t[grob$layout$name == "panel"]
  heights <- convertHeight(grob$heights, "in", valueOnly = TRUE)
  c(bottom = sum(heights[-seq_len(row)]) / fig_height,
    top    = 1 - sum(heights[seq_len(row - 1)]) / fig_height)
}

resources_panel <- function(resources, band, fig_width, fig_height) {
  n           <- nrow(resources)
  right_width <- fig_width * panel_widths[2] / sum(panel_widths)
  qr_width    <- qr_height * fig_height / right_width
  text_x      <- qr_x + qr_width + gutter
  wrap_at     <- max(24, floor((1 - text_x) * right_width * 11))
  row_y       <- band[["bottom"]] +
    diff(band) * seq(2 * n - 1, 1, by = -2) / (2 * n)

  line_npc <- function(size, lineheight) 1.2 * size * lineheight / 72 / fig_height
  title_lh <- line_npc(11.5, 1.1)
  body_lh  <- line_npc(10.5, 1.2)
  cred_lh  <- line_npc(9.5, 1.2)
  gap      <- 5 / 72 / fig_height

  panel       <- ggdraw()
  prev_bottom <- Inf
  for (i in seq_len(n)) {
    r      <- resources[i, ]
    title  <- wrap_text(r$title, wrap_at - 2)
    body   <- if (has_text(r$body)) wrap_text(r$body, wrap_at) else ""
    credit <- if (has_text(r$credit)) {
      wrap_text(paste("Identified by", r$credit), wrap_at + 12)
    } else ""

    title_h <- n_lines(title) * title_lh
    body_h  <- if (nzchar(body)) n_lines(body) * body_lh + gap else 0
    cred_h  <- if (nzchar(credit)) n_lines(credit) * cred_lh + gap else 0
    top     <- row_y[i] + (title_h + body_h + cred_h) / 2

    if (top > prev_bottom - gap) {
      warning(sprintf("Resource %d (\"%s\") collides with the one above; shorten a body.",
                      i, substr(r$title, 1, 40)), call. = FALSE)
    }
    prev_bottom <- top - title_h - body_h - cred_h

    panel <- panel +
      draw_grob(qr_grob(r$url), x = qr_x, y = row_y[i] - qr_height / 2,
                width = qr_width, height = qr_height) +
      draw_label(title, x = text_x, y = top, hjust = 0, vjust = 1,
                 size = 11.5, lineheight = 1.1, fontface = "bold")
    if (nzchar(body)) {
      panel <- panel +
        draw_label(body, x = text_x, y = top - title_h - gap, hjust = 0, vjust = 1,
                   size = 10.5, lineheight = 1.2, colour = "grey25")
    }
    if (nzchar(credit)) {
      panel <- panel +
        draw_label(credit, x = text_x, y = top - title_h - body_h - gap,
                   hjust = 0, vjust = 1, size = 9.5, lineheight = 1.2,
                   fontface = "italic", colour = "grey45")
    }
  }
  panel
}


# Figure --------------------------------------------------------------------

week_summary_plot <- function(week,
                              fig_width  = default_width,
                              fig_height = default_height) {
  left  <- statements_panel(read_statements(week))
  band  <- panel_band(ggplotGrob(left), fig_height)
  right <- resources_panel(week_data(week, "resources"), band, fig_width, fig_height)

  plot_grid(
    left, right, nrow = 1, rel_widths = panel_widths,
    labels = c("Top discussion points", "Top resources"),
    label_size = 16, label_fontface = "bold",
    label_x = 0.015, hjust = 0, vjust = 1.4
  )
}


# Standalone export: Rscript R/week-summary.R [week] --------------------------

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  week <- if (length(args)) as.integer(args[1]) else 2L
  grDevices::pdf(NULL)
  out <- file.path(week_summary_root, "figures", sprintf("week-%02d-summary.png", week))
  ggsave(out, week_summary_plot(week),
         width = default_width, height = default_height, dpi = 300, bg = "white")
  message("wrote ", out)
}
