# Master Requirements Traceability Matrix (MRTM) — XEN SCHOOL MANAGEMENT v3.0

**Status:** Initial traceability baseline — documentation only; owner review required.  
**Source:** *XEN SCHOOL MANAGEMENT — Complete Combined Master Plan v3.0* (16 Nov 2026), consolidated v1.0 + v2.0; Gate 0 audit and approved design decisions.  
**Repository:** `xiong2007-bit/xen-school-management`  
**Purpose:** Trace product requirements to modules, conceptual data structures, phase, acceptance criteria and verification. This is a working baseline, not a claim that requirements have been implemented or tested.

## How to use this matrix
- **Priority:** P0 = pilot-critical foundation; P1 = core/important; P2 = phased/optional; P3 = future.
- **Release phase:** R0 foundation; R1 pilot/core school operations; R2 finance & integrations; R3 extended services/scale; R4 future.
- **Acceptance:** concise, testable outcome. Formal test case IDs and evidence are to be created during test planning.
- **Status:** All rows **Not implemented / not verified** unless marked otherwise. Requirements can be refined with owner approval; changes must be versioned.
- Conceptual entity names are indicative links to the data dictionary and schema blueprint; this matrix does not replace the schema.

## 1. Platform, tenant and onboarding

| ID | Requirement | Module / conceptual entities | Priority / Phase | Acceptance criterion | Verification | Status |
|---|---|---|---|---|---|
| XSM-PLT-001 | Operate as a commercial multi-tenant SaaS | Platform; tenants, schools | P0/R0 | Two tenant schools can operate independently; cross-tenant data access is denied | Tenant isolation tests | Not implemented |
| XSM-PLT-002 | School/campus setup and configuration | Onboarding; campuses, settings | P0/R0 | Admin completes setup wizard and saves required school configuration | E2E setup | Not implemented |
| XSM-PLT-003 | Support primary, secondary and combined schools | Configuration; school levels/programmes | P0/R0 | Each school type can configure relevant levels/forms without code changes | Configuration tests | Not implemented |
| XSM-PLT-004 | Configure locale, timezone, currency and language | Settings; locale preferences | P0/R0 | School preferences persist and display dates/amounts correctly | UI/API tests | Not implemented |
| XSM-PLT-005 | Provision a tenant with plan and entitlements | SaaS admin; tenants, plans, subscriptions | P0/R0 | Provisioning creates tenant, defaults, owner and plan limits atomically or safely retries | Integration/idempotency | Not implemented |
| XSM-PLT-006 | Support tenant lifecycle: trial, active, suspended, closed | Tenant lifecycle | P1/R0 | State changes enforce allowed actions and are audited | State-transition tests | Not implemented |
| XSM-PLT-007 | School branding and customization | Settings/theme | P1/R1 | Logo, colours and branding are configurable and applied consistently | UI acceptance | Not implemented |
| XSM-PLT-008 | Mobile-responsive access | All UI | P0/R1 | Core workflows usable at agreed mobile viewport sizes | Browser responsive tests | Not implemented |
| XSM-PLT-009 | Low-bandwidth-friendly interactions | Frontend/API | P1/R1 | Critical workflows minimize payloads, show progress, retry safely and avoid duplicate writes | Network throttling/E2E | Not implemented |
| XSM-PLT-010 | School group reporting, future only | Group entities/membership | P3/R4 | If introduced, group-level views do not bypass tenant isolation | Architecture/security review | Future |

## 2. Identity, roles and security

| ID | Requirement | Module / conceptual entities | Priority / Phase | Acceptance criterion | Verification | Status |
|---|---|---|---|---|---|---|
| XSM-IAM-001 | Secure authentication and account recovery | Auth/users/sessions | P0/R0 | Signup/login/recovery follow secure provider flows; no plaintext credentials stored | Auth tests/security review | Not implemented |
| XSM-IAM-002 | School membership and scoped roles | Memberships, roles, permissions | P0/R0 | Users may hold distinct roles/scopes; revoked membership loses access | API/RLS tests | Not implemented |
| XSM-IAM-003 | Least-privilege permissions | Permission matrix | P0/R0 | Sensitive actions require explicit capability and scope; deny by default | Authorization tests | Not implemented |
| XSM-IAM-004 | Campus/department/class scope | Scope assignments | P1/R1 | User access is limited to assigned scope | RLS/API tests | Not implemented |
| XSM-IAM-005 | Audited privileged support access | Support grants/audit | P1/R0 | Support access is time-bounded, approved, scoped and recorded | Audit/security tests | Not implemented |
| XSM-IAM-006 | Secure sessions, MFA readiness and account controls | Auth integration | P1/R0 | Session revocation and high-risk account controls are defined and tested | Security tests | Not implemented |
| XSM-IAM-007 | Audit trail for important events | Audit events | P0/R0 | Changes to access, records, finance and settings capture actor, time, action and context | Audit tests | Not implemented |
| XSM-IAM-008 | Tenant-safe API and database policies | RLS, grants, API | P0/R0 | Automated negative tests prove no cross-tenant reads/writes through client or API | RLS integration suite | Not implemented |

