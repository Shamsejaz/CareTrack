# CareTrack AI & LLM Integration

## What This Is
Enforcing production readiness by removing all frontend mocks and simulated logic. Achieving complete feature parity with the marketing website by building Caregiver Support, IoT Device Sync, and Home Robotics API integrations.

## Core Value
Ensures CareTrack operates as a secure, real-world enterprise application compliant with `AGENTS.md` (no mocks), and fulfills all advertised features to users.

## Key Decisions
| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Move Gemini API to Edge Functions | Protect API keys and IP from client-side extraction | Pending |
| Use gemini-1.5-pro for OCR | Better structured JSON output for clinical text | Pending |
| Daily cron job for insights | Prevent overloading the LLM on every page load | Pending |
| Background chat agent | Intercept dangerous patient messages instantly | Pending |

| Anti-Mock Enforcement | Remove `DemoMode` and `Future.delayed` | Active |
| Caregiver Table Linking | Link `patient_id` to `caregiver_id` securely | Pending |
| Native IoT Sync Plugins | Use HealthKit/Health Connect to sync pedometer | Pending |

## Requirements

### Validated
- ✓ [Mobile Food Analysis] — existing
- ✓ [Simulated Edge Functions] — existing
- ✓ [Secure Server-Side LLM Execution] — Milestone 1
- ✓ [Multimodal Prescription OCR] — Milestone 1
- ✓ [Conversational Voice Interface] — Milestone 1

### Active
- [x] Connect `vitals_dashboard_screen` and trackers to real Supabase `health_logs` tables
- [x] Remove `Future.delayed` mocks and integrate real Edge Function HTTP calls for AI parsing
- [x] Build Care Team UI and link patients to caregivers in Supabase
- [x] Implement HealthKit/HealthConnect plugins for device syncing
- [x] Build Home Robotics webhook dispatch via Edge Functions

### Out of Scope
- [General Diagnosis] — App is not a replacement for clinical diagnosis or a primary healthcare provider.

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state
---
*Last updated: 2026-06-26 after initialization*
