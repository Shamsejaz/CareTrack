# Milestone v1.0 — Project Summary

**Generated:** 2026-07-25
**Purpose:** Team onboarding and project review

---

## 1. Project Overview

Integrating Google Gemini LLMs across the CareTrack ecosystem to provide live multimodal OCR, automated caregiver insights, and intelligent care team chat mediation, while moving API execution to secure Supabase Edge Functions.

Enables production-ready AI healthcare companion features, reducing manual data entry for prescriptions, proactively alerting caregivers to health trends, and ensuring patient safety via chat monitoring.

All phases for this milestone are complete.

## 2. Architecture & Technical Decisions

- **Decision:** Move Gemini API to Edge Functions
  - **Why:** Protect API keys and IP from client-side extraction, satisfying strict AGENTS.md compliance.
  - **Phase:** 1
- **Decision:** Use gemini-1.5-pro for OCR
  - **Why:** Better structured JSON output for clinical text.
  - **Phase:** 2
- **Decision:** Daily cron job for insights (pg_cron)
  - **Why:** Prevent overloading the LLM on every page load.
  - **Phase:** 3
- **Decision:** Database Webhooks for Chat Monitoring
  - **Why:** To achieve true background monitoring without modifying frontend client logic, firing on INSERT to the chat_messages table to intercept dangerous patient messages instantly.
  - **Phase:** 4
- **Decision:** Push-to-Talk (PTT) Audio Architecture
  - **Why:** Constant ambient listening creates unacceptable privacy risks (GDPR/HIPAA violations). A prominent PTT button guarantees explicit consent.
  - **Phase:** 5
- **Decision:** Secure Webhook Pipeline for IoT (iot-ingestion)
  - **Why:** External IoT clouds push data via webhooks. Gemini 1.5 Pro detects anomalies statelessly as data arrives.
  - **Phase:** 6
- **Decision:** Natural Language Dispatch and Status Webhook for Robotics (obotics-dispatch and obotics-webhook)
  - **Why:** Allows older adults to request help naturally, while maintaining real-time tracking of the physical robot's status on the Caregiver Dashboard.
  - **Phase:** 7

## 3. Phases Delivered

| Phase | Name | Status | One-Liner |
|-------|------|--------|-----------|
| 1 | Secure Server-Side LLM Execution | Complete | Migrated Gemini API logic to Supabase Edge Function nalyze-meal. |
| 2 | Multimodal Prescription OCR | Complete | Deployed Gemini 1.5 Pro Edge Function with drug interactions and Flutter clinical review UI. |
| 3 | AI Nudges & Predictive Analytics | Complete | Implemented nightly pg_cron Edge Function that aggregates 7-day health logs into an AI insight card on the dashboard. |
| 4 | AI Mediator in Care Team Chat | Complete | Added a stateless Edge Function and Supabase Webhook to monitor chat messages and inject critical AI warnings directly into the Flutter chat UI. |
| 5 | Conversational Voice Interface | Complete | Added a Push-to-Talk voice assistant UI to the Flutter dashboard backed by a secure Supabase Edge Function that uses Gemini to extract intents. |
| 6 | IoT Device Integration | Complete | Added a secure iot-ingestion Edge Function to act as a webhook for third-party medical devices. |
| 7 | Home Robotics API Integration | Complete | Added a robot_tasks schema, a dispatch function that translates natural language into commands, a webhook to receive robot updates, and a UI widget for monitoring. |

## 4. Requirements Coverage

- ? [Mobile Food Analysis]
- ? [Simulated Edge Functions]
- ? Implement secure Edge Functions for LLM requests with Supabase Vault integration
- ? Build multimodal prescription OCR for PDF/PNG scans with drug interaction checks
- ? Create daily cron-triggered AI health nudges for caregivers
- ? Integrate background LLM chat mediator for critical symptom alerts
- ? Build conversational voice interface for accessible health logging
- ? Design API contracts and integrations for home robotics assistance

**Out of Scope:**
- ? [General Diagnosis] — App is not a replacement for clinical diagnosis or a primary healthcare provider.

## 5. Key Decisions Log

- **D-01 (Phase 4):** Adhere to best practices and compliance rules defined in AGENTS.md.
- **D-02 (Phase 4):** Use Database Webhooks for true background chat monitoring.
- **D-03 (Phase 4):** Inject system-level warnings in-chat rather than external SMS alerts to avoid hallucination risks.
- **D-04 (Phase 4):** Stateless LLM invocation for chat monitoring to minimize PHI footprint.
- **D-01 (Phase 5):** Strict adherence to AGENTS.md (ASM) for audio data.
- **D-02 (Phase 5):** Push-to-Talk (PTT) over ambient listening.
- **D-03 (Phase 5):** Clip-based Edge Function processing for voice.
- **D-04 (Phase 5):** Function Calling / Intent Extraction via LLM.
- **D-01 (Phase 6):** Strict adherence to AGENTS.md (ASM).
- **D-02 (Phase 6):** Pivot from Robotics to IoT (before pivoting back to Robotics for Phase 7).
- **D-03 (Phase 6):** Secure Webhook Pipeline for incoming device telemetry.
- **D-04 (Phase 6):** Anomaly Detection using stateless Gemini evaluations.

## 6. Tech Debt & Deferred Items

*(None formally documented in CONTEXT.md or VERIFICATION.md at this time.)*

## 7. Getting Started

- **Key directories:** mobile_app/ (Flutter frontend), supabase/functions/ (Deno backend APIs).
- **Run the project:** lutter run in mobile_app/ to start the app, 
px supabase start to run the local database and edge functions.
- **Tests:** Currently managed manually; verify flows using provided curl templates in erification_guide.md.
- **Where to look first:** Check dashboard_provider.dart for the main data aggregation logic, and index.ts in each supabase/functions/ directory for the Edge Function implementations.

---

## Stats

*(Git statistics unavailable — no tag or date range could be determined.)*
