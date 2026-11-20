# Schema Blueprint — XEN SCHOOL MANAGEMENT v3.0

**Status:** Documentation proposal for review; not implemented. **Scope:** PostgreSQL logical design, tenant isolation, classification and policy intent. This document is subordinate to the Complete Combined Master Plan v3.0, data dictionaries, relationship specification, constraints/RLS specification, all 13 accepted decisions, and implementation roadmap. It does not authorize SQL or code.

## 1. Architectural rules

- PostgreSQL is the relational system of record. Authentication identity is managed by the selected auth provider (currently proposed Supabase Auth); do not duplicate passwords, tokens or credential secrets.
- A school is the tenant. Tenant-owned rows carry non-null `school_id`. Campus, class, subject and other narrower scope are additive—not substitutes for tenant isolation.
- Each tenant-owned table should expose a unique `(school_id,id)` key for composite tenant-safe references. FK relationships between tenant rows should use `(school_id, referenced_id)` to prevent cross-school links. Platform/global tables use ordinary FKs and explicit scope checks.
- UUIDv4 or UUIDv7 is proposed for identifiers; final selection is an open technical decision. Use opaque IDs and do not encode personal data.
- Default columns: `id uuid`, `created_at timestamptz`, `updated_at timestamptz`. Use `created_by`/`updated_by` where accountable actions require. Append-only events/history use `occurred_at` or `recorded_at` and actor fields; no misleading updated timestamp.
- Store instants as UTC `timestamptz`; display and schedule according to school, campus, user, or event timezone explicitly. Keep timezone as IANA name. Date-only facts (DOB, term dates, due dates, attendance date) use `date`. Avoid local timestamp without timezone.
- Use exact monetary amounts: integer minor units (e.g. cents) plus ISO 4217 currency code; no float/double. Amount precision, rounding, currencies without 2 decimal places, exchange rate precision and conversion approval must be specified. A conversion record must retain source/target currency, rate, rate timestamp/source, original and converted amounts, and who approved/used it.
- Enum-like data: use constrained text or lookup/config tables for school-configurable values. Stable platform state values can use checked text or PostgreSQL enums only if future expansion/migration impact is accepted. Do not use enums for tenant-customisable grades, categories, statuses or workflows. State transitions must be explicitly validated and audited.
- Tenant settings/config JSONB is for validated configuration only, not relational facts, access rules, money ledgers or secrets. Version schemas for dynamic forms and CMS component props.
- Use soft deletion only for reversible business records where lifecycle supports it; prefer status/end dates. Never delete/soft-delete to conceal posted finance, published snapshots, audit or legal history. Retention/anonymisation is governed by policy and legal hold.
- Files are metadata in DB; bytes in private object storage. Use opaque object keys, scan/quarantine, explicit classification, signed short-lived access and retention. Public assets must be separately approved.
- Every migration must be small, reviewed, repeatable, tested from empty DB and supported upgrade path, with rollback or forward-fix plan.

## 2. Key strategy and tenant-safe relationship pattern

For each tenant table:
1. `id` is PK.
2. Unique `(school_id,id)` is present (may be redundant physically but supports composite FK).
3. FKs to another tenant table use `(school_id,other_id)`.
4. School-local natural keys are unique with school scope (e.g. `(school_id,student_number)`).
5. Use `school_id` first in tenant query indexes; include FK columns and common filters.
6. Nullable campus/scope FKs must still prove same tenant when set.
7. Cross-domain relationships must use typed references or validated relation tables; do not create arbitrary unchecked polymorphic IDs for core integrity.

Global tables (permissions, platform catalogues, auth identities, system plans) may have no school_id. Where a table supports global and tenant customisation, document whether `school_id IS NULL` means platform-owned and enforce uniqueness appropriately.

## 3. Data classification

| Class | Meaning | Handling |
|---|---|---|
| P0 Public-approved | Public website content, approved public contact, verified public domain | Public API/read model only; publication and unpublish control |
| P1 Internal | Operational configuration, class/subject catalogs, internal service metadata | Authenticated school staff with permission; never anonymous |
| P2 Personal | Student, guardian, staff, attendance, marks, admissions, messages, documents | Least privilege; guardian/student field filtering; encryption where appropriate; audit/export controls |
| P3 Restricted | Medical, safeguarding, custody/legal orders, bursaries, financial account details, identity data, sensitive admissions/HR notes | Separate tables/permission keys; need-to-know; elevated audit; no broad search/export/portal exposure |
| P4 Secret/credential | Provider secrets, tokens, private keys, auth credentials | Secret manager only; never DB plain text, logs or repository |

Classify each row and sensitive field. Public website content must never be populated from private school records by an implicit join. Public content uses an explicitly approved publication record and a safe public projection.

## 4. Table-by-table blueprint

### A. Platform, tenant, identity and access (foundation)

