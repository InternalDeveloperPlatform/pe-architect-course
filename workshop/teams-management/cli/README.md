# Teams CLI Tool

A simple command-line interface for managing engineering teams through the Teams API. Provides a scriptable way to create, list, view, and delete teams without using the web interface.

## Prerequisites

- **Python 3.8+** with pip
- **Teams API running** and accessible (see [Teams API README](../teams-api/README.md))

Verify prerequisites:
```bash
python3 --version
pip3 --version
```

## Installation

### Step 1: Install Dependencies

```bash
# In Coder, install Python tooling first
sudo apt install -y python3.12-venv python3-pip

# Install required packages
pip install -r requirements.txt
```

If you encounter permission issues, use a virtual environment:
```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### Step 2: Make Script Executable

```bash
chmod +x teams_cli.py
```

### Step 3 (Optional): Create Global Command

```bash
# Symlink into your PATH
sudo ln -s $(pwd)/teams_cli.py /usr/local/bin/teams-cli

# Verify
teams-cli --help
```

## Usage

The CLI connects to the Teams API at `http://teams-api.127.0.0.1.sslip.io` by default. Use the `--url` flag to point to a different endpoint.

### Health Check

```bash
python teams_cli.py health

# Output:
# ✅ API Status: healthy
# 📊 Teams Count: 0
```

### Create a Team

```bash
python teams_cli.py create "Backend Team"

# Output:
# ✅ Created team: Backend Team
# 🆔 Team ID: fc9402c5-2b26-41b2-8b97-ccdefdc65fe7
# 📅 Created: 2026-06-17T10:30:45.123456
```

Create multiple teams:
```bash
for team in "Backend-Team" "Frontend-Team" "DevOps-Team" "QA-Team"; do
    python teams_cli.py create "$team"
done
```

> **Tip**: Avoid spaces in team names if you plan to use the operator component later. Use `Backend-Team` or `BackendTeam` instead of `Backend Team`.

### List Teams

```bash
python teams_cli.py list

# Output:
# 📋 Found 2 team(s):
# ------------------------------------------------------------
# 🏷️  Name: Backend-Team
# 🆔 ID: fc9402c5-2b26-41b2-8b97-ccdefdc65fe7
# 📅 Created: 2026-06-17T10:30:45.123456
# ------------------------------------------------------------
# 🏷️  Name: Frontend-Team
# 🆔 ID: a1b2c3d4-e5f6-7890-abcd-ef1234567890
# 📅 Created: 2026-06-17T10:31:22.654321
# ------------------------------------------------------------

# If no teams exist:
# 📭 No teams found
```

### Get a Specific Team

```bash
python teams_cli.py get "fc9402c5-2b26-41b2-8b97-ccdefdc65fe7"

# Output:
# 🏷️  Name: Backend-Team
# 🆔 ID: fc9402c5-2b26-41b2-8b97-ccdefdc65fe7
# 📅 Created: 2026-06-17T10:30:45.123456
```

### Delete a Team

```bash
python teams_cli.py delete "fc9402c5-2b26-41b2-8b97-ccdefdc65fe7"

# Output:
# ✅ Team 'Backend-Team' deleted successfully
```

Note: the delete command executes immediately with no confirmation prompt.

### Using a Different API Endpoint

```bash
# Point to a port-forwarded service
python teams_cli.py --url http://localhost:8080 list

# Point to a Coder workspace
python teams_cli.py --url http://<workspace-name>.coder:3002 health
```

## Command Reference

| Command | Description | Example |
|---------|-------------|---------|
| `health` | Check API health | `python teams_cli.py health` |
| `create NAME` | Create a new team | `python teams_cli.py create "My Team"` |
| `list` | List all teams | `python teams_cli.py list` |
| `get ID` | Get a specific team | `python teams_cli.py get "team-id"` |
| `delete ID` | Delete a team | `python teams_cli.py delete "team-id"` |

### Global Options

| Flag | Description |
|------|-------------|
| `--url URL` | API base URL (default: `http://teams-api.127.0.0.1.sslip.io`) |
| `--help` | Show help message |

### Exit Codes

- `0` — Success
- `1` — Any error (connection failure, not found, bad request, etc.)

## Troubleshooting

### "ModuleNotFoundError: No module named 'requests'"

```bash
pip install -r requirements.txt

# Or with pip3
pip3 install -r requirements.txt
```

### "Could not connect to API"

The CLI can't reach the Teams API. Check that it's running:

```bash
# Verify API pods are up
kubectl get pods -n teams-api

# Start port forwarding if needed
kubectl port-forward -n teams-api svc/teams-api-service 8080:4200

# Then use the port-forwarded URL
python teams_cli.py --url http://localhost:8080 health
```

### "Permission denied"

```bash
chmod +x teams_cli.py

# Or run with python explicitly
python3 teams_cli.py health
```

### Built-in Help

```bash
# General help
python teams_cli.py --help

# Help for a specific command
python teams_cli.py create --help
```

## Next Steps

- **Teams API**: [API Documentation](../teams-api/README.md) — the service this CLI talks to
- **Teams UI**: [Web Interface](../teams-app/README.md) — browser-based alternative
- **Workshop Overview**: [Main README](../../README.md)

## Verification Checklist

Your CLI setup is complete when:
- [ ] Dependencies installed (`pip install -r requirements.txt`)
- [ ] Health check passes (`python teams_cli.py health`)
- [ ] Can create, list, get, and delete teams
- [ ] Error messages are clear when API is unreachable
