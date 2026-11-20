# Data Dictionary — Academics, Attendance, Assessment and Admissions

Common columns and tenant rules are defined in `data-dictionary-platform.md`. All tables below are school-scoped, with same-school FK checks required. Default timestamps apply unless stated.

## 3. Academic structure

### academic_programmes
`id, school_id, programme_code, name, education_stage, description nullable, programme_status, effective_from, effective_to nullable, timestamps`. School-scoped programmes (e.g., national curriculum, Cambridge, IB or specialist tracks) are configurable; programme names/codes are not hardcoded globally.

### academic_calendars
`id, school_id, calendar_code, name, calendar_type, campus_id nullable FK, programme_id nullable FK academic_programmes, timezone, calendar_status, is_default, effective_from, effective_to nullable, timestamps`. A school may maintain multiple calendars for different campuses, programmes, cohorts or operating patterns. Calendar applicability and default rules must be explicit.

### academic_years
`id, school_id, calendar_id FK academic_calendars, name, start_date, end_date, status, is_current, timestamps`. Unique name per calendar; valid range; at most one current year per calendar. The calendar is the date-structure parent, not merely a label.

### academic_terms
`id, school_id, calendar_id FK academic_calendars, academic_year_id FK, name, term_number, start_date, end_date, status, timestamps`. Unique term number/name per year/calendar as configured. Term dates must fit the academic-year policy. Overlap is permitted only when the calendar explicitly allows it; do not enforce a school-wide no-overlap rule.

### calendar_events
`id, school_id, calendar_id nullable FK academic_calendars, campus_id nullable FK school_campuses, academic_year_id nullable FK, event_type, title, description nullable, starts_on date, ends_on date nullable, is_school_day boolean nullable, visibility, status, created_by uuid, timestamps`. Supports holidays, closures, examinations, school events and trips; public visibility requires publication approval. Dates are date-only facts.

### timetable_periods
`id, school_id, calendar_id FK, campus_id nullable FK, period_code, name, sequence_number, local_start_time time, local_end_time time, period_type, is_active, timestamps`. Times are local wall-clock values interpreted with the calendar/campus timezone; start must precede end.

### school_rooms
`id, school_id, campus_id nullable FK, room_code, name, room_type, capacity nullable, accessibility_notes_restricted nullable, room_status, timestamps`. Unique room code within campus/school; room allocation is tenant-scoped.

### timetables
`id, school_id, calendar_id FK, academic_year_id FK, campus_id nullable FK, timetable_type, version_number, status, effective_from date, effective_to nullable, approved_by uuid nullable, approved_at nullable, published_at nullable, created_by uuid, timestamps`. Versioned draft/review/approved/published/retired schedules; preserve published versions and history.

### timetable_entries
`id, school_id, timetable_id FK, class_subject_id FK, class_id FK, stream_id nullable FK, teacher_assignment_id nullable FK, room_id nullable FK school_rooms, weekday, period_id FK timetable_periods, valid_from date nullable, valid_to date nullable, entry_status, timestamps`. Entries must agree with class-subject, teacher, calendar, campus and stream scopes. Detect class, teacher and room clashes within effective timetable versions.

### timetable_exceptions
`id, school_id, timetable_id FK, timetable_entry_id FK, exception_date date, exception_type, replacement_period_id nullable FK, replacement_room_id nullable FK, reason nullable, approved_by uuid nullable, created_at`. Supports cancellations/moved sessions without rewriting recurring entries.

### grade_levels

### grade_levels
`id, school_id, code, name, sort_order, education_stage, age_min nullable, age_max nullable, is_active, timestamps`. Unique code; configurable for school context (e.g., Grade, Form, Year).

### classes
`id, school_id, academic_year_id FK, grade_level_id FK, name, code, campus_id nullable FK, capacity nullable, class_teacher_staff_id nullable FK staff, status, timestamps`. Unique code/year. Class roster assignments are recorded separately.

### class_streams
`id, school_id, class_id FK, name, code, capacity nullable, status, timestamps`. Unique stream code/class.

### subjects
`id, school_id, code, name, short_name, subject_group nullable, is_core, is_active, timestamps`. Unique code.

### class_subjects
`id, school_id, academic_year_id FK, class_id FK, subject_id FK, stream_id nullable FK, teacher_staff_id nullable FK staff, periods_per_week nullable, status, timestamps`. Unique class/subject/stream/year combination.

### student_class_assignments
`id, school_id, student_enrolment_id FK, class_id FK, stream_id nullable FK, start_date, end_date nullable, assignment_status, assigned_by uuid, timestamps`. Preserve movement history; prevent overlapping active assignment except approved multi-class arrangements.