## 3. People, learners, guardians and staff

| ID | Requirement | Module / conceptual entities | Priority / Phase | Acceptance criterion | Verification | Status |
|---|---|---|---|---|---|---|
| XSM-PPL-001 | Student profile and lifecycle | Students, identifiers | P0/R1 | Create/update/search student; status history retained | API/UI tests | Not implemented |
| XSM-PPL-002 | Guardian records and relationships | Guardians, student-guardian links | P0/R1 | Verified relationship and permissions govern guardian access | Workflow/security tests | Not implemented |
| XSM-PPL-003 | Emergency contacts | Emergency-contact records | P1/R1 | Contacts can be designated and accessed by authorized roles only | Permission tests | Not implemented |
| XSM-PPL-004 | Legal/custody restrictions | Guardian restriction records, legal file metadata | P0/R1 | Restrictions have verification, scope, dates, review and precedence; unauthorized guardian access blocked | Scenario tests/security review | Not implemented |
| XSM-PPL-005 | Staff profiles and employment records | Staff, employment/assignments | P0/R1 | Staff record, role and assignment history can be managed | UI/API tests | Not implemented |
| XSM-PPL-006 | Duplicate detection and record correction | Identity matching/audit | P1/R1 | Duplicate candidates surfaced; merges/corrections require authorized workflow and audit | Workflow tests | Not implemented |
| XSM-PPL-007 | Bulk import and export | Import jobs, mappings | P1/R1 | Import validates, previews, reports errors and avoids partial duplicate creation | Import tests | Not implemented |

## 4. Academic structure, calendars, enrolment and timetable

| ID | Requirement | Module / conceptual entities | Priority / Phase | Acceptance criterion | Verification | Status |
|---|---|---|---|---|---|---|
| XSM-ACD-001 | Configure programmes, grades/forms, classes and subjects | Programmes, classes, subjects | P0/R1 | Admin defines academic structure and assigns students/staff | Configuration tests | Not implemented |
| XSM-ACD-002 | Multiple academic calendars | Calendars, calendar assignments | P1/R1 | School can configure separate calendars and applicability by campus/programme | Calendar tests | Not implemented |
| XSM-ACD-003 | Academic years and terms scoped to calendars | Academic years, terms | P0/R1 | Dates, names and term sequence follow selected calendar; overlapping terms only per configured policy | Date-rule tests | Not implemented |
| XSM-ACD-004 | Calendar events and holidays | Calendar events | P1/R1 | Events/holidays can apply to school, campus or programme and appear in views | UI/API tests | Not implemented |
| XSM-ACD-005 | Controlled concurrent enrolments | Enrolments, programme scope | P1/R1 | Valid multiple enrolments are supported; primary enrolment and overlap rules enforced | Integrity tests | Not implemented |
| XSM-ACD-006 | Enrolment history and transitions | Enrolment lifecycle | P0/R1 | Promotion, transfer, withdrawal and re-entry preserve history and dates | State tests | Not implemented |
| XSM-ACD-007 | Class/subject/teacher assignments | Assignments | P0/R1 | Assignments scoped by academic period and valid dates | Integrity tests | Not implemented |
| XSM-ACD-008 | Timetable periods and rooms | Periods, rooms | P1/R1 | Period/room setup supports school schedule configuration | UI/API tests | Not implemented |
| XSM-ACD-009 | Versioned timetable and exceptions | Timetable versions, entries, exceptions | P1/R1 | Published timetable is versioned; exceptions are recorded without losing prior version | Workflow tests | Not implemented |
| XSM-ACD-010 | Timetable clash detection | Clash rules | P1/R1 | Conflicts for teacher, class and room are detected before publish, with allowed exceptions explicit | Automated validation | Not implemented |

## 5. Attendance and student wellbeing

