## Capstone

Welcome to the capstone project — you are near the end!

Please follow the guidance in the presentation for expectations.

### Scope

The capstone focuses on demonstrating your ability to integrate the platform components you have built throughout this course. You are expected to work with the **Teams** feature specifically — do not try to build additional features or services beyond what is asked for below. Depth over breadth is what we are looking for.

### Capstone Requirements

1. Deployment of an API
2. Deployment of a new Gatekeeper policy
3. Deployment of an application that adheres to the new policy

### Deployment Requirements

Our SRE team has said they want to start requiring all teams to use Argo Rollouts to create their deployments.
This will ensure the eventual usage of Canary or Blue/Green patterns, which is more resilient and consistent
for creating stable releases.

As the platform engineer, you are tasked with writing the first draft of the Gatekeeper constraint that prevents
engineers from deploying to production without an Argo rollout defined for their deployment.

You must also demonstrate the functionality of the new feature of the platform by deploying an API via Argo Rollouts,
so that other teams may see an initial starting point for how to configure their own.

### Pre-Flight Checklist

Before starting the capstone, verify each of these items. Resolving these upfront will save significant debugging time.

```bash
# 1. Verify your cluster is healthy
kubectl cluster-info
kubectl get nodes
kubectl top nodes

# 2. Verify Gatekeeper is running and constraints are applied
kubectl get pods -n gatekeeper-system
kubectl get constraints

# 3. Verify the Teams API is running and reachable
kubectl get pods -n teams-api
kubectl port-forward -n teams-api svc/teams-api-service 8080:4200
curl http://localhost:8080/health

# 4. Verify DNS resolution works for your access method
# If using sslip.io:
nslookup teams-api.127.0.0.1.sslip.io
# If using Coder Desktop:
nslookup <workspace-name>.coder

# 5. If using Keycloak for authentication, verify it is running and the realm is loaded
kubectl get pods -n keycloak
kubectl port-forward -n keycloak svc/keycloak-service 8080:8080
# Then open http://localhost:8080/realms/teams in your browser — you should get a JSON response
# If the realm is missing, check that the keycloak-realm-config ConfigMap exists:
kubectl get configmap keycloak-realm-config -n keycloak
# If it is missing, create it from teams-realm.json and restart the Keycloak pod

# 6. If using Keycloak, verify CORS origins include your access URL
# Check teams-realm.json for webOrigins — it must include the URL you use to access the Teams UI
# For Coder Desktop: add http://<workspace-name>.coder:4200
# For port-forward: add http://localhost:4200
```

### Deploy Argo Rollouts

```bash
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
```

Verify the installation worked:

```bash
kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-rollouts/master/docs/getting-started/basic/rollout.yaml
kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-rollouts/master/docs/getting-started/basic/service.yaml

# Check the status of the deployment rollout
kubectl describe rollout
```

Add the Kubectl Argo Rollouts plugin to your Kubectl:

https://argo-rollouts.readthedocs.io/en/stable/installation/#kubectl-plugin-installation

```bash
# Verify the install worked
kubectl argo rollouts get rollout rollouts-demo --watch
```

Take a look at the Argo Rollouts dashboard:

```bash
kubectl argo rollouts dashboard

# Note: verify you can see the demo application deployed.
```

### Checklist

1. Configure and Deploy Argo Rollouts (see their docs)
2. Build a simple RESTful API, containerize it, and push it to DockerHub (don't forget to tag it)
3. Configure a Kubernetes deployment of your new RESTful API
4. Push the deployment to production, using Argo Rollouts Blue/Green or Canary
5. Verify your deployment in the Argo Rollouts dashboard and Grafana

Bonus content: configure a new Grafana dashboard for the Argo Rollouts.

### Minimum Viable Capstone

To meet the requirements, your capstone must demonstrate:
- An API deployed and reachable in your cluster
- A Gatekeeper constraint that enforces Argo Rollout usage for production deployments
- The API deployed via an Argo Rollout (Blue/Green or Canary) that passes your constraint
- Verification in both the Argo dashboard and Grafana

### Optional Extensions (Not Required)

If you finish early and want to go further:
- Add Keycloak authentication to the Teams UI
- Extend the Teams Operator to provision ResourceQuotas or NetworkPolicies per team namespace
- Integrate a real CVE scanner (Trivy, Grype) to replace the static vulnerability data in the CVE constraint
- Add a custom Grafana dashboard showing deployment metrics from Argo Rollouts

### Capstone Troubleshooting

**Keycloak shows a blank page or "Timeout waiting for 3rd party check iframe message":**
This is almost always a CORS issue. Open your browser DevTools (Console and Network tabs) to confirm. Then update the `webOrigins` and `redirectUris` in `teams-realm.json` to include your actual access URL, recreate the ConfigMap, and restart the Keycloak pod.

**Gatekeeper blocks your own platform components:**
This is intentional — your platform components must comply with the same policies you enforce on developers. Common fixes: switch to `nginxinc/nginx-unprivileged` for web deployments, ensure all containers specify `runAsUser` with a non-root UID, and check the CVE constraint's `allowedImages` list.

**Images not found when deploying to kind:**
After building a Docker image locally, you must load it into the kind cluster:
```bash
kind load docker-image <image-name>:<tag> --name 5min-idp
```

**In-memory data loss:**
The Teams API uses in-memory storage. If the API pod restarts, all team data is lost. For the capstone demo, create your test teams just before presenting, or extend the API with a persistent backend.
