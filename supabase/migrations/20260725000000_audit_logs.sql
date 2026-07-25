-- Migration: Phase 2 OCR Audit Logs
-- Description: Creates the ocr_audit_logs table to maintain an immutable audit trail of OCR extraction events, as mandated by the Phase 2 Context (HIPAA compliance).

CREATE TABLE public.ocr_audit_logs (
    id BIGSERIAL PRIMARY KEY,
    patient_id UUID REFERENCES auth.users(id) NOT NULL,
    status TEXT NOT NULL, -- e.g., 'success', 'failure'
    details JSONB, -- Additional details like warnings detected or error messages
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.ocr_audit_logs ENABLE ROW LEVEL SECURITY;

-- Only service_role can insert/read (or admins if we had an admin role)
-- By default, enabling RLS without any policies means NO ONE (except superuser/service_role) can access it.
-- This ensures the Edge Function can insert logs using the service_role key, 
-- but normal authenticated users (patients) cannot modify or view the audit trail.