| Table | PK | Tenant key | Key FKs / constraints / indexes | Class / lifecycle | RLS intent |
|---|---|---|---|---|
| schools | id | tenant root | slug unique; country/currency/timezone valid; status checked | P1; onboarding/trial/active/suspended/closed | Platform provisioning; school users only own safe settings |
| school_campuses | id | school_id | FK school; unique school/code; primary-campus rule | P1; active/inactive | Membership + campus scope |
| user_profiles | id (= auth user) | none | FK auth identity; locale/timezone validated | P2; profile active/deactivated | Self access; scoped school admins limited fields |
| school_memberships | id | school_id | FK school + profile; unique active school/user; invited_by | P2; invited/active/suspended/ended | User self-view; school admin manages only authorized members |
| roles | id | nullable school_id | global or tenant-owned; key unique within scope; scope constrained | P1; active/inactive | Platform roles protected; school role administration permission |
| permissions | id | none | stable unique key | P1 | Platform-managed read |
| role_permissions | id | role_id scope | FK role/permission; unique pair | P1 | Role-admin only |
| membership_roles | id | school_id | membership, role, campus/scope IDs tenant-safe; validity range | P2 | Grantor permission; cannot self-escalate |
| platform_roles | id | none | profile/role; valid period; grant/revoke audited | P3 | Only authorized platform security admins |
| platform_settings | id/key | none | unique key; typed/versioned values | P1/P3 by setting | Platform admin; secrets excluded |
| audit_logs | id | nullable school_id | actor, event, resource, timestamp; append-only | P3 | Audit readers; append-only service |
| security_events | id | nullable school_id | event type, severity, actor/target, safe metadata | P3 | Security operators, append-only |
| consent_records | id | school_id nullable | subject type/id validation; consent version/purpose/scope; withdrawal | P2/P3 | Subject/guardian where lawful; privacy staff |
| platform_access_grants | id | nullable school_id | operator, purpose, scope, start/end, approval | P3 | Explicit time-bound support access; every use audited |

### B. People, guardians, enrolment and HR

| Table | PK | Tenant key | Key FKs / constraints / indexes | Class / lifecycle | RLS intent |
|---|---|---|---|---|---|
| students | id | school_id | unique student number; status and admission/leaving dates | P2; applicant/enrolled/withdrawn/graduated/archived | Staff permission; guardian/student filtered |
| guardians | id | school_id | optional profile FK; contact validation; unique identifiers only when required | P2 | Relationship-based guardian; staff permissions |
| guardian_student_links | id | school_id | guardian/student composite FKs; verified state; validity; unique active pair | P2/P3 | Guardian can see only active verified links and per-link flags |
| guardian_access_restrictions | id | school_id | student/link/person; restriction scope; verified legal-order metadata; dates/review | P3; active/reviewed/expired | Legal/privacy designated roles only; enforced by authorization service |
| student_emergency_contacts | id | school_id | student; contact priority; verified contact/pick-up scope; validity | P2/P3 | Staff; emergency contact only where necessary |
| student_enrolments | id | school_id | student/year/calendar/program; primary enrolment rule; dates/status; controlled multiple enrolments | P2; pending/active/paused/transferred/completed/withdrawn | Registrar/admin; guardian limited |
| staff | id | school_id | unique staff number; optional profile; status | P2/P3 | HR + assigned operational roles |
| staff_employment | id | school_id | staff, department, supervisor composite FKs; date ranges | P3; draft/active/ended | HR restricted |
| staff_qualifications | id | school_id | staff/document FK; verification status | P3 | HR only |
| staff_documents | id | school_id | staff/file FK; expiry; verification | P3 | HR/authorized supervisor |
| staff_departments | id | school_id | unique code; head staff FK | P1/P2 | Staff administration |
| staff_department_memberships | id | school_id | staff/department; valid period | P2 | HR/admin |
| teacher_assignments | id | school_id | staff/class/subject/year; scope and date checks | P2 | Teacher and academic admins scoped |
| enrolment_history/events | id | school_id | enrolment FK; transition/event; actor; before/after safe snapshot | P2 | Registrar; append-only |

### C. Academics and flexible calendar

