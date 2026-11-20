# Data Dictionary — Additional Services, SaaS, Audit and Storage

## 10. Restricted health and safeguarding

These tables are optional, phased, and require jurisdiction/school policy review before activation. Need-to-know grants, separate access audit, retention and export controls apply.

### student_health_profiles
`id, school_id FK, student_id FK, health_summary_restricted nullable, emergency_action_plan_restricted nullable, reviewed_by uuid nullable, reviewed_at nullable, valid_from, valid_to nullable, created_at, updated_at`. Store only necessary health context; avoid duplicating detailed notes in general learner profile.

### student_health_conditions
`id, school_id FK, student_id FK, condition_code nullable, description_restricted, severity nullable, onset_date nullable, status, recorded_by uuid, reviewed_by uuid nullable, created_at, updated_at`.

### student_allergies
`id, school_id FK, student_id FK, allergen, reaction_restricted, severity, emergency_instruction_restricted nullable, status, verified_by uuid nullable, verified_at nullable, created_at, updated_at`.

### health_visits
`id, school_id FK, student_id FK, visit_at timestamptz, reason_restricted, observations_restricted nullable, action_taken_restricted nullable, referred_to nullable, recorded_by uuid, guardian_notification_status nullable, created_at`. Access restricted to authorised health role.

### medication_records
`id, school_id FK, student_id FK, medication_name, dosage_restricted, schedule_restricted nullable, start_date, end_date nullable, administration_required boolean, instructions_restricted nullable, authorised_by uuid nullable, status, created_at, updated_at`. Medication administration logs, if enabled, are separate immutable events.

### medication_administration_events
`id, school_id FK, medication_record_id FK, student_id FK, administered_at timestamptz, dose_restricted, administered_by uuid, outcome, notes_restricted nullable, created_at`. Audit corrections; no silent edits.

### safeguarding_incidents
`id, school_id FK, student_id nullable FK, incident_type, occurred_at timestamptz, reported_at timestamptz, narrative_restricted, risk_level, status, assigned_to uuid nullable, reported_by uuid, created_at, updated_at`. Highly restricted, not visible through ordinary student profile, parent messaging or general exports.

### safeguarding_referrals
`id, school_id FK, incident_id FK, referral_type, recipient_agency_restricted, referred_at, status, outcome_restricted nullable, created_by uuid, timestamps`.

### safeguarding_action_plans
`id, school_id FK, incident_id FK, plan_summary_restricted, owner_user_id uuid, start_date, review_date nullable, status, created_by uuid, timestamps`.

### restricted_record_access_logs
`id, school_id FK, record_type, record_id uuid, actor_user_id uuid, access_action, purpose, outcome, occurred_at, request_id nullable`. Append-only access audit, with log visibility separately restricted.

## 11. Library


### library_books
`id, school_id FK, isbn nullable, title, subtitle nullable, authors jsonb, publisher nullable, publication_year nullable, category_id nullable FK library_categories, language_code, description nullable, cover_file_id nullable FK files, created_at, updated_at`. Catalogue metadata; ISBN unique per school when present.

### library_book_copies
`id, school_id FK, book_id FK library_books, accession_number, campus_id nullable FK school_campuses, shelf_location nullable, copy_status, condition, acquired_at nullable, timestamps`. Unique accession number; status available/on-loan/reserved/lost/repair/retired.

### library_categories
`id, school_id FK, code, name, parent_category_id nullable FK library_categories, is_active, timestamps`. Tenant hierarchy; prevent cycles.

### library_loans
`id, school_id FK, copy_id FK library_book_copies, student_id nullable FK students, staff_id nullable FK staff, issued_by uuid, issued_at, due_at, returned_at nullable, return_condition nullable, loan_status, renewed_count, timestamps`. Exactly one borrower type; one active loan per copy.

### library_reservations
`id, school_id FK, book_id FK library_books, student_id nullable FK students, staff_id nullable FK staff, requested_at, reservation_status, fulfilled_copy_id nullable FK library_book_copies, expires_at nullable, timestamps`. Exactly one requester type; queue policy.

