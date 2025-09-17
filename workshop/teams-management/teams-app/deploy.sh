#!/bin/bash
# deploy.sh - Complete deployment script

set -e

echo "🚀 Deploying Engineering Platform Teams UI to Kubernetes"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="engineering-platform"
UI_IMAGE="teams-ui:latest"
API_IMAGE="teams-api:latest"

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if kubectl is available
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl is not installed or not in PATH"
        exit 1
    fi

    if ! kubectl cluster-info &> /dev/null; then
        log_error "Unable to connect to Kubernetes cluster"
        exit 1
    fi

    log_success "kubectl is configured and connected to cluster"
}

# Check if docker is available
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed or not in PATH"
        exit 1
    fi

    if ! docker info &> /dev/null; then
        log_error "Docker daemon is not running"
        exit 1
    fi

    log_success "Docker is available and running"
}

# Build the Angular application
build_ui() {
    log_info "Building Angular application..."

    if [ ! -f "package.json" ]; then
        log_error "package.json not found. Are you in the correct directory?"
        exit 1
    fi

    # Install dependencies
    npm install

    # Build for production
    npm run build --prod

    log_success "Angular application built successfully"
}

# Build Docker images
build_images() {
    log_info "Building Docker images..."

    # Build UI image
    log_info "Building UI Docker image..."
    docker build -t $UI_IMAGE .

    # Build API image (assuming API Dockerfile exists)
    if [ -f "api.Dockerfile" ]; then
        log_info "Building API Docker image..."
        docker build -f api.Dockerfile -t $API_IMAGE .
    else
        log_warning "API Dockerfile not found. Make sure API image is available"
    fi

    log_success "Docker images built successfully"
}

# Deploy to Kubernetes
deploy_k8s() {
    log_info "Deploying to Kubernetes..."

    # Create namespace if it doesn't exist
    kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
    log_success "Namespace '$NAMESPACE' ready"

    # Apply Kubernetes manifests
    kubectl apply -f k8s/

    log_success "Kubernetes resources deployed"

    # Wait for deployments to be ready
    log_info "Waiting for deployments to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/teams-ui deployment/teams-api -n $NAMESPACE

    log_success "Deployments are ready"
}

# Check deployment status
check_status() {
    log_info "Checking deployment status..."

    echo
    echo "Pods:"
    kubectl get pods -n $NAMESPACE

    echo
    echo "Services:"
    kubectl get services -n $NAMESPACE

    echo
    echo "Ingress:"
    kubectl get ingress -n $NAMESPACE

    echo
    log_info "To access the application:"
    echo "1. Add this to your /etc/hosts file:"
    echo "   127.0.0.1 engineering-platform.local"
    echo "2. Port forward the ingress controller (if using minikube/kind):"
    echo "   kubectl port-forward -n ingress-nginx service/ingress-nginx-controller 8080:80"
    echo "3. Access the application at: http://engineering-platform.local:8080"
}

# Rollback deployment
rollback() {
    log_warning "Rolling back deployment..."
    kubectl rollout undo deployment/teams-ui deployment/teams-api -n $NAMESPACE
    log_success "Rollback completed"
}

# Clean up resources
cleanup() {
    log_warning "Cleaning up Kubernetes resources..."
    kubectl delete -f k8s/
    kubectl delete namespace $NAMESPACE
    log_success "Cleanup completed"
}

# Main deployment function
deploy() {
    log_info "Starting deployment process..."

    check_kubectl
    check_docker
    build_ui
    build_images
    deploy_k8s
    check_status

    log_success "Deployment completed successfully! 🎉"
}

# Parse command line arguments
case "${1:-deploy}" in
    "deploy")
        deploy
        ;;
    "rollback")
        rollback
        ;;
    "cleanup")
        cleanup
        ;;
    "status")
        check_status
        ;;
    "build")
        build_ui
        build_images
        ;;
    *)
        echo "Usage: $0 {deploy|rollback|cleanup|status|build}"
        echo "  deploy   - Full deployment (default)"
        echo "  rollback - Rollback to previous version"
        echo "  cleanup  - Remove all resources"
        echo "  status   - Check deployment status"
        echo "  build    - Build application and images only"
        exit 1
        ;;
esac
