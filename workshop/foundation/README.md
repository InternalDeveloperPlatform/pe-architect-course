# Kubernetes Sandbox Setup Documentation

This guide will walk you through setting up a complete Kubernetes development environment with monitoring and policy management tools.

## Prerequisites

- macOS (Intel or Apple Silicon)
- At least 16GB RAM (recommended 24GB+)
- 50GB+ available disk space
- Admin privileges on your machine

## Table of Contents

1. [Installing kubectl](#installing-kubectl)
2. [Installing Rancher Desktop](#installing-rancher-desktop)
3. [Installing Grafana Stack](#installing-grafana-stack)
4. [Installing Gatekeeper](#installing-gatekeeper)
5. [Verification Steps](#verification-steps)

---

## Installing kubectl

kubectl is the command-line tool for interacting with Kubernetes clusters.

### Option 1: Using Homebrew (Recommended)

```bash
# Install kubectl
brew install kubectl

# Verify installation
kubectl version --client
```

### Option 2: Direct Download

```bash
# Download kubectl binary
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"

# Make it executable
chmod +x ./kubectl

# Move to PATH
sudo mv ./kubectl /usr/local/bin/kubectl

# Verify installation
kubectl version --client
```

### Option 3: Using curl with specific version

```bash
# Download specific version (v1.28.3 to match Rancher Desktop)
curl -LO "https://dl.k8s.io/release/v1.28.3/bin/darwin/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
```

---

## Installing Rancher Desktop

Rancher Desktop provides a Kubernetes environment with an integrated container runtime.

### Step 1: Download and Install

1. Visit [Rancher Desktop Releases](https://github.com/rancher-sandbox/rancher-desktop/releases)
2. Download the latest `.dmg` file for macOS
3. Open the downloaded `.dmg` file
4. Drag Rancher Desktop to Applications folder
5. Launch Rancher Desktop from Applications

### Step 2: Initial Configuration

When Rancher Desktop starts for the first time, configure the following settings:

#### Kubernetes Settings
- **Enable Kubernetes**: ✅ Checked
- **Kubernetes Version**: Select `v1.28.3`
- **Container Runtime**: Select `dockerd (moby)`
- **Enable Traefik**: ✅ Checked

#### Virtual Machine Settings
- **Memory (GB)**: `8`
- **CPUs**: `6`
- **Emulation**: Select `QEMU`

### Step 3: Apply Configuration

```bash
# After configuration, click "Apply" and wait for Rancher Desktop to restart
# This process may take 5-10 minutes

# Verify Kubernetes is running
kubectl get nodes

# Expected output:
# NAME                   STATUS   ROLES                  AGE   VERSION
# lima-rancher-desktop   Ready    control-plane,master   1m    v1.28.3+k3s1
```

### Step 4: Configure kubectl Context

```bash
# Verify current context
kubectl config current-context

# Should show: rancher-desktop

# Test cluster connectivity
kubectl cluster-info
```

---

## Installing Grafana Stack

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

### Step 4: Access Grafana

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

### Step 3: Create a Sample Constraint Template

```bash
# Create a constraint template for required labels
kubectl apply -f - << 'EOF'
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: k8srequiredlabels
spec:
  crd:
    spec:
      names:
        kind: K8sRequiredLabels
      validation:
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

        violation[{"msg": msg}] {
          required := input.parameters.labels
          provided := input.review.object.metadata.labels
          missing := required[_]
          not provided[missing]
          msg := sprintf("Missing required label: %v", [missing])
        }
EOF
```

### Step 4: Create a Sample Constraint

```bash
# Apply constraint to require 'environment' label on all namespaces
kubectl apply -f - << 'EOF'
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredLabels
metadata:
  name: namespace-must-have-env-label
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Namespace"]
  parameters:
    labels: ["environment"]
EOF
```

### Step 5: Test the Constraint

```bash
# Try to create a namespace without the required label (should fail)
kubectl create namespace test-namespace

# Create a namespace with the required label (should succeed)
kubectl apply -f - << 'EOF'
apiVersion: v1
kind: Namespace
metadata:
  name: test-namespace-with-label
  labels:
    environment: development
EOF
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

# Verify Traefik (Rancher Desktop's ingress controller)
kubectl get pods -n kube-system | grep traefik

# Check services
kubectl get services --all-namespaces
```

### Resource Usage Check

```bash
# Check resource usage
kubectl top nodes
kubectl top pods --all-namespaces
```

### Access Web Interfaces

```bash
# Grafana
kubectl port-forward -n monitoring service/grafana-stack-grafana 3000:80

# Prometheus
kubectl port-forward -n monitoring service/grafana-stack-prometheus 9090:9090

# AlertManager
kubectl port-forward -n monitoring service/grafana-stack-alertmanager 9093:9093
```

**Access URLs:**
- **Grafana**: http://localhost:3000 (admin/admin123)
- **Prometheus**: http://localhost:9090
- **AlertManager**: http://localhost:9093
- **Traefik Dashboard**: http://localhost:8080 (if enabled)

### Troubleshooting

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

## Next Steps

1. **Explore Grafana Dashboards**: Import community dashboards for Kubernetes monitoring
2. **Create Custom Policies**: Develop Gatekeeper policies specific to your needs
3. **Set up Ingress**: Configure Traefik ingress rules for your applications
4. **Add Applications**: Deploy sample applications to test the complete stack

## Cleanup

To remove the entire setup:

```bash
# Uninstall Grafana stack
helm uninstall grafana-stack -n monitoring
kubectl delete namespace monitoring

# Uninstall Gatekeeper
kubectl delete -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-3.14/deploy/gatekeeper.yaml

# Stop Rancher Desktop and delete application
# Quit Rancher Desktop and move it to Trash
```

This completes your Kubernetes sandbox setup with monitoring and policy management capabilit
