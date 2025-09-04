# Health Assistant Deployment Guide

## Architecture Overview

- **Backend API**: .NET 8 REST API deployed on GCP Compute Engine
- **Database**: Google Cloud SQL PostgreSQL (35.187.209.229)
- **Frontend**: Flutter Web deployed on nginx
- **Domain**: ldetch.co.jp
  - API: api.ldetch.co.jp
  - App: app.ldetch.co.jp

## Prerequisites

1. GCP Account with billing enabled
2. gcloud CLI installed and configured
3. Docker installed locally
4. Domain configured with DNS pointing to GCP

## Deployment Steps

### 1. Database Setup

Connect to GCP Cloud SQL and initialize database:

```bash
# Connect to Cloud SQL
gcloud sql connect racketrallydb --user=postgres --database=postgres --project=ldtech

# Initialize database schema
\encoding UTF8
\i D:/ldtech/health/health/Database/health_postgres.sql
\c postgres
SET search_path TO health, public;
```

### 2. Environment Configuration

```bash
# Copy and configure environment variables
cd deploy
cp .env.example .env
nano .env  # Edit with your actual values

# Generate secure keys
# For KEYRING_MASTER_KEY (32 bytes base64):
openssl rand -base64 32

# For JWT_SIGNING_KEY (random string):
openssl rand -hex 32
```

### 3. Deploy Backend API

#### Option A: Using Docker on GCP VM

```bash
# Make deployment script executable
chmod +x deploy-to-gcp.sh

# Load environment variables
source .env

# Deploy to production
./deploy-to-gcp.sh production
```

#### Option B: Manual Deployment

```bash
# Build Docker image
cd apps/health_api
docker build -t health-api:latest .

# Push to container registry
docker tag health-api:latest gcr.io/ldtech/health-api:latest
docker push gcr.io/ldtech/health-api:latest

# SSH into GCP VM
gcloud compute ssh health-api-vm --zone=asia-northeast1-a

# Run container
docker run -d \
  --name health-api \
  --restart always \
  -p 5000:5000 \
  -p 5001:5001 \
  -e ASPNETCORE_ENVIRONMENT=Production \
  -e KEYRING_MASTER_KEY=$KEYRING_MASTER_KEY \
  -e Jwt__SigningKey=$JWT_SIGNING_KEY \
  gcr.io/ldtech/health-api:latest
```

### 4. Setup Nginx Reverse Proxy

```bash
# Install nginx on VM
sudo apt-get update
sudo apt-get install nginx certbot python3-certbot-nginx

# Copy nginx configuration
sudo cp nginx.conf /etc/nginx/sites-available/health-api
sudo ln -s /etc/nginx/sites-available/health-api /etc/nginx/sites-enabled/

# Get SSL certificate from Let's Encrypt
sudo certbot --nginx -d api.ldetch.co.jp -d app.ldetch.co.jp

# Test and reload nginx
sudo nginx -t
sudo systemctl reload nginx
```

### 5. Deploy Flutter Web App

```bash
# Build Flutter web app
cd apps/health_app
flutter build web --release

# Copy to web server
rsync -avz build/web/ user@your-server:/var/www/health-app/

# Or deploy to Firebase Hosting
firebase deploy --only hosting
```

### 6. Configure Firewall Rules

```bash
# Allow HTTP/HTTPS traffic
gcloud compute firewall-rules create allow-http \
  --allow tcp:80 \
  --source-ranges 0.0.0.0/0 \
  --target-tags http-server

gcloud compute firewall-rules create allow-https \
  --allow tcp:443 \
  --source-ranges 0.0.0.0/0 \
  --target-tags https-server

# Allow API ports (if not using nginx)
gcloud compute firewall-rules create allow-api \
  --allow tcp:5000,tcp:5001 \
  --source-ranges 0.0.0.0/0 \
  --target-tags health-api
```

## Health Checks

### Backend API
```bash
# Health endpoint
curl https://api.ldetch.co.jp/health

# Swagger UI
open https://api.ldetch.co.jp/swagger
```

### Database Connection
```bash
# Test from API server
docker exec health-api dotnet ef database query "SELECT 1"
```

## Monitoring & Logs

### View API Logs
```bash
# Docker logs
docker logs -f health-api

# Or on GCP
gcloud compute ssh health-api-vm --command="sudo docker logs health-api"
```

### View Nginx Logs
```bash
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

## Backup & Recovery

### Database Backup
```bash
# Automated backup via Cloud SQL
gcloud sql backups create --instance=racketrallydb

# Manual backup
pg_dump -h 35.187.209.229 -U postgres -d postgres -n health > backup_$(date +%Y%m%d).sql
```

### Restore Database
```bash
psql -h 35.187.209.229 -U postgres -d postgres < backup.sql
```

## Troubleshooting

### API Not Responding
1. Check container status: `docker ps`
2. Check logs: `docker logs health-api`
3. Verify environment variables: `docker exec health-api env`
4. Test database connection

### SSL Certificate Issues
```bash
# Renew certificate
sudo certbot renew

# Test certificate
openssl s_client -connect api.ldetch.co.jp:443
```

### Database Connection Issues
1. Check Cloud SQL proxy status
2. Verify IP whitelist in Cloud SQL settings
3. Test connection: `psql -h 35.187.209.229 -U postgres -d postgres`

## Security Checklist

- [ ] Change default passwords
- [ ] Generate secure JWT signing key
- [ ] Generate secure encryption key
- [ ] Enable SSL/TLS
- [ ] Configure firewall rules
- [ ] Enable Cloud SQL backups
- [ ] Set up monitoring alerts
- [ ] Review CORS settings
- [ ] Enable rate limiting
- [ ] Configure log retention

## Production URLs

- **API Base**: https://api.ldetch.co.jp
- **Swagger UI**: https://api.ldetch.co.jp/swagger
- **Health Check**: https://api.ldetch.co.jp/health
- **Web App**: https://app.ldetch.co.jp

## Development URLs

- **API Base**: http://localhost:61676/api
- **Swagger UI**: http://localhost:61676/swagger
- **Database**: 35.187.209.229:5432/postgres (schema: health)