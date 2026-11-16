# Security and privacy baseline

Enforce tenant isolation in server-side business logic and PostgreSQL RLS. Resolve school context from authenticated membership; do not trust client-supplied school IDs alone. Apply least-privilege roles. Restrict guardians to verified guardian-to-student links. Keep public CMS content separate from private records. Keep secrets out of source control and browser bundles. Use short-lived signed URLs for private files and validate uploads. Audit sensitive access, exports, role changes, financial actions and platform support access. Define retention, consent, data export/deletion and incident response. Test tenant isolation, guardian boundaries, public data leakage, webhook replay and backup restoration.

This is planning guidance, not a security certification or legal compliance opinion.
