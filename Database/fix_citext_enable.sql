
-- ==================================================================
-- FIX PACK (Option A): Enable CITEXT & re-create email normalize func
-- Date: 2025-09-04
-- Target: PostgreSQL / Cloud SQL (run in the *target database*)
-- ==================================================================

-- 1) Enable required extensions (CITEXT for case-insensitive email)
CREATE EXTENSION IF NOT EXISTS citext;   -- <== fixes: type "citext" does not exist
CREATE EXTENSION IF NOT EXISTS pgcrypto; -- for gen_random_uuid / digest
-- (Optional, used by indexes elsewhere)
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS btree_gin;

-- 2) Put health schema first
SET search_path = health, public;

-- 3) Recreate fn_email_normalize to compile against CITEXT
CREATE OR REPLACE FUNCTION fn_email_normalize(p_email TEXT)
RETURNS CITEXT LANGUAGE plpgsql STABLE AS $$
DECLARE e TEXT; BEGIN
  IF p_email IS NULL THEN RETURN NULL; END IF;
  e := trim(lower(p_email));
  IF e ~ '^[a-z0-9._%+\-]+@[a-z0-9.\-]+\.[a-z]{2,}$' THEN
    RETURN e::citext;
  ELSE
    RETURN NULL;
  END IF;
END $$;

-- 4) Quick self-test (non-fatal if fails)
DO $$ BEGIN
  PERFORM fn_email_normalize('Test@Example.com');
EXCEPTION WHEN OTHERS THEN
  RAISE WARNING 'fn_email_normalize self-test failed: %', SQLERRM;
END $$;

-- Done.
