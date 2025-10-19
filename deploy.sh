#!/bin/bash

# Kukuk DevOps Project Deployment Script for Minikube
# Usage: ./deploy.sh [dev|prod]

set -e

ENVIRONMENT=${1:-dev}
NAMESPACE=$ENVIRONMENT

echo "Starting deployment to $ENVIRONMENT..."

# Check tools
command -v kubectl >/dev/null || { echo "kubectl fehlt"; exit 1; }
command -v docker >/dev/null || { echo "docker fehlt"; exit 1; }

# Build images
echo "Building backend..."
cd backend
docker build -t andziallas/kukuk-backend:latest .
cd ..

echo "Building frontend..."
cd frontend
docker build -t andziallas/kukuk-frontend:latest .
cd ..

# Push images
echo "Docker Hub Login erforderlich..."
docker login -u andziallas

docker push andziallas/kukuk-backend:latest
docker push andziallas/kukuk-frontend:latest

# Deploy to Minikube
echo "Creating namespace if needed..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

echo "Deploying backend..."
kubectl apply -f k8s/backend-deployment-$ENVIRONMENT.yaml
kubectl apply -f k8s/backend-service.yaml

echo "Deploying frontend..."
kubectl apply -f k8s/frontend-deployment-$ENVIRONMENT.yaml
kubectl apply -f k8s/frontend-service.yaml

echo "Waiting for readiness..."
kubectl wait --for=condition=available --timeout=300s deployment/kukuk-backend -n $NAMESPACE
kubectl wait --for=condition=available --timeout=300s deployment/kukuk-frontend -n $NAMESPACE

echo "Deployment erfolgreich abgeschlossen"

echo "Service-Informationen:"
kubectl get service kukuk-backend -n $NAMESPACE
kubectl get service kukuk-frontend -n $NAMESPACE
