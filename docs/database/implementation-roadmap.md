# Database Implementation Roadmap — XEN SCHOOL MANAGEMENT v3.0

**Status:** Roadmap for review; implementation not started.
**Baseline:** Complete Combined Master Plan v3.0, database dictionary, relationship specification, constraints/indexes/RLS specification and all 13 approved design decisions.
**Approval boundary:** This roadmap describes order, scope, dependencies, validation and release gates. It does not authorize SQL, application code, deployment, production data or credentials.

## 1. Implementation principles

1. Build the complete logical foundation before feature migrations.
2. Each school-owned record is tenant-scoped and tenant isolation is tested, not assumed.
3. Prefer tenant-safe composite keys/foreign keys where applicable.
4. Separate platform-level records from school tenant records and from public website content.
5. Keep XEN SaaS billing separate from school financial operations.
6. Plan all modules in the data model, but ship features in phases.
7. Use additive migrations where possible; destructive changes require review, backups, a deprecation window and rollback/forward-fix plan.
8. Every migration is versioned, reviewed, tested in a disposable database and accompanied by rollback or recovery notes.
9. Do not use floating-point representations for money. Store exact values with explicit currency and conversion evidence.
10. Use immutable posting/history records for finance and other audited processes; corrections are reversals, adjustments or new versions.
11. Access control is deny-by-default; public endpoints expose approved public content only.
12. Use synthetic fixtures for development and automated tests; production data must not be copied into development without approved de-identification.

## 2. Proposed database environment and tooling (to confirm before implementation)

- PostgreSQL managed through Supabase, with Supabase Auth as the identity provider.
- Migration files tracked in Git and executed through a controlled migration tool/CI workflow.
- Separate local, test, staging and production environments; never share production secrets.
- Supabase CLI/local stack for development, if confirmed; automated ephemeral test databases or isolated schemas for CI.
- PostgreSQL extensions only after their need, availability, security impact and environment compatibility are reviewed.
- Secrets are supplied through secret managers/environment configuration, not committed.
- Object/file storage metadata lives in PostgreSQL; actual file bytes use private/public buckets with access rules, preferably Cloudflare R2 subject to final architecture confirmation.
- Exact backup, PITR, recovery and retention capabilities must be confirmed against chosen service tier before production.

## 3. Migration phases and sequence

### Phase 0 — Design freeze and operational readiness
**Deliverables:** finalized naming conventions; schema conventions; UUID strategy; timestamp/time-zone conventions; currency and locale standards; status/enum strategy; deletion/retention rules; tenancy pattern; migration tooling; environment plan; data classification; migration review checklist.
**Dependencies:** approved conceptual specifications.
**Exit gate:** architecture and implementation choices reviewed; legal/security questions flagged; no conflicting unresolved design choices.

### Phase 1 — Platform, tenant, identity and security foundation
**Core entities:** platform configuration, schools/tenants, campuses, user profiles, memberships, roles, permissions, role-permission mapping, membership-role assignment, platform roles, audit/security events, tenant context helpers.
**Build sequence:**
1. Create shared identifiers, timestamps and audit metadata conventions.
2. Create platform-level tables and school tenant table.
3. Create campuses and user/profile records.
4. Create school memberships and role/permission model.
5. Define tenant-safe unique constraints and composite keys.
6. Create helper functions for tenant/membership/permission resolution only after security review.
7. Add baseline RLS for platform, school, membership and profile data.
8. Add security/audit event structures.
**Tests:** tenant A cannot read/write tenant B; users cannot self-grant roles; disabled membership revokes access; platform admin elevation audited; no cross-tenant FK links.
**Exit gate:** tenant isolation tests pass; policy review passes; authentication and tenant context are reliable.

### Phase 2 — People, guardian relationships and staff
**Entities:** students, guardians, guardian-student links, enrolments, staff, employment, qualifications, documents metadata, departments, department memberships, teacher assignments.
**Sequence:** student/guardian/staff identities → verified relationships and access rules → enrolment lifecycle/history → staff employment and assignments → documents metadata and permissions.
**Tests:** duplicate identities within defined school rules; guardian verification; guardian access only to linked learners; revocation/restriction immediate; campus/class scope; history preserved; staff permissions least privilege.
**Exit gate:** enrolment, guardian relationship and staff access workflows pass.

### Phase 3 — Academic structure and flexible calendar
**Entities:** academic calendars/years, terms, grade levels, classes, streams, subjects, class-subject mappings, student class assignment history.
**Sequence:** calendar model → years/terms → grade/class/stream → subject catalog → assignments → class history and promotion/transfer rules.
**Tests:** multiple calendars; overlapping terms where allowed; time-zone/date boundaries; valid campus scope; controlled enrolment rules; historic class records.
**Exit gate:** schools can configure academic structures without bespoke schema changes.

