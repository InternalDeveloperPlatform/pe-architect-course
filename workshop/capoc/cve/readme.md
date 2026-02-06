# 🔍 CVE Module - Container Vulnerability Management

Welcome to the CVE (Common Vulnerabilities and Exposures) module! This hands-on exercise teaches you to implement automated container vulnerability scanning and policy enforcement using OPA Gatekeeper.

## 🎯 Learning Objectives

By completing this module, you will:
- Understand **container vulnerability risks** and mitigation strategies
- Implement **automated CVE scanning policies** with OPA Gatekeeper
- Create **vulnerability threshold controls** that block risky deployments
- Test **real-world scenarios** with vulnerable and safe container images
- Learn to **configure exceptions** for approved vulnerable images

## *IMPORTANT* Recommended extra learning

Keynote on this topic by one of the facilitators:

https://youtu.be/Vo8VCABNc24

## 📋 Prerequisites

**Required**:
- [Foundation module](../../foundation/README.md) completed
- [Main CapOc README](../README.md) reviewed

**Verify Setup**:
```bash
# Verify Gatekeeper is working
kubectl get pods -n gatekeeper-system

# All pods should be "Running"
# If not, complete Foundation module first
```

## 🏗️ What You'll Build

In this module, you'll create a complete CVE scanning pipeline:

1. **CVE Constraint Template** - Defines vulnerability scanning logic
2. **CVE Constraint** - Applies the template with specific thresholds
3. **Test Deployments** - Validate the policy with real examples

## 📚 Understanding CVE Scanning

### What are CVEs?
Common Vulnerabilities and Exposures (CVEs) are publicly disclosed security flaws in software packages. Container images often contain vulnerable libraries that could be exploited.

### Why Policy-Based CVE Management?
- **Preventive Security**: Block vulnerable images before deployment
- **Automated Compliance**: No manual review required
- **Consistent Standards**: Same rules across all environments
- **Developer Feedback**: Clear error messages when policies are violated

## 🚀 Step-by-Step Implementation

### Step 1: Deploy the CVE Constraint Template

First, let's create and apply the constraint template that defines our CVE scanning logic:

```bash
# Apply the CVE constraint template
kubectl apply -f cve-constraint-template.yaml
```

**Verify the template is created**:
```bash
# Check that the template exists
kubectl get constrainttemplates

# You should see the new CVE template listed
# Example output:
# NAME                    AGE
# k8srequiredlabels      10m
# k8scvescanning         1m
```

**What this template does**:
- Checks container images for known vulnerabilities
- Evaluates vulnerability severity levels (Critical, High, Medium, Low)
- Allows configuration of maximum acceptable vulnerability counts
- Provides detailed error messages when policies are violated

### Step 2: Apply the CVE Constraint

Next, apply the constraint that uses our template with specific parameters:

```bash
# Apply the CVE constraint with your desired settings
kubectl apply -f cve-constraint.yaml
```

**Verify the constraint is active**:
```bash
# Check that the constraint is created
kubectl get constraints

# Look for your CVE constraint
# Example output:
# NAME                           AGE
# ns-must-have-gk               15m
# container-cve-scanning        2m
```

**Understanding the constraint configuration**:
- **Scope**: Which resources are checked (e.g., Deployments, Pods)
- **Thresholds**: Maximum allowed vulnerabilities by severity
- **Exceptions**: Specific images that are exempt from the policy

### Step 3: Test with a Vulnerable Deployment

Now let's test our policy by trying to deploy a container with known vulnerabilities:

```bash
# This should FAIL - demonstrates the policy working
kubectl apply -f deployment.yaml
```

**Expected Result**:
```
Error from server (admission webhook denied):
Container image contains vulnerabilities exceeding policy thresholds:
- Critical: 2 (max allowed: 0)
- High: 5 (max allowed: 2)
```

**Understanding the failure**:
- The policy successfully blocked the deployment
- Clear error message explains why it was rejected
- Shows actual vs. allowed vulnerability counts

### Step 4: Test with a Safe Deployment

Now test with a deployment that meets our security standards:

```bash
# This should SUCCEED - demonstrates compliant image
kubectl apply -f deployment-working.yaml
```

**Expected Result**:
```
deployment.apps/secure-app created
```

**Verify the deployment**:
```bash
# Check that the pod is running
kubectl get pods

# You should see the secure-app pod in "Running" state
kubectl get deployment secure-app
```

### Step 5: View Deployment Details

Let's examine what makes each deployment different:

**Check the vulnerable deployment**:
```bash
# Review the vulnerable image details
cat deployment.yaml
```

**Check the safe deployment**:
```bash
# Review the safe image details
cat deployment-working.yaml
```