| Table | PK | Tenant key | Key FKs / constraints / indexes | Class / lifecycle | RLS intent |
|---|---|---|---|---|---|
| academic_calendars | id | school_id | unique calendar code; campus/program applicability | P1; active/retired | Academic admin |
| academic_years | id | school_id | calendar FK; valid range; current uniqueness per calendar | P1; planned/open/closed | Academic admin |
| academic_terms | id | school_id | year/calendar FK; date range; overlap allowed per calendar rules | P1; planned/open/closed | Academic admin |
| calendar_events/holidays | id | school_id | calendar/campus; date or range; event type; school-day/visibility | P1 | Academic admin; public only if published |
| timetable_periods | id | school_id | calendar/campus; local start/end; ordered period | P1 | Academic admin |
| school_rooms | id | school_id | campus/room code/capacity; active state | P1 | Campus/scheduling admins |
| timetables | id | school_id | year/calendar/campus; version/effective dates/status | P1/P2; draft/approved/published/retired | Academic admin; published view only |
| timetable_entries | id | school_id | timetable/class-subject/teacher/room/period/day; clash constraints | P2 | Assigned staff and class scope |
| timetable_exceptions | id | school_id | timetable entry/date; cancellation or move; approval | P2/P3 | Academic admin and affected staff |
| grade_levels | id | school_id | unique code; stage/sort/age range | P1 | Academic admin |
| classes | id | school_id | year/grade/campus; unique code per year; capacity | P1 | Class scope |
| class_streams | id | school_id | class FK; unique code/class; capacity | P1 | Class scope |
| subjects | id | school_id | unique code; active | P1 | Academic admin |
| class_subjects | id | school_id | class/subject/year/stream; unique teaching offering | P1/P2 | Teacher/class scope |
| student_class_assignments | id | school_id | enrolment/class/stream; valid period; prevent conflicting active assignments | P2; active/ended | Class staff and registrar |
| grading_schemes | id | school_id | optional grade/subject/year; calculation version; default uniqueness | P1 | Academic admin |
| grading_scale_items | id | school_id | scheme FK; boundary range/no overlaps; code unique | P1 | Academic admin |
| assessment_periods | id | school_id | year/term/calendar; valid dates | P1 | Academic admin |
| assessments | id | school_id | period/class_subject/scheme; max score >0; weights rules | P2; draft/open/submitted/moderated/approved/published/archived | Teacher assignment; approval workflow |
| assessment_components | id | school_id | assessment FK; max/weight; component order | P2 | Assigned teacher |
| student_marks | id | school_id | assessment/student/component; unique tuple; score bounds or approved absent code | P2 | Assigned teacher; learner/guardian published projection |
| mark_moderation | id | school_id | mark FK; decision, reason, old/new score; append-only | P2/P3 | Moderator, not mark author where separation required |
| student_results | id | school_id | assessment/student; unique; calculation version; approved/published snapshots | P2 | Academic staff; portal published-only |
| report_cards | id | school_id | enrolment/year/term/type unique; snapshot/version; file FK | P2 | Staff; guardian/student published-only |
| report_card_items | id | school_id | report FK/subject; snapshot, ordering | P2 | Parent/student restricted projection |

### D. Attendance

| Table | PK | Tenant key | Key FKs / constraints / indexes | Class / lifecycle | RLS intent |
|---|---|---|---|---|---|
| attendance_sessions | id | school_id | class/stream/year/term; unique date/type/period/scope | P2; draft/submitted/approved/locked | Teacher/class scope |
| attendance_records | id | school_id | session/student; unique; status constrained; late mins nonnegative | P2 | Teacher scope; guardian own linked child published/approved |
| attendance_corrections | id | school_id | record FK; old/new/reason/review; append-only | P2/P3 | Authorized reviewer |
| attendance_notifications | id | school_id | record/guardian; delivery idempotency; minimal payload | P2 | Staff limited; guardian own; delivery service |

### E. Admissions

| Table | PK | Tenant key | Key FKs / constraints / indexes | Class / lifecycle | RLS intent |
|---|---|---|---|---|---|
| admission_campaigns | id | school_id | year/calendar/grade; opening/closing; fee config; schema version | P1/P2; draft/published/open/closed/archived | Admissions staff; public safe campaign projection |
| admission_applications | id | school_id | campaign; unique reference; status transition; converted student unique/idempotent | P2; draft/submitted/review/interview/offered/accepted/rejected/withdrawn/converted | Assigned admissions staff; applicant self-service only |
| admission_applicants | id | school_id | application FK; typed applicant role | P2 | Application scope |
| admission_guardians | id | school_id | application FK; consent/access fields | P2 | Application scope |
| admission_documents | id | school_id | application/file; scan/verification status | P2/P3 | Admissions assigned roles |
| admission_reviews | id | school_id | application/reviewer; stage/decision; append-only | P2/P3 | Admissions review scope |
| admission_interviews | id | school_id | application/staff; schedule/status; restricted notes | P2 | Admissions/interviewer |
| admission_offers | id | school_id | application; offer ref; expiry/decision; one active offer rule | P2 | Admissions |
| admission_status_history | id | school_id | application; from/to, actor, reason, occurred_at | P2/P3 | Admissions; append-only |
| admission_fee_payments | id | school_id | application/campaign; currency/amount; provider idempotency; verified before acceptance | P2 | Bursar/admissions split permissions |
| admissions_conversion_log | id | school_id | application/student/enrolment; unique conversion key | P2 | Registrar/admin; append-only |

### F. School finance (distinct ledger domain)

