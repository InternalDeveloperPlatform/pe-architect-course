# Platform Engineering Architect Course

Companion repo for the [PlatformEngineering.org](https://platformengineering.org) Architect certification course. Hands-on workshop modules covering monitoring, policy-as-code, security operations, and team management on Kubernetes.

## Quick start

This repo is designed to run inside a [Coder](https://coder.com/) cloud development environment. When the workspace starts, the devcontainer bootstrap script automatically provisions a Kind cluster, installs ingress-nginx via Terraform, and configures a local container registry — everything you need is ready when you open the terminal.

1. Launch your Coder workspace (provided during the course)
2. Open a terminal and navigate to `workshop/`
3. Start with [`workshop/foundation/README.md`](workshop/foundation/README.md)

## Repo structure

```
pe-architect-course/
├── .devcontainer/          # Coder/devcontainer configuration
│   ├── devcontainer.json
│   ├── postCreateCommand.sh   # Provisions Kind cluster, Terraform, tooling
│   └── postStartCommand.sh
├── setup/
│   ├── kind/               # Kind cluster configuration
│   │   └── cluster.yaml
│   └── terraform/          # Terraform configs (ingress-nginx, Gatekeeper, Grafana)
│       ├── idp-base.tf
│       ├── idp-ingress.tf
│       ├── providers.tf
│       └── variables.tf
├── workshop/               # All workshop modules — start here
│   ├── foundation/         # Module 1: Cluster setup, Grafana, Gatekeeper
│   ├── capoc/              # Module 2: Compliance at Point of Change
│   │   ├── cve/            #   CVE scanning policies
│   │   └── quality/        #   Code quality gates
│   ├── secops/             # Module 3: Falco runtime security
│   └── teams-management/   # Module 4: Platform APIs & developer experience
│       ├── teams-api/      #   FastAPI team management service
│       ├── teams-app/      #   Angular web UI
│       ├── cli/            #   CLI tool
│       ├── keycloak/       #   SSO/OIDC provider
│       └── operator/       #   Kubernetes controller
├── CONTRIBUTING.md
└── README.md               # ← You are here
```

## Workshop modules

The modules are designed to be completed in order. Each builds on the infrastructure from the previous one.

| Module | Directory | What you'll learn |
|--------|-----------|-------------------|
| **Foundation** | `workshop/foundation/` | Kubernetes cluster verification, Grafana monitoring stack, OPA Gatekeeper setup |
| **CapOc** | `workshop/capoc/` | CVE scanning policies, code quality gates, admission control |
| **SecOps** | `workshop/secops/` | Falco runtime security monitoring, custom security rules |
| **Teams Management** | `workshop/teams-management/` | RESTful APIs, Angular UI, CLI tooling, Keycloak SSO, Kubernetes operators |

## Environment and tooling

The Coder workspace comes pre-installed with everything you need. The bootstrap script (`postCreateCommand.sh`) installs and configures:

- **Kind** — local Kubernetes cluster
- **Terraform** — provisions ingress-nginx, Gatekeeper, and the Grafana monitoring stack
- **kubectl**, **Helm**, **yq**, **jq** — standard Kubernetes tooling
- **mkcert** — local TLS certificates
- **score-k8s** — Score specification for Kubernetes
- **glow** — terminal-based Markdown reader
- **Local container registry** — for pushing custom images during workshops

## Accessing services

| Access method | URL pattern | When to use |
|---------------|------------|-------------|
| Coder Desktop VPN | `http://<workspace>.coder:<port>` | macOS/Windows with Coder Desktop |
| Ingress (sslip.io) | `http://<service>.127.0.0.1.sslip.io` | Host-based routing through ingress-nginx |
| Port-forward | `http://localhost:<port>` | Fallback for any environment |

Linux users without Coder Desktop should use `coder port-forward` — see the [Foundation README](workshop/foundation/README.md) for details.

## Prerequisites

- A Coder workspace (provided during the course)
- A decent internet connection
- Optionally, VS Code with the [Coder remote extension](https://coder.com/docs/ides/vscode)

Recommended reading (not required):
- [Effective Platform Engineering](https://effectiveplatformengineering.com) — Chankramath, Oliver, Cheneweth, and Alvarez
- [The Platform Engineer's Handbook](https://www.packtpub.com/en-us/product/the-platform-engineers-handbook-9781806380121) — Chankramath

## Contributing

Found a bug, a wrong command, or a way to make the workshop better? See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

Course materials for PlatformEngineering.org Architect certification. See course terms for usage.
