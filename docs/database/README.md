# Database blueprint status

The approved v3.0 database design is conceptual. No SQL migrations, schema code, seed data or RLS policies are included in this scaffold.

Domains: platform tenancy and access; people; academics; attendance; assessments and report cards; admissions; school finance; websites/CMS; portals; communication; library; transport; documents; service desk; XEN subscriptions; audit and operations.

Use UUID identifiers, consistent timestamps, school-scoped records and same-tenant relationship constraints. Use integer minor units or exact numeric money values with explicit currency, never floating point. Preserve posted financial and approved academic history through auditable reversals/corrections. Private files require short-lived signed URLs.

Finance is phased: first fee structures, fee assignments, invoices, verified payments, allocations, receipts and balances; later discounts, bursaries, credits, refunds, bank reconciliation, double-entry accounting, expenses, suppliers, budgets and approvals. XEN SaaS billing is separate.

Next artefact: complete data dictionary and relationship specification before migrations are authored.
