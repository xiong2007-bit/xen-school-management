# Schema Blueprint Review Checklist — XEN SCHOOL MANAGEMENT v3.0

**Date:** 21 November 2026  
**Status:** Proposed review aid; documentation only.  
**Authority:** Complete Combined Master Plan v3.0; database data dictionaries; relationship specification; constraints/indexes/RLS; all 13 accepted design decisions; implementation roadmap. The main [Schema Blueprint](schema-blueprint.md), [Table-level reconciliation and security review](schema-blueprint-table-level-review.md), and [Migration Manifest](migration-manifest.md) are the detailed design sources. This file is a release-readiness review checklist, not a replacement or implementation specification.

## Review baseline

- UUIDv4; tenant rows have `school_id` and `UNIQUE(school_id,id)`; tenant-to-tenant references are composite FKs.
- Supabase-managed PostgreSQL; Supabase Auth identities; server-resolved tenant membership; API-first Cloudflare Workers; RLS mandatory.
- UTC `timestamptz` for instants; `date` for calendar facts; explicit IANA timezone context.
- Currency precision registry; integer minor units plus currency code; explicit conversion evidence; no floating-point financial values.
- Schema/domain separation, least-privilege grants, fail-closed policies, safe helpers; avoid SECURITY DEFINER absent justification.
- Private file objects, opaque keys, quarantine/scanning, short-lived authorized access. Secrets remain in secret management.
- Public website projection only exposes approved published content; private CMS and submissions stay inaccessible to anonymous clients.
- School finance and XEN SaaS billing remain separate domains. Restricted health/safeguarding/custody/legal/bursary/bank details require special permissions and audit.

## Table-by-table implementation review required

For **every entity table** in the main blueprint, the schema reviewer must sign off these columns of the review worksheet before SQL is authorized. The blueprint lists proposed PK, tenant key, key relationships, constraints/indexes, class/lifecycle, and RLS intent by entity. Exact FK names/columns and null/delete actions are implementation-stage decisions to be reviewed, not presumed.

| Item | Required review result |
|---|---|
| Primary/unique keys | PK type; tenant composite unique; natural key uniqueness scoped correctly; idempotency uniqueness |
| Foreign keys | Explicit target and columns; tenant composite; global/scope exception rationale; delete/update behavior |
| Constraints | NOT NULL, CHECK, uniqueness, date/range, aggregate invariants and transactional enforcement |
| Indexes | FK coverage; tenant-leading filters; uniqueness; partial-index predicate; write-cost/query-plan rationale |
| Classification | P0 public-approved/P1 internal/P2 personal/P3 restricted/P4 secret; sensitive fields identified |
| Lifecycle | State list, valid transitions, transition authority, history, terminal/reopen behavior |
| Authorization | SELECT/INSERT/UPDATE/DELETE policies; schema grants; tenant, campus/class/subject, guardian or role scope; API exposure |
| Migration | Dependency, cycle strategy, backfill, data validation, deploy impact, rollback/forward fix |
| Tests | Positive and negative tenant/RLS tests, integrity, concurrency, privacy, workflow, performance |

## Required review by domain

| Domain | Entity families to reconcile | Security/integrity review focus | Readiness |
|---|---|---|---|
| Platform/tenancy/identity | schools, campuses, profiles, memberships, role grants, permissions, audit | Auth mapping, tenant resolver, role delegation, revocation, support-access approval, audit integrity | Pending |
| People/guardian/enrolment/HR | students, guardians, links, restrictions, emergency contacts, enrolments, staff and employment | Verified relationship, custody/legal override, multiple-enrolment rule, primary enrolment, restricted HR fields | Pending |
| Academic/calendar/timetable | programmes, calendars, years/terms/events, periods, rooms, timetables, grades/classes/streams/subjects/assignments | Overlap policies, timezone, effective dates, class/teacher/room clashes, version snapshots | Pending |
| Attendance | sessions, records, corrections, notifications | Date eligibility, uniqueness, corrections, class scope, guardian notification minimization | Pending |
| Assessment/results | schemes/scales/versions, assessments/components, marks/moderation/results/report cards | Score and weight constraints, moderation separation, snapshot/recalculation/version rules | Pending |
| Admissions | campaigns/apps/applicants/guardians/documents/reviews/interviews/offers/history/fee snapshots/payments/refunds/conversion | Public input protection, fee version snapshot, idempotent conversion, payment/refund controls | Pending |
| School finance | fees/invoices/items/payments/allocations/receipts/adjustments/discounts/bursaries/refunds/bank/accounting | Exact arithmetic, currencies, posting immutability, verification, segregation of duties, reconciliation | Pending |
| Website/CMS | websites/themes/pages/versions/blocks/navigation/media/publications/domains/translations/forms/submissions | Public projection allow-list, approved versions, domain verification, cache purge, consent, no private data | Pending |
| Portals/communications | preferences, messages, participants, read receipts, moderation, notifications, deliveries | Guardian permissions, participants-only access, restricted content, delivery dedupe, moderation | Pending |
| Optional services | library, transport, boarding, meals, clubs, trips, activities | Dated eligibility, capacity, consent, route/loan uniqueness, entitlement and finance integration | Pending |
| Restricted data | health, safeguarding, legal/custody and restricted incident/case records | Separate schema, need-to-know, audit/reason, minimized metadata, no broad search/export/portal | Pending |
| Documents/governance/ops | files, access logs, retention, export/delete, support, jobs, webhooks, backups | Scan gate, opaque keys, holds, access logs, requester/internal-note separation, job idempotency | Pending |
| XEN SaaS billing | plans, prices, subscriptions, invoices, payment references, entitlements, usage | Platform tenant isolation, snapshots, dedupe, distinct from school finance | Pending |