### assessment_categories
`id, school_id, category_code, name, category_type, default_weight nullable, is_required boolean, is_active, timestamps`. Categories include tests, coursework, practicals, projects and examinations; weighting is configured per applicable scheme/assessment period.

### grading_schemes
`id, school_id, name, description, grade_level_id nullable FK, subject_id nullable FK, academic_year_id nullable FK, calculation_method, pass_mark nullable, ranking_policy nullable, ranking_scope nullable, tie_rule nullable, is_default, status, timestamps`. Scheme changes are versioned; ranking is configurable or disabled by school policy.

### grading_scheme_versions
`id, school_id, grading_scheme_id FK, version_number, rules_snapshot jsonb, effective_from, effective_to nullable, approved_by uuid nullable, approved_at nullable, created_at`. Snapshot of calculation/weighting/aggregation rules; marks/results reference the effective version for reproducibility.

### promotion_rules
`id, school_id, academic_year_id FK, from_grade_level_id FK, to_grade_level_id nullable FK, rule_version, rule_config jsonb, approval_status, approved_by uuid nullable, effective_from, effective_to nullable, timestamps`. Configurable promotion/repeat/subject prerequisites; evaluation produces an auditable decision, not automatic destructive enrolment change.

### report_card_templates
`id, school_id, template_code, name, grade_level_id nullable FK, language_code, template_version, layout_config jsonb, status, approved_by uuid nullable, approved_at nullable, created_at, updated_at`. Validated template/layout snapshot for PDF and digital report cards.

### grading_scale_items
`id, school_id, grading_scheme_id FK, label, grade_code, min_percent, max_percent, points nullable, interpretation nullable, sort_order, timestamps`. Non-overlapping inclusive/exclusive boundary design documented; unique code per scheme; boundaries tied to a versioned grading scheme.

## 4. Attendance

### attendance_sessions
`id, school_id, academic_year_id FK, term_id nullable FK, class_id FK, stream_id nullable FK, session_date date, session_type text (daily/period/event), period_id nullable FK timetable_periods, recorded_by uuid FK user_profiles, status (draft/submitted/approved/locked), submitted_at, approved_by uuid nullable, approved_at nullable, notes nullable, timestamps`. Unique class/date/type/period/stream as applicable.

### attendance_records
`id, school_id, session_id FK, student_id FK, attendance_status text (present/absent/late/excused/partial/other), arrival_time timestamptz nullable, minutes_late integer nullable, reason_code nullable, note nullable, recorded_by uuid, updated_by uuid nullable, timestamps`. Unique session/student. Validate late minutes and state; restricted notes.

### attendance_corrections
`id, school_id, attendance_record_id FK, previous_status, new_status, reason, requested_by uuid, reviewed_by uuid nullable, review_status, reviewed_at nullable, created_at`. Append-only correction log.

### attendance_notifications
`id, school_id, attendance_record_id FK, guardian_id FK, channel, delivery_status, provider_reference nullable, sent_at nullable, error_code nullable, created_at`. Track attempted notification; don't store unnecessary message payload.

## 5. Assessments and results

### assessment_periods
`id, school_id, academic_year_id FK, term_id nullable FK, name, start_date, end_date, status, timestamps`.

### assessments
`id, school_id, assessment_period_id FK, class_subject_id FK, title, assessment_type, assessment_date, max_score numeric, weight numeric nullable, grading_scheme_id nullable FK, status (draft/open/submitted/moderated/approved/published/archived), created_by uuid, approved_by uuid nullable, approved_at nullable, timestamps`. Scores must be within permitted maximum; weight rules validated.

### assessment_components
`id, school_id, assessment_id FK, name, max_score numeric, weight numeric nullable, sort_order, timestamps`. Components optional; if used, component total rules apply.

### student_marks
`id, school_id, assessment_id FK, student_id FK, component_id nullable FK, score numeric nullable, absent_code nullable, comment nullable, entered_by uuid, updated_by uuid nullable, status, timestamps`. Unique assessment/student/component. A mark is either score or approved absence/no-mark code, not both. Restricted access.

### mark_moderation
`id, school_id, student_mark_id FK, old_score numeric nullable, proposed_score numeric nullable, reason, moderator_user_id uuid, decision, decided_at nullable, created_at`. Audit trail of adjustments; do not overwrite moderation history.

### student_results
`id, school_id, assessment_id FK, student_id FK, total_score numeric, percentage numeric nullable, grade_label text nullable, grade_points numeric nullable, rank nullable, calculation_version text, result_status, calculated_at, approved_by uuid nullable, approved_at nullable, published_at nullable, timestamps`. Unique assessment/student; calculated values are snapshots, recalculate with versioned process before publication.

