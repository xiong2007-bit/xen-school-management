# Stage 4 — Pilot Data Import & Migration Plan

**Version:** XEN SCHOOL MANAGEMENT v3.0 / Stage 4 draft  
**Date:** 21 November 2026  
**Status:** Proposed plan; actual source files, mapping and execution are not authorized. Documentation only.

## 1. Goals and principles

Import only data needed for the agreed pilot workflows. Preserve source records, provenance and reconciliation. Minimize child/person data; never use production data for development/testing without explicit authorization and approved safeguards. No import writes occur before a school data owner signs the mapping, validation, dry-run and cutover plan.

## 2. Proposed import batches

| Batch | Data | Priority | Dependency / notes |
|---|---|---|---|
| I-00 | School/campus settings, academic year/calendar, grades/forms/classes/subjects | Required | Confirm IDs, codes, dates and policy |
| I-01 | Staff, user invitations and assignments | Required | Identity matching; do not import passwords |
| I-02 | Student demographics and identifiers | Required | Minimum required fields; duplicate review |
| I-03 | Guardian/contact records and relationships | Required | Verify relationship and permissions separately; import must not auto-grant portal access |
| I-04 | Enrolments, history and class/grade assignments | Required | Reconcile current enrolment and historical scope |
| I-05 | Attendance history | Optional, bounded | Pilot period only if source quality and policy justify |
| I-06 | Assessment/result history | Optional, bounded | Confirm grading definitions and publication policy |
| I-07 | Fee schedules, opening balances and transaction history | Scope-dependent | Finance reconciliation and source-of-truth approval |
| I-08 | Admissions in-progress applications | Optional | Data minimization and conversion status |
| I-09 | Notices, files, CMS content | Not in initial bulk migration by default | Rights, content safety, privacy and attachment scanning |

## 3. Source discovery and data inventory

For each source, record: owner; source system/file/version; export date; format; encoding; row counts; columns; date/time/currency conventions; identifier rules; duplicates; null/invalid values; data sensitivity; lawful purpose/authority; retention; attachment inventory; source-of-truth; and scope to import or exclude.

Supported source formats should be selected after inventory (e.g. CSV/XLSX); no assumption that every source will be accepted. Original files must be stored in an approved restricted location, encrypted, access logged, and deleted according to the approved retention schedule.

## 4. Mapping and transformation controls

- Create a versioned mapping specification for every source column: target field, transformation, requiredness, allowed values, default (if approved), sensitivity, validation, and owner.
- Map identifiers carefully; retain source-system identifier in a restricted import reference field where approved. Avoid matching people solely by name.
- Normalize date formats, phone numbers, text encoding, whitespace and controlled codes; record transformation rules.
- Do not invent missing data or silently replace unknown values. Quarantine invalid or ambiguous rows for owner resolution.
- Deduplicate using agreed deterministic keys plus review; never automatically merge uncertain student/guardian records.
- Verify guardian relationships and portal access through the separate verification workflow after import.
- Import money as exact decimal/integer minor units according to currency policy; preserve original amount, currency, reference and conversion evidence where applicable.
- Never import passwords, session tokens, raw payment credentials or unnecessary sensitive records.
- Preserve original values and lineage sufficient for reconciliation, subject to security/retention.

## 5. Staging, validation and dry-run

1. Receive and log the source package; virus scan attachments; checksum files; confirm authorization.
2. Restrict access to designated data-migration personnel; use isolated staging, never production by default.
3. Validate file structure, schema, encoding, required fields, permitted values, duplicate keys, relationship integrity, dates and scope.
4. Produce dry-run report: accepted/rejected rows, warnings, duplicates, unresolved records, field transformations and expected target counts.
5. Review exceptions with school data owner; resolve or formally exclude; record approvals.
6. Generate a dry-run reconciliation for counts by school/class/status and, where relevant, finance totals by currency/accounting period.
7. Repeat dry-run on corrected source and record version/checksum.
8. Obtain signoff for import batch and cutover window before any actual import.

## 6. Execution and recovery

- Prefer batch IDs and idempotent import operations; prohibit untracked direct database edits.
- Establish snapshot/backup and rollback/compensation method before execution; test recovery on non-production.
- Import in dependency order: school configuration → staff/users (invitation only) → students → guardian relationships → enrolments → optional history/finance.
- Pause on unexpected counts, constraint failures, duplicate rates, cross-tenant mismatch, or reconciliation differences.
- After each batch, reconcile source/accepted/rejected/target counts and relation counts; finance balances/totals must reconcile by currency.
- Record execution operator, timestamps, source checksum, mapping version, batch ID, outcomes, exceptions and approval.
- For failed batches, stop; do not rerun blindly. Determine partial writes, use documented recovery, and verify idempotency before retry.

## 7. Cutover and post-import verification

- Agree freeze window or source delta method, new-record handling and operational owner.
- Run final approved import; reconcile; validate sample records with authorized school representatives.
- Confirm no guardian portal access is enabled without identity/link verification and permission review.
- Confirm imported results are not exposed as published unless explicitly approved.
- Confirm balances and receipts are accurate and that imported opening balances are distinguished from transactional history.
- Confirm files/exports are protected and audit events recorded.
- School data owner signs reconciliation and accepts exceptions; rollback/stop decision remains available.
- Provide staff training and support contact; capture defects and corrections through controlled workflow.

## 8. Reconciliation and signoff template

| Dataset | Source count | Eligible | Rejected/quarantined | Imported | Difference | Owner explanation / resolution | Signoff |
|---|---:|---:|---:|---:|---:|---|---|
| Students | | | | | | | |
| Guardians/relationships | | | | | | | |
| Enrolments | | | | | | | |
| Staff | | | | | | | |
| Attendance (if included) | | | | | | | |
| Assessments (if included) | | | | | | | |
| Finance (per currency) | | | | | | | |

**Stage 4 status:** plan drafted. No school files have been received, analyzed, transformed or imported.
