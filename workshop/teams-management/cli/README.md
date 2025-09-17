# Setup

### Install dependencies
`pip install -r cli-requirements.txt`

### Make the script executable
`chmod +x teams_cli.py`

### Optional: Create a symlink for easier access
`ln -s $(pwd)/teams_cli.py /usr/local/bin/teams-cli`

# Usage

### Check if the API is healthy
`python teams_cli.py health`
### or if you created the symlink:
`teams-cli health`

### Create teams
```
python teams_cli.py create "Backend Team"
python teams_cli.py create "Frontend Team"
python teams_cli.py create "DevOps Team"
```

### List all teams
`python teams_cli.py list`

### Get a specific team (use ID from list command)
`python teams_cli.py get "123e4567-e89b-12d3-a456-426614174000"`

### Delete a team
`python teams_cli.py delete "123e4567-e89b-12d3-a456-426614174000"`

### Use different API URL
`python teams_cli.py --url http://teams-api.local list`

### Get help
```
python teams_cli.py --help
python teams_cli.py create --help
```
