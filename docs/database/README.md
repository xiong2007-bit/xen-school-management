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
10. [Comprehensive schema blueprint](schema-blueprint.md) — logical table inventory, key/tenant relationships, classification, lifecycle, indexes and RLS intent
11. [Migration manifest and acceptance gates](migration-manifest.md) — ordered dependencies and migration/test gates
12. [Schema blueprint review checklist](schema-blueprint-review-checklist.md) — table-level review worksheet, domain readiness and security segregation tests
13. [Technical decision register — approved baseline](technical-decision-register.md)
14. [Technical architecture baseline](technical-architecture-baseline.md)
15. [Pre-implementation readiness checklist](pre-implementation-readiness-checklist.md)
16. [Gate 0 scope and consistency audit](gate-0-scope-consistency-audit.md)
17. [Master requirements traceability matrix (MRTM)](requirements-traceability-matrix.md)
18. [Proposed first-release/pilot scope](proposed-first-release-scope.md)
19. [Stage 3 pilot workflows, user stories and acceptance criteria](pilot-workflows-user-stories-acceptance-criteria.md)
20. [Stage 3 pilot workflow validation and sign-off plan](pilot-workflow-validation-signoff.md)

## Coverage
The specification covers platform/tenant model; users, roles and access; students, guardians, verified links, emergency contacts/legal restrictions, enrolments and staff; academic programmes/calendars/terms/events, classes/subjects, timetable periods/rooms/versioned schedules; attendance; configurable assessment/grading/promotion/report templates; admissions and fee snapshots; school finance, currency conversions and accounting; website builder/reusable blocks/CMS/domains/translations/forms; parent/student portals and communications/read receipts/moderation; library, transport, boarding, meals, clubs, activities and trips; restricted health/safeguarding; documents, service desk; XEN subscriptions/usage; audit/security/consent/exports/deletion/jobs/webhooks/backups; and file metadata. School groups and student portal features are explicitly future/optional.

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

## Gate 0 audit result

**PASS WITH ACTIONS:** The authoritative 22-page Master Plan v3.0 was reviewed and all 28 sections/appendices were mapped. High-priority documentation inconsistencies were corrected. Exact first-release scope, pilot validation, product requirement IDs and technical/provider/legal verification remain open. [Read audit report](gate-0-scope-consistency-audit.md).

## Remaining verification before production
Region/tier and provider capabilities; privacy/legal review and retention schedule; payment provider selection; storage validation; RPO/RTO and recovery drill; domain routing/SSL; role/RLS/API exposure review; operational cost/limits, observability, support and rollback.

## Approval boundary
Technical recommendations are approved as the baseline. This is not implementation authorization. No SQL, migrations, seed data, application code, CI, infrastructure provisioning or deployment should begin until separately authorized.


## Schema blueprint review status (21 November 2026)

- [Schema blueprint](schema-blueprint.md): table-by-table conceptual design plus review supplement, security boundaries and blockers.
- [Migration manifest](migration-manifest.md): 19 proposed ordered migration groups and cross-domain dependency notes.
- [Review checklist](schema-blueprint-review-checklist.md): table review worksheet and domain-by-domain sign-off status.
- **Pending:** owner/pilot validation, technical/provider/privacy/legal decisions, RLS and FK implementation review. Documentation only; executable schema and migrations are not created.


## Stage 3 workflow design status

- [Detailed workflows and acceptance criteria](pilot-workflows-user-stories-acceptance-criteria.md): 18 pilot workflows, persona-based user stories, testable acceptance criteria, exception paths, cross-workflow safety rules and validation protocol.
- [Validation and sign-off plan](pilot-workflow-validation-signoff.md): stakeholder review checklist, validation sessions, outcome log and proposed sign-off gates.
- **Pending:** product owner and pilot-school validation; acceptance criteria are draft and have not been tested. Documentation only; implementation not authorized.


## Stage 4 planning status (21 November 2026)

- [Prioritized pilot backlog and sprint planning proposal](stage-4-prioritized-pilot-backlog-sprint-plan.md): 24 backlog items, dependency notes, proposed Sprint 0–7 sequence, Definition of Ready/Done and decisions requiring validation.
- [Test-case inventory and quality strategy](stage-4-test-case-inventory.md): 45 proposed scenarios, severity guidance, test suites and evidence record. No tests executed.
- [Pilot data import and migration plan](stage-4-data-import-plan.md): source inventory, batch order, mapping, dry-run, reconciliation, cutover and recovery. No school data processed.
- [Implementation readiness gate](stage-4-implementation-readiness-gate.md): proposed GO / GO WITH CONDITIONS / NO-GO evidence gate and signoff roles.
- **Stage 4 outcome:** planning documents drafted and committed for review. Implementation readiness remains **NO-GO** pending stakeholder validation, required evidence and explicit authorization. Documentation only; no code, migrations, CI, infrastructure, deployment or imports created.
