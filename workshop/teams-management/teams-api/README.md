# 🚀 Teams API - RESTful Team Management Service

A fast, lightweight RESTful API service for managing engineering teams. Built with FastAPI, this service provides CRUD operations for team management with JSON responses and automatic API documentation.

## 🎯 Overview

The Teams API provides:
- **CRUD Operations**: Create, Read, Update, Delete teams
- **RESTful Design**: Standard HTTP methods and status codes
- **JSON API**: Clean JSON request/response format
- **Health Monitoring**: Built-in health check endpoint
- **Auto Documentation**: Interactive API docs with Swagger UI
- **Kubernetes Ready**: Production deployment configurations

## 📋 Prerequisites

**Required Software**:
- **Kubernetes cluster** with kubectl access
- **Container runtime** (Docker recommended for local development)
- **Network connectivity** for container image pulls

**Recommended Setup**:
- Complete the [Foundation module](../../foundation/README.md) first
- Have a Kubernetes namespace ready for deployment

**Verify Prerequisites**:
```bash
# Check Kubernetes access
kubectl cluster-info

# Verify you can create resources
kubectl auth can-i create deployments

# Check available resources
kubectl top nodes
```

## 🏗️ Architecture

The Teams API consists of:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│                 │    │                 │    │                 │
│   API Clients   │───▶│   Teams API     │───▶│   Data Storage  │
│  (CLI, UI, curl)│    │  (FastAPI)      │    │  (In-memory)    │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                               │
                               ▼
                       ┌─────────────────┐
                       │                 │
                       │   Kubernetes    │
                       │   Service       │
                       │                 │
                       └─────────────────┘
```

## 🚀 Quick Start Deployment

### Option 1: Using Pre-built Container Images

The easiest way to get started uses the pre-built container images:

```bash
# Create namespace for the API
kubectl create namespace teams-api

# Deploy the Teams API using pre-built images
kubectl apply -f deployment.yaml
```

**Container Images Available**:
- **Docker Hub**: `olivercodes01/teams-api:latest`
- **Registry**: https://hub.docker.com/u/olivercodes01

### Option 2: Local Development Setup

For development and customization:

```bash
# Clone and navigate to the API directory
cd teams-management/teams-api

# Build your own container image
docker build -t teams-api:local .

# Deploy with local image
kubectl apply -f deployment.yaml
# (Modify deployment to use teams-api:local)
```

### Verify Deployment

```bash
# Check that pods are running
kubectl get pods -n teams-api

# Expected output:
# NAME                         READY   STATUS    RESTARTS   AGE
# teams-api-xxxxxxxx-xxxxx     1/1     Running   0          2m

# Check service is created
kubectl get svc -n teams-api

# Expected output:
# NAME               TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
# teams-api-service  ClusterIP   10.96.xxx.xxx  <none>        80/TCP    2m
```

## 🌐 Accessing the API

### Local Development Access

For local development and testing:

```bash
# Port forward the service to your local machine
kubectl port-forward -n teams-api svc/teams-api-service 8080:4200

# Keep this terminal open and use a new terminal for API calls
# The API will be available at: http://<workspace-name>.coder:3002
```

**Verify the port forward is working**:
```bash
# Test basic connectivity
curl http://<workspace-name>.coder:3002/health

# Expected response:
# {"status": "healthy", "teams_count": 0}
```

### Production Access

For production deployments, consider:

- **Ingress Controller**: Expose via ingress for external access
- **Load Balancer**: Use LoadBalancer service type
- **Service Mesh**: Integrate with Istio or similar

## 📚 API Documentation

### Interactive Documentation

Once the API is running, access the interactive documentation:

```bash
# With port forwarding active, open in browser:
# http://localhost:8080/docs

# Or access the ReDoc version:
# http://localhost:8080/redoc
```

### Observability

Go to your Grafana instance ( http://<workspace-name>.coder:3000/grafana )

Navigate to: Kubernetes / Compute Resources / Namespace (Workloads)
Select "Engineering Platform" in the Namspace dropdown.

Here you will see our engineering platform deployed pods and workloads.

### API Endpoints

| Method | Endpoint | Description | Example |
|--------|----------|-------------|---------|
| GET | `/health` | Health check | `curl localhost:8080/health` |
| GET | `/teams` | List all teams | `curl localhost:8080/teams` |
| POST | `/teams` | Create new team | `curl -X POST ... (see below)` |
| GET | `/teams/{id}` | Get specific team | `curl localhost:8080/teams/{id}` |
| DELETE | `/teams/{id}` | Delete team | `curl -X DELETE localhost:8080/teams/{id}` |

## 🧪 API Usage Examples

### Health Check

Always start by verifying the API is healthy:

```bash
curl http://localhost:8080/health

