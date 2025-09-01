
-- ============================================================
-- LDETCH Health - PostgreSQL Schema (Cloud SQL ready)
-- Database: PostgreSQL 13+ (Cloud SQL for GCP)
-- Schema: health
-- Author: ChatGPT (GPT-5 Pro)
-- Date: 2025-09-01
-- ============================================================

-- Extensions (run as a superuser / cloudsqlsuperuser)
CREATE EXTENSION IF NOT EXISTS pgcrypto;   -- gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS citext;     -- case-insensitive email
CREATE EXTENSION IF NOT EXISTS pg_trgm;    -- trigram search
CREATE EXTENSION IF NOT EXISTS btree_gin;  -- btree operators for GIN

-- Application schema
CREATE SCHEMA IF NOT EXISTS health;
SET search_path = health, public;

-- ============================================================
-- Enum types
-- ============================================================
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'plan_type') THEN
        CREATE TYPE plan_type AS ENUM ('free','standard','pro');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'model_tier') THEN
        CREATE TYPE model_tier AS ENUM ('basic','enhanced','realtime');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'care_role_type') THEN
        CREATE TYPE care_role_type AS ENUM ('member','caregiver','doctor','admin');
    END IF;
END $$;

-- ============================================================
-- Helper: updated_at trigger
-- ============================================================
CREATE OR REPLACE FUNCTION trg_set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at := NOW();
  RETURN NEW;
END $$;

-- ============================================================
-- Helper: audit log (generic). Use app.current_user for actor id.
-- ============================================================
CREATE TABLE IF NOT EXISTS audit_log (
  id              BIGSERIAL PRIMARY KEY,
  table_name      TEXT NOT NULL,
  action          TEXT NOT NULL CHECK (action IN ('INSERT','UPDATE','DELETE')),
  actor_user_id   UUID,
  row_pk_text     TEXT,
  old_data        JSONB,
  new_data        JSONB,
  occurred_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION trg_audit_dml()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
  v_actor TEXT;
  v_pk TEXT;
BEGIN
  v_actor := current_setting('app.user_id', true);
  IF TG_OP = 'INSERT' THEN
    v_pk := COALESCE(NEW.id::TEXT, NULL);
    INSERT INTO audit_log(table_name, action, actor_user_id, row_pk_text, old_data, new_data)
    VALUES (TG_TABLE_NAME, TG_OP, NULLIF(v_actor,'')::UUID, v_pk, NULL, to_jsonb(NEW));
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    v_pk := COALESCE(NEW.id::TEXT, NULL);
    INSERT INTO audit_log(table_name, action, actor_user_id, row_pk_text, old_data, new_data)
    VALUES (TG_TABLE_NAME, TG_OP, NULLIF(v_actor,'')::UUID, v_pk, to_jsonb(OLD), to_jsonb(NEW));
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    v_pk := COALESCE(OLD.id::TEXT, NULL);
    INSERT INTO audit_log(table_name, action, actor_user_id, row_pk_text, old_data, new_data)
    VALUES (TG_TABLE_NAME, TG_OP, NULLIF(v_actor,'')::UUID, v_pk, to_jsonb(OLD), NULL);
    RETURN OLD;
  END IF;
  RETURN NULL;
END $$;

-- ============================================================
-- Users
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email           CITEXT NOT NULL,
  name            TEXT   NOT NULL,
  password_hash   TEXT   NOT NULL,
  role            TEXT   NOT NULL DEFAULT 'user' CHECK (role IN ('user','admin')),
  plan            plan_type   NOT NULL DEFAULT 'free',
  model_tier      model_tier  NOT NULL DEFAULT 'basic',
  time_zone       TEXT NOT NULL DEFAULT 'Asia/Tokyo', -- 用户本地时区（配额重置用）
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at      TIMESTAMPTZ
);
-- 唯一邮箱（仅未删除账户）
CREATE UNIQUE INDEX IF NOT EXISTS ux_users_email_active
ON users (email) WHERE deleted_at IS NULL;

