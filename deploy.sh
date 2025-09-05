#!/bin/bash

# Deployment script for GCP VM
# This script deploys the health API to a GCP VM using Docker

set -e

echo "🚀 Starting deployment to GCP VM..."

# Configuration
REMOTE_USER=${REMOTE_USER:-"your-username"}
REMOTE_HOST=${REMOTE_HOST:-"your-gcp-vm-ip"}
REMOTE_DIR="/home/$REMOTE_USER/health-api"

# Check if environment variables are set
if [ -z "$OPENAI_API_KEY" ]; then
    echo "❌ Error: OPENAI_API_KEY environment variable is not set"
    echo "Please set it in your GCP VM environment or pass it to this script"
    exit 1
fi

if [ -z "$JWT_SIGNING_KEY" ]; then
    echo "❌ Error: JWT_SIGNING_KEY environment variable is not set"
    echo "Generate one with: openssl rand -base64 32"
    exit 1
fi

if [ -z "$KEYRING_MASTER_KEY" ]; then
    echo "❌ Error: KEYRING_MASTER_KEY environment variable is not set"
    echo "Generate one with: openssl rand -base64 32"
    exit 1
fi

if [ -z "$DB_CONNECTION_STRING" ]; then
    echo "❌ Error: DB_CONNECTION_STRING environment variable is not set"
    exit 1
fi

echo "📦 Building Docker image locally..."
docker build -t health-api:latest ./apps/health_api

echo "🏷️ Tagging image for registry..."
docker tag health-api:latest gcr.io/ldtech/health-api:latest

echo "📤 Pushing to Google Container Registry..."
docker push gcr.io/ldtech/health-api:latest

echo "🔄 Deploying to GCP VM..."
ssh $REMOTE_USER@$REMOTE_HOST << 'ENDSSH'
    # Pull the latest image
    docker pull gcr.io/ldtech/health-api:latest
    
    # Stop existing container if running
    docker stop health-api-prod 2>/dev/null || true
    docker rm health-api-prod 2>/dev/null || true
    
    # Run the new container with environment variables
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
        gcr.io/ldtech/health-api:latest
    
    # Check if container is running
    docker ps | grep health-api-prod
ENDSSH

echo "✅ Deployment complete!"
echo "📊 View logs with: ssh $REMOTE_USER@$REMOTE_HOST 'docker logs -f health-api-prod'"
echo "🔍 Check health: curl http://$REMOTE_HOST:5000/health"