### Phase 4 — Attendance
**Entities:** attendance sessions, attendance records, corrections, notification events.
**Sequence:** session setup → attendance capture → record uniqueness and states → correction workflow/audit → notification integration records.
**Tests:** duplicate capture prevention; authorised correction; class/teacher scope; guardian visibility; attendance summary consistency; offline/retry behavior if planned.
**Exit gate:** attendance totals and audit history reconcile.

### Phase 5 — Assessment and results foundation
**Entities:** grading schemes/scales, assessment periods, assessments, components, student marks, moderation, results, report cards and items.
**Sequence:** configurable grading → assessment periods → assessment/component structure → marks and validation → moderation → aggregation/results → report-card version/publication.
**Tests:** weights and rounding rules; missing/absent/exempt states; grade boundary changes/versioning; moderation trail; locked published results; role restrictions; reproducible calculations.
**Exit gate:** end-to-end assessment cycle validated against approved school examples.

### Phase 6 — Admissions
**Entities:** campaigns, applications, applicants, guardians, documents, reviews, interviews, offers, status history, configurable fees and admission payments.
**Sequence:** campaign/configuration → applicant/application → document uploads and permissions → workflow/status history → review/interview → offers → payment verification (if enabled) → idempotent conversion to student/enrolment.
**Tests:** public form validation/rate limits; sensitive data minimization; document access; duplicate application handling; workflow transitions; payment verification; conversion idempotency; applicant-to-student linkage.
**Exit gate:** admissions can run through acceptance and authorised conversion with no duplicate student records.

### Phase 7 — Core school finance (first finance release)
**Entities:** fee categories, fee structures/items, fee assignments, invoices/items, payment methods, payments, allocations, receipts.
**Sequence:** currency/amount model → fee catalog/structures → fee assignment → invoice creation/posting → payment record and verification → allocations → receipts → balance/read models.
**Tests:** invoice totals; currency consistency; partial/overpayment rules; allocation limits; idempotent payment callbacks; unverified payment cannot allocate or generate receipt; immutable posted invoice/payment; reversal; reconciliation of student balance.
**Exit gate:** independent financial reconciliation and audit tests pass. Payment providers are not enabled until provider contracts, credentials, callbacks and verification design are separately approved.

### Phase 8 — Website builder, CMS, domains and public publishing
**Entities:** websites, themes, pages, page versions, sections/components, navigation, media metadata, articles, events, domains, translations, publication records, SEO, forms/submissions.
**Sequence:** website tenancy → approved component catalog → draft page/version model → sections and navigation → media and permission controls → publishing workflow → public read model/API → domain verification/mapping → forms → translations.
**Tests:** anonymous public access sees only approved published content; drafts/private data not exposed; XSS/injection prevention; media consent flags; domain verification; revision restore; publishing/unpublishing cache invalidation; tenant-domain mapping.
**Exit gate:** school websites publish safely and are isolated from management records.

### Phase 9 — Portal and communications
**Entities:** portal preferences, notifications, access logs/device tokens, announcements, threads, messages, recipients, attachments, templates, deliveries, preferences, provider logs.
**Sequence:** recipient authorization model → announcements → direct messages/thread participants → attachments → notification delivery records → preferences/read receipts → moderation/retention controls.
**Tests:** recipient membership; teacher-parent/student permissions; cross-tenant message isolation; attachment access; delivery retries/idempotency; moderation and retention; audit.
**Exit gate:** communications are secure, traceable and permission-configurable.

### Phase 10 — Advanced finance and accounting
**Entities:** discounts, bursaries, adjustments, credit notes, refunds/approvals, unallocated credits, bank accounts/imports/entries/reconciliation, chart of accounts, accounting periods, journal entries/lines, expenses/categories, suppliers, purchase requests, budgets/items, financial approvals.
**Sequence:** financial adjustment/credit models → refund workflow → bank import and matching → accounting setup → journal posting rules → expense/supplier workflows → budgets and approval chains → financial reports.
**Tests:** balanced journals; closed-period enforcement; refund caps/approval; reconciliation audit; exact currency conversions; posted record immutability; permission separation; report tie-outs.
**Exit gate:** accounting control and independent reconciliation review accepted.

### Phase 11 — Restricted health and safeguarding
**Entities:** health profile/conditions/allergies, visits/medications as approved, incident and safeguarding records, referrals, action plans, restricted attachments and access audit.
**Sequence:** data classification and policy review → minimal schema → restricted role model → record/incident workflow → access audit and retention controls → reporting with safe aggregates.
**Tests:** strict least-privilege; no exposure through student profile APIs, search, exports, logs or parent portals; access reason/audit where required; legal retention and deletion controls.
**Exit gate:** safeguarding/health data access design reviewed by appropriate school/legal/privacy stakeholders. This module must not launch merely because generic RLS passes.

