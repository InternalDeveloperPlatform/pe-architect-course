### Setup

Images are located at:
https://hub.docker.com/u/olivercodes01

After using deployment files, you can port-forward it to try.

k port-forward -n teams-api svc/teams-api-service 8080:80

### Examples

curl localhost:8080
> {"message":"Teams API is running"}

curl -X POST "http://localhost:8080/teams" \
     -H "Content-Type: application/json" \
     -d '{"name": "BackendTeam"}'
> {"id":"fc9402c5-2b26-41b2-8b97-ccdefdc65fe7","name":"Backend Team","created_at":"2025-08-11T09:41:48.713281"}

curl http://localhost:8080/teams
> [{"id":"fc9402c5-2b26-41b2-8b97-ccdefdc65fe7","name":"Backend Team","created_at":"2025-08-11T09:41:48.713281"}]

curl -X DELETE http://localhost:8080/teams/fc9402c5-2b26-41b2-8b97-ccdefdc65fe7

> {"message":"Team 'Backend Team' deleted successfully"}

Note: strongly recommend not putting spaces in the team name for the next step of the workshop
