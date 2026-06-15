# 04_summarize.R
# Produces summary tables from the suppressed case data
#
# Input:  data/cleaned/cases_q3_2024_suppressed.csv
# Output: data/cleaned/tables/  (one CSV per table)
#
# These tables feed directly into quarterly_report_Q3_2024.Rmd.
# Run after 03_suppress.R.
#
# !! Issue #9 (date field) must be resolved before the time-trend table
#    is produced. That section is currently set to skip with a warning.

library(tidyverse)
library(here)

# ── Load data ─────────────────────────────────────────────────────────────────

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

dir.create(here("data", "cleaned", "tables"), showWarnings = FALSE, recursive = TRUE)

SUPPRESS_THRESHOLD <- 5

display_n <- function(n) if_else(n < SUPPRESS_THRESHOLD, "<5", as.character(n))

# ── Table 1: Total cases by disease ───────────────────────────────────────────

table1 <- cases |>
  count(disease_group, disease, name = "cases") |>
  arrange(disease_group, disease) |>
  mutate(cases = display_n(cases))

write_csv(table1, here("data", "cleaned", "tables", "table1_cases_by_disease.csv"))
message("Table 1 written: cases by disease (", nrow(table1), " rows)")

# ── Table 2: Cases by county and disease group ────────────────────────────────

table2 <- cases |>
  filter(!suppressed) |>
  count(county_name, disease_group, name = "cases") |>
  pivot_wider(
    names_from  = disease_group,
    values_from = cases,
    values_fill = 0
  ) |>
  rowwise() |>
  mutate(Total = sum(c_across(where(is.numeric)), na.rm = TRUE)) |>
  ungroup() |>
  arrange(county_name) |>
  mutate(across(where(is.numeric), display_n))

write_csv(table2, here("data", "cleaned", "tables", "table2_cases_by_county_group.csv"))
message("Table 2 written: cases by county and disease group (", nrow(table2), " rows)")

# ── Table 3: Age group distribution ──────────────────────────────────────────

age_order <- c("<1", "1-4", "5-9", "10-14", "15-19",
               "20-24", "25-34", "35-44", "45-54",
               "55-64", "65-74", "75-84", "85+")

table3 <- cases |>
  mutate(age_group = factor(age_group, levels = age_order)) |>
  count(age_group, disease_group, name = "cases") |>
  pivot_wider(
    names_from  = disease_group,
    values_from = cases,
    values_fill = 0
  ) |>
  arrange(age_group) |>
  mutate(across(where(is.numeric), display_n))

write_csv(table3, here("data", "cleaned", "tables", "table3_age_distribution.csv"))
message("Table 3 written: age distribution (", nrow(table3), " rows)")

# ── Table 4: Hospitalization and outcomes ─────────────────────────────────────

table4 <- cases |>
  group_by(disease_group, disease) |>
  summarise(
    total_cases   = n(),
    hospitalized  = sum(hospitalized == TRUE, na.rm = TRUE),
    pct_hosp      = round(hospitalized / total_cases * 100, 1),
    deaths        = sum(outcome == "Died", na.rm = TRUE),
    .groups       = "drop"
  ) |>
  mutate(
    hospitalized = display_n(hospitalized),
    deaths       = display_n(deaths),
    pct_hosp     = if_else(total_cases < SUPPRESS_THRESHOLD, NA_real_, pct_hosp),
    total_cases  = display_n(total_cases)
  )

write_csv(table4, here("data", "cleaned", "tables", "table4_hospitalization_outcomes.csv"))
message("Table 4 written: hospitalization and outcomes")

# ── Table 5: Weekly trend (BLOCKED on Issue #9) ───────────────────────────────
# Issue #9 — date field not yet decided. This table is skipped until resolved.

issue9_open <- TRUE   # flip to FALSE once Issue #9 is closed

if (issue9_open) {
  warning(
    "Table 5 (weekly trend) skipped — Issue #9 (date field decision) is still open.\n",
    "Once the team decides between report_date and onset_date, set issue9_open <- FALSE\n",
    "and rerun this script."
  )
} else {
  table5 <- cases |>
    mutate(analysis_date = report_date,   # replace with onset_date if that's the decision
           report_week   = floor_date(analysis_date, "week")) |>
    count(report_week, disease_group, name = "cases") |>
    pivot_wider(
      names_from  = disease_group,
      values_from = cases,
      values_fill = 0
    ) |>
    arrange(report_week)

  write_csv(table5, here("data", "cleaned", "tables", "table5_weekly_trend.csv"))
  message("Table 5 written: weekly trend (", nrow(table5), " rows)")
}

message("\nAll tables written to data/cleaned/tables/")
