-- Bulk update users' plan to pro/platinum
-- Usage options:
-- 1) Update by explicit email list
-- 2) Update by explicit phone (E.164) list
-- 3) Load a CSV list (identifier, plan) into a temp table and update

BEGIN;

-- Safety: inspect current distribution (optional)
-- SELECT plan, count(*) FROM users GROUP BY plan ORDER BY 1;

-- Option 1: Update by email list
-- UPDATE users SET plan='pro' WHERE email IN ('alice@example.com','bob@example.com');
-- UPDATE users SET plan='platinum' WHERE email IN ('carol@example.com');

-- Option 2: Update by phone list (E.164)
-- UPDATE users SET plan='pro' WHERE phone_e164 IN ('+819012345678');
-- UPDATE users SET plan='platinum' WHERE phone_e164 IN ('+8613012345678');

-- Option 3: From CSV
-- Prepare CSV file columns: identifier,plan
--   identifier: email or phone_e164 (start with '+' for phone)
--   plan: free|standard|pro|platinum
-- Example:
--   alice@example.com,pro
--   +819012345678,platinum

-- Create temp table and load data
-- DROP TABLE IF EXISTS tmp_user_plans;
-- CREATE TEMP TABLE tmp_user_plans (
--   identifier TEXT NOT NULL,
--   plan plan_type NOT NULL
-- );
-- \copy tmp_user_plans(identifier,plan) FROM 'path/to/users_plan.csv' WITH (FORMAT csv, HEADER false);

-- Apply updates: match email first, then phone
-- UPDATE users u
-- SET plan = t.plan
-- FROM tmp_user_plans t
-- WHERE u.email = t.identifier;

-- UPDATE users u
-- SET plan = t.plan
-- FROM tmp_user_plans t
-- WHERE u.phone_e164 = t.identifier;

COMMIT;

-- Verify
-- SELECT email, phone_e164, plan FROM users WHERE email IN ('alice@example.com') OR phone_e164 IN ('+819012345678');
-- SELECT plan, count(*) FROM users GROUP BY plan ORDER BY 1;