| Table | PK | Tenant key | Key FKs / constraints / indexes | Class / lifecycle | RLS intent |
|---|---|---|---|---|---|
| fee_categories | id | school_id | unique code; category type | P1 | Bursar |
| fee_structures | id | school_id | year/grade/currency; effective dates; status | P1 | Bursar |
| fee_structure_items | id | school_id | structure/category/term; amount minor nonnegative | P1 | Bursar |
| fee_assignments | id | school_id | enrolment/structure; override reason | P2 | Bursar |
| invoices | id | school_id | enrolment; unique invoice no; one currency; immutable once posted | P2; draft/posted/part-paid/paid/void | Bursar/authorized finance |
| invoice_items | id | school_id | invoice; item snapshots; exact totals | P2 | Finance |
| payment_methods | id | nullable school_id | global or tenant configured; secrets not stored | P1 | Platform config/school finance |
| payments | id | school_id | enrolment/guardian/method; unique ref/provider tx/idempotency; verified state | P2 | Bursar; payer filtered |
| payment_allocations | id | school_id | payment/invoice; same currency; bounded allocation; reversal link | P2 | Finance; transactional |
| receipts | id | school_id | payment; unique receipt no; verified-only; void audit | P2 | Finance; guardian own approved receipt |
| fee_discounts | id | school_id | enrolment/category; basis exclusive; approvals/cap | P3 | Finance approvers |
| student_bursaries | id | school_id | enrolment; confidential; amount/percent; approvals | P3 | Restricted bursary panel |
| invoice_adjustments | id | school_id | invoice; reason/approval/posting | P2/P3 | Finance |
| credit_notes | id | school_id | invoice; amount cap; immutable once issued | P2 | Finance |
| refunds | id | school_id | payment; amount net cap; method/status; approval | P2/P3 | Finance separate requester/approver |
| refund_approvals | id | school_id | refund/approver/decision; append-only | P3 | Authorized approvers |
| unallocated_credits | id | school_id | payment/enrolment; currency/status | P2 | Finance |
| bank_accounts | id | school_id | encrypted identifiers/masked values | P3 | Bursar/finance admin only |
| bank_statement_imports | id | school_id | bank account/file; import state | P2/P3 | Finance |
| bank_statement_entries | id | school_id | import/account; unique dedupe hash; currency | P2/P3 | Finance |
| reconciliation_matches | id | school_id | entry/payment/journal; amount and match state | P2 | Finance |
| chart_of_accounts | id | school_id | code unique; parent same tenant; no cycles | P1 | Finance admin |
| accounting_periods | id | school_id | dates non-overlap; closed periods block posting | P1 | Finance admin |
| journal_entries | id | school_id | period; unique journal no; posted immutable/reversal | P2 | Accountant/approver |
| journal_lines | id | school_id | entry/account; exactly debit or credit; currency; balance by currency | P2 | Finance |
| expense_categories | id | school_id | unique code; optional account | P1 | Finance |
| suppliers | id | school_id | unique code; restricted tax identifiers | P2/P3 | Procurement/finance |
| expenses | id | school_id | category/supplier/period; amount/currency; approval workflow | P2 | Requester limited; finance |
| purchase_requests | id | school_id | requester/supplier; amount/currency; status | P2 | Requester and approvers |
| budgets | id | school_id | accounting period; approval state | P1/P2 | Finance |
| budget_items | id | school_id | budget/account; unique budget/account/currency | P2 | Finance |
| financial_approvals | id | school_id | subject type/id validated; step; decision append-only | P3 | Approvers; separation of duties |
| currency_definitions | currency_code | global | ISO code; currency precision/exponent; effective dates | P0/P1 | Platform reference data |
| exchange_rates | id | global/school policy | source/target, rate, source/time, approval and validity | P2 | Finance admin |
| currency_conversion_snapshots | id | school_id | original/converted amounts and currencies; rate snapshot; rounding; reason | P2/P3 | Finance; audit |

**Hard separation:** school finance tables above must never FK into XEN platform subscription invoice/payment tables. Integration, if needed, is by explicit external settlement or reporting boundary—not shared ledger IDs. Posted records use reversal/credit/adjustment, never destructive edits.

### G. Public website / CMS (separate data boundary)

