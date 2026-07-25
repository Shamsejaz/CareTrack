# Phase 5: Conversational Voice Interface - Discussion Log

- **Topic:** Gray areas for implementation
- **User selected:** "best practices & ASM @Agents.md PTT i think research"
- **Resolution:**
  - **Trigger Mechanism**: Push-to-Talk (PTT) to prevent ambient listening risks.
  - **Audio Architecture**: Flutter records clips and uploads to a secure Supabase Edge Function to protect API keys (Server-Side LLM Execution).
  - **Action Capabilities**: Edge function passes the raw audio to `gemini-1.5-pro` to extract intents, executing database updates (like logging medicine) and returning text for TTS.
