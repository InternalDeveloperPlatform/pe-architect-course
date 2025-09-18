# 🛠️ Teams CLI Tool

A powerful command-line interface for managing engineering teams through the Teams API. This CLI provides developers with a fast, scriptable way to manage team operations without needing to use the web interface.

## 🎯 Overview

The Teams CLI tool allows you to:
- **Manage Teams**: Create, list, view, and delete engineering teams
- **Health Monitoring**: Check API connectivity and status
- **Automation**: Script team operations for CI/CD or automated workflows
- **Multiple Environments**: Connect to different API endpoints

## 📋 Prerequisites

**Required Software**:
- **Python 3.8+** with pip package manager
- **Network access** to the Teams API (localhost:8080 by default)

**Recommended Setup**:
- Complete the [Teams API deployment](../teams-api/README.md) first
- Have the Teams API running and accessible

**Verify Prerequisites**:
```bash
# Check Python version
python3 --version

# Check if Teams API is accessible (if running locally)
curl -f http://localhost:8080/health || echo "Teams API not accessible"
```

## ⚙️ Installation & Setup

### Step 1: Install Dependencies

```bash
# Install required Python packages
pip install -r requirements.txt

# Or install with pip3 if needed
pip3 install -r requirements.txt
```

**If you encounter permission issues**:
```bash
# Install in user directory
pip install --user -r requirements.txt

# Or use virtual environment (recommended)
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### Step 2: Make Script Executable

```bash
# Make the CLI script executable
chmod +x teams_cli.py

# Verify it's executable
ls -la teams_cli.py
```

### Step 3: Optional - Create Global Command

For easier access from anywhere in your system:

```bash
# Create a symlink in your PATH
sudo ln -s $(pwd)/teams_cli.py /usr/local/bin/teams-cli

# Or add to your user bin directory
mkdir -p ~/.local/bin
ln -s $(pwd)/teams_cli.py ~/.local/bin/teams-cli

# Make sure ~/.local/bin is in your PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

**Verify global access**:
```bash
# Test the global command
teams-cli --help
```

## 🚀 Usage Examples

### Health Check

Always start by verifying API connectivity:

```bash
# Check API health
python teams_cli.py health

# Expected output:
# ✅ API is healthy
# Status: ok
# Teams count: 3
```

### Creating Teams

Create teams for your organization:

```bash
# Create individual teams
python teams_cli.py create "Backend Team"
python teams_cli.py create "Frontend Team"
python teams_cli.py create "DevOps Team"
python teams_cli.py create "QA Team"

# Expected output for each:
# ✅ Team created successfully
# ID: 123e4567-e89b-12d3-a456-426614174000
# Name: Backend Team
# Created: 2024-01-15T10:30:00Z
```

**Batch team creation**:
```bash
# Create multiple teams with a script
for team in "Backend Team" "Frontend Team" "DevOps Team" "QA Team"; do
    python teams_cli.py create "$team"
done
```

### Listing Teams

View all existing teams:

```bash
# List all teams
python teams_cli.py list

# Expected output:
# 📋 Teams List (4 teams found)
#
# ID: 123e4567-e89b-12d3-a456-426614174000
# Name: Backend Team
# Created: 2024-01-15T10:30:00Z
#
# ID: 456e7890-e89b-12d3-a456-426614174001
# Name: Frontend Team
# Created: 2024-01-15T10:31:00Z
# ...
```

### Getting Team Details

Retrieve detailed information about a specific team:

```bash
# Get specific team details (replace with actual ID)
python teams_cli.py get "123e4567-e89b-12d3-a456-426614174000"

# Expected output:
# 📄 Team Details
# ID: 123e4567-e89b-12d3-a456-426614174000
# Name: Backend Team
# Created: 2024-01-15T10:30:00Z
# Members: 8
# Status: Active
```

### Deleting Teams

Remove teams that are no longer needed:

```bash
# Delete a specific team (replace with actual ID)
python teams_cli.py delete "123e4567-e89b-12d3-a456-426614174000"

# Expected output:
# ⚠️  Are you sure you want to delete 'Backend Team'? (y/N): y
# ✅ Team 'Backend Team' deleted successfully
```

**Force delete without confirmation**:
```bash
# Skip confirmation prompt
python teams_cli.py delete "123e4567-e89b-12d3-a456-426614174000" --force
```

### Using Different API Endpoints

Connect to different environments or deployments:

```bash
# Use custom API URL
python teams_cli.py --url http://teams-api.company.com list

# Use API in different namespace (Kubernetes)
python teams_cli.py --url http://teams-api.staging.svc.cluster.local list

# Use HTTPS with authentication
python teams_cli.py --url https://teams-api.prod.company.com --token $API_TOKEN list
```

## 🔧 Advanced Usage

### Environment Variables

Set default configuration with environment variables:

```bash
# Set default API URL
export TEAMS_API_URL="http://teams-api.company.com"
export TEAMS_API_TOKEN="your-api-token"

# Now you can use the CLI without --url flag
python teams_cli.py list
```

### JSON Output

Get machine-readable output for automation:

```bash
# Get JSON output instead of formatted text
python teams_cli.py list --output json

# Pipe to jq for processing
python teams_cli.py list --output json | jq '.teams[] | select(.name | contains("Backend"))'
```

