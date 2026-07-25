# CareTrack Integration & Verification Guide

This guide documents the backend infrastructure created across all 7 phases of the CareTrack AI integration, with a specific focus on Edge Functions, Webhooks, and how to verify their behavior.

## Overview of Webhooks & Edge Functions

Throughout the project, we migrated client-side logic to **Supabase Edge Functions** and **Database Webhooks** to enforce strict data privacy (`AGENTS.md`) and protect API keys.

| Component | Type | Authentication | Purpose |
| :--- | :--- | :--- | :--- |
| `chat-ai` | Edge Function | User JWT (Bearer) | Generates empathetic AI chat responses for patients. |
| `ocr-process` | Edge Function | User JWT (Bearer) | Parses uploaded prescription images using Gemini 1.5 Pro. |
| `generate-insights` | Edge Function | Service Role (Cron) | Runs nightly to analyze health logs and generate AI nudges. |
| `chat_monitor_webhook` | Database Webhook | Internal Supabase | Triggers automatically on `INSERT` to `chat_messages` to analyze chat for emergencies. |
| `ai-voice-assistant` | Edge Function | User JWT (Bearer) | Handles voice/text intent extraction for logging health data. |
| `iot-ingestion` | Edge Function | Server Secret (`X-Device-Token`) | Receives third-party IoT device telemetry (BP cuffs, wearables). |
| `robotics-dispatch` | Edge Function | User JWT (Bearer) | Translates natural language requests into robotics tasks. |
| `robotics-webhook` | Edge Function | Server Secret (`X-Robot-Token`) | Receives status updates from physical assistive robots. |

---

## How to Verify All Phases

You can verify the backend functionality using the terminal (`curl`) or the Supabase dashboard. **Before running the `curl` commands below, replace the placeholder variables:**
- `[PROJECT_REF]`: Your Supabase project reference (e.g. `svuruefzexxbyetpbixh`).
- `[USER_JWT]`: A valid authentication token for a test patient.
- `[PATIENT_ID]`: The UUID of the test patient.

### Phase 1: Secure Server-Side LLM Execution
**Verification (Chat AI):**
```bash
curl -i --location --request POST 'https://[PROJECT_REF].supabase.co/functions/v1/chat-ai' \
  --header 'Authorization: Bearer [USER_JWT]' \
  --header 'Content-Type: application/json' \
  --data-raw '{
    "message": "I am feeling a bit anxious about my blood sugar today."
  }'
```
*Expected Output*: A JSON response containing a generated, empathetic AI response.

### Phase 2: Multimodal Prescription OCR
**Verification (OCR):**
Upload a prescription image to the `prescriptions` storage bucket. Then invoke the function:
```bash
curl -i --location --request POST 'https://[PROJECT_REF].supabase.co/functions/v1/ocr-process' \
  --header 'Authorization: Bearer [USER_JWT]' \
  --header 'Content-Type: application/json' \
  --data-raw '{
    "file_path": "test-prescription.jpg"
  }'
```
*Expected Output*: A JSON response containing the extracted medication, dosage, and frequency.

### Phase 3: AI Nudges & Predictive Analytics
**Verification (Insights):**
This function is designed to be triggered by `pg_cron` at midnight. To test it manually:
```bash
curl -i --location --request POST 'https://[PROJECT_REF].supabase.co/functions/v1/generate-insights' \
  --header 'Authorization: Bearer [SUPABASE_SERVICE_ROLE_KEY]' \
  --header 'Content-Type: application/json' \
  --data-raw '{}'
```
*Expected Output*: New rows inserted into the `ai_insights` database table.

### Phase 4: AI Mediator in Care Team Chat
**Verification (Chat Monitor):**
Since this relies on a Supabase Database Webhook, you don't call an Edge Function directly. Instead, insert a dangerous message into the database.
```sql
INSERT INTO chat_messages (sender_id, receiver_id, message_text) 
VALUES ('[PATIENT_ID]', '[CAREGIVER_ID]', 'My chest is hurting really badly and I feel dizzy.');
```
*Expected Output*: A few seconds later, an automated AI response will appear in the `chat_messages` table urging the user to call 911, flagged as `is_ai_alert = true`.

### Phase 5: Conversational Voice Interface
**Verification (Voice Assistant):**
```bash
curl -i --location --request POST 'https://[PROJECT_REF].supabase.co/functions/v1/ai-voice-assistant' \
  --header 'Authorization: Bearer [USER_JWT]' \
  --header 'Content-Type: application/json' \
  --data-raw '{
    "text": "I just took my Metformin."
  }'
```
*Expected Output*: A JSON response confirming the intent. The backend will automatically insert a "Medicine" row into the `health_logs` table.

### Phase 6: IoT Device Integration
**Verification (IoT Webhook):**
This function requires a Server-to-Server secret rather than a user JWT.
```bash
curl -i --location --request POST 'https://[PROJECT_REF].supabase.co/functions/v1/iot-ingestion' \
  --header 'X-Device-Token: your_configured_secret' \
  --header 'Content-Type: application/json' \
  --data-raw '{
    "patient_id": "[PATIENT_ID]",
    "device_type": "Smart BP Cuff",
    "reading_type": "Blood Pressure",
    "value": "190/120"
  }'
```
*Expected Output*: `{"success": true, "logged": true, "alerted": true}`. A critical alert is generated in the `notifications` table due to the anomalous reading.

### Phase 7: Home Robotics API
**Verification (Dispatch & Status Webhook):**

1. **Patient Requests Help (Dispatch)**
```bash
curl -i --location --request POST 'https://[PROJECT_REF].supabase.co/functions/v1/robotics-dispatch' \
  --header 'Authorization: Bearer [USER_JWT]' \
  --header 'Content-Type: application/json' \
  --data-raw '{
    "command": "Can you bring me a glass of water?"
  }'
```
*Expected Output*: Creates a new `robot_tasks` row with status `pending` and `task_type: fetch_water`.

2. **Robot Updates Status (Webhook)**
```bash
curl -i --location --request POST 'https://[PROJECT_REF].supabase.co/functions/v1/robotics-webhook' \
  --header 'X-Robot-Token: your_configured_secret' \
  --header 'Content-Type: application/json' \
  --data-raw '{
    "task_id": "THE_ID_RETURNED_ABOVE",
    "status": "completed"
  }'
```
*Expected Output*: Updates the `robot_tasks` table to `completed`, instantly reflecting on the Caregiver's dashboard.
