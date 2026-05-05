# 🛡️ CapOc - Compliance at the Point of Change

Welcome to the Compliance at Point of Change (CapOc) module! This module focuses on implementing automated compliance and quality controls that prevent issues before they reach production.

## 🎯 Learning Objectives

In this module, you will learn to:
- Implement **Container Vulnerability Scanning** with policy enforcement
- Create **Code Quality Gates** that prevent poor-quality deployments
- Build **Policy Templates** for automated compliance checking
- Set up **Proactive Security Controls** rather than reactive monitoring

## 📋 Prerequisites

**Required**: You must complete the [Foundation module](../foundation/README.md) first.

**Verify Prerequisites**:
```bash
# Verify OPA Gatekeeper is running
kubectl get pods -n gatekeeper-system

# Should show all gatekeeper pods in "Running" state
# If not working, complete the Foundation module first

# Verify constraint templates exist
kubectl get constrainttemplates

# Should show: k8srequiredlabels
```

## 🏗️ Module Structure

This module contains two hands-on sub-modules:

### 1. 🔍 CVE Module - Container Vulnerability Management

**What You'll Build**:
- CVE scanning constraint templates
- Vulnerability threshold policies
- Container image security gates

**Path**: [`./cve/readme.md`](./cve/readme.md)

---

### 2. ⚡ Quality Module - Code Coverage Enforcement

**What You'll Build**:
- Code coverage constraint templates
- Minimum coverage threshold policies
- Commit-based quality gates

**Path**: [`./quality/readme.md`](./quality/readme.md)

## 🚀 Getting Started

### Recommended Path

1. **Start with CVE Module**: Begin with [`./cve/readme.md`](./cve/readme.md)
   - More critical for security
   - Builds on Foundation concepts
   - Demonstrates real-world compliance needs

2. **Then Quality Module**: Continue with [`./quality/readme.md`](./quality/readme.md)
   - Reinforces policy concepts
   - Adds code coverage quality gates
   - Completes the compliance picture

### Alternative: Choose Your Focus

**Security-First Path**: Start with CVE module if vulnerability management is your priority

**Operations-First Path**: Start with Quality module if operational excellence is your focus

## 📚 Key Concepts

### Policy as Code
- **Constraint Templates**: Define the policy logic and validation rules
- **Constraints**: Apply templates to specific resources with parameters
- **Violations**: What happens when policies are not met

### Compliance at Point of Change
- **Preventive Controls**: Block non-compliant resources before deployment
- **Shift Left**: Catch issues early in the development process
- **Automated Enforcement**: No manual intervention required

## ✅ Module Completion Checklist

After completing both sub-modules, you should have:

### CVE Module ✅
- [x] CVE constraint template deployed
- [x] CVE constraint active and blocking vulnerable images
- [x] Successfully tested policy with vulnerable and safe images
- [x] Understanding of vulnerability thresholds and exceptions

### Quality Module ✅
- [x] Code coverage constraint template deployed
- [x] Coverage constraint active and blocking low-coverage commits
- [x] Successfully tested with passing and failing coverage scenarios
- [x] Understanding of code coverage policy enforcement

## 🔗 Navigation

**Previous Module**: [🏗️ Foundation](../foundation/README.md) - Complete this first!

**Next Modules**:
- [🔒 SecOps](../secops/README.md) - Security Operations and Monitoring
- [👥 Teams Management](../teams-management/) - Platform APIs and Developer Experience

**Back to Workshop**: [📋 Workshop Overview](../README.md)

---

## 🆘 Quick Troubleshooting

**Gatekeeper Not Working?**
```bash
# Check Gatekeeper status
kubectl get pods -n gatekeeper-system

# If issues, revisit Foundation module
# Path: ../foundation/README.md
```

**Policies Not Enforcing?**
```bash
# Verify constraint templates
kubectl get constrainttemplates

# Verify constraints
kubectl get constraints

# Check for errors
kubectl describe constraint <constraint-name>
```

Ready to implement compliance at the point of change? **Start with the [CVE Module](./cve/readme.md)** to secure your container deployments! 🚀
