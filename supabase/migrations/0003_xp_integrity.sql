-- XP integrity fixes.
-- Run in Supabase -> SQL Editor after deploying the matching app build.

-- 1. One registration per student per tournament: without this, tapping
--    "Register" repeatedly on the same tournament mints +20 XP each time.
do $$ begin
  alter table tournament_registrations
    add constraint uq_tournament_student unique (tournament_id, student_id);
exception when duplicate_object then null;
end $$;

-- 2. Atomic XP increment + level recalculation. The previous client-side
--    read-modify-write could lose XP when two awards landed concurrently.
create or replace function increment_xp(p_student_id uuid, p_delta int)
returns int
language plpgsql
security invoker
as $$
declare
  v_new   int;
  v_level int;
  v_name  text;
begin
  update student_profiles
     set xp_total = xp_total + p_delta
   where user_id = p_student_id
  returning xp_total into v_new;

  if v_new is null then
    raise exception 'No student profile for %', p_student_id;
  end if;

  select l, n into v_level, v_name from (values
    (1, 'Rookie',            0,    100),
    (2, 'Contender',         101,  300),
    (3, 'Challenger',        301,  600),
    (4, 'Competitor',        601,  1000),
    (5, 'Elite',             1001, 1500),
    (6, 'Champion',          1501, 2000),
    (7, 'National Prospect', 2001, 2147483647)
  ) t(l, n, mn, mx)
  where v_new >= mn and v_new <= mx;

  update student_profiles
     set level                = v_level,
         level_name           = v_name,
         is_national_prospect = (v_level >= 7)
   where user_id = p_student_id;

  return v_new;
end $$;
