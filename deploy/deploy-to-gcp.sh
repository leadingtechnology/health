#!/bin/bash

# GCP Deployment Script for Health API
# Usage: ./deploy-to-gcp.sh [staging|production]

set -e

# Configuration
PROJECT_ID="ldtech"
REGION="asia-northeast1"
ZONE="asia-northeast1-a"
VM_NAME="health-api-vm"
SERVICE_NAME="health-api"
IMAGE_NAME="gcr.io/${PROJECT_ID}/${SERVICE_NAME}"
ENVIRONMENT=${1:-staging}

echo "========================================="
echo "Deploying Health API to GCP"
echo "Environment: ${ENVIRONMENT}"
echo "========================================="

# 1. Build and push Docker image
echo "Building Docker image..."
cd ../apps/health_api
docker build -t ${IMAGE_NAME}:latest .
docker tag ${IMAGE_NAME}:latest ${IMAGE_NAME}:${ENVIRONMENT}

echo "Pushing image to Google Container Registry..."
docker push ${IMAGE_NAME}:latest
docker push ${IMAGE_NAME}:${ENVIRONMENT}

# 2. Deploy to Compute Engine
echo "Deploying to Compute Engine..."

# Create firewall rules if not exist
gcloud compute firewall-rules create allow-health-api \
    --allow tcp:5000,tcp:5001 \
    --source-ranges 0.0.0.0/0 \
    --target-tags health-api \
    --project ${PROJECT_ID} \
    2>/dev/null || true

# Create or update VM instance
if gcloud compute instances describe ${VM_NAME} --zone=${ZONE} --project=${PROJECT_ID} &>/dev/null; then
    echo "Updating existing VM instance..."
    
    # SSH into VM and update container
    gcloud compute ssh ${VM_NAME} --zone=${ZONE} --project=${PROJECT_ID} --command="
        sudo docker pull ${IMAGE_NAME}:${ENVIRONMENT}
        sudo docker stop ${SERVICE_NAME} || true
        sudo docker rm ${SERVICE_NAME} || true
        
        # Run new container with environment variables
        sudo docker run -d \
            --name ${SERVICE_NAME} \
            --restart always \
            -p 5000:5000 \
            -p 5001:5001 \
            -e ASPNETCORE_ENVIRONMENT=Production \
            -e KEYRING_MASTER_KEY='${KEYRING_MASTER_KEY}' \
            -e Jwt__SigningKey='${JWT_SIGNING_KEY}' \
            -e ConnectionStrings__Default='Host=35.187.209.229;Port=5432;Database=postgres;Username=postgres;Password=Ldtech@4649;Search Path=health' \
            ${IMAGE_NAME}:${ENVIRONMENT}
        
        # Check container status
        sudo docker ps
    "
else
    echo "Creating new VM instance..."
    
    # Create VM with container-optimized OS
    gcloud compute instances create-with-container ${VM_NAME} \
        --zone=${ZONE} \
        --machine-type=e2-medium \
        --network-interface=network-tier=PREMIUM,subnet=default \
        --maintenance-policy=MIGRATE \
        --provisioning-model=STANDARD \
        --service-account=${PROJECT_ID}-compute@developer.gserviceaccount.com \
        --scopes=https://www.googleapis.com/auth/cloud-platform \
        --tags=health-api,http-server,https-server \
        --container-image=${IMAGE_NAME}:${ENVIRONMENT} \
        --container-restart-policy=always \
        --container-env=ASPNETCORE_ENVIRONMENT=Production,KEYRING_MASTER_KEY=${KEYRING_MASTER_KEY},Jwt__SigningKey=${JWT_SIGNING_KEY} \
        --create-disk=auto-delete=yes,boot=yes,device-name=${VM_NAME},image=projects/cos-cloud/global/images/family/cos-stable,mode=rw,size=20,type=pd-balanced \
        --no-shielded-secure-boot \
        --shielded-vtpm \
        --shielded-integrity-monitoring \
        --labels=app=health-api,environment=${ENVIRONMENT} \
        --project=${PROJECT_ID}
fi

# 3. Get external IP
echo "Getting external IP address..."
EXTERNAL_IP=$(gcloud compute instances describe ${VM_NAME} \
    --zone=${ZONE} \
    --project=${PROJECT_ID} \
    --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

echo "========================================="
echo "Deployment completed!"
echo "External IP: ${EXTERNAL_IP}"
echo "API URL: http://${EXTERNAL_IP}:5000"
echo "Swagger UI: http://${EXTERNAL_IP}:5000/swagger"
echo "========================================="

# 4. Health check
echo "Waiting for service to be ready..."
sleep 10

if curl -f http://${EXTERNAL_IP}:5000/health &>/dev/null; then
    echo "✅ Health check passed!"
else
    echo "❌ Health check failed. Please check the logs:"
    echo "gcloud compute ssh ${VM_NAME} --zone=${ZONE} --command='sudo docker logs ${SERVICE_NAME}'"
fi