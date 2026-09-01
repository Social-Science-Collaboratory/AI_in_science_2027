# Mockup: variable-importance figure for predicting researcher migration.
# Forest-plot layout: each predictor block opens with a bold category row that
# carries an EMPIRICAL density of every importance value in the block (kernel
# density - no normal is fitted, unlike GlobalGratitude Figure 2). Item rows
# below it are grey diamonds + 95% CI over the per-model points, coloured by
# model class, plotted behind them.
# Columns: domestic vs. international moves.
# Rows: Individual / Cultural / Socioeconomic predictor blocks.
# ALL IMPORTANCES ARE SIMULATED — mockup only. Verbatim copy of
# migration_varimp_mockup.R apart from the output size and path at the end;
# it produces panel C of the checkin-workflow figure, which is why that panel
# (and only that panel) carries the MOCK watermark.

suppressPackageStartupMessages({
    library(dplyr)
    library(tidyr)
    library(ggplot2)
    library(ggtext)
})

set.seed(1967)

# ---- Panels and predictors --------------------------------------------------

panel_levels <- c("Domestic moves", "International moves")

level_levels <- c("Individual Predictors",
                  "Cultural Predictors",
                  "Socioeconomic Predictors")

# Each block opens with a bold summary row; item rows are indented under it.
cat_names <- setNames(c("Individual-level predictors",
                        "Cultural-level predictors",
                        "Socioeconomic-level predictors"), level_levels)

cat_lab  <- function(x) paste0("**", x, "**")
# gridtext trims leading whitespace, so the indent is a white (invisible) spacer
item_lab <- function(x) paste0("<span style='color:#FFFFFF'>nn</span>", x)

individual <- c(
    "pre-move citations (non-DEI)",
    "pre-move citations (DEI)",
    "pre-move papers (non-DEI)",
    "pre-move papers (DEI)",
    "pre-move h-index",
    "career age at move"
)

cultural <- c(
    "Δ cultural tightness",
    "Δ cultural individualism",
    "Δ cultural flexibility"
)

socioeconomic <- c(
    "Δ health index",
    "Δ education index",
    "Δ standard of living",
    "Δ life expectancy",
    "Δ gross national income per capita",
    "Δ mean years of schooling",
    "Δ expected years of schooling"
)

predictors <- c(individual, cultural, socioeconomic)

pred_level <- tibble(
    predictor = predictors,
    level = factor(rep(level_levels,
                       c(length(individual), length(cultural), length(socioeconomic))),
                   levels = level_levels)
)

# top-to-bottom row order within the figure, with numeric positions: the y scale
# has to be continuous so the category density has somewhere to go
row_order <- unlist(lapply(level_levels, function(l)
    c(cat_lab(cat_names[[l]]),
      item_lab(pred_level$predictor[pred_level$level == l]))),
    use.names = FALSE)

# Blocks are separated by a gap wide enough that the headroom reserved for the
# density in one facet cannot reach the neighbouring block's rows - otherwise
# free_y expansion drags foreign axis labels into the facet.
BLOCK_GAP <- 3

row_pos <- local({
    pos <- 0; out <- list()
    for (l in rev(level_levels)) {
        items <- item_lab(pred_level$predictor[pred_level$level == l])
        for (lab in c(rev(items), cat_lab(cat_names[[l]]))) {
            pos <- pos + 1
            out[[length(out) + 1]] <- tibble(predictor = lab, ypos = pos)
        }
        pos <- pos + BLOCK_GAP
    }
    bind_rows(out)
})

# ---- Model classes: same palette and levels as Figure 3 ---------------------

model_classes <- c("CatBoost", "ExtraTrees", "LightGBM",
                   "NeuralNetTorch", "RandomForest", "XGBoost", "Other")
model_pal <- c("#E69F00", "#0072B2", "#009E73",
               "#CC79A7", "#D55E00", "#56B4E9", "#8B1A1A")
