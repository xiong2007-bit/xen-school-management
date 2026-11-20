# Technical Decision Register — XEN SCHOOL MANAGEMENT v3.0

**Status:** Owner-approved baseline (20 November 2026). This approval accepts the recommended defaults as the project's architecture direction. Implementation remains separately gated; any provider-dependent, legal, operational, or security detail listed as a pre-implementation verification item must be resolved before production.

## Approval record
The owner approved the recommendations in this register as a whole. Approved baseline choices are not to be silently changed; material changes require an amendment with rationale, impact, and approval. Acceptance of the direction does not imply provider capability, legal compliance, or readiness to deploy.

## Decision summary

| ID | Topic | Approved baseline | Status / remaining verification |
|---|---|---|---|
| TDR-01 | Database platform | Supabase-managed PostgreSQL | Approved; confirm version/features at setup |
| TDR-02 | Region/tier | Select by latency, privacy, budget, availability, backups and recovery | Approved criteria; final region/tier must be verified |
| TDR-03 | Schema organization | Domain schemas with controlled exposure; restricted schemas not browser/anonymous exposed | Approved |
| TDR-04 | Auth | Supabase Auth linked by UUID; no credentials replicated | Approved |
| TDR-05 | API access | API-first Cloudflare Workers for sensitive/core workflows; direct access only explicitly reviewed; RLS mandatory | Approved |
| TDR-06 | Migration tooling | Supabase CLI migrations in Git; reviewed and tested | Approved |
| TDR-07 | IDs | UUIDv4 initially | Approved; reconsider UUIDv7 only with documented case |
| TDR-08 | Tenant context | Derive active tenant membership from authenticated subject; do not trust client tenant/role claims alone | Approved |
| TDR-09 | RLS helpers | Safe search_path, least privilege, fail closed, SECURITY DEFINER avoided unless justified and reviewed | Approved |
| TDR-10 | Time/date | timestamptz for instants, date for calendar facts, IANA timezone context; UTC storage | Approved |
| TDR-11 | Currency/money | Currency code + integer minor units and currency precision registry; explicit conversion snapshots | Approved |
| TDR-12 | Finance ledger | Separate school finance and XEN SaaS billing domains; immutable posted entries and reversals | Approved |
| TDR-13 | File storage | Private Cloudflare R2 as baseline candidate; secure upload, quarantine/scan, short-lived authorized access | Approved direction; validate cost, features and backup |
| TDR-14 | CMS publishing | Private authoring and explicit approved publication versions/projection; safe anonymous reads only | Approved |
| TDR-15 | Payments | Provider-neutral adapters, server-side verification, idempotency and reconciliation | Approved design; provider selection/sandbox verification pending |
| TDR-16 | Privacy/retention | Data inventory, jurisdiction-specific retention, legal holds, export/deletion and incident process | Approved approach; legal durations/review pending |
| TDR-17 | Backups/recovery | Managed backup/PITR where available, independent encrypted backup and restore drills; define RPO/RTO | Approved approach; service targets and tier pending |
| TDR-18 | Testing/CI | Migration replay, realistic RLS roles, tenant-isolation, finance, privacy, files and API tests | Approved |
| TDR-19 | Deployment split | React+TypeScript frontend on Vercel; Cloudflare Workers API; Supabase DB/Auth; R2 baseline candidate; GitHub | Approved baseline; operational fit/free-tier constraints verify |
| TDR-20 | Secrets | Managed server-side secrets; never in frontend/Git; rotation and access audit | Approved |
| TDR-21 | Audit | Append-only audit events, restricted access, avoid sensitive payloads | Approved |
| TDR-22 | Domains/custom domains | Domain verification, tenant mapping, SSL, cache invalidation | Approved requirements; vendor/workflow detail pending |
| TDR-23 | Analytics | Start with PostgreSQL queries/views; add analytics platform only for measured needs | Approved |
| TDR-24 | API/schema exposure | Expose only reviewed surface; restricted schemas stay private; privileged functions/views tested | Approved |

## Approved technical baseline

