# Stage 3 — Pilot Workflows, User Stories & Acceptance Criteria

**Version:** XEN SCHOOL MANAGEMENT v3.0 / Stage 3 draft  
**Date:** 21 November 2026  
**Status:** Draft for product-owner and pilot-school validation. Documentation only.  
**Scope source:** Complete Combined Master Plan v3.0, approved 13 design decisions, Gate 0 audit, Master Requirements Traceability Matrix, proposed first-release scope, database blueprint and migration manifest.

## 1. Purpose and authority

This document converts the proposed pilot scope into end-to-end workflows and testable user stories. It is a planning baseline only: none of these workflows is implemented or tested. Stories are proposed for review; school-specific rules, data fields, role assignments, and exact test evidence remain to be validated. It does not grant implementation authorization.

## 2. Personas and guardrails

| Persona | Pilot responsibility | Guardrails |
|---|---|---|
| XEN platform operator | Provision tenant, monitor safe metadata, respond to support requests | School personal data access only via scoped, approved, time-bound and audited support grant |
| School owner/admin | Configure school, users, academic structure, operational settings | Cannot bypass restrictions, immutable finance/audit or separation of duties |
| Principal/head | Review academic/attendance/operational summaries, approve delegated workflows | Sensitive domains require explicit permissions |
| Admissions officer | Process applications and decisions | Access limited to admissions data and authorized conversion |
| Teacher | Assigned class/subject registers, marks, notices | Only assigned school/campus/class/subject scope; no finance/HR/restricted records |
| Bursar/finance clerk | Fees, invoices, payment recording and receipts | Separate duties for verification/refund/adjustments as school config requires; never SaaS billing admin |
| CMS editor/publisher | Draft/review/publish approved public content | CMS-only; publication must not expose private records |
| Guardian | Access linked learner's approved portal content and messages | Verified active link, per-child permission, valid dates, legal restrictions override |
| Student | Future/optional pilot persona | Dedicated student portal is outside proposed first release; no assumed access |
| Pilot reviewer | Observe, sign acceptance or log issues | Uses synthetic or school-approved test data; no unrestricted production access |

## 3. Workflow inventory and release priority

| Workflow ID | Workflow | Proposed priority | Dependencies |
|---|---|---|---|
| WF-01 | Provision tenant and onboard school | P0 | Tenant, Auth, roles, audit |
| WF-02 | Configure academic structure and calendar | P0 | School configuration |
| WF-03 | Invite staff and grant scoped roles | P0 | Identity/membership |
| WF-04 | Create student, guardian, verify link/restrictions | P0 | People, files, permissions |
| WF-05 | Enrol, promote/transfer/withdraw/re-enrol | P0 | Academic structure, history |
| WF-06 | Import legacy data safely | P1 | Import/validation, people/enrolment |
| WF-07 | Take attendance and correct register | P0 | Timetable/class/enrolment |
| WF-08 | Configure assessments, enter/moderate/publish results | P0 | Academic assignments, grading rules |
| WF-09 | Admissions application/review/offer/conversion | P1 | Admissions, files, people/enrolment, idempotency |
| WF-10 | Configure fees, invoice, record/allocate payment, receipt | P0 pilot finance (scope decision) | Finance, currency, permissions |
| WF-11 | Waiver/adjustment/refund workflow | P1 | Finance approval, audit |
| WF-12 | Guardian portal onboarding and access | P0 | Verified link, permissions, legal restriction |
| WF-13 | Notices and permitted messaging | P1 | Communication permission, moderation |
| WF-14 | Public website draft/review/publish/unpublish | P1 | CMS safe projection, domain/cache controls |
| WF-15 | Operational reporting and authorized export | P1 | Domain access, report filters, audit |
| WF-16 | Tenant offboarding, export, retention and closure | P1 | Governance/legal holds/retention |
| WF-17 | Support access and incident triage | P1 | Support grant, audit, least privilege |
| WF-18 | Backup recovery and release acceptance | P0 gate | Operational readiness |

## 4. Detailed workflows and user stories

### WF-01 — Provision tenant and onboard school

**Goal:** create a tenant and initialize a school safely, without duplicating provisioning on retry.

**Actors:** XEN operator; school owner/admin. **Preconditions:** tenant provisioning authority; plan/entitlement configuration; unique normalized school slug; onboarding agreement and pilot record.

1. Operator starts tenant provisioning and enters the minimum school identity, contact and type (primary/secondary/combined), country, locale, timezone and currency configuration.
2. System validates uniqueness and required fields and displays a review summary.
3. Operator confirms. System creates tenant, school settings, owner invitation, baseline permissions and audit/provisioning record as one logical operation or safely retryable workflow.
4. Owner accepts invitation, completes authentication and required account controls, then confirms school profile and branding.
5. Owner can see onboarding checklist; tenant state is trial/active according to approved SaaS configuration.
6. Operator can view safe operational status; sensitive school records are not available by default.

