# Schema Blueprint — Table-Level Reconciliation & Security Review

**Project:** XEN SCHOOL MANAGEMENT v3.0  
**Review date:** 21 November 2026  
**Status:** Documentation proposal; no executable schema or migration created in this review.  
**Authority:** Complete Combined Master Plan v3.0 (16 November 2026); five database data dictionaries; relationship specification; constraints/indexes/RLS; approved-design-decisions.md (all 13 decisions accepted); implementation-roadmap.md; existing schema blueprint and migration manifest.

## 1. Review outcome

The existing schema blueprint and migration manifest remain the design baseline. This review reconciles table names against the dictionaries, expands grouped optional-service/support/governance/SaaS entities to table-level review, and makes migration numbering safe to distinguish from the existing live migration history.

- Before correction, the five data-dictionary files contained 208 headings representing 207 distinct canonical names. The empty duplicate grade_levels heading has been removed; the current inventory is 207 headings and 207 distinct canonical names.
- The main schema blueprint had duplicated website_reusable_blocks and website_starter_templates rows. Those duplicate rows were removed.
- Canonical names from the dictionaries are used below and in the updated blueprint/manifest. Alias spellings are not new tables.
- All 13 accepted product/design decisions remain accepted. No product decision is reopened here.
- Exact FK columns, nullability, ON DELETE behavior, uniqueness, check constraints, and permission keys must still be reviewed against each dictionary and workflow before executable SQL is approved.

## 2. Canonical-name reconciliation

| Previous blueprint wording / gap | Canonical data-dictionary name | Resolution |
|---|---|---|
| student_transport_assignments | transport_assignments | Use dictionary name; references student_enrolments, transport_routes, transport_stops and optional guardian_student_links. |
| Transport group omitted stops/drivers | transport_stops; transport_drivers | Added separately; transport_route_stops remains the route/stop bridge. |
| document_records | documents | Canonical name. |
| retention_rules | document_retention_rules | Canonical name. |
| support_ticket_messages | ticket_messages | Canonical name. |
| support_ticket_assignments | ticket_assignments | Canonical name. |
| support_ticket_history | ticket_status_history | Canonical name. |
| Support group omitted categories/attachments | ticket_categories; ticket_attachments | Added separately. |
| file_metadata | files | Canonical name. |
| webhook_events | webhook_logs | Canonical name. |
| backup_inventory/recovery_events | backup_records | Canonical name; restore-test evidence is recorded here. |
| promotions | platform_promotions | Canonical name. |
| Promotion redemption not represented | promotion_redemptions (proposed) | Recommended ledger before promo application; dictionary entry and owner approval required. |
| login_activity absent | login_activity | Added as canonical operations/security table. |
| generic service_incidents | No generic table approved | Prefer domain-specific incident tables; defer generic polymorphic incident table. |

## 3. Supplemental entities not yet dictionary-authoritative

These proposals are not accepted table designs merely because they appear in the blueprint. Reconcile into dictionaries and approve or remove before SQL.

| Proposed entity | Why it may be needed | Proposed PK / tenant | Key relationships | Class | Gate |
|---|---|---|---|---|---|
| platform_settings | Typed platform configuration/version history | id UUID; global | Platform-owned config | P1/P3 | Confirm table vs versioned config service; secrets excluded. |
| platform_access_grants | Break-glass support access with scope, purpose, approval and expiry | id UUID; nullable school scope | Operator, school, approver, time range | P3 | Confirm grant model; mandatory audit/expiry; no standing unrestricted access. |
| enrolment_history | Lifecycle events beyond class-assignment history | id UUID; school_id | student_enrolments, actor, transition | P2 | Decide event table vs audit/event records. |
| admissions_conversion_log | Idempotent application-to-student/enrolment conversion | id UUID; school_id | application, converted student/enrolment, conversion key | P2 | Confirm canonical history and unique key; dictionary sync. |
| announcement_recipients | Durable resolved audience/delivery/read state | id UUID; school_id | announcement, user profile | P2 | Add only if audience materialization is needed; dictionary sync. |
| promotion_redemptions | Prevent duplicate/over-limit promo use and preserve redemption/reversal | id UUID; school_id | platform_promotions, subscription/invoice | P2 | Required before promo application; dictionary sync. |

