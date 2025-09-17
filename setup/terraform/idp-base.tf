# Ensure we don't have name conflicts
resource "random_string" "install_id" {
  length  = 4
  special = false
  upper   = false
  numeric = false
}

locals {
  app       = "5min-idp-${random_string.install_id.result}"
  prefix    = "${local.app}-"
  env_type  = "5min-local"
}
