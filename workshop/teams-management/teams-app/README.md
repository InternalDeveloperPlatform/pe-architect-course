# Engineering Platform - Teams Management UI

A modern Angular web application for managing engineering teams, designed to integrate with your Teams API and deploy seamlessly to Kubernetes.

## 🚀 Features

- **Team Creation**: Simple form to create new engineering teams
- **Team Management**: View, list, and delete existing teams
- **Real-time Updates**: Automatic refresh after team operations
- **Responsive Design**: Works on desktop and mobile devices
- **Kubernetes Ready**: Production-ready deployment configuration
- **Health Monitoring**: Built-in health checks and monitoring

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│                 │    │                 │    │                 │
│   Users/Teams   │───▶│   Angular UI    │───▶│   Teams API     │
│     Leaders     │    │   (Frontend)    │    │   (FastAPI)     │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                               │
                               ▼
                       ┌─────────────────┐
                       │                 │
                       │   Kubernetes    │
                       │    Cluster      │
                       │                 │
                       └─────────────────┘
```

## 📋 Prerequisites

- **Node.js** 18+ and npm
- **Docker** and Docker Compose
- **Kubernetes** cluster (minikube, kind, or cloud provider)
- **kubectl** configured to access your cluster
- **Angular CLI** (optional, for development)

## 🛠️ Quick Start

### 1. Clone and Setup

```bash
# Clone the repository
git clone <repository-url>
cd teams-ui

# Install dependencies
npm install
```

### 2. Local Development

```bash
# Start the development server with API proxy
npm run dev

# Or start normally (you'll need to update API URLs)
npm start
```

The application will be available at `http://localhost:4200`

### 3. Deploy to Kubernetes

```bash
# Make the deployment script executable
chmod +x deploy.sh

# Deploy everything
./deploy.sh deploy
```

## 📁 Project Structure

```
teams-ui/
├── src/
│   ├── app/
│   │   ├── components/
│   │   │   ├── team-form/          # Team creation form
│   │   │   └── team-list/          # Teams listing component
│   │   ├── models/
│   │   │   └── team.model.ts       # TypeScript interfaces
│   │   ├── services/
│   │   │   └── teams.service.ts    # API communication service
│   │   ├── app.component.*         # Root component
│   │   └── app.module.ts           # App module configuration
│   ├── environments/               # Environment configurations
│   ├── styles.css                  # Global styles
│   └── index.html                  # Main HTML file
├── k8s/                            # Kubernetes manifests
│   ├── namespace.yaml
│   ├── teams-ui-deployment.yaml
│   ├── teams-ui-service.yaml
│   ├── teams-api-deployment.yaml
│   ├── teams-api-service.yaml
│   └── ingress.yaml
├── Dockerfile                      # Multi-stage Docker build
├── nginx.conf                      # Nginx configuration
├── deploy.sh                       # Deployment script
└── package.json                    # Dependencies and scripts
```

## 🔧 Configuration

### Environment Variables

**Development** (`src/environments/environment.ts`):
```typescript
export const environment = {
  production: false,
  apiUrl: 'http://localhost:8000'
};
```

**Production** (`src/environments/environment.prod.ts`):
```typescript
export const environment = {
  production: true,
  apiUrl: 'http://teams-api-service:8000'  // Kubernetes service
};
```

### API Integration

The application integrates with your Teams API through the following endpoints:

- `GET /teams` - List all teams
- `POST /teams` - Create a new team
- `DELETE /teams/{team_id}` - Delete a team
- `GET /health` - Health check

## 🐳 Docker

### Build Image

```bash
# Build the Docker image
docker build -t teams-ui:latest .

# Run locally
docker run -p 8080:80 teams-ui:latest
```

### Multi-stage Build

The Dockerfile uses a multi-stage build:
1. **Build stage**: Compiles Angular application
2. **Runtime stage**: Serves with Nginx

