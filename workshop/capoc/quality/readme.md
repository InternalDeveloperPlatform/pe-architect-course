# ⚡ Quality Module - Code Coverage Enforcement

Welcome to the Quality Module! This hands-on exercise teaches you to implement automated code coverage quality gates that prevent undertested code from reaching production.

## 🎯 Learning Objectives

By completing this module, you will:
- Implement **code coverage quality gates** using OPA Gatekeeper policies
- Enforce **minimum coverage thresholds** to prevent low-quality deployments
- Create **commit-based coverage policies** using constraint templates
- Build **deployment quality constraints** that validate coverage data
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

In this module, you'll create code coverage quality controls:

1. **Code Coverage Template** - Ensures all deployments meet minimum code coverage thresholds
2. **Coverage Constraint** - Applies the template with coverage data and minimum requirements
3. **Test Scenarios** - Validate policies with passing and failing coverage deployments

## 📚 Understanding Quality Gates

### Why Code Coverage Gates Matter
- **Code Quality**: Prevent undertested code from reaching production
- **Shift Left**: Catch quality issues before deployment, not after incidents
- **Automated Enforcement**: No manual review needed for coverage compliance
- **Risk Reduction**: Higher coverage reduces the likelihood of production bugs

### How This Quality Gate Works
- **Commit SHA Tracking**: Deployments must include a `commit-sha` annotation
- **Coverage Lookup**: The constraint checks coverage data for the commit's SHA
- **Threshold Enforcement**: Deployments below the minimum coverage percentage are rejected

## 🚀 Step-by-Step Implementation

### Step 1: Deploy Code Coverage Constraint Template

First, create a template that enforces code coverage thresholds:

```bash
# Apply the code coverage constraint template
kubectl apply -f quality-constraint-template.yaml
```

**Verify the template is created**:
```bash
# Check that the template exists
kubectl get constrainttemplates

# You should see the new coverage template listed
# Example output:
# NAME                    AGE
# k8srequiredlabels      20m
# k8scvescanning         10m
# codecoveragesimple     10s
```

**What this template does**:
- Requires code coverage on all containers

### Step 2: Apply Quality Constraints

Now apply the constraint that enforces coverage thresholds:

```bash
# Apply code coverage constraint
kubectl apply -f quality-constraint.yaml
```

**Verify the constraint is active**:
```bash
# Check that the constraint exists
kubectl get constraints

# Look for your coverage constraint
# Example output:
# NAME                           AGE
# ns-must-have-gk               25m
# container-cve-scanning        15m
# enforce-code-coverage-simple  10s
```

**Understanding the constraint configuration**:
- **minimumCoverage**: The minimum code coverage percentage required (default: 80%)
- **coverageData**: A map of commit SHAs to their coverage percentages

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
# Verify the template exists
kubectl get constrainttemplates | grep codecoverage

# Verify the constraint is enforcing
kubectl get constraints | grep coverage

# Check constraint status for any issues
kubectl describe constraint enforce-code-coverage-simple
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
- [ ] Code coverage constraint is enforcing the minimum threshold
- [ ] Deployments with sufficient coverage **succeed** and run properly
- [ ] Deployments with low coverage are **rejected** with clear error messages
- [ ] You understand how to adjust coverage thresholds and coverage data

## 🚨 Troubleshooting

### Common Issues and Solutions

**Issue: All deployments blocked by coverage policy**
```bash
# Check if the minimum coverage is too strict
kubectl get constraint enforce-code-coverage-simple -o yaml

# Look at the parameters section
# Consider lowering minimumCoverage or adding coverage data for your commit SHA
```

**Issue: Missing commit-sha annotation**
```bash
# Ensure your deployment has the commit-sha annotation
# The constraint requires: metadata.annotations.commit-sha
# And the SHA must exist in the coverageData map
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
# Test with a deployment missing the commit-sha annotation
# If it passes, check that the constraint is active
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
# This should fail with "Missing required annotation: commit-sha"
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
- **Code Quality**: Coverage enforcement prevents undertested code from deploying
- **Automated Gates**: No manual review needed for coverage compliance
- **Developer Guidance**: Clear quality standards and feedback

Continue your engineering platform journey with the [SecOps module](../../secops/README.md) for runtime security monitoring! 🚀
