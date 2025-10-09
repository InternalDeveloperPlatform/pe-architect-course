## Capstone

Welcome to the capstone project, you are near the end!

Please follow the guidance in the presentation for expectations.

### Capstone requirements

1. Deployment of an API
2. Deployment of a new Gatekeeper policy
3. Deployment of an application that adheres to the new policy

### Deployment Requirements

Our SRE team has said they want to start requiring all teams to use Argo Rollouts to create their deployments.
This will ensure the eventual usage of Canary or Blue/Green patterns, which is more resilient and consistent
for creating stable releases.

As the platform engineer, you are tasked with writing the first draft of the Gatekeeper constraint that prevents
engineers from deploying to production without an Argo rollout defined for their deployment.

You must also demonstrate the functionality of the new feature of the platform by deploying an API via Argo Rollouts,
so that other teams may see an initial starting point for how to configure their own.

### Deploy ArgoCD

```bash
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
```

Verify the installation worked

```bash
kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-rollouts/master/docs/getting-started/basic/rollout.yaml
kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-rollouts/master/docs/getting-started/basic/service.yaml

# Check the status of the deployment rollout
kubectl describe rollout
```

Add the Kubectl Argo Rollouts plugin to your Kubectl

https://argo-rollouts.readthedocs.io/en/stable/installation/#kubectl-plugin-installation

```bash
Verify the install worked

kubectl argo rollouts get rollout rollouts-demo --watch
```

Take a look at the argo rollouts dashboard:

```bash
kubectl argo rollouts dashboard

# Note, verify you can see the demo application deployed.
```


### Checklist

1. Configure and Deploy Argo Rollouts (see their docs)
2. Build a simple RESTful API, containerize it, and push it to dockerhub (don't forget to tag it)
3. Configure a Kubernetes deployment of your new RESTful API
4. Push the deployment to production, using Argo Rollouts Blue/Green or Canary.
5. Verify your deployment in the Argo Rollouts dashboard and Grafana

Bonus content: configure a new grafana dashboard for the Grafana rollouts.
