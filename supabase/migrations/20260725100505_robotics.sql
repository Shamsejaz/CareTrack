-- Phase 7: Home Robotics Integration
CREATE TABLE public.robot_tasks (
    id BIGSERIAL PRIMARY KEY,
    patient_id UUID REFERENCES auth.users(id) NOT NULL,
    task_type TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'in_progress', 'completed', 'failed'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.robot_tasks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Caregivers can view linked patients robot tasks" ON public.robot_tasks 
FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.care_links 
      WHERE public.care_links.caregiver_id = auth.uid() 
      AND public.care_links.patient_id = public.robot_tasks.patient_id
    )
);

CREATE POLICY "Users can view own robot tasks" ON public.robot_tasks 
FOR SELECT USING (auth.uid() = patient_id);