| Table | PK | Tenant key | Key FKs / constraints / indexes | Class / lifecycle | RLS intent |
|---|---|---|---|---|---|
| school_websites | id | school_id | one per tenant unless multi-site; config safe | P1 | Website admins |
| website_themes | id | nullable school_id | platform or tenant theme; schema validated | P1 | Tenant themes isolated; platform themes read-only |
| website_pages | id | school_id | website/parent; unique website+language+slug; page state | P0 only when published; otherwise P1 | Editors; public only published projection |
| website_page_versions | id | school_id | page/version unique; immutable snapshot | P1/P0 | Editor; public exact published version only |
| website_sections | id | school_id | version FK; allow-listed component; position | P1/P0 | Editor; public through approved view |
| website_components | id | nullable school_id | global/tenant schema allowlist; version | P1 | Platform registry or tenant safe config |
| website_reusable_blocks | id | nullable school_id | validated reusable block content; version; safe visibility | P1 | Editor; public only via published page snapshot |
| website_starter_templates | id | none | platform template/version; allowlisted component manifest | P1 | Platform admin; read-only school copy |
| website_navigation | id | school_id | website; version; validated links | P1/P0 | Editor; published projection |
| website_media | id | school_id | website/file; consent/rights metadata | P2 until approved; P0 only after explicit approval | Editor; public approved media only |
| website_articles | id | school_id | website; unique slug/lang; publication status | P0 only published | Editor; public published-only |
| website_events | id | school_id | website; date range; visibility/status | P1/P0 when approved public | Editor; public safe events only |
| website_domains | id | school_id | website; normalized globally unique; verified state; one primary | P1 | Domain admin; public resolver only verified |
| website_translations | id | school_id | page/source/target language; review status | P1/P0 if published | Translator/editor; published translations only |
| website_publications | id | school_id | page/version; publication history; current state | P0 publication metadata | Publisher; anonymous safe read only |
| website_seo_settings | id | school_id | website/page; safe metadata | P0 when published | Editor; public safe projection |
| website_forms | id | school_id | website; schema/destination/retention validated | P1/P0 form schema | Editor; public submission endpoint controlled |
| website_form_submissions | id | school_id | form; retention, assigned handler; payload limited | P2/P3 | Admissions/assigned staff only; public can submit but not read |

**Public/private isolation:** anonymous queries use a dedicated read model/view/API, not base-table RLS broadening. It must select only approved page versions where publication is current, published, not expired/unpublished, domain verified, and content passes policy. CMS authoring and submissions are separate. No public joins to students, guardians, grades, finance, health, safeguarding, or private file metadata. Student photos/achievements require verified consent/legal basis and explicit review.

### H. Portals and communications

| Table | PK | Tenant key | Key FKs / constraints / indexes | Class / lifecycle | RLS intent |
|---|---|---|---|---|---|
| portal_preferences | id | school_id | user/portal unique; validated prefs | P1 | Self; school admin limited |
| portal_notifications | id | school_id | user; safe text; expiry/read state | P2 | Recipient only |
| portal_access_logs | id | school_id | user/time/outcome | P3 | Security/audit |
| portal_device_tokens | id | school_id | encrypted token; unique active; revoked | P3/P4 | Token service; self manage |
| announcements | id | school_id | audience scope validated; status/time | P1/P2 | Author and audience only |
| announcement_recipients (recommended) | id | school_id | announcement/user; unique; delivery/read state | P2 | Recipient and authorized comms staff |
| message_threads | id | school_id | participant set; related student restricted | P2 | Participants only |
| messages | id | school_id | thread; sender; moderation/edit history | P2 | Thread participant; moderator scoped |
| message_recipients | id | school_id | thread/user unique active; thread-level read state | P2 | Participant only |
| message_read_receipts | id | school_id | message/recipient unique; read timestamp | P2 | Recipient and authorized thread participants |
| message_moderation_actions | id | school_id | message/moderator/action/reason/status; append-only | P2/P3 | Moderator scoped; history restricted |
| message_attachments | id | school_id | message/file; permission validated | P2/P3 | Thread participant; signed downloads |
| notification_templates | id | nullable school_id | platform or tenant override; version; active | P1 | Template admin |
| notification_deliveries | id | school_id | recipient/channel/provider; dedupe; retry status | P2 | Recipient; operations sanitized |
| notification_preferences | id | school_id | user/channel/category unique; quiet-hours validation | P1 | Self; policy admin |
| communication_provider_logs | id | school_id | provider event ID unique/idempotent; safe payload | P3 | Operations; append-only |

### I. Optional services

| Table group / tables | Key relationship/constraints | Class/lifecycle | RLS intent |
|---|---|---|---|
| library_categories, library_books, library_book_copies | tenant-safe parent links; ISBN/accession uniqueness; copy status | P1; available/on-loan/reserved/lost/repair/retired | Library role; borrower own limited |
| library_loans, library_reservations, library_fines | exactly one borrower; one active loan/copy; due/renewal checks; fines currency | P2 | Librarian; student/guardian own allowed |
| transport_vehicles, transport_routes, transport_route_stops | route/vehicle/campus; stop sequence unique; capacity/inspection | P1/P2; active/retired | Transport role |
| student_transport_assignments | enrolment/route/stop same route; effective dates | P2 | Transport; guardian own child |
| transport_incidents | student/vehicle/route links; restricted narrative | P3 | Designated safety role only |
| boarding_houses, boarding_rooms, boarding_assignments | capacity; dates; house/room same tenant | P1/P2 | Boarding staff |
| meal_plans, meal_orders, meal_attendance | dates, student assignment, dietary restrictions separate restricted info | P2/P3 | Catering limited; sensitive dietary detail restricted |
| clubs, activities, activity_memberships | staff/student scope; capacity; consent | P1/P2 | Activity staff; guardian own |
| trips, trip_permissions, trip_attendance | dates, permission/consent, emergency contact | P2/P3 | Trip lead and guardian own |
| service_incidents | typed service/student references; restricted details | P3 | Need-to-know; audit |