School groups and school_group_memberships are already documented as future capability and are not a pilot dependency. A generic service_incidents polymorphic table is deferred unless a validated use case cannot be represented by domain-specific incidents.

## 4. Schema conventions and invariants

### 4.1 Primary keys and tenant keys
- Default entity PK: UUIDv4 named id. currency_definitions is the approved natural-key exception using currency_code. user_profiles.id equals the Auth user UUID.
- Every school-owned row has school_id UUID NOT NULL and UNIQUE(school_id,id) for tenant-safe composite references.
- Tenant-to-tenant FKs use (school_id, referenced_id) → (school_id,id). A nullable scoped FK still proves same-school scope when non-null.
- Global catalogues/platform-owned records have no school_id. XEN billing rows may reference school_id but remain platform-billing records with a distinct access boundary, not school-finance records.
- Global and tenant-customized rows have explicit ownership and scoped uniqueness. No implicit “NULL means global” rule without a matching constraint.

### 4.2 Foreign keys and deletion behavior
- Use explicit FKs/bridge tables for core relationships. Polymorphic type/id is permitted only for metadata/audit or validated owner references; it cannot replace core integrity.
- RESTRICT is default for students, guardians, enrolments, posted finance, audit, published snapshots, legal/restricted records and histories.
- SET NULL is limited to optional actor/reference fields where retained snapshots preserve accountability.
- CASCADE is limited to disposable draft/configuration children and requires table-specific review. No cascade may remove history.
- Every FK must be indexed directly or covered by an appropriate composite index.

### 4.3 Time and timezone
- Instants: timestamptz stored/handled in UTC.
- Date-only facts: date (DOB, term bounds, attendance date, due date, assignment effective date).
- IANA timezone is stored for school/campus/calendar/user context.
- Timetable periods use local wall-clock time plus calendar/campus timezone; schedule entries retain weekday and effective date/version. Daylight-saving and future-market recurrence rules require review.
- Append-only records use occurred_at/recorded_at/changed_at, not artificial mutable updated_at.

### 4.4 Money and currency
- Financial amounts are integer minor units plus a currency code; currency_definitions supplies precision/exponent. Do not assume two decimals for every currency.
- Exchange rates use numeric precision chosen and reviewed for the source; conversion snapshots retain source/target amounts/currencies, rate, source/time, rounding method, reason and approver/actor as required.
- Invoice, payment, allocation, receipt, credit, refund and journal lines retain currency; no implicit cross-currency aggregation or allocation.
- Posted financial records are immutable. Corrections use reversal, credit, adjustment or refund records.
- School finance and XEN SaaS billing are separate domains, permission keys, lifecycle, ledger and reporting. No FK from school invoices/payments to XEN subscription invoices/payments.

### 4.5 Status and enum strategy
- Use constrained text or lookup/config tables for school-customisable categories, grades, workflows and status values.
- Stable platform states may use CHECK constraints or PostgreSQL enum only after migration-impact review. Avoid enums for tenant-configurable values.
- Each stateful table has an explicit allowed-state list, transition authority, transition validation, history and terminal/reopen behavior. Never accept arbitrary status strings.
- Append-only transition history is required for admissions, enrolments, attendance corrections, marks moderation, finance posting/reversal, guardian verification/restrictions, publication, support status, subscriptions, access grants and consent changes.

### 4.6 Classification

| Class | Example | Required control |
|---|---|---|
| P0 Public-approved | Current published school page, approved public event/contact, approved public media | Safe public projection only; publication/withdrawal/cache invalidation |
| P1 Internal | School settings, class/subject catalogues, operational configuration | Authenticated role/scope; no anonymous access |
| P2 Personal | Student/guardian/staff records, attendance, marks, admissions, messages, documents | Least privilege, relationship filtering, audit/export controls |
| P3 Restricted | Health, safeguarding, custody/legal, bursary, bank details, restricted HR, access/security logs | Separate tables/schema/permissions, need-to-know, reasoned audit; no broad search/export/portal |
| P4 Secret | Credentials, tokens, keys, signed URLs | Secret manager or ephemeral delivery only; never repository/log/plain DB field |

