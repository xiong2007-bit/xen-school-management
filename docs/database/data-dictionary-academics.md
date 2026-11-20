# Data Dictionary — Academics, Attendance, Assessment and Admissions

Common columns and tenant rules are defined in `data-dictionary-platform.md`. All tables below are school-scoped, with same-school FK checks required. Default timestamps apply unless stated.

## 3. Academic structure

### academic_years
`id, school_id, name, start_date, end_date, status, is_current, created_at, updated_at`. Unique name per school; date range valid; at most one current year per school.

### academic_terms
`id, school_id, academic_year_id FK, name, term_number, start_date, end_date, status, created_at, updated_at`. Unique term number/year; term dates within year; no overlapping terms unless calendar policy permits.

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

### grading_schemes
`id, school_id, name, description, grade_level_id nullable FK, subject_id nullable FK, academic_year_id nullable FK, calculation_method, pass_mark nullable, is_default, status, timestamps`. Version schemes by year where grading changes.

### grading_scale_items
`id, school_id, grading_scheme_id FK, label, grade_code, min_percent, max_percent, points nullable, interpretation nullable, sort_order, timestamps`. Non-overlapping inclusive/exclusive boundary design documented; unique code per scheme.

## 4. Attendance

### attendance_sessions
`id, school_id, academic_year_id FK, term_id nullable FK, class_id FK, stream_id nullable FK, session_date date, session_type text (daily/period/event), period_id nullable uuid, recorded_by uuid FK user_profiles, status (draft/submitted/approved/locked), submitted_at, approved_by uuid nullable, approved_at nullable, notes nullable, timestamps`. Unique class/date/type/period/stream as applicable.

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
`id, school_id, academic_year_id FK, name, opens_at timestamptz, closes_at timestamptz nullable, target_grade_level_id nullable FK, status, application_fee_required boolean, fee_amount_minor bigint nullable, fee_currency char(3) nullable, fee_refund_policy text nullable, form_schema jsonb, published_at nullable, created_by uuid, timestamps`. Configurable, versioned schema; only collect approved necessary fields.

### admission_applications
`id, school_id, campaign_id FK, application_reference text, applicant_given_name, applicant_middle_name nullable, applicant_family_name, applicant_date_of_birth date nullable, applicant_grade_level_id nullable FK, applicant_gender nullable, previous_school nullable, application_status, submitted_at nullable, withdrawn_at nullable, converted_student_id uuid nullable FK students, assigned_reviewer_user_id uuid nullable, timestamps`. Unique reference per school; applicant remains separate from student until authorised conversion.

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
`id, school_id, campaign_id FK, amount_minor bigint, currency char(3), due_rule text, waiver_allowed boolean, refund_rule text, is_active, timestamps`. Amount is campaign application fee, not tuition.

### admission_payments
`id, school_id, application_id FK, fee_setting_id FK, amount_minor bigint, currency char(3), payment_method_id nullable FK payment_methods, provider_reference nullable, verification_status, verified_by uuid nullable, verified_at nullable, paid_at nullable, receipt_reference nullable, created_at, updated_at`. Verify through trusted provider/bank/cash workflow; uploaded proof alone is not proof of settlement.