| ID | Requirement | Module / conceptual entities | Priority / Phase | Acceptance criterion | Verification | Status |
|---|---|---|---|---|---|---|
| XSM-ATT-001 | Class/period attendance registers | Attendance sessions/records | P0/R1 | Authorized teacher records attendance for assigned class/date/session | E2E tests | Not implemented |
| XSM-ATT-002 | Configurable attendance statuses | Status definitions | P1/R1 | Statuses and reason codes configurable; totals computed consistently | Unit tests | Not implemented |
| XSM-ATT-003 | Corrections with reason and audit | Attendance revisions | P0/R1 | Changes after submit require permission/reason and leave history | Audit tests | Not implemented |
| XSM-ATT-004 | Attendance summaries and alerts | Reporting/notifications | P1/R1 | Authorized users see period totals; rules can trigger configured alerts | Report/E2E tests | Not implemented |
| XSM-WEL-001 | Restricted health information | Health profiles, conditions, allergies | P2/R3 | Sensitive data only visible to designated roles; access logged | Privacy/security tests | Not implemented |
| XSM-WEL-002 | Medical visits and medication events | Visit/medication records | P2/R3 | Events are recorded with authorization, time, details and access controls | Workflow/security tests | Not implemented |
| XSM-WEL-003 | Safeguarding incidents and referrals | Incidents, referrals, action plans | P2/R3 | Restricted cases, actions and referrals are access-controlled and audited | Threat/privacy review | Not implemented |

## 6. Assessment, grading and reporting

| ID | Requirement | Module / conceptual entities | Priority / Phase | Acceptance criterion | Verification | Status |
|---|---|---|---|---|---|---|
| XSM-ASM-001 | Configure assessment categories | Categories | P0/R1 | School defines assessment types per programme/period | Configuration tests | Not implemented |
| XSM-ASM-002 | Enter, validate and edit marks | Assessments, marks | P0/R1 | Marks validate range/format and authorized edits are audited | Unit/E2E tests | Not implemented |
| XSM-ASM-003 | Configurable grading rules | Versioned grading rules | P0/R1 | Grade boundaries/labels can be versioned and applied to a defined cohort/period | Rule tests | Not implemented |
| XSM-ASM-004 | Weighting and aggregation | Assessment weights | P1/R1 | Aggregation follows configured weights, missing-mark rules and rounding | Calculation tests | Not implemented |
| XSM-ASM-005 | Moderation and approval | Moderation workflow | P1/R1 | Results can be reviewed/approved with decision and audit trail | Workflow tests | Not implemented |
| XSM-ASM-006 | Ranking and promotion rules | Ranking/promotion | P1/R1 | Ranking and promotion outcomes follow configured policy; exceptions documented | Rule tests | Not implemented |
| XSM-ASM-007 | Report cards and templates | Report-card templates/snapshots | P0/R1 | Reports generated from approved results, template and historical snapshot | PDF/UI tests | Not implemented |
| XSM-ASM-008 | Parent result publishing | Portal projection/publishing | P1/R1 | Only approved and published results visible to verified authorized guardians | Access tests | Not implemented |

## 7. Admissions

| ID | Requirement | Module / conceptual entities | Priority / Phase | Acceptance criterion | Verification | Status |
|---|---|---|---|---|---|---|
| XSM-ADM-001 | Online/offline application intake | Applicants/applications | P1/R1 | Applicant record created with configurable form and status | E2E tests | Not implemented |
| XSM-ADM-002 | Configurable admission forms and fields | Form versions | P1/R1 | Admin configures fields; submitted application retains form-version context | Version tests | Not implemented |
| XSM-ADM-003 | Application document collection | Documents/metadata | P1/R1 | Uploads private, validated and linked to application; secure access only | File-security tests | Not implemented |
| XSM-ADM-004 | Admissions review/interview/offer lifecycle | Review, interview, offer records | P1/R1 | Stage transitions require roles; decisions and dates recorded | Workflow tests | Not implemented |
| XSM-ADM-005 | Configurable application fee, waiver and refund | Versioned fee settings/snapshots | P1/R2 | Free/paid/waiver rules snapshot per application; refunds capped, approved and separate from tuition | Finance workflow tests | Not implemented |
| XSM-ADM-006 | Convert accepted applicant to learner | Conversion workflow | P1/R1 | Conversion is idempotent and carries approved data without duplicate learner creation | Integration tests | Not implemented |

## 8. Finance, payments and accounting