## 5. Table-level supplement for grouped entities

The main schema-blueprint Sections 4A–4H and 4K–4L retain table-by-table details for platform, people, academics, attendance, admissions, core finance, CMS, communications, XEN billing and restricted health/safeguarding. The rows below expand optional-service, document, support and operations entities previously compressed into group summaries. All school-owned rows use school_id and tenant-safe composite FK patterns unless a documented global exception is stated.

### 5.1 Library

| Table | PK / tenant | FKs / dependencies | Constraints / indexes | Class / lifecycle | RLS intent |
|---|---|---|---|---|
| library_categories | id UUID / school_id | parent category self-FK | unique school/code; parent index; prevent cycles | P1; active/inactive | Librarian/admin |
| library_books | id / school_id | category; optional cover files | school/title/ISBN search; ISBN nullable | P1; catalogued/active/retired | Librarian; safe catalogue view |
| library_book_copies | id / school_id | book; optional campus | unique school/accession | P1; available/on-loan/reserved/lost/repair/retired | Librarian |
| library_loans | id / school_id | copy; exactly one student/staff borrower; issuer | one active loan/copy; due/renewal checks; copy/borrower/due indexes | P2; issued/overdue/returned/cancelled | Librarian; borrower own limited |
| library_reservations | id / school_id | book; exactly one student/staff requester; fulfilled copy | active reservation uniqueness policy; expiry/status index | P2; requested/queued/ready/fulfilled/cancelled/expired | Librarian; requester own |
| library_fines | id / school_id | loan; exact amount/currency; waiver approver | amount_minor + currency; waiver reason; loan/status index | P2/P3; assessed/waived/paid/void | Librarian/finance split |

### 5.2 Transport

| Table | PK / tenant | FKs / dependencies | Constraints / indexes | Class / lifecycle | RLS intent |
|---|---|---|---|---|---|
| transport_vehicles | id / school_id | campus optional | unique registration; capacity > 0; inspection/insurance due indexes | P2; active/maintenance/inactive/retired | Transport manager |
| transport_routes | id / school_id | academic_year optional; vehicle; transport_drivers | unique route_code/year; route/status/time indexes | P1/P2; draft/active/paused/retired | Transport scope |
| transport_stops | id / school_id | location fields | coordinate validation; location index review | P2/P3; active/inactive | Transport; coordinates/safe-pickup notes restricted |
| transport_route_stops | id / school_id | route; stop | unique route/sequence; same tenant; planned time | P2; route-version scoped | Transport |
| transport_drivers | id / school_id | optional staff | staff same tenant; encrypted licence; expiry/status index | P3; active/inactive/suspended | Transport/HR split |
| transport_assignments | id / school_id | enrolment; route; stop; optional guardian link | stop must belong to route; date overlap; route/stop/enrolment/status indexes | P2; planned/active/ended/cancelled | Transport; guardian own child only |
| transport_incidents | id / school_id | optional route/vehicle/student | incident time/type; restricted narrative; resolution audit | P3; reported/investigating/resolved/closed | Designated safety staff |

### 5.3 Boarding, meals, clubs, activities and trips