### library_fines
`id, school_id FK, loan_id FK library_loans, amount_minor, currency, reason, fine_status, assessed_at, waived_by uuid nullable, waived_reason nullable, payment_reference nullable, timestamps`. Fine workflow may link to school finance receivable via integration; do not duplicate posted finance ledger amounts.

## 12. Transport

### transport_vehicles
`id, school_id FK, registration_number, vehicle_name nullable, capacity, vehicle_type, status, inspection_due date nullable, insurance_due date nullable, campus_id nullable FK school_campuses, timestamps`. Restricted vehicle details.

### transport_routes
`id, school_id FK, route_code, name, direction, academic_year_id nullable FK, status, vehicle_id nullable FK transport_vehicles, driver_id nullable FK transport_drivers, start_time nullable, end_time nullable, timestamps`. Unique code/year as applicable.

### transport_stops
`id, school_id FK, name, location_description, latitude numeric nullable, longitude numeric nullable, safe_pickup_notes nullable, created_at, updated_at`. Coordinates sensitive; restrict access.

### transport_route_stops
`id, school_id FK, route_id FK, stop_id FK, sequence_number, planned_time nullable, created_at`. Unique route/sequence.

### transport_drivers
`id, school_id FK, staff_id nullable FK staff, name, phone, licence_number_encrypted nullable, licence_expiry nullable, status, created_at, updated_at`. Restricted personal/licence fields.

### transport_assignments
`id, school_id FK, student_enrolment_id FK, route_id FK, stop_id FK, assignment_start date, assignment_end nullable, guardian_contact_link_id nullable FK guardian_student_links, status, timestamps`. Assignment must reference stop on selected route.

### transport_incidents
`id, school_id FK, route_id nullable FK, vehicle_id nullable FK, student_id nullable FK, incident_at, incident_type, description_restricted, reported_by uuid, resolution nullable, resolved_by uuid nullable, resolved_at nullable, timestamps`. Restricted safeguarding/safety access.

## 13. Boarding, meals, activities and trips (optional modules)

These are feature-gated modules. Implement only after each workflow, consent, capacity, finance and safeguarding requirements are reviewed.

### boarding_houses
`id, school_id FK, campus_id nullable FK, house_code, name, house_type, capacity nullable, status, timestamps`. Unique code per school.

### boarding_rooms
`id, school_id FK, house_id FK, room_code, capacity, status, timestamps`. Room must belong to the same school/house.

### boarding_assignments
`id, school_id FK, student_enrolment_id FK, room_id FK, start_date, end_date nullable, assignment_status, assigned_by uuid, timestamps`. Validate capacity, date overlap and approved assignment rules.

### meal_plans
`id, school_id FK, plan_code, name, meal_type, price_minor nullable, currency nullable, effective_from, effective_to nullable, status, timestamps`. Meal fees remain linked to school finance using explicit fee/payment workflow.

### meal_orders
`id, school_id FK, student_enrolment_id FK, meal_plan_id FK, service_date date, order_status, dietary_notes_restricted nullable, created_by uuid, timestamps`. Restricted dietary details; validate order date and plan eligibility.

### meal_attendance
`id, school_id FK, meal_order_id FK nullable, student_enrolment_id FK, service_date date, meal_type, attendance_status, recorded_by uuid, created_at`. Unique per learner/date/meal type as policy requires.

### clubs
`id, school_id FK, club_code, name, description nullable, staff_lead_id nullable FK staff, capacity nullable, status, timestamps`.

### activities
`id, school_id FK, activity_type, title, description nullable, starts_at timestamptz, ends_at nullable, venue nullable, capacity nullable, lead_staff_id nullable FK staff, activity_status, permission_required boolean, created_by uuid, timestamps`. Supports clubs, sports, events and school activities.

### activity_memberships
`id, school_id FK, activity_id FK, student_enrolment_id FK, joined_at, left_at nullable, membership_status, consent_status, timestamps`. Validate capacity and eligibility.

### trips
`id, school_id FK, trip_code, title, destination, starts_at timestamptz, ends_at nullable, transport_plan nullable, lead_staff_id FK staff, trip_status, permission_required boolean, created_by uuid, timestamps`.

