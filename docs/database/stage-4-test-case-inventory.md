# Stage 4 — Test-Case Inventory & Quality Strategy

**Version:** XEN SCHOOL MANAGEMENT v3.0 / Stage 4 draft  
**Date:** 21 November 2026  
**Status:** Proposed inventory only; test cases have not been executed. Documentation only.

## 1. Test strategy and evidence

Testing must cover behavior, permissions, tenant boundaries, lifecycle, correctness, failure recovery and usability. Prefer synthetic test data; use approved masked data only after governance approval. Record test ID, build/version, environment, preconditions, steps, expected outcome, actual outcome, evidence link, tester, date, defect ID and retest status.

Risk priority: **Critical** (cross-tenant exposure, child safety, financial corruption, unauthorized publication, unrecoverable loss) blocks pilot; **High** (core workflow failure or unauthorized access) blocks pilot unless formally accepted with a safe workaround; Medium/Low may be tracked under approved exit criteria.

## 2. Inventory

| Test ID | Area / scenario | Expected outcome | Priority |
|---|---|---|---|
| T-001 | Tenant onboarding, tenant ID uniqueness and configuration | Tenant created once; settings and ownership correct | Critical |
| T-002 | User with no membership requests tenant resources | Denied; no data leakage | Critical |
| T-003 | User belonging to tenant A requests tenant B data | Denied at all layers; no side-channel disclosure | Critical |
| T-004 | Role scope: teacher outside assigned class/subject/campus | Denied | Critical |
| T-005 | Privilege escalation via API payload, URL, forged role or stale session | Denied; audit/security event | Critical |
| T-006 | Invitation expired, reused, revoked or accepted by wrong identity | Correct lifecycle; no unauthorized membership | High |
| T-007 | Staff role change/removal and session/token invalidation | Access revoked according to policy; audit | Critical |
| T-008 | Student duplicate detection and merge prevention | Duplicate flagged; no destructive auto-merge | High |
| T-009 | Guardian link verification, multiple learners and link expiry | Only verified permitted learner data shown | Critical |
| T-010 | Guardian restrictions, custody/legal order, permissions conflict | Restriction overrides ordinary access; audited | Critical |
| T-011 | Emergency contact is not automatically granted portal access | No portal access unless separately verified/authorized | Critical |
| T-012 | Enrolment transitions, transfer, withdrawal, re-entry, promotion | Valid states/history; invalid transitions blocked | High |
| T-013 | Academic year/calendar boundaries, leap dates, timezone and term overlap | Valid configuration; conflicts detected | High |
| T-014 | Attendance submit, duplicate submit, late entry and correction reason | Idempotent; correction trace retained | High |
| T-015 | Attendance totals and summary across filters | Accurate counts; scope enforced | High |
| T-016 | Assessment grading boundaries, rounding, missing/exempt values | Policy-consistent results; no silent coercion | Critical |
| T-017 | Marks edits after moderation, unauthorized moderator and version history | Controlled reopen/reapproval; history retained | Critical |
| T-018 | Report publication/unpublication and guardian visibility | Only approved/published version exposed | Critical |
| T-019 | Admissions application duplicate, decision and conversion retry | Conversion once; duplicate/retry safe | High |
| T-020 | Import dry-run, mapping, invalid rows and duplicate detection | Errors reported; source preserved; no writes during dry-run | Critical |
| T-021 | Import partial failure, retry, rollback/compensation and reconciliation | Safe recoverability; counts and totals reconcile | Critical |
| T-022 | Import tenant/school mismatch and restricted fields | Reject/quarantine; no cross-tenant or unauthorized import | Critical |
| T-023 | Invoice generation, fee schedule snapshot and amount precision | Correct values; no floating-point rounding | Critical |
| T-024 | Payment recording, duplicate reference, idempotency and concurrent allocation | No duplicate payment or over-allocation | Critical |
| T-025 | Unverified payment, reversed payment, refund and adjustment | Correct status; no silent deletion; approvals/audit | Critical |
| T-026 | Receipt, statement, arrears and balance calculations | Reconciles to ledger/payment allocations | Critical |
| T-027 | School finance and XEN subscription billing separation | No cross-domain access or confusion | Critical |
| T-028 | Notice/message recipient permissions, legal restrictions and moderation | Restricted recipient blocked; policy enforced | Critical |
| T-029 | Read receipt, delivery failure, duplicate notification and preference opt-out | Accurate status; retry safe; preference honored | High |
| T-030 | Public CMS projection: private student/guardian data and attachments | Only allowlisted public content visible | Critical |
| T-031 | Draft/review/publish/unpublish, scheduled publish and cache purge | Publication state and visibility consistent | High |
| T-032 | Report/export authorization, filtering, field allowlist and audit | Minimum data only; no unauthorized export | Critical |
| T-033 | CSV/XLSX injection and formula payloads | Export safely neutralizes executable cells | High |
| T-034 | File upload MIME mismatch, malware, oversize, unsafe names and access | Rejected/quarantined; private by default | Critical |
| T-035 | Support access grant expiry, purpose, approval and audit | Time-bound scoped access; auto-expiry/revoke | Critical |
| T-036 | Audit log tamper attempts, sensitive actions and access review | Tamper resistance; audit completeness | Critical |
| T-037 | Backup restore, point-in-time recovery and tenant export | Recoverable within approved RPO/RTO; integrity checked | Critical |
| T-038 | Tenant closure, retention, legal hold and deletion request | Policy honored; hold blocks deletion; evidence retained | Critical |
| T-039 | API rate limits, abuse, brute-force and session security | Controls effective; no account enumeration | High |
| T-040 | Offline/poor network retry and double-submit | Safe retry, idempotency and clear user state | High |
| T-041 | Mobile layout, keyboard access, screen reader labels and contrast | Usable across supported devices and assistive technology | High |
| T-042 | Performance at agreed pilot volume, peak attendance/report traffic | Meets agreed baselines; no tenant bleed | High |
| T-043 | Monitoring/alerts, incident triage and error reporting | Alert actionable; secrets/PII not exposed | High |
| T-044 | Data migration reconciliation of records and finance totals | Source-to-target counts and totals reconciled and signed | Critical |
| T-045 | Pilot end-to-end day: attendance, assessment, fees, guardian view | Representative workflows pass with school signoff | Critical |

## 3. Minimum suites and execution gates

1. **Unit:** business rules, grading, money precision, lifecycle validation, mapping.
2. **Integration:** database constraints, auth, storage, notification, import and finance.
3. **Security:** tenant isolation, permission matrix, guardian restrictions, support access, public projection, export.
4. **Regression:** every accepted workflow and previously fixed defects.
5. **E2E/UAT:** real-role scenarios in staging with synthetic/approved data.
6. **Operational:** backup/restore, incident, monitoring, offboarding, export and deletion.
7. **Non-functional:** accessibility, supported devices, low-bandwidth and performance.

Before pilot: all Critical cases pass; High cases pass or have explicitly approved safe workaround and owner; no critical/high unresolved security or integrity defects; evidence reviewed; data reconciliation signed; operational and school acceptance gates passed. Exact coverage thresholds must be agreed by the owner and engineering lead.

## 4. Execution record template

| Test ID | Version/environment | Date/tester | Result (Pass/Fail/Blocked/Not run) | Evidence | Defect / retest | Signoff |
|---|---|---|---|---|---|---|
| | | | | | | |

**Stage 4 status:** inventory drafted; no tests have been executed, and this document is not evidence of software quality.
