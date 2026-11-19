kubectl port-forward -n engineering-platform svc/teams-api-service 8080:4200 & \
kubectl port-forward -n engineering-platform svc/teams-ui-service 8081:80 & \
kubectl port-forward -n keycloak svc/keycloak-service 8082:8080 & \
kubectl port-forward -n teams-api-adv svc/teams-api-adv-service 8083:4200 & \
kubectl port-forward -n teams-api svc/teams-api-service 8084:4200 & \
kubectl port-forward -n teams-api service/teams-api-preview-service 8085:4200 &\
kubectl port-forward -n monitoring svc/grafana-stack 3000:80 &
