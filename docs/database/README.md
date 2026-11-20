# Database Specification Index — XEN SCHOOL MANAGEMENT v3.0

**Status:** Complete conceptual specification with approved product/design decisions and approved technical architecture baseline. Documentation only; not implemented. No SQL migrations, executable schema, seed data, or RLS code exists yet.

## Specification documents

1. [Platform, tenancy, identity, people and access data dictionary](data-dictionary-platform.md)
2. [Academics, attendance, assessment, report cards and admissions](data-dictionary-academics.md)
3. [School finance and XEN SaaS billing](data-dictionary-finance.md)
4. [School websites, CMS, portals and communication](data-dictionary-web-portals.md)
5. [Library, transport, documents, service desk, SaaS, audit and storage](data-dictionary-services-platform.md)
6. [Entity relationship specification](relationship-specification.md)
7. [Constraints, indexes, tenant isolation, RLS, lifecycle and open decisions](constraints-indexes-rls.md)
8. [Approved design decisions (all 13 accepted)](approved-design-decisions.md)
9. [Database implementation roadmap](implementation-roadmap.md)
10. [Comprehensive schema blueprint](schema-blueprint.md)
11. [Migration manifest and acceptance gates](migration-manifest.md)
12. [Technical decision register — approved baseline](technical-decision-register.md)
13. [Technical architecture baseline](technical-architecture-baseline.md)

## Coverage
The specification covers platform/tenant model; users, roles and access; students, guardians, verified links, enrolments and staff; academic years, terms, grades, classes, streams, subjects and calendars; attendance; assessments, moderation, results and report cards; admissions; school finance and accounting; website/CMS/domains/translations/forms; parent/student portals and communications; library; transport; document management; support desk; XEN subscriptions/usage; audit/security/consent/exports/deletion/jobs/webhooks/backups; and file metadata.

## Approved design principles
- Multi-tenant data isolation and tenant-safe composite relationships.
- Flexible academic calendars and controlled multiple enrolments.
- Configurable grading and assessment.
- Multi-currency with explicit conversion records.
- Full accounting architecture planned and phased.
- Configurable admissions fees.
- Granular guardian/legal access restrictions.
- Restricted health/safeguarding modules.
- Mixed publishing controls for school websites.
- Communications with permissions and moderation.
- Optional school services ecosystem.
- Flexible XEN SaaS pricing/configuration.
- Data governance, retention, residency support, backup and recovery.
- Exact money/currency representation; no floating-point finance.
- Immutable posted financial/historical records with reversal/adjustment flows.
- Verified payments before allocation/receipt.
- Guardian access through verified active relationships and granular permissions.
- Public website reads only approved published content.
- School finance is separate from XEN SaaS billing.

## Approved technical baseline
- Supabase PostgreSQL + Supabase Auth.
- API-first Cloudflare Workers for core/sensitive workflows; RLS mandatory.
- React + TypeScript frontend hosted on Vercel.
- Private Cloudflare R2 is the initial storage candidate.
- Supabase CLI migrations versioned in Git.
- UUIDv4 initially; UTC instants/timestamptz and IANA timezone context.
- Integer minor units with currency code and currency precision registry.
- Domain-separated schemas, private restricted schemas, safe public CMS projections.
- Managed server-side secrets; append-only audit; automated tenant/security tests.

## Remaining verification before production
Region/tier and provider capabilities; privacy/legal review and retention schedule; payment provider selection; storage validation; RPO/RTO and recovery drill; domain routing/SSL; role/RLS/API exposure review; operational cost/limits, observability, support and rollback.

## Approval boundary
Technical recommendations are approved as the baseline. This is not implementation authorization. No SQL, migrations, seed data, application code, CI, infrastructure provisioning or deployment should begin until separately authorized.
