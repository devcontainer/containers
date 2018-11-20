# DAP Dockerization

- Install Docker
- Run `./scripts/start.sh`
- Start Postgres connector
  ```
  curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/ -d @./configs/register-postgres.json
  ```

## Docker Usage

- Run `./scripts/start.sh` to stop and start all container services again
- To rebuild a container service `ENV=dev docker-compose -f ./docker/docker-compose.yml up --build -d dap-data`, here `dev` is current environment and `dap-data` is service you want to rebuild
- To restart a container without rebuilding `ENV=dev docker-compose -f ./docker/docker-compose.yml restart <container_name>`, replace `<container_name>` with container service you want to restart
- To view container logs `ENV=dev docker-compose -f ./docker/docker-compose.yml logs -f <container_name>`
- Login to a container `docker exec -it <container_name> bash`, if `bash` doesn't exists use `sh`

## Troubleshooting

- **Not able to connect to some hosts from docker containers or PROXY ISSUE**

  ```
  # edit vim ~/.docker/config.json to include proxy settings as

  {
    "proxies" : {
      "default" : {
        "httpsProxy" : "http://sjc1intproxy01.crd.ge.com:8080",
        "httpProxy" : "http://sjc1intproxy01.crd.ge.com:8080",
        "noProxy" : "*.ge.com,*.zeplin.io,*.zpl.io,https://index.docker.io/v1/,127.0.0.1,localhost,openge.com,*.openge.ge.com,*.github.build.ge.com,*.predix.io"
      }
    },
    ...
  }
  ```
