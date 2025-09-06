
### 数据库

gcloud sql connect racketrallydb --user=postgres --database=postgres --project=ldtech
SHOW client_encoding;
\encoding UTF8
\set ON_ERROR_STOP on
\i D:/ldtech/health/health/Database/health_postgres.sql

### 数据库操作

\conninfo
\c health
\c postgres

CMD）psql -d postgres -U postgres

SET search_path TO health, public;
SHOW search_path;

### 创建数据库

CREATE DATABASE postgres;

SET app.env = 'dev';
\i D:/ldtech/health/health/Database/health_postgres.sql
\i D:/ldtech/health/health/Database/fix_citext_enable.sql
\i D:/ldtech/health/health/Database/migration_add_platinum_plan.sql
\i D:/ldtech/health/health/Database/add_multimedia_support.sql


### 1）查看数据库

SELECT datname FROM pg_database WHERE datistemplate = false;

---

## Plans API (/api/plans)

- Method: GET
- Auth: Public (no token required)
- Path: `/api/plans`
- Description: Returns all subscription plans (Free, Standard, Pro, Platinum) with monthly/yearly pricing and feature quotas.

Response (200): Array of PlanConfiguration
- plan: `free|standard|pro|platinum`
- name: Display name
- description: Short description
- monthlyPrices: Map of currency => price (e.g., USD/JPY/KRW/TWD/CNY)
- yearlyPrices: Map of currency => price (same keys as monthly)
- quotas: Object
  - realtimeVoiceMinutesPerMonth
  - maxSessionMinutes
  - maxDailyVoiceMinutes
  - offlineSTTMinutesPerMonth
  - ttsMinutesPerMonth
  - textInputTokensPerMonth
  - textOutputTokensPerMonth
  - dailyTextQuestions
  - unlimitedTextQuestions
  - imageGenerationPerMonth
  - imageQuality
  - translationEnabled
  - realtimeTranslation
  - memoryPersistence
  - defaultModel
  - fallbackModel

Example (truncated):

[
  {
    "plan": "standard",
    "name": "Standard",
    "monthlyPrices": { "USD": 19, "JPY": 2900 },
    "yearlyPrices": { "USD": 179, "JPY": 26800 },
    "quotas": {
      "textInputTokensPerMonth": 5000000,
      "textOutputTokensPerMonth": 400000,
      "ttsMinutesPerMonth": 60,
      "imageGenerationPerMonth": 40,
      "translationEnabled": true,
      "memoryPersistence": true,
      "defaultModel": "gpt-4o-mini"
    }
  }
]
