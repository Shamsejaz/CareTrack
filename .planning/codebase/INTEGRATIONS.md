# External Integrations

**Analysis Date:** 2026-06-25

## APIs & External Services

**Artificial Intelligence & Vision:**
- Google Gemini API - Used for analyzing meal photos to support diabetes tracking (calories, carbs, advice, health status).
  - SDK/Client: `google_generative_ai` Dart package v0.4.6
  - Auth: API key via `GEMINI_API_KEY` environment variable (retrieved through `String.fromEnvironment`)
  - Model: `gemini-1.5-flash`

## Data Storage

**Databases:**
- PostgreSQL on Supabase - Primary cloud database hosted on Supabase (local development virtualized via Supabase CLI).
  - Client: `supabase_flutter` for mobile, `@supabase/supabase-js` for web.
  - Connection: Handled via native Supabase RPC and REST APIs over HTTPS.
  - Migrations: Managed locally under `supabase/migrations/` and deployed using the Supabase CLI.

**File Storage:**
- Supabase Storage - Used to store uploaded meal photos, user avatar photos, and prescription scans.
  - Client: Supabase client SDKs (`storage.from(...)`).
  - Buckets: `health_logs` storage references (paths saved in the `photo_url` column of the `health_logs` table).

## Authentication & Identity

**Auth Provider:**
- Supabase Auth - Provides sign-up, login, logout, and session state persistence.
  - Implementation: Integrated in `mobile_app/lib/core/providers/auth_provider.dart` via Riverpod notifier, and in `web_app/src/lib/supabase.ts` for web clients.
  - Token storage: Managed automatically by the Supabase Client SDK (Keychain/Shared Preferences on mobile, localStorage/cookies on web).
  - Session management: Handles active sessions, role selection, and user metadata checks.
  - Demo Mode: Implemented on mobile via `isDemoProvider` to mock user profiles when offline or demonstrating application screens.

## CI/CD & Deployment

**Local Environment:**
- Supabase Local CLI: Configured via `supabase/config.toml` for dockerized local PostgreSQL, auth, storage, and database seeding.

## Environment Configuration

**Development:**
- Required env vars/defines: `GEMINI_API_KEY` for AI services.
- Web Config: `.env` file containing `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` (mirrored in `.env.example`).
- Mobile Config: Hardcoded SVU-prefixed Supabase endpoint URL and anonymous key inside `mobile_app/lib/main.dart` for fallback bootstrap connection.

**Production:**
- Secrets management: Configured in the cloud host dashboards (e.g. Supabase panel, static host configurations).

## Webhooks & Callbacks

**Incoming:**
- None registered in active codebase (no payment or stripe hooks).

**Outgoing:**
- None registered.

---

*Integration audit: 2026-06-25*
*Update when adding/removing external services*
