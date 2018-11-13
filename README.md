# DAP Dockerization

- Install Docker
- Run `./scripts/start.sh`
- Start Postgres connector
  ```
  curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/ -d @./configs/register-postgres.json
  ```
