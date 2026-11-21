# Stage 4 — Implementation Readiness Gate

**Version:** XEN SCHOOL MANAGEMENT v3.0 / Stage 4 draft  
**Date:** 21 November 2026  
**Status:** Gate definition and checklist proposed. No implementation authorization granted.

## 1. Gate purpose

Decide whether the project is sufficiently defined, governed, secured, resourced and testable to begin implementation of the approved pilot scope. A checklist being documented or checked is not proof of evidence unless the evidence is reviewed and accepted by the named owner.

## 2. Required gates

### A. Product and pilot scope
- [ ] Master Plan v3.0 and proposed first-release scope reviewed; scope exclusions explicit.
- [ ] Pilot schools, school types, target term/year and stakeholders named.
- [ ] Stage 3 workflows, stories and acceptance criteria validated by school representatives.
- [ ] Prioritized backlog and sprint plan reviewed; capacity and owners assigned.
- [ ] Change-control, critical defect definitions and pilot success measures agreed.

### B. Technical architecture and environment
- [ ] Architecture/provider/region decision signed; Zimbabwe user latency and applicable privacy requirements assessed.
- [ ] Supabase project/tier/version/extensions/auth/backup capability verified.
- [ ] Vercel/Cloudflare/R2 choices, quotas, cost limits and security fit verified.
- [ ] API responsibilities, client access rules, secret management and environment separation defined.
- [ ] Development, staging, production separation and deployment approval/rollback plan documented.

### C. Security, privacy and governance
- [ ] Threat model and tenant isolation design reviewed.
- [ ] Role, permission, campus/class/subject scope and guardian-access matrix approved.
- [ ] Child-data/privacy lawful-purpose, consent/notice, rights, retention, deletion/legal hold and cross-border transfer review complete.
- [ ] Health/safeguarding remain excluded or restricted with an approved process and design.
- [ ] Support access approval, expiry, scope and audit rules approved.
- [ ] Incident response, breach escalation, vendor/subprocessor and school contract requirements reviewed.
- [ ] Public CMS projection, export allowlist and file upload controls specified.

### D. Data and import
- [ ] Pilot data inventory and data owner assigned.
- [ ] Source formats, identifiers, data quality and permitted data scope confirmed.
- [ ] Mapping, transformations, duplicate policy, exceptions and import order approved.
- [ ] Dry-run/reconciliation process and recovery method demonstrated in a non-production test.
- [ ] Data access, encrypted transfer/storage and disposal schedule approved.
- [ ] No real data is required for implementation until authorization and safeguards are in place.

### E. Test and quality
- [ ] Test-case inventory reviewed and mapped to requirements/workflows.
- [ ] CI, test environments, synthetic fixtures and test-data policy agreed.
- [ ] Critical permission/tenant isolation, guardian restrictions, finance, import and publication cases included.
- [ ] Accessibility, supported-device, low-bandwidth and performance targets set.
- [ ] Backup/restore and recovery tests planned; RPO/RTO approved.
- [ ] Defect triage, severity, retest and evidence record defined.

### F. Delivery and operations
- [ ] Team/skills/availability and budget/cost ceiling confirmed.
- [ ] Sprint capacity, dependency ownership and review responsibilities assigned.
- [ ] Monitoring, alerting, support rota/contact, incident runbook and service expectations defined.
- [ ] School training, pilot communications, feedback process and rollout/rollback plan prepared.
- [ ] Legal/contract terms, subscription/payment scope and pilot support boundaries reviewed.

## 3. Gate outcomes

- **GO:** all mandatory evidence reviewed; no unresolved critical blockers; named approvers sign; implementation authorization is explicit and limited to the approved scope.
- **GO WITH CONDITIONS:** only non-critical items may remain, with owner, due date, compensating control and explicit approval. Must not waive critical security, privacy, child-safety, financial integrity or recovery controls.
- **NO-GO:** missing owner/stakeholder scope approval, unresolved legal/privacy/security risk, tenant isolation unproven, unsafe guardian restrictions, unbounded sensitive-data access, finance/import integrity controls missing, no recovery plan, or critical dependencies unavailable.

## 4. Proposed signoff roles

| Role | Required decision / evidence |
|---|---|
| Product owner / XEN project lead | Scope, prioritization, acceptance and explicit implementation authorization |
| Pilot school representative | Workflow and policy validation; pilot operational acceptance |
| Technical lead | Architecture, dependency, build/test and deployment readiness |
| Security/privacy reviewer | Threat model, child-data, tenant isolation, access, incident and governance review |
| Data owner / migration lead | Source authorization, mapping, reconciliation, recovery and data signoff |
| Finance owner (if pilot finance included) | Currency, payment, balance, reconciliation, adjustment/refund controls |
| Operations owner | Backup, restore, monitoring, support and incident readiness |

## 5. Evidence register and decision record

| Gate item | Evidence/link | Owner | Status | Issue/condition | Reviewer/date |
|---|---|---|---|---|---|
| Scope | | | Pending | | |
| Architecture | | | Pending | | |
| Security/privacy | | | Pending | | |
| Data/import | | | Pending | | |
| Quality/testing | | | Pending | | |
| Operations | | | Pending | | |

**Decision:** [ ] GO  [ ] GO WITH CONDITIONS  [ ] NO-GO  
**Conditions / blockers:**  
**Approvers and dates:**  
**Approved scope:**  
**Explicit authorization to begin implementation:** [ ] Yes [ ] No

## 6. Current status summary

Stage 4 planning documents are drafted, not validated. Stage 3 acceptance remains pending school stakeholders. Gate 0 is PASS WITH ACTIONS. Architecture baseline is approved at conceptual level, but provider/region, cost, legal/privacy, RPO/RTO, operational environment and school-specific policies require evidence. Therefore the current recommendation is **NO-GO for implementation until mandatory gate items are reviewed and signed**.

**Stage 4 status:** Documentation complete for review; implementation readiness not achieved and no code/migrations/infra/imports are authorized.