**Stories:**
- ST-01.1 As a platform operator, I can provision a school with a unique tenant identifier so its data is isolated from all other tenants.
- ST-01.2 As a school owner, I can accept an invitation and finish school setup without the operator knowing my password.
- ST-01.3 As an operator, I can retry failed provisioning without creating duplicate tenants, owner invitations, or default records.

**Acceptance criteria:**
- AC-01.1 A school cannot be provisioned with a duplicate normalized slug or conflicting tenant identity.
- AC-01.2 A provisioning retry with the same idempotency key produces one tenant and one intended owner membership; failure is surfaced and recoverable.
- AC-01.3 Owner invitation is time-limited, single-use, and does not disclose credentials.
- AC-01.4 A school is not usable until required setup and status conditions are satisfied.
- AC-01.5 Tenant A's user cannot read or enumerate Tenant B records by changing IDs, URL, query, export or API request.
- AC-01.6 Provisioning, activation, suspension and privileged support events are auditable.

**Exceptions:** duplicate slug; invalid locale/timezone/currency; invitation expired/revoked; provisioning partial failure; plan quota exceeded; school suspended.

### WF-02 — Configure academic calendar and structure

**Goal:** configure the school's academic model without assuming one calendar fits every campus/programme.

**Actors:** school admin; principal reviewer. **Preconditions:** active tenant and permitted configuration role.

1. Admin creates or selects an academic calendar and assigns its applicability (school/campus/programme).
2. Admin configures academic year, terms, holiday/events, date ranges, local timezone and sequence.
3. Admin configures programmes, grade/form/year levels, streams/classes, subjects, rooms and schedule periods as needed.
4. Admin previews date conflicts, term boundaries and timetable conflicts.
5. Principal or delegated approver reviews and confirms the active configuration.
6. A configuration change affecting active records is versioned and effective-dated; historical year/term snapshots remain understandable.

**Stories:** ST-02.1 Admin can define calendars/terms; ST-02.2 Admin can configure grades/forms and class structure; ST-02.3 Admin can publish a timetable version; ST-02.4 Admin can configure combined school levels without custom code.

**Acceptance criteria:**
- AC-02.1 Academic year and term dates follow configured calendar and validated date rules.
- AC-02.2 Multiple calendars are supported where configured; a record's calendar context is explicit.
- AC-02.3 School type primary, secondary or combined can configure applicable levels and classes.
- AC-02.4 Invalid overlapping term/date combinations are rejected or explicitly permitted by policy with warning and approval.
- AC-02.5 Timetable clashes identify class, teacher and room conflicts; cannot publish unresolved blocking conflicts.
- AC-02.6 Published timetable is versioned; changes do not overwrite the historical published version.
- AC-02.7 Time display uses school/campus IANA timezone; stored instants use UTC.

**Exceptions:** calendar already used by records; invalid date ranges; unauthorized approval; conflicting room/teacher; attempted retroactive change without reason.

### WF-03 — Invite staff and assign scoped permissions

**Goal:** give staff only the access required for their duties.

**Actors:** owner/admin; staff invitee. **Preconditions:** tenant active, role catalogue and permission scopes available.

1. Admin enters staff identity and invitation contact.
2. Admin selects role(s), campus/class/subject scope and effective dates; high-risk permissions may require a second approver.
3. Invitee accepts, authenticates and links membership.
4. Admin verifies role assignment; system logs invitation, acceptance and grant changes.
5. When staff leaves or role changes, membership/grant is ended or revoked; sessions and cached grants become invalid within approved revocation SLA.

**Stories:** ST-03.1 Admin can invite staff; ST-03.2 Admin can grant scoped roles; ST-03.3 Admin can revoke access promptly; ST-03.4 Support access requires an approved grant.

**Acceptance criteria:**
- AC-03.1 Invitation cannot grant a role beyond inviter's delegation authority.
- AC-03.2 A teacher sees only assigned school/campus/classes/subjects.
- AC-03.3 Revoked membership/role cannot access records on subsequent requests; revocation and cache/session behavior is tested.
- AC-03.4 Users cannot elevate their own role or edit platform roles.
- AC-03.5 Restricted permissions (finance, HR, legal, health, safeguarding, export, publish) require explicit grant and are auditable.
- AC-03.6 Platform support access is time-limited, purpose-bound, scoped, approved and audited.

### WF-04 — Student/guardian creation, verification and restrictions

**Goal:** maintain accurate people records and safe guardian access.

**Actors:** authorized admin/registrar; guardian; restriction reviewer. **Preconditions:** tenant and school year configured.

1. Registrar searches for likely duplicates using authorized fields.
2. Registrar creates student profile with school-specific identifier, minimal required data, classification and lifecycle status.
3. Registrar creates or matches guardian profile; records relationship, contact channel, verification evidence/status, allowed categories, dates and consent/preferences where applicable.
4. Legal/custody restriction is reviewed by designated authorized person and recorded with scope, dates, source/evidence reference, review date and priority.
5. Guardian receives invitation or linking process; identity/relationship verification completes.
6. Portal permissions are activated only after verified link and policy checks.
7. Link/restriction changes are audited; revoked access is tested.

