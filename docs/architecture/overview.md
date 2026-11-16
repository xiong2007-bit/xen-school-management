# Architecture overview

Approved direction: React + TypeScript; Cloudflare Workers for API/business logic; Supabase PostgreSQL and Supabase Auth; PostgreSQL Row Level Security; Cloudflare R2; Vercel frontend hosting; Cloudflare DNS, routing and edge security. pnpm workspaces and Turbo are planned monorepo tooling.

The browser is untrusted. Resolve tenant context and enforce membership, role and permission checks server-side. RLS is a second enforcement layer, not a substitute for API authorisation. Never expose privileged database credentials to browser code.

Public website delivery must read only approved published content. Learner, guardian, attendance, assessment, medical and financial records remain private. Plan audit events, rate limits, validation, secure file access, monitoring, backups, restore tests and rollback before production.
