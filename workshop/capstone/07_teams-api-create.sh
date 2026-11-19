#!/bin/bash
curl http://localhost:8083/health
echo -e "\n"
curl http://localhost:8083/teams
echo -e "\n"
echo "=== creating team REST_API ==="
curl -X POST "http://localhost:8083/teams" \
-H "Content-Type: application/json" \
-d '{"name": "REST_API"}'
echo -e "\n"