# Expected response:
{
  "status": "healthy",
  "teams_count": 0
}
```

### Creating Teams

Create a new engineering team:

```bash
curl -X POST "http://localhost:8080/teams" \
     -H "Content-Type: application/json" \
     -d '{"name": "Backend Team"}'

# Expected response:
{
  "id": "fc9402c5-2b26-41b2-8b97-ccdefdc65fe7",
  "name": "Backend Team",
  "created_at": "2025-01-15T10:30:45.123456"
}
```

**Creating multiple teams**:
```bash
# Create several teams for your organization
curl -X POST "http://localhost:8080/teams" -H "Content-Type: application/json" -d '{"name": "Frontend Team"}'
curl -X POST "http://localhost:8080/teams" -H "Content-Type: application/json" -d '{"name": "DevOps Team"}'
curl -X POST "http://localhost:8080/teams" -H "Content-Type: application/json" -d '{"name": "QA Team"}'
curl -X POST "http://localhost:8080/teams" -H "Content-Type: application/json" -d '{"name": "Data Team"}'
```

### Listing Teams

Retrieve all teams:

```bash
curl http://localhost:8080/teams

# Expected response:
[
  {
    "id": "fc9402c5-2b26-41b2-8b97-ccdefdc65fe7",
    "name": "Backend Team",
    "created_at": "2025-01-15T10:30:45.123456"
  },
  {
    "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "name": "Frontend Team",
    "created_at": "2025-01-15T10:31:22.654321"
  }
]
```

### Getting Specific Team

Retrieve details for a specific team:

```bash
# Replace with actual team ID from the list response
curl http://localhost:8080/teams/fc9402c5-2b26-41b2-8b97-ccdefdc65fe7

# Expected response:
{
  "id": "fc9402c5-2b26-41b2-8b97-ccdefdc65fe7",
  "name": "Backend Team",
  "created_at": "2025-01-15T10:30:45.123456"
}
```

### Deleting Teams

Remove a team that's no longer needed:

```bash
curl -X DELETE http://localhost:8080/teams/fc9402c5-2b26-41b2-8b97-ccdefdc65fe7

# Expected response:
{
  "message": "Team 'Backend Team' deleted successfully"
}
```

### Error Handling

The API returns appropriate HTTP status codes:

```bash
# Try to get a non-existent team
curl -i http://localhost:8080/teams/invalid-id

# Response includes:
# HTTP/1.1 404 Not Found
# {"detail": "Team not found"}

# Try to create team with invalid data
curl -X POST http://localhost:8080/teams -H "Content-Type: application/json" -d '{}'

# Response includes:
# HTTP/1.1 422 Unprocessable Entity
# {"detail": [{"loc": ["body", "name"], "msg": "field required"}]}

# Try to create a team with a duplicate name
curl -X POST http://localhost:8080/teams -H "Content-Type: application/json" -d '{"name": "Backend Team"}'

# Response includes:
# HTTP/1.1 400 Bad Request
# {"detail": "Team name already exists"}
```

## 🔧 Configuration Options

### Environment Variables

The API supports configuration through environment variables:

```yaml
# Example deployment configuration
env:
  - name: PORT
    value: "8000"
  - name: HOST
    value: "0.0.0.0"
  - name: LOG_LEVEL
    value: "info"
  - name: CORS_ORIGINS
    value: "*"
```

### Resource Limits

For production deployments, configure appropriate resource limits:

```yaml
# Example resource configuration
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

## 🚨 Troubleshooting

### Common Issues and Solutions

#### 1. Pod Not Starting

**Symptoms**: Pod stuck in `Pending`, `ImagePullBackOff`, or `CrashLoopBackOff`

**Diagnosis**:
```bash
# Check pod status and events
kubectl describe pod -n teams-api <pod-name>

# Check logs
kubectl logs -n teams-api <pod-name>

# Check node resources
kubectl top nodes
```

**Solutions**:
```bash
# If image pull issues, verify image exists
docker pull olivercodes01/teams-api:latest

# If resource issues, check cluster capacity
kubectl describe nodes

# If permission issues, check RBAC
kubectl auth can-i create pods --namespace teams-api
```

#### 2. Service Not Accessible

**Symptoms**: Cannot connect to the API through port forwarding

**Diagnosis**:
```bash
# Check service exists and has endpoints
kubectl get svc -n teams-api
kubectl get endpoints -n teams-api

# Check if port forwarding is active
lsof -i :8080
```

**Solutions**:
```bash
# Restart port forwarding
kubectl port-forward -n teams-api svc/teams-api-service 8080:4200

# Try different local port if 8080 is busy
kubectl port-forward -n teams-api svc/teams-api-service 8081:4200

# Check firewall or network restrictions
```

#### 3. API Returning Errors

**Symptoms**: API responds with 500 Internal Server Error

**Diagnosis**:
```bash
# Check API logs
kubectl logs -f -n teams-api deployment/teams-api

# Check API health endpoint
curl -v http://localhost:8080/health
```

