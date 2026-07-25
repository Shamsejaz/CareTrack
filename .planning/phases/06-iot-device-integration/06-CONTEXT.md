# Phase 6: IoT Device Integration - Context

**Gathered:** 2026-07-25
**Status:** Ready for planning

<domain>
## Phase Boundary

Implement backend infrastructure to ingest telemetry data from smart health devices (like wearables, smart glucometers, and BP monitors) that older adults already trust. Evaluate this incoming stream of data using Gemini for anomalies or risks.

</domain>

<decisions>
## Implementation Decisions

### Overarching Strategy
- **D-01:** Strict adherence to **best practices and `AGENTS.md` (ASM)**. 
- **D-02:** **Pivot from Robotics to IoT**: Based on user feedback, Phase 6 shifted from "Home Robotics" to "IoT Device Integration."

### Ingestion Architecture
- **D-03:** **Secure Webhook Pipeline**. 
  *Reasoning:* External IoT clouds (like Withings or Dexcom API) push data via webhooks. We will set up a secure Edge Function (`iot-ingestion`) to receive these payloads.

### LLM Role
- **D-04:** **Anomaly Detection**.
  *Reasoning:* As raw data flows in from devices, we can pass it statelessly to Gemini to ask if the reading represents a sudden, critical spike or drop based on the patient's baseline (similar to Phase 4's chat mediator).

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

- `.agents/AGENTS.md` — Strict Data Privacy & Server-Side LLM constraints.
- `.planning/ROADMAP.md` — Phase boundaries (Updated to IoT integration).

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `health_logs` table (can be used to store the ingested device telemetry).
- Edge Function patterns (from Phase 1, 3, 4, 5).
</code_context>

<specifics>
## Specific Ideas
- User specifically mentioned: "Pairs beautifully with wearables and smart health devices you already trust. Wearables, Smart glucometers, BP monitors best practices @agents.md"
</specifics>

<deferred>
## Deferred Ideas
None.
</deferred>
