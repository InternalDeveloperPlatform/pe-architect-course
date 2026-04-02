# Troubleshooting Guide

This guide consolidates known issues and their solutions, drawn from real student experiences. Check here first before reaching out to facilitators.

---

## Environment & Coder Setup

### kubectl bash completion not working

**Symptom**: Running `kubectl <tab>` produces `bash: _get_comp_words_by_ref: command not found`.

**Fix**:
```bash
echo "source /etc/bash_completion" >> ~/.bashrc
source ~/.bashrc
```

**Note**: This fix may not survive a Coder workspace restart because the container image is rebuilt. If completions stop working after a restart, re-run the commands above.

---

### kubectl top returns "Metrics API not available"

**Symptom**: `kubectl top nodes` fails with an error about the Metrics API.

**Cause**: The metrics-server is not installed by default in the Coder environment.

**Fix**:
```bash
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update
helm upgrade --install metrics-server metrics-server/metrics-server \
  --namespace kube-system \
  --set args={--kubelet-insecure-tls}

# Wait 30-60 seconds for metrics to become available, then test
kubectl top nodes
```

The `--kubelet-insecure-tls` flag is required in lab environments where the kubelet does not have a valid TLS certificate.

---

### Git remote pointing to outdated repository

**Symptom**: `git pull` does not include recent fixes or merged PRs.

**Diagnosis**:
```bash
git remote -v
# If you see olivercodes/pe-coder-aidp, the remote is outdated
```

**Fix**:
```bash
git remote set-url origin https://github.com/InternalDeveloperPlatform/pe-architect-course.git
git pull
```

---

### SSL certificate expired for sandbox.platformengineering.org

**Symptom**: Browser shows a certificate error or Coder Desktop cannot connect.

**Workaround**: This requires the infrastructure team to renew the certificate. Reach out to the facilitators in Slack. In the meantime, you can continue working if you have an active terminal session in the Coder workspace (the SSH connection is not affected by the web certificate).

---

### Coder Desktop not available on Linux

**Symptom**: Coder Desktop only supports macOS and Windows.

**Workaround**: Use the Coder CLI to forward ports:
```bash
# Forward a single port
coder port-forward <workspace-name> --tcp 3000:3000

# Forward multiple ports
coder port-forward <workspace-name> --tcp 3000:3000 --tcp 4200:4200 --tcp 8080:8080
```

Access all services via `http://localhost:<port>`. When instructions reference `http://<workspace-name>.coder:<port>`, substitute `http://localhost:<port>`.

---

## Grafana & Monitoring (Foundation Module)

### Cannot access Grafana dashboard

**Symptom**: `http://<workspace-name>.coder:3000` does not load.

**Diagnosis**:
```bash
# Check Grafana pod is running
kubectl get pods -n monitoring | grep grafana

# Check port-forward is active
lsof -i :3000
```

**Fix**:
```bash
# Restart the port-forward
kubectl port-forward -n monitoring service/grafana-stack 3000:80

# If port 3000 is in use, try a different local port
kubectl port-forward -n monitoring service/grafana-stack 3001:80
```

Default credentials: `admin` / `admin123`

---

## Falco & SecOps Module

### Falco pods not starting

**Symptom**: Falco pods stuck in `Pending` or `CrashLoopBackOff`.

**Diagnosis**:
```bash
kubectl describe pod -n falco-system <falco-pod-name>
kubectl logs -n falco-system <falco-pod-name>
```

**Common causes and fixes**:

If eBPF is not supported on your kernel:
```bash
helm upgrade falco falcosecurity/falco \
  --namespace falco-system \
  --set driver.kind=module
```

---

### Custom Falco rules failing to load

**Symptom**: Falco logs show `LOAD_ERR_YAML_VALIDATE: Rules content is not yaml array of objects`.

**Cause**: The rules file is formatted as a Kubernetes ConfigMap rather than a raw Falco rules YAML file. When using `--set-file` with Helm, the file must be a plain YAML array of Falco rule objects, not wrapped in a ConfigMap.

**Fix**: Ensure `root-detect-rule.yaml` is a plain YAML file starting with `- rule:`, not `apiVersion: v1 / kind: ConfigMap`. The current repository version has been corrected.

---

### Gatekeeper blocks test pods in Step 6

**Symptom**: After applying security constraints, the `test-curl` or `busybox` pods from Step 6 are rejected by Gatekeeper because they run as root.

