# ⚡ Quality Module - Code Quality Enforcement

Welcome to the Quality Module! This hands-on exercise teaches you to implement automated operational quality gates that ensure deployments follow best practices and organizational standards.

## 🎯 Learning Objectives

By completing this module, you will:
- Implement **operational quality gates** using OPA Gatekeeper policies
- Enforce **resource limits and requirements** to prevent resource exhaustion
- Create **naming convention policies** for consistent infrastructure
- Build **deployment best practice constraints** for operational excellence
- Test **policy violations and compliance** scenarios

## *IMPORTANT* Recommended extra learning

Keynote on this topic by one of the facilitators:

https://youtu.be/Vo8VCABNc24

## 📋 Prerequisites

**Required**:
- [Foundation module](../../foundation/README.md) completed
- [Main CapOc README](../README.md) reviewed
- **Optional**: [CVE module](../cve/readme.md) for better context

**Verify Setup**:
```bash
# Verify Gatekeeper is working
kubectl get pods -n gatekeeper-system

# All pods should be "Running"
# Verify existing constraints
kubectl get constraints
```

## 🏗️ What You'll Build

In this module, you'll create operational quality controls:

1. **Resource Limits Template** - Ensures all deployments have proper resource constraints
2. **Naming Convention Template** - Enforces consistent naming patterns
3. **Quality Constraints** - Apply the templates with specific organizational rules
4. **Test Scenarios** - Validate policies with compliant and non-compliant deployments

## 📚 Understanding Quality Gates

### Why Quality Gates Matter
- **Resource Management**: Prevent deployments from consuming unlimited resources
- **Operational Consistency**: Ensure all deployments follow the same patterns
- **Cost Control**: Avoid runaway processes that consume expensive compute resources
- **Debugging Support**: Consistent naming makes troubleshooting easier

### Types of Quality Controls
- **Resource Constraints**: CPU and memory limits/requests
- **Naming Conventions**: Consistent labeling and naming patterns
- **Security Standards**: Non-root users, read-only filesystems
- **Operational Metadata**: Required labels for monitoring and management

## 🚀 Step-by-Step Implementation

### Step 1: Deploy Resource Limits Constraint Template

First, create a template that enforces proper resource management:

```bash
# Apply the resource limits constraint template
kubectl apply -f quality-constraint-template.yaml
```

**Verify the template is created**:
```bash
# Check that the template exists
kubectl get constrainttemplates

# You should see the new resource template listed
# Example output:
# NAME                    AGE
# k8srequiredlabels      20m
# k8scvescanning         10m
# codecoveragesimple     10s
```

**What this template does**:
- Requires code coverage on all containers

### Step 2: Apply Quality Constraints

Now apply the constraints that use our templates with specific rules:

```bash
# Apply coverage limits constraint
kubectl apply -f quality-constraint.yaml
```

**Verify constraints are active**:
```bash
# Check that both constraints exist
kubectl get constraints

# Look for your quality constraints
# Example output:
# NAME                           AGE
# ns-must-have-gk               25m
# container-cve-scanning        15m
# enforce-code-coverage-simple  10s
```

**Understanding the constraint configurations**:
- **coverage Limits**: code coverage minimum requirements

### Step 3: Test with Non-Compliant Deployment

Test the policy with a deployment that violates quality standards:

```bash
# This should FAIL - demonstrates quality gates working
kubectl apply -f deployment.yaml
```

**Expected Result**:
```
Error from server (admission webhook denied):
Deployment violates quality standards
```

**Understanding the failure**:
- Quality violations detected
- Clear feedback on what needs to be fixed
- Prevents low-quality deployments from reaching the cluster

### Step 4: Test with Compliant Deployment

Now test with a deployment that meets all quality standards:

```bash
# This should SUCCEED - demonstrates compliant deployment
kubectl apply -f deployment-working.yaml
```

**Expected Result**:
```
deployment.apps/frontend-service created
```

**Verify the deployment**:
```bash
# Check that the pod is running
kubectl get pods -l app=my-app

# Check deployment details
kubectl get deployment my-app -o yaml
```

### Step 6: Examine Quality Differences

Compare the deployments to understand quality standards:

