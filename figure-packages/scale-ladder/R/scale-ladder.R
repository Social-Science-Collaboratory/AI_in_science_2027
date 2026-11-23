## Scale ladder: co-authors on flagship model reports, one square per author.
## Usage: scale_ladder_plot(fig_width); `Rscript R/scale-ladder.R` writes figures/.

library(ggplot2)
library(dplyr)
library(readr)


# 0. Where am I? ------------------------------------------------------------

scale_ladder_root <- local({
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

scale_ladder_path <- function(...) file.path(scale_ladder_root, ...)


# 1. Settings ---------------------------------------------------------------

lab_colours <- c(
  "OpenAI"      = "#d55e00",  # vermillion
  "Google"      = "#0072b2",  # blue
  "Meta"        = "#009e73"   # green
)

dot_gap   <- 1     # distance between neighbouring squares
block_gap <- 6     # empty space between one report's block and the next

# Fraction of its grid cell each square fills.
mark_fill <- 0.62


# 2. Data -------------------------------------------------------------------

authors <- read_csv(scale_ladder_path("data", "frontier-model-authors.csv"),
                    show_col_types = FALSE)

authors$date <- as.Date(authors$date)

authors$lab_group <- factor(authors$lab_group, levels = names(lab_colours))
authors           <- authors[order(authors$date), ]

authors$label_name <- sub(" System Card$", "", authors$model)

authors$label_date <- format(authors$date, "%Y")


# 3. Layout -----------------------------------------------------------------

# Width of a string in inches, for a geom_text size given in mm.
text_inches <- function(strings, size_mm, family = "sans") {
  grDevices::pdf(NULL, width = 40, height = 40)
  on.exit(grDevices::dev.off(), add = TRUE)
  graphics::par(ps = size_mm * .pt, family = family)
  graphics::strwidth(strings, units = "inches")
}

# Layout for a given figure width; pass the chunk's fig-width.
scale_ladder_layout <- function(fig_width) {

  # Each block is a near-square grid, ceiling(sqrt(n)) squares wide.
  authors$block_width <- ceiling(sqrt(authors$authors)) * dot_gap

  # Each slot must also fit its labels. Data units per inch depend on the total
  # width, so that scale is solved by fixed-point iteration below.
  counts <- formatC(authors$authors, big.mark = ",", format = "d")

  label_inches <- pmax(
    text_inches(authors$label_name, 2.6),
    text_inches(authors$label_date, 2.6),
    text_inches(counts, 2.9, family = "mono")
  )

  panel_inches <- fig_width - 0.6   # less the plot margins

  if (sum(label_inches) >= panel_inches) {
    warning("The labels need ", round(sum(label_inches), 1), "in but the ",
            "figure is only ", round(panel_inches, 1), "in wide, so they will ",
            "overlap. Widen the figure, or shorten the model names.",
            call. = FALSE)
  }

  units_per_inch <- 40   # a starting guess; the loop below corrects it
  for (pass in seq_len(50)) {
    width  <- pmax(authors$block_width, label_inches * units_per_inch)
    span   <- sum(width) + block_gap * (nrow(authors) - 1)
    solved <- span / panel_inches
    if (abs(solved - units_per_inch) < 0.01) break
    units_per_inch <- solved
  }

  authors$label_width <- label_inches * units_per_inch

  # Each report gets a slot as wide as whichever is bigger, dots or label.
  authors$slot_width <- pmax(authors$block_width, authors$label_width)

  # Where each block starts on the x axis: every slot to its left, plus one gap
  # for each block that came before it.
  authors$x_start <- cumsum(c(0, head(authors$slot_width, -1))) +
    block_gap * (seq_len(nrow(authors)) - 1)

  # The rule under each block spans its whole slot.
  authors$rule_end <- authors$x_start + authors$slot_width

  # Centre each block within its slot.
  authors$block_start <- authors$x_start +
    (authors$slot_width - authors$block_width) / 2

  # One row per credited person; position 0 is bottom-left, filling rightward.
  one_row_per_person <- function(report) {
    side  <- ceiling(sqrt(report$authors))
    index <- seq_len(report$authors) - 1        # 0, 1, 2, ... n-1
    data.frame(
      model     = report$model,
      lab_group = report$lab_group,
      x         = report$block_start + (index %%  side) * dot_gap,  # column
      y         =                      (index %/% side) * dot_gap   # row
    )
  }

  dots <- do.call(rbind, lapply(split(authors, seq_len(nrow(authors))),
                                one_row_per_person))

  # 4. Labels ---------------------------------------------------------------

  labels <- data.frame(
    x         = authors$x_start,
    rule_end  = authors$rule_end,
    centre    = authors$x_start + authors$slot_width / 2,
    lab_group = authors$lab_group,
    count     = formatC(authors$authors, big.mark = ",", format = "d"),
    name      = paste0(authors$label_name, "\n", authors$label_date)
  )

  list(dots = dots, labels = labels, units_per_inch = units_per_inch)
}


# 5. Plot -------------------------------------------------------------------
# Labels hang beneath the blocks, at negative y.

scale_ladder_plot <- function(fig_width = 7.5) {

  layout <- scale_ladder_layout(fig_width)
  dots   <- layout$dots
  labels <- layout$labels

  # Size of one grid cell in mm, scaled by mark_fill.
  mark_mm <- (dot_gap / layout$units_per_inch) * 25.4 * mark_fill

  ggplot() +

    # the squares: one per credited co-author
    geom_point(data = dots, aes(x, y, colour = lab_group),
               size = mark_mm, shape = 15) +

    # a short rule under each block, in that lab's colour
    geom_segment(data = labels,
                 aes(x = x, xend = rule_end, y = -2.5, yend = -2.5,
                     colour = lab_group),
                 linewidth = 0.4, show.legend = FALSE) +

    # the author count, then the model name and year, both centred on the block
    geom_text(data = labels, aes(x = centre, y = -5, label = count,
                                 colour = lab_group),
              hjust = 0.5, vjust = 1, size = 3.1, family = "mono",
              show.legend = FALSE) +
    geom_text(data = labels, aes(x = centre, y = -10, label = name),
              hjust = 0.5, vjust = 1, size = 2.8, colour = "#8c8c8c",
              lineheight = 0.95) +

    scale_colour_manual(values = lab_colours, name = "# of co-authors") +

    scale_x_continuous(expand = expansion(mult = 0.002)) +
    scale_y_continuous(expand = expansion(mult = 0.02)) +

    coord_fixed(clip = "off") +
    guides(colour = guide_legend(title.position = "top", title.hjust = 0.5,
                                 override.aes = list(size = 2.6))) +
    labs(x = NULL, y = NULL) +
    theme_void(base_size = 9) +
    theme(
      legend.position      = "bottom",
      legend.justification = "center",
      legend.title         = element_text(size = 8.5, colour = "#4d4d4d"),
      legend.text          = element_text(size = 8),
      legend.margin        = margin(t = 16),
      plot.margin          = margin(6, 2, 4, 2)
    )
}


# 6. Export -----------------------------------------------------------------

# TRUE only if cairo actually loaded, not just compiled in.
has_cairo <- function() {
  tryCatch(nzchar(grSoftVersion()[["cairo"]]),
           error   = function(e) FALSE,
           warning = function(w) FALSE)
}

if (sys.nframe() == 0) {
  dir.create(scale_ladder_path("figures"), showWarnings = FALSE)
  p <- scale_ladder_plot(fig_width = 7.5)
  ggsave(scale_ladder_path("figures", "scale-ladder.png"), p, width = 7.5,
         height = 2.4, dpi = 600, device = ragg::agg_png, bg = "white")
  # Prefer cairo_pdf where it works.
  ggsave(scale_ladder_path("figures", "scale-ladder.pdf"), p, width = 7.5,
         height = 2.4,
         device = if (has_cairo()) cairo_pdf else grDevices::pdf)
}
