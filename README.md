# XEN SCHOOL MANAGEMENT v3.0

XEN SCHOOL MANAGEMENT is a multi-tenant school-management SaaS for Zimbabwe-first rollout and international expansion.

## Current implementation (v1 foundation)

**Frontend foundation committed:** React + TypeScript + Vite workspace under `apps/web` (read-only dashboard; deployment currently blocked by Vercel provisioning).
- Supabase email/password authentication (sign in and account creation).
- Authenticated school workspace selector/profile.
- School overview metrics.
- Learner directory with search.
- Class directory.
- Recent attendance records.
- School profile view.
- Mobile-responsive administration interface.
- Supabase reads use the authenticated user's session and existing database RLS.
- No service-role key is included in browser code.

**Backend scaffold:** Cloudflare Worker `xen-school` provides `GET /health`, `GET /api/v1/me`, and authenticated `GET /api/v1/schools`. Write APIs and secure onboarding are not yet enabled.

**Live database baseline:** Supabase project `xen-school` has 209 public tables with RLS enabled. The current database has no school/student demo records. The schema snapshot in `supabase/schema-snapshot/` is reconstructed and for review only—not executable migrations.

## Local development

1. Install Node.js 22+.
2. Open a terminal in `apps/web`.
3. Run `npm install`.
4. Copy `.env.example` to `.env`.
5. Set:
   - `VITE_SUPABASE_URL` to the Supabase project URL.
   - `VITE_SUPABASE_PUBLISHABLE_KEY` to the publishable key.
   - `VITE_XEN_API_URL` to the Cloudflare Worker URL.
6. Run `npm run dev`.
7. For a production build, run `npm run build`.

Only Supabase publishable keys may be placed in browser environment variables. Never add service-role keys or database passwords.

## v1 scope in progress

1. Secure school onboarding and membership owner bootstrap (pending policy review).
2. Academic-year and grade/class setup.
3. Learner registration and enrolment.
4. Daily attendance session and marking.
5. Staff records and role assignment.
6. Parent/guardian linking and portal access.
7. Finance, assessments and communication follow in later phases.

## Deployment

Vercel configuration is provided in `apps/web/vercel.json`. Set the three Vite environment variables in the Vercel project before deploying. A deployment build and browser smoke tests are pending; this repository change is not a claim that every workflow is production-ready.

See [database live implementation status](docs/database/live-project-bootstrap-status.md) and [Supabase snapshot notes](supabase/README.md).
