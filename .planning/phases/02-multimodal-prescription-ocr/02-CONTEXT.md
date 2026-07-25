# Phase 2: Multimodal Prescription OCR - Context

**Gathered:** 2026-07-25
**Status:** Ready for planning

<domain>
## Phase Boundary

Implement robust prescription parsing using `gemini-1.5-pro`. This includes updating the `process-prescription` Edge Function to accept multimodal inputs, applying structured JSON schemas for medications, and adding a clinical safety layer for drug interaction warnings.

</domain>

<decisions>
## Implementation Decisions

### Overarching Strategy
- **D-01:** User deferred to **best practices and compliance rules** defined in `AGENTS.md`. All decisions strictly adhere to HIPAA, GDPR, and PDPL requirements.

### Drug Interaction Safety Layer
- **D-02:** Use an **Internal Mock Database** for now. 
  *Compliance reasoning:* Sending extracted medication data (PHI) to a third-party public API (like RxList) without a Business Associate Agreement (BAA) violates HIPAA and PDPL data residency rules. A local/mock database ensures PHI never leaves the secure Supabase environment.

### User Validation Flow
- **D-03:** Mandatory **"Review and Confirm" Screen**. 
  *Compliance reasoning:* Extracted medications must NEVER be auto-saved to the patient's record. The user must review, explicitly consent to, and confirm the AI's extraction to ensure clinical safety and provide explicit consent for data processing (GDPR/PDPL).

### Audit Logging
- **D-04:** **Immutable Audit Trail**.
  *Compliance reasoning:* The Edge Function must log the OCR extraction event, including who uploaded it and when, satisfying HIPAA audit requirements.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

- `.agents/AGENTS.md` — Contains the strict Data Privacy & Compliance rules (HIPAA, GDPR, PDPL) that govern this phase.
- `.planning/codebase/ai_documentation.md` — Details the structured output schema required for `gemini-1.5-pro` (name, dose, timing, frequency) and the clinical safety layer.
- `.planning/ROADMAP.md` — Phase boundaries.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `supabase/functions/process-prescription/index.ts`: The existing simulated Edge Function that will be upgraded to use the live `gemini-1.5-pro` model.
- `mobile_app/lib/features/tracking/medicine_tracker_screen.dart`: The mobile UI where the upload and validation will likely occur.

### Established Patterns
- Supabase Edge Functions with `npm:@google/genai`.
- Strict schema validation using Zod or similar before returning to the client.

</code_context>

<specifics>
## Specific Ideas
- The user emphasized strict adherence to the new compliance block added to `AGENTS.md`. 
</specifics>

<deferred>
## Deferred Ideas
None.
</deferred>
