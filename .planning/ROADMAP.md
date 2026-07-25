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

## Phase 5: Conversational Voice Interface
**Goal:** Enable older adults to interact with the app naturally without typing.
- [ ] Integrate Web Speech API / mobile voice recognition for speech-to-text.
- [ ] Connect audio transcriptions to Gemini to parse intents (logging meals, vitals, answering questions).
- [ ] Implement text-to-speech for conversational feedback.

## Phase 6: IoT Device Integration
**Goal:** Establish backend infrastructure to ingest data from smart health devices (glucometers, BP monitors, wearables).
- `[ ]` Design API contracts for ingesting device telemetry (FHIR/JSON).
- `[ ]` Implement secure webhook listeners for device payloads.
- `[ ]` Route anomalous readings through Gemini for real-time risk assessment.
