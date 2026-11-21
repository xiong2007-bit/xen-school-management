# Migration Manifest — XEN SCHOOL MANAGEMENT v3.0

**Status:** Proposed documentation only. Migration files, SQL, executable schema and CI are not created. Names are logical groups and should receive actual ordered migration IDs only after design approval.

## Manifest conventions
- Each migration is atomic, reviewable, forward-only by default; destructive changes use expand/migrate/contract and require backup/rollback review.
- Dependency order is strictly sequential unless migration tooling supports explicit dependency metadata.
- Every migration includes schema changes, tenant keys/composite FKs, indexes, classification, RLS/grants, test plan, operational impact and rollback/forward-fix notes.
- Run in local disposable DB, CI ephemeral DB, staging and production with explicit approval. No secrets in repo.
- RLS and grants must be applied before a table is exposed to API clients. Avoid relying on owner/service-role behavior for policy tests.
- Migration files are illustrative groups—not SQL files or an implementation.

## Ordered manifest

| Order | Proposed migration group | Contents | Depends on | Verification gate |
|---:|---|---|---|---|
| 0001 | conventions-and-reference-data | UUID/time/money conventions; currency definitions/precision; approved extensions; common audit conventions | 0000 design freeze | Empty DB boot; extension/reference data review |
| 0002 | platform-and-tenants | schools/tenants, campuses, platform settings | 0001 | Tenant root integrity; slug uniqueness |
| 0003 | identity-profiles-memberships | profiles, auth identity links, memberships | 0002 | Auth mapping; membership lifecycle |
| 0004 | roles-permissions-and-audit | roles, permissions, mappings, platform roles, audit/security events, tenant context grants | 0003 | No self-escalation; audit integrity |
| 0005 | file-metadata-foundation | files/object metadata, privacy class, scan state, storage lifecycle metadata (no provider integration) | 0002–0004 | Tenant/object uniqueness; quarantine state |
| 0006 | people-guardian-staff | students, guardians, verified links, emergency contacts, legal/custody restrictions, staff/HR/departments | 0004–0005 | Cross-tenant FK; verified guardian; legal restriction tests |
| 0007 | enrolment-academics-calendar-timetable | controlled enrolments; academic programmes/calendars/years/terms/events; grades/classes/streams/subjects; periods/rooms/timetable versions/entries/exceptions; class history; teacher assignments | 0006 | Calendar overlap rules; concurrent enrolment; timetable clash checks |
| 0008 | attendance | sessions, records, correction history, notification events | 0007 | Duplicate prevention; correction/audit; period references |
| 0009 | assessment-and-results | assessment categories, versioned grading schemes/scales/rules, promotion rules, periods, assessments/components, marks, moderation, results, report cards/templates/layout snapshots | 0007; 0008 optional integration | Configurable grading; snapshot reproducibility |
| 0010 | admissions | campaigns, applications, applicants/guardians, documents, reviews/interviews/offers, canonical fee settings/snapshots/payments/refunds, conversion history | 0005–0007 | Public submission privacy; fee snapshot; transition/idempotent conversion |
| 0011 | school-finance-core | fee categories/structures/items/assignments, payment methods, invoices/items, payments, allocations, receipts | 0006–0007; 0005 | Currency consistency, verified-payment and allocation invariants |
| 0012 | websites-and-cms | website/theme/page/version/sections/components/reusable blocks/starter templates/navigation/media/articles/events/domains/translations/publications/SEO/forms/submissions | 0002; 0004; 0005 | Public projection, unpublish, verified-domain checks |
| 0013 | portals-and-communications | preferences, notifications, access logs/tokens, announcements, threads/messages/recipients/read receipts/attachments/moderation actions, templates/deliveries/preferences/provider logs | 0004–0012 as relevant | Recipient permissions, receipts, moderation, attachment privacy and retries |
| 0014 | advanced-finance-accounting | discounts/bursaries/adjustments/credit/refunds, unallocated credit, bank/reconciliation, exchange rates/conversion snapshots, accounts/periods/journals, expenses/suppliers/purchase/budgets/approvals | 0011 | Double-entry balancing, FX snapshots, approvals, closed periods |
| 0015 | health-and-safeguarding | restricted health profiles/conditions/allergies/visits/medications, incidents, concerns, referrals, plans, attachments/access audit | 0004; 0006; 0005 | Need-to-know, legal/privacy and safeguarding review |
| 0016 | optional-school-services | library, transport, boarding, meals, clubs, activities, trips, permissions, attendance and service incidents | 0006–0008; 0011 integration optional | Capacity, consent, safety and module-specific acceptance |
| 0017 | xen-saas-billing | plans/features, billing customers, subscriptions/items, platform invoices/payments/events, usage, promotions/redemptions | 0002; 0004; provider event foundation | Separate from school finance; idempotent billing |
| 0018 | documents-support-governance | document categories/versions/permissions/access logs, retention, export/deletion requests, support desk, jobs/failures, webhook events, backup/recovery inventory, consent | 0004–0017; extends 0005 file foundation | Scan/quarantine, permissions, retention/holds, support privacy |
| 0019 | localisation-and-region-readiness | translation catalogs, country-specific config, residency/region metadata, locale/jurisdiction settings | 0002; configurable modules | Zimbabwe and international locale/date/currency/jurisdiction tests |

