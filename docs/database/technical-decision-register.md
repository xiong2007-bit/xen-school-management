# Technical Decision Register — XEN SCHOOL MANAGEMENT v3.0

**Status:** Owner-approved baseline (20 November 2026). Owner approval accepts the recommendations as architecture direction. Provider-dependent, legal, operational, and security verification remains a pre-production gate. Implementation is separately gated.

## Approval record
The owner approved this register's recommendations as a whole. Material changes require an amendment recording rationale, impact, alternatives, and approval. Approval does not guarantee provider capabilities, legal compliance, or production readiness.

## Decisions

| ID | Topic | Approved baseline | Remaining verification |
|---|---|---|---|
| TDR-01 | Database | Supabase-managed PostgreSQL | Confirm version/features |
| TDR-02 | Region/tier | Choose using latency, privacy, cost, availability, backup/recovery | Final region and tier |
| TDR-03 | Schema | Domain schemas/namespaces; restricted schemas private | Exposure/grant review |
| TDR-04 | Auth | Supabase Auth; UUID identity; no credentials replicated | Setup verification |
| TDR-05 | API | API-first Cloudflare Workers for core/sensitive workflows; direct access only reviewed; RLS mandatory | Exposure review |
| TDR-06 | Migrations | Supabase CLI, version-controlled and reviewed | Tooling setup |
| TDR-07 | IDs | UUIDv4 initially | Reconsider only with documented need |
| TDR-08 | Tenant context | Server resolves authenticated membership; client school ID is only a selector | Membership/revocation tests |
| TDR-09 | RLS helpers | Least privilege, safe search_path, fail-closed; avoid SECURITY DEFINER unless justified/reviewed | Policy review and tests |
| TDR-10 | Time | timestamptz for instants, date for calendar facts, UTC and IANA timezone | Schema implementation review |
| TDR-11 | Currency | Integer minor units + currency code + precision registry; explicit conversion snapshots | Currency rules/rounding review |
| TDR-12 | Finance | School finance separate from XEN SaaS billing; posted entries immutable/reversed | Ledger design review |
| TDR-13 | Storage | Private Cloudflare R2 baseline candidate; quarantine/scan and authorized short-lived access | Validate cost, features, backup |
| TDR-14 | CMS | Private authoring, explicit approved publication versions, safe public projection | Publishing/security tests |
| TDR-15 | Payments | Provider-neutral adapters, server verification, idempotency and reconciliation | Select providers and sandbox |
| TDR-16 | Privacy | Data inventory, jurisdiction-specific retention, legal holds, export/deletion, incident process | Legal/privacy review |
| TDR-17 | Recovery | Managed backups/PITR if available, independent encrypted backups and restore drills | Define RPO/RTO and tier |
| TDR-18 | Testing | Migration replay, realistic roles/RLS, tenant isolation, finance, privacy, files and API tests | Implement CI later |
| TDR-19 | Hosting | React/TypeScript on Vercel; Workers API; Supabase DB/Auth; R2 candidate; GitHub | Plan limits, cost and operational fit |
| TDR-20 | Secrets | Managed server-side secrets, never frontend/Git; rotation/access audit | Configure and verify |
| TDR-21 | Audit | Append-only audit events, restricted access, avoid sensitive payloads | Retention/export controls |
| TDR-22 | Domains | Domain verification, tenant routing, SSL, cache invalidation | Provider/workflow |
| TDR-23 | Analytics | Start with PostgreSQL views/queries; scale only on measured need | Monitoring requirements |
| TDR-24 | API exposure | Only reviewed surface; restricted schemas private; privileged views/functions tested | Permission audit |

## Approved baseline detail

### Platform and architecture
- Supabase-managed PostgreSQL and Supabase Auth.
- Cloudflare Workers as API/backend; API-first for core and sensitive operations.
- React + TypeScript frontend hosted on Vercel.
- Private Cloudflare R2 is the initial storage candidate.
- GitHub source control; Supabase CLI migration files.
- Automated unit/integration/security tests; browser acceptance tests planned.
- Keep architecture lean and validate provider tiers, pricing and limitations before deployment.

### Tenancy and security
- Resolve tenant context server-side from authenticated identity and active membership. A client school ID only selects context; validate membership and permissions.
- RLS is mandatory defence in depth. Policies fail closed and tests include cross-tenant access.
- Restricted schemas are not exposed to browser/anonymous roles.
- SQL helpers use safe search_path, fully qualified objects, least privilege; avoid SECURITY DEFINER unless a documented, reviewed need exists.
- Membership revocation must take effect immediately or within a documented cache invalidation interval.
- UUIDv4 initially; do not expose sequential IDs as public identifiers.
- Keep platform, school core, academics, school finance, private CMS, communications, restricted data, XEN billing and operations in clear domain namespaces.

### Time and currency
- Store instants as timestamptz (UTC), calendar-only facts as date, and relevant IANA timezone.
- Monetary values: integer minor units, currency code, currency-specific precision. Do not assume all currencies have two decimals.
- Conversions preserve source/target values, rate, source and timestamp as applicable. No cross-currency sums without explicit conversion.
- Zimbabwe currency/legal tender configuration must be reviewed and kept configurable rather than hardcoded.

### Finance, payments and publishing
- School finance and XEN SaaS billing are separate domains, permissions, lifecycle and reporting.
- Posted financial records are immutable; corrections use reversal/adjustment workflows.
- Verify payments server-side; use idempotency, reconciliation and auditable provider transaction references. Never trust frontend success.
- CMS authoring is private. Publish explicit approved versions; anonymous reads use safe public projections only. Unpublish invalidates cache.
- Public content must never expose student, guardian, attendance, assessment, finance, health or safeguarding data.

### Files, privacy, audit and recovery
- Private files by default. Upload to quarantine; validate type/size, scan, authorize, then use short-lived signed URLs or Worker delivery. Object keys contain no personal information.
- Public media requires explicit approval, rights and consent checks.
- Maintain data inventory, purpose/lawful basis, consent where required, access/correction, retention, deletion/anonymization, legal hold, export and incident response. Child and restricted health/safeguarding data require heightened controls and jurisdiction review.
- Audit events are append-only, restricted and avoid unnecessary sensitive payloads.
- Define backups, PITR, independent encrypted backup, key custody, restore drills and RPO/RTO. Provider backup alone is insufficient.

## Pre-production verification gates
1. Verify PostgreSQL version, region/tier, extensions, pooling, backup/PITR, pricing and Zimbabwe latency.
2. Privacy/legal review for residency, children’s data, retention, consent, school contracts and deletion/export.
3. Define RPO/RTO by domain and perform a restoration drill.
4. Compare R2 with Supabase Storage for cost, upload/download access, scanning, lifecycle and backup.
5. Select payment providers following market/legal review and sandbox tests.
6. Validate custom-domain verification, SSL, tenant routing and cache purge.
7. Review API roles/grants, RLS, and tenant-isolation threat model.
8. Confirm costs/limits, observability, secret management, deployment and rollback.
9. Define support, incident response, escalation and audit access.
10. Obtain separate implementation authorization before executable SQL, migrations, app code, CI, infrastructure or deployment.

## Change control and boundary
Amend any baseline with decision ID, change, rationale, security/tenancy/privacy/cost/migration/operations impact, alternatives, approval and document updates. This register is documentation only; it does not authorize implementation.
