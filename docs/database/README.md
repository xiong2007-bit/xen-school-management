# Database Specification Index — XEN SCHOOL MANAGEMENT v3.0

**Status:** Complete conceptual specification; approved design decisions recorded. Not implemented. No SQL migrations, executable schema, seed data or RLS code are present.

## Specification documents

1. [Platform, tenancy, identity, people and access data dictionary](data-dictionary-platform.md)
2. [Academics, attendance, assessment, report cards and admissions](data-dictionary-academics.md)
3. [School finance and XEN SaaS billing](data-dictionary-finance.md)
4. [School websites, CMS, portals and communication](data-dictionary-web-portals.md)
5. [Library, transport, documents, service desk, SaaS, audit and storage](data-dictionary-services-platform.md)
6. [Entity relationship specification](relationship-specification.md)
7. [Constraints, indexes, tenant isolation, RLS, lifecycle and open decisions](constraints-indexes-rls.md)
8. [Approved design decisions (all 13 accepted)](approved-design-decisions.md)

## Coverage

The specification describes the platform/tenant model; users and roles; students, guardians, verified links, enrolments and staff; academic years/terms/grades/classes/streams/subjects; attendance; assessment, moderation and results; report cards; admissions campaigns/applications/documents/reviews/interviews/offers/payments; fee structures/invoices/payments/allocations/receipts; advanced finance and accounting; website builder/CMS/domains/translations/forms; parent/student portals and communications; library; transport; document management; support desk; XEN subscriptions/usage; audit/security/consent/exports/deletion/jobs/webhooks/backups; and file metadata.

## Approved design principles

- Multi-tenant data isolation and tenant-safe composite relationships.
- Flexible academic calendars and controlled multiple enrolments.
- Fully configurable grading and assessment.
- Full multi-currency support with explicit conversion records.
- Full accounting architecture planned and implemented in phases.
- School-configurable admissions fees.
- Granular guardian/legal access restrictions.
- Restricted health and safeguarding modules.
- Mixed publishing controls for school websites.
- Full communication system with configurable permissions/moderation.
- Optional school services ecosystem (transport, boarding, meals, activities, trips).
- Flexible XEN SaaS pricing/configuration.
- Flexible data governance, retention, residency support, backups and recovery.
- Exact money with currency; no floating-point financial values.
- Immutable posted financial and approved historical records with reversal/adjustment flows.
- Verified payment before allocation/receipt.
- Guardian access only through verified active relationship and granular permissions.
- Public website reads only approved published content.
- Finance architecture planned up front and implemented in phases.
- School finance is separate from XEN SaaS billing.

## Before implementation

The 13 previously open decisions have been accepted and documented in `approved-design-decisions.md`. Next: prepare the database implementation roadmap, migration sequence, and detailed security/RLS design; validate jurisdiction-specific privacy/retention, payment integrations and operational workflows. Implementation remains unauthorized until separately approved.
