# Roadmap

## Phase 1: Secure Server-Side LLM Execution
**Goal:** Migrate client-side Gemini calls to secure Supabase Edge Functions.
- [ ] Configure Supabase Vault with `GEMINI_API_KEY`.
- [ ] Create Deno Edge Function `analyze-log` using the `npm:@google/genai` SDK.
- [ ] Update mobile app to route analysis requests through the Edge Function instead of direct API calls.

## Phase 2: Multimodal Prescription OCR
**Goal:** Implement robust prescription parsing using `gemini-1.5-pro`.
- [ ] Update `process-prescription` Edge Function to accept image/PDF bytes.
- [ ] Configure Gemini structured output schema for medications (name, dose, timing, frequency).
- [ ] Implement drug interaction validation logic (mock or RxList API).

## Phase 3: AI Nudges & Predictive Analytics
**Goal:** Generate personalized patient nudges.
- [ ] Create pg_cron job in Supabase to run daily over `health_logs`.
- [ ] Implement Edge Function to fetch last 7 days of logs and synthesize a health nudge.
- [ ] Update Caregiver and Patient dashboard to display the dynamic AI insight instead of the hardcoded widget.

## Phase 4: AI Mediator in Care Team Chat
**Goal:** Background monitoring of care team chat for critical symptoms.
- [ ] Implement database trigger on `chat_messages` table for new inserts.
- [ ] Create Edge Function to evaluate message text for severe symptoms using Gemini.
- [ ] Implement push notification dispatch and auto-reply alerting the patient.
