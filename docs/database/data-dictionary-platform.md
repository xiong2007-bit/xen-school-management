# Data Dictionary — Platform, Tenancy, Identity and Access

**Version:** XEN School Management v3.0 · **Status:** Design specification only · **Database:** PostgreSQL

## Conventions
Unless stated otherwise, tables use `id uuid primary key default gen_random_uuid()` (UUIDv4 as the approved initial strategy), `created_at timestamptz not null default now()`, and `updated_at timestamptz not null default now()`. Tenant-owned tables include `school_id uuid not null references schools(id)`. Use `deleted_at` only for records whose lifecycle permits soft deletion; never soft-delete posted financial records to conceal activity. Enum-like values should be lookup tables or constrained text where tenant configurability is needed. All dates/times are timezone-aware where an instant is represented; date-only school events use `date`. Money is exact numeric or integer minor units, with currency explicitly stored. Sensitive fields are access-restricted and encrypted where appropriate.

## 1. Platform and school tenancy

### school_groups (future capability)
- `id uuid PK, name, group_code, status, created_at, updated_at`.
Optional organisation above multiple school tenants; planned for later phase and not required for initial pilot. Group membership never collapses school tenant boundaries.

### school_group_memberships (future capability)
- `id uuid PK, school_group_id FK school_groups, school_id FK schools, membership_status, valid_from, valid_to nullable, created_at`.
Unique active group/school; a school may belong to a group only under explicitly approved rules. Group-level permissions are scoped grants and never imply unrestricted cross-tenant access.

### schools
- `id uuid PK`: tenant identity.
- `legal_name text NOT NULL`: registered/legal name.
- `display_name text NOT NULL`: school-facing name.
- `slug text NOT NULL UNIQUE`: XEN subdomain identifier; normalized lowercase.
- `school_type text NOT NULL`: primary, secondary, combined, international/other via controlled values.
- `country_code char(2) NOT NULL DEFAULT 'ZW'`, `timezone text NOT NULL DEFAULT 'Africa/Harare'`, `default_currency char(3) NOT NULL DEFAULT 'USD'`, `locale text NOT NULL DEFAULT 'en`.
- `status text NOT NULL`: onboarding, trial, active, suspended, closed.
- `contact_email text`, `contact_phone text`, `postal_address text`, `physical_address text`.
- `settings jsonb NOT NULL DEFAULT '{}'`: non-sensitive tenant configuration only.
- `created_at`, `updated_at`, `activated_at timestamptz`.
Constraints: unique slug; valid ISO country/currency; status controlled; settings validated by application.

### school_campuses
- `id`, `school_id FK`, `name`, `code`, `campus_type`, `address`, `phone`, `email`, `timezone`, `is_primary boolean`, timestamps.
Unique `(school_id, code)`. Campus is optional scope; tenant remains school.

### user_profiles
- `id uuid PK references auth.users(id) on delete cascade`: one profile per auth user.
- `display_name text`, `given_name text`, `family_name text`, `preferred_name text`, `avatar_file_id uuid`, `locale text`, `timezone text`, `phone_e164 text`, `profile_status text`, timestamps.
Avoid storing duplicate authentication credentials. Profile fields are user-level, not school-specific.

### school_memberships
- `id`, `school_id FK`, `user_id FK user_profiles(id)`, `membership_status`: invited, active, suspended, ended.
- `staff_id uuid nullable FK staff(id)`, `invited_by uuid nullable FK user_profiles(id)`, `joined_at`, `ended_at`, `created_at`, `updated_at`.
Unique active membership per school/user (enforce with partial unique index); staff link optional and unique where present.

### roles
- `id`, `school_id uuid nullable`: null for platform-defined role; non-null for tenant-defined role.
- `key text NOT NULL`, `name text NOT NULL`, `description text`, `scope text NOT NULL` (platform/school/campus/class/subject), `is_system boolean`, `is_active boolean`, timestamps.
Unique key within scope (school-specific or global).

### permissions
- `id`, `key text UNIQUE NOT NULL`, `description text`, `module text`, `sensitivity text`, `created_at`.
Permission keys are platform-managed, stable identifiers.

### role_permissions
- `id`, `role_id FK`, `permission_id FK`, `created_at`.
Unique role/permission pair.

### membership_roles
- `id`, `school_membership_id FK`, `role_id FK`, `campus_id uuid nullable FK school_campuses`, `scope_type text`, `scope_id uuid nullable`, `granted_by uuid FK user_profiles`, `valid_from timestamptz`, `valid_until timestamptz nullable`, `created_at`.
Scope assignment grants a role only within allowed scope; prevent scope IDs crossing tenants.

### platform_roles
- `id`, `user_id FK user_profiles`, `role_id FK roles`, `granted_by uuid`, `valid_from`, `valid_until`, `created_at`.
Only platform operators may administer; all grants/revocations audited.

## 2. People and relationships

