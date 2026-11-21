# Migration Manifest — XEN SCHOOL MANAGEMENT v3.0

**Status:** Documentation-only logical sequence; not actual migration filenames or applied versions. **Order labels:** D01–D19. **No SQL, schema, seed, CI, infrastructure or deployment changes were made in this review.**

## Baseline distinction

The live project bootstrap status records 13 applied migration-history entries and 209 public tables with RLS enabled. The original 12 bootstrap migration sources are not fully mirrored as authored SQL in the repository; one verified school-owner provisioning migration is committed, and catalog-reconstructed snapshot files are not executable migrations. Clean replay is not verified. The D01–D19 groups below are a proposed future normalized design sequence and must be reconciled with the live baseline before any new SQL. See [live-project-bootstrap-status.md](live-project-bootstrap-status.md).

## Manifest conventions

- D01–D19 are logical order labels only; do not use them as Supabase migration filenames or imply they have been applied.
- Every actual migration must identify exact tables/columns, PK and unique keys, tenant-safe composite FKs, null/delete actions, checks, indexes, classification, lifecycle transitions, grants/RLS, API exposure, test evidence and rollback/forward-fix.
- RLS/grants must be fail-closed before any table or view is exposed. Test using normal application roles, not owner/service-role bypass.
- Use reviewed expand/migrate/contract steps for breaking changes. Destructive changes require backup, recovery plan and approval.
- File metadata foundation is early because private documents, admissions, staff, CMS and communications depend on it. Provider/storage implementation remains separately gated.
- Global/platform catalogues, tenant-owned school records and XEN platform-billing records have separate ownership and policies.
- Product decisions accepted in approved-design-decisions.md are not reopened. Technical/provider/legal/operational evidence remains required.

## Ordered logical manifest

