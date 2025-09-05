# Deployment Guide

## Environment Configuration

### Development Environment

**OpenAI API Key Location**: `apps/health_api/appsettings.Development.json`

```json
{
  "OpenAI": {
    "ApiKey": "sk-YOUR_OPENAI_API_KEY_HERE"
  }
}
```

### Production Environment (GCP VM + Docker)

**OpenAI API Key Location**: Linux environment variables

## Setting Up Production Environment

### 1. SSH to your GCP VM

```bash
gcloud compute ssh YOUR_VM_NAME --zone=YOUR_ZONE
```

### 2. Set Environment Variables

Edit your shell profile (`~/.bashrc` or `~/.bash_profile`):

```bash
# OpenAI Configuration
export OPENAI_API_KEY="sk-YOUR_ACTUAL_OPENAI_KEY_HERE"
export OPENAI_MODEL="gpt-4o-mini"  # Optional, defaults to gpt-4o-mini

# Database Configuration
export DB_CONNECTION_STRING="Host=35.187.209.229;Port=5432;Database=postgres;Username=postgres;Password=YOUR_PASSWORD"

# JWT Configuration (generate with: openssl rand -base64 32)
export JWT_SIGNING_KEY="YOUR_SECURE_256BIT_KEY_HERE"

# Encryption Key for API storage (generate with: openssl rand -base64 32)
export KEYRING_MASTER_KEY="YOUR_BASE64_ENCODED_32BYTE_KEY"
```

Reload your shell:

```bash
source ~/.bashrc
```

### 3. Deploy with Docker

#### Option A: Using docker-compose

```bash
# Clone or update your repository
git pull origin main

# Deploy with production configuration
docker-compose -f docker-compose.prod.yml up -d
```

#### Option B: Manual Docker deployment

```bash
# Build the image
docker build -t health-api:latest ./apps/health_api

# Run the container
docker run -d \
  --name health-api-prod \
  --restart unless-stopped \
  -p 5000:5000 \
  -p 5001:5001 \
  -e ASPNETCORE_ENVIRONMENT=Production \
  -e "ConnectionStrings__DefaultConnection=$DB_CONNECTION_STRING" \
  -e "Jwt__SigningKey=$JWT_SIGNING_KEY" \
  -e "OpenAI__ApiKey=$OPENAI_API_KEY" \
  -e "KEYRING_MASTER_KEY=$KEYRING_MASTER_KEY" \
  health-api:latest
```

### 4. Verify Deployment

```bash
# Check container status
docker ps

# View logs
docker logs -f health-api-prod

# Test health endpoint
curl http://localhost:5000/health
```

## Security Notes

1. **Never commit API keys to version control**
   - Development keys go in `appsettings.Development.json` (gitignored)
   - Production keys use environment variables

2. **Use strong keys**
   - JWT signing key: At least 32 characters
   - Encryption key: Base64-encoded 32-byte key

3. **Rotate keys regularly**
   - Update OpenAI API key monthly
   - Rotate JWT signing key quarterly

## Configuration Hierarchy

The API reads configuration in this order (later sources override earlier ones):

1. `appsettings.json` (base configuration)
2. `appsettings.{Environment}.json` (environment-specific)
3. Environment variables
4. Command-line arguments

## Troubleshooting

### OpenAI API not working

1. Check if API key is set:
   ```bash
   echo $OPENAI_API_KEY
   ```

2. Check container environment:
   ```bash
   docker exec health-api-prod env | grep OPENAI
   ```

3. Check API logs:
   ```bash
   docker logs health-api-prod | grep -i openai
   ```

### Database connection issues

1. Test connection from VM:
   ```bash
   psql -h 35.187.209.229 -U postgres -d postgres
   ```

2. Check firewall rules in GCP Console

### Container not starting

1. Check Docker logs:
   ```bash
   docker logs health-api-prod
   ```

2. Verify all required environment variables are set

3. Check disk space:
   ```bash
   df -h
   ```