## Dependency notes

- File metadata foundation is intentionally moved to 0005, before admissions, staff documents, CMS media and finance attachments that reference files.
- Currency precision reference data is introduced at 0001; exchange-rate records and immutable conversion snapshots are introduced in advanced finance (0014), while multi-currency fields are supported in core finance.
- Admission fees use campaign fee settings as the canonical configuration and an application-specific snapshot; payments are admissions-domain records and remain separate from tuition.
- Academic calendars, timetable periods, rooms, versioned timetables and date exceptions are included in 0007. Published timetable versions must not be overwritten.
- Restriction/legal access metadata is in the people foundation (0006), with highly restricted document content stored through the file foundation.
- The table above is the authoritative sequence. No additional renumbering proposal is outstanding.

## Cross-migration acceptance criteria

- Dependencies exist before referenced FK creation. Circular links (e.g., website primary domain; student photo file; class teacher staff; converted application student) should be nullable and/or introduced in later alteration steps with documented cycle handling.
- All tenant tables have `school_id`, unique `(school_id,id)`, tenant-safe composite FK patterns and RLS.
- All FKs indexed or covered. Tenant-leading indexes exist for common paths; index additions reviewed for write cost.
- No public access to base private CMS, submissions, media metadata, student or finance tables.
- Health, safeguarding, custody/legal, bursary and bank details are separately classified and restricted.
- School finance and XEN SaaS billing table groups, permission keys, lifecycle and reporting remain separate.
- Posted/approved historical records are immutable; corrections use event/reversal/version records.
- Idempotency and transactional consistency for admissions conversion, provider webhooks, payments, allocations, receipts, refunds, journal posting and publication.
- Every migration has test coverage, security review where sensitive, upgrade/rollback or forward-fix plan and acceptance sign-off.

## Required test gates by phase

1. **Migration integrity:** replay from empty; supported upgrade path; schema diff; rollback/forward-fix test; no accidental destructive change.
2. **Tenant security:** tenant A/B reads/writes, guessed IDs, nested joins, RPC/view paths, campus/class scope, revoked membership and role grants.
3. **RLS correctness:** tests as normal application roles; no owner/service bypass in proof; explicit anonymous, platform and school-role tests.
4. **Workflow:** valid/invalid transitions, duplicate/retry/idempotency, race conditions, lock/transaction invariants, immutable snapshots.
5. **Privacy:** verified guardian relation/revocation; legal restrictions; public projection; field minimization; sensitive records absent from search, exports, messages, logs and APIs.
6. **Finance:** currency consistency, exact arithmetic/rounding, invoice/payment/allocation reconciliation, verified-only receipt, refund caps/approval, balanced journals, closed period.
7. **File security:** scan/quarantine, object-key isolation, signed-link expiry, classification, consent, retention and deletion.
8. **Performance:** representative school scale, query plans, indexes, pagination, reporting and cache invalidation.
9. **Operations:** backup restoration, recovery objectives, incident response, monitoring, migration window and access review.
10. **Domain validation:** school pilot acceptance; finance/accounting, legal/privacy, health/safeguarding and Zimbabwe-market review where relevant.

## Items for review before authorizing SQL

- Confirm UUID version and database version/extensions.
- Confirm migration tool and environments.
- Confirm trusted tenant-context/RLS helper and role architecture.
- Decide file-metadata foundation placement and resolve circular FK plan.
- Confirm schemas vs single schema/namespaces and table naming.
- Validate composite FK conventions against chosen auth provider and global tables.
- Confirm timezone/calendar, currency/rounding and conversion design.
- Confirm payment provider strategy and verification model.
- Confirm retention, residency, backups/PITR, RPO/RTO.
- Confirm domain/DNS/publication and cache invalidation.
- Confirm health/safeguarding, custody/legal data model and access reviewers.
- Confirm SaaS billing state machine and pricing/limits.
- Confirm table-level and column-level security where required, API exposure boundaries.
- Approve pilot and acceptance criteria.

## Explicit non-deliverables

This manifest contains no SQL, migration scripts, executable schema, seed data, application code, CI, infrastructure, deployment configuration or production changes. It is a planning artifact only.


## 7. Migration review checklist and table-group traceability

