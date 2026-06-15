# 05_figures.R
# Generates charts for the quarterly report
#
# Input:  data/cleaned/cases_q3_2024_suppressed.csv
# Output: reports/output/figures/  (PNG files, 300 dpi)
#
# Run after 04_summarize.R.
#
# Open issues affecting this script:
#   Issue #8  — legend grouping by disease_group (OPEN — good first issue)
#   Issue #9  — date field for trend figure (OPEN — trend figure skipped)

library(tidyverse)
library(lubridate)
library(here)

# ── Setup ─────────────────────────────────────────────────────────────────────

dir.create(here("reports", "output", "figures"), showWarnings = FALSE, recursive = TRUE)

cases <- read_csv(
  here("data", "cleaned", "cases_q3_2024_suppressed.csv"),
  col_types = cols(.default = col_character())
) |>
  mutate(
    report_date  = as.Date(report_date),
    onset_date   = as.Date(onset_date),
    hospitalized = as.logical(hospitalized),
    suppressed   = as.logical(suppressed)
  )

# ── Color palette ─────────────────────────────────────────────────────────────
# Issue #8: currently coloring by disease. Once Issue #8 is resolved,
# switch to coloring by disease_group with linetype for individual diseases.

disease_colors <- c(
  "Salmonella (non-typhoidal)" = "#2196F3",
  "Campylobacter"              = "#64B5F6",
  "Shigella"                   = "#0D47A1",
  "Hepatitis A"                = "#4CAF50",
  "Pertussis"                  = "#1B5E20",
  "Lyme disease"               = "#FF9800"
)

group_colors <- c(
  "Enteric"              = "#2196F3",
  "Vaccine-preventable"  = "#4CAF50",
  "Vector-borne"         = "#FF9800"
)

report_theme <- theme_minimal(base_size = 12) +
  theme(
    plot.title    = element_text(face = "bold", size = 13),
    plot.subtitle = element_text(color = "grey40", size = 10),
    legend.position = "bottom",
    panel.grid.minor = element_blank()
  )

save_fig <- function(plot, filename, width = 8, height = 5) {
  ggsave(
    filename = here("reports", "output", "figures", filename),
    plot     = plot,
    width    = width,
    height   = height,
    dpi      = 300
  )
  message("Saved: reports/output/figures/", filename)
}

# ── Figure 1: Total cases by disease (bar chart) ─────────────────────────────

fig1 <- cases |>
  filter(!suppressed) |>
  count(disease_group, disease) |>
  mutate(disease = fct_reorder(disease, n)) |>
  ggplot(aes(x = n, y = disease, fill = disease_group)) +
  geom_col() +
  geom_text(aes(label = n), hjust = -0.2, size = 3.5) +
  scale_fill_manual(values = group_colors, name = "Disease group") +
  scale_x_continuous(expand = expansion(mult = c(0, 0.15))) +
  labs(
    title    = "Figure 1. Reported cases by disease, Q3 2024",
    subtitle = "Region 4 | July 1 – September 30, 2024",
    x        = "Number of cases",
    y        = NULL
  ) +
  report_theme

save_fig(fig1, "fig1_cases_by_disease.png")

# ── Figure 2: Cases by county (horizontal bar) ───────────────────────────────

fig2 <- cases |>
  filter(!suppressed, !is.na(county_name)) |>
  count(county_name, disease_group) |>
  mutate(county_name = fct_reorder(county_name, n, sum)) |>
  ggplot(aes(x = n, y = county_name, fill = disease_group)) +
  geom_col() +
  scale_fill_manual(values = group_colors, name = "Disease group") +
  scale_x_continuous(expand = expansion(mult = c(0, 0.05))) +
  labs(
    title    = "Figure 2. Reported cases by county, Q3 2024",
    subtitle = "Suppressed cells (<5 cases) excluded",
    x        = "Number of cases",
    y        = NULL
  ) +
  report_theme

save_fig(fig2, "fig2_cases_by_county.png")

# ── Figure 3: Age distribution ────────────────────────────────────────────────

age_order <- c("<1", "1-4", "5-9", "10-14", "15-19",
               "20-24", "25-34", "35-44", "45-54",
               "55-64", "65-74", "75-84", "85+")

fig3 <- cases |>
  filter(!suppressed) |>
  mutate(age_group = factor(age_group, levels = age_order)) |>
  count(age_group, disease_group) |>
  ggplot(aes(x = age_group, y = n, fill = disease_group)) +
  geom_col(position = "stack") +
  scale_fill_manual(values = group_colors, name = "Disease group") +
  labs(
    title    = "Figure 3. Cases by age group and disease group, Q3 2024",
    x        = "Age group",
    y        = "Number of cases"
  ) +
  report_theme +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

save_fig(fig3, "fig3_age_distribution.png")

# ── Figure 4: Weekly trend (BLOCKED on Issue #9) ──────────────────────────────

issue9_open <- TRUE   # flip to FALSE once Issue #9 is closed

if (issue9_open) {
  warning(
    "Figure 4 (weekly trend) skipped — Issue #9 (date field decision) is still open."
  )
} else {
  fig4 <- cases |>
    filter(!suppressed) |>
    mutate(
      analysis_date = report_date,  # replace with onset_date if that's the decision
      report_week   = floor_date(analysis_date, "week")
    ) |>
    count(report_week, disease_group) |>
    ggplot(aes(x = report_week, y = n, color = disease_group)) +
    geom_line(linewidth = 1) +
    geom_point(size = 2) +
    scale_color_manual(values = group_colors, name = "Disease group") +
    scale_x_date(date_breaks = "2 weeks", date_labels = "%b %d") +
    labs(
      title    = "Figure 4. Weekly case counts by disease group, Q3 2024",
      subtitle = "Week of report date | Region 4",   # update if onset_date used
      x        = NULL,
      y        = "Cases"
    ) +
    report_theme

  save_fig(fig4, "fig4_weekly_trend.png", width = 10, height = 5)
}

message("\nFigure generation complete.")
