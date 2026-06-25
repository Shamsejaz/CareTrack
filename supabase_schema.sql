-- CareTrack Supabase Schema

-- 1. Profiles Table (Extended user data)
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  username TEXT UNIQUE,
  full_name TEXT,
  avatar_url TEXT,
  role TEXT CHECK (role IN ('patient', 'caregiver', 'doctor', 'admin')) DEFAULT 'patient',
  gender TEXT,
  age INTEGER,
  conditions TEXT[], -- e.g. ['Diabetes', 'BP']
  wake_up_time TIME,
  meal_time JSONB, -- { breakfast: '08:00', lunch: '13:00', dinner: '20:00' }
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. Health Logs (The core activity data)
CREATE TABLE public.health_logs (
  id BIGSERIAL PRIMARY KEY,
  patient_id UUID REFERENCES auth.users(id) NOT NULL,
  log_type TEXT NOT NULL, -- 'Sugar', 'Meal', 'Walk', 'Water', 'Medicine'
  value TEXT,            -- Reading value or meal description
  photo_url TEXT,        -- Remote path to uploaded proof
  manual_confirm BOOLEAN DEFAULT false,
  intervention_alert JSONB, -- { severity: 'High', message: '...' }
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Medications (Prescription extracted data)
CREATE TABLE public.medications (
  id BIGSERIAL PRIMARY KEY,
  patient_id UUID REFERENCES auth.users(id) NOT NULL,
  name TEXT NOT NULL,
  dose TEXT,
  timing TEXT, -- 'After Breakfast', 'Before Bed', etc.
  frequency TEXT, -- 'Daily', 'Twice a day'
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 4. Set up Row Level Security (RLS)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.health_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.medications ENABLE ROW LEVEL SECURITY;

-- Patients can read/write their own data
CREATE POLICY "Users can view own profile" ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Patients can view own logs" ON public.health_logs FOR SELECT USING (auth.uid() = patient_id);
CREATE POLICY "Patients can insert own logs" ON public.health_logs FOR INSERT WITH CHECK (auth.uid() = patient_id);

CREATE POLICY "Patients can view own medications" ON public.medications FOR SELECT USING (auth.uid() = patient_id);

-- 5. Caregiver-Patient Links
CREATE TABLE public.care_links (
  id BIGSERIAL PRIMARY KEY,
  patient_id UUID REFERENCES auth.users(id) NOT NULL,
  caregiver_id UUID REFERENCES auth.users(id) NOT NULL,
  role TEXT CHECK (role IN ('caregiver', 'doctor')) DEFAULT 'caregiver',
  status TEXT DEFAULT 'active', -- 'active', 'pending', 'revoked'
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  UNIQUE(patient_id, caregiver_id)
);

-- 6. Invitation Codes
CREATE TABLE public.invitation_codes (
  code TEXT PRIMARY KEY,
  patient_id UUID REFERENCES auth.users(id) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  expires_at TIMESTAMP WITH TIME ZONE DEFAULT (timezone('utc'::text, now()) + interval '24 hours')
);

-- 7. Notifications / Alerts
CREATE TABLE public.notifications (
  id BIGSERIAL PRIMARY KEY,
  patient_id UUID REFERENCES auth.users(id) NOT NULL,
  type TEXT NOT NULL, -- 'high_sugar', 'missed_med', 'vital_alert'
  message TEXT NOT NULL,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 8. Chat Messages
CREATE TABLE public.chat_messages (
  id BIGSERIAL PRIMARY KEY,
  sender_id UUID REFERENCES auth.users(id) NOT NULL,
  receiver_id UUID REFERENCES auth.users(id) NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 9. Additional RLS for connectivity
ALTER TABLE public.care_links ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invitation_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

-- Caregivers can view data for linked patients
CREATE POLICY "Caregivers can view linked patients logs" ON public.health_logs 
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.care_links 
    WHERE public.care_links.caregiver_id = auth.uid() 
    AND public.care_links.patient_id = public.health_logs.patient_id
  )
);

CREATE POLICY "Patients can view own links" ON public.care_links FOR SELECT USING (auth.uid() = patient_id OR auth.uid() = caregiver_id);
CREATE POLICY "Patients can create invitations" ON public.invitation_codes FOR INSERT WITH CHECK (auth.uid() = patient_id);
CREATE POLICY "Caregivers can view invitations" ON public.invitation_codes FOR SELECT USING (true); -- Codes are verified in app logic

CREATE POLICY "Users can view own notifications" ON public.notifications FOR SELECT USING (
  auth.uid() = patient_id OR 
  EXISTS (
    SELECT 1 FROM public.care_links 
    WHERE public.care_links.caregiver_id = auth.uid() 
    AND public.care_links.patient_id = public.notifications.patient_id
  )
);

CREATE POLICY "Users can exchange messages" ON public.chat_messages FOR ALL USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

