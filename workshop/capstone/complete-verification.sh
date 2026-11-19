#!/bin/bash
echo "=== COMPLETE PLATFORM VERIFICATION ==="
echo "[Gatekeeper]"
kubectl get pods -n gatekeeper-system --no-headers
echo "[Falco]"
kubectl get pods -n falco-system --no-headers
echo "[Teams API]"
kubectl get deployment teams-api -n engineering-platform
echo "[Teams Operator]"
kubectl get deployment teams-operator -n engineering-platform
echo "[Teams UI]"
kubectl get deployment teams-ui -n engineering-platform
echo "[Teams Count]"
curl -s http://localhost:8083/teams | jq length
echo "[Managed Namespaces]"
kubectl get ns -l app.kubernetes.io/managed-by=teams-operator --no-headers
echo "=== PLATFORM READY ==="