# Keycloak

We deploy Keycloak as our SSO provider. The `keycloak.yaml` file contains all the resources needed, but most are commented out by default. You need to uncomment the sections you need before applying.

### Setup

1. Open `keycloak.yaml` and uncomment the resources you need. At minimum, uncomment:
   - **Namespace** (`keycloak`)
   - **PostgreSQL Deployment and Service** (Keycloak's database)
   - **Keycloak Service** (exposes Keycloak to the cluster)
   - **ConfigMap** (`keycloak-realm-config` — contains the realm import)

   The Keycloak Deployment and Ingress are already uncommented.

2. Adapt any `<workspace-name>` references in `keycloak.yaml` to match your Coder workspace name.

3. Apply and wait for rollout:
```bash
kubectl apply -f keycloak.yaml
kubectl -n keycloak rollout status deployment keycloak
```

> **Note**: The Keycloak Deployment depends on PostgreSQL being available (`KC_DB_URL` points to `keycloak-postgres-service`), and the Ingress depends on `keycloak-service` existing. If you apply without uncommenting those resources, the pods will crash or the ingress will have no backend.