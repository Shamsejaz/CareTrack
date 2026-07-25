# Phase 1: Secure Server-Side LLM Execution - Context

**Gathered:** 2026-07-25
**Status:** Ready for planning

<domain>
## Phase Boundary

Migrate client-side Gemini calls to secure Supabase Edge Functions. Move API execution to the backend to protect API keys and intellectual property, while keeping the client functionality (like meal photo analysis) working seamlessly.

</domain>

<decisions>
## Implementation Decisions

### Payload Format
- **D-01:** Base64 JSON payload — the Edge Function will accept JSON payloads containing base64 encoded bytes for any multimodal inputs (like the meal photo), simplifying parsing compared to multipart form data.

### Response Validation
- **D-02:** Validate schema on the Edge Function before returning — the Edge Function must parse the raw Gemini JSON and ensure it conforms to the expected clinical/app schemas (e.g. `{ mealName, calories, carbs, healthStatus, advice }`) before sending it down to the mobile app, preventing malformed responses from crashing the client.

### Error Handling Strategy
- **D-03:** Generic 500 error for clients — if Gemini API errors occur, the backend will log the detailed trace but return generic, safe messages (e.g., "AI analysis temporarily unavailable") to the client.

### the agent's Discretion
User deferred to best practices for all technical implementation details. Use standard Deno/Supabase patterns for Edge Functions and `npm:@google/genai`.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Architecture and Design
- `.planning/codebase/ai_documentation.md` — Details current simulated Edge Function and live mobile implementation patterns for Gemini.
- `.planning/ROADMAP.md` — General phase requirements and project structure.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `mobile_app/lib/core/services/ai_service.dart`: The current client-side AI service to be refactored to call the Edge Function instead of Gemini directly.
- `supabase/functions/process-prescription/index.ts`: Existing simulated edge function that can serve as a template or reference for Edge Function structure.

### Established Patterns
- Supabase Edge Functions in TypeScript using Deno.
- Vault for secrets management (`GEMINI_API_KEY`).

### Integration Points
- Refactoring `mobile_app`'s Dart code to send API requests to the Supabase endpoint instead of Google GenAI SDK.
- The new `analyze-meal` edge function will connect directly to the Gemini API using `npm:@google/genai`.

</code_context>

<specifics>
## Specific Ideas

No specific requirements — user deferred to best practice and standard approaches.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 1-Secure Server-Side LLM Execution*
*Context gathered: 2026-07-25*
