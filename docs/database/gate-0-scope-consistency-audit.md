# Gate 0 — Scope and Documentation Consistency Audit

**Project:** XEN SCHOOL MANAGEMENT v3.0  
**Audit date:** 20 November 2026  
**Authoritative source reviewed:** *XEN SCHOOL MANAGEMENT — Complete Combined Master Plan, Version 3.0, 16 November 2026* (22 pages; consolidated v1.0 + v2.0).  
**Repository:** `xiong2007-bit/xen-school-management`  
**Scope:** Documentation consistency and requirements coverage only. No code or database implementation was created.

## Executive result

**Result: PASS WITH ACTIONS.** The complete master plan was located and reviewed against the data dictionary, approved design decisions, relationship specification, constraints/RLS, schema blueprint, migration manifest, roadmap, technical decision register and readiness checklist.

The intended product scope is coherent: a Zimbabwe-first, international-ready, multi-tenant school platform combining public websites, private school operations, guardian/applicant portals and XEN platform administration. The 13 product/design decisions accepted on 20 November 2026 remain consistent with the master plan.

The audit found several documentation gaps and stale contradictions. These have been corrected in the linked specifications below. Remaining items are release-scope or pre-implementation verification tasks—not unresolved contradictions in the approved product baseline.

**Gate 0 does not authorize implementation.** SQL, migrations, application code, CI, infrastructure and deployment remain separately gated.

## Master-plan coverage matrix

| Master Plan area | Audit result | Reconciliation |
|---|---|---|
| 1. Vision, outcomes, scope | Covered | Product, Zimbabwe-first, international-ready, SaaS and connected experiences align |
| 2. Customers, schools, campuses, roles | Covered; group capability deferred | Tenant/school/campus roles documented; school groups explicitly future |
| 3. School onboarding | Covered | Setup dependencies, tenant creation, plan, settings, branding, staff, learners and guardians in roadmap |
| 4. Identity/configuration/academic setup | Covered | Country, currency, timezone, language, configurable grade/form, calendars and settings |
| 5. Students, guardians, staff | Covered; legal restriction detail strengthened | Student lifecycle, guardians, staff and verification; emergency contacts and legal restrictions added |
| 6. Academics/enrolment/teaching | Covered; enrolment rule corrected | Controlled multiple enrolments, primary enrolment, programme, assignment history |
| 7. Attendance/safeguarding | Covered; restricted module definitions added | Registers, statuses, corrections, notification and restricted safeguarding notes |
| 8. Assessment/results/report cards | Covered; configurability strengthened | Categories, versioned rules, weighting/aggregation, ranking, promotion and report templates |
| 9. Timetables/calendar/operations | Covered; detailed schema added | Calendars, holidays/events, periods, rooms, timetable versions/entries/exceptions and clash checks |
| 10. Parent/guardian/student portals | Covered | Guardian verification and published-only views; student portal remains optional/future |
| 11. Communications | Covered; read receipts/moderation clarified | Announcements, messaging, recipient permissions, per-message read receipts, moderation history, delivery and preferences |
| 12. Public websites/builder | Covered; reusable blocks/templates added | Approved visual components, structured content, responsive design, no arbitrary script injection |
| 13. CMS/media/publishing | Covered | Draft/review/publish/unpublish, revisions, media rights/consent, safe public projections |
| 14. Domains/languages/SEO | Covered | Domain verification, primary/aliases, SSL, translations, review, SEO and cache boundary |
| 15. Admissions | Covered; fee model reconciled | Applicant lifecycle, versioned forms, documents/reviews/interviews/offers and idempotent conversion |
| 16. School finance | Covered | Fees, invoices, payment allocation, receipts, arrears, credits/refunds/waivers and statements |
| 17. Payment integrations | Covered as architecture; provider selection open | Provider-neutral adapters, verified events, Zimbabwe candidates and reconciliation; no provider claimed integrated |
| 18. Accounting/reconciliation | Covered | Double-entry, periods, accounts, bank reconciliation, expenses, budgets, approvals and immutable journals |
| 19. Library/transport/documents/service desk | Covered | Definitions and roadmap; optional modules feature-gated |
| 20. Reports/analytics | Partially modelled; intentional design choice | Core reporting uses controlled queries/read models; dedicated analytics/website visit tracking needs privacy and product decision |
| 21. XEN subscriptions/admin | Covered | Plans, entitlements, subscriptions, usage, billing, promotions, support and tenant lifecycle |
| 22. Technical architecture/flows | Covered | Approved architecture baseline and request/data flow documented |
| 23. Data/privacy/security | Covered; restricted health/legal model strengthened | Tenant RLS, child privacy, consent, retention, export/deletion, residency, backup and incident response |
| 24. Roles/permissions/governance | Covered | Role + scope + relationship + sensitivity + workflow permissions and audited support access |
| 25. Commercial/growth | Covered | Subscription bands, setup/training/support/integrations; pricing remains open |
| 26. Development roadmap | Covered | Phased roadmap aligned with migration sequence |
| 27. Testing/pilot/operations | Covered as plan; not evidenced | Tenant, finance, privacy, mobile/low-bandwidth, backup/recovery, pilot and support tests remain future work |
| 28. Acceptance criteria/risks/open decisions | Covered; stale statuses corrected | Product decisions are accepted; technical and launch gates remain open |
| Appendix workflows/glossary | Covered | Admissions, payment, CMS publishing and attendance workflows retained |