**Review the non-compliant deployment**:
```bash
# Review what makes this deployment fail
cat deployment.yaml
```

**Review the compliant deployment**:
```bash
# Review the proper quality standards
cat deployment-working.yaml
```

**Key differences you'll notice**:
- **Inspect the Sha**: the sha for the working image has met the quality requirement

## ✅ Verification Steps

### Confirm Quality Gates are Working

**1. Template and Constraint Status**:
```bash
# Verify both templates exist
kubectl get constrainttemplates | grep -E "(resource|naming)"

# Verify both constraints are enforcing
kubectl get constraints | grep -E "(resource|naming)"

# Check constraint status for any issues
kubectl describe constraint <constraint name>
```

**2. Policy Enforcement Testing**:
```bash
# Test compliant deployment
kubectl apply -f deployment-working.yaml
# Should succeed

# Check successful deployment
kubectl get deployment my-app
```

**4. Clean Up Test Resources**:
```bash
# Remove successful deployment
kubectl delete -f deployment-working.yaml

# Bad deployments should already be blocked
kubectl delete -f deployment.yaml --ignore-not-found=true
```

### Success Criteria ✅

Your quality gates are working correctly when:
- [ ] Quality constraints are enforcing policies
- [ ] Compliant deployments **succeed** and run properly
- [ ] Error messages clearly explain policy violations
- [ ] You understand how to adjust quality standards

## 🚨 Troubleshooting

### Common Issues and Solutions

**Issue: All deployments blocked by resource policies**
```bash
# Check if resource requirements are too strict
kubectl get constraint <name> -o yaml

# Look at the parameters section
# Consider lowering minimum requirements or raising maximum limits
```

**Issue: Valid names rejected by naming policy**
```bash
# Check naming pattern requirements
kubectl describe constraint <name>

# Verify your deployment names match the required pattern
# Common issue: underscores not allowed, only hyphens
```

**Issue: Constraint not enforcing**
```bash
# Check constraint status
kubectl describe constraint <constraint-name>

# Look for errors in status section
# Common causes: template errors, parameter mismatches
```

**Issue: Policies too permissive**
```bash
# Test with obviously bad deployments
# If they pass, check constraint parameters
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-no-commit-sha-provided
spec:
  selector:
    matchLabels:
      app: test
  template:
    metadata:
      labels:
        app: test
    spec:
      containers:
      - name: app
        image: nginx
EOF
# This should fail if policies are working
```

### Getting Help

If you encounter issues:
1. **Check template syntax** - YAML formatting is crucial
2. **Verify constraint parameters** - ensure they match template expectations
3. **Test incrementally** - start with simple policies, add complexity
4. **Check Gatekeeper logs**:
   ```bash
   kubectl logs -n gatekeeper-system deployment/gatekeeper-controller-manager
   ```

## 🎯 Next Steps

### Option 1: Explore Other Workshop Modules
- **Security Operations**: [`../../secops/README.md`](../../secops/README.md)
  - Runtime security monitoring with Falco
  - Security threat detection and alerting

- **Teams Management**: [`../../teams-management/`](../../teams-management/)
  - Build APIs for engineering teams
  - Create CLI tools and web interfaces

### Option 2: Advanced Quality Gates
- **Image Policy**: Enforce approved container registries
- **Network Policy**: Ensure proper network isolation
- **Backup Policy**: Require backup annotations
- **Monitoring Policy**: Enforce observability standards

### Option 3: Integration with CI/CD
- Configure policies in build pipelines
- Pre-deployment validation
- Policy-as-code version control
- Automated policy testing

## 🎉 Congratulations!

You've successfully implemented comprehensive quality gates for your engineering platform! Your deployments now:

✅ **Block low-quality deployments** before they cause issues
✅ **Provide clear feedback** to developers on quality standards
✅ **Support customizable rules** for different environments

Your platform now ensures operational excellence automatically!

### What You've Achieved
- **Improved Quality**: Improved quality reduces outags
- **Cost Control**: Resource constraints prevent waste
- **Developer Guidance**: Clear quality standards and feedback

Continue your engineering platform journey with the [SecOps module](../../secops/README.md) for runtime security monitoring! 🚀
