# Data dictionary for Q3 2024 case data

Last updated: 2024-10-07 | Maintained by: Jordan T.

This document defines every variable in the cleaned case-level dataset (`data/cleaned/cases_q3_2024.csv`). If a variable's meaning is unclear or a coding decision was made mid-project, there should be a corresponding GitHub Issue explaining the decision.

---

## Case-level variables

| Variable | Type | Description | Notes |
|---|---|---|---|
| `case_id` | character | Unique case identifier from state system | De-identified; do not use to re-link to PII |
| `disease` | character | Disease name (see disease groupings below) | Standardized in `02_clean.R` |
| `disease_group` | character | Broad grouping for summary tables | See `data/lookups/disease_groups.csv` |
| `report_date` | date | Date case was reported to the health department | YYYY-MM-DD format |
| `onset_date` | date | Patient-reported or estimated date of symptom onset | Missing in ~18% of records; see Issue #5 |
| `invest_complete_date` | date | Date investigation was marked complete | |
| `county_fips` | character | 5-digit FIPS code for county of residence | Leading zeros preserved as character; see [Issue #7](../../issues/7) |
| `county_name` | character | County name | Added in `02_clean.R` via FIPS lookup |
| `age_group` | character | Age group at time of report | 5-year bands; `<1`, `1-4`, `5-9`, ... `85+` |
| `sex` | character | Sex as recorded in surveillance system | `Male`, `Female`, `Unknown` |
| `race_ethnicity` | character | Combined race/ethnicity field | Recoded to OMB 2024 categories; see [Issue #14](../../issues/14) |
| `hospitalized` | logical | Whether hospitalization was recorded | `TRUE`, `FALSE`, `NA` |
| `outcome` | character | Case outcome | `Alive`, `Died`, `Unknown` |
| `imported` | logical | Whether case was travel-related/imported | |
| `outbreak_related` | logical | Whether case was linked to an outbreak | |
| `suppressed` | logical | Whether cell was suppressed in output | Added by `03_suppress.R` |

---

## Disease groupings

| `disease` | `disease_group` |
|---|---|
| Salmonella (non-typhoidal) | Enteric |
| Campylobacter | Enteric |
| Shigella | Enteric |
| Hepatitis A | Vaccine-preventable |
| Pertussis | Vaccine-preventable |
| Lyme disease | Vector-borne |

---

## Date field guidance

There is an open decision on which date field to use as the primary analysis date. See [Issue #9](../../issues/9) for the full discussion. Until that issue is closed, `02_clean.R` retains both `report_date` and `onset_date` and does not derive an `analysis_date` field.

---

## Suppression rules

See [`docs/suppression-policy.md`](suppression-policy.md) for the full policy. In the dataset, any record with `suppressed = TRUE` was excluded from county-level published counts.
