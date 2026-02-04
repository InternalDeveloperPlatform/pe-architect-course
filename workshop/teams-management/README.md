# 👥 Teams Management - Engineering Platform APIs & Developer Experience

Welcome to the Teams Management module! This comprehensive module teaches you to build a complete engineering platform with APIs, CLI tools, and web interfaces for managing engineering teams. You'll learn to create developer-friendly tools that make platform operations simple and scalable.

## TODO

- add docs on operator install
- do a runthrough with these updated docs

## 🎯 Learning Objectives

By completing this module, you will:
- Build **RESTful APIs** for engineering team management with FastAPI
- Create **command-line tools** for developers and automation
- Deploy **full-stack web applications** with modern Angular UI
- Implement **complete CRUD workflows** from API to UI
- Understand **platform engineering principles** for developer experience
- Learn **Kubernetes-native application deployment** patterns

## 📋 Prerequisites

**Required**:
- [Foundation module](../foundation/README.md) completed
- Basic understanding of APIs and web applications
- **Recommended**: Complete at least one of [CapOc](../capoc/README.md) or [SecOps](../secops/README.md) modules

**Verify Prerequisites**:
```bash
# Verify Kubernetes cluster is ready
kubectl cluster-info

# Check available resources
kubectl top nodes

# Verify you can create namespaces and deployments
kubectl auth can-i create namespaces
kubectl auth can-i create deployments
```

## 🏗️ Module Architecture

This module implements a complete 3-tier application stack:

```
┌─────────────────────────────────────────────────────────────────┐
│                        🌐 User Interfaces                        │
├─────────────────────────┬───────────────────────────────────────┤
│     📱 Web UI           │        🛠️ CLI Tool                    │
│   (Angular + Nginx)     │     (Python CLI)                      │
│   Port: 4200            │   teams-cli command                   │
└─────────────────────────┴───────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────┐
│                       🚀 Teams API                               │
│                    (FastAPI + Python)                            │
│                      Port: 8080                                  │
└─────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────┐
│                   📊 Data Storage                                │
│                 (In-memory store)                                │
│              Production: External Database                       │
└─────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────┐
│                  ☸️ Kubernetes Platform                         │
│             Services, Deployments, Ingress                       │
└─────────────────────────────────────────────────────────────────┘
```

## 📚 Module Components

### 1. 🚀 Teams API (`teams-api/`)
**Duration**: ~20-30 minutes
**Technology**: FastAPI, Python

**What You'll Build**:
- RESTful API with full CRUD operations
- Automatic API documentation with Swagger UI
- Health monitoring and error handling
- Kubernetes deployment configurations

**Key Features**:
- Create, read, update, delete teams
- JSON API responses
- Built-in health checks
- Container-ready deployment

**Path**: [`./teams-api/README.md`](./teams-api/README.md)

---

### 2. 🛠️ Teams CLI (`cli/`)
**Duration**: ~15-25 minutes
**Technology**: Python, Click framework

**What You'll Build**:
- Command-line interface for team management
- Scriptable automation tools
- Multi-environment support
- Developer-friendly commands

**Key Features**:
- `teams-cli create "Team Name"`
- `teams-cli list` and `teams-cli get <id>`
- `teams-cli delete <id>` with confirmation
- Health checking and connectivity tests

**Path**: [`./cli/README.md`](./cli/README.md)

---

### 3. 📱 Teams Web UI (`teams-app/`)
**Duration**: ~30-40 minutes
**Technology**: Angular, TypeScript, Nginx

**What You'll Build**:
- Modern web application for team management
- Responsive design for desktop and mobile
- Real-time updates and error handling
- Production-ready deployment

**Key Features**:
- Interactive team creation forms
- Team listing with search and filtering
- Delete operations with confirmations
- Health monitoring dashboard

**Path**: [`./teams-app/README.md`](./teams-app/README.md)

## 🚀 Quick Start Guide

### Recommended Learning Path

Follow this sequence for the best learning experience:

**Step 1: Deploy the Teams API** (Start Here)
```bash
cd teams-api
# Follow the teams-api/README.md guide
```

