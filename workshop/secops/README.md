# 🔒 SecOps - Security Operations & Runtime Monitoring

Welcome to the Security Operations (SecOps) module! This hands-on exercise teaches you to implement runtime security monitoring and threat detection using Falco, the CNCF runtime security project.

## 🎯 Learning Objectives

By completing this module, you will:
- Deploy **Falco runtime security monitoring** for real-time threat detection
- Implement **custom security rules** tailored to your environment
- Create **security constraints with OPA Gatekeeper** for preventive controls
- Test **security violations and alerting** scenarios
- Understand **runtime vs. admission-time security controls**

## 📋 Prerequisites

**Required**:
- [Foundation module](../foundation/README.md) completed
- Kubernetes cluster with sufficient permissions
- **Optional**: [CapOc modules](../capoc/README.md) for better policy context

**Verify Setup**:
```bash
# Verify Kubernetes cluster is ready
kubectl cluster-info

# Verify Gatekeeper is working (from Foundation)
kubectl get pods -n gatekeeper-system

# Check available resources
kubectl top nodes
```

## 🏗️ What You'll Build

In this module, you'll create a comprehensive security monitoring setup:

1. **Falco Runtime Security** - Real-time security monitoring and alerting
2. **Custom Security Rules** - Tailored threat detection for your environment
3. **Security Constraints** - Policy-based security controls with Gatekeeper
4. **Testing Scenarios** - Validate detection and prevention capabilities

## 📚 Understanding Runtime Security

### What is Falco?
Falco is a runtime security monitoring tool that uses system calls to detect anomalous activity and potential security threats in real-time. It's a graduated CNCF project trusted by organizations worldwide.

### Runtime vs. Admission-Time Security
- **Admission-Time** (Gatekeeper): Prevents bad things from being deployed
- **Runtime** (Falco): Detects bad things that are happening while running
- **Together**: Complete security coverage across the deployment lifecycle

### Why Runtime Monitoring Matters
- **Zero-Day Protection**: Detect unknown threats based on behavior
- **Insider Threats**: Monitor for malicious activities by authenticated users
- **Compliance**: Meet regulatory requirements for security monitoring
- **Incident Response**: Get real-time alerts for security investigations

## 🚀 Step-by-Step Implementation

### Step 1: Install Falco Runtime Security

First, let's deploy Falco with modern eBPF drivers for efficient monitoring:

```bash
# Add the Falco Helm repository
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update
```

```bash
# Install Falco with eBPF driver and gRPC output
helm install falco falcosecurity/falco \
  --namespace falco-system \
  --create-namespace \
  --set driver.kind=modern_ebpf \
  --set falcosidekick.enabled=true
```

**Verify Falco Installation**:
```bash
# Check that Falco pods are running
kubectl get pods -n falco-system

# Expected output:
# NAME          READY   STATUS    RESTARTS   AGE
# falco-xxxxx   2/2     Running   0          2m

# Verify Falco is monitoring
kubectl logs -n falco-system daemonset/falco | head -20
```

**What this deployment includes**:
- **eBPF Driver**: Modern, efficient kernel monitoring
- **gRPC Output**: Enable integrations with external systems
- **Default Rules**: Pre-configured security detection rules
- **DaemonSet**: Runs on every node for complete coverage

### Step 2: Test Basic Falco Detection

Let's verify Falco is working by triggering a basic security alert:

```bash
# This should generate security alerts - run a privileged container
kubectl run test-privileged \
  --image=busybox \
  --restart=Never \
  --rm -it \
  --overrides='{"spec":{"securityContext":{"privileged":true}}}' \
  -- sh
```

**Check for security alerts**:
```bash
# Exit the privileged container (type 'exit') then check logs
kubectl logs -n falco-system daemonset/falco | grep "Privileged container"

# You should see alerts about the privileged container
```

### Step 3: Deploy Custom Security Rules

Now let's add custom security rules for detecting specific threats:

```bash
# Create custom rule file and deploy with Falco
helm upgrade falco falcosecurity/falco \
  --namespace falco-system \
  --set driver.kind=modern_ebpf \
  --set falcosidekick.enabled=true \
  --set-file customRules."custom_rules\.yaml"=./root-detect-rule.yaml
```

**Verify custom rules are loaded**:
```bash
# Check Falco logs for rule loading
kubectl logs -n falco-system daemonset/falco | grep -i "rules"

# Should show custom rules being loaded
```

**Understanding the custom rule**:
The `root-detect-rule.yaml` contains rules for detecting:
- Root user executions in containers
- Suspicious file access patterns
- Network connections from containers
- Privilege escalation attempts

