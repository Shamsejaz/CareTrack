-- Enable extensions for cron and network requests if not already enabled
CREATE EXTENSION IF NOT EXISTS pg_cron;
CREATE EXTENSION IF NOT EXISTS pg_net;

-- Create ai_insights table
CREATE TABLE public.ai_insights (
    id BIGSERIAL PRIMARY KEY,
    patient_id UUID REFERENCES auth.users(id) NOT NULL,
    insight_text TEXT NOT NULL,
    severity TEXT NOT NULL CHECK (severity IN ('Positive', 'Neutral', 'Warning', 'Critical')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable Row Level Security
ALTER TABLE public.ai_insights ENABLE ROW LEVEL SECURITY;

-- Policy: Patients and their caregivers can read insights
CREATE POLICY "Users can read their own insights" 
    ON public.ai_insights 
    FOR SELECT 
    USING (auth.uid() = patient_id);

-- Note: The Edge Function will insert insights using the Service Role key, 
-- which bypasses RLS, so we don't need an INSERT policy for regular users.

-- Schedule nightly cron job to invoke the generate-ai-nudges Edge Function
-- Runs every day at 2:00 AM
SELECT cron.schedule(
    'nightly-ai-nudges',
    '0 2 * * *',
    $$
    SELECT net.http_post(
        url:='https://svuruefzexxbyetpbixh.supabase.co/functions/v1/generate-ai-nudges',
        headers:='{"Content-Type": "application/json", "Authorization": "Bearer YOUR_SERVICE_ROLE_KEY_HERE"}'::jsonb
    )
    $$
);
