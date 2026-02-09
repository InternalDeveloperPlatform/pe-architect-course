# Kubernetes Sandbox Setup Documentation

This guide will walk you through setting up a complete Kubernetes development environment with monitoring and policy management tools.

## Table of Contents

1. [Installing Grafana Stack](#installing-grafana-stack)
2. [Installing Gatekeeper](#installing-gatekeeper)
3. [Installing Metrics Server](#installing-metrics-server)
4. [Verification Steps](#verification-steps)

---

## Installing Grafana Stack

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

#### Install coder desktop
To access port-forwarded resources, you need to first install coder desktop.

Please follow the instructions here:
https://coder.com/docs/user-guides/desktop

(Basically, you need to do 2 things in the instructions above. Use ```brew install --cask coder/coder/coder-desktop``` and then ```ssh <workspace-name>.code```)
Coder desktop provides easy access to your resources over a secure VPN tunnel.

```bash
# In Coder environments, use the built-in proxy
# Forward the port and access via the Coder proxy URL
kubectl port-forward -n monitoring service/grafana-stack 3000:80

# Navigate to
`http://<workspace-name>.coder:3000/grafana`
```

#### Note - Workspace URL

To access the workspace url, click the coder desktop app icon, and copy the url name.

Or, just construct the url as follows:

`http://<workspace-name>.coder:3000`

So if your workspace name is student123 your url is http://student123.coder:3000/

**Getting Admin Credentials**
```bash
# Default credentials from our setup:
# Username: admin
# Password: admin123

# Get the admin password (if you didn't set a custom one)
kubectl get secret -n monitoring grafana-stack \
  -o jsonpath="{.data.admin-password}" | base64 --decode && echo
```

**Verify Grafana Access**
1. Open your browser to the Grafana URL
2. Login with admin credentials
3. You should see the Grafana dashboard
4. Navigate to "Dashboards" → "Browse" to see pre-installed dashboards

**Default Credentials:**
- Username: `admin`
- Password: `admin123` (or the value from the secret)

---

## Verify Grafana Setup

Navigate to: Dashboards > Kubernetes / Compute Resources / Namespace (Pods)
Select: Namespace > monitoring

You should now see Grafana metrics for the monitoring namespace.

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
```

### Step 3: Deploy Constraint Template

Deploy a simple constraint template (Use the appropriate relative or absolute paths for the YAML file)
`kubectl apply -f simple-constraint-template.yaml`

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

### Step 4: Deploy Constraint

`kubectl apply -f simple-constraint.yaml`

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

## Installing Metrics Server

Metrics Server provides resource usage metrics for `kubectl top` commands.

### Step 1: Install Metrics Server

```bash
# Add Helm repository
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update

# Install (--kubelet-insecure-tls required for development/lab environments)
helm upgrade --install metrics-server metrics-server/metrics-server \
  --namespace kube-system \
  --set args={--kubelet-insecure-tls}

# Wait for ready
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=metrics-server -n kube-system --timeout=90s
```

### Step 2: Verify Installation

```bash
# Check pod status
kubectl get pods -n kube-system -l app.kubernetes.io/name=metrics-server

# Test metrics (may take 30-60 seconds)
kubectl top nodes
```

---

## ✅ Verification Steps

### Step 1: Verify Complete Setup

**Check Core Components**
```bash
# Verify all namespaces are created
kubectl get namespaces | grep -E "(monitoring|gatekeeper-system)"

# Expected output:
# gatekeeper-system   Active   2m
# monitoring          Active   5m

# Check cluster health
kubectl get nodes
kubectl cluster-info
```

**Verify Monitoring Stack**
```bash
# Check all monitoring pods are running
kubectl get pods -n monitoring

# All pods should show "Running" or "Completed" status
# Wait for all pods to be ready (this may take 2-3 minutes)
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=grafana -n monitoring --timeout=300s
```

**Verify Gatekeeper**
```bash
# Check Gatekeeper pods
kubectl get pods -n gatekeeper-system

# Expected output (all should be Running):
# gatekeeper-audit-xxx                 1/1     Running   0          2m
# gatekeeper-controller-manager-xxx    1/1     Running   0          2m

# Verify constraint template is working
kubectl get constrainttemplates

# Should show: k8srequiredlabels

# Verify constraint is active
kubectl get constraints

# Should show: K8sRequiredLabels/ns-must-have-gk
```

### Step 2: Test the Complete Workflow

**Test Grafana Dashboard**
```bash
# Forward the port (run in a separate terminal)
kubectl port-forward -n monitoring service/grafana-stack 3000:80

# In your browser, go to http://<workspace-name>.coder:3000
# Login with admin/admin123
# You should see dashboards under "Dashboards" → "Browse"
```

**Test Gatekeeper Policy**
```bash
# This should FAIL (demonstrating the policy works)
kubectl create namespace test-fail

# Expected error: admission webhook "validation.gatekeeper.sh" denied the request

# This should SUCCEED
kubectl apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: test-success
  labels:
    admission: "allowed"
EOF

# Cleanup test namespace
kubectl delete namespace test-success
```

### Step 3: Resource Usage Check

```bash
# Check resource usage
kubectl top nodes
kubectl top pods --all-namespaces

# Ensure your cluster isn't overloaded
# Memory usage should be under 80%
# CPU usage should be reasonable
```

### IMPORTANT: Remove the constraint after testing

We will be deploying Falco later on in the project, and it will not have the namespace label "admission" in it by default. Since the above constraint was just for verifying gatekeeper is working properly, we can now safely remove the constraints. We will use other more complex constraints in the next module.

Note: You can leave the constraint-template deployed it you want to play around with other namespace constraints. The only thing that actually *blocks* namespace creation is the constraint itself (which depends on the constraint template as a CRD).

```bash
kubectl delete -f simple-ns-with-label.yaml
kubectl delete -f simple-constraint.yaml
```

### ✅ Success Criteria

Your foundation setup is complete when:
- [ ] All monitoring pods are in "Running" state
- [ ] All gatekeeper pods are in "Running" state
- [ ] Grafana dashboard is accessible at `http://<workspace-name>.coder:3000`
- [ ] Metrics Server pod is in "Running" state
- [ ] `kubectl top nodes` returns resource metrics
- [ ] You can login to Grafana with admin/admin123
- [ ] Constraint template `k8srequiredlabels` exists
- [ ] Constraint `ns-must-have-gk` is active
- [ ] Creating namespace without required label fails
- [ ] Creating namespace with required label succeeds
- [ ] Resource usage is reasonable (< 80% memory)
- [ ] Remove constraint `ns-must-have-gk` after you finish testing

## 🚨 Troubleshooting

### Common Issues and Solutions

#### 1. Pods Stuck in Pending State
**Symptoms**: Pods show `Pending` status for extended periods

**Diagnosis**:
```bash
# Check pod details for scheduling issues
kubectl describe pod <pod-name> -n <namespace>

# Check node resources
kubectl describe nodes
kubectl top nodes
```

**Solutions**:
```bash
# If resource constraints, scale down other components
kubectl scale deployment -n monitoring grafana-stack-prometheus-node-exporter --replicas=1

# Or increase cluster resources (add nodes, increase limits)
```

#### 2. Gatekeeper Not Enforcing Policies
**Symptoms**: Can create resources that should be blocked

**Diagnosis**:
```bash
# Check if Gatekeeper is running
kubectl get pods -n gatekeeper-system

# Verify templates and constraints exist
kubectl get constrainttemplates
kubectl get constraints

# Check constraint status
kubectl describe constraint ns-must-have-gk
```

**Solutions**:
```bash
# Restart Gatekeeper if needed
kubectl rollout restart deployment -n gatekeeper-system gatekeeper-controller-manager

# Re-apply templates if missing
kubectl apply -f simple-constraint-template.yaml
kubectl apply -f simple-constraint.yaml
```

#### 3. Grafana Dashboard Not Accessible
**Symptoms**: Cannot connect to `http://<workspace-name>.coder:3000`

**Diagnosis**:
```bash
# Check if Grafana pod is running
kubectl get pods -n monitoring | grep grafana

# Check service exists
kubectl get service -n monitoring grafana-stack

# Check logs for errors
kubectl logs -n monitoring deployment/grafana-stack
```

**Solutions**:
```bash
# Restart port-forward
kubectl port-forward -n monitoring service/grafana-stack 3000:80

# Or try different port if 3000 is busy
kubectl port-forward -n monitoring service/grafana-stack 3001:80

# Check if password is correct
kubectl get secret -n monitoring grafana-stack -o jsonpath="{.data.admin-password}" | base64 --decode && echo
```

#### 4. High Resource Usage / Cluster Overloaded
**Symptoms**: High CPU/memory usage, pods failing to start

**Diagnosis**:
```bash
# Check resource usage
kubectl top nodes
kubectl top pods --all-namespaces

# Check events for resource issues
kubectl get events --sort-by='.lastTimestamp'
```

**Solutions**:
```bash
# Scale down resource-intensive components
kubectl scale deployment -n monitoring grafana-stack-prometheus-node-exporter --replicas=0
kubectl scale deployment -n monitoring grafana-stack-kube-state-metrics --replicas=0

# Reduce Prometheus retention period
helm upgrade grafana-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set prometheus.prometheusSpec.retention=3d

# Or completely restart with minimal resources
helm uninstall grafana-stack -n monitoring
# Then reinstall with the values file (lower resource limits)
```

#### 5. kubectl top Returns "Metrics not available"
**Symptoms**: `kubectl top nodes` returns error about metrics API

**Diagnosis**:
```bash
kubectl get pods -n kube-system -l app.kubernetes.io/name=metrics-server
kubectl logs -n kube-system deployment/metrics-server
```

**Solutions**:
```bash
helm upgrade --install metrics-server metrics-server/metrics-server \
  --namespace kube-system \
  --set args={--kubelet-insecure-tls}

# Wait 60 seconds for metrics availability
sleep 60 && kubectl top nodes
```

#### 6. Helm Installation Fails
**Symptoms**: `helm install` command fails

**Common Solutions**:
```bash
# Update helm repositories
helm repo update

# Check if namespace exists
kubectl create namespace monitoring --dry-run=client -o yaml

# Try installation with timeout
helm install grafana-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values grafana-stack-values.yaml \
  --wait \
  --timeout=600s
```

### Getting Additional Help

1. **Check pod logs in detail**:
   ```bash
   kubectl logs -f <pod-name> -n <namespace>
   kubectl logs --previous <pod-name> -n <namespace>  # Previous container logs
   ```

2. **Describe resources for events**:
   ```bash
   kubectl describe pod <pod-name> -n <namespace>
   kubectl describe service <service-name> -n <namespace>
   ```

3. **Check cluster events**:
   ```bash
   kubectl get events --sort-by='.lastTimestamp' --all-namespaces
   ```

4. **Verify RBAC permissions** (if using restricted clusters):
   ```bash
   kubectl auth can-i create pods --namespace monitoring
   kubectl auth can-i get secrets --namespace monitoring
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

# Uninstall Metrics Server
helm uninstall metrics-server -n kube-system

# Uninstall Gatekeeper
kubectl delete -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-3.14/deploy/gatekeeper.yaml
```

---

## 🎉 Foundation Complete!

Congratulations! You have successfully set up your engineering platform foundation with:

✅ **Kubernetes cluster** ready for development
✅ **Grafana monitoring stack** with dashboards and metrics
✅ **OPA Gatekeeper** enforcing policy-as-code
✅ **Metrics Server** providing resource usage data
✅ **Health checks** and verification steps completed

## 🎯 Next Steps

Now that your foundation is solid, you can proceed to any of the specialized modules:

### Recommended Next Module: CapOc (Compliance at Point of Change)
**Path**: [`../capoc/README.md`](../capoc/README.md)
- Learn about CVE scanning and vulnerability management
- Implement code quality gates and enforcement
- Practice with constraint templates and policies

### Alternative Paths:

**Security Operations**: [`../secops/README.md`](../secops/README.md)
- Deploy Falco for runtime security monitoring
- Create custom security rules and alerts
- Monitor for security threats and anomalies

**Teams Management**: [`../teams-management/`](../teams-management/)
- Build RESTful APIs for team management
- Create command-line tools for developers
- Deploy full-stack applications with Angular UI

### Quick Reference

**Accessing Your Services:**
```bash
# Grafana Dashboard
kubectl port-forward -n monitoring service/grafana-stack-grafana 3000:80
# Then visit: http://<workspace-name>.coder:3000 (admin/admin123)

# Check all services
kubectl get services --all-namespaces

# Monitor cluster health
kubectl get pods --all-namespaces
```

**Key Files Created:**
- `grafana-stack-values.yaml` - Grafana configuration
- `simple-constraint-template.yaml` - Policy template
- `simple-constraint.yaml` - Namespace policy

Ready to continue your engineering platform journey? Choose your next module above! 🚀
