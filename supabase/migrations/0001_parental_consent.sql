-- Parental consent for student athletes under 18.
-- Run this in Supabase → SQL Editor before deploying the updated registration flow.

alter table users
  add column if not exists is_minor boolean default false,
  add column if not exists guardian_name text,
  add column if not exists guardian_mobile text,
  add column if not exists parental_consent boolean default false,
  add column if not exists consent_given_at timestamptz;

-- Defense in depth: a minor row can only exist with consent recorded.
alter table users
  add constraint chk_minor_consent
  check (is_minor = false or parental_consent = true);