**Explanation**: This is expected behavior. Gatekeeper (admission control) and Falco (runtime detection) are two separate layers. Gatekeeper prevents non-compliant pods from starting. Falco only monitors pods that are already running. Once Gatekeeper is active, it will block the same violations that Falco would have detected at runtime.

To test Falco independently, run test pods in a namespace that is exempt from Gatekeeper constraints (e.g., `default` if it is not in the constraint's namespace list), or temporarily remove the constraint during testing.

---

## Teams API Module

### Port number confusion

The Teams API uses different ports at different layers:

| Layer | Port | Notes |
|---|---|---|
| Python application (uvicorn) | 8000 | Hardcoded in `main.py` |
| Kubernetes Service | 4200 | Defined in the service YAML, maps to container port 8000 |
| Port-forward (local) | Your choice | e.g., `kubectl port-forward svc/teams-api-service 8080:4200` makes it available at `localhost:8080` |

When configuring port-forwards, the format is `<local-port>:<service-port>`.

---

### Teams API data disappears after pod restart

**Cause**: The API uses in-memory storage. This is intentional for the workshop.

**Workaround**: Re-create your test teams after a restart. For the capstone, create teams just before your demo. If you want persistence, extend the API with a SQLite or PostgreSQL backend as an exercise.

---

## Teams Web UI Module

### nginx Permission Denied errors on deployment

**Symptom**: Pods crash with `mkdir() "/var/cache/nginx/client_temp" failed (13: Permission denied)`.

**Cause**: The standard `nginx` image runs as root (UID 0). Gatekeeper's security constraint blocks root containers, and even without Gatekeeper, running nginx as non-root with the standard image fails because it cannot create cache directories.

**Fix**: Use `nginxinc/nginx-unprivileged` as the base image in your Dockerfile, which runs as UID 101 and handles cache directories correctly. Update the `securityContext` in your deployment YAML to use `runAsUser: 101`.

---

## Capstone Module

### Keycloak shows blank page or timeout

**Symptom**: The Teams UI shows a blank page. Browser console shows "Timeout when waiting for 3rd party check iframe message".

**Cause**: The Keycloak realm's CORS configuration (`webOrigins` in `teams-realm.json`) does not include the URL you are accessing the UI from.

**Fix**:
1. Open `teams-realm.json`
2. Add your access URL to the `webOrigins` and `redirectUris` arrays (e.g., `http://<workspace-name>.coder:4200` or `http://localhost:4200`)
3. Recreate the ConfigMap and restart Keycloak:
```bash
kubectl delete configmap keycloak-realm-config -n keycloak
kubectl create configmap keycloak-realm-config --from-file=teams-realm.json -n keycloak
kubectl rollout restart deployment keycloak -n keycloak
```

---

### Keycloak realm not loading

**Symptom**: `http://localhost:8080/realms/teams` returns a 404.

**Cause**: The ConfigMap with `teams-realm.json` may not have existed when the Keycloak pod started.

**Fix**:
```bash
# Check if the ConfigMap exists
kubectl get configmap keycloak-realm-config -n keycloak

# If missing, create it
kubectl create configmap keycloak-realm-config --from-file=teams-realm.json -n keycloak

# Restart Keycloak to pick up the realm
kubectl rollout restart deployment keycloak -n keycloak
```

---

### Images not found when deploying to kind

**Symptom**: `ErrImagePull` or `ImagePullBackOff` for locally built images.

**Cause**: Kind clusters cannot pull from your local Docker daemon. You must explicitly load images.

**Fix**:
```bash
kind load docker-image <image-name>:<tag> --name 5min-idp
```

Run this after every `docker build` before deploying to the cluster.

---

### sslip.io domains not resolving

**Symptom**: `nslookup teams-api.127.0.0.1.sslip.io` fails, or the browser cannot reach ingress URLs.

**Cause**: Some DNS resolvers or corporate networks block wildcard DNS services like sslip.io.

**Workaround**: Use `kubectl port-forward` instead of ingress, and access services via `localhost`. Update `environment.ts` in the Teams App to use `http://localhost:<port>` instead of the sslip.io URL.

---

## Still Stuck?

1. Check the module-specific README for detailed troubleshooting sections
2. Search the Slack channel — another student may have already solved your issue
3. Reach out to facilitators with:
   - The exact error message
   - The command you ran
   - The output of `kubectl get pods --all-namespaces`
