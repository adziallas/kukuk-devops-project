#!/bin/bash

# Kukuk DevOps Project Deployment Script
# Usage: ./deploy.sh [dev|prod]

set -e

ENVIRONMENT=${1:-dev}
NAMESPACE=$ENVIRONMENT

echo "🚀 Starting deployment to $ENVIRONMENT environment..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

# Check if docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ docker is not installed or not in PATH"
    exit 1
fi

echo "📦 Building Docker images..."

# Build backend image
echo "Building backend image..."
cd backend
docker build -t andziallas/kukuk-backend:latest .
cd ..

# Build frontend image
echo "Building frontend image..."
cd frontend
docker build -t andziallas/kukuk-frontend:latest .
cd ..

echo "🐳 Pushing images to Docker Hub..."

# Login to Docker Hub (you'll need to enter credentials)
echo "Please login to Docker Hub..."
docker login -u andziallas

# Push images
docker push andziallas/kukuk-backend:latest
docker push andziallas/kukuk-frontend:latest

echo "☸️ Deploying to Kubernetes..."

# Create namespace if it doesn't exist
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Deploy backend
echo "Deploying backend..."
kubectl apply -f k8s/backend-deployment-$ENVIRONMENT.yaml
kubectl apply -f k8s/backend-service.yaml

# Deploy frontend
echo "Deploying frontend..."
kubectl apply -f k8s/frontend-deployment-$ENVIRONMENT.yaml
kubectl apply -f k8s/frontend-service.yaml

# Wait for deployments to be ready
echo "⏳ Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/kukuk-backend -n $NAMESPACE
kubectl wait --for=condition=available --timeout=300s deployment/kukuk-frontend -n $NAMESPACE

echo "✅ Deployment completed successfully!"

# Show service information
echo "📊 Service Information:"
echo "Backend Service:"
kubectl get service kukuk-backend -n $NAMESPACE
echo ""
echo "Frontend Service:"
kubectl get service kukuk-frontend -n $NAMESPACE

echo ""
echo "🎉 Deployment to $ENVIRONMENT environment completed!"
echo "You can now access your application through the Kubernetes services."
