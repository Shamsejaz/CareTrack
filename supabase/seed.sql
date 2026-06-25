-- SQL script to create an admin user in Supabase Auth and Profiles
-- Email: shams_ejaz@yahoo.com
-- Default Password: AdminPassword123!

DO $$
DECLARE
  new_user_id UUID := gen_random_uuid();
BEGIN
  -- 1. Insert into auth.users
  INSERT INTO auth.users (
    id,
    instance_id,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    email_change,
    email_change_token_new,
    recovery_token
  )
  VALUES (
    new_user_id,
    '00000000-0000-0000-0000-000000000000',
    'shams_ejaz@yahoo.com',
    crypt('AdminPassword123!', gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{"full_name":"Shams Ejaz"}',
    now(),
    now(),
    '',
    '',
    '',
    ''
  );

  -- 2. Insert into auth.identities
  INSERT INTO auth.identities (
    id,
    user_id,
    identity_data,
    provider,
    last_sign_in_at,
    created_at,
    updated_at
  )
  VALUES (
    new_user_id,
    new_user_id,
    format('{"sub":"%s","email":"%s"}', new_user_id, 'shams_ejaz@yahoo.com')::jsonb,
    'email',
    now(),
    now(),
    now()
  );

  -- 3. Insert into public.profiles
  INSERT INTO public.profiles (
    id,
    full_name,
    role,
    created_at
  )
  VALUES (
    new_user_id,
    'Shams Ejaz',
    'admin',
    now()
  );

  RAISE NOTICE 'Admin user created with ID: %', new_user_id;
END $$;
