# XEN SCHOOL MANAGEMENT Web — v1 foundation

React + TypeScript + Vite interface connected to Supabase Auth and tenant-filtered read-only school data.

## Features
- Email/password sign-in and account creation.
- Responsive sidebar workspace navigation.
- Overview cards, learner directory/search, classes, attendance read view, and school profile.
- Supabase browser client uses publishable key and signed-in session; RLS is the authorization boundary.
- No data creation/edit/delete controls yet. Secure onboarding and write APIs are pending.

## Setup
```sh
npm install
cp .env.example .env
npm run dev
```
Fill the three environment variables in `.env`. Never place a service-role or secret key in Vite variables.

## Production build
```sh
npm run build
```

Deployment via Vercel is configured, but current deployment attempts are failing before build with platform error `Resource provisioning failed`. No build logs were available. Retry deployment after platform provisioning recovers.