### students
- `id`, `school_id FK`, `student_number text NOT NULL`, `given_name`, `middle_name`, `family_name`, `preferred_name`, `date_of_birth date`, `sex text nullable`, `nationality_code char(2) nullable`, `photo_file_id uuid nullable`, `status text NOT NULL` (applicant, enrolled, withdrawn, graduated, archived), `admission_date date`, `leaving_date date`, `created_at`, `updated_at`.
Unique student number per school. Avoid unnecessary national ID collection; sensitive identity data, if legally required, belongs in separately protected records.

### guardians
- `id`, `school_id FK`, `user_id uuid nullable FK user_profiles`, `guardian_number text nullable`, `given_name`, `family_name`, `preferred_name`, `email`, `phone_e164`, `address`, `preferred_language`, `contact_preferences jsonb`, timestamps.
A guardian may have an account later or not; contact details are school-scoped.

### guardian_student_links
- `id`, `school_id FK`, `guardian_id FK`, `student_id FK`, `relationship_type text`, `is_primary_contact boolean`, `is_emergency_contact boolean`, `can_pick_up boolean`, `can_view_academic boolean`, `can_view_attendance boolean`, `can_view_finance boolean`, `legal_authority_status text`, `verified_at`, `verified_by uuid`, `valid_from date`, `valid_to date nullable`, `created_at`, `updated_at`.
Unique active guardian/student relationship as appropriate; every portal access must check active and verified relationship and permissions.

### student_emergency_contacts
- `id, school_id FK, student_id FK, contact_name, relationship nullable, phone, email nullable, address nullable, contact_priority, is_authorised_pickup boolean, contact_scope text, valid_from date, valid_to date nullable, verification_status, verified_by uuid nullable, verified_at nullable, created_at, updated_at`.
Emergency contacts may be separate from guardians. Contact/pick-up authority is not portal access or legal guardianship; verify and restrict by school policy.

### guardian_access_restrictions
- `id, school_id FK, student_id FK, guardian_student_link_id nullable FK, restricted_person_reference nullable, restriction_type, scope jsonb, effective_from date, effective_to date nullable, status, source_type, verified_by uuid, verified_at, legal_document_file_id uuid nullable FK files, review_due date nullable, created_by uuid, timestamps`.
Restricted legal/custody/access-order metadata. Store only the minimum necessary details; document content is highly restricted. Enforce restrictions in authorization services and RLS policies, with expiry/review and audited changes. Do not treat a guardian link or consent flag as overriding a current legal restriction.

### student_enrolments
- `id, school_id FK, student_id FK, academic_year_id FK, calendar_id nullable FK academic_calendars, grade_level_id FK, programme_id nullable, class_id FK nullable, stream_id FK nullable, enrolment_type, concurrent_group_id nullable, is_primary boolean, enrolment_status text, enrolment_date date, exit_date date nullable, exit_reason text nullable, previous_school text nullable, created_by uuid, timestamps.
Support controlled concurrent enrolments only where school rules/programme combinations permit. Require a defined primary enrolment per applicable scope and preserve programme/class transfer history. Validate allowed combinations and prevent unintended overlap; do not apply a blanket one-enrolment-per-year restriction.

### staff
- `id`, `school_id FK`, `staff_number text NOT NULL`, `user_id uuid nullable FK user_profiles`, `given_name`, `middle_name`, `family_name`, `preferred_name`, `email`, `phone_e164`, `date_of_birth date nullable`, `employment_status text`, `photo_file_id uuid nullable`, timestamps.
Unique staff number per school. Sensitive HR attributes restricted.

### staff_employment
- `id`, `school_id FK`, `staff_id FK`, `employment_type text`, `job_title`, `department_id uuid nullable FK staff_departments`, `start_date`, `end_date nullable`, `contract_status`, `work_location`, `supervisor_staff_id uuid nullable FK staff`, `created_at`, `updated_at`.
History of employment/position changes; avoid overwriting historical contracts.

### staff_qualifications
- `id`, `school_id FK`, `staff_id FK`, `qualification_name`, `institution`, `award_date date nullable`, `verification_status`, `document_file_id uuid nullable`, timestamps.

### staff_documents
- `id`, `school_id FK`, `staff_id FK`, `document_type`, `file_id FK files`, `issue_date date nullable`, `expiry_date date nullable`, `verification_status`, `verified_by uuid nullable`, timestamps.

### staff_departments
- `id`, `school_id FK`, `name`, `code`, `head_staff_id uuid nullable FK staff`, `is_active`, timestamps. Unique school/code.

### staff_department_memberships
- `id`, `school_id FK`, `staff_id FK`, `department_id FK`, `start_date`, `end_date nullable`, `created_at`. Unique active staff/department assignment.

### teacher_assignments
- `id`, `school_id FK`, `staff_id FK`, `class_id FK`, `subject_id FK nullable`, `academic_year_id FK`, `assignment_role text`, `start_date`, `end_date nullable`, timestamps.
Assignment scope is explicit; enforce that referenced class/subject/year belong to the same school.