### Platform and deployment
- **Database:** Supabase-managed PostgreSQL.
- **Identity:** Supabase Auth; application profile and school memberships separate from auth identity.
- **Backend/API:** Cloudflare Workers, API-first for core/sensitive workflows.
- **Frontend:** React + TypeScript; Vercel hosting.
- **Object storage:** private Cloudflare R2 baseline candidate.
- **Source control:** GitHub.
- **Migrations:** Supabase CLI, committed to repository and reviewed.
- **Tests:** automated unit/integration/security tests; browser acceptance tests planned.
- Keep the platform intentionally lean and validate plan limits and costs before deployment.

### Tenancy, security and database
- Tenant context must be resolved server-side from authenticated user and active membership; a client-provided school ID is only a selector and must be validated.
- PostgreSQL RLS is mandatory defense-in-depth; all policies fail closed and are tested for cross-tenant access.
- Private/restricted schemas are not exposed to browser/anonymous API roles.
- SQL helper functions use safe search paths and least privilege. Avoid SECURITY DEFINER unless a reviewed need exists.
- Use UUIDv4 initially. Never expose sequential identifiers as public identifiers.
- Domain schemas/namespaces keep platform, school core, academics, school finance, CMS/private, communications, restricted data, XEN billing and operations separated.
- Auth credentials and privileged secrets are never copied into application records or frontend code.

### Time and currency
- Store instants as timestamptz (UTC); use date for date-only facts; store relevant IANA timezone.
- Monetary values use integer minor units and currency codes with currency-specific precision. Do not assume two decimal places.
- Conversions store source amount/currency, target amount/currency, rate, source and timestamp as applicable. No cross-currency summation without explicit conversion.
- Zimbabwe currency and tender rules must be configurable and reviewed against current law/policy; no single global currency is hardcoded.

### Finance, payments and public content
- School finance and XEN SaaS billing are separate domains, lifecycle and permission systems.
- Posted ledger entries are immutable; correction uses reversal/adjustment.
- Payment confirmation is server-side verified and idempotent; reconcile provider transactions; do not trust browser success.
- CMS authoring is private; publication creates explicit version/status. Anonymous reads only approved public projections and media; unpublish invalidates cache.
- Public pages must not expose student, guardian, attendance, assessment, finance, health or safeguarding data.

### File security
- Private objects by default; object keys contain no personal information.
- Upload to quarantine, validate type/size, scan, authorize, then serve by short-lived signed URL or Worker-mediated delivery.
- Public assets require explicit publication/rights/consent checks. Metadata and object lifecycle/retention are tracked.

### Privacy, audit and recovery
- Maintain data inventory, purpose, lawful basis/consent where applicable, access/correction, retention, deletion/anonymization, legal holds, exports and incident response.
- Children's data and restricted health/safeguarding data require heightened access controls and jurisdiction-specific review.
- Audit is append-only and access-restricted; avoid unnecessarily storing sensitive payloads.
- Backups, PITR, independent encrypted backups, key custody, restore drills and RPO/RTO must be documented and tested. A provider's backup feature alone is not sufficient.

## Pre-implementation verification gates
These are not architecture reversals; they are required due diligence before selecting production services or creating production migrations:
1. Confirm Supabase PostgreSQL version, region, tier, extensions, pooling, backup/PITR, pricing and latency.
2. Confirm legal/privacy review for data residency, child data, retention, consent, school contracts and deletion/exports.
3. Define RPO/RTO by domain; test backup restoration and recovery procedure.
4. Validate R2 vs Supabase Storage costs/features, file scanning, signed access, backup and lifecycle.
5. Select payment providers after Zimbabwe/international market and legal feasibility review; sandbox and webhook verification.
6. Validate domain verification, SSL, tenant routing and cache purge behavior.
7. Confirm API exposure and role/grant model; review RLS policies and tenant isolation threat model.
8. Confirm hosting plan limits, costs, observability, secrets and deployment/rollback procedures.
9. Decide operational support, incident response, escalation and audit access.
10. Obtain final implementation-stage authorization before executable SQL, migrations, application code, CI, infrastructure or deployment.

## Change control
Any change to this baseline must be recorded as an amendment with decision ID, proposed change, reason, impact (security, tenancy, privacy, cost, migration compatibility, operations), alternatives considered, owner approval, and update to relevant documents.

## Implementation boundary
This is architecture documentation only. It does not authorize or constitute SQL migrations, executable schema, seed data, application code, CI workflows, infrastructure provisioning, or deployment.
