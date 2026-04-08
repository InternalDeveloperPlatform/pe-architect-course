# Define variables
DOCKER_IMAGE = hashicorp/terraform:latest
WORKDIR = /workspace
LOCAL_DIR = $(PWD)
CODER_WORKSPACE = pe-course-architect
# CODER_PATH = terraform-configs # Path in Coder workspace

# Dockerized Terraform commands
init:
	docker run --rm -v $(LOCAL_DIR):$(WORKDIR) -w $(WORKDIR) $(DOCKER_IMAGE) init --upgrade

plan:
	docker run --rm -v $(LOCAL_DIR):$(WORKDIR) -w $(WORKDIR) \
    -v ~/.config/gcloud:/root/.config/gcloud:ro \
    -e GOOGLE_APPLICATION_CREDENTIALS=/root/.config/gcloud/application_default_credentials.json \
  $(DOCKER_IMAGE) plan


apply:
	docker run --rm -v $(LOCAL_DIR):$(WORKDIR) -w $(WORKDIR) $(DOCKER_IMAGE) apply

# Push to Coder
push-to-coder:
	@echo "Pushing code to Coder workspace: $(CODER_WORKSPACE)"
	coder templates push $(CODER_WORKSPACE) --yes
#	coder sync $(LOCAL_DIR) $(CODER_WORKSPACE):$(CODER_PATH)

# Clean Docker container remnants (optional)
clean:
	@echo "Cleaning up any unused Docker resources..."
	docker system prune -f

# Help menu
help:
	@echo "Usage:"
	@echo "  make init           - Run Terraform init in Docker"
	@echo "  make plan           - Run Terraform plan in Docker"
	@echo "  make apply          - Run Terraform apply in Docker"
	@echo "  make push-to-coder  - Push local code to Coder workspace"
	@echo "  make clean          - Clean Docker resources"