### J. Documents, support and platform operations

| Table | PK | Tenant key | Key FKs / constraints / indexes | Class / lifecycle | RLS intent |
|---|---|---|---|---|---|
| document_categories | id | school_id | unique code; retention policy | P1 | Document admin |
| document_records | id | school_id | owner/type; classification; lifecycle | P2/P3 | Explicit permissions |
| document_versions | id | school_id | document/file; version unique; checksum; scan status | P2/P3 | Authorized readers; quarantined denied |
| document_permissions | id | school_id | document/subject/permission/scope; validity | P3 | Grantor authorized; prevent self-grant |
| document_access_logs | id | school_id | actor/document/action/time; append-only | P3 | Security/audit |
| retention_rules | id | school_id nullable | category, duration, legal basis, holds | P3 | Privacy/compliance |
| data_export_requests | id | school_id nullable | requester/scope/verification/approval/status | P3 | Privacy admin; requester status only |
| data_deletion_requests | id | school_id nullable | identity verification, scope, legal hold, outcome | P3 | Privacy admin |
| support_tickets | id | school_id nullable | requester/category/priority/status | P2/P3 | Requester + assigned support |
| support_ticket_messages | id | school_id nullable | ticket; public/internal visibility; attachments | P2/P3 | Internal notes hidden from requester |
| support_ticket_assignments | id | school_id nullable | ticket/agent/valid interval | P2 | Support |
| support_ticket_history | id | school_id nullable | from/to/actor/time; append-only | P2/P3 | Support and requester-safe history |
| system_jobs | id | nullable school_id | job key/idempotency/status/schedule | P3 | Operations |
| job_failures | id | nullable school_id | job/error sanitized/retry | P3 | Operations |
| webhook_events | id | nullable school_id | provider/event ID unique; signature status; sanitized payload | P3 | Integration operators |
| backup_inventory/recovery_events | id | nullable school_id | backup metadata and recovery verification | P3 | Operations/security |
| file_metadata | id | school_id nullable | object key unique; size/MIME/scan/classification; owner | P2/P3 | Metadata and storage policy; public approved only |

### K. XEN SaaS billing (separate platform ledger)

| Table | PK | Tenant key | Key FKs / constraints / indexes | Class / lifecycle | RLS intent |
|---|---|---|---|---|---|
| subscription_plans | id | none | plan key/version; active catalog | P1 | Platform commercial admin; public catalog safe |
| subscription_features | id | none | plan/feature unique; quota/config | P1 | Platform admin |
| billing_customers | id | school_id | school/provider customer ID unique | P2 | XEN billing only; school sees own |
| school_subscriptions | id | school_id | plan; contract snapshot; period/status; history | P2 | XEN billing admin; tenant own billing view |
| subscription_items | id | school_id | subscription/feature/quantity; effective dates | P2 | Billing |
| subscription_invoices | id | school_id | invoice number unique; currency; immutable posted | P2 | XEN billing only |
| subscription_payments | id | school_id | invoice/provider; idempotency; verified state | P2 | XEN billing only |
| subscription_events | id | school_id | subscription; transition history append-only | P2/P3 | Billing audit |
| usage_records | id | school_id | feature/period/dedupe; quantity | P2 | Billing/tenant usage read |
| promotions | id | none or platform | code/status/validity/limits | P1 | Commercial admin |
| promotion_redemptions | id | school_id | promotion/subscription/invoice; unique redemption key | P2 | Billing |

**No shared tables or identifiers with school invoices/payments.** SaaS plan charges must not be posted into a school's tuition ledger. Only explicitly designed settlement reports may cross the boundary.

## 5. Lifecycle and state-machine conventions

- Tenant: onboarding → trial/active → suspended → active or closed; closed is terminal except approved reopening.
- Membership: invited → active → suspended/ended. Ending revokes grants.
- Enrolment: pending → active → paused/transferred/completed/withdrawn; event history retained. Multiple enrolments permitted only under accepted policy; one primary per relevant student/calendar context.
- Assessment: draft → open → submitted → moderated → approved → published → archived; transitions guarded and published snapshots immutable.
- Attendance: draft → submitted → approved → locked; corrections are append-only.
- Admissions: campaign draft/published/open/closed/archived; application draft/submitted/review/interview/offered/accepted/rejected/withdrawn/converted; transition history.
- School finance: invoice draft → posted → part-paid/paid → void only through controlled process; payments pending/received/verified/failed/reversed/refunded; receipt issued/voided. Posted objects immutable.
- CMS: draft → review → published → archived; page version immutable; publication/unpublication is an event.
- Files: uploaded → quarantined/scanning → clean/approved or rejected → archived/deleted per retention; unscanned file never publicly accessible.
- SaaS subscription: trial/active/past_due/grace/suspended/cancelled/expired; price/plan snapshot and event log.
- Optional services: statuses documented per module, never generic unchecked state.

