# Pre-Implementation Readiness Checklist — XEN SCHOOL MANAGEMENT v3.0

**Status:** Gate 0 audit completed with actions; architecture baseline approved; Gates 1–7 verification evidence pending. No implementation authorization is implied.

This checklist tracks readiness before executable database migrations and code are created. Items are marked `[ ]` until evidence is reviewed and accepted.

## Gate 0 — Project and scope freeze
- [x] Confirm master plan v3.0 is authoritative and the data dictionary, relationship specification, constraints/RLS, schema blueprint, migration manifest and 13 approved design decisions were cross-checked against it (Gate 0 audit report).
- [x] Confirm intended module scope and phased/future modules from Master Plan v3.0.
- [ ] Finalize exact first-release scope and explicit exclusions (owner prioritization still required).
- [x] Confirm school types (primary, secondary, combined), Zimbabwe-first market assumptions, role groups and personas from Master Plan v3.0.
- [x] Draft unique requirement IDs and acceptance criteria in the [Master Requirements Traceability Matrix](requirements-traceability-matrix.md) (owner review and stakeholder validation pending).
- [x] Define change-control principle for scope and architecture amendments in the approved technical baseline.
- [x] Confirm Master Plan v3.0 glossary and key terminology; extend as implementation-specific terms are added.

**Evidence:** Master Plan v3.0, [Gate 0 audit report](gate-0-scope-consistency-audit.md), approved decisions, architecture baseline and [requirements traceability matrix](requirements-traceability-matrix.md). **Gate 0 status: PASS WITH ACTIONS** (first-release scope, owner validation and stakeholder acceptance remain open).

## Gate 1 — Architecture and environment verification
- [ ] Verify selected Supabase PostgreSQL version, extensions, region, tier, connection pooling, API exposure, Auth settings and backup capabilities.
- [ ] Evaluate latency from target Zimbabwe users and legal/privacy implications of region.
- [ ] Confirm Vercel and Cloudflare plan constraints, cost, quotas, limits and operational fit.
- [ ] Confirm API-first Worker responsibilities and permitted direct client operations.
- [ ] Confirm private storage provider and file security workflow.
- [ ] Define local, staging and production environments and separation.
- [ ] Define configuration and secrets strategy, rotation and least-privilege access.
- [ ] Define deployment approvals, rollback/forward-fix, smoke tests and monitoring.

**Evidence:** environment decision sheet, provider comparison, cost estimate, configuration/security plan.

## Gate 2 — Data governance and risk
- [ ] Complete data inventory by module and sensitivity/classification.
- [ ] Complete privacy/legal review for Zimbabwe pilot and future target jurisdictions.
- [ ] Define purposes/lawful basis, consent where applicable, data subject rights, retention, deletion/anonymization and legal holds.
- [ ] Establish child-data safeguards and guardian verification rules.
- [ ] Approve restricted health/safeguarding access model and audit.
- [ ] Define data residency, cross-border transfer, vendor/subprocessor review and school contracts.
- [ ] Define incident response, breach escalation and notification process.
- [ ] Confirm public-content/media consent, rights and review workflow.
- [ ] Define export and school offboarding/tenant closure process.

**Evidence:** data map, privacy/risk register, retention schedule, access matrix, incident plan.

## Gate 3 — Security and tenancy
- [ ] Define tenant membership, roles, permissions, campus scopes and delegation model.
- [ ] Threat-model cross-tenant access, IDOR, role escalation, account recovery, session abuse and public API exposure.
- [ ] Define tenant-context resolution and revocation/cache behavior.
- [ ] Define RLS policy standards and reviewed helper patterns.
- [ ] Define database roles/grants and schema/API exposure allowlist.
- [ ] Define audit event schema, protected access, retention and integrity requirements.
- [ ] Define rate limiting, abuse protection, input validation and idempotency.
- [ ] Define secure file upload/download, scanning, quarantine and signed access.
- [ ] Specify security test scenarios and minimum release criteria.

**Evidence:** threat model, role matrix, RLS standards, security test plan.

