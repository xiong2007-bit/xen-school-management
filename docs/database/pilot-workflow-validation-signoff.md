# Stage 3 — Pilot Workflow Validation & Sign-off Plan

**Project:** XEN SCHOOL MANAGEMENT v3.0  
**Date:** 21 November 2026  
**Status:** Draft; validation not performed. Documentation only.

## Purpose

Define how product owner and Zimbabwe pilot-school stakeholders review Stage 3 workflow and acceptance criteria, collect evidence, and decide whether the proposed pilot scope is fit for the next design/implementation gate. The linked [Detailed Pilot Workflows, User Stories & Acceptance Criteria](pilot-workflows-user-stories-acceptance-criteria.md) is the source of workflow/story/AC IDs.

## Stakeholder review checklist

| Review area | Reviewer(s) | Review prompts | Status |
|---|---|---|---|
| Tenant onboarding and identity | Product owner, platform/security | School types, owner invitation, tenant provisioning, role delegation, suspension and support grants | Pending |
| Academic setup | School admin/principal | Calendars, terms, forms/grades, streams, subjects, timetable, effective dates | Pending |
| Student and guardian records | Registrar/admin, privacy/legal reviewer | Required learner data, duplicate handling, guardian verification, restrictions, emergency contacts | Pending |
| Enrolment lifecycle | Registrar/principal | Primary enrolment, concurrent enrolment, promotion, transfer, withdrawal, re-entry | Pending |
| Import | School admin/data owner | Source files, mapping, duplicates, errors, reconciliation tolerance, approval | Pending |
| Attendance | Teacher/principal | Daily vs period, statuses, lateness, absence reasons, correction authority, guardian release | Pending |
| Assessment/results | Teachers, academic lead | Grading schemes, weighting, aggregation, moderation, report cards, publication/revision | Pending |
| Admissions | Admissions lead | Form fields, campaign, documents, review, offer, fees/waiver, conversion | Pending |
| School finance | Bursar/finance reviewer | Fee schedules, invoice, offline payment, verification, allocation, receipt, statements, refunds | Pending |
| Guardian portal | Guardian representative, admin | Linking/verification, per-child permission, restrictions, information visible, revocation | Pending |
| Communication | Admin, guardian, privacy reviewer | Channels, preferences/consent, bulk audience, moderation, read receipts | Pending |
| Public CMS | CMS editor/publisher, privacy reviewer | Template, public fields, review/publish, consent, domain, takedown/cache invalidation | Pending |
| Reporting/export | Principal, bursar, privacy reviewer | Reports, filters, field minimization, export authorization and audit | Pending |
| Governance/offboarding | Owner, privacy/legal, platform operator | Export, retention, legal hold, closure, deletion/anonymization | Pending |
| Support/recovery/release | Technical owner, QA/security, pilot owner | Scoped support, audit, restore, RPO/RTO, issue severity, go/no-go | Pending |

## Proposed validation protocol

1. Share workflow draft and proposed first-release scope before the session; record version and reviewer.
2. Use a test environment and synthetic dataset. Do not circulate real student records, health data, custody documents or bank details in workshop notes.
3. For each workflow, ask reviewer to walk through actor, starting conditions, steps, exception cases, desired outcome and data visibility.
4. Mark each story/criterion **Accepted**, **Needs change**, **Rejected**, or **Deferred**. Record comments and a change-request ID for material change.
5. Resolve contradictory school practices by documenting configurable rules and identifying pilot-specific choices; do not hard-code one school's preference as global.
6. Prioritize safety, tenant separation, finance integrity, privacy/legal and data retention. These cannot be waived by convenience.
7. Update MRTM, pilot-scope and workflow documents after approval; keep a change history.
8. Once implementation is authorized and built, convert accepted criteria to test cases and link evidence. Do not claim criteria passed from document review alone.

## Validation outcome log

No sessions have been conducted. Use this table to record results:

| Session | Date | School type / participants | Workflows reviewed | Decision | Change requests / evidence | Approver |
|---|---|---|---|---|---|
| A Setup & access | TBD | TBD | WF-01–03 | Pending | TBD |
| B Learner lifecycle & privacy | TBD | TBD | WF-04–06 | Pending | TBD |
| C Teaching operations | TBD | TBD | WF-07–08 | Pending | TBD |
| D Admissions & finance | TBD | TBD | WF-09–11 | Pending | TBD |
| E Guardian, communications, CMS | TBD | TBD | WF-12–14 | Pending | TBD |
| F Reporting & governance | TBD | TBD | WF-15–17 | Pending | TBD |
| G Go/no-go | TBD | TBD | WF-18 | Pending | TBD |

## Proposed sign-off criteria

- [ ] Product owner approves proposed first-release scope and confirms any exclusions.
- [ ] Pilot stakeholder review covers at least admin, teacher, bursar, guardian and admissions; technical/security and privacy/legal review are represented.
- [ ] School-type coverage (primary, secondary, combined) is recorded; unreviewed types are clearly excluded from initial pilot.
- [ ] P0 workflow and acceptance criteria are approved, with measurable outcomes and test data.
- [ ] Sensitive access and public/private boundaries reviewed: tenant isolation; guardian verification/restriction; restricted health/safeguarding/legal; school finance vs SaaS billing; anonymous CMS projection.
- [ ] Finance pilot scope, currency, manual/provider payment process and reconciliation are agreed.
- [ ] Data import and reconciliation plan, retention/legal hold, privacy and consent controls are reviewed.
- [ ] Technical provider, hosting region, security, backup, recovery and support readiness decisions have owners and evidence.
- [ ] Changes are reconciled into MRTM and pilot scope; version is identified.
- [ ] Go/no-go authority and acceptance record are defined.

## Sign-off record (blank)

| Field | Value |
|---|---|
| Scope/document version | TBD |
| Pilot school(s) and type(s) | TBD |
| Product owner | TBD |
| School owner/admin reviewer | TBD |
| Teacher representative | TBD |
| Bursar/finance reviewer | TBD |
| Admissions representative | TBD |
| Guardian representative | TBD |
| Security/privacy/legal reviewer | TBD |
| Technical/recovery owner | TBD |
| Decision | Pending — draft only |
| Conditions / deferred items | TBD |
| Approval date | TBD |
| Evidence location | TBD |

## Open items and next gate

Stage 3 documentation is complete as a draft. Stakeholder validation, scope freeze and acceptance sign-off remain pending. Stage 4 should consolidate the validated requirements into a prioritized pilot backlog, test-case inventory, data-import plan and implementation gate checklist only after review; implementation still requires separate explicit authorization.

**Not created:** code, SQL, executable migrations/schema, seed data, CI, infrastructure, deployment, or imported real school data.
