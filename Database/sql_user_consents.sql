-- user_consents: APPI の同意記録テーブル（越境移転・要配慮情報・第三者提供など）
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 同意记录（版本化、可撤回）
CREATE TYPE consent_type AS ENUM (
  'privacy_notice_ack',
  'sensitive_processing',
  'cross_border_transfer',
  'third_party_share',
  'external_transmission_analytics',
  'external_transmission_crash',
  'marketing',
  'terms_accept',
  'tokusho_confirm'
);

CREATE TABLE IF NOT EXISTS user_consents (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type             consent_type NOT NULL,
  doc_key          TEXT NOT NULL,                 -- 例如 'privacy_policy_ja'
  doc_version      TEXT NOT NULL,                 -- 例如 '2025-09-06'
  content_sha256   TEXT NOT NULL,                 -- 当时文档摘要，便于举证
  accepted         BOOLEAN NOT NULL,              -- true=同意; false=拒绝/撤回
  legal_basis      TEXT NOT NULL DEFAULT 'consent',
  recipient        TEXT,                          -- 共享/跨境的接收方（如 OpenAI）
  recipient_country TEXT,                         -- 接收方所在国（如 'US'）
  method           TEXT NOT NULL DEFAULT 'in_app_checkbox',
  ip               INET,
  user_agent       TEXT,
  locale           TEXT,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  revoked_at       TIMESTAMPTZ
);

-- 保留“当前有效”的快捷唯一性（每种同意 1 条未撤回记录）
CREATE UNIQUE INDEX IF NOT EXISTS ux_user_consents_active
ON user_consents(user_id, type) WHERE revoked_at IS NULL AND accepted = true;

-- 第三者提供记录（APPI 记录义务，建议单表留存满3年）
CREATE TABLE IF NOT EXISTS third_party_provision_log (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  recipient_name   TEXT NOT NULL,
  recipient_address TEXT,
  recipient_country TEXT,
  categories       TEXT NOT NULL,                 -- 提供的信息类别
  method           TEXT NOT NULL DEFAULT 'electronic',
  provided_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