| Table | PK / tenant | FKs / dependencies | Constraints / indexes | Class / lifecycle | RLS intent |
|---|---|---|---|---|---|
| boarding_houses | id / school_id | campus optional | unique house_code; capacity nonnegative | P1/P2; active/inactive | Boarding admin |
| boarding_rooms | id / school_id | house | unique house/room_code; capacity nonnegative | P1/P2; active/inactive | Boarding staff |
| boarding_assignments | id / school_id | enrolment; room | same school; date overlap and capacity checks; student/room/date indexes | P2; planned/active/ended/cancelled | Boarding staff; guardian permitted view only |
| meal_plans | id / school_id | none | plan code; price_minor/currency; effective dates | P1; draft/active/retired | Catering/finance split |
| meal_orders | id / school_id | enrolment; meal plan | eligible plan/date; order-status index; restricted dietary notes | P2/P3; pending/confirmed/cancelled/served | Catering; dietary notes restricted |
| meal_attendance | id / school_id | order optional; enrolment | unique enrolment/date/meal type per policy | P2; present/absent/late/other | Catering scope |
| clubs | id / school_id | staff lead optional | unique club code; capacity; status index | P1; active/inactive | Activity admin |
| activities | id / school_id | lead staff optional | start/end valid; capacity; permission flag; date/status index | P2; planned/open/completed/cancelled | Activity staff |
| activity_memberships | id / school_id | activity; enrolment | unique active activity/enrolment; consent/capacity/date checks | P2; pending/active/ended/cancelled | Activity staff; guardian own child |
| trips | id / school_id | lead staff | date range; status and date indexes | P2; planned/open/completed/cancelled | Trip lead |
| trip_permissions | id / school_id | trip; enrolment; guardian link; optional evidence file | verified authority; one active decision per trip/enrolment/version | P3; pending/approved/declined/revoked | Trip lead; guardian own permission |
| trip_attendance | id / school_id | trip; enrolment | unique trip/enrolment; check-in time | P2/P3; present/absent/late/other | Trip lead; restricted notes |

### 5.4 Documents and retention

| Table | PK / tenant | FKs / dependencies | Constraints / indexes | Class / lifecycle | RLS intent |
|---|---|---|---|---|---|
| document_categories | id / school_id | retention rule optional | unique school/code; sensitivity/category index | P1; active/inactive | Document admin |
| documents | id / school_id | category; files; validated typed owner reference | classification/status; category/owner/status indexes; no unchecked polymorphic FK | P2/P3; draft/active/archived/expired | Explicit permission; restricted categories separate |
| document_versions | id / school_id | document; files | unique document/version; checksum and scan status | P2/P3; uploaded/quarantined/clean/rejected/archived | Authorized readers; quarantine denied |
| document_permissions | id / school_id | document; principal/scope | validity range; no public grant for restricted | P3; active/expired/revoked | Grantor authorized; no self-grant |
| document_access_logs | id / school_id | document; user | append-only; document/time and actor/time indexes | P3 | Security/audit readers |
| document_retention_rules | id / school_id | category optional | retention days/action; legal hold overrides deletion; category index | P3; active/reviewed/retired | Privacy/compliance |

### 5.5 Service desk

| Table | PK / tenant | FKs / dependencies | Constraints / indexes | Class / lifecycle | RLS intent |
|---|---|---|---|---|---|
| support_tickets | id UUID / school_id | requester profile or guardian; category | unique ticket number; status/priority/assignee indexes | P2/P3; new/open/in-progress/waiting/resolved/closed | Requester + assigned support |
| ticket_categories | id / school_id | school category | unique scope/code; default priority; active index | P1; active/inactive | Support admin |
| ticket_messages | id / school_id | ticket; sender profile | requester/internal visibility; ticket/time index | P2/P3 | Internal notes never requester-visible |
| ticket_assignments | id / school_id | ticket; assignee/grantor | assignment interval history; ticket/assignee indexes | P2; assigned/unassigned | Support |
| ticket_attachments | id / school_id | ticket/message/files | scan-clean requirement; visibility checks | P2/P3 | Requester-visible only when authorized |
| ticket_status_history | id / school_id | ticket; actor | append-only; ticket/time index | P2/P3; transition history | Support and requester-safe projection |

### 5.6 XEN SaaS billing (platform billing, not school finance)

