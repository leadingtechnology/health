
-- ============================================================
-- LDETCH Health - PostgreSQL FULL Schema (Email/OTP & Phone/OTP, no password login)
-- Database: PostgreSQL 13+ (Cloud SQL for GCP)
-- Schema: health
-- Author: ChatGPT (GPT-5 Pro)
-- Date: 2025-09-04
-- ============================================================
-- Highlights:
--  * Users can login via Email+OTP OR Phone(E.164)+OTP.
--  * users.email and users.phone_e164 are both optional, but AT LEAST ONE must be present.
--  * password_hash is deprecated and nullable (kept for forward compatibility).
--  * Includes: auditing, quotas (free=3/day by local tz), care circles, patients, conversations, shares,
--    API key storage (app-layer encrypted), tasks, OTP for phone & email, helper functions.
-- ============================================================
DO $$
BEGIN
  IF current_setting('app.env', true) = 'dev' THEN
    EXECUTE 'DROP SCHEMA IF EXISTS health CASCADE';
    EXECUTE 'CREATE SCHEMA health';
  ELSE
    RAISE NOTICE 'Production-like env: skip dropping schema (set app.env=dev to allow).';
  END IF;
END$$;
SET search_path = health, public;

-- ============================================================================
-- Extensions and Basic Setup
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS citext;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS btree_gin;

CREATE SCHEMA IF NOT EXISTS health;
SET search_path = health, public;

-- Enums
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname='plan_type') THEN
    CREATE TYPE plan_type AS ENUM ('free','standard','pro');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname='model_tier') THEN
    CREATE TYPE model_tier AS ENUM ('basic','enhanced','realtime');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname='care_role_type') THEN
    CREATE TYPE care_role_type AS ENUM ('member','caregiver','doctor','admin');
  END IF;
END $$;

-- Helpers: updated_at + audit
CREATE OR REPLACE FUNCTION trg_set_updated_at() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at := NOW(); RETURN NEW;
END $$;