## 6. Tenant composite-FK and integrity requirements

- Add unique `(school_id,id)` on tenant tables.
- All tenant FK pairs use same-school composite FK. Exceptions require a written review (e.g., profile/auth global identity).
- FK column indexes are mandatory unless covered by a composite index.
- Unique constraints should include tenant scope; public domains are global unique normalized values.
- Aggregate constraints (allocations ≤ payment/invoice balances, journal balanced, capacity, active enrolment overlaps) require transaction-safe service logic/locking or trigger design; a CHECK alone is insufficient.
- Polymorphic reference fields are allowed only for audit/consent/event/service metadata with a typed registry and validation; core relational data must use explicit FK or bridge tables.
- Prevent cycles in parent hierarchies (departments, grade trees, categories, accounts, CMS pages) with reviewed application/trigger enforcement.

## 7. Index strategy

Default: tenant-leading indexes for frequent access and FK joins; index every FK. Include common status/date filters. Avoid excess indexes on high-write event/ledger tables. Use partial indexes for active links, primary assignments, unexpired grants, current subscriptions. GIN/JSONB indexes only after query profiling. Use cursor pagination.

Recommended indexes (baseline):
- tenant access: memberships (school,user,status), (user,status); role grants (membership,valid_from,valid_until); school slug; campus school/code.
- people: students (school,status), unique (school,student_number); guardian links (school,student,active/verified), (school,guardian); enrolments (school,student), (school,year,status).
- academic: calendars/years/terms by school/calendar/dates; classes by school/year/grade; class subjects by class/subject/year; assignments by enrolment/class/date.
- attendance: sessions by school/class/date and school/year/date; records unique session/student; corrections by record/time.
- assessment: assessments by school/period/status and offering/date; marks/results unique assessment/student/component; reports by enrolment/year/term.
- admissions: applications by campaign/status/submission and unique reference; history by application/time.
- finance: invoices by enrolment/status/due; payments by school/received/status; provider transaction unique; allocations invoice/payment; receipts unique; bank imports/entries date+dedupe; journals by period/date/status; lines by entry/account.
- CMS: pages website/language/status/slug; publications page/status/time; domains unique normalized; form submissions form/status/time.
- communication: notifications user/read/time; threads/messages time; recipients unique; delivery status/channel/queued; provider event unique.
- services: copy status/book; active loan by copy/borrower; route-stop unique route/sequence; assignments route/status; support tickets status/assignee.
- governance: files school/classification/status/time; audit school/time and actor/time and resource; job status/time; usage unique dedupe + school/feature/period.

## 8. Security role matrix (policy intent; actual permission keys and policies are review items)

| Role | Allowed access baseline | Explicit exclusions / checks |
|---|---|---|
| XEN platform administrator | Platform settings, tenant lifecycle, plan catalog, operational health | No routine unrestricted P2/P3 school data; privileged support access must be scoped, time-limited, purpose-bound, approved/audited |
| XEN support/operator | Assigned tickets, safe tenant metadata, diagnostics | No financial/medical/legal record access by default; access grant required |
| School owner | School configuration, membership/role admin, module configuration, reports | Cannot bypass legal restrictions, audit or immutable ledgers; own role grants constrained |
| School administrator | Operational management across granted school scope | Sensitive finance/HR/health/safeguarding/legal require explicit separate permission |
| Principal/head | Academic/attendance/discipline/approved reporting within school | Restricted health/legal/finance requires specific authorization; audit |
| Bursar/finance | School fees, payments, receipts, refunds, budgets, reconciliation | No XEN SaaS billing administration; bursary/bank details and approval segregation |
| Admissions | Campaign/application/review/offers; applicant conversion workflow | No general student/finance/medical access; admissions payment controls separated |
| Teacher | Assigned classes, subjects, attendance, marks, communications | No unrelated classes, HR, finance, legal/medical, safeguarding by default |
| Website editor/publisher | CMS drafts, assets, website configuration, publication workflow | No student management or private finance; public publication only approved content |
| Guardian | Verified linked learner(s), permitted attendance/results/finance/communications | Active verified relationship, per-child flags, custody/legal restrictions, field filtering; revoked immediately |
| Student | Own profile/portal, published results, attendance, permitted services | Self only; no other students, private staff notes, restricted/legal/health data |
| Librarian/transport/boarding/service staff | Relevant module data and assigned scope | Student sensitive records excluded; incidents restricted |
| Privacy/security/audit reviewer | Governance records, access/audit, approved data requests | Access purpose and scope; no broad operational rights unless separately granted |

Use separate permission keys and separate RLS policies for SELECT/INSERT/UPDATE/DELETE. Deny by default. Service-role bypass is not a security test. Never let users self-assign platform roles or broader tenant roles.

## 9. RLS intent by domain

