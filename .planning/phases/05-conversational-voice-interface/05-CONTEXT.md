# Phase 5: Conversational Voice Interface - Context

**Gathered:** 2026-07-25
**Status:** Ready for planning

<domain>
## Phase Boundary

Implement a conversational voice interface for the Flutter app. The goal is to allow older adults to speak naturally to log health events or ask questions without typing.

</domain>

<decisions>
## Implementation Decisions

### Overarching Strategy
- **D-01:** Strict adherence to **best practices and `AGENTS.md` (ASM)**. Ensure the audio pipeline respects data minimization and keeps API keys out of the frontend.

### Trigger Mechanism
- **D-02:** **Push-to-Talk (PTT)**. 
  *Reasoning:* Constant ambient listening creates unacceptable privacy risks (GDPR/HIPAA violations). A prominent PTT button will be added to the dashboard for explicit consent and clear user interaction.

### Audio Architecture
- **D-03:** **Clip-based Edge Function Processing**. 
  *Reasoning:* To secure API keys (Phase 1 constraint), the Flutter app will record a short audio clip (e.g., m4a/wav) and upload it to a secure Supabase Edge Function (`ai-voice-assistant`). The Edge Function will send the raw audio to `gemini-1.5-pro` (which natively supports audio) to extract the user's intent and transcribe the text.

### Action Capabilities
- **D-04:** **Function Calling / Intent Extraction**.
  *Reasoning:* The LLM will parse the audio to determine if the user is trying to log a health event (e.g., "I just took my medicine") or asking a general question. The Edge Function will execute the corresponding database operation if needed, and return a textual response that the app can read back via Text-to-Speech (TTS).

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

- `.agents/AGENTS.md` — Strict Data Privacy & Server-Side LLM constraints.
- `.planning/ROADMAP.md` — Phase boundaries.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- Supabase Edge Functions (`ai-voice-assistant`)
- Flutter Dashboard UI — Need to add a prominent floating microphone button.
- Flutter audio recording packages (e.g., `record`) and TTS packages (e.g., `flutter_tts`). We may need to mock this for the demo or use basic native capabilities if adding complex dependencies is risky.
</code_context>

<specifics>
## Specific Ideas
- User emphasized PTT, Best Practices, and ASM (`AGENTS.md`).
</specifics>

<deferred>
## Deferred Ideas
None.
</deferred>
