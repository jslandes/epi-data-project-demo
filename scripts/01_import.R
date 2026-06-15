# 01_import.R
# Pulls case data from the state surveillance system and saves to data/raw/
#
# In production, this script connects to the state's SFTP server and downloads
# the quarterly case export. For the demo environment, it generates a synthetic
# dataset with realistic structure and saves it as if it were a real export.
#
# Output: data/raw/cases_q3_2024_raw.csv
#
# Run this script first, before any other script in the pipeline.

library(tidyverse)
library(lubridate)
library(here)

set.seed(2024)

# ── Configuration ─────────────────────────────────────────────────────────────

QUARTER_START <- as.Date("2024-07-01")
QUARTER_END   <- as.Date("2024-09-30")
EXPORT_DATE   <- as.Date("2024-10-04")
N_CASES       <- 1423

# ── Reference values ──────────────────────────────────────────────────────────

diseases <- c(
  "Salmonella (non-typhoidal)", "Salmonella (non-typhoidal)", "Salmonella (non-typhoidal)",
  "Campylobacter", "Campylobacter",
  "Shigella",
  "Hepatitis A",
  "Pertussis", "Pertussis",
  "Lyme disease", "Lyme disease", "Lyme disease"
)

counties <- tibble(
  county_fips = c("36001", "36009", "36013", "36021", "36029",
                  "36035", "36039", "36043", "36049", "36055",
                  "36063", "36067", "36075", "36083", "36091",
                  "36099", "36103", "36111", "36117", "36123"),
  county_name = c("Albany", "Cattaraugus", "Chautauqua", "Columbia", "Erie",
                  "Fulton", "Greene", "Herkimer", "Lewis", "Monroe",
                  "Niagara", "Onondaga", "Oswego", "Rockland", "Saratoga",
                  "Steuben", "Suffolk", "Ulster", "Schuyler", "Yates"),
  pop_weight  = c(8, 2, 3, 2, 12, 1, 1, 1, 1, 9,
                  3, 7, 2, 4, 4, 2, 10, 3, 1, 1)
)

age_groups <- c("<1", "1-4", "5-9", "10-14", "15-19",
                "20-24", "25-34", "35-44", "45-54",
                "55-64", "65-74", "75-84", "85+")

sex_vals <- c("Male", "Female", "Unknown")

race_eth_vals <- c(
  "White non-Hispanic", "White non-Hispanic", "White non-Hispanic",
  "Black or African American", "Black or African American",
  "Hispanic", "Hispanic",
  "Asian",
  "AIAN",
  "Multiracial",
  "Unknown", "Unknown"
)

# Introduce some dirty values to make cleaning realistic
race_eth_dirty <- c(race_eth_vals,
                    "Latino", "Black", "white", "NHPI",
                    "Hispanic female", "Mexican American", "unknown", "refused")

outcomes  <- c("Alive", "Alive", "Alive", "Alive", "Alive", "Unknown", "Died")

# ── Generate cases ────────────────────────────────────────────────────────────

county_sample <- sample(
  counties$county_fips,
  size    = N_CASES,
  replace = TRUE,
  prob    = counties$pop_weight
)

disease_sample <- sample(diseases, size = N_CASES, replace = TRUE)

report_dates <- sample(
  seq(QUARTER_START, QUARTER_END, by = "day"),
  size    = N_CASES,
  replace = TRUE
)

# onset date: precedes report date by 3–28 days; missing ~18% of the time
onset_lag   <- sample(3:28, size = N_CASES, replace = TRUE)
onset_dates <- report_dates - onset_lag
onset_dates[sample(1:N_CASES, size = round(N_CASES * 0.183))] <- NA

# investigation complete date: 0–21 days after report date
invest_lag            <- sample(0:21, size = N_CASES, replace = TRUE)
invest_complete_dates <- report_dates + invest_lag

cases <- tibble(
  case_id              = paste0("CDR-2024-", sample(10000:99999, N_CASES, replace = FALSE)),
  disease              = disease_sample,
  report_date          = format(report_dates, "%Y-%m-%d"),
  onset_date           = if_else(!is.na(onset_dates), format(onset_dates, "%Y-%m-%d"), NA_character_),
  invest_complete_date = format(invest_complete_dates, "%Y-%m-%d"),
  county_fips          = county_sample,
  age_group            = sample(age_groups, N_CASES, replace = TRUE,
                                prob = c(1,3,4,4,5,7,10,10,12,13,12,9,5) / 95),
  sex                  = sample(sex_vals, N_CASES, replace = TRUE, prob = c(48, 48, 4)),
  race_ethnicity       = sample(race_eth_dirty, N_CASES, replace = TRUE),
  hospitalized         = sample(c(TRUE, FALSE, NA), N_CASES, replace = TRUE,
                                prob = c(0.08, 0.88, 0.04)),
  outcome              = sample(outcomes, N_CASES, replace = TRUE),
  imported             = sample(c(TRUE, FALSE), N_CASES, replace = TRUE, prob = c(0.06, 0.94)),
  outbreak_related     = sample(c(TRUE, FALSE), N_CASES, replace = TRUE, prob = c(0.12, 0.88))
)

# ── Introduce known data quality problems ─────────────────────────────────────

# Problem 1: 47 records with missing or malformed FIPS (Issue #7)
fips_problems <- sample(1:N_CASES, 47)
cases$county_fips[fips_problems[1:31]]  <- NA_character_            # 31 blank
cases$county_fips[fips_problems[32:45]] <- substr(                  # 14 missing leading zero
  cases$county_fips[fips_problems[32:45]], 2, 5)
cases$county_fips[fips_problems[46:47]] <- c("36999", "36000")      # 2 invalid codes

# Problem 2: 6 duplicate case IDs (Issue #4 — closed, but realistic to have had)
dup_rows <- sample(1:N_CASES, 6)
dups <- cases[dup_rows, ] |>
  mutate(
    invest_complete_date = format(as.Date(invest_complete_date) + sample(1:3, 6, replace = TRUE),
                                  "%Y-%m-%d")
  )
cases <- bind_rows(cases, dups)

# ── Write output ──────────────────────────────────────────────────────────────

dir.create(here("data", "raw"), showWarnings = FALSE, recursive = TRUE)

write_csv(cases, here("data", "raw", "cases_q3_2024_raw.csv"))

message(
  "Export complete.\n",
  "  Records written: ", nrow(cases), "\n",
  "  Export date:     ", EXPORT_DATE, "\n",
  "  Saved to:        data/raw/cases_q3_2024_raw.csv\n",
  "\nKnown issues in this export:",
  "\n  - 47 records with missing or malformed FIPS codes (see Issue #7)",
  "\n  - 6 duplicate case IDs (legacy issue; dedup logic in 02_clean.R)"
)