**Solutions**:
```bash
# Restart the deployment
kubectl rollout restart deployment/teams-api -n teams-api

# Check for configuration issues
kubectl describe deployment/teams-api -n teams-api
```

#### 4. Performance Issues

**Symptoms**: Slow API responses or timeouts

**Diagnosis**:
```bash
# Check resource usage
kubectl top pods -n teams-api

# Test API response time
time curl http://localhost:8080/health
```

**Solutions**:
```bash
# Increase resource limits
kubectl patch deployment teams-api -n teams-api -p '{"spec":{"template":{"spec":{"containers":[{"name":"teams-api","resources":{"limits":{"cpu":"1000m","memory":"1Gi"}}}]}}}}'
```

### Health Monitoring

Set up monitoring to catch issues early:

```bash
# Create a monitoring script
cat > monitor-api.sh << 'EOF'
#!/bin/bash
while true; do
    if ! curl -f -s http://localhost:8080/health > /dev/null; then
        echo "$(date): API health check failed"
        # Add alerting logic here
    fi
    sleep 30
done
EOF

chmod +x monitor-api.sh
```

## 🧪 Testing the API

### Manual Testing Workflow

Complete test sequence to verify everything works:

```bash
# 1. Health check
curl http://localhost:8080/health

# 2. List teams (should be empty initially)
curl http://localhost:8080/teams

# 3. Create a team
team_response=$(curl -s -X POST "http://localhost:8080/teams" -H "Content-Type: application/json" -d '{"name": "Test Team"}')
echo $team_response

# 4. Extract team ID for next steps
team_id=$(echo $team_response | jq -r '.id')
echo "Created team with ID: $team_id"

# 5. List teams again (should show the created team)
curl http://localhost:8080/teams

# 6. Get specific team
curl http://localhost:8080/teams/$team_id

# 7. Delete the team
curl -X DELETE http://localhost:8080/teams/$team_id

# 8. Verify deletion (should be empty again)
curl http://localhost:8080/teams
```

### Automated Testing

Create a simple test script:

```bash
cat > test-api.sh << 'EOF'
#!/bin/bash
set -e

BASE_URL="http://localhost:8080"
echo "Testing Teams API at $BASE_URL"

# Test health endpoint
echo "✅ Testing health endpoint..."
curl -f $BASE_URL/health > /dev/null

# Test team creation
echo "✅ Testing team creation..."
response=$(curl -s -X POST "$BASE_URL/teams" -H "Content-Type: application/json" -d '{"name": "Test Team"}')
team_id=$(echo $response | jq -r '.id')

# Test team listing
echo "✅ Testing team listing..."
curl -f $BASE_URL/teams > /dev/null

# Test team deletion
echo "✅ Testing team deletion..."
curl -f -X DELETE $BASE_URL/teams/$team_id > /dev/null

echo "🎉 All tests passed!"
EOF

chmod +x test-api.sh
./test-api.sh
```

## 🎯 Next Steps

### Integration with Other Components

1. **Teams CLI**: Use the [CLI tool](../cli/README.md) for command-line team management
2. **Teams UI**: Deploy the [web interface](../teams-app/README.md) for GUI-based management
3. **Monitoring**: Integrate with your monitoring stack for observability

### Development and Customization

- **Add Features**: Extend the API with team member management, permissions, etc.
- **Database Integration**: Replace in-memory storage with persistent database
- **Authentication**: Add authentication and authorization
- **Rate Limiting**: Implement rate limiting for production use

### Production Considerations

- **High Availability**: Deploy multiple replicas with load balancing (note that this module demo does not have a database, so you will need to implement one prior to scaling up replicas)
- **Data Persistence**: Use external database for data storage
- **Security**: Implement HTTPS, authentication, and input validation
- **Monitoring**: Add metrics, logging, and health checks

## 📝 Important Notes

### Team Naming Recommendations

**⚠️ Important**: For the workshop exercises, avoid spaces in team names if you plan to use the CLI or UI components. Use formats like:
- ✅ `BackendTeam` or `Backend-Team` or `backend_team`
- ❌ `Backend Team` (spaces can cause issues in subsequent workshop steps)

### Data Persistence

The current API uses in-memory storage, which means:
- **Data is lost** when the pod restarts
- **Not suitable for production** without external database
- **Perfect for learning** and development environments

## ✅ Verification Checklist

Your Teams API setup is complete when:
- [ ] API pods are running in the teams-api namespace
- [ ] Port forwarding works and you can access localhost:8080
- [ ] Health check returns 200 OK status
- [ ] You can create, list, and delete teams via curl
- [ ] Interactive API docs are accessible at /docs
- [ ] Error handling works (try invalid requests)

**Ready to manage teams with your API!** 🚀 Your RESTful service is now ready for integration with CLI tools and web interfaces.
