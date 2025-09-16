#!/usr/bin/env bash

# Define a sudo wrapper
# run_as_root() {
#   if [ "$(id -u)" -ne 0 ]; then
#     sudo "$@"
#   else
#     "$@"
#   fi
# }

# run_as_root apt-get install -y curl unzip wget net-tools jq

# # Make certificates happen :)
# if ! command -v mkcert &> /dev/null
# then
#   echo "mkcert not found. Installing..."
#   curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64"
#   chmod +x mkcert-v*-linux-amd64
#   run_as_root mv mkcert-v*-linux-amd64 /usr/local/bin/mkcert
# else
#   echo "mkcert is already installed."
# fi
# export CAROOT="/workspaces"
# mkcert -install
#
# # Check if dockerd is running
# if ! pgrep -x "dockerd" > /dev/null
# then
#   echo "Docker daemon is not running. Starting dockerd in the background..."
#   run_as_root dockerd > /dev/null 2>&1 &
# else
#   echo "Docker daemon is already running."
# fi
#
# # For Terraform 1.5.7
# ARCH=$(uname -m)
# if [[ "$ARCH" == "x86_64" ]]; then
#     ARCH="amd64"
# elif [[ "$ARCH" == "aarch64" ]]; then
#     ARCH="arm64"
# else
#     echo "Unsupported architecture: $ARCH"
#     exit 1
# fi
#
# if ! command -v terraform &> /dev/null
# then
#   echo "Terraform not found. Installing..."
#   VERSION="1.5.7"
#   wget "https://releases.hashicorp.com/terraform/${VERSION}/terraform_${VERSION}_linux_${ARCH}.zip"
#   unzip terraform_${VERSION}_linux_${ARCH}.zip
#   run_as_root mv terraform /usr/local/bin/
#   rm terraform_${VERSION}_linux_${ARCH}.zip
# else
#   echo "Terraform is already installed."
# fi
#
# # For YQ
# if ! command -v yq &> /dev/null
# then
#   echo "yq not found. Installing..."
#   VERSION="v4.35.1" # Replace with the desired version
#   wget "https://github.com/mikefarah/yq/releases/download/${VERSION}/yq_linux_${ARCH}"
#   run_as_root mv yq_linux_${ARCH} /usr/local/bin/yq
# else
#   echo "yq is already installed."
# fi
#
# # For score-k8s AMD64 / x86_64
# if ! command -v score-k8s &> /dev/null
# then
#   echo "score-k8s not found. Installing..."
#   [ $(uname -m) = x86_64 ] && curl -sLO "https://github.com/score-spec/score-k8s/releases/download/0.1.18/score-k8s_0.1.18_linux_amd64.tar.gz"
#   # For score-k8s ARM64
#   [ $(uname -m) = aarch64 ] && curl -sLO "https://github.com/score-spec/score-k8s/releases/download/0.1.18/score-k8s_0.1.18_linux_arm64.tar.gz"
#   tar xvzf score-k8s*.tar.gz
#   rm score-k8s*.tar.gz README.md LICENSE
#   run_as_root mv ./score-k8s /usr/local/bin/score-k8s
#   run_as_root chown root: /usr/local/bin/score-k8s
# else
#   echo "score-k8s is already installed."
# fi
#
# # Install glow to be able to read MD files in the terminal
# if ! command -v glow &> /dev/null
# then
#   echo "glow not found. Installing..."
#   run_as_root mkdir -p /etc/apt/keyrings
#   curl -fsSL https://repo.charm.sh/apt/gpg.key | run_as_root gpg --dearmor -o /etc/apt/keyrings/charm.gpg
#   echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | run_as_root tee /etc/apt/sources.list.d/charm.list
#   run_as_root apt update && run_as_root apt install glow -y
# else
#   echo "glow is already installed."
# fi
#
# # Check if kubectl is installed
# if ! command -v kubectl &> /dev/null
# then
#   echo "kubectl not found. Installing..."
#   # For Kubectl AMD64 / x86_64
#   [ $(uname -m) = x86_64 ] && curl -sLO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
#   # For Kubectl ARM64
#   [ $(uname -m) = aarch64 ] && curl -sLO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
#   chmod +x ./kubectl
#   run_as_root mv ./kubectl /usr/local/bin/kubectl
# else
#   echo "kubectl is already installed."
# fi
#
# # Check if kind is installed
# if ! command -v kind &> /dev/null
# then
#   echo "kind not found. Installing..."
#   # For Kind AMD64 / x86_64
#   [ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.26.0/kind-linux-amd64
#   # For ARM64
#   [ $(uname -m) = aarch64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.26.0/kind-linux-arm64
#   chmod +x ./kind
#   run_as_root mv ./kind /usr/local/bin/kind
# else
#   echo "kind is already installed."
# fi
#
# # setup autocomplete for kubectl
# run_as_root apt-get update -y && run_as_root apt-get install bash-completion -y
# mkdir $HOME/.kube
# echo "source <(kubectl completion bash)" >> $HOME/.bashrc
# echo "complete -F __start_kubectl k" >> $HOME/.bashrc
#
# # Check if the network already exists and create it if it does not
# if ! docker network ls | grep -q 'kind'; then
#   docker network create -d=bridge -o com.docker.network.bridge.enable_ip_masquerade=true -o com.docker.network.driver.mtu=1500 --subnet fc00:f853:ccd:e793::/64 kind
# else
#   echo "Network 'kind' already exists."
# fi
#
# export BASE_DIR=/home/vscode
# mkdir -p $BASE_DIR/state/kube
#
# # 1. Create registry container unless it already exists
# reg_name='kind-registry'
# reg_port='5001'
# if [ "$(docker inspect -f '{{.State.Running}}' "${reg_name}" 2>/dev/null || true)" != 'true' ]; then
#   docker run -d --restart=always -p "127.0.0.1:${reg_port}:5000" --network bridge --name "${reg_name}" registry:2
# fi
#
# # 2. Create Kind cluster
# if [ ! -f $BASE_DIR/state/kube/config.yaml ]; then
#   kind create cluster -n 5min-idp --kubeconfig $BASE_DIR/state/kube/config.yaml --config ./setup/kind/cluster.yaml
# fi
#
# # connect current container to the kind network
# container_name="5min-idp"
# if [ "$(docker inspect -f='{{json .NetworkSettings.Networks.kind}}' "${container_name}")" = 'null' ]; then
#   docker network connect "kind" "${container_name}"
# fi
#
# # used by humanitec-agent / inside docker to reach the cluster
# export kubeconfig_docker=$BASE_DIR/state/kube/config-internal.yaml
# kind export kubeconfig --internal -n 5min-idp --kubeconfig "$kubeconfig_docker"
# # used in general
# kind export kubeconfig --internal -n 5min-idp
#
# # 3. Add the registry config to the nodes
# #
# # This is necessary because localhost resolves to loopback addresses that are
# # network-namespace local.
# # In other words: localhost in the container is not localhost on the host.
# #
# # We want a consistent name that works from both ends, so we tell containerd to
# # alias localhost:${reg_port} to the registry container when pulling images
# REGISTRY_DIR="/etc/containerd/certs.d/localhost:${reg_port}"
# for node in $(kind get nodes -n 5min-idp); do
#   docker exec "${node}" mkdir -p "${REGISTRY_DIR}"
#   cat <<EOF | docker exec -i "${node}" cp /dev/stdin "${REGISTRY_DIR}/hosts.toml"
# [host."http://${reg_name}:5000"]
# EOF
# done
#
# # 4. Connect the registry to the cluster network if not already connected
# # This allows kind to bootstrap the network but ensures they're on the same network
# if [ "$(docker inspect -f='{{json .NetworkSettings.Networks.kind}}' "${reg_name}")" = 'null' ]; then
#   docker network connect "kind" "${reg_name}"
# fi
#
# # 5. Document the local registry
# # https://github.com/kubernetes/enhancements/tree/master/keps/sig-cluster-lifecycle/generic/1755-communicating-a-local-registry
# cat <<EOF | kubectl apply -f -
# apiVersion: v1
# kind: ConfigMap
# metadata:
#   name: local-registry-hosting
#   namespace: kube-public
# data:
#   localRegistryHosting.v1: |
#   host: "localhost:${reg_port}"
#   help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
# EOF
#
# ## Update /etc/hosts with the kind cluster name
# if ! grep -q "5min-idp-control-plane" /etc/hosts; then
#   echo "127.0.0.1 5min-idp-control-plane" | run_as_root tee -a /etc/hosts
# fi
#
# ## Prep env
# # Get the gateway API in if we want to work with score-k8s
# #kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml
# # ATTENTION WITH THIS ONE - we need this at least for Git to be able to interact with the self-signed cert
# echo "git config --global user.name \"giteaAdmin\"" >> $HOME/.bashrc
# echo "git config --global credential.helper store" >> $HOME/.bashrc
#
# ### Export needed env-vars for terraform
# # Variables for TLS in Terraform
# # export TF_VAR_tls_ca_cert=$TLS_CA_CERT
# export TF_VAR_tls_cert_string=$PIDP_CERT
# export TF_VAR_tls_key_string=$PIDP_KEY
# # Kubeconfig for Terraform
# export TF_VAR_kubeconfig=$kubeconfig_docker
#
# terraform -chdir=setup/terraform init
# terraform -chdir=setup/terraform apply -auto-approve
#
# # Check if the gitea_runner container is already running
# if [ "$(docker inspect -f '{{.State.Running}}' gitea_runner 2>/dev/null || true)" != 'true' ]; then
#   # Create Gitea Runner for Actions CI
#   RUNNER_TOKEN=""
#   while [[ -z $RUNNER_TOKEN ]]; do
#     response=$(curl -k -s -X 'GET' 'https://5min-idp-control-plane/api/v1/admin/runners/registration-token' -H 'accept: application/json' -H 'authorization: Basic NW1pbmFkbWluOjVtaW5hZG1pbg==')
#     if [[ $response == *"token"* ]]; then
#       RUNNER_TOKEN=$(echo $response | jq -r '.token')
#     fi
#     sleep 1
#   done
#
#   # Start Gitea Runner
#   docker volume create gitea_runner_data
#   docker create \
#     --name gitea_runner \
#     -v gitea_runner_data:/data \
#     -v /var/run/docker.sock:/var/run/docker.sock \
#     -v /etc/ssl/certs:/etc/ssl/certs:ro \
#     -v /etc/ca-certificates:/etc/ca-certificates:ro \
#     -e CONFIG_FILE=/config.yaml \
#     -e GITEA_INSTANCE_URL=https://5min-idp-control-plane \
#     -e GITEA_RUNNER_REGISTRATION_TOKEN=$RUNNER_TOKEN \
#     -e GITEA_RUNNER_NAME=local \
#     -e GITEA_RUNNER_LABELS=local \
#     --network kind \
#     gitea/act_runner:latest
#   # sed 's|###ca-certficates.crt###|'"$TLS_CA_CERT"'|' setup/gitea/config.yaml > setup/gitea/config.done.yaml
#   # docker cp setup/gitea/config.done.yaml gitea_runner:/config.yaml
#   docker cp setup/gitea/config.yaml gitea_runner:/config.yaml
#   docker start gitea_runner
# else
#   echo "gitea_runner container is already running and gitea configured."
# fi
#
# # Create Gitea org with configuration
# curl -k -X 'POST' \
#   'https://5min-idp-control-plane/api/v1/orgs' \
#   -H 'accept: application/json' \
#   -H 'authorization: Basic NW1pbmFkbWluOjVtaW5hZG1pbg==' \
#   -H 'Content-Type: application/json' \
#   -d '{
#   "repo_admin_change_team_access": true,
#   "username": "5minorg",
#   "visibility": "public"
# }'
# curl -k -X 'POST' \
#   'https://5min-idp-control-plane/api/v1/orgs/5minorg/actions/variables/CLOUD_PROVIDER' \
#   -H 'accept: application/json' \
#   -H 'authorization: Basic NW1pbmFkbWluOjVtaW5hZG1pbg==' \
#   -H 'Content-Type: application/json' \
#   -d '{
#   "value": "5min"
# }'

# Set some nice aliases
echo "alias k='kubectl'" >> $HOME/.bashrc
echo "alias kg='kubectl get'" >> $HOME/.bashrc
echo "alias h='humctl'" >> $HOME/.bashrc
echo "alias sk='score-k8s'" >> $HOME/.bashrc

echo ""
echo ">>>> ready to roll."
