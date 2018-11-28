#!/bin/bash
# set -ex

ROOT_DIR="$(dirname $0)/../"

if [ ! -f ${HOME}/.aws/credentials ]; then
  mkdir -p ${HOME}/.aws;
  touch ${HOME}/.aws/credentials;
fi;

# PROJECTS=("sbx" "")
# DEPLOYMENT_ZONE = dev | prod | qa
DEPLOYMENT_ZONE=("default" "prod" "qa" "dev")
randFile=$(md5 <(echo $(pwd)) | cut -d' ' -f4 | cut  -c1-6)
OIFS="${IFS}"
IFS=","
# READ ENV VARS in order default,prod,qa,dev
eval find  "${ROOT_DIR}/environment/docker/.{${DEPLOYMENT_ZONE[*]}}.env" -type f -exec sed -E 's/^\ \*\[^#\]+/export\ \&/g' '{}'  2>/dev/null + > ${randFile}
IFS="${OIFS}"
unset -v IFS
source ${randFile} && rm -rf ${randFile}

function up () {
  local services=();
  local unavailableServices=();
  if [ $# -eq 0 ]; then
    services=$(yq r ${ROOT_DIR}/docker/docker-compose.yml -j | jq -c '.services | keys' | echo $@)
    docker-compose -f ${ROOT_DIR}/docker/docker-compose.yml config
    docker-compose -f ${ROOT_DIR}/docker/docker-compose.yml down --remove-orphans
    # docker-compose --file ${ROOT_DIR}/docker/docker-compose.yml --project-name ${PROJECT_NAME:-$(basename ${PWD%/*})} up --build
    docker-compose --file ${ROOT_DIR}/docker/docker-compose.yml up --build
  else
    for i in $@; do
      if [ $(yq r ${ROOT_DIR}/docker/docker-compose.yml -j | jq ".services | has(\"${i}\")") = "true" ]; then
        services+=("${i}");
      else 
        unavailableServices+=("${i}");
      fi;
    done;
    if [ ${#unavailableServices[@]} -gt 0 ]; then 
      echo "Services not defined in compose file: ${unavailableServices[@]}";
    fi;
    if [ ${#services[@]} -gt 0 ]; then
      docker-compose -f ${ROOT_DIR}/docker/docker-compose.yml stop ${services[@]};
      docker-compose -f ${ROOT_DIR}/docker/docker-compose.yml rm -f ${services[@]};
      docker-compose --file ${ROOT_DIR}/docker/docker-compose.yml up --build ${services[@]};
    fi;
  fi;
}

# Prints docker-compose config after evalutating all environment variables can be 
# provided space seperated services to specifically print config of those services
function config() {
  local services=();
  local unavailableServices=();
  if [ $# -eq 0 ]; then
    docker-compose -f ${ROOT_DIR}/docker/docker-compose.yml config
  else
    for i in $@; do
      if [ $(yq r ${ROOT_DIR}/docker/docker-compose.yml -j | jq ".services | has(\"${i}\")") = "true" ]; then
        services+=("${i}");
      else 
        unavailableServices+=("${i}");
      fi;
    done;
    if [ ${#unavailableServices[@]} -gt 0 ]; then 
      echo "Services not defined in compose file: ${unavailableServices[@]}";
    fi;
    if [ ${#services[@]} -gt 0 ]; then
      docker-compose -f ${ROOT_DIR}/docker/docker-compose.yml config | \
        yq r - 'services' -j | \
        jq "{services: {$(echo ${services[@]} | sed -e '/\([^ ]\+\)/ s//\1: .\1,/g' -e '/,$/ s///g')}}" | \
        python -c 'import sys, yaml, json; yaml.safe_dump(json.load(sys.stdin), sys.stdout, default_flow_style=False)'
    fi;
  fi;
}

function down() {
    docker-compose -f ${ROOT_DIR}/docker/docker-compose.yml down --remove-orphans;
}
"$@"