| Table | PK / tenant | FKs / dependencies | Constraints / indexes | Class / lifecycle | RLS intent |
|---|---|---|---|---|---|
| subscription_plans | id UUID / global | none | unique plan_key/version; effective price snapshot | P1; draft/active/retired | Platform commercial admin; safe catalog projection |
| subscription_features | id / global | plan | unique plan/feature; quota/config validated | P1 | Platform billing admin |
| billing_customers | id / school_id | school; provider/customer reference | unique provider/customer; encrypted tax identifier | P2 | XEN billing; school own view only |
| school_subscriptions | id / school_id | school; plan | contract snapshot; period checks; status history | P2; trial/active/past_due/grace/suspended/cancelled/expired | XEN billing; tenant own subscription view |
| subscription_items | id / school_id | subscription | feature/quantity/price/currency snapshot; effective range | P2; active/ended | Billing |
| subscription_invoices | id / school_id | subscription | unique invoice number; exact totals; immutable posted | P2; draft/issued/paid/overdue/void | XEN billing only |
| subscription_payments | id / school_id | invoice | provider ref/idempotency; verified state; amount/currency | P2; pending/verified/failed/reversed/refunded | XEN billing only |
| subscription_events | id / school_id | subscription | append-only state transition | P2/P3; event history | Billing audit |
| usage_records | id / school_id | feature/period | dedupe key unique; usage indexes | P2; recorded/aggregated | Billing and tenant usage view |
| platform_promotions | id UUID / global | none | promo_code unique; validity/limits/value/currency checks | P1; draft/active/expired/suspended | Platform commercial admin |
| promotion_redemptions (proposed) | id UUID / school_id | promotion; subscription/invoice | unique redemption/idempotency; limit/reversal rules | P2; pending/redeemed/reversed | XEN billing; tenant own history |

### 5.7 Security, governance, jobs, webhooks, backups and files

| Table | PK / tenant | FKs / dependencies | Constraints / indexes | Class / lifecycle | RLS intent |
|---|---|---|---|---|---|
| audit_logs | id UUID / nullable school_id | actor/profile; typed resource reference | append-only; school/time, actor/time, resource indexes | P3; immutable | Audit readers; writer service only |
| security_events | id / nullable school_id | user/profile optional | severity/type/time; sanitized metadata | P3; open/triaged/resolved | Security operators |
| login_activity | id / nullable school_id | user/profile optional | time/result/method; IP hash only; retention | P3; success/failure/challenge | Security access only |
| data_export_requests | id / school_id | requester; optional files | identity verification, scope, expiry/approval | P3; submitted/verified/approved/processing/completed/failed/rejected/expired | Privacy admin; requester status only |
| data_deletion_requests | id / nullable school_id | requester; typed subject | legal hold/retention review and outcome | P3; submitted/verified/review/approved/held/completed/rejected | Privacy admin |
| consent_records | id / school_id | validated typed subject; optional evidence file | purpose/policy version; grant/withdraw dates | P2/P3; granted/withdrawn/expired | Privacy role; subject/guardian view where lawful |
| system_jobs | id UUID / nullable school_id | workflow refs validated | idempotency key; job type/status/time indexes | P3; queued/running/succeeded/failed/cancelled | Operations |
| job_failures | id UUID / nullable school_id | system_job | sanitized error; retryable/attempt number | P3; retryable/resolved | Operations |
| webhook_logs | id UUID / nullable school_id | provider event; domain event optional | unique provider/event ID; signature/dedupe | P3; received/verified/processed/failed | Integration operators |
| backup_records | id UUID / global | environment/storage reference | checksum, retention, completion and restore-test evidence | P3; pending/running/completed/failed/restore-tested/expired | Operations/security |
| files | id UUID / nullable school_id | uploader profile; validated owner metadata | unique provider/bucket/object key; size/MIME/checksum; scan/classification/status indexes | P2/P3; uploaded/quarantined/scanning/clean/rejected/archived/deleted | Metadata RLS + private storage policy; approved public projection only |

## 6. Tenant and RLS policy intent

- Resolve school context from authenticated identity + active membership + permission/scope; never trust a client-provided school_id alone.
- Tenant-owned table policy checks school_id plus membership/permission and optional campus/class/subject/department/assignment scope.
- Platform-global tables use platform roles or allow-listed safe reads. Tenant customization is explicitly scoped.
- Platform-billing tables reference schools but are protected by platform billing roles; a school owner may read only its own subscription/billing projection.
- Guardian access requires an active, verified, in-date guardian_student_link, per-link permission for the record category, and no overriding custody/legal restriction. Emergency/pickup permission is not portal permission.
- Student access is own-record only, verified and feature-enabled, and only approved/published fields.
- Public CMS access is through a dedicated safe projection/API for current approved published versions and approved public assets. Base authoring, form submissions, private file metadata and learner/finance/restricted tables are denied to anonymous.
- Restricted health/safeguarding/custody/legal/bursary/bank records have separate permissions and, where appropriate, private schemas. Access is purpose-bound and audited. Ordinary student/staff roles do not inherit restricted access.
- Files: metadata RLS and storage access both enforce tenant/classification/scan status. Signed URLs are short-lived; no durable signed URL field.
- Audit and histories are append-only; users cannot update/delete their own events. Platform support access is scoped, time-bound, approved and logged.
- Separate SELECT/INSERT/UPDATE/DELETE policies and API checks. Deny by default; service-role bypass is not evidence of RLS correctness.