### trip_permissions
`id, school_id FK, trip_id FK, student_enrolment_id FK, guardian_student_link_id FK, permission_status, signed_at nullable, evidence_file_id nullable FK files, submitted_at nullable, reviewed_by uuid nullable, reviewed_at nullable, timestamps`. Only verified legal/authorised guardian can grant permission; apply custody/access restrictions.

### trip_attendance
`id, school_id FK, trip_id FK, student_enrolment_id FK, attendance_status, checked_at nullable, recorded_by uuid, notes_restricted nullable, created_at`. Unique trip/learner.

## 15. Documents

### document_categories
`id, school_id FK, name, code, sensitivity, retention_rule_id nullable, is_active, timestamps`.

### documents
`id, school_id FK, category_id FK, file_id FK files, title, description nullable, owner_entity_type nullable, owner_entity_id nullable, sensitivity, document_status, uploaded_by uuid, created_at, updated_at`. Entity links are polymorphic and validated by application; sensitive categories require explicit policies.

### document_versions
`id, school_id FK, document_id FK, file_id FK files, version_number, uploaded_by uuid, change_note nullable, created_at`. Immutable versions; unique document/version.

### document_permissions
`id, school_id FK, document_id FK, principal_type, principal_id uuid, permission, granted_by uuid, valid_from, valid_until nullable, created_at`. Enforce tenant scope and no public grants for restricted documents.

### document_access_logs
`id, school_id FK, document_id FK, user_id uuid, action, outcome, accessed_at, safe_context jsonb`. Audit access/download.

### document_retention_rules
`id, school_id FK, category_id nullable FK document_categories, retention_period_days nullable, action_at_expiry, legal_hold, description, created_at, updated_at`. Legal hold supersedes deletion workflow.

## 14. Service desk

### support_tickets
`id, school_id FK, ticket_number, requester_user_id nullable FK user_profiles, requester_guardian_id nullable FK guardians, category_id nullable FK ticket_categories, subject, description, priority, ticket_status, assigned_to uuid nullable, related_student_id nullable FK students, created_at, updated_at, closed_at nullable`. Ticket references only authorised context; sensitive ticket types restricted.

### ticket_categories
`id, school_id FK, code, name, default_priority, is_active, timestamps`.

### ticket_messages
`id, school_id FK, ticket_id FK, sender_user_id nullable FK, message_body, visibility (requester/internal), created_at, edited_at nullable`. Internal notes hidden from requester; audit edits.

### ticket_assignments
`id, school_id FK, ticket_id FK, assignee_user_id, assigned_by uuid, assigned_at, unassigned_at nullable, created_at`. Assignment history.

### ticket_attachments
`id, school_id FK, ticket_id FK, message_id nullable FK ticket_messages, file_id FK files, uploaded_by uuid, created_at`.

### ticket_status_history
`id, school_id FK, ticket_id FK, old_status nullable, new_status, changed_by uuid, reason nullable, changed_at`. Append-only.

## 15. XEN commercial SaaS billing

These records describe billing of schools as customers of XEN, separate from student fee balances. Tenant scoping differs: subscription records reference the school customer; platform staff have controlled access.

### subscription_plans
`id uuid PK, plan_key unique, name, description, billing_interval, base_price_minor, currency, status, effective_from, effective_to nullable, created_at, updated_at`. Version prices; do not retroactively mutate active contracts without change event.

### subscription_features
`id, plan_id FK subscription_plans, feature_key, included_quantity nullable, limit_unit nullable, feature_config jsonb, created_at`. Unique plan/feature.

### school_subscriptions
`id, school_id FK, plan_id FK, subscription_status, start_at, trial_end_at nullable, current_period_start, current_period_end, cancel_at_period_end, cancelled_at nullable, external_customer_id nullable, created_at, updated_at`. History should permit subscription changes over time.

### subscription_items
`id, school_subscription_id FK, feature_key, quantity, unit_price_minor, currency, item_status, effective_from, effective_to nullable, created_at`. Snapshot contracted pricing.

### subscription_invoices
`id, school_id FK, school_subscription_id FK, invoice_number, currency, subtotal_minor, tax_minor, total_minor, balance_minor, issued_at, due_at nullable, invoice_status, period_start, period_end, created_at, updated_at`. Separate from school invoices.

