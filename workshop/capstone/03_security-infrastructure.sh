#!/bin/bash
echo "=== SECURITY INFRASTRUCTURE ==="
echo "=== Gatekeeper ==="
kubectl get pods -n gatekeeper-system
kubectl get constrainttemplates
kubectl get constraints
echo "=== Falco ==="
kubectl get pods -n falco-system