**Stories:** ST-04.1 Registrar can create/search learner; ST-04.2 Authorized staff can verify guardian relation; ST-04.3 Reviewer can record legal access restrictions; ST-04.4 Guardian can access only allowed linked learner data.

**Acceptance criteria:**
- AC-04.1 Duplicate candidates are surfaced; merge is a controlled, authorized, audited process that preserves source/history.
- AC-04.2 Guardian link is not active for portal access until verification requirements pass.
- AC-04.3 Permission is child-specific and category-specific (profile, attendance, results, finance, communication); defaults are restrictive.
- AC-04.4 Legal/custody restrictions override ordinary guardian permissions and are tested with deny scenarios.
- AC-04.5 Emergency-contact status does not automatically confer portal, custody or record access.
- AC-04.6 Restricted data does not leak through search snippets, exports, notifications, public CMS or ordinary guardian views.
- AC-04.7 Link expiration, revocation and contact changes are auditable and reflected promptly.

### WF-05 — Enrolment, promotion, transfer, withdrawal and re-entry

**Goal:** preserve a learner's academic history across lifecycle changes.

**Actors:** registrar/admin; approver for exceptional changes. **Preconditions:** student exists, academic year/programme/class is configured.

1. Registrar selects learner and valid academic context, programme/grade/class, dates and enrolment type.
2. System checks eligibility, existing active enrolments, overlap and primary-enrolment rules.
3. Registrar confirms; enrolment is created with an auditable event.
4. Promotion/transfer records end date and destination, and creates a new dated enrolment as required; previous records remain.
5. Withdrawal records reason/date under permissions; re-entry creates a new lifecycle record, not destructive reactivation.

**Stories:** ST-05.1 Registrar can enrol student; ST-05.2 Admin can promote or transfer with history; ST-05.3 Admin can withdraw and re-enrol; ST-05.4 System supports approved multiple enrolments.

**Acceptance criteria:**
- AC-05.1 Enrolment must reference the same school and valid programme/class/calendar context.
- AC-05.2 Eligibility and date checks prevent invalid overlap except configured and approved cases.
- AC-05.3 Primary enrolment uniqueness is enforced in the agreed context; multiple enrolments remain supported where accepted.
- AC-05.4 Promotion/transfer/withdrawal/re-entry preserves previous enrolment, dates and actor/reason.
- AC-05.5 Changes do not silently rewrite historical attendance, assessment, invoices or reports.

### WF-06 — Legacy data import and reconciliation

**Goal:** import school data with a reviewable, safe process before live use.

**Actors:** authorized school admin; import operator; school reviewer. **Preconditions:** approved import template, lawful source, staging/synthetic environment.

1. Operator uploads a supported file into private quarantine.
2. File passes scanning; parser validates required columns, formats, duplicate candidates and relationship references.
3. System produces preview with valid rows, errors, warnings and estimated changes; no writes are committed at preview.
4. Admin maps columns and resolves errors; sample records are checked.
5. Authorized operator executes import with idempotent batch ID; rejected rows remain downloadable only by authorized roles.
6. Admin reconciles totals and sample records; batch is approved and audit record retained.

**Stories:** ST-06.1 Admin can preview import; ST-06.2 Admin can resolve validation errors; ST-06.3 Import is retry-safe; ST-06.4 Admin can reconcile and approve.

**Acceptance criteria:**
- AC-06.1 Preview does not mutate business records.
- AC-06.2 Import rejects/quarantines malformed or unscanned files and invalid relationship rows.
- AC-06.3 Import reports row-level error/warning and counts (accepted, rejected, skipped, duplicate candidates).
- AC-06.4 Repeating same batch does not create duplicate students, guardians, enrolments or charges.
- AC-06.5 Import is scoped to school and source data is not exposed to other tenants.
- AC-06.6 School reviewer verifies totals and sample before go-live; discrepancy list is resolved or accepted in writing.

### WF-07 — Attendance register and correction

**Goal:** teacher records daily/period attendance and authorized corrections retain history.

**Actors:** teacher; attendance admin; guardian (limited view). **Preconditions:** active enrolment, configured calendar/session, class/subject assignment.

1. Teacher opens assigned class/session/date; system displays eligible students only.
2. Teacher records configured status (present, absent, late, excused or school-approved alternatives) and optional permitted note.
3. Teacher submits register; missing entries and invalid session/date are highlighted.
4. Register may be approved/locked per school policy.
5. Correction requires authorized role, reason and previous/new value; history retained.
6. Guardian receives only approved notification and allowed summary; no sensitive notes.

**Stories:** ST-07.1 Teacher can take register; ST-07.2 Teacher can submit; ST-07.3 Authorized admin can correct; ST-07.4 Guardian sees permitted attendance.

