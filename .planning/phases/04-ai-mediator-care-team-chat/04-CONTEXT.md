# Phase 4: AI Mediator in Care Team Chat - Context

**Gathered:** 2026-07-25
**Status:** Ready for planning

<domain>
## Phase Boundary

Implement a background AI monitor for the care team chat. The AI will passively read incoming chat messages, identify potential critical health symptoms (e.g., "Dad fell today", "Mom is feeling dizzy"), and automatically inject a system-level warning or advice directly into the chat stream.

</domain>

<decisions>
## Implementation Decisions

### Overarching Strategy
- **D-01:** User deferred to **best practices and compliance rules** defined in `AGENTS.md`. All decisions strictly adhere to HIPAA, GDPR, and PDPL requirements.

### Trigger Mechanism
- **D-02:** **Database Webhooks**. 
  *Reasoning:* To achieve true background monitoring without modifying frontend client logic, we will use a Supabase Database Webhook that fires on `INSERT` to the `care_team_messages` table. This webhook calls an Edge Function asynchronously.

### Alert Destination
- **D-03:** **In-Chat System Messages**. 
  *Reasoning:* The AI will insert a new message into the chat with a special `is_system=true` flag. This ensures all care team members see the context immediately, but prevents the AI from triggering external 911/SMS alerts (which could be dangerous in case of hallucination).

### Data Privacy & Security
- **D-04:** **Stateless LLM Invocation**.
  *Reasoning:* The Edge Function sends only the text of the single new message to Gemini 1.5 Pro to determine if there is a critical symptom. The LLM does not retain the data, and we do not store the AI's intermediate thought process, minimizing PHI footprint.
</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

- `.agents/AGENTS.md` — Strict Data Privacy & Compliance rules (HIPAA, GDPR, PDPL).
- `.planning/ROADMAP.md` — Phase boundaries.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- Supabase Edge Functions — Can be triggered by Supabase Webhooks.
- Need to check if `care_team_messages` table exists in the initial schema. If not, it needs to be created.
</code_context>

<specifics>
## Specific Ideas
- The user emphasized strict adherence to `AGENTS.md` for this phase.
</specifics>

<deferred>
## Deferred Ideas
None.
</deferred>
