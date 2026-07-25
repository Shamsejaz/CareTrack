-- Add subscription fields to the profiles table
ALTER TABLE public.profiles
ADD COLUMN subscription_tier TEXT CHECK (subscription_tier IN ('free', 'premium', 'family')) DEFAULT 'free',
ADD COLUMN stripe_customer_id TEXT,
ADD COLUMN revenuecat_app_user_id TEXT,
ADD COLUMN subscription_status TEXT DEFAULT 'active',
ADD COLUMN subscription_end_date TIMESTAMP WITH TIME ZONE;
