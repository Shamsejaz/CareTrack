-- Phase 4: Add is_system to chat_messages
ALTER TABLE public.chat_messages ADD COLUMN is_system BOOLEAN DEFAULT false NOT NULL;

-- Note: The Webhook trigger for the Edge Function must be configured 
-- manually in the Supabase Dashboard UI to avoid hardcoding the Service Role Key.