### Security role matrix

| Role | Default allowed scope | Sensitive exclusions / control |
|---|---|---|
| XEN platform administrator | Platform configuration, tenant lifecycle, plan catalog, operations | No routine unrestricted P2/P3 school data; privileged access requires scope, purpose, approval, expiry and audit |
| XEN support/operator | Assigned tickets, safe diagnostics and tenant metadata | No finance, HR, health, safeguarding, custody/legal or raw learner data without approved access grant |
| School owner | School settings, membership/role admin, module configuration and oversight | Cannot bypass legal restrictions, immutable records or approval separation; no self-escalation |
| School administrator | Operational records in granted school/campus scope | Restricted finance/HR/health/safeguarding/legal require separate permissions |
| Principal/head/deputy | Academic/attendance, approved operational reports, designated approvals | Restricted health/legal/finance only when specifically authorized; actions audited |
| Registrar | Students, enrolments, transfers, class assignments, admissions conversion | Guardian legal documents, health, safeguarding and finance are separate |
| Admissions officer | Campaigns, applications, reviews, interviews, offers and conversion | No unrelated student records, finance ledger, health or HR |
| Bursar | Fee setup, invoices, payments, allocations, receipts, arrears, approved refunds | No XEN SaaS billing; sensitive bursary/bank data and approvals segregated |
| Accountant/auditor | School finance/accounting within assigned scope; auditor may be read-only | School-finance only; XEN billing separate; posting/approval segregation |
| Teacher/class teacher | Assigned class/subjects, attendance, marks, class communication | No unrelated classes, HR, finance, legal/medical or safeguarding by default |
| HR officer | Staff, employment, qualifications, leave and restricted HR records | Student data and finance only if separately granted |
| Website editor/publisher | Private CMS authoring, approved assets, publishing workflow | No private student/guardian/finance/health records; publication only approved projection |
| Health/nurse | Minimum necessary health records, visits and medication workflow | No safeguarding case access unless separately assigned; guardian exposure controlled |
| Safeguarding lead/case team | Assigned cases, referrals and plans | Need-to-know, reason audit, legal/privacy review; no broad export/search |
| Librarian | Library catalogue, copies, loans and fines | Borrower profile limited; no other sensitive learner data |
| Transport/boarding/catering staff | Assigned routes, vehicles, boarding/meal assignments | Medical/sensitive notes only through explicit minimum-necessary emergency workflow |
| Guardian | Verified linked child and permitted fields/features | Active link, flags, legal restriction, time scope; immediate revocation |
| Student | Own record and enabled/published portal data | No peers, staff notes, restricted records, finance unless approved |
| Privacy/security reviewer | Approved governance/access/audit scope | Purpose-bound; no blanket operational rights |

## 7. Canonical entity inventory by logical migration group

These are dependency group labels, not actual migration filenames. Core table-by-table details remain in schema-blueprint.md and dictionaries; this supplement expands grouped rows.