**Acceptance criteria:**
- AC-07.1 Register roster derives from enrolment/assignment for selected date; withdrawn/not-yet-enrolled learners excluded.
- AC-07.2 Each student/session has at most one current record; duplicate submit is safe/idempotent.
- AC-07.3 Attendance status belongs to configured list; invalid values rejected.
- AC-07.4 Submitted/locked register is changed only through controlled correction with reason and audit.
- AC-07.5 Teacher cannot record unrelated class attendance.
- AC-07.6 Guardian can see linked learner's released attendance only; legal restrictions and field filtering apply.
- AC-07.7 Notifications avoid revealing sensitive details or exposing other learners.

### WF-08 — Assessment, moderation, report and publish

**Goal:** marks follow configurable school rules and are published only after authorized review.

**Actors:** teacher; academic admin/moderator; principal/delegate; guardian. **Preconditions:** subject/class assignment, assessment period, grading scheme version and roster.

1. Admin selects or configures grading/assessment scheme, weights, score bounds, aggregation and publication policy; version/effective date is saved.
2. Teacher creates assessment with class/subject/period/date and component rules.
3. Teacher enters marks for eligible learners; validation checks bounds, completeness and roster.
4. Teacher submits; moderation/review may correct or return with comments and history.
5. Authorized approver confirms calculation/report snapshot and publishes.
6. Guardian views published result only; later correction creates revised snapshot/version and is auditable.

**Stories:** ST-08.1 Admin configures grading; ST-08.2 Teacher enters marks; ST-08.3 Moderator reviews; ST-08.4 Authorized approver publishes; ST-08.5 Guardian views published result.

**Acceptance criteria:**
- AC-08.1 Assessment uses scheme version applicable to assessment; changing scheme does not silently recalculate approved historical result.
- AC-08.2 Scores and component weights obey configured constraints; aggregate is reproducible and rounding rule documented.
- AC-08.3 Only assigned teacher/authorized staff may enter or edit marks within permitted workflow.
- AC-08.4 Moderation/approval state and changes preserve actor, reason, timestamp and version.
- AC-08.5 Report cannot be published with blocking errors (missing marks, invalid weights, unresolved required moderation).
- AC-08.6 Published reports are immutable snapshots; corrections require authorized revision/unpublish workflow.
- AC-08.7 Guardians cannot see unpublished, unrelated or restricted learner results.

### WF-09 — Admission application, decision and conversion

**Goal:** accept applications and convert an accepted applicant into learner/enrolment exactly once.

**Actors:** applicant/guardian; admissions officer; approver; registrar. **Preconditions:** campaign configured/open, fee policy/version and documents checklist reviewed.

1. School publishes only safe campaign details and application form.
2. Applicant submits minimal required data and documents through a controlled public route; submission gets reference and acknowledgement.
3. Admissions staff review completeness, verify documents, request additional information, interview if configured, and record decisions/history.
4. Offer is generated with expiry and approved terms; acceptance/decline is recorded.
5. If fees are configured, snapshot fee/version; record payment/waiver status under permissions and provider policy.
6. Authorized registrar converts accepted application to student/enrolment using idempotency; links source application and records conversion event.

**Stories:** ST-09.1 Applicant can submit; ST-09.2 Admissions can review; ST-09.3 School can offer/decline; ST-09.4 Accepted applicant converts once; ST-09.5 Fee quote remains consistent with version.

**Acceptance criteria:**
- AC-09.1 Public form is rate-limited, validates fields, protects files and does not expose other applications.
- AC-09.2 Application reference is unique; submit/retry does not create duplicates.
- AC-09.3 Workflow transitions are validated and history is retained; decisions require appropriate role.
- AC-09.4 Application fee is a versioned snapshot; changes to fee schedule do not alter existing application quote.
- AC-09.5 Accepted conversion is transactional/idempotent; retries create exactly one learner and intended enrolment.
- AC-09.6 Admissions staff cannot browse unrelated restricted health/safeguarding/finance data.
- AC-09.7 Applicant documents remain private and scan status is required before authorized access.

### WF-10 — School fees, invoice, payment, allocation and receipt

**Goal:** record school charges and payment evidence with correct balances and distinct school-finance domain.

**Actors:** bursar; finance reviewer; guardian (approved view). **Preconditions:** approved fee configuration, currency precision, financial permissions and period.

1. Bursar configures fee items and schedules with effective dates, target class/programme/year and currency.
2. Charge/invoice is created from applicable configuration; line items, student and fee version snapshot are reviewed.
3. Payment is recorded (manual/offline evidence in pilot or approved provider event); payer/reference/date/currency/amount and verification status are recorded.
4. Verified payment is allocated to invoice(s); system checks tenant, learner, currency/approved conversion and allocation limits.
5. Receipt is issued once after verified payment/allocation as configured; statement/balance updates.
6. Bursar reviews arrears/statement; guardian can see only allowed linked learner financial information.
7. Adjustments, waivers, refunds or reversals use WF-11.

