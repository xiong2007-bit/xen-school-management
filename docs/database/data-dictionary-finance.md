# Data Dictionary — School Finance and XEN Billing

## Currency and conversion primitives (cross-cutting)

### currency_definitions
`currency_code char(3) PK, display_name, minor_unit_exponent, is_active, effective_from, effective_to nullable, source_or_policy_reference nullable, created_at, updated_at`. Currency precision is configurable from an authoritative currency registry/policy; do not assume all currencies have two decimal places.

### exchange_rates
`id uuid PK, source_currency char(3) FK currency_definitions, target_currency char(3) FK currency_definitions, rate numeric, rate_source, rate_as_of timestamptz, effective_from, effective_to nullable, approval_status, approved_by uuid nullable, created_at`. Rate must be positive; source and target currencies differ; rate source/time and approval policy are recorded.

### currency_conversion_snapshots
`id uuid PK, school_id FK, source_amount_minor bigint, source_currency char(3), target_amount_minor bigint, target_currency char(3), exchange_rate numeric, exchange_rate_id nullable FK exchange_rates, rate_source, rate_as_of timestamptz, rounding_method, conversion_reason, converted_by uuid, created_at`. Immutable evidence for each conversion; store the actual rate and both amounts so historical values do not depend on later rate changes. Cross-currency allocation or reconciliation requires an explicit conversion snapshot and policy.

This design distinguishes each school's operational finance from XEN's own SaaS subscription billing. Finance tables use explicit currency and integer minor units for amounts (e.g., cents). Each posted transaction is immutable; corrections use reversals, credits or adjustments. Provider callbacks are idempotent. Payment is not considered verified solely because a screenshot/proof file was uploaded.

## 7. Core school fees (first finance phase)

### fee_categories
`id, school_id, code, name, description nullable, category_type, is_active, timestamps`. Unique code per school. Category types include tuition, levy, transport, boarding, meals, activity and other.

### fee_structures
`id, school_id, academic_year_id FK, grade_level_id nullable FK, name, currency char(3), effective_from date, effective_to nullable, status, created_by uuid, timestamps`. Structures may be targeted by grade, campus or student segment; do not create overlapping active rules without an explicit priority.

### fee_structure_items
`id, school_id, fee_structure_id FK, fee_category_id FK, description, amount_minor bigint, frequency, due_date nullable, term_id nullable FK, quantity numeric default 1, is_optional boolean, timestamps`. Nonnegative amount; quantity precision rules documented; currency inherited from structure.

### fee_assignments
`id, school_id, student_enrolment_id FK, fee_structure_id FK, assigned_at, assigned_by uuid, status, override_reason nullable, timestamps`. Supports fee structure assigned to a specific enrolment; overrides require reason and audit.

### invoices
`id, school_id, student_enrolment_id FK, invoice_number, currency char(3), issue_date date, due_date date nullable, invoice_status, subtotal_minor bigint, discount_minor bigint default 0, tax_minor bigint default 0, total_minor bigint, balance_minor bigint, description nullable, created_by uuid, posted_at nullable, voided_at nullable, void_reason nullable, timestamps`. Unique invoice number per school; balance computed/maintained consistently; only draft may be edited; posted invoices are corrected by credit/debit note or void process. Currency cannot be mixed on one invoice.

### invoice_items
`id, school_id, invoice_id FK, fee_category_id nullable FK, fee_structure_item_id nullable FK, description, quantity numeric, unit_amount_minor bigint, line_total_minor bigint, tax_rate numeric nullable, service_period_start date nullable, service_period_end date nullable, created_at`. Item snapshot preserves charge description and amount even if source fee config changes.

### payment_methods
`id, school_id uuid nullable (null means platform-defined), code, name, method_type, provider_key nullable, is_active, requires_verification, instructions nullable, timestamps`. Platform provider methods may be configured per tenant; secret credentials belong in protected secret store, not table.

### payments
`id, school_id FK, payment_reference, payer_guardian_id nullable FK guardians, student_enrolment_id nullable FK, payment_method_id FK, currency char(3), amount_minor bigint, received_at timestamptz, payment_status (pending/received/verified/failed/reversed/refunded), external_reference nullable, provider_transaction_id nullable, verified_by uuid nullable, verified_at nullable, received_by uuid nullable, idempotency_key text nullable, notes restricted nullable, timestamps`. Unique school/payment reference; unique provider transaction per provider where appropriate; nonnegative amount. State changes audited.

### payment_allocations
`id, school_id FK, payment_id FK, invoice_id FK, amount_minor bigint, allocated_at, allocated_by uuid, allocation_status, reversal_of_allocation_id nullable FK, created_at`. Allocation must not exceed verified unallocated payment or invoice outstanding; same currency; use reversals for corrections.

### receipts
`id, school_id FK, payment_id FK, receipt_number, issued_at, issued_by uuid, receipt_status, file_id nullable FK files, voided_at nullable, void_reason nullable, created_at`. Unique receipt number; receipt only for verified/settled payment; preserve void history.

## 8. Advanced finance (later phases)

### fee_discounts
`id, school_id FK, student_enrolment_id FK, fee_category_id nullable FK, discount_type, amount_minor nullable, percent numeric nullable, currency nullable, reason, approval_status, approved_by uuid nullable, valid_from, valid_to nullable, timestamps`. Validate only one intended discount basis and cap at applicable fee.