**Step 2: Set up the CLI Tool**
```bash
cd cli
# Follow the cli/README.md guide
```

**Step 3: Deploy the Web UI**
```bash
cd teams-app
# Follow the teams-app/README.md guide
```

### Alternative: Deploy Everything at Once

For experienced users who want to see the complete stack:

```bash
# Deploy all components in sequence
kubectl apply -f teams-api/k8s/
kubectl apply -f teams-app/k8s/

# Set up CLI tool
cd cli
pip install -r requirements.txt
chmod +x teams_cli.py

# Verify everything is working
kubectl get pods --all-namespaces | grep teams
```

## 🧪 End-to-End Testing Workflow

Once all components are deployed, test the complete workflow:

### 1. API Testing
```bash
# Port forward the API
kubectl port-forward -n teams-api svc/teams-api-service 8080:80

# Test API endpoints
curl http://localhost:8080/health
curl -X POST "http://localhost:8080/teams" -H "Content-Type: application/json" -d '{"name": "TestTeam"}'
```

### 2. CLI Testing
```bash
# Test CLI commands
python cli/teams_cli.py health
python cli/teams_cli.py list
python cli/teams_cli.py create "CLI Test Team"
```

### 3. Web UI Testing
```bash
# Port forward the UI (if using port-forward)
kubectl port-forward -n engineering-platform svc/teams-ui-service 4200:80

# Open browser to http://localhost:4200
# Test creating, viewing, and deleting teams through the interface
```

## 🎯 Integration Scenarios

### Scenario 1: Developer Onboarding
```bash
# New developer joins, needs to create a team
python teams_cli.py create "Mobile App Team"

# Verify through web UI
# Add team members through future enhancements
```

### Scenario 2: Automated Team Management
```bash
# CI/CD pipeline creates teams for new projects
#!/bin/bash
for project in "ProjectA" "ProjectB" "ProjectC"; do
    python teams_cli.py create "$project Team"
done

# Generate reports
python teams_cli.py list --output json > team_report.json
```

### Scenario 3: Platform Self-Service
```bash
# Teams manage themselves through web interface
# Platform team monitors through API health checks
curl http://teams-api.internal/health

# Grafana dashboards show team creation metrics
# (Future enhancement with monitoring integration)
```

## ✅ Module Completion Checklist

### Teams API ✅
- [ ] API pods running in teams-api namespace
- [ ] Health endpoint responding (200 OK)
- [ ] Can create teams via curl/Postman
- [ ] Can list and delete teams via API
- [ ] Interactive API docs accessible at /docs

### Teams CLI ✅
- [ ] CLI dependencies installed successfully
- [ ] Can connect to Teams API
- [ ] Can create, list, and delete teams via CLI
- [ ] Global command works (if configured)
- [ ] Error handling provides clear feedback

### Teams Web UI ✅
- [ ] UI pods running in engineering-platform namespace
- [ ] Web interface accessible via browser
- [ ] Can create teams through web form
- [ ] Can view team list and details
- [ ] Can delete teams with confirmation
- [ ] Responsive design works on different screen sizes

### Integration Testing ✅
- [ ] Same team data visible across all interfaces
- [ ] Changes in one interface reflect in others
- [ ] All components can communicate with API
- [ ] Health checks pass for all components
- [ ] Can demonstrate complete team lifecycle

## 🚨 Troubleshooting

### Common Issues Across Components

#### 1. API Connection Issues
**Symptoms**: CLI or UI cannot connect to API

**Diagnosis**:
```bash
# Check API pod status
kubectl get pods -n teams-api

# Test API connectivity
curl http://localhost:8080/health

# Check port forwarding
lsof -i :8080
```

**Solutions**:
```bash
# Restart port forwarding
kubectl port-forward -n teams-api svc/teams-api-service 8080:80

# Check API logs
kubectl logs -f deployment/teams-api -n teams-api
```

#### 2. Data Inconsistency
**Symptoms**: Different data showing in CLI vs UI

**Diagnosis**:
```bash
# Verify all components use same API endpoint
# Check API logs for all requests
kubectl logs -f deployment/teams-api -n teams-api
```