| ID | Requirement | Module / conceptual entities | Priority / Phase | Acceptance criterion | Verification | Status |
|---|---|---|---|---|---|---|
| XSM-FIN-001 | Fee structures and schedules | Fee items/structures | P0/R2 | Fees configured by school/programme/cohort/period and version | Configuration tests | Not implemented |
| XSM-FIN-002 | Student invoices/statements | Invoices/lines/statements | P0/R2 | Invoices are reproducible; statement balances reconcile to transactions | Finance tests | Not implemented |
| XSM-FIN-003 | Record payments and allocation | Payments/allocations | P0/R2 | Payment recorded once and allocated under approved rules | Idempotency/reconciliation | Not implemented |
| XSM-FIN-004 | Receipts and arrears tracking | Receipts/ledger/reporting | P0/R2 | Receipt issued for verified payment; arrears derive from outstanding balances | Invariant tests | Not implemented |
| XSM-FIN-005 | Waivers, credits, refunds and adjustments | Adjustment/refund records | P1/R2 | Actions require permission/reason/approval; original records preserved | Audit/finance tests | Not implemented |
| XSM-FIN-006 | Multi-currency and precision registry | Currency metadata | P0/R2 | Each currency uses configured precision; calculations avoid floating point | Calculation tests | Not implemented |
| XSM-FIN-007 | Exchange-rate conversions with evidence | Rates/conversion snapshots | P1/R2 | Conversion stores source/target amounts, rate, timestamp, source, rounding and reason | Finance tests | Not implemented |
| XSM-FIN-008 | Provider-neutral payment integrations | Provider adapters/webhooks | P1/R2 | Provider events verified, idempotent and reconciled; secrets never client-exposed | Integration/security tests | Not implemented |
| XSM-FIN-009 | Double-entry accounting architecture | Accounts/journals/periods | P2/R3 | Posted journals balance; edits use reversal/adjustment; closed periods controlled | Accounting invariant tests | Not implemented |
| XSM-FIN-010 | Expenses, budgets and bank reconciliation | Expenses/budgets/reconciliation | P2/R3 | Transactions reviewed/approved; reconciliation differences explained and tracked | Workflow tests | Not implemented |
| XSM-FIN-011 | Separate school finance from XEN billing | Domain boundary | P0/R0 | School ledgers cannot be mixed with XEN SaaS subscription ledger | Architecture/integration tests | Not implemented |

## 9. Communication, portals and public websites

| ID | Requirement | Module / conceptual entities | Priority / Phase | Acceptance criterion | Verification | Status |
|---|---|---|---|---|---|---|
| XSM-COM-001 | Announcements and targeted messaging | Messages/audience | P1/R1 | Authorized message targets specified audience; no unauthorized recipients | Audience/security tests | Not implemented |
| XSM-COM-002 | Guardian messaging and permissions | Threads/messages | P1/R1 | Guardian may message only within verified link and allowed policy | Authorization tests | Not implemented |
| XSM-COM-003 | Per-message read receipts | Read-receipt records | P2/R2 | Read receipt belongs to authorized recipient/message and does not expose other recipients | Privacy tests | Not implemented |
| XSM-COM-004 | Moderation and append-only history | Moderation actions | P2/R2 | Moderation actions preserve history, actor, reason and timestamp | Audit tests | Not implemented |
| XSM-COM-005 | Notification preferences and delivery status | Preferences/delivery | P1/R1 | User preferences respected; failed delivery and retry status visible | Integration tests | Not implemented |
| XSM-PRT-001 | Guardian portal | Guardian projection | P0/R1 | Verified guardian sees permitted learner records only | E2E/access tests | Not implemented |
| XSM-PRT-002 | Optional/future student portal | Student projection | P3/R4 | If enabled, age-appropriate permissions and separate approval; no default guardian/finance leakage | Privacy tests | Future |
| XSM-WEB-001 | School public website and CMS | Pages/content | P1/R1 | School creates pages and preview/publish/unpublish through roles | E2E tests | Not implemented |
| XSM-WEB-002 | Safe visual website builder | Blocks/templates | P2/R3 | Approved reusable blocks/templates render safely; no arbitrary script injection | Security/accessibility tests | Not implemented |
| XSM-WEB-003 | Draft, review, publishing and revisions | Content versions | P1/R1 | Publishing requires role; prior versions retained and rollback/revision possible | Workflow tests | Not implemented |
| XSM-WEB-004 | Media rights and consent controls | Media metadata | P1/R1 | Public media has permission/rights metadata and publication review | Workflow/privacy tests | Not implemented |
| XSM-WEB-005 | Custom domains and SSL lifecycle | Domain records | P2/R3 | Ownership verified, SSL status monitored and tenant routing isolated | Integration/security tests | Not implemented |
| XSM-WEB-006 | Language, SEO and public projection | Translations/SEO/public views | P2/R3 | Published pages expose approved localized metadata; private records never appear publicly | API/security tests | Not implemented |