### report_cards
`id, school_id, student_enrolment_id FK` (field name should be `student_enrolment_id`), academic_year_id FK, term_id nullable FK, report_card_type, status, generated_at, approved_by uuid nullable, approved_at nullable, published_at nullable, file_id uuid nullable FK files, created_by uuid, timestamps`. Unique enrolment/year/term/type. Treat report output as snapshot.

### report_card_items
`id, school_id, report_card_id FK, subject_id FK, assessment_summary jsonb, total_score numeric nullable, grade_label nullable, teacher_comment nullable, position, timestamps`. JSON is only for a versioned summary snapshot; underlying marks remain relational.

## 6. Admissions

### admission_campaigns
`id, school_id, academic_year_id FK, name, opens_at timestamptz, closes_at timestamptz nullable, target_grade_level_id nullable FK, status, form_schema jsonb, form_version, published_at nullable, created_by uuid, timestamps`. Configurable, versioned schema; only collect approved necessary fields. Fee configuration is stored canonically in admission_fee_settings rather than duplicated on the campaign row.

### admission_applications
`id, school_id, campaign_id FK, application_reference text, applicant_given_name, applicant_middle_name nullable, applicant_family_name, applicant_date_of_birth date nullable, applicant_grade_level_id nullable FK, applicant_gender nullable, previous_school nullable, application_status, submitted_at nullable, withdrawn_at nullable, converted_student_id uuid nullable FK students, assigned_reviewer_user_id uuid nullable, fee_snapshot_id nullable FK admission_application_fee_snapshots, timestamps`. Unique reference per school; applicant remains separate from student until authorised conversion. Form version and fee snapshot must be preserved for each submitted application.

### admission_applicants
`id, school_id, application_id FK, applicant_type (student/other), name fields, date_of_birth nullable, contact fields nullable, relationship nullable, created_at`. Use where campaign forms support additional applicants; define canonical applicant data mapping carefully.

### admission_guardians
`id, school_id, application_id FK, guardian_name, relationship, email, phone, address nullable, is_primary, consent_flags jsonb, created_at, updated_at`. Guardian records should be merged/converted only after verification and acceptance.

### admission_documents
`id, school_id, application_id FK, document_type, file_id FK files, verification_status, reviewed_by uuid nullable, reviewed_at nullable, rejection_reason nullable, created_at`.

### admission_reviews
`id, school_id, application_id FK, reviewer_user_id uuid, review_stage, decision, score numeric nullable, notes restricted, reviewed_at, created_at`. Reviews are append-only history.

### admission_interviews
`id, school_id, application_id FK, scheduled_at timestamptz, location_or_link nullable, interviewer_staff_id nullable FK staff, status, outcome nullable, notes restricted, created_at, updated_at`.

### admission_offers
`id, school_id, application_id FK, offer_reference, offered_grade_level_id FK, offer_status, issued_at, expires_at nullable, accepted_at nullable, declined_at nullable, conditions jsonb, issued_by uuid, timestamps`. Unique reference; offer transitions logged.

### admission_status_history
`id, school_id, application_id FK, old_status nullable, new_status, changed_by uuid, reason nullable, changed_at`. Append-only.

### admission_fee_settings
`id, school_id, campaign_id FK, version_number, fee_required boolean, amount_minor bigint nullable, currency char(3) nullable, due_rule text nullable, waiver_allowed boolean, refund_rule text nullable, effective_from, effective_to nullable, is_active, created_by uuid, timestamps`. This is the single canonical campaign fee configuration; free applications are explicit. Version changes do not alter submitted applications. Application fees are separate from tuition.

### admission_application_fee_snapshots
`id, school_id, application_id FK, fee_setting_id FK, fee_setting_version, fee_required boolean, amount_minor bigint nullable, currency char(3) nullable, waiver_status, waived_amount_minor nullable, waiver_reason nullable, approved_by uuid nullable, due_at nullable, refund_policy_snapshot nullable, created_at`. Freeze the applicable fee/waiver terms when an application is submitted or fee is assessed; free/waived applications must be distinguishable from unpaid fees.

### admission_payments

### admission_payment_refunds
`id, school_id FK, admission_payment_id FK, refund_reference, amount_minor bigint, currency char(3), refund_status, reason, requested_by uuid, approved_by uuid nullable, processed_at nullable, provider_reference nullable, created_at, updated_at`. Refunds reference original admission payments, cannot exceed verified paid amount net of previous refunds, and require policy-based approval/audit.
`id, school_id, application_id FK, fee_snapshot_id FK, amount_minor bigint, currency char(3), payment_method_code, provider_reference nullable, verification_status, verified_by uuid nullable, verified_at nullable, paid_at nullable, receipt_reference nullable, idempotency_key nullable, created_at, updated_at`. Verify through trusted provider/bank/cash workflow; uploaded proof alone is not proof of settlement. Payment/refund states and reconciliation are auditable.
