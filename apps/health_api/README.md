# health_api —— RESTful 后端（.NET 8）

域名：**ldetch.co.jp**（用于 CORS 与默认 Issuer/Audience）

本工程为你的 Flutter 前端提供：**家族（照护圈）互通、用户与配额、OpenAI API Key 安全保存、代理调用 Chat Completions** 等能力。

## 功能要点

- 用户注册/登录（JWT）
- **免费每日 3 问**的配额（服务端可信计数；Standard/Pro 视为无限*）
- 照护圈（CareCircle）与成员管理
- 患者档案、会话记录与共享授权（ShareGrant）
- **OpenAI API Key 加密保存（AES‑GCM）**，仅管理员可设/查（仅掩码）
- 统一的 **/api/openai/ask** 代理到 OpenAI Chat Completions（使用已保存的 Key 与模型）
- CORS 允许：`https://app.ldetch.co.jp`、本地 `localhost` 端口
- Swagger（/swagger）便于调试

## 快速开始（开发）

```bash
cd health_api
dotnet restore
# 生成 32 字节主密钥（AES-GCM），生产请存放在安全位置
export KEYRING_MASTER_KEY=$(openssl rand -base64 32)

# 开发启动（默认 SQLite ./data/health.db）
dotnet run
# 打开 http://localhost:5000/swagger
```

> Windows PowerShell:
>
> ```powershell
> setx KEYRING_MASTER_KEY ( [Convert]::ToBase64String((New-Object byte[] 32 | % {[void](New-Object System.Security.Cryptography.RNGCryptoServiceProvider).GetBytes($_)})) )
> ```

## 必要环境变量

- `KEYRING_MASTER_KEY`：**必须**。Base64 的 32 字节密钥，用于对 API Key 等敏感数据进行 AES‑GCM 加密。  
- `Jwt__SigningKey`：JWT HS256 签名秘钥（建议 ≥ 32 个字符）。  
- 可选：`ConnectionStrings__Default`（默认 `Data Source=./data/health.db`）、`OpenAI__DefaultModel`、`Cors__AllowedOrigins:0..n`。

## 典型调用流程

1. **注册登录**
   - `POST /api/auth/register` → 返回 `accessToken`（Bearer）  
   - `POST /api/auth/login` → 返回 `accessToken`
2. **管理员设置 OpenAI Key**
   - 将某用户 `role` 设为 `admin`（临时：可在数据库中把该用户 Role 改为 'admin'）
   - `POST /api/orgsettings/openai` Body: `{ "keyName":"default","apiKeyPlain":"sk-..." }`
   - `GET  /api/orgsettings/openai` → `{ configured:true, masked:"sk-....****...." }`
3. **前端扣额→提问**
   - `GET /api/users/me/quota` → 显示“今日剩余 x/3”  
   - `POST /api/openai/ask` Body: `{ "prompt":"给我 10 分钟睡前放松", "model":"gpt-4o-mini" }`  
     服务器端会先扣额（Free），再调用 OpenAI，返回 `replyText`。

## 主要端点（节选）

- `POST /api/auth/register`、`POST /api/auth/login`
- `GET /api/users/me`、`GET /api/users/me/quota`
- `GET /api/circles`、`POST /api/circles`、`POST /api/circles/{id}/members`、`DELETE /api/circles/{id}/members/{userId}`
- `GET /api/patients`、`POST /api/patients`
- `GET /api/conversations?patientId=`、`POST /api/conversations`
- `POST /api/conversations/share`（逐会话共享，支持到期）
- `GET /api/orgsettings/openai`、`POST /api/orgsettings/openai`（管理员）
- `POST /api/openai/ask`（统一代理）

## 生产建议

- 切换到 **PostgreSQL**：把 `ConnectionStrings__Default` 改为 `Host=...;Database=...;Username=...;Password=...` 并使用 Npgsql Provider；替换 `UseSqlite` → `UseNpgsql`。
- 将 `EnsureCreated()` 替换为 **EF Core Migration**：`dotnet tool install --global dotnet-ef` → 建立迁移并 `db.Database.Migrate()`。
- 把 KEYRING_MASTER_KEY 存入 **KMS/KeyVault**；开启 **HTTPS**、**反向代理** 与 **WAF**。
- 接入 **App Store Server Notifications** 与 **Google Play RTDN** 同步订阅状态，统一“权益表”。
- 如需 **Realtime 语音**代理，建议单独用 WebSocket 服务（可用 .NET 的 YARP/WebSockets 或沿用你已有的 Node 代理）。

## CORS 与域名

已允许：`https://app.ldetch.co.jp`、`https://ldetch.co.jp` 和常见本地端口。你可在 `appsettings.json` 的 `Cors.AllowedOrigins` 中增删。

---

## 邮件与验证码

  2. 开发环境的处理：

- 在开发环境下，验证码直接返回给前端（方便测试）
- 生产环境下，验证码不返回，但也没有实际发送邮件

  需要添加的邮件配置：

  通常需要在 appsettings.json 中添加SMTP配置，例如：

  "Email": {
    "Smtp": {
      "Host": "smtp.gmail.com",  // 或其他邮件服务商
      "Port": 587,
      "EnableSsl": true,
      "Username": "<your-email@gmail.com>",
      "Password": "your-app-password",
      "FromEmail": "<noreply@ldetch.co.jp>",
      "FromName": "Health Assistant"
    }
  }

  或使用第三方邮件服务（推荐）：

  "SendGrid": {
    "ApiKey": "your-sendgrid-api-key",
    "FromEmail": "<noreply@ldetch.co.jp>",
    "FromName": "Health Assistant"
  }

  常见的邮件发送方案：

  1. SendGrid - 云端邮件服务，可靠性高
  2. AWS SES - 如果已在使用AWS
  3. SMTP直连 - 使用Gmail、Outlook等
  4. MailKit - .NET邮件发送库

© 2025 ldetch.co.jp  health_api