| Order | Logical group | Canonical table families / scope | Depends on | Blocking acceptance gate |
|---|---|---|---|---|
| D01 | conventions and reference data | currency_definitions; UUID/time/money/reference conventions; approved extension inventory (no extension selected by default) | Design freeze | Database/version/extension compatibility; currency precision; conventions reviewed |
| D02 | tenant root | schools; school_campuses; platform_settings (proposed, dictionary reconciliation required) | D01 | Tenant root integrity; slug/campus-code uniqueness; status and timezone validation |
| D03 | identity and membership | user_profiles; school_memberships; Auth identity mapping | D02; Supabase Auth | Profile mapping; membership invitation/activation/revocation; no duplicate active membership |
| D04 | authorization and audit foundation | roles; permissions; role_permissions; membership_roles; platform_roles; audit_logs; security_events; login_activity; platform_access_grants (proposed) | D03 | No self-escalation; scope grants; append-only audit; trusted tenant resolver; fail-closed RLS |
| D05 | file metadata foundation | files; storage classification/scan/status metadata only (no provider integration) | D02–D04 | Unique opaque object key; classification; quarantine/scan state; no public default |
| D06 | people, guardian relationships and HR | students; guardians; guardian_student_links; student_emergency_contacts; guardian_access_restrictions; student_enrolments; staff; staff_employment; staff_qualifications; staff_documents; staff_departments; staff_department_memberships; teacher_assignments; enrolment_history (proposed) | D04–D05 | Same-tenant FKs; verified guardian; legal restriction override; approved concurrent enrolments; history and HR privacy |
| D07 | academic structure/calendar/timetable | academic_programmes; academic_calendars; academic_years; academic_terms; calendar_events; timetable_periods; school_rooms; timetables; timetable_entries; timetable_exceptions; grade_levels; classes; class_streams; subjects; class_subjects; student_class_assignments | D06 | Calendar/date policy; flexible term overlap; current-year uniqueness; capacity; tenant-safe scope; timetable clash/version tests |
| D08 | attendance | attendance_sessions; attendance_records; attendance_corrections; attendance_notifications | D07 | Session uniqueness; date/class eligibility; status validation; correction history; notification minimization |
| D09 | assessment and results | assessment_categories; grading_schemes; grading_scheme_versions; promotion_rules; report_card_templates; grading_scale_items; assessment_periods; assessments; assessment_components; student_marks; mark_moderation; student_results; report_cards; report_card_items | D07; D08 optional integration | Configurable grading; bounds/weights; moderation; calculation snapshot reproducibility; publication filtering |
| D10 | admissions | admission_campaigns; admission_applications; admission_applicants; admission_guardians; admission_documents; admission_reviews; admission_interviews; admission_offers; admission_status_history; admission_fee_settings; admission_application_fee_snapshots; admission_payments; admission_payment_refunds; admissions_conversion_log (proposed) | D05–D07 | Public submission minimized; fee snapshot; workflow transitions; verified payments/refunds; idempotent conversion |
| D11 | school finance core | fee_categories; fee_structures; fee_structure_items; fee_assignments; invoices; invoice_items; payment_methods; payments; payment_allocations; receipts | D05–D07 | Exact amounts; currency consistency; verified payment; allocation caps; receipt uniqueness; immutability and reconciliation |
| D12 | websites and CMS | school_websites; website_themes; website_pages; website_page_versions; website_sections; website_components; website_reusable_blocks; website_starter_templates; website_navigation; website_media; website_articles; website_events; website_domains; website_translations; website_publications; website_seo_settings; website_forms; website_form_submissions | D02; D04–D05 | Public projection allow-list; approved immutable version; domain verification; consent/media rights; unpublish and cache purge |
| D13 | portals and communications | portal_preferences; portal_notifications; portal_access_logs; portal_device_tokens; announcements; announcement_recipients (proposed); message_threads; messages; message_read_receipts; message_recipients; message_attachments; message_moderation_actions; notification_templates; notification_deliveries; notification_preferences; communication_provider_logs | D04–D12 as relevant | Recipient/guardian permissions; moderation/read receipts; safe notification payloads; delivery dedupe/retry |
| D14 | advanced school finance/accounting | fee_discounts; student_bursaries; invoice_adjustments; credit_notes; refunds; refund_approvals; unallocated_credits; bank_accounts; bank_statement_imports; bank_statement_entries; reconciliation_matches; chart_of_accounts; accounting_periods; journal_entries; journal_lines; expenses; expense_categories; suppliers; purchase_requests; budgets; budget_items; financial_approvals; exchange_rates; currency_conversion_snapshots | D11 | Double-entry balance; approval separation; FX snapshots; bank reconciliation; closed-period control; reversals/credits |
| D15 | restricted health and safeguarding | student_health_profiles; student_health_conditions; student_allergies; health_visits; medication_records; medication_administration_events; safeguarding_incidents; safeguarding_referrals; safeguarding_action_plans; restricted_record_access_logs | D04–D06; D05 files | Need-to-know; dedicated permissions/schema; reason audit; legal/privacy/safeguarding review; no standard portal/search/export exposure |
| D16 | optional school services | library_categories; library_books; library_book_copies; library_loans; library_reservations; library_fines; transport_vehicles; transport_routes; transport_stops; transport_route_stops; transport_drivers; transport_assignments; transport_incidents; boarding_houses; boarding_rooms; boarding_assignments; meal_plans; meal_orders; meal_attendance; clubs; activities; activity_memberships; trips; trip_permissions; trip_attendance | D05–D08; D11 integration optional | Capacity, eligibility, consent/guardian authority, route/stop and loan uniqueness, restricted incident access, module entitlement |
| D17 | XEN SaaS billing and usage | subscription_plans; subscription_features; billing_customers; school_subscriptions; subscription_items; subscription_invoices; subscription_payments; subscription_events; usage_records; platform_promotions; promotion_redemptions (proposed) | D02; D04 | Contract/price snapshot; state machine; provider-event/idempotency; limits/entitlements; separate from school ledger |
| D18 | documents, support and governance/operations | document_categories; documents; document_versions; document_permissions; document_access_logs; document_retention_rules; support_tickets; ticket_categories; ticket_messages; ticket_assignments; ticket_attachments; ticket_status_history; data_export_requests; data_deletion_requests; consent_records; system_jobs; job_failures; webhook_logs; backup_records | D04–D17; D05 | Private files; scan/quarantine; access audit; legal hold; requester/internal separation; idempotent jobs/events; restore evidence |
| D19 | localization and region readiness | Country/locale/jurisdiction configuration and translation catalogues; exact entity inventory is to be approved before SQL | D02; configurable domains | Zimbabwe-first and international date/currency/locale/tax/privacy validation |

