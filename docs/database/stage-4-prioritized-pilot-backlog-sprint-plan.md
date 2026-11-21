# Stage 4 — Prioritized Pilot Backlog & Sprint Planning Proposal

**Version:** XEN SCHOOL MANAGEMENT v3.0 / Stage 4 draft  
**Date:** 21 November 2026  
**Status:** Planning proposal for product-owner and pilot-school review. Documentation only; no implementation authorized.  
**Basis:** Master Plan v3.0, approved design decisions, proposed first-release scope, Stage 3 workflows/stories/acceptance criteria, schema blueprint and readiness checklist.

## 1. Purpose and planning assumptions

Convert proposed pilot scope into an ordered, dependency-aware backlog and a time-boxed sprint proposal. This is not a commitment to dates, capacity, or release. Estimate only after team, availability, school requirements, technical decisions and acceptance criteria are confirmed. A sprint is proposed as two weeks; solo or part-time work may require longer.

**Priority definitions**
- **P0 / Must:** required for safe pilot operations; blocks pilot if incomplete.
- **P1 / Should:** included in pilot if capacity and validation permit; a documented manual fallback may be accepted.
- **P2 / Could:** defer without compromising the pilot's essential workflows.
- **P3 / Later:** post-pilot or product expansion.

**Sizing:** XS (≤1 day), S (2–3 days), M (4–6 days), L (7–10 days), XL (more than 10 days); indicative only, not engineering estimates.

## 2. Backlog and dependencies

| ID | Epic / deliverable | Priority | Size | Dependencies | Exit evidence |
|---|---|---:|---|---|---|
| B-001 | Product scope freeze, school policy discovery and decision log | P0 | M | Owner + pilot stakeholders | Signed scope, policy matrix, unresolved items assigned |
| B-002 | Environment/provider, region, cost and legal/privacy decisions | P0 | M | B-001 | Decision records; environment/security plan |
| B-003 | Tenant, identity, membership, roles, permission matrix | P0 | L | B-001, B-002 | Role/scope tests and reviewed threat model |
| B-004 | Tenant isolation, database access boundaries, audit foundations | P0 | XL | B-003 | Cross-tenant denial tests; audit coverage |
| B-005 | School/campus, calendars, terms, grades/forms/classes/subjects | P0 | L | B-003/004 | Configuration acceptance and calendar edge cases |
| B-006 | Staff invitations, assignments and least-privilege access | P0 | M | B-003/004/005 | Invitation lifecycle and scope checks |
| B-007 | Student, guardian, contacts, verified links, legal restrictions | P0 | XL | B-003/004 | Guardian access matrix; restriction precedence tests |
| B-008 | Enrolment lifecycle and history (promotion/transfer/withdrawal/re-entry) | P0 | L | B-005/007 | State-transition and history tests |
| B-009 | Import tooling, staging, mapping, validation, reconciliation and rollback | P1 | XL | B-007/008; import plan | Dry-run evidence; reconciliation signoff |
| B-010 | Attendance registers, correction reason/history and reports | P0 | L | B-005/006/008 | Register, correction and summary acceptance |
| B-011 | Assessment setup, marks, moderation, publication, report cards | P0 | XL | B-005/006/008 | Grading rule tests and publication approvals |
| B-012 | Admissions workflow and idempotent learner conversion | P1 | L | B-007/008; file security | Duplicate/retry and decision tests |
| B-013 | Fee items/schedules, invoices, payments, allocation, receipts, balances | P0* | XL | B-002/003/004/007/008; currency decision | Finance controls, duplicate payment and reconciliation |
| B-014 | Waivers, adjustments, refunds and approval segregation | P1 | L | B-013 | Authorization, reversal and audit tests |
| B-015 | Guardian portal onboarding, attendance/results/notice visibility | P0 | L | B-007/008/010/011/permission policy | Per-learner permission and restriction tests |
| B-016 | Notices and messaging, preferences, moderation, delivery/read states | P1 | L | B-003/007/015 | Permission, abuse and failure-path tests |
| B-017 | Public CMS starter site, safe projection, draft/review/publish | P1 | M | B-002/003; content policy | Data-leak tests and publish/unpublish checks |
| B-018 | Reports and safe exports (enrolment, attendance, results, finance) | P1 | L | Relevant epics | Filter, permission, audit and export tests |
| B-019 | Observability, incident workflow, support access, backup/recovery | P0 | L | B-002/003/004 | Restore drill, support grant audit, runbooks |
| B-020 | Performance, accessibility, mobile/low-bandwidth, usability | P0 | L | Core features | Target-device checks; performance baseline |
| B-021 | Pilot UAT, defect triage, training, go/no-go review | P0 | L | Core epics + validation | Signed acceptance and release decision |
| B-022 | Optional modules (library, transport, boarding, meals, clubs) | P3 | XL | Pilot learnings | Separate discovery |
| B-023 | Full accounting, bank reconciliation, automated payment integrations | P2 | XL | Finance pilot + provider/legal review | Separate scope and control review |
| B-024 | Advanced website builder, domains, multilingual, student portal | P2 | XL | CMS/portal learning | Separate roadmap approval |