## Findings and corrections

### G0-01 — Academic calendars and term overlap (High) — RESOLVED
**Finding:** The approved decision supports multiple calendars, overlapping terms, campus/programme applicability and varied dates. The detailed dictionary previously had only academic years/terms and a school-wide term overlap caveat.

**Correction:** Added academic programmes, academic calendars, calendar-scoped years/terms, calendar events/holidays and explicit overlap-policy semantics. Updated relationships, blueprint and roadmap.

### G0-02 — Timetable and room scheduling (High) — RESOLVED
**Finding:** Master plan requires weekly class/teacher timetables, rooms/periods, clash detection, versioned changes and published views. Detailed data definitions did not provide timetable entities.

**Correction:** Added timetable periods, rooms, timetable versions, entries, date exceptions and clash-validation rules to the academics dictionary, schema blueprint, relationship spec and migration manifest.

### G0-03 — Concurrent enrolments and primary enrolment (High) — RESOLVED
**Finding:** A prior dictionary/constraint rule imposed one enrolment per student/year unless exception, conflicting with the accepted controlled-multiple-enrolment decision.

**Correction:** Changed to approved concurrent enrolments with programme/scope rules, a primary enrolment, date/overlap validation and history. Removed the blanket uniqueness constraint from recommended integrity/index rules.

### G0-04 — Guardian custody/legal restrictions and emergency contacts (High) — RESOLVED
**Finding:** The master plan and accepted decision require legal/custody restrictions, authorised contacts and emergency-contact controls beyond simple guardian-link flags.

**Correction:** Added separate emergency-contact and guardian-access-restriction records with verification, scope, dates/review, protected legal document metadata and explicit precedence over ordinary guardian permissions. Updated relationship and security specifications.

### G0-05 — Admissions fee configuration (High) — RESOLVED
**Finding:** Campaign fee fields and a separate fee-settings table duplicated mutable fee configuration; no clear snapshot model was stated.

**Correction:** Made versioned `admission_fee_settings` the canonical free/paid/waiver/refund configuration. Submitted applications preserve an application-fee snapshot; admission payments reference that snapshot, and refunds are separately capped/approved. These remain separate from tuition. Updated relationships and blueprint.

### G0-06 — Currency precision and conversions (High) — RESOLVED
**Finding:** Approved multi-currency and explicit conversions were not fully represented in the finance dictionary; “minor units” could be interpreted as universally two decimals.

**Correction:** Added currency precision registry, source-aware exchange rates and immutable conversion snapshots with source/target amounts, rate, time, rounding and reason. Clarified no universal two-decimal assumption and no cross-currency allocation without conversion evidence.

### G0-07 — Optional school services and health/safeguarding (High) — RESOLVED
**Finding:** Boarding, meals, clubs, activities, trips and permissions appeared in blueprint/roadmap but lacked complete dictionary definitions. Restricted health/safeguarding was not sufficiently detailed in the data dictionary.

**Correction:** Added table definitions for boarding, meals, activities/clubs, trips, permissions and attendance; added restricted health conditions/allergies/visits/medication events, safeguarding incidents/referrals/action plans and access logs. Access and retention are explicitly restricted.

