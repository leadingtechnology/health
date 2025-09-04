# LDETCH Health — PostgreSQL 设计（Cloud SQL for GCP）

本方案为你的 `health_api` 后端提供**完整数据库设计**：表结构、约束、索引、触发器、函数/存储过程（PL/pgSQL）。
目标：安全、可扩展、支持**家族互通**、**逐会话共享**、**免费每日 3 问配额**、**OpenAI Key 加密保存（应用层）**。

## 快速使用

1. **在 Cloud SQL 创建 PostgreSQL 实例与数据库**（PostgreSQL 13+）。  
2. 使用 `psql` 或 Cloud SQL 控制台执行：

   ```sql
   \i health_postgres.sql
   ```

3. 在后端连接串中使用该数据库；为应用账号授予文末的 `GRANT` 示例权限。

## 关键设计要点

- **扩展**：开启 `pgcrypto`（UUID）、`citext`（邮箱大小写不敏感）、`pg_trgm`（三元组模糊搜索）。  
- **主键**：`UUID`（`gen_random_uuid()`）。  
- **用户表**：`users(email CITEXT UNIQUE WHERE deleted_at IS NULL)`，含 `plan`（枚举：free/standard/pro）、`model_tier`。  
- **时区**：`users.time_zone` 保存用户本地时区；配额按**本地日界**重置。  
- **照护圈**：`care_circles` + `care_circle_members(role)`，支持 owner/admin 管理成员。  
- **患者/会话**：`patients`（可选主属圈/创建人）→ `conversations`（摘要 + `is_shared` 标记 + `tsvector/trgm` 索引）。  
- **共享授权**：`share_grants`（to_user_id 或 to_email 二选一，支持到期与撤销）。  
- **配额**：`quota_usages(user_id, local_date) UNIQUE`；函数 `fn_quota_try_consume()` **原子扣额**，并返回 `ok/used_today/daily_limit/reset_at`。  
- **API Key**：`api_key_secrets(encrypted_value TEXT)` —— **仅存应用层 AES‑GCM 密文**；DB 中不保留明文；函数 `fn_mask_secret()` 供 UI 显示掩码。  
- **审计**：`audit_log` + 触发器 `trg_audit_dml()`；应用层在事务内执行 `SET LOCAL app.user_id='<uuid>'`，审计将记录操作者。

## 常用函数（节选）

- `fn_quota_get(user_id)` → `used_today, daily_limit, reset_at`  
- `fn_quota_try_consume(user_id, reason TEXT DEFAULT 'ask')` → `ok, used_today, daily_limit, reset_at`  
- `fn_create_care_circle(actor, name)` → 新圈子 UUID  
- `fn_circle_add_member(actor, circle, user, role)` / `fn_circle_remove_member(...)`  
- `fn_conversation_share(actor, conversation, to_user, to_email, redact, expires)` / `fn_conversation_revoke_share(actor, share_id)`

> ⚠️ 配额“无限*”的方案（Standard/Pro）不会写入计数，仅返回快照；如需统计量，可改为累加计数。

## 性能与扩展

- 频繁搜索会话摘要时，优先使用 `pg_trgm`（中文/日文更合适）；已创建 `GIN (summary_text gin_trgm_ops)`。  
- 大表（如 `audit_log`、`conversations`）可按月分区；现阶段不必过早优化。  
- Cloud SQL 建议：
  - 开启 **自动备份**与**时间点恢复（PITR）**；  
  - 使用 **私有 IP** + Cloud SQL Proxy/Connector 接入；  
  - 将应用账号最小权限化（只对 `health` schema 授权）。

## 与后端的对接

- EF Core（Npgsql）可直接对接此模式。若你使用 **Code‑First**，可将实体与枚举映射到相同表/类型；  
  若你选择 **DB‑First**，可用 `dotnet ef dbcontext scaffold` 反向生成实体，并保留自定义函数的调用（通过存储过程或原生 SQL）。

## 审计用法示例

在后端每个写操作开始的事务里执行：

```sql
SET LOCAL app.user_id = '00000000-0000-0000-0000-000000000000';
-- 之后进行 INSERT/UPDATE/DELETE，将自动写入 audit_log
```

## 下一步可选增强

- 开启 **Row‑Level Security (RLS)** 并建立 policy（需要连接会话中设置 `app.user_id`，并使用 `SECURITY DEFINER` 函数封装访问）。  
- 引入 **documents/document_references** 表，管理 PDF 物理存储与 FHIR 元数据映射。  
- 针对共享访问设计 **materialized view** 加速授权查询。

---

如需我帮你把这套 SQL **直接迁移到 Cloud SQL 并生成初始化用户/权限脚本**，告诉我你的数据库名与期望的连接账号即可。
