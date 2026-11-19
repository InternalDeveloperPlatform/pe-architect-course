#!/bin/bash
teams-cli --url http://localhost:8083 health
teams-cli --url http://localhost:8083 list
echo "=== creating team \"CLI\": teams-cli --url http://localhost:8083 create \"CLI\" ==="
teams-cli --url http://localhost:8083 create "CLI"