**Stories:** ST-10.1 Bursar configures fee schedule; ST-10.2 Bursar creates invoice; ST-10.3 Finance records payment; ST-10.4 Verified payment is allocated; ST-10.5 Receipt/statement available; ST-10.6 Guardian sees permitted balance.

**Acceptance criteria:**
- AC-10.1 Invoice retains fee schedule, currency, precision, line totals and due-date snapshot.
- AC-10.2 No floating-point monetary values; currency precision and rounding are explicit.
- AC-10.3 Payment is not allocatable or receiptable before verification policy is satisfied.
- AC-10.4 Duplicate provider transaction/reference or retry is detected/idempotent according to reviewed uniqueness rules.
- AC-10.5 Allocations cannot exceed payment available amount or invoice outstanding balance; transaction-safe enforcement prevents concurrent over-allocation.
- AC-10.6 Currency mismatch is rejected unless approved conversion record and policy are present.
- AC-10.7 Posted invoice/payment/allocation/receipt is not edited destructively; correction uses reversal/adjustment workflow.
- AC-10.8 School finance is not mixed with XEN subscription billing; guardian access is relationship/permission filtered.
- AC-10.9 Reports reconcile invoice totals, payment totals, allocations, credits and balances.

### WF-11 — Waiver, adjustment and refund

**Goal:** correct financial records without bypassing approval or immutable history.

**Actors:** bursar initiator; designated approver; finance reviewer. **Preconditions:** posted transaction and policy/permission.

1. Initiator proposes adjustment, waiver, credit or refund with reason, amount, evidence and reference.
2. System validates balance, eligible transaction, amount cap and policy.
3. A different approver reviews when segregation-of-duties rule applies; approval/rejection recorded.
4. Approved adjustment/refund is posted as new linked record/reversal, not deletion of original.
5. Reconciliation/statement reflects corrected position and audit trail.

**Stories:** ST-11.1 Finance initiates correction; ST-11.2 Authorized approver reviews; ST-11.3 System preserves original record; ST-11.4 School can reconcile.

**Acceptance criteria:**
- AC-11.1 Reason and evidence reference required by policy.
- AC-11.2 Approval authority and segregation-of-duties are enforced; requester cannot approve own high-risk action where required.
- AC-11.3 Refund/credit cannot exceed approved eligible amount or available balance.
- AC-11.4 Original posted record remains immutable and linked to adjustment/reversal.
- AC-11.5 Duplicate requests/retries do not create duplicate refunds/credits.
- AC-11.6 Approval/rejection, posting and audit events are retained.

### WF-12 — Guardian portal onboarding and data access

**Goal:** provide safe, relationship-scoped self-service.

**Actors:** guardian; school administrator/reviewer; support. **Preconditions:** guardian profile and verified relationship, permissions, restrictions and portal feature enabled.

1. Guardian receives invitation through approved contact channel and completes identity/account verification.
2. Guardian confirms linked learner(s); each relationship is verified and permission flags reviewed.
3. Guardian sees only allowed categories: profile, attendance, published results, approved notices/messages and finance (if enabled/allowed).
4. Guardian requests correction or reports relationship issue; school reviews through authorized workflow.
5. Link expires/revokes or restriction changes; portal access and cached access are revoked within approved SLA.

**Stories:** ST-12.1 Guardian can activate account; ST-12.2 Guardian can view permitted records; ST-12.3 Guardian can request correction; ST-12.4 School can revoke access.

**Acceptance criteria:**
- AC-12.1 Account does not automatically link to a learner based solely on matching name/email/phone.
- AC-12.2 Link verification, permission categories, effective dates and legal restrictions are checked on access.
- AC-12.3 Guardian cannot access siblings/learners without separate verified authorized links.
- AC-12.4 Only approved/published data appears; internal notes and restricted records remain hidden.
- AC-12.5 Revocation/restriction change invalidates future API access and portal session/cache as specified.
- AC-12.6 Guardian portal has no direct access to public/private CMS base records or XEN SaaS billing records.

### WF-13 — School notice and direct messaging

**Goal:** send communications only to permitted recipients with moderation and privacy controls.

**Actors:** authorized school staff; guardian recipients; moderation role. **Preconditions:** channel/feature enabled, consent/preferences, verified relationships.

1. Staff drafts notice/message, audience and channel; previews recipient count and filtered scope.
2. Content is reviewed/moderated if required; sensitive categories are blocked or routed to restricted process.
3. Authorized staff sends; delivery records track queued/sent/failed; retry is idempotent.
4. Guardian reads permitted message; read receipt is recorded if feature enabled and consent/configuration permits.
5. Admin handles moderation/abuse and reports without unnecessary message-content exposure.

**Stories:** ST-13.1 Staff can send school notice; ST-13.2 Staff can message permitted guardian; ST-13.3 Guardian preferences apply; ST-13.4 Moderator can manage flagged content.

