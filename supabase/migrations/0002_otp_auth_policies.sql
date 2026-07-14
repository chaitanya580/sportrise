-- Owner-scoped RLS policies for Supabase phone-OTP auth.
-- Run AFTER enabling the Phone provider in Supabase Auth and deploying
-- the OTP login build. New accounts are created with users.id equal to
-- auth.uid(), so writes can be locked to the verified phone's owner.
--
-- Prerequisite: delete pre-auth test rows from users/student_profiles —
-- their ids don't correspond to any auth user.

-- 1. Remove the wide-open anon write policies (bootstrap-era).
drop policy if exists "anon insert users"           on users;
drop policy if exists "anon insert student_profiles" on student_profiles;
drop policy if exists "anon update student_profiles" on student_profiles;
drop policy if exists "anon insert xp"              on xp_transactions;
drop policy if exists "anon insert tournament_regs" on tournament_registrations;
drop policy if exists "anon insert sessions"        on coaching_sessions;

-- 2. Owner-scoped writes for authenticated (OTP-verified) users.
drop policy if exists "own user insert" on users;
create policy "own user insert" on users
  for insert to authenticated with check (id = auth.uid());

drop policy if exists "own user update" on users;
create policy "own user update" on users
  for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

drop policy if exists "own profile insert" on student_profiles;
create policy "own profile insert" on student_profiles
  for insert to authenticated with check (user_id = auth.uid());

drop policy if exists "own profile update" on student_profiles;
create policy "own profile update" on student_profiles
  for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "own xp insert" on xp_transactions;
create policy "own xp insert" on xp_transactions
  for insert to authenticated with check (student_id = auth.uid());

drop policy if exists "own tournament reg insert" on tournament_registrations;
create policy "own tournament reg insert" on tournament_registrations
  for insert to authenticated with check (student_id = auth.uid());

drop policy if exists "own session insert" on coaching_sessions;
create policy "own session insert" on coaching_sessions
  for insert to authenticated with check (student_id = auth.uid());

-- 3. Reads for signed-in users (the anon read policies from the demo
--    bootstrap remain in place so the unauthenticated scout dashboard
--    keeps working; tighten those once scouts get real accounts).
drop policy if exists "auth read users" on users;
create policy "auth read users" on users
  for select to authenticated using (true);

drop policy if exists "auth read student_profiles" on student_profiles;
create policy "auth read student_profiles" on student_profiles
  for select to authenticated using (true);

drop policy if exists "auth read xp" on xp_transactions;
create policy "auth read xp" on xp_transactions
  for select to authenticated using (true);

drop policy if exists "auth read tournaments" on tournaments;
create policy "auth read tournaments" on tournaments
  for select to authenticated using (true);

drop policy if exists "auth read tournament_regs" on tournament_registrations;
create policy "auth read tournament_regs" on tournament_registrations
  for select to authenticated using (true);

drop policy if exists "auth read coach_profiles" on coach_profiles;
create policy "auth read coach_profiles" on coach_profiles
  for select to authenticated using (true);

drop policy if exists "auth read sessions" on coaching_sessions;
create policy "auth read sessions" on coaching_sessions
  for select to authenticated using (true);