names(model_pal) <- model_classes
summ_col <- "grey25"   # category (summary) rows
item_col <- "grey40"   # item rows

# top 3 configs per model class
models <- paste0(rep(model_classes, each = 3), "_top", 1:3)
model_class_of <- sub("_.*$", "", models)

# ---- Simulated mean importance profiles per panel ---------------------------
# Simulated story: domestic moves are driven by destination culture and by DEI-
# adjacent output; international moves are driven by career capital and by
# human-development / income gaps.

profile <- tribble(
    ~predictor,                            ~Domestic, ~International,
    "pre-move citations (non-DEI)",             0.45,           0.72,
    "pre-move citations (DEI)",                 0.62,           0.48,
    "pre-move papers (non-DEI)",                0.40,           0.66,
    "pre-move papers (DEI)",                    0.55,           0.44,
    "pre-move h-index",                         0.48,           0.80,
    "career age at move",                       0.58,           0.62,
    "Δ cultural tightness",                     0.70,           0.52,
    "Δ cultural individualism",                 0.54,           0.60,
    "Δ cultural flexibility",                   0.62,           0.50,
    "Δ health index",                           0.38,           0.55,
    "Δ education index",                        0.42,           0.58,
    "Δ standard of living",                     0.66,           0.78,
    "Δ life expectancy",                        0.32,           0.60,
    "Δ gross national income per capita",       0.50,           0.85,
    "Δ mean years of schooling",                0.40,           0.52,
    "Δ expected years of schooling",            0.38,           0.50
)

profile_long <- profile |>
    pivot_longer(-predictor, names_to = "panel", values_to = "mu") |>
    mutate(panel = paste(panel, "moves"))

# ---- Simulate per-model importances -----------------------------------------
# Draw noisy importances around each panel profile, then rescale each model to
# its own maximum (as the real pipeline does), so values live on [0, 1].

sim <- expand_grid(panel = panel_levels, model = models) |>
    left_join(tibble(model = models, model_class = model_class_of), by = "model") |>
    left_join(profile_long, by = "panel", relationship = "many-to-many") |>
    mutate(raw = pmax(rnorm(n(), mean = mu, sd = 0.16), 0)) |>
    group_by(panel, model) |>
    mutate(scaled = raw / max(raw)) |>
    ungroup() |>
    left_join(pred_level, by = "predictor") |>
    mutate(
        panel       = factor(panel, levels = panel_levels),
        predictor   = factor(predictor, levels = rev(predictors)),
        model_class = factor(model_class, levels = model_classes)
    )

# Item rows: one diamond + interval per predictor, model cloud behind it.
summ <- sim |>
    group_by(panel, level, predictor) |>
    summarise(mean_imp = mean(scaled),
              se = sd(scaled) / sqrt(n()),
              .groups = "drop") |>
    mutate(predictor = item_lab(as.character(predictor)),
           lb = pmax(mean_imp - 1.96 * se, 0),
           ub = pmin(mean_imp + 1.96 * se, 1)) |>
    left_join(row_pos, by = "predictor")

sim <- sim |>
    mutate(predictor = item_lab(as.character(predictor))) |>
    left_join(row_pos, by = "predictor")

# Category rows: empirical density over every model x predictor value in the
# block. No distributional form is imposed - this is a kernel density of the
# same dots the item rows summarise.
cat_pos <- tibble(level = factor(level_levels, levels = level_levels),
                  predictor = cat_lab(cat_names[level_levels])) |>
    left_join(row_pos, by = "predictor")

DENS_H <- 1.4   # density height, in row units