**Solutions**:
```bash
# Restart API to clear in-memory data
kubectl rollout restart deployment/teams-api -n teams-api

# Verify API URL configuration in all components
```

#### 3. Deployment Issues
**Symptoms**: Pods not starting or crashing

**Diagnosis**:
```bash
# Check all component deployments
kubectl get pods --all-namespaces | grep teams

# Describe failed pods
kubectl describe pod <pod-name> -n <namespace>
```

**Solutions**:
```bash
# Check resource constraints
kubectl top nodes

# Verify images are accessible
docker pull olivercodes01/teams-api:latest
```

### Component-Specific Troubleshooting

For detailed troubleshooting of individual components, refer to:
- [Teams API Troubleshooting](./teams-api/README.md#-troubleshooting)
- [CLI Troubleshooting](./cli/README.md#-troubleshooting)
- [Web UI Troubleshooting](./teams-app/README.md#-troubleshooting)

## 🎯 Next Steps & Extensions

### Immediate Next Steps
1. **Complete Integration Testing**: Verify all components work together
2. **Explore API Documentation**: Visit http://localhost:8080/docs
3. **Customize for Your Needs**: Modify team data structure
4. **Monitor Performance**: Watch resource usage and response times

### Advanced Extensions

#### 1. Add Authentication
```bash
# Implement JWT tokens
# Add user management
# Secure API endpoints
```

#### 2. Database Integration
```bash
# Replace in-memory storage
# Add PostgreSQL or MongoDB
# Implement data persistence
```

#### 3. Enhanced Features
```bash
# Add team member management
# Implement team permissions
# Add team analytics and reporting
# Integration with external systems (Slack, GitHub, etc.)
```

#### 4. Production Readiness
```bash
# Add HTTPS/TLS
# Implement rate limiting
# Add comprehensive logging
# Set up monitoring and alerting
# Configure backup and recovery
```

### Integration with Platform Components

#### Monitoring Integration
```bash
# Add metrics to Grafana (from Foundation module)
# Create team creation/deletion dashboards
# Monitor API performance and errors
```

#### Security Integration
```bash
# Integrate with security policies (from SecOps module)
# Add team-based RBAC
# Implement audit logging
```

#### Compliance Integration
```bash
# Ensure team operations follow policies (from CapOc module)
# Add compliance reporting
# Implement automated policy checks
```

## 📖 Learning Resources

### Platform Engineering Concepts
- **Developer Experience**: How to build tools developers love
- **API Design**: RESTful principles and best practices
- **CLI Design**: Creating intuitive command-line interfaces
- **Web UI/UX**: Modern frontend development patterns

### Technologies Used
- **FastAPI**: Modern Python web framework
- **Angular**: Frontend framework for web applications
- **Click**: Python CLI framework
- **Docker**: Containerization
- **Kubernetes**: Container orchestration

### Related Documentation
- **Workshop Overview**: [Main README](../README.md)
- **Foundation Setup**: [Foundation README](../foundation/README.md)
- **Security Operations**: [SecOps README](../secops/README.md)
- **Compliance Controls**: [CapOc README](../capoc/README.md)

## 🎉 Congratulations!

Upon completing this module, you will have built a complete engineering platform with:

✅ **RESTful API** with comprehensive team management capabilities  
✅ **Command-line tools** for developers and automation  
✅ **Modern web interface** for self-service operations  
✅ **Kubernetes deployment** patterns for production use  
✅ **End-to-end workflows** from API to user interface  

### What You've Learned
- **Platform Engineering**: How to build developer-centric tools
- **Full-Stack Development**: API, CLI, and web UI integration
- **Kubernetes Applications**: Deploying and managing multi-tier applications
- **Developer Experience**: Creating intuitive, scriptable tools
- **System Integration**: Connecting multiple components seamlessly

**Ready to build platforms that developers love?** 🚀 Your teams management system is now a foundation for building comprehensive engineering platforms that scale with your organization!

---

**Need help?** Check the individual component README files for detailed instructions and troubleshooting, or reach out to the workshop facilitators.