### student_bursaries
`id, school_id FK, student_enrolment_id FK, bursary_name, amount_minor nullable, percent nullable, currency nullable, funding_source nullable, confidentiality_level, start_date, end_date nullable, approval_status, approved_by uuid nullable, timestamps`. Restricted access and approvals.

### invoice_adjustments
`id, school_id FK, invoice_id FK, adjustment_type, amount_minor, reason, approval_status, approved_by uuid nullable, posted_at nullable, created_by uuid, timestamps`. Posted adjustments auditable; link to credit/debit documents where required.

### credit_notes
`id, school_id FK, invoice_id FK, credit_note_number, amount_minor, currency, reason, status, issued_at nullable, issued_by uuid, timestamps`. Credit note total cannot exceed invoice eligible amount; invoice balance recalculated through ledger.

### refunds
`id, school_id FK, payment_id FK, refund_reference, amount_minor, currency, refund_method, refund_status, requested_by uuid, approved_by uuid nullable, processed_at nullable, provider_reference nullable, reason, timestamps`. Refund cannot exceed eligible payment net of previous refunds; require approval workflow.

### refund_approvals
`id, school_id FK, refund_id FK, approver_user_id uuid, decision, notes, decided_at, created_at`. Append-only approvals.

### unallocated_credits
`id, school_id FK, payment_id FK, student_enrolment_id FK, amount_minor, currency, status, created_at, applied_at nullable`. Represent unapplied funds; reconcile to payment ledger.

### bank_accounts
`id, school_id FK, account_name, bank_name, account_currency, masked_account_number, account_identifier_encrypted nullable, is_active, created_at, updated_at`. Restrict account details; never expose raw account identifier to general roles.

### bank_statement_imports
`id, school_id FK, bank_account_id FK, file_id FK, import_status, imported_by uuid, imported_at, row_count, errors jsonb, created_at`.

### bank_statement_entries
`id, school_id FK, import_id FK, bank_account_id FK, transaction_date, value_date nullable, description, amount_minor, currency, bank_reference nullable, entry_hash, match_status, created_at`. Unique import/hash for deduplication.

### reconciliation_matches
`id, school_id FK, statement_entry_id FK, payment_id nullable FK, journal_line_id nullable FK, match_type, matched_amount_minor, matched_by uuid, matched_at, status, created_at`. Support split/combined matching through a reconciliation group if needed; no cross-currency matches without documented conversion.

### chart_of_accounts
`id, school_id FK, account_code, account_name, account_type, parent_account_id nullable FK, currency nullable, is_control_account, is_active, timestamps`. Unique account code; tree must remain within tenant and avoid cycles.

### accounting_periods
`id, school_id FK, name, start_date, end_date, status, closed_by uuid nullable, closed_at nullable, timestamps`. No overlapping periods; closed periods restrict posting.

### journal_entries
`id, school_id FK, journal_number, accounting_period_id FK, entry_date, source_type, source_id nullable, description, status, created_by uuid, posted_by uuid nullable, posted_at nullable, reversal_of_entry_id nullable FK, timestamps`. Posted entries immutable; reversal required; unique number.

### journal_lines
`id, school_id FK, journal_entry_id FK, account_id FK, debit_minor bigint, credit_minor bigint, currency char(3), description nullable, student_enrolment_id nullable FK, created_at`. Exactly one of debit/credit positive per line; journal totals balance by currency; control-account rules enforced.

### expenses
`id, school_id FK, expense_reference, expense_category_id FK, supplier_id nullable FK, accounting_period_id nullable FK, amount_minor, currency, expense_date, description, status, submitted_by uuid, approved_by uuid nullable, paid_at nullable, payment_reference nullable, receipt_file_id nullable FK files, timestamps`. Workflow states draft/submitted/approved/rejected/paid/void; approvals separated where required.

### expense_categories
`id, school_id FK, code, name, account_id nullable FK chart_of_accounts, is_active, timestamps`. Unique code.

### suppliers
`id, school_id FK, supplier_code, name, contact_name nullable, email nullable, phone nullable, address nullable, tax_identifier nullable restricted, status, timestamps`. Unique code; sensitive tax data restricted.

### purchase_requests
`id, school_id FK, request_number, requester_staff_id nullable FK staff, supplier_id nullable FK, description, amount_minor, currency, needed_by date nullable, request_status, submitted_at nullable, approved_by uuid nullable, approved_at nullable, timestamps`.

### budgets
`id, school_id FK, accounting_period_id FK, name, status, created_by uuid, approved_by uuid nullable, timestamps`.

### budget_items
`id, school_id FK, budget_id FK, account_id FK, amount_minor, currency, notes nullable, timestamps`. Unique budget/account/currency.

### financial_approvals
`id, school_id FK, subject_type, subject_id uuid, approval_step, approver_user_id uuid, decision, comments nullable, decided_at, created_at`. Subject types validated; immutable approvals; separation of duties policy.

## Finance invariants
1. Money is exact and currency-tagged; amounts are never floating point.
2. A payment is allocated only when verified; allocations cannot exceed available funds or invoice balance.
3. Invoice item descriptions/prices are snapshots.
4. Receipts are issued for verified payments and never silently altered.
5. Refunds and credits have approval, history and amount caps.
6. Posted journals balance (debits = credits) per currency and cannot be edited; corrections reverse and re-post.
7. Payment provider callbacks use idempotency and signature validation; log safe provider references.
8. School fee ledger and XEN SaaS billing are separate domains.