Each ordered group is a planning label, not a migration file. Before an actual migration is authored, its PR must identify exact tables/columns and reviewed FK graph; PK and unique keys; tenant-safe composite FK exceptions; delete/update behavior; constraints and lifecycle transitions; data classification; indexes; grants/RLS/API exposure; test evidence; and migration risk/rollback or forward-fix plan.

| Order | Logical domain | Table families | Tenant/security boundary | Blocking acceptance |
|---:|---|---|---|---|
| 0001 | conventions/reference | currency precision, reference conventions, extensions if approved | Platform/global | UUID/time/currency conventions; environment compatibility reviewed |
| 0002 | tenant root | schools, campuses, settings | Tenant root | tenant status and unique slug; root isolation |
| 0003 | identity | profiles, memberships | Global auth + tenant membership | active membership resolution, revoked access |
| 0004 | authorization/audit | roles, permissions, grants, audit/security | Platform vs tenant scoped | no self-escalation; append-only audit; least privilege |
| 0005 | file metadata | file records, classification, scan/retention metadata | Tenant + private storage | quarantine/clean and key isolation |
| 0006 | people/HR | students, guardians, restrictions, emergency contacts, staff | Tenant; restricted HR/legal fields | guardian verification/revocation, legal restriction override |
| 0007 | academics | calendar/year/terms, programmes, timetable, classes/subjects, enrolment | Tenant-safe academic graph | date/overlap rules, approved multiple enrolment, schedule clashes |
| 0008 | attendance | sessions/records/corrections/notifications | Tenant + class scope | eligibility, uniqueness, corrections/audit |
| 0009 | assessment | scheme versions, assessments, marks, moderation, results, report cards | Tenant + assigned subject | bounds, snapshots, moderation and published filtering |
| 0010 | admissions | campaigns/apps/reviews/offers/fees/payments/conversion | Tenant; public submission isolated | public minimization, snapshot fee, idempotent conversion |
| 0011 | school finance core | fee setup, invoice, payment, allocation, receipt | Separate school-finance domain | exact totals, verified payments, bounded allocation, receipt |
| 0012 | public CMS | websites/pages/versions/blocks/publication/domains/forms | Private CMS and safe public projection | anonymous access only approved version; unpublish/cache purge |
| 0013 | portals/communications | portal filters, messages, notifications, receipts, moderation | Tenant + participant/guardian scopes | recipient scope, moderation, delivery idempotency |
| 0014 | advanced accounting | credit/refund/FX/bank/reconciliation/journals/budgets | School-finance domain | double-entry balance, approvals, close/reversal, FX snapshots |
| 0015 | restricted records | health/safeguarding/custody/legal | Separate restricted schema/domain | restricted role, reason audit, no portal/public/search leakage |
| 0016 | optional services | library, transport, boarding, meals, clubs, trips | Tenant + service assignment | consent/capacity/eligibility; module entitlement |
| 0017 | SaaS billing | XEN plans/pricing/subscriptions/usage/entitlements | Platform billing domain | contract snapshot, dedupe, separation from school ledger |
| 0018 | documents/support/governance | retention, requests, service desk, jobs, webhooks, backup inventory | Tenant-private + platform ops | privacy controls, access audit, hold, idempotent jobs |
| 0019 | localization/region | translation/config/residency/jurisdiction | Global + tenant configuration | locale/currency/date/region checks and privacy review |

## 8. Cross-domain dependency and cycle handling

- The tenant root and identity/authorization must precede all tenant-owned domains; security/RLS must be applied as soon as a table is exposed, not deferred to a later “security migration”.
- File metadata precedes records that attach files. Store references nullable only where the business relationship is optional; later migrations add constraints for cross-domain cycles (e.g., profile photo, CMS domain, converted admissions record). Do not resolve a cycle with unchecked IDs.
- Admissions conversion references students/enrolments created in the academics/people domain and is transactional/idempotent; admission payment records remain distinct from school tuition payments until an explicitly approved transfer/allocation workflow.
- Assessment may optionally depend on attendance for reporting; avoid a hard FK cycle. Reports consume approved snapshots/read models.
- CMS publication tables depend on website authoring/version structures; public API/read projection is separate and allow-listed. Private forms/submissions never enter the public projection.
- School finance core precedes advanced accounting. Accounting journal references are domain-local; school ledger and XEN subscription ledger must not share tables or posting routines.
- Restricted schema links to students through tenant-safe references, but access is not inherited from ordinary student permissions. Metadata visible to other modules must be minimized.
- Optional modules depend on core people/enrolment, file metadata, and (where fee charging is enabled) finance; they are not blockers for the first pilot.

## 9. Release and approval status

The manifest is a proposed dependency sequence. No migration IDs are assigned to actual files, no migrations have been created or run, and no executable schema, seed data, CI, infrastructure or deployment was changed. Scope, provider/legal/privacy, RPO/RTO and role/RLS review items remain open. Implementation requires separate explicit authorization.