**Key differences you'll notice**:
- Different base images (outdated vs. recent)
- Different vulnerability counts
- Different update strategies

## ✅ Verification Steps

### Confirm CVE Policy is Working

**1. Template and Constraint Status**:
```bash
# Verify template exists
kubectl get constrainttemplates | grep -i vuln

# Verify constraint exists and is enforcing
kubectl get constraints | grep -i vuln

# Check constraint status for any issues
kubectl describe constraint -f cve-constraint.yaml
```

**2. Policy Enforcement Test**:
```bash
# Try deploying vulnerable image (should fail)
kubectl apply -f deployment.yaml

# Try deploying safe image (should succeed)
kubectl apply -f deployment-working.yaml

# Check successful deployment
kubectl get deployment secure-app
```

**3. Clean Up Test Resources**:
```bash
# Remove test deployments
kubectl delete -f deployment-working.yaml

# Vulnerable deployment should already be blocked, but try:
kubectl delete -f deployment.yaml --ignore-not-found=true
```

### Success Criteria ✅

Your CVE scanning is working correctly when:
- [ ] CVE constraint template exists
- [ ] CVE constraint is active and enforcing
- [ ] Vulnerable image deployment is **blocked** with clear error message
- [ ] Safe image deployment **succeeds** and runs
- [ ] Error messages clearly explain policy violations
- [ ] You understand how to adjust vulnerability thresholds

## 🎨 Customization Options

### Adjusting Vulnerability Thresholds

Edit your constraint to change acceptable risk levels:

```yaml
# Example threshold configuration
parameters:
  maxCritical: 0      # Block any critical vulnerabilities
  maxHigh: 2          # Allow up to 2 high-severity issues
  maxMedium: 10       # Allow up to 10 medium-severity issues
  maxLow: 50          # Allow up to 50 low-severity issues
```

### Adding Image Exceptions

For approved images that may contain acceptable vulnerabilities:

```yaml
# Example exception configuration
parameters:
  exemptImages:
    - "registry.company.com/approved-legacy-app:v1.2.3"
    - "docker.io/company/special-tool:*"
```

### Scope Customization

Adjust which resources are scanned:

```yaml
# Example scope configuration
spec:
  match:
    kinds:
      - apiGroups: ["apps"]
        kinds: ["Deployment", "DaemonSet"]
      - apiGroups: [""]
        kinds: ["Pod"]
```

## 🚨 Troubleshooting

### Common Issues and Solutions

**Issue: Constraint not enforcing**
```bash
# Check constraint status
kubectl describe constraint -f cve-constraint.yaml

# Look for errors in the status section
# Common causes: template syntax errors, invalid parameters
```

**Issue: All deployments blocked**
```bash
# Check if thresholds are too restrictive
kubectl get constraint -f cve-constraint.yaml -o yaml

# Consider adjusting maxHigh, maxMedium values
```

**Issue: Policy too permissive**
```bash
# Verify vulnerable images are actually being blocked
# Check constraint configuration for correct parameters
kubectl apply -f deployment-vulnerable.yaml
# This should fail if policy is working
```

**Issue: Template not found**
```bash
# Re-apply the constraint template
kubectl apply -f cve-constraint-template.yaml

# Verify it exists
kubectl get constrainttemplates
```

### Getting Help

If you're stuck:
1. **Review the constraint template** for syntax errors
2. **Check pod logs** for Gatekeeper components:
   ```bash
   kubectl logs -n gatekeeper-system deployment/gatekeeper-controller-manager
   ```
3. **Verify prerequisites** - ensure Foundation module is complete
4. **Test with simple policies** first, then add complexity

## 🎯 Next Steps

### Option 1: Continue with Quality Module
Path: [`../quality/readme.md`](../quality/readme.md)
- Build on your policy knowledge
- Add operational quality gates
- Complete the full compliance picture

### Option 2: Explore Advanced CVE Features
- Configure image scanning integrations
- Set up vulnerability notifications
- Create exception workflows

### Option 3: Move to Security Operations
Path: [`../../secops/README.md`](../../secops/README.md)
- Runtime security monitoring with Falco
- Threat detection and response
- Security incident management

## 🎉 Congratulations!

You've successfully implemented automated container vulnerability scanning with OPA Gatekeeper! Your engineering platform now:

✅ **Blocks vulnerable containers** before they reach production
✅ **Provides clear feedback** to developers about security issues
✅ **Enforces consistent security standards** across all deployments
✅ **Supports customizable risk thresholds** for different environments

Your containers are now much more secure! Continue with the [Quality Module](../quality/readme.md) to add operational excellence to your compliance controls. 🚀