### Scripting Examples

**Team rotation script**:
```bash
#!/bin/bash
# Rotate team assignments weekly

# Get all team IDs
team_ids=$(python teams_cli.py list --output json | jq -r '.teams[].id')

for team_id in $team_ids; do
    echo "Processing team: $team_id"
    # Add your rotation logic here
done
```

**Health monitoring script**:
```bash
#!/bin/bash
# Monitor API health for alerting

if ! python teams_cli.py health --quiet; then
    echo "ALERT: Teams API is unhealthy" | mail -s "API Alert" admin@company.com
fi
```

## 🆘 Troubleshooting

### Common Issues and Solutions

#### 1. "Command not found" Error

**Symptoms**: `bash: teams_cli.py: command not found`

**Solutions**:
```bash
# Make sure you're in the correct directory
pwd
ls -la teams_cli.py

# Use full path if not in current directory
/path/to/workshop/teams-management/cli/teams_cli.py health

# Or make sure it's executable
chmod +x teams_cli.py
```

#### 2. Python Import Errors

**Symptoms**: `ModuleNotFoundError: No module named 'requests'`

**Diagnosis**:
```bash
# Check if requirements are installed
pip list | grep requests

# Check Python path
python3 -c "import sys; print(sys.path)"
```

**Solutions**:
```bash
# Reinstall requirements
pip install -r requirements.txt

# Try with pip3 if using Python 3
pip3 install -r requirements.txt

# Use virtual environment
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

#### 3. API Connection Issues

**Symptoms**: `Connection error: Failed to connect to API`

**Diagnosis**:
```bash
# Test API connectivity manually
curl -f http://localhost:8080/health

# Check if port forwarding is active (for Kubernetes)
kubectl get pods -n teams-api

# Verify API is running
kubectl logs -n teams-api deployment/teams-api
```

**Solutions**:
```bash
# Start port forwarding for Kubernetes deployment
kubectl port-forward -n teams-api svc/teams-api-service 8080:80

# Use correct API URL for your setup
python teams_cli.py --url http://correct-api-url health

# Check firewall or network restrictions
telnet localhost 8080
```

#### 4. Permission Denied Errors

**Symptoms**: `Permission denied` when trying to execute

**Solutions**:
```bash
# Make script executable
chmod +x teams_cli.py

# Check ownership
ls -la teams_cli.py

# Run with python explicitly if needed
python3 teams_cli.py health
```

#### 5. Authentication Issues

**Symptoms**: `401 Unauthorized` or `403 Forbidden`

**Solutions**:
```bash
# Check if API requires authentication
curl -i http://localhost:8080/teams

# Use authentication token if required
python teams_cli.py --token your-token-here list

# Set environment variable
export TEAMS_API_TOKEN="your-token"
```

### Getting Additional Help

#### Built-in Help

```bash
# General help
python teams_cli.py --help

# Command-specific help
python teams_cli.py create --help
python teams_cli.py delete --help
python teams_cli.py list --help
```

#### Debug Mode

```bash
# Enable verbose output for troubleshooting
python teams_cli.py --verbose health
python teams_cli.py --debug create "Test Team"
```

#### Logs and Diagnostics

```bash
# Check API logs if available
kubectl logs -f deployment/teams-api -n teams-api

# Test API endpoints manually
curl -v http://localhost:8080/health
curl -v http://localhost:8080/teams
```

## 📚 Command Reference

### Global Options

- `--url URL`: API base URL (default: http://localhost:8080)
- `--token TOKEN`: Authentication token
- `--output FORMAT`: Output format (text, json)
- `--verbose`: Enable verbose output
- `--help`: Show help message

### Commands

| Command | Description | Example |
|---------|-------------|---------|
| `health` | Check API health | `teams-cli health` |
| `list` | List all teams | `teams-cli list` |
| `get ID` | Get team details | `teams-cli get "team-id"` |
| `create NAME` | Create new team | `teams-cli create "New Team"` |
| `delete ID` | Delete team | `teams-cli delete "team-id"` |

### Exit Codes

- `0`: Success
- `1`: General error
- `2`: API connection error
- `3`: Authentication error
- `4`: Not found error

## 🎯 Next Steps

### Integration Options

1. **CI/CD Integration**: Use in build pipelines for team management
2. **Automation Scripts**: Create automated team provisioning workflows
3. **Monitoring Integration**: Add to monitoring scripts for API health checks

### Advanced Features

Consider extending the CLI with:
- Team member management
- Bulk operations support
- Configuration file support
- Interactive mode

### Related Tools

- **Teams API**: [Teams API Documentation](../teams-api/README.md)
- **Teams UI**: [Web Interface](../teams-app/README.md)
- **Workshop Overview**: [Main README](../../README.md)

## ✅ Verification Checklist

Your CLI setup is complete when:
- [ ] Dependencies installed successfully
- [ ] Script is executable
- [ ] Health check passes
- [ ] Can create, list, and delete teams
- [ ] Global command works (if configured)
- [ ] Error handling provides clear feedback

**Ready to manage teams like a pro!** 🚀 Your CLI tool is now ready for daily team management operations.