### subscription_payments
`id, school_id FK, subscription_invoice_id FK, amount_minor, currency, payment_method, provider_reference nullable, payment_status, received_at nullable, idempotency_key nullable, created_at, updated_at`.

### subscription_events
`id, school_id FK, school_subscription_id FK, event_type, previous_state jsonb nullable, new_state jsonb, actor_type, actor_id nullable, occurred_at, created_at`. Append-only.

### usage_records
`id, school_id FK, feature_key, quantity, unit, period_start, period_end, source, deduplication_key, recorded_at`. Unique deduplication key; aggregated for metering.

### billing_customers
`id, school_id FK, legal_name, billing_email, billing_address jsonb, tax_identifier_encrypted nullable, external_customer_reference nullable, created_at, updated_at`. Restricted billing contact data.

### platform_promotions
`id uuid PK, promo_code unique, promotion_type, value, currency nullable, starts_at, ends_at, max_redemptions nullable, status, created_at, updated_at`. Redemption ledger needed before applying promotions.

## 16. Security, audit and operations

### audit_logs
`id uuid PK, school_id nullable FK schools, actor_user_id nullable FK user_profiles, actor_type, action, resource_type, resource_id nullable, outcome, occurred_at, request_id nullable, ip_hash nullable, user_agent_summary nullable, changes_redacted jsonb nullable`. Append-only, restricted; never store credentials or full sensitive payloads.

### security_events
`id uuid PK, school_id nullable FK, user_id nullable FK, event_type, severity, occurred_at, source, safe_metadata jsonb, resolved_at nullable, resolved_by nullable`. Alertable and retention-controlled.

### login_activity
`id uuid PK, user_id nullable FK user_profiles, school_id nullable FK, occurred_at, result, method, ip_hash nullable, device_summary nullable, risk_flags jsonb`. Security access only; minimize retention.

### data_export_requests
`id, school_id FK, requester_user_id FK, export_scope jsonb, request_status, approved_by nullable, requested_at, completed_at nullable, file_id nullable FK files, expires_at nullable, audit_reference`. Verify permissions and redact excluded fields.

### data_deletion_requests
`id, school_id FK, requester_user_id nullable FK, subject_type, subject_id uuid, legal_basis, request_status, reviewed_by nullable, reviewed_at nullable, completed_at nullable, outcome_summary, created_at`. Preserve legal/financial/child-protection retention obligations and record decisions.

### consent_records
`id, school_id FK, subject_type, subject_id uuid, consent_type, policy_version, consent_status, granted_by_user_id nullable, granted_at nullable, withdrawn_at nullable, evidence_file_id nullable FK files, created_at`. Record guardian authority and consent purpose; withdrawal history.

### system_jobs
`id uuid PK, school_id nullable FK, job_type, job_status, queued_at, started_at nullable, finished_at nullable, attempt_count, idempotency_key nullable, safe_payload jsonb, created_at`.

### job_failures
`id uuid PK, job_id FK system_jobs, failed_at, error_code, safe_error_summary, retryable, attempt_number, created_at`. Never log secrets.

### webhook_logs
`id uuid PK, school_id nullable FK, provider, event_id, event_type, signature_valid, received_at, processed_at nullable, processing_status, safe_payload jsonb, error_code nullable`. Unique provider/event ID for deduplication.

### backup_records
`id uuid PK, environment, backup_type, started_at, completed_at nullable, status, storage_reference, checksum nullable, retention_until nullable, restore_tested_at nullable, created_at`. Do not expose storage secrets; restore tests recorded.

## 17. Shared file metadata (storage)

### files
`id uuid PK, school_id uuid nullable FK schools, storage_provider, bucket_name, object_key, original_filename, content_type, size_bytes bigint, checksum_sha256 nullable, privacy_class, uploaded_by uuid nullable FK user_profiles, scan_status, file_status, created_at, updated_at, deleted_at nullable`. Unique provider/bucket/object key. Storage objects are not public by default; public media requires explicit approval and consent checks. Do not store signed URLs as durable values.