* Essential finance remains a proposed pilot inclusion; explicitly validate whether pilot school(s) can accept manual-only payment reconciliation or whether finance must be reduced/deferred. Do not silently omit finance from scope.

## 3. Proposed sprint sequence (two-week sprint placeholders)

| Sprint | Focus / outcome | Backlog IDs | Review / gate |
|---|---|---|---|
| Sprint 0 — Discovery & design | Confirm pilot scope, policy matrix, technical/provider/legal choices, data inventory and threat model | B-001, B-002 | Scope and architecture signoff before build |
| Sprint 1 — Secure foundation | Tenant, auth, membership, scoped permissions, audit and cross-tenant safeguards | B-003, B-004 | Security/tenancy gate |
| Sprint 2 — School setup & people | Academic setup, staff access, student/guardian records and restriction model | B-005, B-006, B-007 | Role, identity and child-data review |
| Sprint 3 — Lifecycle & attendance | Enrolment lifecycle and attendance/corrections | B-008, B-010 | Workflow acceptance |
| Sprint 4 — Assessment & guardian portal | Assessment/marks/moderation/publication and guardian visibility | B-011, B-015 | Results privacy and grading validation |
| Sprint 5 — Finance & admissions | Essential finance, admissions conversion, adjustments/refunds | B-012, B-013, B-014 | Finance reconciliation and separation-of-duties review |
| Sprint 6 — Imports, comms, CMS, reports | Import pilot, notices/messaging, starter CMS, reports/exports | B-009, B-016, B-017, B-018 | Import signoff; public-data/privacy review |
| Sprint 7 — Hardening & pilot | Recovery/monitoring, accessibility, performance, UAT, training and go/no-go | B-019, B-020, B-021 | Pilot release gate |

**Schedule caveat:** sequence may change based on capacity, blockers and school calendar. Split or extend sprints where estimates exceed capacity; do not compress security, privacy or reconciliation acceptance.

## 4. Definition of Ready (story entry)

A backlog item may enter a sprint only when: (1) owner and priority confirmed; (2) story and acceptance criteria reviewed; (3) dependencies identified and available; (4) data classification and permissions understood; (5) design/policy decisions resolved or explicit bounded assumption approved; (6) test approach and expected evidence defined; (7) size agreed by delivery team; and (8) no hidden requirement for sensitive production data.

## 5. Definition of Done (proposed)

- Acceptance criteria met and peer-reviewed.
- Automated tests appropriate to risk (unit, integration, permission, tenant isolation, regression).
- Sensitive data handling and audit reviewed.
- Error, retry, concurrency and rollback/reversal behavior documented/tested.
- Accessibility and mobile/low-bandwidth checks performed for user-facing work.
- Documentation, operator/support notes and known limitations updated.
- Staging evidence reviewed; no unresolved critical/high security or data-integrity defects.
- Product owner accepts item or records rejection/rework.

## 6. Capacity and risk notes

- Establish a capacity baseline only after team composition and availability are known; reserve 20–30% capacity for discovery, defects, review and operational work.
- Finance, imports, guardian restrictions, tenant isolation, assessment publishing and data export are high-risk; estimate with technical spikes and explicit control reviews.
- Avoid parallel work that depends on unresolved identity, tenancy or academic structure.
- Any scope change must update requirements traceability, workflow acceptance, backlog, risk register and scope approval.

## 7. Decisions needed before planning is approved

1. Pilot school(s), stakeholder owners, target academic period and actual capacity.
2. Final pilot scope, including essential finance and admissions.
3. Provider/region, cost limits, legal/privacy and security review.
4. Role and permission matrix, guardian policy and safeguarding boundaries.
5. Grading/attendance/enrolment policies and finance reconciliation controls.
6. Import data source(s), formats, quality, mappings and accountable data owner.
7. Definition of critical/high defect and pilot exit criteria.

**Stage 4 status:** Proposed backlog and sprint sequence drafted. No estimates are committed; stakeholder approval and readiness evidence remain outstanding.
