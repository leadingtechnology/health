# 环境配置指南

## 为什么使用 .env 文件？

1. **安全性** - 敏感信息不会被提交到版本控制
2. **灵活性** - 不同环境使用不同配置
3. **简便性** - 无需修改代码即可更改配置
4. **标准化** - 业界通用做法

## 后端配置 (.NET API)

### 1. 创建配置文件

```bash
cd apps/health_api

# 开发环境
cp .env.example .env.development

# 生产环境
cp .env.example .env.production
```

### 2. 生成安全密钥

```bash
# 生成加密密钥 (KEYRING_MASTER_KEY)
openssl rand -base64 32

# 生成JWT签名密钥 (Jwt__SigningKey)
openssl rand -hex 32
```

### 3. 配置文件说明

#### .env.development (开发环境)
```env
# 使用GCP Cloud SQL数据库
ConnectionStrings__DefaultConnection=Host=35.187.209.229;Port=5432;Database=postgres;Username=postgres;Password=Ldtech@4649;Search Path=health;

# 开发环境可以使用简单的密钥
KEYRING_MASTER_KEY=dGVzdGtleWZvcmRldmVsb3BtZW50b25seQ==
Jwt__SigningKey=development_key_at_least_32_characters_long

# 允许localhost访问
Cors__AllowedOrigins__0=http://localhost:3000
Cors__AllowedOrigins__1=http://localhost:8080
```

#### .env.production (生产环境)
```env
# 生产数据库配置
ConnectionStrings__DefaultConnection=Host=35.187.209.229;Port=5432;Database=postgres;Username=postgres;Password=PRODUCTION_PASSWORD;Search Path=health;

# 使用强密钥
KEYRING_MASTER_KEY=[生成的Base64密钥]
Jwt__SigningKey=[生成的随机字符串]

# 只允许生产域名
Cors__AllowedOrigins__0=https://app.ldetch.co.jp
Cors__AllowedOrigins__1=https://ldetch.co.jp
```

## 前端配置 (Flutter)

### 1. 创建配置文件

```bash
cd apps/health_app

# 开发环境
echo "API_BASE_URL=http://localhost:61676/api" > .env.development

# 生产环境
echo "API_BASE_URL=https://api.ldetch.co.jp/api" > .env.production
```

### 2. Flutter自动加载

应用启动时会根据编译模式自动选择配置文件：
- Debug模式 → `.env.development`
- Release模式 → `.env.production`

## Docker环境变量

### 使用docker-compose

```yaml
services:
  api:
    env_file:
      - .env.development  # 或 .env.production
```

### 使用Docker run

```bash
docker run -d \
  --env-file .env.production \
  health-api:latest
```

## 环境变量优先级

1. 系统环境变量 (最高优先级)
2. .env文件
3. appsettings.json (最低优先级)

## 安全最佳实践

### ✅ 应该做的

1. **永远不要提交 .env 文件到Git**
   ```bash
   # 确保.gitignore包含
   .env
   .env.*
   !.env.example
   ```

2. **使用强密钥**
   ```bash
   # 至少32个字符
   openssl rand -hex 32
   ```

3. **定期轮换密钥**
   - 每3-6个月更新一次
   - 发生泄露立即更换

4. **使用密钥管理服务**
   - GCP Secret Manager
   - Azure Key Vault
   - AWS Secrets Manager

### ❌ 不应该做的

1. **不要在代码中硬编码密钥**
2. **不要使用弱密码**
3. **不要共享生产环境密钥**
4. **不要在日志中打印密钥**

## 故障排查

### 环境变量未加载

```bash
# 检查文件是否存在
ls -la .env*

# 检查环境变量
dotnet run -- --environment=Development
echo $ASPNETCORE_ENVIRONMENT
```

### 权限问题

```bash
# 设置正确的文件权限
chmod 600 .env.production  # 只有所有者可读写
```

### Docker环境变量

```bash
# 检查容器环境变量
docker exec health-api env | grep -E "JWT|KEYRING"
```

## 环境变量参考

### 必需的环境变量

| 变量名 | 描述 | 示例 |
|--------|------|------|
| `KEYRING_MASTER_KEY` | AES加密密钥 | Base64编码的32字节密钥 |
| `Jwt__SigningKey` | JWT签名密钥 | 至少32个字符的随机字符串 |
| `ConnectionStrings__DefaultConnection` | 数据库连接字符串 | PostgreSQL连接字符串 |

### 可选的环境变量

| 变量名 | 描述 | 默认值 |
|--------|------|--------|
| `ASPNETCORE_ENVIRONMENT` | 运行环境 | Development |
| `ASPNETCORE_URLS` | 监听地址 | http://localhost:5000 |
| `OpenAI__ApiKey` | OpenAI API密钥 | (空) |
| `Jwt__ExpireMinutes` | Token过期时间 | 1440 (24小时) |

## 快速开始

### 开发环境

```bash
# 1. 复制示例文件
cp .env.example .env.development

# 2. 编辑配置
nano .env.development

# 3. 运行应用
dotnet run
```

### 生产部署

```bash
# 1. 创建生产配置
cp .env.example .env.production

# 2. 生成安全密钥
./scripts/generate-keys.sh

# 3. 部署
docker-compose -f docker-compose.prod.yml up -d
```

## 相关文档

- [部署指南](../deploy/README.md)
- [安全指南](SECURITY.md)
- [API文档](API.md)