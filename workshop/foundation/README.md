# Kubernetes Sandbox Setup Documentation

This guide will walk you through setting up a complete Kubernetes development environment with monitoring and policy management tools.

## Table of Contents

1. [Installing Grafana Stack](#installing-grafana-stack)
2. [Installing Gatekeeper](#installing-gatekeeper)
3. [Verification Steps](#verification-steps)

---

## Installing Grafana Stack

### Prerequisite

Install Helm:

```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

The Grafana stack includes Prometheus, Grafana, AlertManager, and other monitoring tools.

### Step 1: Add Helm Repository

```bash
# Add Prometheus community Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

### Step 2: Create Values File

Create a configuration file to optimize resource usage:

```bash
cat > grafana-stack-values.yaml << 'EOF'
# Prometheus configuration
prometheus:
  prometheusSpec:
    resources:
      requests:
        memory: 1Gi
        cpu: 500m
      limits:
        memory: 2Gi
        cpu: 1000m
    retention: 7d
    storageSpec:
      volumeClaimTemplate:
        spec:
          resources:
            requests:
              storage: 10Gi

# Grafana configuration
grafana:
  resources:
    requests:
      memory: 256Mi
      cpu: 100m
    limits:
      memory: 512Mi
      cpu: 500m
  adminPassword: admin123
  service:
    type: NodePort
    nodePort: 30300
  persistence:
    enabled: true
    size: 2Gi

# AlertManager configuration
alertmanager:
  enabled: true
  alertmanagerSpec:
    resources:
      requests:
        memory: 128Mi
        cpu: 100m
      limits:
        memory: 256Mi
        cpu: 200m

# Node Exporter
nodeExporter:
  enabled: true

# Kube State Metrics
kubeStateMetrics:
  enabled: true

# Disable some components to save resources
kubeEtcd:
  enabled: false
kubeControllerManager:
  enabled: false
kubeScheduler:
  enabled: false
EOF
```

### Step 3: Install the Stack

```bash
# Create namespace
kubectl create namespace monitoring

# Install kube-prometheus-stack
helm install grafana-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values grafana-stack-values.yaml \
  --wait

# Verify installation
kubectl get pods -n monitoring
```

### Step 4: Access Grafana -

# TODO - Proxy port forwarding in coder.com

```bash
# Get Grafana admin password (if you didn't set one)
kubectl get secret -n monitoring grafana-stack-grafana \
  -o jsonpath="{.data.admin-password}" | base64 --decode && echo

# Access Grafana via port-forward
kubectl port-forward -n monitoring service/grafana-stack-grafana 3000:80

# Or access via NodePort (if configured)
# http://localhost:30300
```

**Default Credentials:**
- Username: `admin`
- Password: `admin123` (or the value from the secret)

---

## Installing Gatekeeper

Open Policy Agent (OPA) Gatekeeper provides policy-based control for Kubernetes.

### Step 1: Install Gatekeeper

```bash
# Apply Gatekeeper manifests
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-3.14/deploy/gatekeeper.yaml

# Wait for Gatekeeper to be ready
kubectl wait --for=condition=Ready pod -l control-plane=controller-manager -n gatekeeper-system --timeout=90s
```

### Step 2: Verify Installation

```bash
# Check Gatekeeper pods
kubectl get pods -n gatekeeper-system

# Expected output:
# NAME                                             READY   STATUS    RESTARTS   AGE
# gatekeeper-audit-xxx                             1/1     Running   0          1m
# gatekeeper-controller-manager-xxx                1/1     Running   0          1m
# gatekeeper-policy-manager-xxx                    1/1     Running   0          1m
```

### Verify gatekeeper install worked.

Deploy a simple constraint template
`k apply -f simple-constraint-template.yaml`

``` yaml
apiVersion: templates.gatekeeper.sh/v1
kind: ConstraintTemplate
metadata:
  name: k8srequiredlabels
spec:
  crd:
    spec:
      names:
        kind: K8sRequiredLabels
      validation:
        # Schema for the `parameters` field
        openAPIV3Schema:
          type: object
          properties:
            labels:
              type: array
              items:
                type: string
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8srequiredlabels

        violation[{"msg": msg, "details": {"missing_labels": missing}}] {
          provided := {label | input.review.object.metadata.labels[label]}
          required := {label | label := input.parameters.labels[_]}
          missing := required - provided
          count(missing) > 0
          msg := sprintf("you must provide labels: %v", [missing])
        }
```

`k apply -f simple-constraint.yaml`

``` yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredLabels
metadata:
  name: ns-must-have-gk
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Namespace"]
  parameters:
    labels: ["admission"]
```

### Step 5: Test the Constraint

```bash
# Try to create a namespace without the required label (should fail)
kubectl create namespace test-namespace

# Create a namespace with the required label (should succeed)
kubectl apply -f simple-ns-with-label.yaml
```


---

## Verification Steps

### Verify Complete Setup

```bash
# Check all namespaces
kubectl get namespaces

# Check nodes
kubectl get nodes

# Check all pods across namespaces
kubectl get pods --all-namespaces

# Check services
kubectl get services --all-namespaces
```

### Resource Usage Check

```bash
# Check resource usage
kubectl top nodes
kubectl top pods --all-namespaces
```

#### Common Issues

1. **Pods stuck in Pending state**
   ```bash
   kubectl describe pod <pod-name> -n <namespace>
   # Check for resource constraints or node issues
   ```

2. **Gatekeeper not enforcing policies**
   ```bash
   kubectl get constrainttemplates
   kubectl get constraints
   kubectl describe constraint <constraint-name>
   ```

3. **Grafana not accessible**
   ```bash
   kubectl get pods -n monitoring | grep grafana
   kubectl logs -n monitoring deployment/grafana-stack-grafana
   ```

4. **High resource usage**
   ```bash
   # Reduce Prometheus retention
   helm upgrade grafana-stack prometheus-community/kube-prometheus-stack \
     --namespace monitoring \
     --set prometheus.prometheusSpec.retention=3d
   ```

#### Resource Optimization

If you experience performance issues:

```bash
# Scale down replicas for resource-intensive components
kubectl scale deployment -n monitoring grafana-stack-prometheus-node-exporter --replicas=0
kubectl scale deployment -n monitoring grafana-stack-kube-state-metrics --replicas=0
```

## Cleanup

To remove the entire setup:

```bash
# Uninstall Grafana stack
helm uninstall grafana-stack -n monitoring
kubectl delete namespace monitoring

# Uninstall Gatekeeper
kubectl delete -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-3.14/deploy/gatekeeper.yaml
```

This completes your Kubernetes sandbox setup with monitoring and policy management capability

The next module is `capoc/cve`