CREATE TABLE IF NOT EXISTS audit_log (
  id            BIGSERIAL PRIMARY KEY,
  table_name    TEXT NOT NULL,
  action        TEXT NOT NULL CHECK (action IN ('INSERT','UPDATE','DELETE')),
  actor_user_id UUID,
  row_pk_text   TEXT,
  old_data      JSONB,
  new_data      JSONB,
  occurred_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION trg_audit_dml() RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE v_actor TEXT; v_pk TEXT; BEGIN
  v_actor := current_setting('app.user_id', true);
  IF TG_OP='INSERT' THEN
    v_pk := COALESCE(NEW.id::TEXT,NULL);
    INSERT INTO audit_log(table_name,action,actor_user_id,row_pk_text,old_data,new_data)
    VALUES (TG_TABLE_NAME,TG_OP,NULLIF(v_actor,'')::UUID,v_pk,NULL,to_jsonb(NEW));
    RETURN NEW;
  ELSIF TG_OP='UPDATE' THEN
    v_pk := COALESCE(NEW.id::TEXT,NULL);
    INSERT INTO audit_log(table_name,action,actor_user_id,row_pk_text,old_data,new_data)
    VALUES (TG_TABLE_NAME,TG_OP,NULLIF(v_actor,'')::UUID,v_pk,to_jsonb(OLD),to_jsonb(NEW));
    RETURN NEW;
  ELSIF TG_OP='DELETE' THEN
    v_pk := COALESCE(OLD.id::TEXT,NULL);
    INSERT INTO audit_log(table_name,action,actor_user_id,row_pk_text,old_data,new_data)
    VALUES (TG_TABLE_NAME,TG_OP,NULLIF(v_actor,'')::UUID,v_pk,to_jsonb(OLD),NULL);
    RETURN OLD;
  END IF;
  RETURN NULL;
END $$;

-- Phone normalize
CREATE OR REPLACE FUNCTION fn_phone_normalize(p_phone TEXT, p_default_cc TEXT DEFAULT NULL)
RETURNS TEXT LANGUAGE plpgsql STABLE AS $$
DECLARE s TEXT; BEGIN
  IF p_phone IS NULL OR length(trim(p_phone))=0 THEN RETURN NULL; END IF;
  s := regexp_replace(p_phone, '[\s\-\(\)]', '', 'g');
  IF left(s,1) <> '+' THEN
    IF p_default_cc IS NOT NULL AND p_default_cc ~ '^[1-9][0-9]{1,3}$' THEN
      s := '+' || p_default_cc || regexp_replace(s, '[^0-9]', '', 'g');
    ELSE
      s := '+' || regexp_replace(s, '[^0-9]', '', 'g');
    END IF;
  ELSE
    s := '+' || regexp_replace(right(s, length(s)-1), '[^0-9]', '', 'g');
  END IF;
  IF s ~ '^\+[1-9][0-9]{6,14}$' THEN RETURN s; ELSE RETURN NULL; END IF;
END $$;

-- Email normalize (basic sanity check; citext handles case-insensitive)
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

-- Users (email/phone optional; at least one required; no passwords)
CREATE TABLE IF NOT EXISTS users (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email         CITEXT,                 -- nullable
  name          TEXT NOT NULL DEFAULT '', -- display name (optional)
  password_hash TEXT,                   -- deprecated (NULL for OTP accounts)
  role          TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('user','admin')),
  plan          plan_type  NOT NULL DEFAULT 'free',
  model_tier    model_tier NOT NULL DEFAULT 'basic',
  time_zone     TEXT NOT NULL DEFAULT 'Asia/Tokyo',
  phone_e164    TEXT,                   -- E.164
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at    TIMESTAMPTZ,
  CONSTRAINT ck_users_phone_e164_format CHECK (phone_e164 IS NULL OR phone_e164 ~ '^\+[1-9][0-9]{6,14}$'),
  CONSTRAINT ck_users_identity CHECK (email IS NOT NULL OR phone_e164 IS NOT NULL)
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_users_email_active ON users(email) WHERE deleted_at IS NULL AND email IS NOT NULL;
CREATE UNIQUE INDEX IF NOT EXISTS ux_users_phone_active ON users(phone_e164) WHERE deleted_at IS NULL AND phone_e164 IS NOT NULL;
CREATE TRIGGER trg_users_updated BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION trg_set_updated_at();
CREATE TRIGGER trg_users_audit AFTER INSERT OR UPDATE OR DELETE ON users FOR EACH ROW EXECUTE FUNCTION trg_audit_dml();

-- Auto-normalize phone on change (optional)
CREATE OR REPLACE FUNCTION trg_users_phone_normalize()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.phone_e164 IS NOT NULL THEN NEW.phone_e164 := fn_phone_normalize(NEW.phone_e164, NULL); END IF;
  IF NEW.email IS NOT NULL THEN NEW.email := fn_email_normalize(NEW.email); END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER trg_users_phone_normalize_biud
BEFORE INSERT OR UPDATE OF phone_e164, email ON users
FOR EACH ROW EXECUTE FUNCTION trg_users_phone_normalize();

-- Circles/Members
CREATE TABLE IF NOT EXISTS care_circles (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name          TEXT NOT NULL,
  owner_user_id UUID NOT NULL REFERENCES users(id),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TRIGGER trg_care_circles_updated BEFORE UPDATE ON care_circles FOR EACH ROW EXECUTE FUNCTION trg_set_updated_at();
CREATE TRIGGER trg_care_circles_audit AFTER INSERT OR UPDATE OR DELETE ON care_circles FOR EACH ROW EXECUTE FUNCTION trg_audit_dml();

CREATE TABLE IF NOT EXISTS care_circle_members (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  care_circle_id UUID NOT NULL REFERENCES care_circles(id) ON DELETE CASCADE,
  user_id        UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role           care_role_type NOT NULL DEFAULT 'member',
  added_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (care_circle_id, user_id)
);
CREATE INDEX IF NOT EXISTS ix_cc_members_user ON care_circle_members(user_id);
CREATE TRIGGER trg_cc_members_audit AFTER INSERT OR UPDATE OR DELETE ON care_circle_members FOR EACH ROW EXECUTE FUNCTION trg_audit_dml();

-- Patients
CREATE TABLE IF NOT EXISTS patients (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name               TEXT NOT NULL,
  birth_date         DATE,
  gender             TEXT,
  conditions         TEXT,
  allergies          TEXT,
  emergency_contact  TEXT,
  primary_circle_id  UUID REFERENCES care_circles(id) ON DELETE SET NULL,
  created_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS ix_patients_primary_circle ON patients(primary_circle_id);
CREATE TRIGGER trg_patients_updated BEFORE UPDATE ON patients FOR EACH ROW EXECUTE FUNCTION trg_set_updated_at();
CREATE TRIGGER trg_patients_audit AFTER INSERT OR UPDATE OR DELETE ON patients FOR EACH ROW EXECUTE FUNCTION trg_audit_dml();

-- Conversations
CREATE TABLE IF NOT EXISTS conversations (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title         TEXT NOT NULL,
  patient_id    UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  owner_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  summary_text  TEXT NOT NULL DEFAULT '',
  is_shared     BOOLEAN NOT NULL DEFAULT FALSE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  tsv           tsvector GENERATED ALWAYS AS (to_tsvector('simple', coalesce(title,'') || ' ' || coalesce(summary_text,''))) STORED
);
CREATE INDEX IF NOT EXISTS ix_conv_patient ON conversations(patient_id);
CREATE INDEX IF NOT EXISTS ix_conv_owner ON conversations(owner_user_id);
CREATE INDEX IF NOT EXISTS ix_conv_tsv ON conversations USING GIN (tsv);
CREATE INDEX IF NOT EXISTS ix_conv_summary_trgm ON conversations USING GIN (summary_text gin_trgm_ops);
CREATE TRIGGER trg_conversations_updated BEFORE UPDATE ON conversations FOR EACH ROW EXECUTE FUNCTION trg_set_updated_at();
CREATE TRIGGER trg_conversations_audit AFTER INSERT OR UPDATE OR DELETE ON conversations FOR EACH ROW EXECUTE FUNCTION trg_audit_dml();

-- Shares
CREATE TABLE IF NOT EXISTS share_grants (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  to_user_id      UUID REFERENCES users(id) ON DELETE SET NULL,
  to_email        CITEXT,
  redact_pii      BOOLEAN NOT NULL DEFAULT TRUE,
  expires_at      TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  revoked_at      TIMESTAMPTZ,
  CONSTRAINT ck_share_target CHECK (to_user_id IS NOT NULL OR to_email IS NOT NULL)
);
CREATE INDEX IF NOT EXISTS ix_share_conversation ON share_grants(conversation_id);
CREATE INDEX IF NOT EXISTS ix_share_to_user ON share_grants(to_user_id);
CREATE TRIGGER trg_share_grants_audit AFTER INSERT OR UPDATE OR DELETE ON share_grants FOR EACH ROW EXECUTE FUNCTION trg_audit_dml();

-- Quotas
CREATE TABLE IF NOT EXISTS quota_usages (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  local_date DATE NOT NULL,
  used_count INT  NOT NULL DEFAULT 0,
  UNIQUE (user_id, local_date)
);
CREATE INDEX IF NOT EXISTS ix_quota_user_date ON quota_usages(user_id, local_date);

CREATE OR REPLACE FUNCTION fn_plan_daily_limit(p plan_type) RETURNS INT LANGUAGE SQL IMMUTABLE AS $$
  SELECT CASE p WHEN 'free' THEN 3 ELSE 2147483647 END;
$$;
CREATE OR REPLACE FUNCTION fn_reset_at_local_midnight(p_tz TEXT) RETURNS TIMESTAMPTZ LANGUAGE SQL STABLE AS $$
  SELECT (date_trunc('day', (NOW() AT TIME ZONE p_tz)) + interval '1 day') AT TIME ZONE p_tz;
$$;
CREATE OR REPLACE FUNCTION fn_quota_get(p_user_id UUID)
RETURNS TABLE(used_today INT, daily_limit INT, reset_at TIMESTAMPTZ) LANGUAGE plpgsql STABLE AS $$
DECLARE v_plan plan_type; v_tz TEXT; v_date DATE; BEGIN
  SELECT plan,time_zone INTO v_plan,v_tz FROM users WHERE id=p_user_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'User not found'; END IF;
  v_date := (NOW() AT TIME ZONE v_tz)::DATE;
  daily_limit := fn_plan_daily_limit(v_plan);
  SELECT q.used_count INTO used_today FROM quota_usages q WHERE q.user_id=p_user_id AND q.local_date=v_date;
  used_today := COALESCE(used_today,0);
  reset_at := fn_reset_at_local_midnight(v_tz);
  RETURN NEXT;
END $$;
CREATE OR REPLACE FUNCTION fn_quota_try_consume(p_user_id UUID, p_reason TEXT DEFAULT 'ask')
RETURNS TABLE(ok BOOLEAN, used_today INT, daily_limit INT, reset_at TIMESTAMPTZ) LANGUAGE plpgsql VOLATILE AS $$
DECLARE v_plan plan_type; v_tz TEXT; v_date DATE; v_limit INT; v_rows INT; BEGIN
  SELECT plan,time_zone INTO v_plan,v_tz FROM users WHERE id=p_user_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'User not found'; END IF;
  v_limit := fn_plan_daily_limit(v_plan);
  v_date  := (NOW() AT TIME ZONE v_tz)::DATE;
  reset_at := fn_reset_at_local_midnight(v_tz);
  daily_limit := v_limit;
  IF v_limit >= 2147483647 THEN
    SELECT used_count INTO used_today FROM quota_usages WHERE user_id=p_user_id AND local_date=v_date;
    used_today := COALESCE(used_today,0); ok := TRUE; RETURN NEXT;
  END IF;
  INSERT INTO quota_usages(user_id, local_date, used_count) VALUES (p_user_id, v_date, 0)
  ON CONFLICT (user_id, local_date) DO NOTHING;
  UPDATE quota_usages SET used_count = used_count + 1
   WHERE user_id=p_user_id AND local_date=v_date AND used_count < v_limit;
  GET DIAGNOSTICS v_rows = ROW_COUNT;
  IF v_rows = 0 THEN
    SELECT used_count INTO used_today FROM quota_usages WHERE user_id=p_user_id AND local_date=v_date;
    used_today := COALESCE(used_today, v_limit); ok := FALSE; RETURN NEXT;
  ELSE
    SELECT used_count INTO used_today FROM quota_usages WHERE user_id=p_user_id AND local_date=v_date;
    ok := TRUE; RETURN NEXT;
  END IF;
END $$;

CREATE OR REPLACE FUNCTION fn_mask_secret(s TEXT) RETURNS TEXT LANGUAGE SQL IMMUTABLE AS $$
  SELECT CASE WHEN s IS NULL THEN NULL WHEN length(s) <= 8 THEN '****' ELSE substring(s,1,4) || '****' || substring(s from length(s)-3) END;
$$;

-- API keys
CREATE TABLE IF NOT EXISTS api_key_secrets (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider           TEXT NOT NULL DEFAULT 'openai',
  name               TEXT NOT NULL DEFAULT 'default',
  encrypted_value    TEXT NOT NULL,
  created_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (provider, name)
);
CREATE TRIGGER trg_api_key_secrets_audit AFTER INSERT OR UPDATE OR DELETE ON api_key_secrets FOR EACH ROW EXECUTE FUNCTION trg_audit_dml();

-- Tasks
CREATE TABLE IF NOT EXISTS tasks (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  patient_id    UUID REFERENCES patients(id) ON DELETE SET NULL,
  title         TEXT NOT NULL,
  due_at        TIMESTAMPTZ NOT NULL,
  notes         TEXT,
  category      TEXT CHECK (category IN ('medication','exercise','appointment','safety','other')),
  is_done       BOOLEAN NOT NULL DEFAULT FALSE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS ix_tasks_owner_due ON tasks(owner_user_id, due_at);
CREATE TRIGGER trg_tasks_updated BEFORE UPDATE ON tasks FOR EACH ROW EXECUTE FUNCTION trg_set_updated_at();
CREATE TRIGGER trg_tasks_audit AFTER INSERT OR UPDATE OR DELETE ON tasks FOR EACH ROW EXECUTE FUNCTION trg_audit_dml();

-- Care circle / share helpers
CREATE OR REPLACE FUNCTION fn_create_care_circle(p_actor UUID, p_name TEXT) RETURNS UUID LANGUAGE plpgsql VOLATILE AS $$
DECLARE v_id UUID; BEGIN
  INSERT INTO care_circles(name, owner_user_id) VALUES (p_name, p_actor) RETURNING id INTO v_id;
  INSERT INTO care_circle_members(care_circle_id, user_id, role) VALUES (v_id, p_actor, 'admin');
  RETURN v_id;
END $$;
CREATE OR REPLACE FUNCTION fn_is_circle_admin(p_actor UUID, p_circle UUID) RETURNS BOOLEAN LANGUAGE SQL STABLE AS $$
  SELECT EXISTS (
    SELECT 1 FROM care_circles c
    WHERE c.id = p_circle AND (c.owner_user_id = p_actor
      OR EXISTS (SELECT 1 FROM care_circle_members m WHERE m.care_circle_id=p_circle AND m.user_id=p_actor AND m.role='admin'))
  );
$$;
CREATE OR REPLACE FUNCTION fn_circle_add_member(p_actor UUID, p_circle UUID, p_user UUID, p_role care_role_type DEFAULT 'member')
RETURNS BOOLEAN LANGUAGE plpgsql VOLATILE AS $$
BEGIN
  IF NOT fn_is_circle_admin(p_actor, p_circle) THEN RAISE EXCEPTION 'Forbidden'; END IF;
  INSERT INTO care_circle_members(care_circle_id,user_id,role) VALUES (p_circle,p_user,p_role)
  ON CONFLICT (care_circle_id,user_id) DO UPDATE SET role=EXCLUDED.role;
  RETURN TRUE;
END $$;
CREATE OR REPLACE FUNCTION fn_circle_remove_member(p_actor UUID, p_circle UUID, p_user UUID)
RETURNS BOOLEAN LANGUAGE plpgsql VOLATILE AS $$
BEGIN
  IF NOT fn_is_circle_admin(p_actor, p_circle) THEN RAISE EXCEPTION 'Forbidden'; END IF;
  DELETE FROM care_circle_members WHERE care_circle_id=p_circle AND user_id=p_user; RETURN TRUE;
END $$;
CREATE OR REPLACE FUNCTION fn_conversation_share(p_actor UUID, p_conversation UUID, p_to_user UUID, p_to_email CITEXT, p_redact BOOLEAN, p_expires TIMESTAMPTZ)
RETURNS UUID LANGUAGE plpgsql VOLATILE AS $$
DECLARE v_owner UUID; v_id UUID; BEGIN
  SELECT owner_user_id INTO v_owner FROM conversations WHERE id=p_conversation; IF NOT FOUND THEN RAISE EXCEPTION 'Not found'; END IF;
  IF v_owner <> p_actor THEN RAISE EXCEPTION 'Forbidden'; END IF;
  INSERT INTO share_grants(conversation_id,to_user_id,to_email,redact_pii,expires_at)
  VALUES (p_conversation,p_to_user,p_to_email,COALESCE(p_redact,TRUE),p_expires) RETURNING id INTO v_id;
  UPDATE conversations SET is_shared=TRUE WHERE id=p_conversation; RETURN v_id;
END $$;
CREATE OR REPLACE FUNCTION fn_conversation_revoke_share(p_actor UUID, p_share_id UUID)
RETURNS BOOLEAN LANGUAGE plpgsql VOLATILE AS $$
DECLARE v_conv UUID; v_owner UUID; BEGIN
  SELECT conversation_id INTO v_conv FROM share_grants WHERE id=p_share_id; IF NOT FOUND THEN RETURN FALSE; END IF;
  SELECT owner_user_id INTO v_owner FROM conversations WHERE id=v_conv; IF v_owner <> p_actor THEN RAISE EXCEPTION 'Forbidden'; END IF;
  UPDATE share_grants SET revoked_at=NOW() WHERE id=p_share_id AND revoked_at IS NULL;
  UPDATE conversations SET is_shared = EXISTS(SELECT 1 FROM share_grants WHERE conversation_id=v_conv AND revoked_at IS NULL) WHERE id=v_conv;
  RETURN TRUE;
END $$;

-- OTP: PHONE
CREATE TABLE IF NOT EXISTS phone_otp (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone_e164  TEXT NOT NULL,
  purpose     TEXT NOT NULL DEFAULT 'login' CHECK (purpose IN ('login','bind','reset')),
  code_hash   BYTEA NOT NULL,
  code_salt   BYTEA NOT NULL,
  attempts    INT   NOT NULL DEFAULT 0,
  expires_at  TIMESTAMPTZ NOT NULL DEFAULT (NOW() + interval '5 minutes'),
  consumed_at TIMESTAMPTZ,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_ip  INET,
  user_agent  TEXT
);
CREATE INDEX IF NOT EXISTS ix_phone_otp_active ON phone_otp(phone_e164) WHERE consumed_at IS NULL;
CREATE INDEX IF NOT EXISTS ix_phone_otp_expires ON phone_otp(expires_at);

CREATE OR REPLACE FUNCTION fn_gen_otp_code(p_digits INT DEFAULT 6) RETURNS TEXT LANGUAGE plpgsql VOLATILE AS $$
DECLARE n INT; BEGIN
  IF p_digits < 4 OR p_digits > 10 THEN p_digits := 6; END IF;
  n := floor(random() * (10^p_digits))::INT;
  RETURN to_char(n, 'FM' || rpad('0', p_digits, '0'));
END $$;

CREATE OR REPLACE FUNCTION fn_phone_otp_create(p_phone TEXT, p_purpose TEXT DEFAULT 'login', p_ttl_seconds INT DEFAULT 300, p_default_cc TEXT DEFAULT NULL, p_ip INET DEFAULT NULL, p_ua TEXT DEFAULT NULL)
RETURNS TABLE(otp_id UUID, phone_e164 TEXT, code_plain TEXT, expires_at TIMESTAMPTZ) LANGUAGE plpgsql VOLATILE AS $$
DECLARE v_phone TEXT; v_code TEXT; v_salt BYTEA; v_hash BYTEA; BEGIN
  v_phone := fn_phone_normalize(p_phone, p_default_cc);
  IF v_phone IS NULL THEN RAISE EXCEPTION 'Invalid phone'; END IF;
  v_code := fn_gen_otp_code(6);
  v_salt := gen_random_bytes(16);
  v_hash := digest(v_code || v_salt, 'sha256');
  INSERT INTO phone_otp(phone_e164,purpose,code_hash,code_salt,expires_at,created_ip,user_agent)
  VALUES (v_phone,p_purpose,v_hash,v_salt,NOW()+make_interval(secs=>p_ttl_seconds),p_ip,p_ua)
  RETURNING id,phone_e164,expires_at INTO otp_id,phone_e164,expires_at;
  code_plain := v_code; RETURN NEXT;
END $$;

CREATE OR REPLACE FUNCTION fn_phone_otp_verify(p_phone TEXT, p_code TEXT, p_purpose TEXT DEFAULT 'login', p_default_cc TEXT DEFAULT NULL, p_max_attempts INT DEFAULT 5)
RETURNS BOOLEAN LANGUAGE plpgsql VOLATILE AS $$
DECLARE v_phone TEXT; r RECORD; v_hash BYTEA; BEGIN
  v_phone := fn_phone_normalize(p_phone, p_default_cc);
  IF v_phone IS NULL THEN RETURN FALSE; END IF;
  SELECT * INTO r FROM phone_otp WHERE phone_e164=v_phone AND purpose=p_purpose AND consumed_at IS NULL AND expires_at>NOW()
  ORDER BY created_at DESC LIMIT 1;
  IF NOT FOUND THEN RETURN FALSE; END IF;
  IF r.attempts >= p_max_attempts THEN RETURN FALSE; END IF;
  v_hash := digest(p_code || r.code_salt, 'sha256');
  IF v_hash = r.code_hash THEN
    UPDATE phone_otp SET consumed_at=NOW() WHERE id=r.id; RETURN TRUE;
  ELSE
    UPDATE phone_otp SET attempts = attempts + 1 WHERE id=r.id; RETURN FALSE;
  END IF;
END $$;

-- OTP: EMAIL
CREATE TABLE IF NOT EXISTS email_otp (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email       CITEXT NOT NULL,
  purpose     TEXT NOT NULL DEFAULT 'login' CHECK (purpose IN ('login','bind','reset')),
  code_hash   BYTEA NOT NULL,
  code_salt   BYTEA NOT NULL,
  attempts    INT   NOT NULL DEFAULT 0,
  expires_at  TIMESTAMPTZ NOT NULL DEFAULT (NOW() + interval '10 minutes'),
  consumed_at TIMESTAMPTZ,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_ip  INET,
  user_agent  TEXT
);
CREATE INDEX IF NOT EXISTS ix_email_otp_active ON email_otp(email) WHERE consumed_at IS NULL;
CREATE INDEX IF NOT EXISTS ix_email_otp_expires ON email_otp(expires_at);

CREATE OR REPLACE FUNCTION fn_email_otp_create(p_email TEXT, p_purpose TEXT DEFAULT 'login', p_ttl_seconds INT DEFAULT 600, p_ip INET DEFAULT NULL, p_ua TEXT DEFAULT NULL)
RETURNS TABLE(otp_id UUID, email CITEXT, code_plain TEXT, expires_at TIMESTAMPTZ) LANGUAGE plpgsql VOLATILE AS $$
DECLARE v_email CITEXT; v_code TEXT; v_salt BYTEA; v_hash BYTEA; BEGIN
  v_email := fn_email_normalize(p_email);
  IF v_email IS NULL THEN RAISE EXCEPTION 'Invalid email'; END IF;
  v_code := fn_gen_otp_code(6);
  v_salt := gen_random_bytes(16);
  v_hash := digest(v_code || v_salt, 'sha256');
  INSERT INTO email_otp(email,purpose,code_hash,code_salt,expires_at,created_ip,user_agent)
  VALUES (v_email,p_purpose,v_hash,v_salt,NOW()+make_interval(secs=>p_ttl_seconds),p_ip,p_ua)
  RETURNING id,email,expires_at INTO otp_id,email,expires_at;
  code_plain := v_code; RETURN NEXT;
END $$;

CREATE OR REPLACE FUNCTION fn_email_otp_verify(p_email TEXT, p_code TEXT, p_purpose TEXT DEFAULT 'login', p_max_attempts INT DEFAULT 5)
RETURNS BOOLEAN LANGUAGE plpgsql VOLATILE AS $$
DECLARE v_email CITEXT; r RECORD; v_hash BYTEA; BEGIN
  v_email := fn_email_normalize(p_email);
  IF v_email IS NULL THEN RETURN FALSE; END IF;
  SELECT * INTO r FROM email_otp WHERE email=v_email AND purpose=p_purpose AND consumed_at IS NULL AND expires_at>NOW()
  ORDER BY created_at DESC LIMIT 1;
  IF NOT FOUND THEN RETURN FALSE; END IF;
  IF r.attempts >= p_max_attempts THEN RETURN FALSE; END IF;
  v_hash := digest(p_code || r.code_salt, 'sha256');
  IF v_hash = r.code_hash THEN
    UPDATE email_otp SET consumed_at=NOW() WHERE id=r.id; RETURN TRUE;
  ELSE
    UPDATE email_otp SET attempts = attempts + 1 WHERE id=r.id; RETURN FALSE;
  END IF;
END $$;

-- Convenience login/create helpers (idempotent)
CREATE OR REPLACE FUNCTION fn_phone_login_or_register(p_phone TEXT, p_name TEXT DEFAULT NULL, p_time_zone TEXT DEFAULT 'Asia/Tokyo', p_default_cc TEXT DEFAULT NULL)
RETURNS UUID LANGUAGE plpgsql VOLATILE AS $$
DECLARE v_phone TEXT; v_user UUID; v_verified BOOLEAN; BEGIN
  v_phone := fn_phone_normalize(p_phone, p_default_cc);
  IF v_phone IS NULL THEN RAISE EXCEPTION 'Invalid phone'; END IF;
  SELECT EXISTS(SELECT 1 FROM phone_otp WHERE phone_e164=v_phone AND consumed_at IS NOT NULL AND consumed_at > NOW()-interval '10 minutes') INTO v_verified;
  IF NOT v_verified THEN RAISE EXCEPTION 'OTP not verified or expired'; END IF;
  SELECT id INTO v_user FROM users WHERE phone_e164=v_phone AND deleted_at IS NULL;
  IF FOUND THEN RETURN v_user; END IF;
  INSERT INTO users(email,name,password_hash,role,plan,model_tier,time_zone,phone_e164)
  VALUES (NULL, COALESCE(p_name, v_phone), NULL, 'user','free','basic', p_time_zone, v_phone)
  RETURNING id INTO v_user; RETURN v_user;
END $$;

CREATE OR REPLACE FUNCTION fn_email_login_or_register(p_email TEXT, p_name TEXT DEFAULT NULL, p_time_zone TEXT DEFAULT 'Asia/Tokyo')
RETURNS UUID LANGUAGE plpgsql VOLATILE AS $$
DECLARE v_email CITEXT; v_user UUID; v_verified BOOLEAN; BEGIN
  v_email := fn_email_normalize(p_email);
  IF v_email IS NULL THEN RAISE EXCEPTION 'Invalid email'; END IF;
  SELECT EXISTS(SELECT 1 FROM email_otp WHERE email=v_email AND consumed_at IS NOT NULL AND consumed_at > NOW()-interval '10 minutes') INTO v_verified;
  IF NOT v_verified THEN RAISE EXCEPTION 'OTP not verified or expired'; END IF;
  SELECT id INTO v_user FROM users WHERE email=v_email AND deleted_at IS NULL;
  IF FOUND THEN RETURN v_user; END IF;
  INSERT INTO users(email,name,password_hash,role,plan,model_tier,time_zone,phone_e164)
  VALUES (v_email, COALESCE(p_name, split_part(v_email::text,'@',1)), NULL, 'user','free','basic', p_time_zone, NULL)
  RETURNING id INTO v_user; RETURN v_user;
END $$;

-- Grants (example)
-- CREATE ROLE health_api LOGIN PASSWORD '***';
-- GRANT USAGE ON SCHEMA health TO health_api;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA health TO health_api;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA health TO health_api;
-- ALTER DEFAULT PRIVILEGES IN SCHEMA health GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO health_api;
-- ALTER DEFAULT PRIVILEGES IN SCHEMA health GRANT USAGE, SELECT ON SEQUENCES TO health_api;
