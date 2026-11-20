# Database Constraints, Indexes, Tenant Isolation and Lifecycle

## 1. Tenant-safe referential integrity

A conventional FK on `id` does not alone prove that two tenant rows share the same `school_id`. Recommended pattern: add a unique constraint `(school_id, id)` to each tenant table and use composite FKs such as `(school_id, student_id) REFERENCES students(school_id,id)`. Apply this pattern to tenant-to-tenant relationships. Global tables (permissions, system plans, auth identity) use ordinary FKs with separate scope checks. Tenant ID is derived from verified session membership in server code and must not be trusted solely from user input.

## 2. Uniqueness and integrity baseline

- School slug globally unique; domain name globally unique after normalisation.
- School-local codes unique: campus, student number, staff number, grade, class, stream, subject, category, fee, invoice, receipt, admission reference, ticket, transport route, book accession and supplier code.
- Membership: one active school/user membership.
- Guardian link: no duplicate active guardian/student relationship; verification and per-link permissions apply. Emergency-contact authority and legal/custody restrictions are separate records and override ordinary relationship access.
- Calendar/year/term: valid ranges; current year uniqueness per calendar; terms may overlap only under explicit calendar policy. Validate timetable periods, class/teacher/room conflicts, effective dates and published-version integrity.
- Class and stream capacity nonnegative; active enrolment/class assignments cannot exceed capacity unless an override is recorded.
- Enrolment: allow multiple concurrent enrolments only for approved programme/grade combinations; define primary enrolment per applicable scope; prevent conflicting active assignments and preserve history. Do not impose a blanket student/year uniqueness rule.
- Attendance: unique session/student; student must be eligible for class on date.
- Assessment: scores within maximum; assessment period, class subject and student must be in same school and eligible cohort. Versioned grading/weighting/aggregation/ranking/promotion/report-layout rules; component weights and totals validated.
- Report cards: unique enrolment/year/term/type; published artifacts are snapshots.
- Admissions: unique application reference; conversion creates/links one student idempotently; application statuses transition via workflow.
- Invoice: unique invoice number; amounts reconcile to line totals and discount/tax; single currency; posted invoices immutable.
- Payment: unique school reference; external provider transaction idempotent; verified status required for allocations/receipts.
- Allocation: same currency, same tenant, not greater than available payment or invoice outstanding. Enforce with transactional service/locking; simple CHECK cannot enforce aggregate sums.
- Refund: amount <= eligible net received; approval and immutable transaction history.
- Journal: debits equal credits per currency; only posted entries are immutable; posting restricted to open period.
- Website: unique page slug per website/language; publication points to version; domain verified before routing; component schema allow-list.
- Files: object key unique; size > 0; file status and scan status required; public privacy classification requires approval.
- Messages: thread participants authorise access; internal support notes excluded from requester view.
- Transport: route-stop sequence unique; assignment stop must belong to route; student assignment valid for period.
- Subscription: contract snapshots price/plan; event history; usage dedupe key unique.

## 3. Recommended indexes

Create indexes on all FK columns and common tenant-scoped filter/sort paths. Use composite indexes starting with school_id for tenant queries.

### Tenant/identity
- memberships: `(school_id,user_id,status)`, `(user_id,status)`.
- role assignments: `(school_membership_id,valid_from,valid_until)`; role permissions by role_id.
- campuses, staff, students: `(school_id,status)`, unique identifiers.

### Academics
- academic years: `(school_id,start_date,end_date)`; terms: `(school_id,academic_year_id,start_date)`.
- classes: `(school_id,academic_year_id,grade_level_id)`; streams by class.
- enrolments: `(school_id,student_id,academic_year_id,status)`, `(school_id,student_id,is_primary,status)`, programme/year and valid-date indexes; avoid a unique student/year index that blocks approved concurrent enrolments.
- class assignments: `(school_id,class_id,start_date,end_date)`, `(school_id,student_enrolment_id)`.

### Attendance and results
- attendance sessions: `(school_id,class_id,session_date)`, `(school_id,academic_year_id,session_date)`.
- attendance records: unique `(session_id,student_id)`, `(school_id,student_id,session_date)` via session date denormalisation or join strategy.
- assessments: `(school_id,class_subject_id,assessment_date)`, `(school_id,assessment_period_id,status)`.
- marks/results: unique assessment/student/component; `(school_id,student_id,assessment_id)`; report cards by student enrolment/year/term.

### Admissions and finance
- applications: `(school_id,campaign_id,status,submitted_at)`, unique reference.
- invoices: `(school_id,student_enrolment_id,invoice_status,due_date)`, `(school_id,invoice_number)`.
- payments: `(school_id,received_at,payment_status)`, unique payment reference; provider transaction index.
- allocations: `(invoice_id,payment_id)`; partial active index where status active.
- receipts: unique receipt number; payment_id.
- bank entries: import_id, account/date, entry_hash.
- journal entries: `(school_id,accounting_period_id,entry_date,status)`; journal lines account/entry.