## Gate 4 — Financial and integration readiness
- [ ] Define currency precision registry, rounding rules, conversion source/timestamp and exchange-rate approval.
- [ ] Confirm Zimbabwe currency/tender configuration through current legal/commercial review.
- [ ] Review school finance workflows: invoices, payments, allocations, receipts, refunds, arrears, reconciliation, waivers and adjustments.
- [ ] Define accounting ledger posting/reversal, periods, audit and approval controls.
- [ ] Keep school financial domain and XEN SaaS billing separate.
- [ ] Select payment providers after market/legal feasibility review.
- [ ] Define provider adapter contracts, webhook verification, idempotency, reconciliation, refund/chargeback and failure handling.
- [ ] Define external integration inventory, ownership, credentials, scopes and failure/retry policy.

**Evidence:** finance workflow specifications, currency policy, integration/provider decisions.

## Gate 5 — Database migration readiness
- [ ] Reconcile table list, columns, PK/FK, uniqueness, checks, delete/update behavior and tenant-safe composite keys against schema blueprint.
- [ ] Confirm naming conventions, schema/domain boundaries, enum/reference-table approach and status lifecycle.
- [ ] Confirm UUID generation, timestamps, timezone, money representation and soft-delete/archival rules.
- [ ] Confirm indexes with query patterns, uniqueness and foreign-key support.
- [ ] Review every table's sensitivity, tenant scope, RLS intent, grants and API exposure.
- [ ] Review each relationship for cross-tenant leakage and valid lifecycle.
- [ ] Validate migration dependency ordering and phased module boundaries.
- [ ] Identify seed/reference data and its source/ownership.
- [ ] Define migration review, fresh-database replay, drift detection and failure recovery.
- [ ] Confirm destructive changes require backup, plan and approval.
- [ ] Define data migration/import strategy for pilot schools, including validation and reconciliation.

**Evidence:** signed schema review, migration sequence, query/index plan, import plan.

## Gate 6 — Quality and test readiness
- [ ] Define acceptance criteria for each release/module.
- [ ] Define unit, integration, RLS/tenant isolation, API, browser, accessibility and regression test approach.
- [ ] Plan realistic test users/roles and synthetic test datasets.
- [ ] Define finance invariants and reconciliation tests.
- [ ] Define privacy, consent, export/deletion and file-security tests.
- [ ] Define migration replay tests against fresh PostgreSQL and upgrade-path tests.
- [ ] Define CI checks, dependency scanning, secret scanning, lint/type checks and build.
- [ ] Establish release blockers, severity thresholds and defect triage.
- [ ] Plan performance/load testing and target service-level expectations.

**Evidence:** test strategy, test cases, CI quality gates, acceptance matrix.

## Gate 7 — Operations and launch
- [ ] Define per-domain RPO/RTO and service-level objectives for pilot.
- [ ] Confirm backups, PITR, independent encrypted backups, access/key custody and retention.
- [ ] Perform restoration drill and verify database, files, auth, DNS, secrets and app consistency.
- [ ] Define monitoring, alerts, logs, metrics, tracing and privacy-safe telemetry.
- [ ] Define support desk, school onboarding, tenant provisioning, escalation and incident roles.
- [ ] Define maintenance windows, release notes, migration downtime policy and rollback/forward-fix.
- [ ] Define custom-domain ownership verification, SSL, tenant routing and cache purge.
- [ ] Prepare pilot school onboarding, training, data import, acceptance and feedback.
- [ ] Complete commercial pricing, billing/support terms and school contract review.

**Evidence:** recovery test report, operations runbook, onboarding plan, launch checklist.

## Gate 8 — Owner implementation authorization
- [ ] Owner confirms readiness evidence for Gates 0–7.
- [ ] Any remaining high-risk open items have named owners, mitigations and deadlines.
- [ ] Confirm first implementation phase and its exact scope.
- [ ] Confirm authorization is for a specific deliverable (e.g., migration foundation only), not unrestricted production deployment.
- [ ] Record approval date and approved scope.

**Only after this gate is explicitly approved may implementation begin.** Authorization should be scoped by stage: foundational migration set, security/RLS implementation, core modules, tests, staging, and production release.

## Current status summary
- **Architecture direction:** owner-approved.
- **Product/design decisions:** all 13 accepted.
- **Conceptual data dictionary, relationships, constraints, blueprint and migration manifest:** documented.
- **Technical baseline:** documented and approved.
- **Readiness gates:** not yet evidenced/closed.
- **SQL migrations, application code, CI, infrastructure and deployment:** not started/authorized.

