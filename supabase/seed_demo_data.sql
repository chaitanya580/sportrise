-- Demo seed data: 6 verified coaches + 4 upcoming Hyderabad tournaments.
-- Run in Supabase -> SQL Editor (runs as postgres, bypasses RLS).
-- Safe to re-run: cleans up previous seed rows first (matched by the
-- 90000000xx dummy mobile numbers and seeded tournament names).

-- ── cleanup previous seed ─────────────────────────────────────
delete from coach_profiles where user_id in
  (select id from users where mobile like '90000000%' and role = 'coach');
delete from users where mobile like '90000000%' and role = 'coach';
delete from tournaments where name in (
  'Hyderabad Youth Football League',
  'Telangana School Cricket Cup',
  'Monsoon 5-a-side Championship',
  'Inter-School T20 Trophy');

-- ── coaches ───────────────────────────────────────────────────
do $$
declare uid uuid;
begin
  insert into users (name, mobile, age, city, role, is_minor, parental_consent)
  values ('Ravi Kumar', '9000000001', 38, 'Hyderabad', 'coach', false, true)
  returning id into uid;
  insert into coach_profiles (user_id, sport, city, fee_per_session, avg_rating, total_sessions, is_verified)
  values (uid, 'Football', 'Hyderabad', 500, 4.8, 210, true);

  insert into users (name, mobile, age, city, role, is_minor, parental_consent)
  values ('Suresh Goud', '9000000002', 45, 'Hyderabad', 'coach', false, true)
  returning id into uid;
  insert into coach_profiles (user_id, sport, city, fee_per_session, avg_rating, total_sessions, is_verified)
  values (uid, 'Football', 'Hyderabad', 350, 4.5, 140, true);

  insert into users (name, mobile, age, city, role, is_minor, parental_consent)
  values ('Anita Reddy', '9000000003', 31, 'Secunderabad', 'coach', false, true)
  returning id into uid;
  insert into coach_profiles (user_id, sport, city, fee_per_session, avg_rating, total_sessions, is_verified)
  values (uid, 'Football', 'Secunderabad', 600, 4.9, 320, true);

  insert into users (name, mobile, age, city, role, is_minor, parental_consent)
  values ('Mohammed Irfan', '9000000004', 41, 'Hyderabad', 'coach', false, true)
  returning id into uid;
  insert into coach_profiles (user_id, sport, city, fee_per_session, avg_rating, total_sessions, is_verified)
  values (uid, 'Cricket', 'Hyderabad', 800, 4.7, 260, true);

  insert into users (name, mobile, age, city, role, is_minor, parental_consent)
  values ('Prakash Rao', '9000000005', 36, 'Hyderabad', 'coach', false, true)
  returning id into uid;
  insert into coach_profiles (user_id, sport, city, fee_per_session, avg_rating, total_sessions, is_verified)
  values (uid, 'Cricket', 'Hyderabad', 450, 4.4, 95, true);

  insert into users (name, mobile, age, city, role, is_minor, parental_consent)
  values ('Lakshmi Devi', '9000000006', 29, 'Warangal', 'coach', false, true)
  returning id into uid;
  insert into coach_profiles (user_id, sport, city, fee_per_session, avg_rating, total_sessions, is_verified)
  values (uid, 'Badminton', 'Warangal', 300, 4.6, 75, true);
end $$;

-- ── tournaments ───────────────────────────────────────────────
insert into tournaments (name, sport, city, venue, event_date, registration_deadline, is_verified)
values
  ('Hyderabad Youth Football League', 'Football', 'Hyderabad',
   'Gachibowli Indoor Stadium', now() + interval '30 days', now() + interval '20 days', true),
  ('Telangana School Cricket Cup', 'Cricket', 'Hyderabad',
   'LB Stadium', now() + interval '45 days', now() + interval '30 days', true),
  ('Monsoon 5-a-side Championship', 'Football', 'Secunderabad',
   'St. Anns Grounds', now() + interval '21 days', now() + interval '14 days', true),
  ('Inter-School T20 Trophy', 'Cricket', 'Hyderabad',
   'Uppal Community Grounds', now() + interval '60 days', now() + interval '40 days', true);