## ☸️ Kubernetes Deployment

### Components

- **Namespace**: `engineering-platform`
- **Frontend**: Angular UI with Nginx (3 replicas)
- **Backend**: FastAPI Teams API (2 replicas)
- **Services**: ClusterIP services for internal communication
- **Ingress**: External access with CORS support

### Deployment Commands

```bash
# Deploy everything
./deploy.sh deploy

# Check status
./deploy.sh status

# Rollback
./deploy.sh rollback

# Clean up
./deploy.sh cleanup
```

### Access the Application

After deployment:

1. **Add to hosts file**:
   ```bash
   echo "127.0.0.1 engineering-platform.local" >> /etc/hosts
   ```

2. **Port forward** (for local clusters):
   ```bash
   kubectl port-forward -n ingress-nginx service/ingress-nginx-controller 8080:80
   ```

3. **Open browser**: `http://engineering-platform.local:8080`

## 🔍 Monitoring and Health Checks

### Health Endpoints

- **UI Health**: `GET /health` → Returns "healthy"
- **API Health**: `GET /health` → Returns status and team count

### Kubernetes Probes

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 80
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /health
    port: 80
  initialDelaySeconds: 5
  periodSeconds: 5
```

### Monitoring Commands

```bash
# Watch pods
kubectl get pods -n engineering-platform -w

# Check logs
kubectl logs -f deployment/teams-ui -n engineering-platform
kubectl logs -f deployment/teams-api -n engineering-platform

# Port forward for debugging
kubectl port-forward service/teams-ui-service 8080:80 -n engineering-platform
```

## 🎨 UI Features

### Team Creation Form
- **Validation**: Required field, minimum length
- **Error Handling**: Display API errors
- **Loading States**: Prevent double submission

### Team List
- **Real-time Updates**: Refresh after operations
- **Responsive Grid**: Adapts to screen size
- **Delete Confirmation**: Prevents accidental deletions
- **Empty States**: Helpful messaging when no teams exist

### Responsive Design
- **Mobile First**: Works on all screen sizes
- **Modern Styling**: Clean, professional interface
- **Loading Indicators**: Clear feedback for async operations

## 🛡️ Security

### CORS Configuration
```yaml
nginx.ingress.kubernetes.io/cors-allow-origin: "*"
nginx.ingress.kubernetes.io/cors-allow-methods: "GET, POST, PUT, DELETE, OPTIONS"
nginx.ingress.kubernetes.io/cors-allow-headers: "Content-Type, Authorization"
```

### Resource Limits
```yaml
resources:
  requests:
    memory: "64Mi"
    cpu: "50m"
  limits:
    memory: "128Mi"
    cpu: "100m"
```

## 🐛 Troubleshooting

### Common Issues

**1. API Connection Issues**
```bash
# Check if API service is running
kubectl get pods -n engineering-platform
kubectl logs deployment/teams-api -n engineering-platform

# Test API connectivity
kubectl exec -it deployment/teams-ui -n engineering-platform -- wget -qO- http://teams-api-service:8000/health
```

**2. UI Not Loading**
```bash
# Check UI pod logs
kubectl logs deployment/teams-ui -n engineering-platform

# Verify nginx configuration
kubectl exec -it deployment/teams-ui -n engineering-platform -- cat /etc/nginx/conf.d/default.conf
```

**3. Build Issues**
```bash
# Clear npm cache
npm cache clean --force

# Rebuild
rm -rf node_modules dist
npm install
npm run build
```

### Development Tips

- Use `npm run dev` for development with API proxy
- Check browser network tab for API call issues
- Use Angular DevTools browser extension for debugging
- Monitor pod logs in real-time during development

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📝 License

This project is licensed under the MIT License.

---

## 📞 Support

For issues and questions:
- Check the troubleshooting section above
- Review Kubernetes pod logs
- Verify API connectivity
- Check ingress and service configurations

Happy team management! 🎉
