# Engineering Platform Workshop

Welcome to the companion repo for PlatformEngineering.org Architect! This hands-on set of mini-projects will have you do exercises for building platform concepts you learn about in the course with monitoring, policy management, security operations, and team management capabilities.

## DOCS and MODULE TODOS

- Size(small): Test and update guide on using coder.com proxy (accessing grafana and teams app ui)
- Size(small): Change docs and source from using Traefik Ingress to Nginx Ingress (or modify k8s spinup to put traefik)
- Size(small): Run end to end through updated docs, checking for errors/mistakes/not working things/etc.
- Size(medium): Verify/Modify Keycloak deployment in last module to work with coder.com environment
- Size(small): Migrate repos/code to peorg github repos and off personal
- Size(small): update coder.com template code to reference new github url after this repo is moved to peorg github
- Size(medium): reference back to workshop content (i.e. little context sections "when you learned about x, this is relevant to it" etc.)
- Size(medium): create helper cli script, that lets users deploy/teardown foundation setup or other modules automatically, so they can catchup to current module if they missed a week and need to jump to current


## 🎯 Learning Objectives

By the end of this workshop, you will:
- Set up a complete Kubernetes-based engineering platform
- Implement policy-as-code with Open Policy Agent (OPA) Gatekeeper
- Configure monitoring and alerting with Grafana stack
- Deploy security monitoring with Falco
- Build and manage engineering teams through APIs and UIs

## 📋 System Requirements

Before starting, ensure your system meets these requirements:
- Decent internet connection recommended for accessing coder.com environments

Optional:
- Visual Studio Code has a coder.com remote extension, where you can access your coder.com environment from your local VS Code instead of using it in the browser.

### Required Software
- None: We will use coder.com environments

### Verify Prerequisites
```bash
# Check Docker
docker --version

# Check Kubernetes
kubectl cluster-info

# Check Helm
helm version

# Check Python
python3 --version

# Check Node.js
node --version
```

## 🚀 Getting Started

**⚠️ IMPORTANT: Start with the Foundation module first!**

1. **Begin Here**: Navigate to [`foundation/README.md`](foundation/README.md)
2. Complete all foundation setup before proceeding to other modules
3. Follow the modules in the recommended order below

## 📚 Workshop Modules

### 1. 🏗️ Foundation (`foundation/`) - **START HERE**

Contains the fundamental setup for your Kubernetes environment including:
- Kubernetes cluster verification
- Grafana monitoring stack installation
- OPA Gatekeeper policy engine setup
- Initial health checks and verification

**Key Deliverables:**
- Functioning Kubernetes cluster
- Grafana dashboard accessible
- Gatekeeper policies working

---

### 2. 🛡️ CapOc (`capoc/`) - Compliance at Point of Change
**Prerequisites**: Foundation module completed

Focuses on implementing compliance and quality controls:
- **CVE Module**: Container vulnerability scanning and policies
- **Quality Module**: Code quality gates and enforcement

**Key Deliverables:**
- CVE scanning policies active
- Quality gates preventing bad deployments
- Working constraint templates and policies

---

### 3. 🔒 SecOps (`secops/`) - Security Operations

Dedicated to security monitoring and threat detection:
- Falco runtime security monitoring
- Custom security rules and alerts
- Security policy enforcement

**Key Deliverables:**
- Falco deployed and monitoring
- Security alerts working
- Custom security rules active

---

### 4. 👥 Teams Management (`teams-management/`) - Platform APIs & UX

In-depth module covering engineering platform APIs and developer experience:
- **Teams API**: RESTful API for team management
- **CLI Tool**: Command-line interface for teams
- **Web UI**: Angular-based team management interface
- **Custom Kubernetes Controller**: Responds to the teams api being used and creates/edits/destroys team namespaces based on the state of teams in the api

**Key Deliverables:**
- Working Teams API with CRUD operations
- Functional CLI tool
- Web UI for team management
- Complete end-to-end team lifecycle

## ✅ Module Completion Checklist

### Foundation ✅
- [ ] Kubernetes cluster accessible
- [ ] Grafana dashboard working
- [ ] Gatekeeper policies deployed
- [ ] All health checks passing

### CapOc ✅
- [ ] CVE scanning active
- [ ] Quality policies enforced
- [ ] Constraint templates working

### SecOps ✅
- [ ] Falco monitoring active
- [ ] Security alerts configured
- [ ] Custom rules deployed

### Teams Management ✅
- [ ] Teams API responding
- [ ] CLI tool functional
- [ ] Web UI accessible
- [ ] End-to-end team workflow working
- [ ] Kubernetes operator deployed and working (responds/creates team namespaces based on api usage)

## 🆘 Troubleshooting & Support

### Common Issues

**Kubernetes Connection Issues**
```bash
# Verify cluster connection
kubectl cluster-info
kubectl get nodes

# Check cluster resources
kubectl top nodes
kubectl get pods --all-namespaces
```

**Resource Constraints**
```bash
# Check resource usage
kubectl top nodes
kubectl describe nodes

# Scale down components if needed
kubectl scale deployment <deployment-name> --replicas=1
```

**Port Conflicts**
- Grafana: Default port 3000
- Teams UI: Default port 4200
- Teams API: Default port 8080

### Getting Help

1. **Check module-specific README files** for detailed troubleshooting
2. **Review pod logs** for specific error messages:
   ```bash
   kubectl logs <pod-name> -n <namespace>
   ```
3. **Verify prerequisite installations** before proceeding
4. **Reach out to facilitators** for assistance

## 📖 Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [OPA Gatekeeper Guide](https://open-policy-agent.github.io/gatekeeper/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Falco Documentation](https://falco.org/docs/)

---

**Ready to begin?** 🎯 Head to the [`foundation/README.md`](foundation/README.md) to start your engineering platform journey!
