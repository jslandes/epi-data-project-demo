# Changelog

This file records significant changes to the data or analysis decisions. For full context on any entry, follow the linked Issue.

Format: `YYYY-MM-DD — Description — [Issue #N]`

---

## October 2024

**2024-10-09** — Identified 47 records with missing or malformed FIPS codes in the raw export. Cross-referencing against CDC FIPS lookup table. — [Issue #7](../../issues/7)

**2024-10-07** — Data dictionary drafted and posted. Variable definitions for `race_ethnicity` still pending resolution of recoding question. — [Issue #14](../../issues/14)

**2024-10-04** — Raw data export received from state system. Saved to `data/raw/` without modification. Import script (`01_import.R`) run and verified.

---

## September 2024

**2024-09-28** — Q2 report closed out. Repository cleaned up; Q2 scripts archived to `archive/q2_2024/`. Q3 milestone opened.

**2024-09-12** — Suppression policy reviewed and re-approved by Dr. Reyes ahead of Q3 cycle. No changes from Q2 policy. — [`docs/suppression-policy.md`](suppression-policy.md)

---

## August 2024

**2024-08-15** — Resolved: pertussis cases will use report date as primary date field for Q2, pending broader discussion for Q3. — [Issue #3, closed](../../issues/3)

**2024-08-02** — Identified duplicate case IDs in Q2 raw export (n=6). Confirmed with state system contact as data entry errors. Duplicates removed before cleaning. — [Issue #4, closed](../../issues/4)

---

## July 2024

**2024-07-22** — `renv` lockfile initialized. All team members should run `renv::restore()` before running any scripts. — [Issue #2, closed](../../issues/2)

**2024-07-10** — Repository created. Folder structure, README, and docs stubs committed.