- Tenant tables: RLS enabled. Resolve tenant from authenticated identity + active membership and role scope; do not trust client-provided school_id.
- Platform/global tables: platform role or safe read catalog policy; tenant-customized rows require tenant scope.
- Guardians: link must be active, verified, in date, permission flag allows category, and legal restrictions do not block.
- Student self access: verified account link and own student record only; feature and field scope.
- Public CMS: base tables are not anonymous. Dedicated safe public projection returns only approved published content and approved public media; domain verification and cache invalidation/unpublish required.
- Finance: dedicated permission family, separate approval roles, own school scope, immutable records; no parent portal data unless verified guardian and finance flag.
- Health/safeguarding/custody/legal: restrictive policies and dedicated roles, audit access, no general profile joins, no portal or export without explicit reviewed authorization.
- Files: metadata RLS + storage policy; private files signed URLs after authorization, scan/clean status; public bucket only approved public assets.
- SaaS billing: platform billing staff and school billing-view permission; separate schema/domain; school cannot inspect other tenants.
- Audit/events: append-only, read restricted; actors cannot edit/delete their events.
- Platform support access: purpose/approval/expiry and access logs; policy helper checks grant.

## 10. Testing/acceptance gates

1. Empty database migration replay and upgrade-path migration test.
2. PK/FK/check/unique constraints and composite tenant FK negative tests.
3. Tenant A/B tests across every table group: read/write/delete denial, guessed IDs, indirect joins, RPC/view exposure.
4. Role matrix tests using non-owner, non-service application roles.
5. Guardian link verification/revocation/legal restriction and field-level access tests.
6. Anonymous CMS tests: drafts, unapproved media, unpublished/expired versions, unverified domains and private submissions all denied; only approved published projection exposed.
7. School finance vs SaaS billing separation tests; currency, allocation, receipt, refund and immutable posted transaction tests.
8. Health/safeguarding/custody records are not exposed in search, notifications, exports, portal APIs or public pages.
9. Workflow transition, idempotency, concurrency/locking, duplicate callbacks and conversion tests.
10. Data classification, file scan/quarantine, signed URL expiry, retention/legal holds and deletion/export approvals.
11. Index/query-plan/performance baseline; pagination and workload/tenant tests.
12. Backup/restore and recovery drills with integrity verification.
13. Domain expert review for finance, legal/custody, health/safeguarding, Zimbabwe and future-market privacy.
14. Product owner accepts phase scope and pilot validation.

### L. Restricted health and safeguarding

| Table group / tables | Key relationship/constraints | Class/lifecycle | RLS intent |
|---|---|---|---|
| student_health_profiles, student_health_conditions, student_allergies | student; minimal necessary fields; validity/review; separate sensitivity | P3; active/reviewed/expired | Designated health staff only |
| health_visits, medication_records, medication_administration_events | student/medication; time; administration event immutable | P3 | Need-to-know; no general parent/profile access |
| safeguarding_incidents | student optional; incident type/date; restricted narrative; assigned role | P3; reported/assessed/action/closed | Safeguarding designated roles only |
| safeguarding_referrals, safeguarding_action_plans | incident; referral/plan owner, review and outcome | P3 | Designated case team |
| restricted_record_access_logs | record/actor/purpose/outcome/time | P3; append-only | Security/privacy reviewer |

## 11. Technical verification items (decisions accepted; evidence still required)

1. Confirm Supabase region/tier, PostgreSQL version/extensions, pooling, Auth settings, backup/PITR and limits.
2. Confirm local/CI/staging/production environments and migration tooling configuration.
3. Review tenant-context and RLS helper design, grants and exposed schemas/views/RPC; test fail-closed.
4. Verify calendar and timetable timezone semantics, recurrence, clash detection, published-version rules and date exceptions.
5. Validate currency precision registry, conversion snapshots, rounding and source/approval policy.
6. Select payment providers and verify merchant/API access, callbacks, refunds, settlement and reconciliation.
7. Complete legal/privacy review: child data, retention, residency, consent, custody/legal restrictions and incident response.
8. Validate private storage provider, quarantine/scanning, key management, signed access, lifecycle and backup.
9. Define health/safeguarding roles, record minimums, access audit, retention and case workflows.
10. Confirm SaaS quotas, billing state transitions, grace/suspension, promotions and provider integrations.
11. Validate custom domains, DNS/SSL, tenant routing, public read projections and cache invalidation.
12. Define reporting/analytics performance targets and largest expected tenant; choose read models only as needed.
13. Confirm optional module rollout gates, feature entitlements and pilot-school validation.
14. Confirm export/deletion/anonymisation, audit immutability, recovery targets and operational procedures.
15. Complete the Gate 0 documentation consistency audit and close blockers before executable schema work.

## 12. Approval boundary

This is a proposed logical blueprint, not final schema. Review for completeness, security, operational practicality, jurisdictional requirements and pilot-school workflows. No SQL, migrations, executable schema, seed data, application code, CI, infrastructure or deployment has been created. Separate explicit authorization is required before implementation.
