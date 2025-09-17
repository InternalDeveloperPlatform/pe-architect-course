1. install falco

helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update

helm install falco falcosecurity/falco \
  --namespace falco-system \
  --create-namespace \
  --set driver.kind=modern_ebpf \
  --set falco.grpc.enabled=true \
  --set falco.grpcOutput.enabled=true

kubectl get pods -n falco

2. Add constraint template
3. Add constraint
4. Deploy deployment.yaml
5. Deploy deployment-working.yaml


helm upgrade falco falcosecurity/falco \
  --namespace falco-system \
  --set driver.kind=modern_ebpf \
  --set falco.grpc.enabled=true \
  --set falco.grpcOutput.enabled=true \
  --set-file customRules."custom_rules\.yaml"=./root-detect-rule.yaml
