# Phase 3: AI Nudges & Predictive Analytics - Context

**Gathered:** 2026-07-25
**Status:** Ready for planning

<domain>
## Phase Boundary

Generate personalized, predictive AI nudges for caregivers based on patient health logs. This phase entails querying historical health logs and using an LLM to synthesize trends into actionable insights (e.g., "Blood sugar has been trending down over the last 3 days").

</domain>

<decisions>
## Implementation Decisions

### Overarching Strategy
- **D-01:** User deferred to **best practices and compliance rules** defined in `AGENTS.md`. All decisions strictly adhere to HIPAA, GDPR, and PDPL requirements.

### Trigger Mechanism
- **D-02:** **Scheduled Cron Job (`pg_cron`)**. 
  *Performance reasoning:* Triggering an LLM generation on-demand when the dashboard loads is too slow. A nightly/morning cron job ensures the insights are pre-calculated and instantly available.

### Data Timeframe (Data Minimization)
- **D-03:** **7-Day Rolling Window**. 
  *Compliance reasoning:* To comply with GDPR/PDPL Data Minimization, we only feed the minimum required data into the LLM context window. 7 days provides enough trend data for an accurate nudge without exposing an entire medical history.

### Delivery & Notifications
- **D-04:** **In-App Dashboard Only (No PHI in Push)**.
  *Compliance reasoning:* Sending specific health trends ("Sugar is low") via email or APNs/FCM push notifications violates HIPAA (since push payloads are not E2E encrypted). We will only show the detailed nudge inside the secure, authenticated app dashboard. We may send a generic push notification ("You have a new health insight for [Patient]").

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

- `.agents/AGENTS.md` — Strict Data Privacy & Compliance rules (HIPAA, GDPR, PDPL).
- `.planning/codebase/ai_documentation.md` — Details the daily cron-triggered AI health nudges architecture.
- `.planning/ROADMAP.md` — Phase boundaries.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `mobile_app/lib/features/dashboard/providers/dashboard_provider.dart` — Provides `health_logs` and could be updated to fetch `ai_insights`.
- Supabase Edge Functions — Can be triggered by `pg_cron` using `pg_net`.

</code_context>

<specifics>
## Specific Ideas
- The user emphasized strict adherence to `AGENTS.md` for this phase.
</specifics>

<deferred>
## Deferred Ideas
None.
</deferred>
