## ---------------------------------------------------------------------------
## AI Race Observatory — co-authors on flagship model reports
##
## One small square = one credited co-author. Each report is drawn as a block
## of them; because the block is (roughly) square, its AREA is proportional to
## the author count -- four times the people is four times the ink.
##
## Read top to bottom: settings, then data, then layout, then the plot.
## ---------------------------------------------------------------------------

library(ggplot2)
library(dplyr)
library(readr)


# 0. Where am I? ------------------------------------------------------------
# The book sources this file from the project root, but `Rscript R/scale-
# ladder.R` runs it from inside scale-ladder/. Rather than depend on the
# working directory, find this file and treat its parent as the package root,
# so data/ and figures/ always resolve.

scale_ladder_root <- local({
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

scale_ladder_path <- function(...) file.path(scale_ladder_root, ...)


# 1. Settings ---------------------------------------------------------------

# Okabe-Ito hues: colourblind-safe, and still distinct at 1px mark size.
lab_colours <- c(
  "OpenAI"      = "#d55e00",  # vermillion
  "Google"      = "#0072b2",  # blue
  "Meta"        = "#009e73",  # green
  "Open-weight" = "#cc79a7"   # pink
)

dot_gap   <- 1     # distance between neighbouring squares
block_gap <- 6     # empty space between one report's block and the next

# How much of its cell each square fills. This is a fraction rather than a
# size, because the grid pitch changes with the width of the figure -- pin the
# square to a fixed number of millimetres and the grid reads as separate marks
# at one width and as a solid slab at another. Below about 0.7 the gaps close.
mark_fill <- 0.62


# 2. Data -------------------------------------------------------------------

authors <- read_csv(scale_ladder_path("data", "frontier-model-authors.csv"),
                    show_col_types = FALSE)

authors$date <- as.Date(authors$date)

# What the figure currently shows: the three labs with an unbroken published
# series, from GPT-1 on. The 2017 Transformer paper and the open-weight
# releases stay in the CSV -- delete the two filters below to bring them back.
authors     <- authors[authors$model != "Attention Is All You Need", ]
authors     <- authors[authors$lab_group != "Open-weight", ]
lab_colours <- lab_colours[names(lab_colours) != "Open-weight"]

authors$lab_group <- factor(authors$lab_group, levels = names(lab_colours))
authors           <- authors[order(authors$date), ]

# The CSV's `model` field is the record; what the figure prints is shorter.
# These are the same display names build-figure.js uses, so the R and HTML
# twins stay in step.
short_names <- c(
  "Attention Is All You Need" = "Transformer",
  "GPT-5 System Card"         = "GPT-5"
)

authors$label_name <- ifelse(authors$model %in% names(short_names),
                             short_names[authors$model], authors$model)

# Year only. Several reports share a year, but the sequence is already carried
# by the left-to-right order, and a month on every block costs width that the
# names need more.
authors$label_date <- format(authors$date, "%Y")


# 3. Layout -----------------------------------------------------------------

# Width of a string in inches, at the size ggplot will draw it. geom_text sizes
# are in mm, hence .pt to get to points.
text_inches <- function(strings, size_mm, family = "sans") {
  grDevices::pdf(NULL, width = 40, height = 40)
  on.exit(grDevices::dev.off(), add = TRUE)
  graphics::par(ps = size_mm * .pt, family = family)
  graphics::strwidth(strings, units = "inches")
}

# The layout depends on how wide the figure will be drawn, because the labels
# are a fixed size in inches while the blocks are a fixed size in data units,
# and coord_fixed ties the two together. So it is computed per figure width
# rather than once at load: pass the same width you give the chunk's fig-width.
scale_ladder_layout <- function(fig_width) {

  # Each block is as square as we can make it: a report with 280 authors gets a
  # 17-wide grid (ceiling of sqrt(280)), filled row by row.
  authors$block_width <- ceiling(sqrt(authors$authors)) * dot_gap

  # A block also has to make room for the text underneath it, or the early
  # reports -- whose blocks are a few dots wide but whose names are not -- run
  # into each other.
  #
  # The awkward part is the one noted above: the scale that converts a label's
  # inches into data units depends on the total width of the plot, which is the
  # very thing we are computing. So measure the labels, then solve for the
  # scale by iterating -- guess how many data units fit in an inch, see what
  # total width that implies, feed it back. It settles in a few passes as long
  # as the labels together are narrower than the figure.
  # formatC, not format: format() right-aligns a vector to a common width by
  # padding with spaces, and a padded string centres on its padding rather
  # than on its digits.
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
            "overlap. Widen the figure, or shorten the names in `short_names`.",
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

  # The rule under a block spans its whole slot, so it is always at least as
  # wide as the text sitting under it.
  authors$rule_end <- authors$x_start + authors$slot_width

  # A slot can be wider than the block standing in it, so centre the block --
  # the label underneath is centred on the same midpoint.
  authors$block_start <- authors$x_start +
    (authors$slot_width - authors$block_width) / 2

  # Now expand to one row per credited person, and give each person a spot
  # inside their report's grid: position 0 is bottom-left, then fill rightward.
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
# Everything below the dots is drawn at negative y, so the blocks all sit on
# y = 0 and the labels hang beneath them.

scale_ladder_plot <- function(fig_width = 7.5) {

  layout <- scale_ladder_layout(fig_width)
  dots   <- layout$dots
  labels <- layout$labels

  # geom_point sizes are in mm, so convert one grid cell into millimetres and
  # take the agreed fraction of it.
  mark_mm <- (dot_gap / layout$units_per_inch) * 25.4 * mark_fill

  ggplot() +

    # the squares: one per credited co-author
    geom_point(data = dots, aes(x, y, colour = lab_group),
               size = mark_mm, shape = 15) +

    # a short rule under each block, in that lab's colour. show.legend = FALSE
    # keeps the line out of the legend key, which is a square and only a square.
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

    # ggplot pads 5% onto each end of a range by default. Here that is just
    # inset, and it stops the figure reaching the full width of the column, so
    # take it back; clip = "off" below keeps the end labels from being cut.
    scale_x_continuous(expand = expansion(mult = 0.002)) +
    scale_y_continuous(expand = expansion(mult = 0.02)) +

    coord_fixed(clip = "off") +          # keeps the mark grid square
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

# capabilities("cairo") only reports that cairo was compiled in, not that it
# will load -- on a Mac without XQuartz it says TRUE and then fails at draw
# time. Ask the graphics module what it actually resolved instead. Don't probe
# by opening a cairo device: a failed open leaves grDevices in a state where
# the plain pdf() fallback errors too.
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
  # cairo_pdf embeds fonts properly, so prefer it where it really works.
  ggsave(scale_ladder_path("figures", "scale-ladder.pdf"), p, width = 7.5,
         height = 2.4,
         device = if (has_cairo()) cairo_pdf else grDevices::pdf)
}
