# Cell suppression policy

Last updated: 2024-09-12 | Approved by: Dr. Reyes

This document describes the suppression rules applied before any county-level counts are published or shared outside the workgroup. These rules exist to protect patient privacy and comply with our data use agreement.

---

## The basic rule

Any cell containing **fewer than 5 cases** is suppressed in published output.

The `03_suppress.R` script applies this rule and sets `suppressed = TRUE` on affected records. Suppressed cells are replaced with `<5` in HTML and PDF report output.

---

## Secondary suppression

When suppression of a small cell would allow someone to calculate the suppressed value by subtraction, we also suppress the next-smallest cell in that row or column. This is called **complementary suppression**.

Example: if a county has 3 Salmonella cases (suppressed) and 47 total enteric cases, publishing both numbers would reveal the suppressed count. In that situation, we suppress the next-smallest disease category for that county as well.

The logic for this is in `03_suppress.R` starting at line 88. See [Issue #11](../../issues/11) for the discussion around edge cases.

---

## What is never suppressed

- Statewide totals
- Disease groups (as opposed to individual diseases) at the county level, unless the group itself is under 5
- Zero counts — a zero is published as 0, not suppressed

---

## Exceptions process

If a program area needs unsuppressed data for internal use (e.g., for an outbreak investigation), they must:

1. Be named on the data use agreement
2. Submit a request to the data lead
3. Receive the unsuppressed file via encrypted transfer, not email

Unsuppressed data is never committed to this repository.

---

## Reference

Our suppression policy follows guidance from:

- CDC's *Principles of Epidemiology in Public Health Practice*, 3rd ed., Section 6
- State health department data release policy (v2.3, 2023)
- Our executed data use agreement (see [`docs/data-use-agreement.md`](data-use-agreement.md))
