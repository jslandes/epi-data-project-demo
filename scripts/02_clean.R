# 02_clean.R
# Cleans and validates the raw case export for Q3 2024
#
# Input:  data/raw/cases_q3_2024_raw.csv
# Output: data/cleaned/cases_q3_2024.csv
#
# See GitHub Issues for decisions made during cleaning:
#   Issue #7  — FIPS code fixes
#   Issue #9  — date field selection (OPEN — do not derive analysis_date yet)
#   Issue #14 — race/ethnicity recoding

library(tidyverse)
library(janitor)
library(lubridate)
library(here)

# ── 1. Load raw data ──────────────────────────────────────────────────────────

raw <- read_csv(
  here("data", "raw", "cases_q3_2024_raw.csv"),
  col_types = cols(
    case_id              = col_character(),
    disease              = col_character(),
    report_date          = col_date(format = "%Y-%m-%d"),
    onset_date           = col_date(format = "%Y-%m-%d"),
    invest_complete_date = col_date(format = "%Y-%m-%d"),
    county_fips          = col_character(),   # preserve leading zeros
    age_group            = col_character(),
    sex                  = col_character(),
    race_ethnicity       = col_character(),
    hospitalized         = col_logical(),
    outcome              = col_character(),
    imported             = col_logical(),
    outbreak_related     = col_logical()
  )
) |>
  clean_names()

message("Loaded ", nrow(raw), " raw records.")

# ── 2. Validate FIPS codes ────────────────────────────────────────────────────
# Issue #7: 47 records had missing or malformed FIPS codes in the raw export.
# Fix: cross-reference against the CDC FIPS lookup table by county name.
# Status: IN PROGRESS — do not run suppression script until this is resolved.

fips_lookup <- read_csv(here("data", "lookups", "fips_codes.csv"),
                        col_types = cols(.default = col_character()))

cases <- raw |>
  left_join(fips_lookup, by = "county_fips", suffix = c("", "_lookup")) |>
  mutate(
    county_name = coalesce(county_name, county_name_lookup),
    fips_flag   = is.na(county_fips) | nchar(county_fips) != 5
  )

n_fips_problems <- sum(cases$fips_flag)
if (n_fips_problems > 0) {
  warning(n_fips_problems, " records still have FIPS issues — see Issue #7.")
}

# ── 3. Standardize disease names ─────────────────────────────────────────────

disease_groups <- read_csv(here("data", "lookups", "disease_groups.csv"),
                           col_types = cols(.default = col_character()))

cases <- cases |>
  left_join(disease_groups, by = "disease")

# ── 4. Recode race/ethnicity ──────────────────────────────────────────────────
# Issue #14: recoding to OMB 2024 categories. OPEN — mapping not finalized.
# Placeholder below; update once Issue #14 is resolved.

cases <- cases |>
  mutate(
    race_ethnicity = case_when(
      race_ethnicity %in% c("Hispanic", "Latino", "Hispanic or Latino") ~ "Hispanic or Latino",
      race_ethnicity %in% c("White", "White non-Hispanic")              ~ "White, non-Hispanic",
      race_ethnicity %in% c("Black", "Black or African American")       ~ "Black or African American",
      race_ethnicity == "Asian"                                          ~ "Asian",
      race_ethnicity %in% c("AIAN", "American Indian or Alaska Native") ~ "American Indian or Alaska Native",
      race_ethnicity %in% c("NHPI", "Native Hawaiian or Pacific Islander") ~ "Native Hawaiian or Pacific Islander",
      race_ethnicity %in% c("Multiracial", "More than one race")        ~ "Multiracial",
      TRUE                                                               ~ "Unknown"
    )
  )

# ── 5. Date field note ────────────────────────────────────────────────────────
# Issue #9 is OPEN: the team has not decided whether to use report_date or
# onset_date as the primary analysis date. Both fields are retained here.
# Do NOT derive an analysis_date variable until Issue #9 is closed.

# ── 6. Write cleaned output ───────────────────────────────────────────────────

cases |>
  select(-ends_with("_lookup"), -fips_flag) |>
  write_csv(here("data", "cleaned", "cases_q3_2024.csv"))

message("Wrote ", nrow(cases), " cleaned records to data/cleaned/cases_q3_2024.csv")