| Logical group | Canonical entities | Depends on |
|---|---|---|
| D01 conventions/reference | currency_definitions; UUID/time/money/reference conventions; approved extension inventory | Design freeze |
| D02 tenant root | schools; school_campuses; school_groups and school_group_memberships (future); platform_settings (proposed) | D01 |
| D03 identity | user_profiles; school_memberships | D02; Auth |
| D04 authorization/audit | roles; permissions; role_permissions; membership_roles; platform_roles; audit_logs; security_events; login_activity; platform_access_grants (proposed) | D03 |
| D05 files | files | D02–D04 |
| D06 people/HR | students; guardians; guardian_student_links; student_emergency_contacts; guardian_access_restrictions; student_enrolments; staff; staff_employment; staff_qualifications; staff_documents; staff_departments; staff_department_memberships; teacher_assignments; enrolment_history (proposed) | D04–D05 |
| D07 academics/calendar/timetable | academic_programmes; academic_calendars; academic_years; academic_terms; calendar_events; timetable_periods; school_rooms; timetables; timetable_entries; timetable_exceptions; grade_levels; classes; class_streams; subjects; class_subjects; student_class_assignments | D06 |
| D08 attendance | attendance_sessions; attendance_records; attendance_corrections; attendance_notifications | D07 |
| D09 assessment/results | assessment_categories; grading_schemes; grading_scheme_versions; promotion_rules; report_card_templates; grading_scale_items; assessment_periods; assessments; assessment_components; student_marks; mark_moderation; student_results; report_cards; report_card_items | D07; D08 optional |
| D10 admissions | admission_campaigns; admission_applications; admission_applicants; admission_guardians; admission_documents; admission_reviews; admission_interviews; admission_offers; admission_status_history; admission_fee_settings; admission_application_fee_snapshots; admission_payments; admission_payment_refunds; admissions_conversion_log (proposed) | D05–D07 |
| D11 school-finance core | fee_categories; fee_structures; fee_structure_items; fee_assignments; invoices; invoice_items; payment_methods; payments; payment_allocations; receipts | D05–D07 |
| D12 websites/CMS | school_websites; website_themes; website_pages; website_page_versions; website_sections; website_components; website_reusable_blocks; website_starter_templates; website_navigation; website_media; website_articles; website_events; website_domains; website_translations; website_publications; website_seo_settings; website_forms; website_form_submissions | D02; D04–D05 |
| D13 portals/communications | portal_preferences; portal_notifications; portal_access_logs; portal_device_tokens; announcements; announcement_recipients (proposed); message_threads; messages; message_read_receipts; message_recipients; message_attachments; message_moderation_actions; notification_templates; notification_deliveries; notification_preferences; communication_provider_logs | D04–D12 |
| D14 advanced school finance | fee_discounts; student_bursaries; invoice_adjustments; credit_notes; refunds; refund_approvals; unallocated_credits; bank_accounts; bank_statement_imports; bank_statement_entries; reconciliation_matches; chart_of_accounts; accounting_periods; journal_entries; journal_lines; expenses; expense_categories; suppliers; purchase_requests; budgets; budget_items; financial_approvals; exchange_rates; currency_conversion_snapshots | D11 |
| D15 restricted health/safeguarding | student_health_profiles; student_health_conditions; student_allergies; health_visits; medication_records; medication_administration_events; safeguarding_incidents; safeguarding_referrals; safeguarding_action_plans; restricted_record_access_logs | D04–D06; D05 files |
| D16 optional services | library_categories; library_books; library_book_copies; library_loans; library_reservations; library_fines; transport_vehicles; transport_routes; transport_stops; transport_route_stops; transport_drivers; transport_assignments; transport_incidents; boarding_houses; boarding_rooms; boarding_assignments; meal_plans; meal_orders; meal_attendance; clubs; activities; activity_memberships; trips; trip_permissions; trip_attendance | D05–D08; D11 optional |
| D17 XEN SaaS billing | subscription_plans; subscription_features; billing_customers; school_subscriptions; subscription_items; subscription_invoices; subscription_payments; subscription_events; usage_records; platform_promotions; promotion_redemptions (proposed) | D02; D04 |
| D18 documents/support/governance | document_categories; documents; document_versions; document_permissions; document_access_logs; document_retention_rules; support_tickets; ticket_categories; ticket_messages; ticket_assignments; ticket_attachments; ticket_status_history; data_export_requests; data_deletion_requests; consent_records; system_jobs; job_failures; webhook_logs; backup_records | D04–D17; D05 |
| D19 localization/region | Country/locale/jurisdiction configuration and translation catalogues; exact entity inventory to be approved | D02; configurable domains |

## 8. Migration and acceptance gates