### G0-08 — Configurable assessment and promotion/reporting rules (High) — RESOLVED
**Finding:** Approved grading decision includes categories, weighting, aggregation, ranking, promotion, comments and report layouts; tables only partially specified.

**Correction:** Added assessment categories, versioned grading-rule snapshots, promotion rules and report-card template/layout records. Existing marks, moderation and report-card snapshots remain.

### G0-09 — Communication read receipts and moderation history (Medium) — RESOLVED
**Finding:** Thread-level read state and moderation status did not fully express per-message receipts and immutable moderation history.

**Correction:** Added per-message read receipts and append-only moderation actions; retained thread-level last-read as a convenience.

### G0-10 — Website builder reusable blocks and starter templates (Medium) — RESOLVED
**Finding:** Builder features such as reusable approved sections and starter kits were not explicitly represented.

**Correction:** Added reusable block library and versioned platform starter templates. UI capabilities (autosave, undo/redo, responsive preview, accessibility and safe component rendering) remain acceptance criteria, not claims of implementation.

### G0-11 — Migration dependency order (High) — RESOLVED
**Finding:** Admissions/CMS/staff documents referenced files while file metadata was scheduled late. The manifest contained a provisional order and a second conflicting refinement.

**Correction:** Replaced the manifest with one authoritative order: file metadata foundation before people/documents/admissions/CMS/finance attachments; calendar/timetable and the newly specified entities are included; removed conflicting renumbering advice.

### G0-12 — Stale “open decision” lists (Medium) — RESOLVED
**Finding:** Constraints and blueprint listed calendar, enrolment, admissions fees, guardian restrictions, health and messaging choices as open even though the owner accepted them.

**Correction:** Reclassified them as approved product decisions and replaced the old lists with technical verification items. UUIDv4 is now consistently recorded as approved.

## Deferred or remaining items

These do not invalidate the Gate 0 product scope, but require decisions or evidence before release:
- **School groups:** the master plan describes group reporting as future. A future group entity/membership abstraction is documented; school remains the security tenant and groups do not bypass tenant isolation.
- **Student portal:** optional/future, with age-appropriate permissions and no default finance/guardian exposure.
- **Reporting and website analytics:** operational reports can use controlled query/read models; visits, engagement and analytics retention require a privacy-conscious product decision. Do not add unnecessary learner tracking.
- **Offline/low-bandwidth:** responsive/mobile and safe retry are requirements; offline capture/synchronization is not assumed. Define pilot acceptance tests and exact offline scope before building.
- **First release finance scope:** core fee collection versus when full accounting/expenditure is introduced remains phased and requires owner prioritization; the full accounting model is approved.
- **Provider/legal/operations:** payment provider selection, current Zimbabwe payment and currency policy, privacy/legal review, residency, retention schedule, storage verification, region/tier, RPO/RTO, restore drill, custom domain operational details and plan/cost limits remain pre-production gates.
- **Pilot validation:** validate terms, fee workflows, grading, timetables, admission forms, imports and reports with representative Zimbabwean primary, secondary and combined schools before real-data migration.

## Repository remediation record

Documentation updates were made to:
- `data-dictionary-academics.md`
- `data-dictionary-platform.md`
- `data-dictionary-finance.md`
- `data-dictionary-web-portals.md`
- `data-dictionary-services-platform.md`
- `relationship-specification.md`
- `schema-blueprint.md`
- `constraints-indexes-rls.md`
- `migration-manifest.md`
- `approved-design-decisions.md`
- `implementation-roadmap.md`

The README and readiness checklist are to link this audit and track Gate 0 status.

## Gate 0 exit status

- [x] Authoritative master plan located and reviewed.
- [x] Coverage mapped across all 28 sections and appendices.
- [x] High-priority contradictions/gaps identified and reconciled in documentation.
- [x] Approved product decisions separated from technical verification tasks.
- [x] Migration order made internally consistent.
- [ ] Owner confirms the first release scope and pilot validation plan.
- [ ] Gate 1–7 verification evidence remains outstanding.

**Conclusion:** Gate 0 consistency audit is complete and passes with actions. The documentation baseline is aligned enough to proceed to readiness evidence gathering and detailed implementation planning; it is not a production-ready schema and does not authorize implementation.