**Acceptance criteria:**
- AC-13.1 Audience membership is computed from school and permission scope; no recipient can see other recipients unless explicitly intended.
- AC-13.2 Restricted/legal-sensitive details are excluded from bulk notifications and content preview policy.
- AC-13.3 Consent/preferences and channel rules are enforced; delivery is idempotent and logged.
- AC-13.4 Moderation actions retain reason and actor; restricted moderation notes are not exposed to recipients.
- AC-13.5 Messages/files follow private file policy and retention rules.

### WF-14 — Public school website content

**Goal:** publish school-approved content without exposing private school-management records.

**Actors:** CMS editor; publisher; anonymous visitor. **Preconditions:** website provisioned, safe template, publication roles, verified domain if custom domain.

1. Editor drafts page/news/contact content using approved blocks/assets; private records cannot be selected as content source.
2. Editor submits review; publisher checks accuracy, consent/rights, sensitive content and links.
3. Publisher approves and publishes a version to safe public projection.
4. Anonymous visitor accesses only published version through school route/domain.
5. Publisher unpublishes/takes down; delivery/cache and public assets are invalidated.

**Stories:** ST-14.1 Editor drafts; ST-14.2 Publisher reviews; ST-14.3 Visitor reads published page; ST-14.4 Publisher removes content promptly.

**Acceptance criteria:**
- AC-14.1 Anonymous reads cannot query CMS authoring tables, drafts, submissions, student/guardian records, finance, restricted data or private media metadata.
- AC-14.2 Public projection contains allow-listed approved fields only and publication-version reference.
- AC-14.3 Unverified custom domain cannot serve tenant public content.
- AC-14.4 Published student-identifiable content/media requires documented review/consent basis.
- AC-14.5 Unpublish, takedown, domain disable or consent withdrawal invalidates public/cache/signed access within defined SLA.
- AC-14.6 Publishing and unpublishing are audited; prior version retained according to policy.

### WF-15 — Operational reports and export

**Goal:** produce scoped operational information without leaking sensitive fields.

**Actors:** admin, principal, teacher, bursar, authorized export reviewer. **Preconditions:** report definition and scope/permission.

1. User selects report and filters within assigned school/campus/class/year scope.
2. System validates filters and limits; report displays only allowed fields.
3. Export is separately permission-checked, purpose recorded if sensitive, and generated in private storage.
4. User downloads through time-limited authorized link; access and export event logged.
5. School reconciles export against UI totals; sensitive categories excluded unless explicitly approved.

**Stories:** ST-15.1 Authorized user can view scoped report; ST-15.2 Export requires permission; ST-15.3 Export is private/audited; ST-15.4 Report totals are reproducible.

**Acceptance criteria:**
- AC-15.1 Report filters enforce tenant and assigned scope, not only UI filtering.
- AC-15.2 Export does not include restricted health/safeguarding/legal/bank/bursary data by default.
- AC-15.3 Export permission is distinct from view permission where policy requires.
- AC-15.4 Export job and file are private, scoped, logged and expire/delete under policy.
- AC-15.5 Totals reconcile to source records for selected date/filter context.

### WF-16 — Tenant closure, data export and retention

**Goal:** offboard school safely under contract, retention, legal hold and privacy rules.

**Actors:** school owner; platform operator; privacy reviewer. **Preconditions:** verified closure request and authority; retention/legal hold policy defined.

1. Owner requests export/closure and authenticates; system checks authority and open financial/legal/retention obligations.
2. Reviewer confirms export scope, format, destination and secure delivery.
3. Export generated and verified; school receives access; download and acknowledgement recorded.
4. Tenant enters approved closure/suspension state; user access disabled and services stopped per policy.
5. Records retained, anonymized or deleted according to schedule and legal holds; deletion is staged and audited.

**Stories:** ST-16.1 Owner requests export; ST-16.2 Reviewer approves; ST-16.3 Operator closes tenant; ST-16.4 Legal hold prevents prohibited deletion.

**Acceptance criteria:**
- AC-16.1 Only authorized owner/representative may request closure/export; verification is recorded.
- AC-16.2 Export is encrypted/protected, private and scoped; delivery access expires.
- AC-16.3 Legal hold, retention and open obligations block or alter deletion as specified.
- AC-16.4 Closure revokes access, tokens/links and tenant operations; privileged actions are audited.
- AC-16.5 Deletion/anonymization evidence is recorded; no claim of deletion where hold applies.
- AC-16.6 Tenant closure does not delete platform billing/audit obligations contrary to retention policy.

### WF-17 — Scoped support access and incident handling

**Goal:** support service without broad or persistent exposure to school data.

**Actors:** school requester; XEN support; approver; security reviewer. **Preconditions:** support ticket and defined purpose.

1. Requester describes issue and supplies minimal non-sensitive diagnostic details.
2. Support asks for scoped grant only if record access is necessary; identifies tenant, data category, actions, purpose and expiry.
3. Authorized approver grants or rejects; user is notified as policy requires.
4. Support performs limited action; all data access and actions logged.
5. Grant expires/revokes automatically; incident notes redact secrets and unnecessary personal data.