### Phase 12 — Optional school services
**Entities:** library catalog/copies/categories/loans/reservations/fines; transport vehicles/routes/stops/drivers/assignments/incidents; boarding/dormitory/room/house; meals; clubs/activities/trips/permissions and attendance as approved.
**Sequence:** each optional module receives a separate feature design and migration set; shared people/permissions/document foundations are reused.
**Tests:** module-specific workflows, capacity/assignment rules, parent permissions, incidents and tenant isolation.
**Exit gate:** each module is feature-flagged, documented and separately accepted; do not block core product.

### Phase 13 — XEN SaaS commercial billing and usage
**Entities:** plans/features, subscriptions/items, platform invoices/payments/events, usage, billing customers, promotions.
**Sequence:** plan/feature catalog → subscription state machine → usage metering → invoice generation → payment/renewal integration → grace/suspension/reactivation rules → admin reporting.
**Tests:** idempotent webhooks; subscription transitions; limits; grace periods; cancellation; promotions; tenant billing isolation; school operational finance remains separate.
**Exit gate:** commercial billing reconciles and can be operated without affecting school finance records.

### Phase 14 — Documents, support, platform operations and governance
**Entities:** document categories/files/versions/permissions/access logs/retention; support tickets/categories/messages/assignments/attachments/status history; data export/deletion requests; consent; jobs/failures; webhooks; backups.
**Sequence:** file metadata and private storage controls → document lifecycle → support workflows → export/deletion lifecycle → jobs/retry/idempotency → webhook logs → backup inventory/restore tests → governance reporting.
**Tests:** signed access expiration; scanning and quarantine policy; retention/legal holds; deletion verification; export authorization; job retry; audit completeness; restore tests.
**Exit gate:** operations and governance workflows are tested and documented.

### Phase 15 — Internationalisation and multi-region readiness
**Scope:** translation catalogs and content translation relations; locale/time-zone settings; country-specific identifiers; configurable academic/financial/legal rules; region and residency configuration; multi-region operational planning.
**Tests:** locale/date/number/currency display; translated content fallback; no assumptions tied to Zimbabwe identifiers; residency policies and deployment boundaries.
**Exit gate:** international support is configuration-driven, not hardcoded to one country.

## 4. Suggested release groupings

| Release | Database phases | User-facing outcome |
|---|---|---|
| Foundation | 0–2 | Secure school tenancy, users, students, guardians, staff |
| School operations | 3–5 | Academic setup, attendance, assessments/results |
| Admissions | 6 | Online admissions workflow |
| Finance v1 | 7 | Fees, invoices, verified payments, receipts and balances |
| School digital presence | 8 | Website builder, CMS, domains, admissions forms |
| Portals & communication | 9 | Guardian/student portals and messaging |
| Finance v2 | 10 | Accounting, reconciliation, refunds, budgets |
| Restricted services | 11–12 | Health/safeguarding and optional school services |
| SaaS operations | 13–14 | XEN billing, documents, support and governance |
| International expansion | 15 | Localisation and region readiness |

Release order may change based on pilot schools and delivery capacity, but foundational tenancy/security must precede every tenant feature.

## 5. Migration file organization (proposed, not created)

Use sequential, timestamped migration files with small, reviewable scopes. Proposed group prefixes:
- `0001_platform_extensions_and_conventions`
- `0002_platform_and_tenants`
- `0003_identity_profiles_and_memberships`
- `0004_roles_permissions_and_audit`
- `0005_people_guardians_and_staff`
- `0006_enrolments_and_academic_structure`
- `0007_attendance`
- `0008_assessment_and_results`
- `0009_admissions`
- `0010_school_finance_core`
- `0011_websites_and_cms`
- `0012_portals_and_communications`
- `0013_advanced_finance_and_accounting`
- `0014_health_and_safeguarding`
- `0015_optional_school_services`
- `0016_xen_saas_billing`
- `0017_documents_support_and_governance`
- `0018_localisation_and_region_settings`

These are illustrative grouping names only; actual migration IDs and contents will be finalized before implementation.

## 6. Required migration contents and review checklist

For each migration:
- Purpose and scope.
- Dependencies and affected entities.
- Schema changes (tables, columns, constraints, indexes, functions/triggers/policies).
- Tenant scope and data classification for each new entity.
- RLS/policy changes and grants.
- Data migration/backfill plan (if any).
- Performance considerations.
- Automated tests and expected results.
- Deployment order and compatibility notes.
- Rollback, or forward-fix procedure if rollback is unsafe.
- Backup requirement and restore validation for high-risk changes.
- Documentation updates.

