# keykloak

We deploy keycloak as our SSO provider

- first adapt your `<workspace-name>` in `keycloak.yaml`
- then run
```bash
kubectl apply -f keycloak.yaml
kubectl -n keycloak rollout status deployment keycloak
```