## 10. Optional services, documents and operations

| ID | Requirement | Module / conceptual entities | Priority / Phase | Acceptance criterion | Verification | Status |
|---|---|---|---|---|---|---|
| XSM-SVC-001 | Library management | Catalogue/loans | P2/R3 | Items, borrowing, returns, overdue and permissions managed | E2E tests | Not implemented |
| XSM-SVC-002 | Transport routes and assignments | Routes/stops/vehicles | P2/R3 | Students assigned under approved transport rules; authorized contacts view status | Workflow tests | Not implemented |
| XSM-SVC-003 | Boarding management | Boarding houses/rooms | P2/R3 | Allocation and occupancy rules prevent invalid assignments | Integrity tests | Not implemented |
| XSM-SVC-004 | Meals and meal plans | Plans/orders | P2/R3 | Plans and participation tracked with permissions | Workflow tests | Not implemented |
| XSM-SVC-005 | Clubs, activities and trips | Activities/trips/permissions | P2/R3 | Participation, consent/permission and attendance captured | E2E tests | Not implemented |
| XSM-SVC-006 | Service desk/help requests | Tickets/requests | P2/R3 | Tickets have category, priority, assignment, status and audit history | Workflow tests | Not implemented |
| XSM-DOC-001 | Secure document storage metadata | Files/documents | P0/R0 | Private metadata and access controls; uploads validate type/size and are quarantined/scanned | File/security tests | Not implemented |
| XSM-DOC-002 | Retention and archival lifecycle | Retention jobs | P1/R0 | Policies trigger eligible archive/delete/anonymize; legal holds override | Governance tests | Not implemented |
| XSM-DOC-003 | Export and tenant offboarding | Export/deletion jobs | P1/R0 | Authorized export is complete, logged and protected; offboarding follows retention/hold rules | E2E/privacy tests | Not implemented |

## 11. XEN SaaS administration, analytics and governance

| ID | Requirement | Module / conceptual entities | Priority / Phase | Acceptance criterion | Verification | Status |
|---|---|---|---|---|---|---|
| XSM-SAS-001 | Subscription plans and flexible pricing | Plans/subscriptions | P0/R0 | Plan entitlements configurable without code deployment | Unit/API tests | Not implemented |
| XSM-SAS-002 | Usage limits and metering | Usage records | P1/R0 | Usage is measured consistently, deduplicated and enforceable by plan | Integration tests | Not implemented |
| XSM-SAS-003 | XEN platform admin dashboard | Admin views | P1/R0 | Authorized platform admin sees tenant/system status, not unrestricted learner data | Role/privacy tests | Not implemented |
| XSM-SAS-004 | Billing lifecycle and payment records for XEN | SaaS billing | P1/R2 | SaaS billing domain separate, auditable and reconciled | Finance tests | Not implemented |
| XSM-ANA-001 | Operational reports and dashboards | Read models/reports | P1/R1 | Reports reflect authoritative data, respect scope and can be reproduced | Report/access tests | Not implemented |
| XSM-ANA-002 | Privacy-conscious analytics | Analytics policy | P2/R3 | Tracking minimized, retention documented and no unnecessary learner tracking | Privacy review | Not implemented |
| XSM-GOV-001 | Consent and privacy controls | Consent records | P1/R0 | Consent/purpose and changes recorded where applicable; access/use follows policy | Privacy tests | Not implemented |
| XSM-GOV-002 | Retention, residency and legal holds | Governance policies | P0/R0 | Data classification, policy and jurisdiction apply; holds prevent premature deletion | Governance tests | Not implemented |
| XSM-GOV-003 | Incident response and security event handling | Incident records/runbooks | P1/R0 | Incident severity, escalation, response and evidence retention are defined | Tabletop/audit | Not implemented |
| XSM-GOV-004 | Backups and recovery | Backup/restore operations | P0/R0 | Restore drill proves defined RPO/RTO and integrity for DB and files | Recovery test | Not implemented |