## Dependency and cycle handling

- Tenant root and identity/authorization precede all tenant-owned domains; tenant-safe FK and RLS are required when each table is introduced, not deferred.
- D05 files precede any file reference. File owner/entity references may be nullable only where optional and later constrained; do not solve cycles with unchecked IDs.
- Admissions conversion is transactional and idempotent; admission-fee payments remain separate from tuition unless a separately approved transfer workflow exists.
- Academic assessments may optionally use attendance data; avoid hard FK cycles. Report cards consume approved/versioned snapshots.
- CMS publication depends on page/version structures; anonymous read is an allow-listed projection, not a policy on private authoring tables.
- D11 school finance precedes D14 accounting. School-finance and XEN billing ledgers, permissions, posting routines and reports stay distinct.
- Restricted records link to students with tenant-safe FKs, but do not inherit general student permissions.
- Optional service charges integrate with school finance only through explicit charge/invoice workflow and idempotency.
- D18 governance extends D05 file metadata and must not create public file access.

## Required migration acceptance gates

1. Replay from a clean empty database and upgrade from the supported baseline; schema diff reviewed.
2. Every PK, unique, FK, tenant composite FK, check constraint, delete action and FK index verified.
3. RLS enabled and tested with normal roles across tenant A/B, platform, guardian, student, teacher, finance, support and restricted roles.
4. No public access to private CMS, form submissions, media metadata, student/guardian/attendance/results/finance/health/safeguarding tables.
5. Guardian-link verification, per-link permission, legal restriction, expiry and revocation tests.
6. Workflow transitions, idempotency, duplicate callbacks, concurrency, immutable snapshots and reversal tests.
7. School-finance exact arithmetic/currency/allocation/receipt/refund/journal/reconciliation tests; XEN billing separation.
8. File quarantine/scanning, object-key isolation, signed-link expiry, public approval, legal hold and deletion tests.
9. Performance and query-plan tests using representative tenant volumes; pagination, reports, exports and cache invalidation.
10. Backup/restore, RPO/RTO, operational alerts, incident response and access-review evidence.
11. Finance, privacy/legal, health/safeguarding, Zimbabwe-market and pilot-school domain validation.
12. Product owner accepts phase scope, evidence, risks and release boundary.

## Review items before authorizing SQL

- Reconcile the proposed logical model against the live 209-table scaffold and 13 applied migration records. Identify normalized entities vs JSONB placeholder tables, source exact applied SQL, baseline diff and clean replay.
- Confirm database version/extensions, region/tier, API exposure, migration tooling, pooling, Auth configuration, quotas, cost and performance.
- Approve exact schema namespaces/grants, tenant context helper, role/JWT claims, RLS and permission keys.
- Approve supplemental proposed entities or remove them; sync dictionary/relationship docs first.
- Review concrete FK actions, nullable scopes, unique/check constraints, indexes and cycles for every table.
- Verify calendar/timetable timezone, recurrence, DST and overlap rules; grading/rounding/ranking/promotion rules.
- Verify currency precision, exchange-rate source/approval, Zimbabwe currency configuration, payment providers, settlement/refund/reconciliation.
- Complete privacy/legal/retention/residency/cross-border/consent/legal-hold review, especially child data.
- Validate storage provider, scanning, signed access, lifecycle, independent backup and restoration.
- Confirm SaaS pricing/limits/trials/grace/suspension/promotions and custom-domain/cache design.
- Approve pilot scope, acceptance criteria, import plan, training, support, RPO/RTO and release/rollback.

## Explicit non-deliverables and status

This manifest is a documentation plan. It does not create migration files, SQL, executable schema, seed data, application code, CI, infrastructure or deployment. D01–D19 are not actual migration IDs and are not claimed applied. The live bootstrap and reconstructed snapshots are described separately in [live-project-bootstrap-status.md](live-project-bootstrap-status.md).
