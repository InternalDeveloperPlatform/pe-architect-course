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
cd teams-app

# In coder install node first
curl -fsSL https://deb.nodesource.com/setup_24.x | sudo -E bash -
sudo apt install -y nodejs

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
teams-app/
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
  apiUrl: 'http://teams-api.127.0.0.1.sslip.io'
};
```

**Production** (`src/environments/environment.prod.ts`):
```typescript
export const environment = {
  production: true,
  apiUrl: 'http://teams-api-service:4200'  // Kubernetes service
};
```

> ⚠️ **Keycloak URL lives in two places.** Besides `environment.ts` above, `src/app/config/keycloak.config.ts` has its **own separate, hardcoded** `url` for Keycloak. If you change one and not the other, login will silently keep failing. See [Troubleshooting](#-troubleshooting) for the full list of places to keep in sync.

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

1. **Via ingress** (if ingress-nginx is running):
   The active ingress serves the UI at `http://teams-ui.127.0.0.1.sslip.io` (sslip.io resolves to 127.0.0.1 automatically — no hosts file needed).

2. **Via port-forward** (recommended for most students):
   ```bash
   kubectl port-forward -n engineering-platform service/teams-ui-service 8080:80
   ```
   Then open `http://<workspace-name>.coder:8080`

### 🪟 Windows 11 + Coder (without Coder Connect / Coder Desktop)

If you're on Windows 11 Pro and can't get **Coder Connect / Coder Desktop** to reliably resolve the workspace hostname (`http://<workspace-name>.coder`), use the **two-hop port-forward pattern** below instead. It's confirmed working end-to-end (API + UI + Keycloak login).

**Pattern (per service):**

1. Inside the **Coder workspace**, forward the Kubernetes service to a local port with `kubectl port-forward`.
2. On **Windows PowerShell**, forward that same port from the workspace to your machine with `coder port-forward`.
3. Open `http://localhost:<port>` in your Windows browser.

Run all of these **in parallel** (one terminal/PowerShell window each):

| Service | In the workspace | In Windows PowerShell | Browser URL |
|---|---|---|---|
| Teams API | `kubectl port-forward -n teams-api svc/teams-api-service 8080:4200` | `coder port-forward <workspace> --tcp 8080:8080` | `http://localhost:8080` |
| Teams UI (deployed to k8s) | `kubectl port-forward -n engineering-platform service/teams-ui-service 8081:80` | `coder port-forward <workspace> --tcp 8081:8081` | `http://localhost:8081` |
| Teams UI (dev, `ng serve` / `npm start`) | *(runs natively in the workspace, not a k8s service)* | `coder port-forward <workspace> --tcp 4200:4200` | `http://localhost:4200` |
| Keycloak | `kubectl port-forward -n keycloak svc/keycloak-service 8082:8080` | `coder port-forward <workspace> --tcp 8082:8082` | `http://localhost:8082` |
| Grafana (optional) | `kubectl port-forward -n monitoring service/grafana-stack 3000:80` | `coder port-forward <workspace> --tcp 3000:3000` | `http://localhost:3000` |

> Both the deployed UI (8081) and the dev-server UI (4200) work — pick whichever fits your workflow. Just make sure the port you use is present in Keycloak's `webOrigins`/`redirectUris` for the `teams-ui` client (see Troubleshooting below).

With this pattern you don't need `sslip.io` DNS, ingress, or Coder Connect at all — everything resolves through `localhost` on Windows.

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
kubectl exec -it deployment/teams-ui -n engineering-platform -- wget -qO- http://teams-api-service:4200/health
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

### Keycloak login fails / blank screen / "Timeout waiting for 3rd party check iframe message"

This usually means Keycloak's expected URL and the URL you're actually accessing the app from **don't match**. There are **4 different places** that all need to agree on the access method (`localhost:<port>` for the two-hop Windows pattern, or `<workspace>.coder` / `*.sslip.io` for other setups) — and they're easy to get out of sync:

1. **`k8s/keycloak-deployment.yaml`** — `KC_HOSTNAME` env var. If you're accessing Keycloak through more than one method (ingress, `*.coder`, `localhost` via port-forward), the simplest fix is to **remove `KC_HOSTNAME` entirely** and keep `KC_HOSTNAME_STRICT=false`. Keycloak then derives its URL dynamically from the incoming `Host` header instead of a fixed value, so it works regardless of how you're accessing it.
2. **Keycloak realm's `webOrigins` / `redirectUris`** (client `teams-ui`, in `keycloak-realm-config` ConfigMap or applied live). Needs every origin/URL you'll actually use — e.g. `http://localhost:4200`, `http://localhost:8081`. If you already imported the realm once, editing the ConfigMap and restarting the pod **won't apply the change** (Keycloak's import strategy is "ignore if already exists"). Update the live client instead with `kcadm.sh`:
   ```bash
   kubectl exec -n keycloak deployment/keycloak -- /opt/keycloak/bin/kcadm.sh config credentials \
     --server http://localhost:8080 --realm master --user admin --password admin

   kubectl exec -n keycloak deployment/keycloak -- /opt/keycloak/bin/kcadm.sh get clients -r teams -q clientId=teams-ui --fields id
   # copy the returned id, then:
   kubectl exec -n keycloak deployment/keycloak -- /opt/keycloak/bin/kcadm.sh update clients/<CLIENT-UUID> -r teams \
     -s 'webOrigins=["http://localhost:8081","http://localhost:4200"]' \
     -s 'redirectUris=["http://localhost:8081/*","http://localhost:4200/*"]'
   ```
