# DAP Dockerization

- Install Docker, yq, and jq
- Run `./scripts/start.sh up`
- Start Postgres connector
  ```
  curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/ -d @./configs/register-postgres.json
  ```

## Docker Usage

- Run `./scripts/start.sh up` to stop and start all container services again
- To (re)build specific container services, run `./scripts/start.sh up <container_name_1> <container_name_2>`
- To rebuild a container service `ENV=dev docker-compose -f ./docker/docker-compose.yml up --build -d <container_name>`, here `dev` is current environment. Replace `<container_name>` with container service you want to restart
- To restart a container without rebuilding `ENV=dev docker-compose -f ./docker/docker-compose.yml restart <container_name>`, replace `<container_name>` with container service you want to restart
- To view container logs `ENV=dev docker-compose -f ./docker/docker-compose.yml logs -f <container_name>`
- Login to a container `docker exec -it <container_name> zsh`, if `zsh` doesn't exists use `bash` or `sh`
- Run `./scripts/start.sh config` to see how docker compose file gets evaluated.
- Run `./scripts/start.sh config <container_name_1> <container_name_2>` to see config of service `container_name_1` and `container_name_2`
- Run `./scripts/start.sh down` for cleanup

## Troubleshooting

- **Not able to connect to some hosts from docker containers or PROXY ISSUE**

  ```
  # edit vim ~/.docker/config.json to include proxy settings as

  {
    "proxies" : {
      "default" : {
        "httpsProxy" : "",
        "httpProxy" : "",
        "noProxy" : ""
      }
    },
    ...
  }
  ```
