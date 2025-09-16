# Configure k8s cluster by exposing the locally running Kubernetes Cluster to the Humanitec Orchestrator
# using the Humanitec Agent

resource "tls_private_key" "agent_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

locals {
  agent_id = "${local.prefix}agent"
}

locals {
  parsed_kubeconfig = yamldecode(file(var.kubeconfig))
}
