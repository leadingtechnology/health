# health_api · RESTful API (.NET 8)

用于配合 Flutter 前端，提供：用户与配额、照护圈、OpenAI Chat 代理（服务端加密保存 API Key）、OTP 登录（邮箱/手机）等能力。

## 快速开始

```bash
cd apps/health_api
dotnet restore
export KEYRING_MASTER_KEY=$(openssl rand -base64 32)
dotnet run
# Swagger: http://localhost:5000/swagger
```

Windows PowerShell:

```powershell
setx KEYRING_MASTER_KEY ( [Convert]::ToBase64String((New-Object byte[] 32 | % {[void](New-Object System.Security.Cryptography.RNGCryptoServiceProvider).GetBytes($_)})) )
```

## 必要环境变量

- `KEYRING_MASTER_KEY`: 用于加密 OpenAI API Key（AES‑GCM）。
- `Jwt__SigningKey`: JWT HS256 密钥（32+ 字符）。
- 数据库：使用 PostgreSQL 连接串 `ConnectionStrings:DefaultConnection`。

## 主要接口

- 认证：`POST /api/auth/register`，`POST /api/auth/login`，`POST /api/auth/otp/send`，`POST /api/auth/otp/verify`
- 用户：`GET /api/users/me`，`GET /api/users/me/quota`
- OpenAI：`POST /api/openai/ask`（统一代理）
- 套餐：`GET /api/plans`（公开，价格与额度）
- 其他：照护圈/患者/会话共享等

## Plans API (/api/plans)

- Method: GET
- Auth: Public（无需 Token）
- Path: `/api/plans`
- Description: 返回 Free、Standard、Pro、Platinum 的月/年价格与额度，用于前端展示价格卡片。

Response (200): Array of PlanConfiguration
- plan: `free|standard|pro|platinum`
- name: 计划名称
- description: 简要介绍
- monthlyPrices: 货币=>单价（USD/JPY/KRW/TWD/CNY）
- yearlyPrices: 货币=>年费
- quotas: 对象，包含：
  - realtimeVoiceMinutesPerMonth / maxSessionMinutes / maxDailyVoiceMinutes
  - offlineSTTMinutesPerMonth / ttsMinutesPerMonth
  - textInputTokensPerMonth / textOutputTokensPerMonth
  - dailyTextQuestions / unlimitedTextQuestions
  - imageGenerationPerMonth / imageQuality
  - translationEnabled / realtimeTranslation / memoryPersistence
  - defaultModel / fallbackModel

Example（截取）：

[
  {
    "plan": "standard",
    "name": "Standard",
    "monthlyPrices": { "USD": 19, "JPY": 2900 },
    "yearlyPrices":  { "USD": 179, "JPY": 26800 },
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

© 2025 ldetch.co.jp  health_api

