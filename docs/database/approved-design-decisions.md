# Approved Design Decisions — XEN SCHOOL MANAGEMENT v3.0

**Status:** Approved by product owner. These decisions govern the design baseline. They do not authorize implementation.
**Approval:** User accepted all 13 recommended decisions on 2026-11-20.
**Scope:** Complete architecture planned; implementation may be phased as separately approved.

## Decision summary

| # | Area | Approved decision |
|---|---|---|
| 1 | Academic calendars | C — Flexible calendars supporting multiple calendars, overlapping terms, varied dates, holidays, campuses and programmes. |
| 2 | Student enrolments | C — Controlled multiple enrolments, with defined rules and a primary enrolment; preserve transfer, programme-change and enrolment history. |
| 3 | Grading and report cards | C — Fully configurable assessment engine: grading scales, assessment types, weighting, coursework/exams, grade boundaries, aggregation, ranking, promotion rules, comments and report layouts. |
| 4 | Currency | C — Full multi-currency finance, including currency-specific invoices/payments/balances and explicit exchange-rate/conversion records. Never combine unlike currencies without conversion. |
| 5 | Accounting | C — Full accounting architecture including double-entry journals, chart of accounts, accounting periods, bank reconciliation, expenses, budgets, approvals and reports; implementation phased. |
| 6 | Admissions fees | C — Each school configures free/paid applications, fee amount/currency, waiver and refund rules. Admissions charges remain separate from tuition and other school fees. |
| 7 | Guardian/legal access | C — Advanced access management for verified relationships, restrictions, custody/legal orders, authorised/emergency contacts and granular permissions. Restrict sensitive legal records. |
| 8 | Health/safeguarding | C — Dedicated restricted modules for medical information, visits, incidents, safeguarding concerns, referrals and action plans. Phased implementation; access is need-to-know. |
| 9 | Website publishing | C — Mixed publishing control: schools manage ordinary content and design; platform retains technical/security controls and may require review for designated sensitive content. Drafts, preview, revisions, rollback and consent safeguards. |
| 10 | Communication | C — Full communication system including direct/group messages, announcements, attachments, notifications, read receipts, permissions, moderation and history; configurable rules for student/teacher/guardian communication. |
| 11 | School services | C — Broad optional ecosystem planned for transport, boarding, meals, clubs, activities, trips, permissions and associated attendance; phased rollout. |
| 12 | SaaS pricing | C — Flexible commercial model configurable by learner count, modules, storage, campuses, integrations, support and optional services. Plan tiers (Starter, Growth, Professional, Enterprise) are concepts, not final prices. |
| 13 | Data governance | C — Flexible governance including residency policy support, retention, backup/recovery, deletion/anonymisation, export, legal holds and incident response; initial deployment may use affordable central cloud infrastructure. |

## Implementation implications

- Build the logical model and security architecture to support these decisions before implementation, avoiding premature omission of required entities and relationships.
- Use phased delivery without sacrificing architectural support: accounting, health/safeguarding, school services, communication and internationalisation may launch later.
- Maintain tenant boundaries and least-privilege access. Sensitive health, safeguarding, custody/legal, financial and identity data require additional classification and controls.
- Multi-currency records must include currency and exact monetary values; conversions must record the applicable rate, date/source and converted amounts. Never use floating point for money.
- Published public school website content is isolated from private student, guardian, finance, health and safeguarding data.
- Keep school operational finance separate from XEN's SaaS subscription billing.
- Treat pricing, legal/compliance requirements, payment providers, data residency choices and detailed workflows as configuration/implementation decisions requiring further validation—not as already finalized.

## Approval boundary

This approved baseline updates the design specification only. **No application code, SQL migrations, executable schema, seed data, infrastructure deployment or implementation has been authorized by this approval.** Next step: prepare and review the database implementation roadmap, migration sequence, and detailed security/RLS design for separate approval.
