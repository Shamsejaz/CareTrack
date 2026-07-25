ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS consent_given BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS consent_date TIMESTAMP WITH TIME ZONE;

-- Create a function to handle new user signups
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, role, consent_given, consent_date)
  values (
    new.id,
    new.raw_user_meta_data->>'full_name',
    coalesce(new.raw_user_meta_data->>'role', 'patient'),
    coalesce((new.raw_user_meta_data->>'consent_given')::boolean, true),
    now()
  )
  on conflict (id) do nothing;
  return new;
end;
$$ language plpgsql security definer;

-- Trigger the function every time a user is created
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
