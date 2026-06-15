# 03_suppress.R
# Applies cell suppression rules to the cleaned case data
#
# Input:  data/cleaned/cases_q3_2024.csv
# Output: data/cleaned/cases_q3_2024_suppressed.csv
#
# Policy: docs/suppression-policy.md
# Issues: #11 (complementary suppression edge cases — OPEN)
#
# !! Do not run this script until Issue #7 (FIPS fixes) is resolved.
# !! Running suppression on incomplete county data will produce wrong results.

library(tidyverse)
library(here)

SUPPRESS_THRESHOLD <- 5   # cells with n < this value are suppressed

cases <- read_csv(here("data", "cleaned", "cases_q3_2024.csv"),
                  col_types = cols(.default = col_character()))

# ── Primary suppression ───────────────────────────────────────────────────────
# Flag any county × disease cell with fewer than SUPPRESS_THRESHOLD cases.

county_disease_counts <- cases |>
  count(county_fips, county_name, disease, name = "n") |>
  mutate(suppressed_primary = n < SUPPRESS_THRESHOLD)

# ── Complementary suppression ─────────────────────────────────────────────────
# Issue #11: edge cases in complementary suppression logic are not fully
# resolved. The block below is a placeholder — review Issue #11 before
# using this output in any published table.

county_disease_counts <- county_disease_counts |>
  group_by(county_fips) |>
  arrange(n) |>
  mutate(
    suppressed_complementary = suppressed_primary & row_number() == 2
  ) |>
  ungroup() |>
  mutate(
    suppressed = suppressed_primary | suppressed_complementary,
    n_display  = if_else(suppressed, "<5", as.character(n))
  )

# ── Join suppression flags back to case records ───────────────────────────────

cases_out <- cases |>
  left_join(
    county_disease_counts |> select(county_fips, disease, suppressed),
    by = c("county_fips", "disease")
  )

write_csv(cases_out, here("data", "cleaned", "cases_q3_2024_suppressed.csv"))

message(
  "Suppression complete. ",
  sum(county_disease_counts$suppressed), " of ",
  nrow(county_disease_counts), " county-disease cells suppressed."
)
