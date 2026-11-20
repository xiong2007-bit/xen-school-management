# Proposed First Release Scope — XEN SCHOOL MANAGEMENT v3.0

**Status:** Recommended scope for owner and pilot-school review; NOT approved/frozen.  
**Source:** Master Plan v3.0, approved design decisions, Gate 0 audit and requirements traceability matrix.  
**Strategy:** Deliver a reliable school-operating core for Zimbabwean pilot schools before expanding into the full platform.

## 1. Release objective
Pilot a secure, tenant-isolated system with school setup, people, academic administration, daily attendance, assessment/results, admissions, guardian communication and essential fee tracking. A school must be able to complete a defined set of real workflows without spreadsheets being the source of truth for those workflows.

## 2. Proposed included scope

### Foundation (must be completed first)
- Tenant creation, school onboarding and configuration.
- Secure authentication, school memberships, scoped roles and permission checks.
- Tenant isolation and RLS; audit records for sensitive/administrative actions.
- File/document metadata and secure upload workflow.
- School/campus, academic year/calendar/term, programme/grade/form/class/subject setup.
- Responsive design; low-bandwidth payloads, safe retry and clear error states.
- Database migrations, CI checks, staging environment, monitoring and backup/restore verification.

### School core
- Student profiles, guardian relationships and verified access.
- Emergency contacts and legal/custody restriction controls.
- Staff profiles and class/subject/teacher assignments.
- Enrolment and promotion/transfer/withdrawal history.
- Configurable attendance statuses; daily or period registers; correction history and summaries.
- Assessment categories, marks, configurable grading, aggregation, moderation/approval and report cards.
- Basic admissions application, document checklist, review, offer/decision and idempotent learner conversion.
- Guardian portal: profile-linked attendance, published results, school notices and approved communications.
- Announcements and direct messaging within explicit role/guardian permissions; notification preferences and delivery status.
- Operational reports: enrolment lists, class lists, attendance summaries, approved results, admissions pipeline and basic fee balances.
- School public website: controlled pages/news/contact information and draft/review/publish workflow using a safe starter template.

### Essential finance for pilot (recommended inclusion; must be validated)
- Configurable fee items and fee schedules, scoped by class/programme/period.
- Student billing/invoices and statements.
- Record school payments (including offline/manual payment confirmation with permissions and evidence); prevent duplicate records.
- Allocation, receipts, balances and arrears.
- Credits/waivers/adjustments and refunds through controlled approval and audit workflows.
- Currency/precision configuration and explicit conversion evidence where cross-currency activity is allowed.
- Payment integration: pilot may begin with manual reconciliation; any provider integration must be selected, legally reviewed, tested and separately approved.

## 3. Proposed exclusions from first pilot
These remain in the master product vision and data architecture but are not prerequisites for the first pilot unless pilot partners demonstrate a critical need:
- Full double-entry accounting, bank reconciliation, budgets, expense management and advanced financial reports.
- Advanced provider payment integrations, recurring payments and automated reconciliation.
- Library, transport, boarding, meals, clubs, activities and trip-management modules.
- Health records, medication management and safeguarding case-management (keep any urgent school safeguarding process out of app until its restricted design is reviewed and approved).
- Advanced drag-and-drop website builder, custom domains, SEO suite, multilingual publishing and reusable template marketplace.
- Dedicated student portal (optional/future); analytics and website visitor tracking beyond privacy-safe operational metrics.
- Offline-first synchronization; low-bandwidth responsive access and safe retries remain requirements.
- School-group dashboards and multi-jurisdiction expansion beyond Zimbabwe pilot validation.

## 4. Pilot profiles and validation
Recruit at least one representative school for each relevant type if feasible, or document why the initial pilot covers only one type:
- Primary school
- Secondary school
- Combined school

Pilot stakeholders should include school administrator, bursar/accounts, teacher, admissions staff, guardian and platform support/admin. Validate the actual term/calendar, enrolment, attendance, grading, admissions, fee, guardian/legal-access and communication workflows before importing real data.

## 5. Minimum acceptance scenarios
1. School owner/admin can provision/configure the tenant, academic calendar, programmes/classes and roles.
2. A staff member cannot access records outside assigned school/campus/role scope.
3. Student and guardian records are linked only after verification; custody restrictions block disallowed access.
4. Learner can be enrolled, moved/promoted, withdrawn and re-enrolled with history preserved.
5. Teacher takes a register; corrections require authorization/reason and audit.
6. Teacher submits marks; grading/aggregation follows configured rules; authorized staff approve and publish a report.
7. Guardian sees only linked learner's published permitted records and notices.
8. Applicant submits application/documents; school reviews/decides; accepted applicant converts exactly once.
9. Bursar creates charges, records/allocates payment, issues receipt and verifies statement/balance; refunds/adjustments are authorized and audited.
10. Admin publishes a public school notice/page; only published approved content appears publicly.
11. School data export is authorized, logged and protected; tenant closure respects retention/legal hold.
12. Restore test recovers database and private file metadata/storage to a documented recovery point; integrity checks pass.
13. Critical workflows work on supported phone screen sizes and under agreed throttled network conditions.
14. CI runs migration replay, automated tests, security/tenant checks and build before a release candidate is accepted.

## 6. Proposed pilot success measures (targets to approve)
- No known critical/high tenant-isolation or privacy/security defects at pilot entry.
- 100% of defined P0 scenarios pass in release candidate.
- Finance balances reconcile for all pilot test cases; no duplicate payment allocation/receipt on retries.
- Attendance and results are reproducible from stored source records and approved rules.
- At least one school administrator, teacher and guardian from the pilot complete assigned scenarios without developer intervention, with usability issues recorded.
- Import validation reports discrepancies before live cutover; school confirms data reconciliation.
- Recovery test demonstrates the owner-approved RPO/RTO.
- Pilot issues, response owner, severity and go/no-go decision recorded.

## 7. Decisions needed before scope freeze
- [ ] Confirm whether core fees/invoices/receipts are required in pilot (recommended: yes).
- [ ] Confirm whether school public website publishing is required in pilot (recommended: simple CMS yes; advanced builder no).
- [ ] Confirm attendance cadence (daily, lesson/period, or both) for pilot schools.
- [ ] Confirm pilot grading/report-card formats and required Zimbabwe school-specific fields.
- [ ] Confirm admission fee functionality for first pilot (recommend configurable fee/waiver; provider payment not required initially).
- [ ] Confirm which school types and number of schools are included.
- [ ] Confirm manual payment recording/reconciliation acceptable for pilot.
- [ ] Confirm data-import formats, cutover approach and test-data handling.
- [ ] Approve support, training and guardian onboarding approach.
- [ ] Assign requirement owners and pilot sign-off authority.

## 8. Scope freeze rule
Once approved, this document becomes the pilot release baseline. New requests must be recorded as change proposals, assessed for cost, security, data impact, test impact and schedule, and approved or deferred. Scope freeze does not mean design rigidity; defects and security corrections remain mandatory.

**Recommendation:** Approve the pilot scope only after at least one Zimbabwean school representative validates the workflows and the owner answers the decisions above. This is a proposal and creates no implementation authorization.