No D01–D19 label is an actual migration filename or applied database version. Before an actual migration is created, review exact table/column names, FK columns/delete actions, unique/check constraints, tenant composite FKs, indexes, classification, lifecycle, grants/RLS, API exposure, backfill, tests and rollback/forward-fix.

1. Scope/name reconciliation: canonical names match dictionaries; proposed extras approved or removed; no duplicate tables/aliases.
2. Baseline reconciliation: compare target design to live 209-table scaffold and 13 applied migration-history entries; resolve normalized tables vs JSONB placeholders; source exact applied SQL and validate clean replay.
3. Migration integrity: replay from empty; upgrade from supported baseline; schema diff; rollback/forward-fix.
4. Tenant security: A/B tenant read/write/delete, guessed UUIDs, joins, views/RPC, campus/class/subject scope, revoked membership and role changes.
5. RLS: normal application roles; anonymous, guardian, student, teacher, finance, platform/support and restricted roles; never test only as owner/service role.
6. Workflow/state: transition matrix, invalid transitions, idempotency, concurrency, locks and append-only history.
7. Public/private segregation: anonymous only current approved projection; drafts/unpublished content, private submissions/files, unverified domains and private student/restricted data denied; unpublish/cache invalidation verified.
8. Guardian/child privacy: active verified link, per-child permission, legal restriction, emergency-contact distinction, revocation and field filtering.
9. Finance integrity: exact arithmetic/rounding, currency, invoice totals, payment verification, allocation caps, receipt, refund cap/approval, balanced journal, closed-period lock and finance-domain separation.
10. Restricted data: no health/safeguarding/legal/bursary/bank detail in standard profile/search, portal, public projection, notification, export or logs; reasoned access audit.
11. File security: scan/quarantine, tenant object keys, MIME/size/checksum, signed URL expiry, consent/public approval, legal hold and deletion.
12. Performance: representative tenant sizes, query plans, FK/index coverage, pagination, reports, exports and public cache.
13. Recovery/operations: backup restore, integrity checks, RPO/RTO evidence, incident process, migration window, monitoring and access review.
14. Domain validation: pilot review for academic calendar, grading, timetable, admissions, Zimbabwe fees/currency, reporting, legal/privacy, health/safeguarding and support.
15. Owner gate: product owner accepts scope, evidence, risks and release boundary.

## 9. Unresolved technical and operational decisions

The 13 product decisions are accepted. Remaining gates:

- Live-schema reconciliation: 209 public tables, 13 applied migration records, only the verified school-owner provisioning SQL currently mirrored as an authored migration; reconstructed snapshot is not a clean replay. Exact history source, baseline diff and replay validation required.
- Database version/extensions, project region/tier, API exposure, pooling, quotas, cost and performance.
- Schema namespace names, grants, role/JWT claims, tenant-context helper, RLS implementation and exact permission keys.
- Concrete FK actions, nullability, constraints for each table, cycle resolution and supplemental-table approval.
- Timetable local-time, recurrence, daylight-saving and calendar-overlap rules.
- Currency precision/rounding, exchange-rate source/approval, accounting rules and current Zimbabwe currency/tender configuration.
- Payment provider sequence, merchant/API availability, callback signature verification, refunds, settlement and reconciliation.
- Subscription pricing, entitlements/limits, grace/suspension, promotion rules and redemption ledger.
- Storage provider, scanning/quarantine, signed access, lifecycle, encryption, independent backup and restore.
- Privacy/legal review: child-data purpose/consent, retention, residency/cross-border, legal holds, deletion/anonymisation, school contracts and jurisdiction compliance.
- Restricted health/safeguarding/custody/legal fields, designated roles, access reason, case workflow and reviewers.
- Public domains, SSL, tenant routing, cache invalidation, content approval, media rights/consent and analytics minimization.
- Pilot scope, acceptance, import, training, support, RPO/RTO, monitoring, incident response and cost.

## 10. Approval boundary

This review is documentation only. It does not create or modify application code, SQL migrations, executable schema, seed data, CI workflows, infrastructure or deployment. Existing bootstrap and repository artifacts remain governed by live-project-bootstrap-status.md. The logical schema remains proposed and must pass the review gates before implementation.