## Security matrix review (policy intent)

| Actor | Default scope | Deny-by-default sensitive exclusions |
|---|---|---|
| Platform administrator | Platform configuration and tenant lifecycle | No routine unrestricted school P2/P3 access; privileged access must be time/purpose limited, approved and audited |
| Support/operator | Assigned support ticket and safe diagnostics | No school finance, HR, health, safeguarding, legal or raw student data without scoped grant |
| School owner/admin | Authorized school configuration and staff/membership management | Restricted records, legal limits and immutable audit/finance cannot be bypassed |
| Principal | School academics, attendance and approved operational reporting | Health/legal/finance requires distinct grants |
| Bursar/finance | School finance records and approved operations | No XEN platform billing administration; sensitive bursary/bank records and approvals segregated |
| Admissions | Applications, reviews, offers and conversion | No general access to enrolled student records, finance ledger, health or HR |
| Teacher | Assigned classes/subjects, attendance and marks | No unrelated cohorts, HR, finance, custody/legal or restricted health/safeguarding |
| CMS editor/publisher | Private authoring and reviewed publishing | No private school records; publication must pass approved controls |
| Guardian | Verified child links and per-link allowed fields/features | No other learners; legal restrictions override; emergency-contact authority does not equal portal access |
| Student | Own record and published/allowed portal data | No peers, staff notes, restricted records, private finance or unpublished results |
| Service module staff | Relevant module, assigned school scope | No unrelated personal/sensitive records |
| Privacy/security/auditor | Approved governance, audit or security scope | Purpose-bound; no blanket operational privileges |

## Explicit segregation tests required

1. Anonymous request cannot read private CMS base records, drafts, submissions, private media metadata, student/guardian/attendance/marks/finance data. Only approved published projection and approved public assets return.
2. A publication can be unpublished or withdrawn; cache/public delivery must be invalidated. Domain not verified means no tenant public route.
3. School finance tables and reports cannot read/write XEN subscription billing; XEN billing staff cannot see school tuition/payment records by default.
4. Health/safeguarding/legal/custody/bursary/bank details do not appear in standard student search, notifications, portal, public CMS, exports or logs; authorized access is reasoned and audited.
5. Tenant A cannot query, mutate, infer or join Tenant B rows, even with guessed UUIDs, nested relationships, views, RPC, or revoked membership.
6. Guardian portal requires active verified link, allowed per-link permission, valid time range, and no overriding restriction. Revocation is tested.
7. RLS tests use normal application roles; owner/service-role bypass does not count as proof.

## Dependencies and manifest

Use the ordered logical groups in [migration-manifest.md](migration-manifest.md) (D01–D19). They are not actual migration filenames or applied versions. Dependencies are: reference/conventions → tenant root → identity → authorization/audit → file metadata → people → academics → attendance → assessment → admissions → school finance core → CMS → communications/portals → advanced accounting → restricted records → optional services → SaaS billing → governance/support → localization. Review cycles (student photo/file, CMS domain, application conversion) by nullable initial reference and later constraint migration or safe service orchestration, never unchecked polymorphic IDs. RLS/grants are applied before exposure in each migration.

## Unresolved items — review required

- Final pilot scope and acceptance criteria/stakeholder validation.
- Region, tier, PostgreSQL version/extensions, Auth provider settings, API exposure, cost/limits and hosting latency.
- Detailed schema namespace/exposure allow-list and role/grant/RLS helper implementation review.
- Concrete FK delete actions, table/column names, enum/reference strategy and optional campus/class/subject scope.
- Calendar overlap, recurrence, timetable local-time semantics and daylight-saving policy for future markets.
- Currency registry, precision/rounding, exchange source/approval and Zimbabwe legal-tender configuration.
- Payment provider, callback verification, settlement/refund/reconciliation and admission-fee transfer rules.
- Legal/privacy, children’s data, consent, retention, deletion/anonymization, legal holds, residency/cross-border transfer.
- Restricted health/safeguarding/custody workflow, access reason and reviewers.
- Storage provider, scanning, backup and restore, independent backups, RPO/RTO.
- Domain verification, SSL, tenant routing and cache invalidation; analytics/performance targets; support and incident plan.

## Approval boundary

Checklist items remain **Pending** until reviewed and evidence recorded. This is documentation only. It does not create or authorize SQL, migrations, schema execution, seed data, app code, CI, infrastructure, or deployment.


## Documentation reconciliation update (21 November 2026)

- Canonical table names are aligned with the dictionaries; previous aliases and omitted grouped tables are recorded in the table-level review addendum.
- A duplicate empty grade_levels heading was removed from the academics dictionary; duplicated CMS blueprint rows were removed.
- D01–D19 are logical dependency labels only. Existing live bootstrap migration history must be reconciled before any future SQL is authored.
- **Review work complete:** naming and grouped-table inventory. **Implementation readiness remains pending:** baseline diff/replay, exact constraints/FK actions, policy/grant tests, provider/legal/operational evidence and pilot acceptance.
