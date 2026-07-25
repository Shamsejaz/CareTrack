# Phase 3: AI Nudges & Predictive Analytics - Discussion Log

- **Topic:** Gray areas for implementation
- **User selected:** "use the best practices and @agents.md Compliance"
- **Resolution:** Deferred to strict compliance with HIPAA, GDPR, and PDPL.
  - Used a daily `pg_cron` trigger to pre-calculate insights efficiently.
  - Restrict LLM context window to 7 days of logs (Data Minimization).
  - Show nudges in the secure dashboard only; no PHI sent via push notifications.
