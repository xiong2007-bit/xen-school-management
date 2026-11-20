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
| 0001 | conventions-and-required-extensions | UUID strategy, common constraints/helpers only after review, audit conventions, extensions approved | 0000 design freeze | Empty DB boot; extension availability; naming review |
| 0002 | platform-and-tenants | schools, campuses, platform settings | 0001 | Tenant root integrity; slug uniqueness |
| 0003 | identity-profiles-memberships | profiles, memberships, identity links | 0002 | Auth identity mapping; membership lifecycle |
| 0004 | roles-permissions-and-audit | roles, permissions, mappings, platform roles, audit/security events, access grants | 0003 | No self-escalation; audit immutability |
| 0005 | people-guardian-staff | students, guardians, verified links/restrictions, staff/HR/departments | 0004 | Cross-tenant FK tests; guardian/legal restrictions |
| 0006 | enrolments-and-calendar | enrolments/history, calendars, years/terms/holidays, grade/class/stream/subjects, teacher/class assignments | 0005 | Flexible calendar; controlled concurrent enrolments |
| 0007 | attendance | sessions, records, correction history, notifications | 0006 | Duplicate prevention; approval/correction |
| 0008 | assessment-and-reporting | grading schemes/scales, periods, assessments/components, marks, moderation, results, report cards | 0006; 0007 optional integration | Configurable grading and snapshot reproducibility |
| 0009 | admissions | campaigns, applications, applicants/guardians, docs/reviews/interviews/offers, fees/payment records, conversion log | 0005; 0006; file metadata foundation (00017 may be split earlier) | Public submission privacy; transition/idempotent conversion |
| 0010 | school-finance-core | fee config/assignment, invoices/items, payment methods/payments, allocations, receipts | 0005; 0006; admission fee integration optional | Reconciliation, currency, verified-payment invariants |
| 0011 | websites-and-cms | website/theme/page/version/sections/components/navigation/media/articles/events/domains/translations/publications/SEO/forms/submissions | 0002; 0004; file metadata | Public projection and unpublish/domain checks |
| 0012 | portals-and-communications | preferences, notifications, access logs/tokens, announcements/recipient records, threads/messages/recipients/attachments, templates/deliveries/preferences/provider logs | 0004; 0005; 0007–0011 as relevant | Recipient permission, attachment privacy, retry/idempotency |
| 0013 | advanced-finance-accounting | discounts/bursaries/adjustments/credit/refunds, unallocated credit, bank/reconciliation, accounts/periods/journals, expenses/suppliers/purchase/budgets/approvals, conversions | 0010 | Double-entry balancing, approvals, closed periods, immutable postings |
| 0014 | health-and-safeguarding | restricted health profiles/visits/medications (as approved), incidents, concerns, referrals, plans, attachments/access audit | 0004; 0005; file layer | Need-to-know access and independent privacy/safeguarding review |
| 0015 | optional-school-services | library, transport, boarding, meals, clubs, activities, trips, permissions, incidents | 0005; 0006; 0007; 0010 integration optional | Each module separately feature-gated and accepted |
| 0016 | xen-saas-billing | plan catalog/features, billing customer, subscriptions/items, platform invoices/payments/events, usage, promotions/redemptions | 0002; 0004; provider event foundation | Explicitly separate from school finance; idempotent billing |
| 0017 | files-documents-support-governance | file metadata/version/permissions/access logs, categories, retention, export/deletion requests, support desk, jobs/failures, webhook events, backup/recovery inventory, consent if not earlier | 0004; all modules that reference files (recommend file metadata sub-group earlier before 0009/0011) | Scan/quarantine, permission checks, retention/holds, support privacy |
| 0018 | localisation-and-region-readiness | translations/catalogs, country-specific config, residency/region metadata, locale and jurisdiction settings | 0002; all configurable modules | Zimbabwe and international locale/date/currency/jurisdiction tests |

### Dependency refinement

The initial list above must be split/reordered if file metadata is required by admissions, CMS, staff documents or finance receipt attachments. Recommended implementation order for file primitives is to move a small **file-metadata foundation** migration immediately after 0004 (as 0005), then renumber people and subsequent groups. Do not create FKs to an undefined files table. Likewise audit/event primitives should exist before high-risk workflow history. This is an explicit manifest issue to resolve during finalization.

Suggested refined order:
1. conventions/extensions
2. platform/tenants
3. identity/membership
4. roles/permissions/audit
5. file metadata + private storage metadata (no storage integration implementation)
6. people/guardians/staff/legal access
7. enrolments/calendar/academic structure
8. attendance
9. assessment/reporting
10. admissions
11. school finance core
12. websites/CMS
13. portals/communications
14. advanced finance/accounting
15. restricted health/safeguarding
16. optional school services
17. XEN SaaS billing
18. documents/support/governance (extend file foundation; exports/deletion, support, retention, jobs/webhooks)
19. localisation/region readiness

The refined numbering is the recommended ordering. Final migration IDs may be timestamps or monotonic numbers; the repository roadmap's illustrative prefixes should be reconciled before implementation.

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
