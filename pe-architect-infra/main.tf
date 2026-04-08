terraform {
  required_providers {
    coder = {
      source = "coder/coder"
    }
    google = {
      source = "hashicorp/google"
      version = "6.24.0"
    }
    envbuilder = {
      source = "coder/envbuilder"
    }
    terracurl = {
      source = "devops-rob/terracurl"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

provider "coder" {}

provider "google" {
  zone    = data.coder_parameter.zone.value
  project = var.project_id
}

data "google_compute_default_service_account" "default" {}

data "google_secret_manager_regional_secret_version" "orgcreatetoken" {
  project  = "663142533109"
  location = "europe-west3"
  secret   = "orgcreatetoken"
  version  = "1"
}

data "coder_workspace" "me" {}
data "coder_workspace_owner" "me" {}

variable "project_id" {
  description = "Which Google Compute Project should your workspace live in?"
  default     = "platform-fundamentals-courses"
}

variable "cache_repo" {
  #default     = "europe-west3-docker.pkg.dev/platform-fundamentals-courses/coder-pe"
  default     = ""
  description = "(Optional) Use a container registry as a cache to speed up builds. Example: host.tld/path/to/repo."
  type        = string
}

variable "cache_repo_docker_config_path" {
  default     = ""
  description = "(Optional) Path to a docker config.json containing credentials to the provided cache repo, if required. This will depend on your Coder setup. Example: `/home/coder/.docker/config.json`."
  sensitive   = true
  type        = string
}

data "coder_parameter" "zone" {
  name         = "zone"
  display_name = "Zone"
  description  = "Which zone should your workspace live in?"
  type         = "string"
  icon         = "/emojis/1f30e.png"
  default      = "europe-west3-a"
  mutable      = false
  order        = 3
  option {
    name  = "North America (Northeast)"
    value = "northamerica-northeast1-a"
    icon  = "/emojis/1f1fa-1f1f8.png"
  }
  option {
    name  = "North America (Central)"
    value = "us-central1-a"
    icon  = "/emojis/1f1fa-1f1f8.png"
  }
  option {
    name  = "North America (West)"
    value = "us-west2-c"
    icon  = "/emojis/1f1fa-1f1f8.png"
  }
  option {
    name  = "Europe (West)"
    value = "europe-west3-a"
    icon  = "/emojis/1f1ea-1f1fa.png"
  }
  option {
    name  = "South America (East)"
    value = "southamerica-east1-a"
    icon  = "/emojis/1f1e7-1f1f7.png"
  }
}

variable "instance_type" {
  default     = "e2-standard-4"
  description = "Select an instance type for your workspace."
  type        = string
}

variable "fallback_image" {
  default = "codercom/enterprise-base:ubuntu"
  type    = string
}

variable "devcontainer_builder" {
  default = "ghcr.io/coder/envbuilder:latest"
  type    = string
}

variable "repo_url" {
  default     = "https://github.com/InternalDeveloperPlatform/pe-architect-course"
  description = "Repository URL"
  type        = string
}

data "local_sensitive_file" "cache_repo_dockerconfigjson" {
  count    = var.cache_repo_docker_config_path == "" ? 0 : 1
  filename = var.cache_repo_docker_config_path
}

# Be careful when modifying the below locals!
locals {
  # Ensure Coder username is a valid Linux username
  linux_user = lower(substr(data.coder_workspace_owner.me.name, 0, 32))
  # Name the container after the workspace and owner.
  container_name = "coder-${data.coder_workspace_owner.me.name}-${lower(data.coder_workspace.me.name)}"
  # The devcontainer builder image is the image that will build the devcontainer.
  # devcontainer_builder_image = data.coder_parameter.devcontainer_builder.value
  devcontainer_builder_image = var.devcontainer_builder
  # We may need to authenticate with a registry. If so, the user will provide a path to a docker config.json.
  docker_config_json_base64 = try(data.local_sensitive_file.cache_repo_dockerconfigjson[0].content_base64, "")
  # The envbuilder provider requires a key-value map of environment variables. Build this here.
  envbuilder_env = {
    # ENVBUILDER_GIT_URL and ENVBUILDER_CACHE_REPO will be overridden by the provider
    # if the cache repo is enabled.
    "ENVBUILDER_GIT_URL" : var.repo_url,
    # The agent token is required for the agent to connect to the Coder platform.
    "CODER_AGENT_TOKEN" : try(coder_agent.dev.0.token, ""),
    # The agent URL is required for the agent to connect to the Coder platform.
    "CODER_AGENT_URL" : data.coder_workspace.me.access_url,
    # The agent init script is required for the agent to start up. We base64 encode it here
    # to avoid quoting issues.
    "ENVBUILDER_INIT_SCRIPT" : "echo ${base64encode(try(coder_agent.dev[0].init_script, ""))} | base64 -d | sh",
    "ENVBUILDER_DOCKER_CONFIG_BASE64" : try(data.local_sensitive_file.cache_repo_dockerconfigjson[0].content_base64, ""),
    # The fallback image is the image that will run if the devcontainer fails to build.
    # "ENVBUILDER_FALLBACK_IMAGE" : data.coder_parameter.fallback_image.value,
    "ENVBUILDER_FALLBACK_IMAGE" : var.fallback_image,
    # The following are used to push the image to the cache repo, if defined.
    "ENVBUILDER_CACHE_REPO" : var.cache_repo,
    "ENVBUILDER_PUSH_IMAGE" : var.cache_repo == "" ? "" : "true",
    # You can add other required environment variables here.
    # See: https://github.com/coder/envbuilder/?tab=readme-ov-file#environment-variables
  }
  # If we have a cached image, use the cached image's environment variables. Otherwise, just use
  # the environment variables we've defined above.
  docker_env_input = try(envbuilder_cached_image.cached.0.env_map, local.envbuilder_env)
  # Convert the above to the list of arguments for the Docker run command.
  # The startup script will write this to a file, which the Docker run command will reference.
  docker_env_list_base64 = base64encode(join("\n", [for k, v in local.docker_env_input : "${k}=${v}"]))

  # Builder image will either be the builder image parameter, or the cached image, if cache is provided.
  # builder_image = try(envbuilder_cached_image.cached[0].image, data.coder_parameter.devcontainer_builder.value)
  builder_image = try(envbuilder_cached_image.cached[0].image, var.devcontainer_builder)

  # The GCP VM needs a startup script to set up the environment and start the container. Defining this here.
  # NOTE: make sure to test changes by uncommenting the local_file resource at the bottom of this file
  # and running `terraform apply` to see the generated script. You should also run shellcheck on the script
  # to ensure it is valid.
  startup_script = <<-META
    #!/usr/bin/env sh
    set -eux

    # If user does not exist, create it and set up passwordless sudo
    if ! id -u "${local.linux_user}" >/dev/null 2>&1; then
      useradd -m -s /bin/bash "${local.linux_user}"
      echo "${local.linux_user} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/coder-user
    fi

    # Check for Docker, install if not present
    if ! command -v docker >/dev/null 2>&1; then
      echo "Docker not found, installing..."
      curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh >/dev/null 2>&1
      sudo usermod -aG docker ${local.linux_user}
      newgrp docker
    else
      echo "Docker is already installed."
    fi

    # Write the Docker config JSON to disk if it is provided.
    if [ -n "${local.docker_config_json_base64}" ]; then
      mkdir -p "/home/${local.linux_user}/.docker"
      printf "%s" "${local.docker_config_json_base64}" | base64 -d | tee "/home/${local.linux_user}/.docker/config.json"
      chown -R ${local.linux_user}:${local.linux_user} "/home/${local.linux_user}/.docker"
    fi

    # Write the container env to disk.
    printf "%s" "${local.docker_env_list_base64}" | base64 -d | tee "/home/${local.linux_user}/env.txt"

    # Setup mkcert and make SSL happen
    curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64"
    chmod +x mkcert-v*-linux-amd64
    mv mkcert-v*-linux-amd64 /usr/local/bin/mkcert
    if [ ! -d "/home/${local.linux_user}/envbuilder" ]; then
      mkdir -p /home/${local.linux_user}/envbuilder
    fi
    export CAROOT=/home/${local.linux_user}/envbuilder
    mkcert -install
    if [ ! -f $CAROOT/pidpCERT.pem ] || [ ! -f $CAROOT/pidpKEY.pem ]; then
      mkcert -cert-file $CAROOT/pidpCERT.pem -key-file $CAROOT/pidpKEY.pem localhost 5min-idp-control-plane git.localhost pidp.localtest.me pidp-git.localtest.me pidp-127-0-0-1.nip.io pidp.127.0.0.1.nip.io 127.0.0.1 ::1
    fi
    export PIDP_CERT=$(base64 -w0 $CAROOT/pidpCERT.pem)
    export PIDP_KEY=$(base64 -w0 $CAROOT/pidpKEY.pem)

    # Start envbuilder.
    docker run \
      --rm \
      --net=host \
      -h ${lower(data.coder_workspace.me.name)} \
      -v /home/${local.linux_user}/envbuilder:/workspaces \
      -v /var/run/docker.sock:/var/run/docker.sock \
      --env-file /home/${local.linux_user}/env.txt \
      -e "PIDP_CERT=$PIDP_CERT" \
      -e "PIDP_KEY=$PIDP_KEY" \
      -e "LINUX_USER=${local.linux_user}" \
    ${local.builder_image}
  META
}

# Create a persistent disk to store the workspace data.
resource "google_compute_disk" "root" {
  name  = "coder-${data.coder_workspace.me.id}-root"
  type  = "pd-ssd"
  image = "debian-cloud/debian-12"
  lifecycle {
    ignore_changes = all
  }
  size = 30
}

# heck for the presence of a prebuilt image in the cache repo
# that we can use instead.C
resource "envbuilder_cached_image" "cached" {
  count         = var.cache_repo == "" ? 0 : data.coder_workspace.me.start_count
  builder_image = local.devcontainer_builder_image
  git_url       = var.repo_url
  cache_repo    = var.cache_repo
  extra_env     = local.envbuilder_env
}

# This is useful for debugging the startup script. Left here for reference.
# resource local_file "startup_script" {
#   content  = local.startup_script
#   filename = "${path.module}/startup_script.sh"
# }

# Create a VM where the workspace will run.
resource "google_compute_instance" "vm" {
  name         = "coder-${lower(data.coder_workspace_owner.me.name)}-${lower(data.coder_workspace.me.name)}-root"
  machine_type = var.instance_type
  # data.coder_workspace_owner.me.name == "default"  is a workaround to suppress error in the terraform plan phase while creating a new workspace.
  desired_status = (data.coder_workspace_owner.me.name == "default" || data.coder_workspace.me.start_count == 1) ? "RUNNING" : "TERMINATED"

  network_interface {
    network = "default"
    access_config {
      // Ephemeral public IP
    }
  }

  boot_disk {
    auto_delete = false
    source      = google_compute_disk.root.name
  }

  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["cloud-platform"]
  }

  metadata = {
    # The startup script runs as root with no $HOME environment set up, so instead of directly
    # running the agent init script, create a user (with a homedir, default shell and sudo
    # permissions) and execute the init script as that user.
    startup-script = local.startup_script
  }
}

# Create a Coder agent to manage the workspace.
resource "coder_agent" "dev" {
  count              = data.coder_workspace.me.start_count
  arch               = "amd64"
  auth               = "token"
  os                 = "linux"
  dir                = "/workspaces/${trimsuffix(basename(var.repo_url), ".git")}"
  connection_timeout = 0

  metadata {
    key          = "cpu"
    display_name = "CPU Usage"
    interval     = 5
    timeout      = 5
    script       = "coder stat cpu"
  }
  metadata {
    key          = "memory"
    display_name = "Memory Usage"
    interval     = 5
    timeout      = 5
    script       = "coder stat mem"
  }
  metadata {
    key          = "disk"
    display_name = "Disk Usage"
    interval     = 5
    timeout      = 5
    script       = "coder stat disk"
  }
}

# See https://registry.coder.com/modules/code-server
module "code-server" {
  count  = data.coder_workspace.me.start_count
  source = "registry.coder.com/modules/code-server/coder"

  # This ensures that the latest version of the module gets downloaded, you can also pin the module version to prevent breaking changes in production.
  version = ">= 1.0.0"

  agent_id = coder_agent.dev[0].id
  order    = 1
}

# Create metadata for the workspace and home disk.
resource "coder_metadata" "workspace_info" {
  count       = data.coder_workspace.me.start_count
  resource_id = google_compute_instance.vm.id

  item {
    key   = "type"
    value = google_compute_instance.vm.machine_type
  }

  item {
    key   = "zone"
    value = data.coder_parameter.zone.value
  }

  # daily_cost = 15
}

resource "coder_metadata" "home_info" {
  resource_id = google_compute_disk.root.id

  item {
    key   = "size"
    value = "${google_compute_disk.root.size} GiB"
  }

  # daily_cost = 10
}
