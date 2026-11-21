-- Catalog-reconstructed table columns/defaults. Review before clean replay.
create table public.academic_calendars (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  code text not null,
  name text not null,
  timezone text not null default 'Africa/Harare'::text,
  campus_id uuid,
  programme_id uuid,
  status text not null default 'active'::text,
  created_at timestamp with time zone not null default now()
);

create table public.academic_programmes (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  code text not null,
  name text not null,
  stage text,
  status text not null default 'active'::text,
  created_at timestamp with time zone not null default now()
);

create table public.academic_terms (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  academic_year_id uuid not null,
  name text not null,
  term_number integer,
  start_date date not null,
  end_date date not null,
  status text not null default 'planned'::text,
  created_at timestamp with time zone not null default now()
);

create table public.academic_years (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  calendar_id uuid not null,
  name text not null,
  start_date date not null,
  end_date date not null,
  status text not null default 'planned'::text,
  created_at timestamp with time zone not null default now()
);

create table public.accounting_periods (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  name text not null,
  start_date date not null,
  end_date date not null,
  status text default 'open'::text,
  closed_at timestamp with time zone
);

create table public.activities (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  record_data jsonb not null default '{}'::jsonb,
  status text not null default 'active'::text,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

create table public.activity_memberships (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  record_data jsonb not null default '{}'::jsonb,
  status text not null default 'active'::text,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

create table public.admission_applicants (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  application_id uuid not null,
  first_name text not null,
  last_name text not null,
  date_of_birth date,
  extra_data jsonb default '{}'::jsonb
);

create table public.admission_application_fee_snapshots (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  application_id uuid not null,
  setting_id uuid not null,
  amount_minor bigint not null,
  currency character(3) not null,
  waived boolean default false,
  waiver_reason text
);

create table public.admission_applications (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  campaign_id uuid not null,
  reference text not null,
  status text not null default 'draft'::text,
  submitted_at timestamp with time zone,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

create table public.admission_campaigns (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  code text not null,
  name text not null,
  academic_year_id uuid,
  opens_on date,
  closes_on date,
  form_schema jsonb not null default '{}'::jsonb,
  status text not null default 'draft'::text,
  created_at timestamp with time zone default now()
);

create table public.admission_documents (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  application_id uuid not null,
  file_id uuid not null,
  doc_type text not null,
  scan_status text default 'pending'::text,
  review_status text default 'pending'::text
);

create table public.admission_fee_settings (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  campaign_id uuid not null,
  version integer not null,
  fee_required boolean default false,
  amount_minor bigint not null default 0,
  currency character(3) not null,
  waiver_allowed boolean default false,
  policy jsonb default '{}'::jsonb,
  effective_from date not null,
  effective_until date
);

create table public.admission_fee_snapshots (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  application_id uuid not null,
  setting_id uuid not null,
  amount_minor bigint not null,
  currency character(3) not null,
  waived boolean default false,
  waiver_reason text
);

create table public.admission_guardians (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  application_id uuid not null,
  first_name text not null,
  last_name text not null,
  relationship text,
  email text,
  phone text,
  consent_status text default 'pending'::text
);

create table public.admission_interviews (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  application_id uuid not null,
  interviewer_id uuid,
  scheduled_at timestamp with time zone,
  timezone text,
  status text default 'scheduled'::text,
  restricted_notes text
);

create table public.admission_offers (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  application_id uuid not null,
  offer_reference text not null,
  expires_at timestamp with time zone,
  decision text default 'pending'::text,
  decided_at timestamp with time zone
);

create table public.admission_payment_refunds (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  payment_id uuid not null,
  amount_minor bigint not null,
  reason text,
  status text default 'requested'::text,
  approved_by uuid,
  created_at timestamp with time zone default now()
);

create table public.admission_payments (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  application_id uuid not null,
  amount_minor bigint not null,
  currency character(3) not null,
  provider_ref text,
  idempotency_key text not null,
  status text default 'pending'::text,
  verified_by uuid,
  verified_at timestamp with time zone,
  created_at timestamp with time zone default now()
);

create table public.admission_reviews (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  application_id uuid not null,
  reviewer_id uuid,
  decision text,
  review_notes text,
  reviewed_at timestamp with time zone
);

create table public.admission_status_history (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  application_id uuid not null,
  from_status text,
  to_status text,
  actor_id uuid,
  reason text,
  occurred_at timestamp with time zone default now()
);

create table public.admissions_conversion_log (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  application_id uuid not null,
  student_id uuid not null,
  enrolment_id uuid,
  conversion_key text not null,
  converted_at timestamp with time zone default now()
);

create table public.announcement_recipients (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  announcement_id uuid not null,
  user_id uuid,
  guardian_link_id uuid,
  delivery_status text default 'queued'::text,
  delivered_at timestamp with time zone
);

create table public.announcements (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  title text not null,
  body text not null,
  audience jsonb default '{}'::jsonb,
  status text default 'draft'::text,
  published_at timestamp with time zone,
  created_by uuid,
  created_at timestamp with time zone default now()
);

create table public.assessment_categories (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  name text not null,
  weighting numeric(7,4),
  status text not null default 'active'::text,
  created_at timestamp with time zone not null default now()
);

create table public.assessment_components (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  assessment_id uuid not null,
  name text not null,
  max_score numeric(12,4) not null,
  weighting numeric(7,4),
  sort_order integer not null default 0,
  created_at timestamp with time zone not null default now()
);

create table public.assessment_periods (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  academic_year_id uuid not null,
  term_id uuid,
  name text not null,
  start_date date not null,
  end_date date not null,
  status text not null default 'planned'::text,
  created_at timestamp with time zone not null default now()
);

create table public.assessments (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  class_subject_id uuid not null,
  assessment_period_id uuid not null,
  category_id uuid,
  scheme_version_id uuid,
  title text not null,
  max_score numeric(12,4) not null,
  weighting numeric(7,4),
  due_date date,
  status text not null default 'draft'::text,
  created_by uuid,
  approved_by uuid,
  published_at timestamp with time zone,
  created_at timestamp with time zone not null default now()
);

create table public.attendance_corrections (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  attendance_record_id uuid not null,
  old_status text not null,
  new_status text not null,
  reason text not null,
  requested_by uuid,
  reviewed_by uuid,
  created_at timestamp with time zone not null default now()
);

create table public.attendance_notifications (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  attendance_record_id uuid not null,
  guardian_link_id uuid not null,
  notification_type text not null,
  delivery_status text not null default 'queued'::text,
  idempotency_key text not null,
  created_at timestamp with time zone not null default now()
);

create table public.attendance_records (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  session_id uuid not null,
  student_id uuid not null,
  status text not null,
  minutes_late integer not null default 0,
  note text,
  recorded_by uuid,
  recorded_at timestamp with time zone not null default now()
);

create table public.attendance_sessions (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  class_id uuid not null,
  stream_id uuid,
  academic_term_id uuid,
  session_date date not null,
  session_type text not null default 'daily'::text,
  period_label text,
  status text not null default 'draft'::text,
  recorded_by uuid,
  approved_by uuid,
  created_at timestamp with time zone not null default now()
);

create table public.audit_logs (
  id uuid not null default gen_random_uuid(),
  school_id uuid,
  actor_user_id uuid,
  action text not null,
  resource_type text not null,
  resource_id uuid,
  occurred_at timestamp with time zone not null default now(),
  request_id text,
  metadata jsonb not null default '{}'::jsonb
);

create table public.backup_inventory (
  id uuid not null default gen_random_uuid(),
  school_id uuid,
  record_data jsonb not null default '{}'::jsonb,
  created_at timestamp with time zone default now()
);

create table public.bank_accounts (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  account_name text not null,
  bank_name text,
  masked_account text,
  encrypted_reference text,
  currency character(3) not null,
  status text default 'active'::text
);

create table public.bank_statement_entries (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  import_id uuid not null,
  bank_account_id uuid not null,
  entry_date date not null,
  description text,
  amount_minor bigint not null,
  currency character(3) not null,
  dedupe_key text not null
);

create table public.bank_statement_imports (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  bank_account_id uuid not null,
  file_id uuid,
  status text default 'uploaded'::text,
  created_at timestamp with time zone default now()
);

create table public.billing_customers (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  contact_data jsonb default '{}'::jsonb,
  provider_ref text,
  created_at timestamp with time zone default now()
);

create table public.boarding_assignments (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  record_data jsonb not null default '{}'::jsonb,
  status text not null default 'active'::text,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

create table public.boarding_houses (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  record_data jsonb not null default '{}'::jsonb,
  status text not null default 'active'::text,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

create table public.boarding_rooms (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  record_data jsonb not null default '{}'::jsonb,
  status text not null default 'active'::text,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

create table public.budget_items (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  budget_id uuid not null,
  item_description text,
  amount_minor bigint not null
);

create table public.budgets (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  account_id uuid,
  period_id uuid,
  name text not null,
  amount_minor bigint not null,
  currency character(3) not null,
  status text default 'draft'::text
);

create table public.calendar_events (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  calendar_id uuid,
  campus_id uuid,
  title text not null,
  event_type text not null,
  start_date date not null,
  end_date date not null,
  is_school_day boolean not null default false,
  visibility text not null default 'internal'::text,
  created_at timestamp with time zone not null default now()
);

create table public.chart_of_accounts (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  account_code text not null,
  name text not null,
  account_type text not null,
  parent_account_id uuid,
  status text default 'active'::text
);

create table public.class_streams (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  class_id uuid not null,
  code text not null,
  name text not null,
  capacity integer,
  status text not null default 'active'::text,
  created_at timestamp with time zone not null default now()
);

create table public.class_subjects (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  class_id uuid not null,
  subject_id uuid not null,
  academic_year_id uuid not null,
  stream_id uuid,
  created_at timestamp with time zone not null default now()
);

create table public.classes (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  academic_year_id uuid not null,
  grade_level_id uuid not null,
  campus_id uuid,
  code text not null,
  name text not null,
  capacity integer,
  status text not null default 'active'::text,
  created_at timestamp with time zone not null default now()
);

create table public.clubs (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  record_data jsonb not null default '{}'::jsonb,
  status text not null default 'active'::text,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

create table public.communication_provider_logs (
  id uuid not null default gen_random_uuid(),
  school_id uuid,
  provider text,
  event_type text,
  provider_reference text,
  status text,
  received_at timestamp with time zone default now(),
  safe_payload jsonb default '{}'::jsonb
);

create table public.consent_records (
  id uuid not null default gen_random_uuid(),
  school_id uuid,
  subject_type text not null,
  subject_id uuid not null,
  purpose text not null,
  consent_version text not null,
  status text not null,
  recorded_by uuid,
  recorded_at timestamp with time zone not null default now(),
  expires_at timestamp with time zone
);

create table public.credit_notes (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  invoice_id uuid not null,
  credit_number text not null,
  amount_minor bigint not null,
  reason text,
  status text default 'draft'::text,
  created_at timestamp with time zone default now()
);

create table public.currency_conversion_snapshots (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  source_currency character(3) not null,
  target_currency character(3) not null,
  source_minor bigint not null,
  target_minor bigint not null,
  rate numeric(24,12) not null,
  rate_at timestamp with time zone not null,
  source text,
  created_at timestamp with time zone default now()
);

create table public.currency_definitions (
  currency_code character(3) not null,
  currency_name text not null,
  minor_unit_digits smallint not null,
  active boolean default true
);

create table public.data_deletion_requests (
  id uuid not null default gen_random_uuid(),
  school_id uuid,
  record_data jsonb not null default '{}'::jsonb,
  created_at timestamp with time zone default now()
);

create table public.data_export_requests (
  id uuid not null default gen_random_uuid(),
  school_id uuid,
  record_data jsonb not null default '{}'::jsonb,
  created_at timestamp with time zone default now()
);

create table public.document_access_logs (
  id uuid not null default gen_random_uuid(),
  school_id uuid,
  record_data jsonb not null default '{}'::jsonb,
  created_at timestamp with time zone default now()
);

create table public.document_categories (
  id uuid not null default gen_random_uuid(),
  school_id uuid,
  record_data jsonb not null default '{}'::jsonb,
  created_at timestamp with time zone default now()
);

create table public.document_permissions (
  id uuid not null default gen_random_uuid(),
  school_id uuid,
  record_data jsonb not null default '{}'::jsonb,
  created_at timestamp with time zone default now()
);

create table public.document_records (
  id uuid not null default gen_random_uuid(),
  school_id uuid,
  record_data jsonb not null default '{}'::jsonb,
  created_at timestamp with time zone default now()
);

create table public.document_versions (
  id uuid not null default gen_random_uuid(),
  school_id uuid,
  record_data jsonb not null default '{}'::jsonb,
  created_at timestamp with time zone default now()
);

create table public.enrolment_history (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  enrolment_id uuid not null,
  event_type text not null,
  from_status text,
  to_status text,
  actor_user_id uuid,
  reason text,
  occurred_at timestamp with time zone not null default now(),
  metadata jsonb not null default '{}'::jsonb
);

create table public.exchange_rates (
  id uuid not null default gen_random_uuid(),
  base_currency character(3) not null,
  quote_currency character(3) not null,
  rate numeric(24,12) not null,
  rate_at timestamp with time zone not null,
  source text,
  approved_by uuid
);

create table public.expense_categories (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  code text not null,
  name text not null
);

create table public.expenses (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  category_id uuid,
  supplier_id uuid,
  expense_date date not null,
  amount_minor bigint not null,
  currency character(3) not null,
  description text not null,
  status text default 'draft'::text
);

create table public.fee_assignments (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  enrolment_id uuid not null,
  structure_id uuid not null,
  override_reason text,
  created_at timestamp with time zone default now()
);

create table public.fee_categories (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  code text not null,
  name text not null,
  type text default 'tuition'::text,
  status text default 'active'::text
);

create table public.fee_structure_items (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  structure_id uuid not null,
  category_id uuid not null,
  term_id uuid,
  amount_minor bigint not null
);

create table public.fee_structures (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  academic_year_id uuid not null,
  grade_level_id uuid,
  currency character(3) not null,
  name text not null,
  status text default 'draft'::text,
  created_at timestamp with time zone default now()
);

create table public.file_metadata (
  id uuid not null default gen_random_uuid(),
  school_id uuid,
  object_key text not null,
  original_filename text,
  mime_type text,
  byte_size bigint,
  classification text not null default 'P2'::text,
  scan_status text not null default 'pending'::text,
  storage_provider text not null default 'private_object_storage'::text,
  retention_until date,
  uploaded_by uuid,
  created_at timestamp with time zone not null default now()
);

create table public.financial_approvals (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  resource_type text not null,
  resource_id uuid not null,
  approver_id uuid not null,
  decision text not null,
  reason text,
  decided_at timestamp with time zone default now()
);

create table public.grade_levels (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  code text not null,
  name text not null,
  stage text,
  sort_order integer not null default 0,
  status text not null default 'active'::text,
  created_at timestamp with time zone not null default now()
);

create table public.grading_scale_items (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  scheme_version_id uuid not null,
  grade_code text not null,
  grade_label text not null,
  min_percent numeric(7,4) not null,
  max_percent numeric(7,4) not null,
  sort_order integer not null default 0
);

create table public.grading_scheme_versions (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  scheme_id uuid not null,
  version_number integer not null,
  effective_from date,
  effective_until date,
  rules_snapshot jsonb not null,
  approved_by uuid,
  approved_at timestamp with time zone,
  created_at timestamp with time zone not null default now()
);

create table public.grading_schemes (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  name text not null,
  scope jsonb not null default '{}'::jsonb,
  status text not null default 'draft'::text,
  created_at timestamp with time zone not null default now()
);

create table public.guardian_access_restrictions (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  student_id uuid not null,
  guardian_id uuid,
  link_id uuid,
  restriction_type text not null,
  scope jsonb not null default '{}'::jsonb,
  legal_basis_reference text,
  document_file_id uuid,
  verified_by uuid,
  starts_on date not null,
  ends_on date,
  review_due date,
  status text not null default 'active'::text,
  created_at timestamp with time zone not null default now()
);

create table public.guardian_student_links (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  guardian_id uuid not null,
  student_id uuid not null,
  relationship text not null,
  verification_status text not null default 'pending'::text,
  can_view_academic boolean not null default false,
  can_view_attendance boolean not null default false,
  can_view_finance boolean not null default false,
  can_receive_messages boolean not null default false,
  can_pick_up boolean not null default false,
  valid_from date not null default CURRENT_DATE,
  valid_until date,
  verified_by uuid,
  verified_at timestamp with time zone,
  created_at timestamp with time zone not null default now()
);

create table public.guardians (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  profile_id uuid,
  first_name text not null,
  last_name text not null,
  email text,
  phone text,
  preferred_contact_method text,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

create table public.health_visits (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  student_id uuid not null,
  visit_at timestamp with time zone default now(),
  reason text,
  notes text,
  follow_up_date date
);

create table public.invoice_adjustments (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  invoice_id uuid not null,
  amount_minor bigint not null,
  reason text not null,
  approved_by uuid,
  status text default 'draft'::text
);

create table public.invoice_items (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  invoice_id uuid not null,
  description text not null,
  qty numeric(12,4) default 1,
  unit_minor bigint not null,
  line_minor bigint not null,
  category_id uuid
);

create table public.invoices (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  enrolment_id uuid not null,
  invoice_number text not null,
  currency character(3) not null,
  issued_on date not null,
  due_on date,
  total_minor bigint not null default 0,
  status text not null default 'draft'::text,
  posted_at timestamp with time zone,
  created_at timestamp with time zone default now()
);

create table public.job_failures (
  id uuid not null default gen_random_uuid(),
  school_id uuid,
  record_data jsonb not null default '{}'::jsonb,
  created_at timestamp with time zone default now()
);

create table public.journal_entries (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  period_id uuid not null,
  entry_number text not null,
  source_type text,
  source_id uuid,
  description text,
  status text default 'draft'::text,
  posted_at timestamp with time zone,
  posted_by uuid
);

create table public.journal_lines (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  entry_id uuid not null,
  account_id uuid not null,
  debit_minor bigint not null default 0,
  credit_minor bigint not null default 0,
  currency character(3) not null,
  description text
);

create table public.library_book_copies (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  record_data jsonb not null default '{}'::jsonb,
  status text not null default 'active'::text,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

create table public.library_books (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  record_data jsonb not null default '{}'::jsonb,
  status text not null default 'active'::text,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

create table public.library_categories (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  record_data jsonb not null default '{}'::jsonb,
  status text not null default 'active'::text,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

create table public.library_fines (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  record_data jsonb not null default '{}'::jsonb,
  status text not null default 'active'::text,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

create table public.library_loans (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  record_data jsonb not null default '{}'::jsonb,
  status text not null default 'active'::text,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

create table public.library_reservations (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  record_data jsonb not null default '{}'::jsonb,
  status text not null default 'active'::text,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

create table public.mark_moderation (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  mark_id uuid not null,
  action text not null,
  previous_score numeric(12,4),
  new_score numeric(12,4),
  reason text not null,
  moderator_user_id uuid,
  created_at timestamp with time zone not null default now()
);

create table public.meal_attendance (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  record_data jsonb not null default '{}'::jsonb,
  status text not null default 'active'::text,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

create table public.meal_orders (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  record_data jsonb not null default '{}'::jsonb,
  status text not null default 'active'::text,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

create table public.meal_plans (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  record_data jsonb not null default '{}'::jsonb,
  status text not null default 'active'::text,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

create table public.medication_administration_events (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  medication_record_id uuid not null,
  student_id uuid not null,
  administered_at timestamp with time zone,
  administered_by uuid,
  dose_given text,
  notes text
);

create table public.medication_records (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  student_id uuid not null,
  medication_name text not null,
  dosage text,
  frequency text,
  start_date date,
  end_date date,
  status text default 'active'::text,
  authorization_file_id uuid
);

create table public.membership_roles (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  membership_id uuid not null,
  role_id uuid not null,
  campus_id uuid,
  granted_by uuid,
  valid_from timestamp with time zone not null default now(),
  valid_until timestamp with time zone,
  created_at timestamp with time zone not null default now()
);

create table public.message_attachments (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  message_id uuid not null,
  file_id uuid not null,
  created_at timestamp with time zone default now()
);

create table public.message_moderation_actions (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  message_id uuid not null,
  moderator_id uuid,
  action text not null,
  reason text,
  acted_at timestamp with time zone default now()
);

create table public.message_read_receipts (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  message_id uuid not null,
  user_id uuid not null,
  read_at timestamp with time zone default now()
);

create table public.message_recipients (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  message_id uuid not null,
  user_id uuid not null,
  delivered_at timestamp with time zone,
  status text default 'active'::text
);

create table public.message_threads (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  thread_type text default 'direct'::text,
  subject text,
  created_by uuid,
  status text default 'active'::text,
  created_at timestamp with time zone default now()
);

create table public.messages (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  thread_id uuid not null,
  sender_id uuid,
  body text,
  content_type text default 'text'::text,
  sent_at timestamp with time zone default now(),
  edited_at timestamp with time zone,
  moderation_status text default 'unreviewed'::text
);

create table public.notification_deliveries (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  notification_id uuid,
  recipient_user_id uuid,
  channel text not null,
  status text default 'queued'::text,
  provider_reference text,
  idempotency_key text not null,
  attempt_count integer default 0,
  last_attempt_at timestamp with time zone,
  created_at timestamp with time zone default now()
);

create table public.notification_preferences (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  user_id uuid not null,
  channel_preferences jsonb default '{}'::jsonb,
  updated_at timestamp with time zone default now()
);

create table public.notification_templates (
  id uuid not null default gen_random_uuid(),
  school_id uuid,
  template_key text not null,
  channel text not null,
  locale text default 'en'::text,
  body text not null,
  version integer default 1,
  status text default 'active'::text
);

create table public.payment_allocations (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  payment_id uuid not null,
  invoice_id uuid not null,
  amount_minor bigint not null,
  currency character(3) not null,
  allocated_at timestamp with time zone default now()
);

create table public.payment_methods (
  id uuid not null default gen_random_uuid(),
  school_id uuid,
  method_key text not null,
  name text not null,
  config jsonb default '{}'::jsonb,
  enabled boolean default true
);

create table public.payments (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  enrolment_id uuid,
  guardian_id uuid,
  amount_minor bigint not null,
  currency character(3) not null,
  method text,
  reference text,
  idempotency_key text not null,
  status text not null default 'pending'::text,
  received_at timestamp with time zone default now(),
  verified_by uuid,
  verified_at timestamp with time zone
);

create table public.permissions (
  id uuid not null default gen_random_uuid(),
  permission_key text not null,
  description text,
  created_at timestamp with time zone not null default now()
);

create table public.platform_access_grants (
  id uuid not null default gen_random_uuid(),
  school_id uuid,
  operator_user_id uuid not null,
  purpose text not null,
  scope jsonb not null,
  approved_by uuid,
  starts_at timestamp with time zone not null,
  ends_at timestamp with time zone not null,
  revoked_at timestamp with time zone,
  created_at timestamp with time zone not null default now()
);

create table public.platform_roles (
  id uuid not null default gen_random_uuid(),
  user_id uuid not null,
  role_key text not null,
  granted_by uuid,
  valid_from timestamp with time zone not null default now(),
  valid_until timestamp with time zone,
  created_at timestamp with time zone not null default now()
);

create table public.platform_settings (
  setting_key text not null,
  setting_value jsonb not null,
  value_version integer not null default 1,
  updated_at timestamp with time zone not null default now(),
  updated_by uuid
);

create table public.portal_access_logs (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  user_id uuid,
  event_type text not null,
  resource_type text,
  resource_id uuid,
  occurred_at timestamp with time zone default now(),
  metadata jsonb default '{}'::jsonb
);

create table public.portal_device_tokens (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  user_id uuid not null,
  token_hash text not null,
  device_label text,
  revoked_at timestamp with time zone,
  created_at timestamp with time zone default now()
);

create table public.portal_notifications (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  user_id uuid not null,
  notification_type text not null,
  title text not null,
  body text,
  related_type text,
  related_id uuid,
  read_at timestamp with time zone,
  created_at timestamp with time zone default now()
);

create table public.portal_preferences (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  user_id uuid not null,
  preferences jsonb default '{}'::jsonb,
  updated_at timestamp with time zone default now()
);

create table public.promotion_redemptions (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  promotion_id uuid not null,
  redeemed_by uuid,
  redeemed_at timestamp with time zone default now()
);

create table public.promotion_rules (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  academic_year_id uuid,
  from_grade_id uuid,
  to_grade_id uuid,
  version_no integer default 1,
  criteria jsonb not null,
  status text default 'draft'::text,
  approved_by uuid
);

create table public.promotions (
  id uuid not null default gen_random_uuid(),
  code text not null,
  terms jsonb not null,
  status text default 'active'::text,
  starts_at timestamp with time zone,
  ends_at timestamp with time zone
);

create table public.purchase_requests (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  requester_id uuid,
  supplier_id uuid,
  description text not null,
  amount_minor bigint not null,
  currency character(3) not null,
  status text default 'submitted'::text,
  created_at timestamp with time zone default now()
);

create table public.receipts (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  payment_id uuid not null,
  receipt_number text not null,
  issued_at timestamp with time zone default now(),
  status text default 'issued'::text
);

create table public.reconciliation_matches (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  statement_entry_id uuid not null,
  payment_id uuid,
  matched_amount_minor bigint not null,
  matched_by uuid,
  matched_at timestamp with time zone default now()
);

create table public.recovery_events (
  id uuid not null default gen_random_uuid(),
  school_id uuid,
  record_data jsonb not null default '{}'::jsonb,
  created_at timestamp with time zone default now()
);

create table public.refund_approvals (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  refund_id uuid not null,
  approver_id uuid not null,
  decision text not null,
  reason text,
  decided_at timestamp with time zone default now()
);

create table public.refunds (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  payment_id uuid not null,
  amount_minor bigint not null,
  reason text,
  status text default 'requested'::text,
  requested_by uuid,
  approved_by uuid,
  processed_at timestamp with time zone,
  created_at timestamp with time zone default now()
);

create table public.report_card_items (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  report_card_id uuid not null,
  subject_id uuid,
  item_snapshot jsonb not null,
  sort_order integer not null default 0,
  created_at timestamp with time zone not null default now()
);

create table public.report_card_templates (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  name text not null,
  template_version integer not null default 1,
  layout_config jsonb not null default '{}'::jsonb,
  status text not null default 'draft'::text,
  created_at timestamp with time zone not null default now()
);

create table public.report_cards (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  enrolment_id uuid not null,
  academic_year_id uuid not null,
  term_id uuid,
  template_id uuid,
  snapshot jsonb not null,
  status text not null default 'draft'::text,
  published_at timestamp with time zone,
  file_id uuid,
  created_at timestamp with time zone not null default now()
);

create table public.restricted_record_access_logs (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  record_type text not null,
  record_id uuid not null,
  actor_id uuid,
  purpose text not null,
  accessed_at timestamp with time zone default now()
);

create table public.retention_rules (
  id uuid not null default gen_random_uuid(),
  school_id uuid,
  record_data jsonb not null default '{}'::jsonb,
  created_at timestamp with time zone default now()
);

create table public.role_permissions (
  id uuid not null default gen_random_uuid(),
  role_id uuid not null,
  permission_id uuid not null,
  created_at timestamp with time zone not null default now()
);

create table public.roles (
  id uuid not null default gen_random_uuid(),
  school_id uuid,
  role_key text not null,
  display_name text not null,
  description text,
  is_system boolean not null default false,
  status text not null default 'active'::text,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

create table public.safeguarding_action_plans (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  incident_id uuid not null,
  plan jsonb not null,
  owner_id uuid,
  review_date date,
  status text default 'active'::text
);

create table public.safeguarding_incidents (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  student_id uuid,
  incident_reference text,
  incident_date date,
  category text,
  restricted_details text,
  reported_by uuid,
  status text default 'open'::text,
  classification text default 'restricted'::text
);

create table public.safeguarding_referrals (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  incident_id uuid not null,
  referral_type text,
  agency text,
  referral_date date,
  details text,
  status text default 'draft'::text
);

create table public.school_campuses (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  code text not null,
  name text not null,
  address jsonb not null default '{}'::jsonb,
  is_primary boolean not null default false,
  status text not null default 'active'::text,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

create table public.school_group_memberships (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  group_id uuid not null,
  joined_on date default CURRENT_DATE,
  left_on date,
  status text default 'active'::text
);

create table public.school_groups (
  id uuid not null default gen_random_uuid(),
  group_code text,
  name text not null,
  status text default 'active'::text,
  created_at timestamp with time zone default now()
);

create table public.school_memberships (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  user_id uuid not null,
  status text not null default 'invited'::text,
  invited_by uuid,
  joined_at timestamp with time zone,
  ended_at timestamp with time zone,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

create table public.school_rooms (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  campus_id uuid,
  room_code text not null,
  name text,
  capacity integer,
  room_type text,
  status text default 'active'::text
);

create table public.school_subscriptions (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  customer_id uuid not null,
  plan_id uuid not null,
  status text default 'trial'::text,
  starts_at timestamp with time zone,
  ends_at timestamp with time zone,
  contract_snapshot jsonb default '{}'::jsonb,
  created_at timestamp with time zone default now()
);

create table public.school_websites (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  site_name text not null,
  slug text not null,
  status text default 'draft'::text,
  created_at timestamp with time zone default now()
);

create table public.schools (
  id uuid not null default gen_random_uuid(),
  slug text not null,
  legal_name text not null,
  display_name text not null,
  country_code character(2) not null default 'ZW'::bpchar,
  default_currency character(3) not null default 'USD'::bpchar,
  timezone text not null default 'Africa/Harare'::text,
  status text not null default 'onboarding'::text,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

create table public.security_events (
  id uuid not null default gen_random_uuid(),
  school_id uuid,
  actor_user_id uuid,
  target_user_id uuid,
  event_type text not null,
  severity text not null,
  occurred_at timestamp with time zone not null default now(),
  safe_metadata jsonb not null default '{}'::jsonb
);

create table public.service_incidents (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  record_data jsonb not null default '{}'::jsonb,
  status text not null default 'active'::text,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

create table public.staff (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  staff_number text not null,
  profile_id uuid,
  first_name text not null,
  last_name text not null,
  email text,
  phone text,
  status text not null default 'active'::text,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

create table public.staff_department_memberships (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  staff_id uuid not null,
  department_id uuid not null,
  starts_on date not null,
  ends_on date,
  created_at timestamp with time zone not null default now()
);

create table public.staff_departments (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  code text not null,
  name text not null,
  head_staff_id uuid,
  status text not null default 'active'::text,
  created_at timestamp with time zone not null default now()
);

create table public.staff_documents (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  staff_id uuid not null,
  file_id uuid not null,
  document_type text not null,
  expiry_date date,
  verification_status text not null default 'pending'::text,
  created_at timestamp with time zone not null default now()
);

create table public.staff_employment (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  staff_id uuid not null,
  department_id uuid,
  job_title text not null,
  supervisor_staff_id uuid,
  start_date date not null,
  end_date date,
  employment_type text,
  restricted_notes text,
  created_at timestamp with time zone not null default now()
);

create table public.staff_qualifications (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  staff_id uuid not null,
  qualification text not null,
  institution text,
  awarded_on date,
  verification_status text not null default 'pending'::text,
  file_id uuid,
  created_at timestamp with time zone not null default now()
);

create table public.student_allergies (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  student_id uuid not null,
  allergen text not null,
  reaction text,
  severity text,
  emergency_action text,
  created_at timestamp with time zone default now()
);

create table public.student_class_assignments (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  enrolment_id uuid not null,
  class_id uuid not null,
  stream_id uuid,
  starts_on date not null,
  ends_on date,
  assignment_status text not null default 'active'::text,
  created_at timestamp with time zone not null default now()
);

create table public.student_emergency_contacts (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  student_id uuid not null,
  full_name text not null,
  relationship text,
  phone text not null,
  priority integer not null default 1,
  verified boolean not null default false,
  can_pick_up boolean not null default false,
  valid_from date not null default CURRENT_DATE,
  valid_until date,
  created_at timestamp with time zone not null default now()
);

create table public.student_enrolments (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  student_id uuid not null,
  academic_year_id uuid,
  programme_id uuid,
  status text not null default 'pending'::text,
  is_primary boolean not null default true,
  start_date date not null,
  end_date date,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

create table public.student_health_conditions (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  student_id uuid not null,
  condition_name text not null,
  details text,
  severity text,
  active boolean default true,
  created_at timestamp with time zone default now()
);

create table public.student_health_profiles (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  student_id uuid not null,
  health_summary text,
  updated_at timestamp with time zone default now()
);

create table public.student_marks (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  assessment_id uuid not null,
  component_id uuid,
  student_id uuid not null,
  score numeric(12,4),
  mark_status text not null default 'scored'::text,
  comment text,
  recorded_by uuid,
  recorded_at timestamp with time zone not null default now()
);

create table public.student_results (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  assessment_id uuid not null,
  student_id uuid not null,
  raw_score numeric(12,4),
  percentage numeric(7,4),
  grade_code text,
  calculation_version text not null,
  snapshot jsonb not null,
  status text not null default 'draft'::text,
  approved_by uuid,
  published_at timestamp with time zone,
  created_at timestamp with time zone not null default now()
);

create table public.student_transport_assignments (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  record_data jsonb not null default '{}'::jsonb,
  status text not null default 'active'::text,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

create table public.students (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  student_number text not null,
  legal_first_name text not null,
  legal_last_name text not null,
  preferred_name text,
  date_of_birth date,
  sex text,
  status text not null default 'applicant'::text,
  admission_date date,
  leaving_date date,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

create table public.subjects (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  code text not null,
  name text not null,
  stage text,
  status text not null default 'active'::text,
  created_at timestamp with time zone not null default now()
);

create table public.subscription_events (
  id uuid not null default gen_random_uuid(),
  school_id uuid,
  subscription_id uuid,
  event_type text not null,
  payload jsonb default '{}'::jsonb,
  occurred_at timestamp with time zone default now()
);

create table public.subscription_features (
  id uuid not null default gen_random_uuid(),
  plan_id uuid not null,
  feature_key text not null,
  feature_value jsonb not null
);

create table public.subscription_invoices (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  subscription_id uuid not null,
  invoice_number text not null,
  amount_minor bigint not null,
  currency character(3) not null,
  status text default 'draft'::text,
  due_on date,
  created_at timestamp with time zone default now()
);

create table public.subscription_items (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  subscription_id uuid not null,
  feature_key text,
  quantity integer default 1,
  price_snapshot jsonb default '{}'::jsonb
);

create table public.subscription_payments (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  invoice_id uuid not null,
  amount_minor bigint not null,
  currency character(3) not null,
  provider_reference text,
  idempotency_key text not null,
  status text default 'pending'::text,
  created_at timestamp with time zone default now()
);

create table public.subscription_plans (
  id uuid not null default gen_random_uuid(),
  plan_key text not null,
  name text not null,
  description text,
  pricing jsonb default '{}'::jsonb,
  status text default 'draft'::text
);

create table public.suppliers (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  supplier_code text,
  name text not null,
  contact_data jsonb default '{}'::jsonb
);

create table public.support_ticket_assignments (
  id uuid not null default gen_random_uuid(),
  school_id uuid,
  record_data jsonb not null default '{}'::jsonb,
  created_at timestamp with time zone default now()
);

create table public.support_ticket_history (
  id uuid not null default gen_random_uuid(),
  school_id uuid,
  record_data jsonb not null default '{}'::jsonb,
  created_at timestamp with time zone default now()
);

create table public.support_ticket_messages (
  id uuid not null default gen_random_uuid(),
  school_id uuid,
  record_data jsonb not null default '{}'::jsonb,
  created_at timestamp with time zone default now()
);

create table public.support_tickets (
  id uuid not null default gen_random_uuid(),
  school_id uuid,
  record_data jsonb not null default '{}'::jsonb,
  created_at timestamp with time zone default now()
);

create table public.system_jobs (
  id uuid not null default gen_random_uuid(),
  school_id uuid,
  record_data jsonb not null default '{}'::jsonb,
  created_at timestamp with time zone default now()
);

create table public.teacher_assignments (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  staff_id uuid not null,
  class_subject_id uuid not null,
  starts_on date not null,
  ends_on date,
  created_at timestamp with time zone not null default now()
);

create table public.timetable_entries (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  timetable_id uuid not null,
  class_id uuid not null,
  subject_id uuid not null,
  teacher_id uuid,
  room_id uuid,
  period_id uuid not null,
  weekday smallint not null
);

create table public.timetable_exceptions (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  entry_id uuid not null,
  exception_date date not null,
  exception_type text not null,
  reason text,
  approved_by uuid,
  created_at timestamp with time zone default now()
);

create table public.timetable_periods (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  calendar_id uuid,
  period_code text not null,
  name text,
  start_time time without time zone not null,
  end_time time without time zone not null,
  sort_order integer default 0
);

create table public.timetables (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  academic_year_id uuid not null,
  campus_id uuid,
  version_no integer default 1,
  status text default 'draft'::text,
  effective_from date,
  effective_until date,
  approved_by uuid,
  published_at timestamp with time zone
);

create table public.transport_incidents (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  record_data jsonb not null default '{}'::jsonb,
  status text not null default 'active'::text,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

create table public.transport_route_stops (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  record_data jsonb not null default '{}'::jsonb,
  status text not null default 'active'::text,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

create table public.transport_routes (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  record_data jsonb not null default '{}'::jsonb,
  status text not null default 'active'::text,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

create table public.transport_vehicles (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  record_data jsonb not null default '{}'::jsonb,
  status text not null default 'active'::text,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

create table public.trip_attendance (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  record_data jsonb not null default '{}'::jsonb,
  status text not null default 'active'::text,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

create table public.trip_permissions (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  record_data jsonb not null default '{}'::jsonb,
  status text not null default 'active'::text,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

create table public.trips (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  record_data jsonb not null default '{}'::jsonb,
  status text not null default 'active'::text,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

create table public.unallocated_credits (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  payment_id uuid not null,
  amount_minor bigint not null,
  currency character(3) not null,
  status text default 'available'::text
);

create table public.usage_records (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  feature_key text not null,
  quantity numeric(14,4) not null,
  period_start timestamp with time zone not null,
  period_end timestamp with time zone not null,
  idempotency_key text not null,
  recorded_at timestamp with time zone default now()
);

create table public.user_profiles (
  id uuid not null,
  display_name text,
  preferred_name text,
  locale text not null default 'en'::text,
  timezone text,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

create table public.webhook_events (
  id uuid not null default gen_random_uuid(),
  school_id uuid,
  record_data jsonb not null default '{}'::jsonb,
  created_at timestamp with time zone default now()
);

create table public.website_articles (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  website_id uuid not null,
  title text not null,
  slug text not null,
  summary text,
  content jsonb default '{}'::jsonb,
  status text default 'draft'::text,
  published_at timestamp with time zone
);

create table public.website_components (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  component_key text not null,
  component_schema jsonb not null,
  version integer default 1,
  status text default 'active'::text
);

create table public.website_domains (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  website_id uuid not null,
  domain_name text not null,
  verification_status text default 'pending'::text,
  verified_at timestamp with time zone
);

create table public.website_events (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  website_id uuid not null,
  title text not null,
  description text,
  start_at timestamp with time zone,
  end_at timestamp with time zone,
  timezone text,
  status text default 'draft'::text,
  visibility text default 'internal'::text
);

create table public.website_form_submissions (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  form_id uuid not null,
  submission_data jsonb not null,
  submitted_at timestamp with time zone default now(),
  review_status text default 'new'::text,
  ip_hash text
);

create table public.website_forms (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  website_id uuid not null,
  name text not null,
  form_schema jsonb not null,
  privacy_notice text,
  publication_status text default 'draft'::text
);

create table public.website_media (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  file_id uuid not null,
  alt_text text,
  rights_status text default 'unverified'::text,
  consent_metadata jsonb default '{}'::jsonb
);

create table public.website_navigation (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  website_id uuid not null,
  menu_key text not null,
  items jsonb default '[]'::jsonb,
  version integer default 1
);

create table public.website_page_versions (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  page_id uuid not null,
  version_no integer not null,
  content_snapshot jsonb not null,
  created_by uuid,
  created_at timestamp with time zone default now()
);

create table public.website_pages (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  website_id uuid not null,
  path text not null,
  title text not null,
  page_type text default 'page'::text,
  status text default 'draft'::text,
  created_at timestamp with time zone default now()
);

create table public.website_publications (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  website_id uuid not null,
  page_id uuid,
  version_id uuid,
  publication_status text not null,
  approved_by uuid,
  published_at timestamp with time zone,
  unpublished_at timestamp with time zone,
  public_snapshot jsonb
);

create table public.website_reusable_blocks (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  name text not null,
  content jsonb not null,
  version integer default 1,
  status text default 'draft'::text
);

create table public.website_sections (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  page_id uuid not null,
  section_type text not null,
  config jsonb default '{}'::jsonb,
  sort_order integer default 0
);

create table public.website_seo_settings (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  website_id uuid not null,
  resource_type text not null,
  resource_id uuid,
  meta_title text,
  meta_description text,
  canonical_url text,
  seo_config jsonb default '{}'::jsonb
);

create table public.website_starter_templates (
  id uuid not null default gen_random_uuid(),
  school_id uuid,
  template_key text not null,
  name text not null,
  config jsonb not null,
  version integer default 1,
  is_global boolean default false,
  status text default 'active'::text
);

create table public.website_themes (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  name text not null,
  theme_config jsonb default '{}'::jsonb,
  version integer default 1,
  status text default 'draft'::text
);

create table public.website_translations (
  id uuid not null default gen_random_uuid(),
  school_id uuid not null,
  website_id uuid not null,
  locale text not null,
  resource_type text not null,
  resource_id uuid,
  translation jsonb not null,
  status text default 'draft'::text
);