## 12. Quality, delivery and acceptance

| ID | Requirement | Module / delivery | Priority / Phase | Acceptance criterion | Verification | Status |
|---|---|---|---|---|---|---|
| XSM-QA-001 | Automated unit and integration tests | CI/test suites | P0/R0 | Core domain logic and integrations have automated tests; CI blocks failing checks | CI evidence | Not implemented |
| XSM-QA-002 | Tenant isolation and RLS regression suite | Security tests | P0/R0 | Positive and negative tests cover all tenant-bound domains | Automated RLS suite | Not implemented |
| XSM-QA-003 | Migration replay and upgrade tests | Database migrations | P0/R0 | Fresh database builds reproducibly; supported upgrade path tested | Migration CI | Not implemented |
| XSM-QA-004 | Browser end-to-end and accessibility tests | UI | P1/R1 | Priority workflows work on supported mobile/desktop and meet agreed accessibility baseline | Playwright/manual audit | Not implemented |
| XSM-QA-005 | Performance and reliability targets | Load/observability | P1/R1 | Pilot targets are defined and load tests meet them under agreed workload | Load-test report | Not implemented |
| XSM-QA-006 | School pilot and feedback loop | Pilot operations | P0/R1 | Representative Zimbabwean school validates workflows; issues tracked and sign-off recorded | Pilot evidence | Not implemented |
| XSM-QA-007 | Release/rollback and deployment governance | CI/CD/operations | P0/R0 | Staging, approvals, smoke checks, migration strategy and rollback/forward plan documented and exercised | Deployment drill | Not implemented |
| XSM-QA-008 | Commercial launch readiness | Support/pricing/contracts | P1/R1 | Pricing, support, terms, onboarding and launch criteria approved | Launch checklist | Not implemented |

## 13. Release map (provisional, owner to confirm)

| Phase | Proposed deliverables | Release gate |
|---|---|---|
| R0 — Foundation | Tenant/auth/roles/RLS/audit, configuration, document metadata, platform admin, SaaS plan foundations, CI/migrations/backup baseline | Security, tenant isolation, restore and migration replay evidence |
| R1 — School pilot/core | People, enrolment, academic setup/calendars, attendance, assessment/report cards, admissions baseline, guardian portal, communications, reports, onboarding, responsive UI | Pilot workflow acceptance and privacy/security sign-off |
| R2 — Finance/integrations | Fee schedules, invoices, payment/allocation/receipts, admissions fees/refunds, multi-currency/conversions, provider integrations, SaaS billing | Finance invariants, reconciliation, provider verification |
| R3 — Extended school operations | Accounting, expenses, library, transport, boarding, meals, clubs/trips, health/safeguarding, CMS builder, domains, analytics, advanced communications | Per-module permission, privacy, operational and acceptance gates |
| R4 — Future | School-group capabilities and optional student portal; additional jurisdictions/integrations as approved | Separate scope and architecture approval |

## 14. Open owner decisions and evidence backlog
1. Confirm first-release scope and exclusions; identify what must be in the first Zimbabwe pilot.
2. Define personas and permission matrix from representative school validation.
3. Confirm workflows and acceptance criteria with primary, secondary and combined school stakeholders.
4. Decide offline capture/synchronization scope; current baseline is responsive, low-bandwidth and safe retry, not offline-first.
5. Prioritize core school finance versus full accounting in release phases.
6. Confirm reporting/analytics privacy and metrics.
7. Verify current payment providers, Zimbabwe currency/tender policy and regulatory obligations with qualified sources.
8. Decide hosting region/tier, provider capabilities, cost/limits, residency and latency.
9. Approve retention schedule, data contracts, incident plan, RPO/RTO and recovery drill.
10. Formalize requirement change-control, owner sign-off and test-case IDs.

## 15. Gate 1 exit criteria (requirements planning)
Gate 1 may be considered complete when:
- [ ] Owner-approved first release scope and explicit exclusions are attached.
- [ ] All P0 requirements have named owner, acceptance and test plan.
- [ ] R1 pilot requirements have measurable acceptance criteria and validated workflows.
- [ ] Open decisions are assigned owners and due dates.
- [ ] Provider, legal/privacy, currency/payment and hosting assumptions are clearly marked verified or pending.
- [ ] A test plan and pilot acceptance plan are approved.
- [ ] Owner signs scope baseline and change-control approach.

**Current result: IN PROGRESS — matrix drafted, owner scope review and stakeholder validation pending.**