### CMS, messaging and other services
- website pages: `(website_id,language_code,page_status,slug)`; publication by page/status/published_at.
- domain: unique normalized domain and website/primary index.
- notifications: `(school_id,user_id,read_at,created_at)`; deliveries by status/channel/queued_at.
- messages: `(thread_id,sent_at)`; recipients unique thread/user; ticket status/assignee indexes.
- library copies: `(school_id,copy_status,book_id)`; active loans by copy and borrower.
- route stops: unique route/sequence; assignments by enrolment/status.
- files: `(school_id,privacy_class,file_status,created_at)` and object-key unique.
- audit logs: `(school_id,occurred_at)`, `(actor_user_id,occurred_at)`, `(resource_type,resource_id)`.
- usage: unique dedupe key; `(school_id,feature_key,period_start)`.

Use partial indexes for active records where appropriate, GIN indexes only for measured JSONB search needs, and avoid over-indexing write-heavy ledgers. Use cursor pagination rather than deep offsets at scale.

## 4. RLS policy design

Enable RLS on every tenant table. Policies must use a trusted helper that resolves active membership and permission for the current authenticated user, with tenant ID validated from membership. Never rely on client-supplied school_id. Separate SELECT/INSERT/UPDATE/DELETE policies; deny destructive operations on immutable financial, audit and published history tables. Platform operations use narrowly controlled privileged pathways with audit and explicit tenant context.

- School staff: membership + permission + role scope.
- Campus/class/subject scoped staff: validate membership role scope and resource scope.
- Guardians: verified active guardian-student link, plus each link's portal permission flags and resource-specific checks.
- Students: self-access only where portal is enabled and record belongs to that student.
- Public website: no direct table access; use safe published-content views/API with only public columns and currently published versions.
- Files: RLS on metadata and private signed URL service; bucket access policies mirror tenant and privacy classification.
- Finance: separate permission keys and sensitive scopes; bursary/expense/refund/accounting controls.
- XEN platform console: platform role, support access purpose, least privilege, auditable time-bound access; no blanket unrestricted read without logged reason.

## 5. Lifecycle and deletion

- Identity deletion should not cascade into school records that need retention; deactivation/anonymisation workflow handles relationships.
- Student withdrawal/graduation changes lifecycle status and enrolment dates; retain academic and legal records under approved retention policy.
- Guardian relationship revocation immediately stops portal access, with historical link preserved.
- Staff departure ends membership/role grants and employment; retain required records.
- Posted invoices, payments, allocations, receipts, journals and audit entries are immutable; use voids/reversals/credits.
- CMS drafts may be deleted; published versions/publication events retained for history.
- File deletion is governed by retention/legal holds, references and object storage lifecycle; soft deletion alone does not remove sensitive data.
- Data export/deletion requests require identity verification, scope review, legal hold/retention review and logged outcome.

## 6. Transactions and concurrency

Use transactions for: enrolment conversion; invoice posting; payment verification and allocation; receipt issuance; refund approval/processing; journal posting; admissions conversion; assessment approval/publication; domain verification state changes. Use row locking or serializable/optimistic concurrency to prevent double allocation, double conversion, duplicate provider callbacks and race conditions. Use idempotency keys for externally retried operations.

## 7. Privacy, safeguarding and retention

Collect only necessary data. Sensitive medical, safeguarding, legal authority, national ID, financial account, bursary and incident details should be isolated into restricted tables or access classes rather than ordinary profile fields. Establish school- and jurisdiction-specific retention rules, guardian consent/authority, lawful processing, export and deletion workflows. This blueprint is not legal advice or compliance certification.

## 8. Accepted product decisions and remaining technical verification

The following are **approved product/design decisions** and must not be reopened as unresolved in this document:
- Flexible multiple academic calendars and overlapping terms where calendar policy permits.
- Controlled concurrent enrolments with primary-enrolment rules and history.
- Fully configurable grading, assessment and report-card rules.
- Multi-currency with explicit conversion records.
- Full accounting architecture, phased.
- School-configurable free/paid admissions fees, currency, waivers and refund rules; separate from tuition.
- Granular verified guardian/legal restrictions, custody and emergency-contact permissions.
- Restricted health and safeguarding modules, phased.
- Mixed website publishing controls and consent safeguards.
- Full communications system with read receipts, permissions, moderation and history.
- Optional transport, boarding, meals, clubs, activities, trips, permissions and attendance.
- Flexible XEN SaaS pricing/entitlements.
- Flexible data governance, residency, retention, backup/recovery, deletion, export, legal holds and incident response.

### Technical and operational verification still required
1. Validate calendar, timetable, local-time and recurrence semantics; verify clash detection and timetable publication snapshots.
2. Confirm concurrent-enrolment rules, primary scope and integrity constraints.
3. Confirm grading calculation/versioning, ranking, promotion, report layouts and rounding.
4. Define currency precision registry, conversion snapshots, rate source/approval and accounting treatment.
5. Select/validate payment providers, settlement, callbacks, refunds and reconciliation.
6. Validate guardian/legal restriction records, verification source, effective dates, review, access and legal-document protection.
7. Complete privacy/legal review for health/safeguarding, child data, retention, residency and consent.
8. Review website translation/review, media rights/consent, domain verification, public projection and cache invalidation.
9. Define communications policy for group messaging, read receipts, moderation, recipient scope and retention.
10. Validate optional service workflows and rollout gates.
11. Define SaaS plans, quotas, trials, grace/suspension, promotion redemption and pricing.
12. Define privacy, backup/PITR, RPO/RTO, audit retention and deletion workflows by jurisdiction.
13. Confirm API permission/exposure, database grants, RLS, tenant context and audit immutability.
14. Complete pilot school review of naming, workflows, grading, finance, admissions and timetable.

