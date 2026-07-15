-- users.age was constrained to the student range (5-30), but coaches
-- share the users table and are typically older. The app still enforces
-- 5-30 for student registrations; the DB now accepts any user 5-80.
alter table users drop constraint users_age_check;
alter table users add constraint users_age_check check (age >= 5 and age <= 80);
