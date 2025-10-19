#!/bin/bash

# Kukuk DevOps Project – Cleanup Script for Minikube
# Usage: ./undeploy.sh [dev|prod]

set -e

ENVIRONMENT=${1:-dev}
NAMESPACE=$ENVIRONMENT

echo "Entferne Ressourcen aus Namespace: $NAMESPACE"

# Prüfen, ob Namespace existiert
if kubectl get namespace $NAMESPACE >/dev/null 2>&1; then
  echo "Namespace gefunden: $NAMESPACE"
else
  echo "Namespace $NAMESPACE existiert nicht. Abbruch."
  exit 0
fi

# Ressourcen löschen
kubectl delete deployment kukuk-backend -n $NAMESPACE --ignore-not-found
kubectl delete deployment kukuk-frontend -n $NAMESPACE --ignore-not-found
kubectl delete service kukuk-backend -n $NAMESPACE --ignore-not-found
kubectl delete service kukuk-frontend -n $NAMESPACE --ignore-not-found

# Namespace löschen
kubectl delete namespace $NAMESPACE --ignore-not-found

echo "Alle Ressourcen wurden entfernt."