## 7. RLS and tenant-isolation implementation sequence

1. Establish tenant key conventions and security threat model.
2. Define user-to-school membership and active membership checks.
3. Define permission and scoped-role semantics.
4. Implement safe tenant context resolution—never trust a client-supplied tenant ID alone.
5. Apply RLS to tenant tables before exposing APIs.
6. Create policy matrix for school staff, scoped staff, guardians, students, public visitors and platform operators.
7. Use restrictive default policies; explicit grants and explicit allow rules.
8. Validate composite tenant foreign keys and uniqueness prevent cross-tenant relationships.
9. Test using non-owner application roles; superuser/service roles bypassing RLS must not be used as proof of security.
10. Add negative tests for every role and every table group; include anonymous/public requests.
11. Audit privileged operations and carefully constrain platform support access.
12. Repeat isolation tests whenever a schema, policy, view, function, API or role changes.

### Minimum RLS test matrix

- Anonymous visitor: only approved public website data.
- School staff: only their tenant and granted scope.
- Teacher: assigned classes/subjects and permitted student records.
- Bursar: permitted finance records; no restricted health/safeguarding by default.
- Admissions staff: applicants and admissions records; no unrelated student records.
- Website editor: CMS only; no private student/finance/medical data.
- Guardian: verified linked students and permitted fields; restrictions immediately enforced.
- Student: own records and permitted portal features only.
- Platform support: explicit, time-limited, audited access as approved; not unrestricted routine access.
- Disabled user/membership: access denied.
- Cross-tenant guessed IDs: no read, write, update, delete or indirect disclosure.

## 8. Test strategy by layer

**Schema tests:** types, nullability, defaults, uniqueness, FK integrity, check constraints, indexes and migration replay.

**RLS/security tests:** positive and negative access tests, tenant isolation, role escalation, sensitive fields, views/functions and public endpoints.

**Workflow tests:** transaction atomicity, idempotency, status transitions, concurrency, immutability, reversal and history.

**Finance tests:** currency arithmetic, rounding, invoice/payment allocation, receipts, refunds, journal balancing and reconciliation.

**Privacy tests:** guardian link/revocation, restricted records, export, deletion/anonymisation, retention, audit and consent.

**Performance tests:** common tenant queries, large school data volumes, indexes, pagination, reporting queries, workload isolation and public-site caching.

**Recovery tests:** backup restore, point-in-time recovery (where supported), restore into isolated environment, integrity verification and documented recovery time/objective targets.

## 9. Release gates (must all pass)

- Migration applies cleanly from empty database and from supported prior version.
- Schema validation and automated test suite pass.
- Tenant isolation and RLS tests pass with realistic roles.
- No secrets or sensitive personal data in repository, logs or test fixtures.
- API and data contracts reviewed for sensitive/public exposure.
- Backup and recovery requirements met for release risk.
- Migration/rollback/forward-fix procedure documented.
- Monitoring, audit and operational alerts defined.
- Product owner approves release scope and acceptance criteria.
- High-risk features (finance, health/safeguarding, custody/legal access) receive domain/security review.

## 10. Pre-implementation decisions still to confirm

Although the 13 product design decisions are approved, the following technical and operational details require confirmation before writing migrations:
1. Exact PostgreSQL/Supabase project and service-tier capabilities, including backup/PITR and regional availability.
2. Migration tool and CI integration.
3. Tenant context and RLS helper design, including safe handling of Supabase Auth JWT claims.
4. UUID/key strategy and tenant composite FK convention.
5. Time-zone/date/timestamp policy.
6. Currency precision, rounding and exchange-rate source/approval policy.
7. Payment providers and webhook verification for Zimbabwe and future markets.
8. Data retention schedules and jurisdiction-specific requirements.
9. School-specific workflow configuration boundaries.
10. File storage provider, scanning/quarantine and signed URL design.
11. Health/safeguarding fields, roles, workflows and lawful access.
12. SaaS pricing limits and lifecycle states.
13. Domain routing, cache invalidation and publishing workflow.
14. Performance/scale targets, recovery objectives and backup schedule.
15. Detailed acceptance criteria and pilot-school validation.

## 11. Recommended next step

Review and approve this roadmap. Once approved, prepare a **schema blueprint and migration manifest**: table groups, proposed primary/foreign keys, tenant keys, enum/status definitions, data classifications, dependencies and RLS policy matrix. That blueprint is still documentation. SQL implementation should only begin after a separate explicit authorization.
