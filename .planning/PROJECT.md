# CareTrack AI & LLM Integration

## What This Is
Integrating Google Gemini LLMs across the CareTrack ecosystem to provide live multimodal OCR, automated caregiver insights, and intelligent care team chat mediation, while moving API execution to secure Supabase Edge Functions.

## Core Value
Enables production-ready AI healthcare companion features, reducing manual data entry for prescriptions, proactively alerting caregivers to health trends, and ensuring patient safety via chat monitoring.

## Key Decisions
| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Move Gemini API to Edge Functions | Protect API keys and IP from client-side extraction | Pending |
| Use gemini-1.5-pro for OCR | Better structured JSON output for clinical text | Pending |
| Daily cron job for insights | Prevent overloading the LLM on every page load | Pending |
| Background chat agent | Intercept dangerous patient messages instantly | Pending |

## Requirements

### Validated
- ✓ [Mobile Food Analysis] — existing
- ✓ [Simulated Edge Functions] — existing

### Active
- [ ] Implement secure Edge Functions for LLM requests with Supabase Vault integration
- [ ] Build multimodal prescription OCR for PDF/PNG scans with drug interaction checks
- [ ] Create daily cron-triggered AI health nudges for caregivers
- [ ] Integrate background LLM chat mediator for critical symptom alerts
- [ ] Build conversational voice interface for accessible health logging
- [ ] Design API contracts and integrations for home robotics assistance

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
