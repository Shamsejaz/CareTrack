# Requirements

## User Stories
- As a user, I want the app to be fully functional without mock data so that my health logs actually save securely to my profile.
- As a user, I want to use real authentication so that my privacy is protected.
- As a caregiver, I want to securely link my account to a patient's account so that I can view their real-time dashboard.
- As a user, I want the app to sync with my Apple Health or Google Health Connect so I don't have to manually enter my steps and vitals.
- As a patient with limited mobility, I want to press a button in my app to dispatch physical tasks to my home robot via an API webhook.

## Acceptance Criteria
- ALL `Future.delayed` instances used for UI simulation are replaced with live `http` calls to Supabase Edge Functions.
- `isDemoProvider` is retained for quick UI testing, but all real backend routes and providers correctly query Supabase when Demo Mode is false.
- `vitals_dashboard_screen.dart` plots actual data rows from the `health_logs` table (unless in demo mode).
- Care Team UI allows entering a Caregiver email, which inserts a relationship into a `care_team_links` Supabase table (secured with RLS).
- App successfully requests HealthKit/HealthConnect permissions and reads pedometer data.
- A Supabase Edge Function is deployed that successfully forwards JSON payloads to an external robotics webhook URL.

## Definition of Done
- No mock data or artificial delays exist anywhere in the frontend codebase.
- App continues to compile successfully (no lint or type errors).
- All new Edge Functions are deployed and integrated.
- Strict Row Level Security (RLS) is applied to all new tables (e.g., `care_team_links`).
