#!/bin/bash
cd /workspaces/pe-architect-course/workshop/secops
echo "=== root user deployment: kubectl apply -f root_deployment.yaml ==="
kubectl apply -f root_deployment.yaml
echo "=== non-root user deployment: kubectl apply -f nonroot_deployment.yaml ==="
kubectl apply -f nonroot_deployment.yaml