CREATE TRIGGER trg_users_updated BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION trg_set_updated_at();
CREATE TRIGGER trg_users_audit AFTER INSERT OR UPDATE OR DELETE ON users
FOR EACH ROW EXECUTE FUNCTION trg_audit_dml();

-- ============================================================
-- Care circles (family/caregiver) & members
-- ============================================================
CREATE TABLE IF NOT EXISTS care_circles (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name            TEXT NOT NULL,
  owner_user_id   UUID NOT NULL REFERENCES users(id),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TRIGGER trg_care_circles_updated BEFORE UPDATE ON care_circles
FOR EACH ROW EXECUTE FUNCTION trg_set_updated_at();
CREATE TRIGGER trg_care_circles_audit AFTER INSERT OR UPDATE OR DELETE ON care_circles
FOR EACH ROW EXECUTE FUNCTION trg_audit_dml();

CREATE TABLE IF NOT EXISTS care_circle_members (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  care_circle_id  UUID NOT NULL REFERENCES care_circles(id) ON DELETE CASCADE,
  user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role            care_role_type NOT NULL DEFAULT 'member',
  added_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (care_circle_id, user_id)
);
CREATE INDEX IF NOT EXISTS ix_cc_members_user ON care_circle_members(user_id);
CREATE TRIGGER trg_cc_members_audit AFTER INSERT OR UPDATE OR DELETE ON care_circle_members
FOR EACH ROW EXECUTE FUNCTION trg_audit_dml();

-- ============================================================
-- Patients
-- ============================================================
CREATE TABLE IF NOT EXISTS patients (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name                TEXT NOT NULL,
  birth_date          DATE,
  gender              TEXT,
  conditions          TEXT,
  allergies           TEXT,
  emergency_contact   TEXT,
  primary_circle_id   UUID REFERENCES care_circles(id) ON DELETE SET NULL,
  created_by_user_id  UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS ix_patients_primary_circle ON patients(primary_circle_id);
CREATE TRIGGER trg_patients_updated BEFORE UPDATE ON patients
FOR EACH ROW EXECUTE FUNCTION trg_set_updated_at();
CREATE TRIGGER trg_patients_audit AFTER INSERT OR UPDATE OR DELETE ON patients
FOR EACH ROW EXECUTE FUNCTION trg_audit_dml();

-- ============================================================
-- Conversations (visit summaries / chats)
-- ============================================================
CREATE TABLE IF NOT EXISTS conversations (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title           TEXT NOT NULL,
  patient_id      UUID NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  owner_user_id   UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  summary_text    TEXT NOT NULL DEFAULT '',
  is_shared       BOOLEAN NOT NULL DEFAULT FALSE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  -- 简易搜索字段（中日文本建议配合 pg_trgm）
  tsv             tsvector GENERATED ALWAYS AS (
                     to_tsvector('simple', coalesce(title,'') || ' ' || coalesce(summary_text,''))
                   ) STORED
);
CREATE INDEX IF NOT EXISTS ix_conv_patient ON conversations(patient_id);
CREATE INDEX IF NOT EXISTS ix_conv_owner ON conversations(owner_user_id);
CREATE INDEX IF NOT EXISTS ix_conv_tsv ON conversations USING GIN (tsv);
CREATE INDEX IF NOT EXISTS ix_conv_summary_trgm ON conversations USING GIN (summary_text gin_trgm_ops);
CREATE TRIGGER trg_conversations_updated BEFORE UPDATE ON conversations
FOR EACH ROW EXECUTE FUNCTION trg_set_updated_at();
CREATE TRIGGER trg_conversations_audit AFTER INSERT OR UPDATE OR DELETE ON conversations
FOR EACH ROW EXECUTE FUNCTION trg_audit_dml();

-- ============================================================
-- Share grants (per-conversation, revocable, optional expiry)
-- ============================================================
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
CREATE TRIGGER trg_share_grants_audit AFTER INSERT OR UPDATE OR DELETE ON share_grants
FOR EACH ROW EXECUTE FUNCTION trg_audit_dml();

-- ============================================================
-- Quota usage (per-user per-local-date)
-- ============================================================
CREATE TABLE IF NOT EXISTS quota_usages (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  local_date      DATE NOT NULL,
  used_count      INT  NOT NULL DEFAULT 0,
  UNIQUE (user_id, local_date)
);
CREATE INDEX IF NOT EXISTS ix_quota_user_date ON quota_usages(user_id, local_date);

-- ============================================================
-- API key storage (encrypted at app level)
-- ============================================================
CREATE TABLE IF NOT EXISTS api_key_secrets (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider            TEXT NOT NULL DEFAULT 'openai',
  name                TEXT NOT NULL DEFAULT 'default',
  encrypted_value     TEXT NOT NULL,  -- AES-GCM blob (Base64) from app layer
  created_by_user_id  UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (provider, name)
);
CREATE TRIGGER trg_api_key_secrets_audit AFTER INSERT OR UPDATE OR DELETE ON api_key_secrets
FOR EACH ROW EXECUTE FUNCTION trg_audit_dml();

-- ============================================================
-- Optional: tasks (support "设为任务/提醒") - can be used by future API
-- ============================================================
CREATE TABLE IF NOT EXISTS tasks (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_user_id   UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  patient_id      UUID REFERENCES patients(id) ON DELETE SET NULL,
  title           TEXT NOT NULL,
  due_at          TIMESTAMPTZ NOT NULL,
  notes           TEXT,
  category        TEXT CHECK (category IN ('medication','exercise','appointment','safety','other')),
  is_done         BOOLEAN NOT NULL DEFAULT FALSE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS ix_tasks_owner_due ON tasks(owner_user_id, due_at);
CREATE TRIGGER trg_tasks_updated BEFORE UPDATE ON tasks
FOR EACH ROW EXECUTE FUNCTION trg_set_updated_at();
CREATE TRIGGER trg_tasks_audit AFTER INSERT OR UPDATE OR DELETE ON tasks
FOR EACH ROW EXECUTE FUNCTION trg_audit_dml();

-- ============================================================
-- Functions: utility
-- ============================================================

-- Return plan daily limit (INT_MAX for unlimited*)
CREATE OR REPLACE FUNCTION fn_plan_daily_limit(p plan_type)
RETURNS INT LANGUAGE SQL IMMUTABLE AS $$
  SELECT CASE p WHEN 'free' THEN 3 ELSE 2147483647 END;
$$;

-- Return local midnight reset time given tz
CREATE OR REPLACE FUNCTION fn_reset_at_local_midnight(p_tz TEXT)
RETURNS TIMESTAMPTZ LANGUAGE SQL STABLE AS $$
  SELECT (date_trunc('day', (NOW() AT TIME ZONE p_tz)) + interval '1 day') AT TIME ZONE p_tz;
$$;

-- Get quota snapshot for a user
CREATE OR REPLACE FUNCTION fn_quota_get(p_user_id UUID)
RETURNS TABLE(used_today INT, daily_limit INT, reset_at TIMESTAMPTZ) LANGUAGE plpgsql STABLE AS $$
DECLARE
  v_plan plan_type;
  v_tz   TEXT;
  v_date DATE;
BEGIN
  SELECT plan, time_zone INTO v_plan, v_tz FROM users WHERE id = p_user_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'User not found'; END IF;
  v_date := (NOW() AT TIME ZONE v_tz)::DATE;
  daily_limit := fn_plan_daily_limit(v_plan);
  SELECT q.used_count INTO used_today FROM quota_usages q WHERE q.user_id = p_user_id AND q.local_date = v_date;
  used_today := COALESCE(used_today, 0);
  reset_at := fn_reset_at_local_midnight(v_tz);
  RETURN NEXT;
END $$;

-- Try consume 1 unit for today (atomic). Returns ok flag + snapshot.
CREATE OR REPLACE FUNCTION fn_quota_try_consume(p_user_id UUID, p_reason TEXT DEFAULT 'ask')
RETURNS TABLE(ok BOOLEAN, used_today INT, daily_limit INT, reset_at TIMESTAMPTZ)
LANGUAGE plpgsql VOLATILE AS $$
DECLARE
  v_plan plan_type;
  v_tz   TEXT;
  v_date DATE;
  v_limit INT;
  v_used INT;
BEGIN
  SELECT plan, time_zone INTO v_plan, v_tz FROM users WHERE id = p_user_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'User not found'; END IF;
  v_limit := fn_plan_daily_limit(v_plan);
  v_date := (NOW() AT TIME ZONE v_tz)::DATE;
  reset_at := fn_reset_at_local_midnight(v_tz);
  daily_limit := v_limit;

  IF v_limit >= 2147483647 THEN
    -- Unlimited* plans: do not count, always ok
    SELECT used_count INTO v_used FROM quota_usages WHERE user_id = p_user_id AND local_date = v_date;
    used_today := COALESCE(v_used, 0);
    ok := TRUE;
    RETURN NEXT;
  END IF;

  -- Ensure row exists
  INSERT INTO quota_usages(user_id, local_date, used_count)
  VALUES (p_user_id, v_date, 0)
  ON CONFLICT (user_id, local_date) DO NOTHING;

  -- Atomic increment if under limit
  UPDATE quota_usages
     SET used_count = used_count + 1
   WHERE user_id = p_user_id
     AND local_date = v_date
     AND used_count < v_limit;

  GET DIAGNOSTICS v_used = ROW_COUNT;
  IF v_used = 0 THEN
    -- No row updated => quota reached
    SELECT used_count INTO v_used FROM quota_usages WHERE user_id = p_user_id AND local_date = v_date;
    used_today := COALESCE(v_used, v_limit);
    ok := FALSE;
    RETURN NEXT;
  ELSE
    SELECT used_count INTO v_used FROM quota_usages WHERE user_id = p_user_id AND local_date = v_date;
    used_today := v_used;
    ok := TRUE;
    RETURN NEXT;
  END IF;
END $$;

-- Mask a secret (for UI)
CREATE OR REPLACE FUNCTION fn_mask_secret(s TEXT)
RETURNS TEXT LANGUAGE SQL IMMUTABLE AS $$
  SELECT CASE WHEN s IS NULL THEN NULL
              WHEN length(s) <= 8 THEN '****'
              ELSE substring(s,1,4) || '****' || substring(s from length(s)-3) END;
$$;

-- ============================================================
-- Procedures for circles/members with basic authorization
-- Note: pass actor_user_id from app layer; DB checks ownership/admin role.
-- ============================================================

-- Create a care circle
CREATE OR REPLACE FUNCTION fn_create_care_circle(p_actor UUID, p_name TEXT)
RETURNS UUID LANGUAGE plpgsql VOLATILE AS $$
DECLARE
  v_id UUID;
BEGIN
  INSERT INTO care_circles(name, owner_user_id) VALUES (p_name, p_actor) RETURNING id INTO v_id;
  INSERT INTO care_circle_members(care_circle_id, user_id, role) VALUES (v_id, p_actor, 'admin');
  RETURN v_id;
END $$;

-- Is actor admin of circle?
CREATE OR REPLACE FUNCTION fn_is_circle_admin(p_actor UUID, p_circle UUID)
RETURNS BOOLEAN LANGUAGE SQL STABLE AS $$
  SELECT EXISTS (
    SELECT 1 FROM care_circles c
    WHERE c.id = p_circle AND (c.owner_user_id = p_actor
           OR EXISTS (SELECT 1 FROM care_circle_members m WHERE m.care_circle_id = p_circle AND m.user_id = p_actor AND m.role = 'admin'))
  );
$$;

-- Add member (requires admin)
CREATE OR REPLACE FUNCTION fn_circle_add_member(p_actor UUID, p_circle UUID, p_user UUID, p_role care_role_type DEFAULT 'member')
RETURNS BOOLEAN LANGUAGE plpgsql VOLATILE AS $$
BEGIN
  IF NOT fn_is_circle_admin(p_actor, p_circle) THEN
    RAISE EXCEPTION 'Forbidden: actor is not admin of circle %', p_circle;
  END IF;
  INSERT INTO care_circle_members(care_circle_id, user_id, role) VALUES (p_circle, p_user, p_role)
  ON CONFLICT (care_circle_id, user_id) DO UPDATE SET role = EXCLUDED.role;
  RETURN TRUE;
END $$;

-- Remove member (requires admin)
CREATE OR REPLACE FUNCTION fn_circle_remove_member(p_actor UUID, p_circle UUID, p_user UUID)
RETURNS BOOLEAN LANGUAGE plpgsql VOLATILE AS $$
BEGIN
  IF NOT fn_is_circle_admin(p_actor, p_circle) THEN
    RAISE EXCEPTION 'Forbidden: actor is not admin of circle %', p_circle;
  END IF;
  DELETE FROM care_circle_members WHERE care_circle_id = p_circle AND user_id = p_user;
  RETURN TRUE;
END $$;

-- Share a conversation (requires owner)
CREATE OR REPLACE FUNCTION fn_conversation_share(p_actor UUID, p_conversation UUID, p_to_user UUID, p_to_email CITEXT, p_redact BOOLEAN, p_expires TIMESTAMPTZ)
RETURNS UUID LANGUAGE plpgsql VOLATILE AS $$
DECLARE
  v_owner UUID;
  v_id UUID;
BEGIN
  SELECT owner_user_id INTO v_owner FROM conversations WHERE id = p_conversation;
  IF NOT FOUND THEN RAISE EXCEPTION 'Conversation not found'; END IF;
  IF v_owner <> p_actor THEN
    RAISE EXCEPTION 'Forbidden: only owner can share conversation';
  END IF;

  INSERT INTO share_grants(conversation_id, to_user_id, to_email, redact_pii, expires_at)
  VALUES (p_conversation, p_to_user, p_to_email, COALESCE(p_redact, TRUE), p_expires)
  RETURNING id INTO v_id;

  UPDATE conversations SET is_shared = TRUE WHERE id = p_conversation;
  RETURN v_id;
END $$;

-- Revoke share
CREATE OR REPLACE FUNCTION fn_conversation_revoke_share(p_actor UUID, p_share_id UUID)
RETURNS BOOLEAN LANGUAGE plpgsql VOLATILE AS $$
DECLARE
  v_conv UUID;
  v_owner UUID;
BEGIN
  SELECT conversation_id INTO v_conv FROM share_grants WHERE id = p_share_id;
  IF NOT FOUND THEN RETURN FALSE; END IF;
  SELECT owner_user_id INTO v_owner FROM conversations WHERE id = v_conv;
  IF v_owner <> p_actor THEN
    RAISE EXCEPTION 'Forbidden: only owner can revoke share';
  END IF;
  UPDATE share_grants SET revoked_at = NOW() WHERE id = p_share_id AND revoked_at IS NULL;
  -- optional: if no more active grants, mark conversation as not shared
  UPDATE conversations SET is_shared = EXISTS(SELECT 1 FROM share_grants WHERE conversation_id = v_conv AND revoked_at IS NULL) WHERE id = v_conv;
  RETURN TRUE;
END $$;

-- ============================================================
-- Grants (example role for application)
-- ============================================================
-- CREATE ROLE health_api LOGIN PASSWORD '***';         -- set in Cloud SQL
-- GRANT USAGE ON SCHEMA health TO health_api;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA health TO health_api;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA health TO health_api;
-- ALTER DEFAULT PRIVILEGES IN SCHEMA health GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO health_api;
-- ALTER DEFAULT PRIVILEGES IN SCHEMA health GRANT USAGE, SELECT ON SEQUENCES TO health_api;

-- ============================================================
-- End of schema
-- ============================================================
