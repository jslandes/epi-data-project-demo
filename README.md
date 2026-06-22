# Communicable Disease Quarterly Report

**Workgroup:** Region 4 Epidemiology Data Team  
**Reporting period:** Q3 2024 (July 1 - September 30)  
**Status:** 🟡 In progress - data cleaning phase

## What this repository is for

This repo tracks the data work behind our quarterly communicable disease report. That includes:

- Cleaning and validating case data pulled from the state surveillance system
- Applying suppression rules before any county-level numbers are released publicly
- Producing the summary tables and figures that go into the report
- Keeping a record of every analytical decision we made and why

If you're new to the team, start with [`docs/data-dictionary.md`](docs/data-dictionary.md) and [`docs/suppression-policy.md`](docs/suppression-policy.md).

## Repository layout
```
/
├── data/
│   ├── raw/            ← Original exports from the surveillance system (do not edit)
│   ├── cleaned/        ← Output of cleaning scripts; these are the analysis-ready files
│   └── lookups/        ← Reference tables (FIPS codes, ICD codes, disease groupings)
│
├── scripts/
│   ├── 01_import.R          ← Pulls data from the state system and saves to data/raw/
│   ├── 02_clean.R           ← Cleans, validates, and writes to data/cleaned/
│   ├── 03_suppress.R        ← Applies cell suppression rules
│   ├── 04_summarize.R       ← Produces the summary tables
│   └── 05_figures.R         ← Generates charts for the report
│
├── reports/
│   ├── quarterly_report_Q3_2024.Rmd    ← Main report document (knit to HTML and PDF)
│   └── output/                         ← Rendered HTML and PDF output
│
└── docs/
    ├── data-dictionary.md       ← Variable definitions and coding notes
    ├── suppression-policy.md    ← Our cell suppression rules and rationale
    ├── data-use-agreement.md    ← DUA terms relevant to this dataset
    └── changelog.md             ← Running log of data changes and decisions
```


## How we use GitHub Issues and Projects

Every task, problem, or decision that affects the analysis gets an Issue. This is how we:

- Track what's done and what's blocking us
- Record *why* we made analytical decisions, not just what we did
- Hand off work without losing context

The **[Q3 2024 Report Board](../../projects)** is our main project board. Check it at the start of every team meeting.

## Data notes for this quarter

| Item | Detail |
|---|---|
| Source system | State notifiable disease surveillance system |
| Export date | 2024-10-04 |
| Diseases included | Salmonella, Campylobacter, Hepatitis A, Pertussis, Shigella, Lyme disease |
| Geographic level | County (FIPS code) |
| Date fields | Report date, onset date, investigation complete date |
| Primary analysis tool | R (tidyverse, janitor, knitr, ggplot2) |
| Report format | RMarkdown → HTML and PDF |
| Known issues | See [open issues](../../issues) |

## R environment

We use `renv` to keep package versions consistent across machines. After cloning:

```r
install.packages("renv")
renv::restore()
```

Key packages: `tidyverse`, `janitor`, `lubridate`, `knitr`, `rmarkdown`, `kableExtra`, `ggplot2`, `readxl`, `here`.

## Contacts

| Role | Person |
|---|---|
| Data lead | Jordan T. |
| Epi lead | Dr. Reyes |
| Report coordinator | Sam W. |
| IT/systems contact | helpdesk@region4health.org |

## Quick links

- [Open issues](../../issues)
- [Q3 Report Project Board](../../projects)
- [All project boards](../../projects)
- [Data dictionary](docs/data-dictionary.md)
- [Suppression policy](docs/suppression-policy.md)
- [Changelog](docs/changelog.md)
