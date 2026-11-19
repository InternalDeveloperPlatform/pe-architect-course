#!/bin/bash
echo "=== CAPSTONE VERIFICATION ==="
echo "[Gatekeeper]"
kubectl get pods -n gatekeeper-system | grep Running
echo "[Falco]"
kubectl get pods -n falco-system | grep Running
echo "[Engineering Platform]"
kubectl get pods -n engineering-platform | grep Running
echo "[Monitoring]"
kubectl get pods -n monitoring | grep Running
echo "[Namespaces]"
kubectl get ns -l app.kubernetes.io/managed-by=teams-operator
echo "[Health Check]"
curl -s http://localhost:8083/health