### Step 4: Add Security Constraint Template

Create a security constraint template that works with Falco:

```bash
# Apply security constraint template
kubectl apply -f constraint-template.yaml
```

**Verify the template**:
```bash
# Check that security template is created
kubectl get constrainttemplates | grep -i falco

# Should show the new security template
```

**What this template does**:
- Prevents deployment of privileged containers
- Requires security contexts for all containers
- Blocks containers running as root
- Enforces read-only root filesystems

### Step 5: Apply Security Constraint

Apply the constraint that uses our security template:

```bash
# Apply security constraint
kubectl apply -f constraint.yaml
```

**Verify constraint is enforcing**:
```bash
# Check that constraint exists and is active
kubectl get constraints | grep -i falco

# Check constraint status
kubectl describe constraint
```

### Step 6: Test Security Detection and Prevention

**Test 1: Runtime Detection (Falco)**
```bash
# This will be detected by Falco but allowed by Kubernetes
kubectl run test-curl \
  --image=curlimages/curl \
  --restart=Never \
  --rm -it \
  -- sh

# Inside the container, try these commands:
# whoami
# cat /etc/passwd
# nc -l 8080

# Exit and check Falco logs for detections
kubectl logs -n falco-system daemonset/falco | tail -20
```

**Test 2: Admission Prevention (Gatekeeper)**
```bash
# This should FAIL - blocked by security constraint
kubectl apply -f deployment.yaml

# Expected error about security policy violations
```

**Test 3: Compliant Deployment**
```bash
# This should SUCCEED - meets security requirements
kubectl apply -f deployment-works.yaml

# Verify deployment
kubectl get deployment secure-nonroot-app
```

## ✅ Verification Steps

### Confirm Complete Security Setup

**1. Falco Runtime Monitoring**:
```bash
# Verify Falco is running and monitoring
kubectl get pods -n falco-system
kubectl get daemonset -n falco-system

# Check Falco is generating logs
kubectl logs -n falco-system daemonset/falco | tail -10

# Verify custom rules are loaded
kubectl logs -n falco-system daemonset/falco | grep "custom_rules"
```

**2. Security Constraints**:
```bash
# Verify security constraint template exists
kubectl get constrainttemplates | grep -i falco

# Verify security constraint is enforcing
kubectl get constraints | grep -i falco

# Test constraint enforcement
kubectl apply -f deployment.yaml
# Should be blocked with security violations
```

**3. End-to-End Security Testing**:
```bash
# Test runtime detection
kubectl run security-test --image=busybox --rm -it -- sh
# Run: whoami, cat /etc/passwd, exit
# Check logs: kubectl logs -n falco-system daemonset/falco | tail -5

# Test admission prevention
kubectl apply -f deployment.yaml
# Should fail with security policy errors

# Test compliant deployment
kubectl apply -f deployment-works.yaml
# Should succeed
kubectl get deployment secure-nonroot-app
```

### Success Criteria ✅

Your security operations setup is working when:
- [ ] Falco pods are running on all nodes
- [ ] Falco generates alerts for suspicious activities
- [ ] Custom security rules are loaded and active
- [ ] Security constraint template exists
- [ ] Security constraints block non-compliant deployments
- [ ] Compliant deployments succeed and run
- [ ] You can correlate runtime alerts with deployment policies

## 🎨 Customization Options

### Custom Falco Rules

Add organization-specific detection rules in `custom_rules.yaml`:

```yaml
# Example custom rule
- rule: Suspicious Network Activity
  desc: Detect unexpected network connections
  condition: >
    spawned_process and container and
    proc.name in (nc, telnet, ncat) and
    not proc.args contains "allowed_host"
  output: >
    Suspicious network tool executed (user=%user.name container=%container.name
    image=%container.image.repository proc=%proc.cmdline)
  priority: WARNING
```

### Advanced Security Constraints

Extend security policies with additional requirements:

```yaml
# Example additional security parameters
parameters:
  allowPrivileged: false           # No privileged containers
  allowHostNetwork: false          # No host networking
  allowHostPID: false             # No host PID namespace
  requiredSecurityContext: true   # Must have security context
  allowedCapabilities: []         # No additional capabilities
  forbiddenSyscalls: ["mount", "umount"]  # Block dangerous syscalls
```

### Falco Output Integration

Configure Falco to send alerts to external systems:

```yaml
# Example output configuration
falco:
  json_output: true
  http_output:
    enabled: true
    url: "https://webhook.company.com/falco-alerts"
  program_output:
    enabled: true
    program: "curl -X POST https://slack.com/api/webhook..."
```

## 🚨 Troubleshooting

### Common Issues and Solutions

#### 1. Falco Pods Not Starting
**Symptoms**: Pods stuck in `Pending` or `CrashLoopBackOff`

**Diagnosis**:
```bash
# Check pod status and events
kubectl describe pod -n falco-system <falco-pod-name>

# Check node resources
kubectl top nodes

# Verify eBPF support
kubectl logs -n falco-system <falco-pod-name> | grep -i ebpf
```

**Solutions**:
```bash
# Try without eBPF driver if not supported
helm upgrade falco falcosecurity/falco \
  --namespace falco-system \
  --set driver.kind=module

# Or use kernel module instead
helm upgrade falco falcosecurity/falco \
  --namespace falco-system \
  --set driver.kind=kmod
```

#### 2. No Security Alerts Generated
**Symptoms**: Falco running but no alerts appear

**Diagnosis**:
```bash
# Check Falco configuration
kubectl logs -n falco-system daemonset/falco | grep -i "rules loaded"

# Test with known violation
kubectl run test-root --image=busybox --overrides='{"spec":{"securityContext":{"runAsUser":0}}}' --rm -it -- whoami
```

**Solutions**:
```bash
# Verify log output format
kubectl logs -n falco-system daemonset/falco --tail=50

# Check rule syntax
kubectl describe configmap -n falco-system falco
```

#### 3. Security Constraints Not Enforcing
**Symptoms**: Insecure deployments are allowed

**Diagnosis**:
```bash
# Check Gatekeeper status
kubectl get pods -n gatekeeper-system

# Verify constraint template
kubectl get constrainttemplates

# Check constraint configuration
kubectl describe constraint <constraint-name>
```

**Solutions**:
```bash
# Restart Gatekeeper if needed
kubectl rollout restart deployment -n gatekeeper-system gatekeeper-controller-manager

# Re-apply constraint template
kubectl apply -f security-constraint-template.yaml
```

#### 4. High Resource Usage
**Symptoms**: Falco consuming excessive CPU/memory

**Diagnosis**:
```bash
# Check resource usage
kubectl top pods -n falco-system

# Review Falco configuration
kubectl get configmap -n falco-system falco -o yaml
```

**Solutions**:
```bash
# Reduce rule complexity or frequency
helm upgrade falco falcosecurity/falco \
  --namespace falco-system \
  --set resources.requests.cpu=100m \
  --set resources.limits.memory=512Mi
```

### Performance Optimization

For production deployments:
```bash
# Optimize Falco for production
helm upgrade falco falcosecurity/falco \
  --namespace falco-system \
  --set driver.kind=modern_ebpf \
  --set resources.requests.cpu=200m \
  --set resources.requests.memory=256Mi \
  --set resources.limits.cpu=1000m \
  --set resources.limits.memory=1Gi \
  --set syscall_event_drops.max_burst=1000
```

## 🎯 Next Steps

### Option 1: Advanced Security Features
- **Alert Integration**: Connect Falco to Slack, PagerDuty, or SIEM
- **Custom Rules**: Develop organization-specific detection rules
- **Response Automation**: Automatically respond to security events

### Option 2: Complete Platform Experience
Continue with [Teams Management](../teams-management/) module:
- Build APIs for managing engineering teams
- Create developer-friendly CLI tools
- Deploy full-stack team management UI

### Option 3: Security Hardening
- Implement network policies for microsegmentation
- Add image vulnerability scanning automation
- Set up security compliance reporting

## 🎉 Congratulations!

You've successfully implemented a comprehensive security operations platform! Your environment now features:

✅ **Real-time Security Monitoring** with Falco detecting threats as they happen
✅ **Custom Security Rules** tailored to your specific threat model
✅ **Preventive Security Controls** blocking insecure deployments
✅ **Complete Coverage** from admission-time to runtime security
✅ **Production-Ready Monitoring** with alerting and logging capabilities

### What You've Achieved
- **Threat Detection**: Real-time monitoring for security violations
- **Preventive Controls**: Block insecure configurations before deployment
- **Compliance**: Meet security monitoring and alerting requirements
- **Incident Response**: Detailed logs and alerts for security investigations

Your engineering platform now provides defense in depth with both preventive and detective security controls!

**Ready for the next challenge?** Continue with the [Teams Management module](../teams-management/) to build developer-facing platform APIs and interfaces! 🚀
