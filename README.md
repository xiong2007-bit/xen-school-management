# XEN SCHOOL MANAGEMENT v3.0

A clean, documentation-first monorepo scaffold for the XEN TECHNOLOGIES school-management SaaS platform.

## Project status

**Stage:** repository scaffold and architecture planning only.  
**Application code:** intentionally not included.  
**Database implementation:** not included; the approved database blueprint is conceptual documentation at this stage.

## Product scope

XEN SCHOOL MANAGEMENT is a multi-tenant SaaS platform designed for primary, secondary and combined schools, launching in Zimbabwe before expanding internationally. It brings together four connected experiences:

1. Individually designed public school websites.
2. A private school management workspace.
3. Parent/guardian and optional student portals.
4. The XEN platform administration console.

## Approved technology direction

- Frontend: React + TypeScript
- API/business logic: Cloudflare Workers
- Database and authentication: Supabase (PostgreSQL and Supabase Auth)
- Database access control: PostgreSQL Row Level Security
- File storage: Cloudflare R2
- Frontend hosting: Vercel
- DNS, edge security and routing: Cloudflare
- Source control: GitHub
- Planned testing: Vitest and Playwright
- Planned monorepo tooling: pnpm workspaces and Turbo

These are approved architectural directions, not installed or configured dependencies.

## Repository structure

- `apps/` — web application, API and marketing experience boundaries.
- `packages/` — shared UI, types, validation, tenancy, permissions and platform capabilities.
- `supabase/` — reserved for future database assets; no migrations or executable database code yet.
- `infrastructure/` — deployment, storage, domains, monitoring and backup planning.
- `tests/` — future test suites, including tenant-isolation and security tests.
- `docs/` — product, architecture, database, API, module, security and operational documentation.
- `scripts/` — reserved for future approved tooling; no scripts included.

## Key architecture principles

- Every school's private records must be tenant-scoped and protected by server-side authorisation and database RLS.
- Guardian access must be based on verified guardian-to-student relationships.
- Public school websites must expose only approved published content.
- Private learner, guardian, attendance, marks, medical and financial records must never be exposed through public website APIs.
- Financial records must preserve audit history; posted transactions should be reversed or adjusted rather than silently overwritten.
- XEN SaaS subscription billing must remain separate from each school's operational fee and finance records.
- Secrets must never be committed to GitHub or exposed to browser code.

## Finance delivery approach

The complete finance architecture is planned up front, with implementation phased. The first finance release is intended to cover fee structures, invoices, verified payments, allocations, receipts and balances. Advanced accounting, reconciliation, bursaries, refunds, budgets and supplier workflows are later phases.

## Working agreement for this stage

This repository is deliberately a scaffold, not a running application. It contains folder placeholders and planning documentation only. Do not treat the presence of a folder as evidence that its feature has been implemented. Application code, SQL migrations, dependency manifests, CI workflows and deployment configuration will be added only in a separately authorised implementation stage.

## Next planning artefacts

The documentation folders provide the locations for the approved v3.0 product plan, architecture decisions, conceptual database dictionary and relationship specification, API contracts, module specifications, security model, deployment plan and testing strategy.