**Stories:** ST-17.1 Support can diagnose using safe metadata; ST-17.2 Access requires grant; ST-17.3 School can view support-access audit where permitted.

**Acceptance criteria:**
- AC-17.1 Support access is not implied by platform role; no routine unrestricted P2/P3 school data.
- AC-17.2 Grant is purpose, tenant, category, action, time and approver scoped.
- AC-17.3 Expired/revoked grant fails immediately within approved access revocation SLA.
- AC-17.4 Support access/action logs are protected from alteration by the accessing actor.
- AC-17.5 Secrets and restricted data are excluded from diagnostics and support exports by default.

### WF-18 — Recovery and pilot release acceptance

**Goal:** prove operational readiness and pilot acceptance before live data use.

**Actors:** technical owner, product owner, pilot school signatories, QA/security reviewer. **Preconditions:** staging, test dataset, backups, recovery objectives, release candidate.

1. QA runs critical acceptance suite, tenant isolation and restricted-data leakage tests using normal roles.
2. Technical owner performs documented backup restore for database and private files to recovery point; verifies integrity and dependencies.
3. Pilot users execute representative workflows on supported phone/desktop and agreed network profile; issues recorded.
4. Product owner reviews P0/P1 defects, scope changes, training, support and data reconciliation.
5. Go/no-go is recorded with signatories, evidence links, conditions, rollback/forward-fix plan and date.

**Stories:** ST-18.1 QA can run defined test suite; ST-18.2 Operator can restore; ST-18.3 Pilot users can complete tasks; ST-18.4 Owner can make evidence-based release decision.

**Acceptance criteria:**
- AC-18.1 All approved P0 acceptance scenarios pass; no unresolved critical/high tenant-security/privacy defect.
- AC-18.2 Tenant isolation and RLS tests run using ordinary application roles; owner/service bypass is not proof.
- AC-18.3 Recovery exercise demonstrates approved RPO/RTO and verifies database/files/integrity; targets are not assumed until approved.
- AC-18.4 Pilot users complete core tasks; usability, accessibility, mobile and low-bandwidth issues are recorded.
- AC-18.5 Data import reconciliation is signed by school owner before live use.
- AC-18.6 Go/no-go, sign-off, risks, exclusions and action owners are documented; no automatic deployment authorization.

## 5. Cross-workflow acceptance rules (mandatory)

1. **Tenant isolation:** every workflow/API/report/export is school-scoped and cannot leak by guessed IDs, joins, URLs, files, RPC/views or background jobs.
2. **Least privilege:** role, campus/class/subject scope and action permissions are checked server-side; UI-only checks do not count.
3. **Guardian safety:** active verified relationship, per-category permission, valid dates and restrictions are checked for each access path.
4. **Restricted domains:** health/safeguarding/legal/custody/bursary/bank data are excluded from ordinary search, messages, notifications, public projection and exports unless explicitly reviewed and authorized.
5. **Public/private separation:** anonymous access only safe approved published projection and assets; CMS base, drafts, submissions and private media are denied.
6. **Financial integrity:** no float money; currency/precision/rounding evidence; verified payments; bounded allocation; idempotency; immutable posting and controlled correction; separate school finance vs XEN SaaS billing.
7. **Lifecycle/history:** valid transitions, actor/reason/timestamp, immutable snapshots and no destructive historical overwrite.
8. **Retry/concurrency:** duplicate requests, provider callbacks, conversion, payments and publication retries are safe; concurrency invariants are transactional.
9. **Audit/privacy:** sensitive changes/access are audited; logs minimize content/PII; retention/legal holds govern deletion.
10. **Accessibility/responsive/low-bandwidth:** target screens, keyboard/accessibility checks and network profile to be agreed; core tasks must not silently fail.

## 6. Requirement traceability

Workflow/story IDs are supplemental to existing XSM requirement IDs. Before test execution, maintain a trace table mapping each story/AC to requirement IDs, test case ID, environment, evidence URL, result, defect, tester and date. The detailed MRTM remains the primary requirements reference. Crosswalks are expected for at least:

| Workflow | Requirement families (MRTM) |
|---|---|
| WF-01, WF-03 | PLT, IAM, SaaS, audit |
| WF-02, WF-05 | ACD, calendar, enrolment, timetable |
| WF-04, WF-12 | PPL, IAM, guardian, privacy/legal |
| WF-06 | import/export, files, governance |
| WF-07 | attendance, guardian notifications |
| WF-08 | assessment, moderation, reports, portal |
| WF-09 | admissions, files, finance snapshots, enrolment |
| WF-10, WF-11 | school finance, accounting, permissions, audit |
| WF-13 | communications, moderation, consent, notification |
| WF-14 | CMS, public publishing, domain, media rights |
| WF-15, WF-16 | reports, export/delete, governance, legal hold |
| WF-17 | support access, audit, IAM |
| WF-18 | QA, tenant security, recovery, pilot launch |