# The y spine is drawn by hand so it stops at the category row's baseline
# instead of running up the side of the density. Only the left column carries
# it, and in the bottom block it runs to the panel edge to meet the x axis.
yaxis_seg <- lapply(level_levels, function(l) {
    labs <- c(cat_lab(cat_names[[l]]),
              item_lab(pred_level$predictor[pred_level$level == l]))
    yy <- row_pos$ypos[match(labs, row_pos$predictor)]
    tibble(level = l,
           y0 = if (l == tail(level_levels, 1)) -Inf else min(yy),
           y1 = max(yy))
}) |>
    bind_rows() |>
    mutate(level = factor(level, levels = level_levels),
           panel = factor(panel_levels[1], levels = panel_levels))

dens <- sim |>
    group_by(panel, level) |>
    group_modify(~ {
        d <- stats::density(.x$scaled, from = 0, to = 1, n = 512)
        tibble(x = d$x, h = d$y / max(d$y))
    }) |>
    ungroup() |>
    left_join(select(cat_pos, level, ypos), by = "level")

# ---- Figure (geoms/theme mirror varimp_plot_by_model) -----------------------

base_size <- 12
k <- base_size / 12

fig <- ggplot(mapping = aes(y = ypos)) +
    geom_point(data = sim, aes(x = scaled, color = model_class), shape = 16,
               position = position_jitter(height = 0.2, width = 0, seed = 1967),
               size = 1.7 * k, alpha = 0.22) +
    # item rows: grey diamond + 95% CI
    geom_errorbar(data = summ, aes(xmin = lb, xmax = ub),
                  orientation = "y", width = 0, linewidth = 1.0 * k,
                  color = item_col) +
    geom_point(data = summ, aes(x = mean_imp),
               shape = 23, size = 3.2 * k, stroke = 0,
               color = item_col, fill = item_col) +
    geom_segment(data = yaxis_seg,
                 aes(x = -Inf, xend = -Inf, y = y0, yend = y1),
                 inherit.aes = FALSE, linewidth = 0.5, colour = "black",
                 lineend = "square") +
    # category rows: empirical density of the whole block
    geom_ribbon(data = dens,
                aes(x = x, ymin = ypos, ymax = ypos + DENS_H * h,
                    group = interaction(panel, level)),
                inherit.aes = FALSE,
                fill = "grey86", color = NA) +
    scale_x_continuous(limits = c(0, 1), breaks = c(0, 0.5, 1)) +
    scale_y_continuous(breaks = row_pos$ypos, labels = row_pos$predictor,
                       expand = expansion(add = c(0.7, DENS_H + 0.4))) +
    scale_color_manual(values = model_pal, name = NULL, drop = FALSE,
                       guide = guide_legend(nrow = 1,
                                            override.aes = list(alpha = 1, size = 3 * k))) +
    facet_grid(level ~ panel, scales = "free_y", space = "free_y") +
    labs(x = "Estimated Variable Importance", y = NULL) +
    theme_classic(base_size = base_size) +
    theme(strip.background = element_blank(),
          axis.line.y     = element_blank(),
          axis.ticks.y    = element_blank(),
          strip.text.x    = element_text(face = "bold", size = base_size + 1,
                                         margin = margin(b = 6 * k, t = 0)),
          strip.text.y    = element_blank(),
          axis.text.y     = element_markdown(hjust = 0, size = base_size - 2),
          panel.spacing.x = unit(1.4, "lines"),
          panel.spacing.y = unit(1.0, "lines"),
          legend.position = "bottom",
          legend.box.margin = margin(t = 2 * k),
          legend.key.spacing.x = unit(0.8, "lines"),
          plot.margin     = margin(8, 14, 8, 10) * k)

# Rendered at the book's full text width (12in less the figure's 0.12in
# margins) so panel C spans the same width as row 1 of the multipanel, rather
# than sitting centred and narrow. The original mockup was 10.5 x 8.6; only
# these output dimensions differ from that script.
ggsave("checkin-workflow/images/panel-c-simulated-figure.png", fig,
       width = 11.76, height = 7.0, dpi = 300, bg = "white")
cat("saved checkin-workflow/images/panel-c-simulated-figure.png\n")
