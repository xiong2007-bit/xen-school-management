# XEN SCHOOL MANAGEMENT Supabase

## Current live project
- Project name: xen-school
- Project ref: pdidtgcrubfcacdlvpmx
- Region: eu-west-1
- URL: https://pdidtgcrubfcacdlvpmx.supabase.co
- 12 migrations applied in live history; schema is currently a scaffold.

## Schema snapshot
The `schema-snapshot/` directory contains catalog-reconstructed SQL files captured from the live database. **These are not executable Supabase migrations and must not be run against the live project.** They were placed outside `migrations/` to avoid accidentally being picked up by `supabase db push`.

Snapshot limitations: reconstructed columns/defaults, constraints, indexes, RLS policies, helper function and seed references; not necessarily the exact original authored SQL. A clean replay has not been tested. Review, fix dependencies, and run against a disposable empty Postgres/Supabase instance before using as a baseline.

## Live database state (last verified)
- 209 public tables
- 209 tables with RLS enabled
- 171 policies
- 163 tenant-select policies
- 18 global role templates, 45 permissions, 123 role-permission mappings
- 11 currency reference rows
- no school or student records loaded

## API
Cloudflare Worker `xen-school` is deployed with `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` secret bindings. Starter routes: `GET /health`, `GET /api/v1/me` (Supabase Auth JWT verification), and `GET /api/v1/schools` (read-only request using caller JWT and database RLS). Only GET/OPTIONS are accepted; writes are not implemented. No service-role key is used or exposed. Deployment was confirmed via Cloudflare API; live HTTP smoke test remains pending.

## Important
The database is not production-ready. Write policies and workflow validation remain closed/unimplemented. Some optional modules are flexible `record_data` JSONB placeholders. Restricted health/safeguarding tables have no client access policies. Security, migration replay, tests, app UI and pilot signoff remain pending.
