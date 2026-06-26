# Requirements

## User Stories
- As a system admin, I want the Gemini API key secured in the backend so it isn't exposed in client apps.
- As a patient, I want to upload prescription photos so my medication schedule is parsed automatically.
- As a caregiver, I want daily automated summaries of my linked patients' health trends.
- As a caregiver, I want to be immediately notified if a patient mentions critical symptoms in the chat.

## Acceptance Criteria
- Supabase Edge Functions are deployed and successfully proxy requests to the Google Gemini API using a securely stored Vault secret.
- Prescription OCR returns structured JSON containing medications, doses, timings, and validates against potential drug interactions.
- A pg_cron database job queries `health_logs` and generates personalized insights successfully.
- The chat monitor correctly identifies symptom severity in real-time and triggers push notifications to the respective caregiver.

## Definition of Done
- All backend Edge Functions are written, deployed, and tested.
- Frontend components are integrated with the new Edge Functions instead of simulating them.
- All code passes type checking and linting.
- No secrets are hardcoded in the codebase.