## 7. Validation plan and evidence template

### Validation participants

Minimum validation roles: product owner, pilot school owner/admin, teacher, admissions officer, bursar, guardian, technical/security reviewer, and support/operator. A school may nominate individuals who cover multiple roles, but role-specific test accounts must remain separate for authorization tests. For initial pilot, record school type and explicitly state whether primary, secondary and combined workflows were all reviewed or only a subset.

### Validation sessions

- **Session A — Setup & access:** WF-01–WF-03; tenant setup, invites, revocation, scoped roles.
- **Session B — Learner lifecycle & safeguarding controls:** WF-04–WF-06; duplicate detection, verified guardian, restrictions, enrolment and import.
- **Session C — Teaching & daily operations:** WF-07–WF-08; attendance, corrections, marks, grading, moderation, report publishing.
- **Session D — Admissions & fees:** WF-09–WF-11; application, conversion, invoice, payment, receipt, adjustments/refunds.
- **Session E — Guardian, communication & website:** WF-12–WF-14; guardian access, notice/message, CMS publish/unpublish and public isolation.
- **Session F — Reporting, governance & support:** WF-15–WF-17; reports, export, closure, support grants.
- **Session G — Pilot go/no-go:** WF-18; restore evidence, acceptance suite, issue review and sign-off.

### Evidence record (copy per scenario)

| Field | Record |
|---|---|
| Validation ID / Workflow / Story / AC | To assign |
| Requirement IDs | MRTM crosswalk |
| School type / pilot school | Record only as approved |
| Test environment / build or version | To record |
| Role/account / tenant / scope | Synthetic test identity preferred |
| Preconditions / test data | To record; avoid real sensitive data |
| Steps / expected outcome | Use the AC as basis; detail test case |
| Actual outcome / pass-fail-blocked | To record |
| Evidence reference | Screenshots/logs with PII minimized, URL or test report |
| Defect ID / severity / owner | If failed |
| Tester / reviewer / date | To record |
| Approval / notes | Product owner or school reviewer |

### Validation exit criteria (proposed)

- Owner and pilot stakeholders validate the workflow list, terminology, scope and school-specific rules.
- Each P0 story is accepted or explicitly deferred by the product owner; acceptance criteria remain measurable.
- P0 scenarios pass before pilot entry; no critical/high security/privacy defects remain.
- Tenant A/B, guardian verification/revocation, legal restrictions, anonymous CMS, finance separation and restricted-data leakage tests pass.
- Financial reconciliation and idempotency tests pass for the pilot's enabled finance scope.
- Import reconciliation, training/support, backup/restore and recovery objectives are approved.
- Known issues, risks, exclusions, data-processing/legal approvals and owners are documented.
- Pilot go/no-go sign-off recorded; this sign-off does not itself authorize deployment beyond the separately approved release stage.

## 8. Open validation decisions

1. Confirm first pilot schools, type(s), number, stakeholder representatives and sign-off authority.
2. Confirm attendance mode (daily, period, or both), allowed statuses and correction approval.
3. Confirm grade/form/stream nomenclature, grading schemes, report-card layouts, promotion rules and moderation requirements.
4. Confirm admissions form fields, document requirements, application fees/waivers, and conversion conditions.
5. Confirm whether fee/invoice/receipt features are in pilot; payment capture is manual or provider-integrated; approval segregation.
6. Confirm guardian verification method, category permissions, custody/legal restriction workflow, revocation SLA and portal onboarding.
7. Confirm communications channels, consent/preferences, moderation and read-receipt requirements.
8. Confirm public website scope, template, publisher approvals, consent for learner imagery, custom-domain readiness.
9. Confirm import formats, data-quality tolerances, duplicate resolution and sign-off.
10. Confirm export, retention, deletion, legal hold, jurisdiction/residency and school closure policy.
11. Confirm supported devices/browsers, mobile viewport, network profile, accessibility baseline and response-time targets.
12. Confirm RPO/RTO, backup and restore sign-off, support SLA and pilot issue triage.

## 9. Change control

Stakeholder changes are recorded as change requests with source, affected workflow/story/AC, business value, priority, scope/cost, security/privacy/data/migration/test impact, decision and approver. Approved changes update the MRTM and pilot-scope baseline with version/date. Requirements cannot be marked implemented or passed without linked test evidence.

## 10. Status and approval

- Workflows drafted: WF-01 through WF-18.
- Stories and proposed acceptance criteria drafted; no implementation or execution evidence exists.
- Stakeholder validation: **Pending**.
- Owner approval of first-release scope: **Pending**.
- Test case IDs and evidence: **Not yet assigned**.
- Pilot go/no-go: **Not reached**.

**Explicit non-deliverables:** application code, SQL, executable schema/migrations, seed data, CI, infrastructure, deployment or real-data import. This document does not authorize any of these.