3. **`src/environments/environment.ts`** — `apiUrl` and `keycloak.url` need to point at the ports you're actually using (e.g. `http://localhost:8080` for the API, `http://localhost:8082` for Keycloak).
4. **`src/app/config/keycloak.config.ts`** — ⚠️ **this is the one that's easy to miss.** It has its own hardcoded Keycloak `url`, separate from `environment.ts`. Changing `environment.ts` alone will **not** fix your login if this file still points at the old URL (e.g. `http://platform-auth.127.0.0.1.sslip.io`). Update it to match, e.g.:
   ```typescript
   const keycloakConfig: KeycloakConfig = {
     url: 'http://localhost:8082',
     realm: 'teams',
     clientId: 'teams-ui',
   };
   ```

**Bonus tip:** if `npm start` / `ng serve` seems to hang with no output in the Coder workspace, add `"cli": { "analytics": false }` to `angular.json`. Without it, Angular CLI can wait on an interactive analytics prompt that never resolves in a non-interactive terminal.

### Known bugs in the workshop material (as of Aug 2026)

- **`keycloak.yaml` — missing `---` separator.** The file defines the Keycloak `Deployment` twice: once with basic CORS settings, and again further down labeled `# k8s/keycloak-deployment.yaml (Enhanced with comprehensive CORS)`. There's no `---` document separator between the end of the `keycloak-realm-config` ConfigMap and the start of the "Enhanced" Deployment, so `kubectl apply -f keycloak.yaml` fails to parse (duplicate keys in a single YAML document). Add a `---` before the `# k8s/keycloak-deployment.yaml (Enhanced with comprehensive CORS)` comment.
- **Unfilled placeholder in `webOrigins`.** The realm's `teams-ui` client ships with a literal, never-filled-in placeholder: `"http://fernando-pe-arch.coder:<port>"` in `webOrigins` (and a similar pattern in `post.logout.redirect.uris`). This needs to be replaced with a real origin (or removed) before the realm import is usable as-is.

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

## 🎯 Next Steps

### Integration Options
1. **Full Stack Deployment**: Deploy with the [Teams API](../teams-api/README.md) for complete functionality
2. **CLI Integration**: Use the [Teams CLI](../cli/README.md) for automated team management
3. **Monitoring**: Integrate with monitoring stack for observability

### Advanced Features
Consider extending the UI with:
- Team member management interface
- Role-based access control
- Team analytics and reporting
- Integration with external systems

### Production Deployment
For production use:
- Configure HTTPS with proper SSL certificates
- Set up authentication and authorization
- Implement proper logging and monitoring
- Use external database for data persistence
- Configure backup and disaster recovery

## ✅ Success Checklist

Your Teams UI is working correctly when:
- [ ] All pods are running in engineering-platform namespace
- [ ] UI is accessible via ingress or port forwarding
- [ ] Can connect to Teams API successfully
- [ ] Can create, view, and delete teams through the interface
- [ ] Health check endpoint responds correctly
- [ ] Error handling provides user-friendly messages
- [ ] Responsive design works on different screen sizes

## 📞 Support & Additional Resources

### Getting Help
For issues and questions:
1. **Check the troubleshooting section above** for common solutions
2. **Review Kubernetes pod logs** for error details:
   ```bash
   kubectl logs -f deployment/teams-ui -n engineering-platform
   ```
3. **Verify API connectivity** is working:
   ```bash
   kubectl exec -it deployment/teams-ui -n engineering-platform -- curl http://teams-api-service:4200/health
   ```
4. **Check ingress and service configurations** for networking issues:
   ```bash
   kubectl describe ingress -n engineering-platform
   kubectl get svc -n engineering-platform
   ```

### Related Documentation
- **Workshop Overview**: [Main README](../../README.md)
- **Teams API**: [API Documentation](../teams-api/README.md)
- **Teams CLI**: [CLI Documentation](../cli/README.md)
- **Foundation Setup**: [Foundation README](../../foundation/README.md)

### Community Resources
- [Angular Documentation](https://angular.io/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Docker Documentation](https://docs.docker.com/)
- [Nginx Configuration Guide](https://nginx.org/en/docs/)

---

**Happy team management!** 🎉 Your full-stack team management platform is now ready for production use. You've built a complete engineering platform with monitoring, security, compliance, and team management capabilities!
