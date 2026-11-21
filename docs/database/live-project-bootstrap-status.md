# Live Cloud Project Bootstrap — XEN SCHOOL MANAGEMENT

**Date:** 21 November 2026  
**Status:** Bootstrap implementation started. Live resources created and database migrations applied. Not production-ready.

## Cloud resources

- **Supabase project:** `xen-school`
- **Project ref:** `pdidtgcrubfcacdlvpmx`
- **Region:** `eu-west-1`
- **Database:** PostgreSQL 17; project status reported `ACTIVE_HEALTHY`
- **Project URL:** https://pdidtgcrubfcacdlvpmx.supabase.co
- **Cloudflare Worker:** `xen-school`
- **Worker URL:** https://xen-school.tanatswanrufasha.workers.dev
- **Worker subdomain:** enabled
- **Cloudflare Worker deployment:** API reported successful deployment. A live HTTP request could not be verified through the available browser fetch.

## Database implementation status

Nine migrations were applied in the Supabase project:

1. `0001_foundation_people_academics_attendance_assessment`
2. `0002_admissions_school_finance_core`
3. `0003_cms_portals_communications`
4. `0004_optional_services_restricted_health`
5. `0005_saas_billing_and_operations`
6. `0006_accounting_fx_and_bank_reconciliation`
7. `0007_foreign_key_indexes`
8. `0008_rls_membership_helper_fix`
9. `0009_additional_blueprint_tables`

Verified snapshot:

- **209 public tables**
- **209/209 tables have RLS enabled**
- **170 public policies**, including **163 tenant-select policies**
- **Zero school data rows were imported or seeded**
- Security advisor currently reports 40 informational tables with RLS enabled and no client policies. These are intentionally fail-closed platform, audit, operations, or restricted-record tables; permissions must be designed before access is opened.
- Health advisor reports no lints.
- Performance advisor reports unused-index informational findings on this new empty database. Indexes were created for FK paths; actual query tuning needs representative workloads.

## Tenant-security design

A private helper `private.is_school_member(uuid)` was added as a stable SECURITY DEFINER function with an empty search path and explicit authenticated-user membership check. Tenant SELECT policies call this helper to avoid recursive RLS on `school_memberships`. The helper is in the non-exposed `private` schema; execution is granted to authenticated users.

Client writes remain closed by default. Business write policies and server-side workflows must be implemented and tested before the application can create/edit records.

## Implemented domains

Detailed relational foundation includes tenants, campuses, profiles/memberships, roles and permissions, students, guardian relationships/restrictions, staff, academic programmes/calendars/years/terms, classes/streams/subjects, enrolments, attendance, assessment/grading/marks/results/report cards, admissions, core fees/invoices/payments/allocations/receipts/refunds, websites/CMS, portal notifications and communications, FX/accounting/bank reconciliation, subscriptions/usage/promotions, documents/support/operations, timetable and promotion-rule foundations.

Optional modules (library, transport, boarding, meals, clubs, activities and trips) and several operations/document/support records were initially scaffolded using a flexible JSONB `record_data` field. They are table-level placeholders and are **not yet fully normalized to their approved data dictionaries**. Health and safeguarding tables are created with RLS enabled and no client policies; they are intentionally inaccessible pending specialist access controls and review.

## Important reproducibility gap

The live Supabase migration history has the nine applied migration names, but the exact SQL migration files have **not yet been mirrored into the Git repository**. The next engineering task is to create and review versioned migration files in `supabase/migrations/`, verify them against a clean disposable database, and reconcile them with this live schema. Do not treat this live schema as a finalized or reproducible release until that is complete.

## Not yet implemented

- Supabase Auth signup/onboarding flow, secure school provisioning, role assignment and permissions enforcement
- API/database connection from Cloudflare Worker (no Supabase secrets configured in Worker)
- Cloudflare R2 bucket and private upload/scan pipeline
- Actual application frontend, dashboard, forms, reports or end-to-end workflows
- Client/server write policies, RPCs or validated business transactions
- Payment providers, email/SMS providers, webhook processing
- Public CMS read projection and domain verification workflow
- Full normalized optional-service and operations schemas
- Restricted health/safeguarding access implementation
- Migration files in Git, clean-database replay, automated tests, CI, backup/recovery drill, legal/privacy review, pilot signoff

**Safety:** no student, guardian, staff, school, or finance records have been inserted. This bootstrap is development infrastructure only.
