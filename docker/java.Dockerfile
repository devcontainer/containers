# Please have umtm.zip file in root folder of the project
# docker build \
#   --build-arg ENV=dev \
#   --build-arg SERVICE_NAME=dap-audit-service \
#   --build-arg SERVICE_VERSION=0.0.1-SNAPSHOT \
#   -t dap-audit-service 
#   -f java.Dockerfile .
FROM maven:3.5.2-jdk-8-slim AS BUILD_IMAGE

ARG ENV=${ENV:-dev}
ENV ENV=${ENV:-dev}

WORKDIR /usr/src/app
COPY . .
COPY ./.${ENV}.env .env
COPY umtm.zip ${MAVEN_CONFIG}/repository/com/ge/digital/services/umtm-client/
# RUN env; \
#   if [ "${HTTP_PROXY}" != "" ]; then \
#   echo "<settings><proxies><proxy> <id>http-proxy</id> <active>true</active> <protocol>http</protocol> <host>PITC-Zscaler-ASPAC-Bangalore3PR.proxy.corporate.ge.com</host> <port>80</port> </proxy> <proxy> <id>https-proxy</id> <active>true</active> <protocol>https</protocol> <host>PITC-Zscaler-ASPAC-Bangalore3PR.proxy.corporate.ge.com</host> <port>80</port> </proxy> </proxies> </settings>" > ${MAVEN_CONFIG}/settings.xml; \
#   fi;\
#   cd ${MAVEN_CONFIG}/repository/com/ge/digital/services/umtm-client; \
#   unzip umtm.zip -d .; \
#   ls -la ;\
#   pwd;\
#   cd /usr/src/app; \
#   mvn clean install;

RUN set -eux;\ 
  cd ${MAVEN_CONFIG}/repository/com/ge/digital/services/umtm-client; \
  unzip umtm.zip -d .; \
  cd /usr/src/app; \
  if [ "${HTTP_PROXY}" != "" ]; then \
  hostport=$(echo "${HTTP_PROXY}" | sed -e 's/^\(\([^/]\+\):\/\/\)\?\(\([^@:]\+\)\(:\([^@]\+\)\)\?@\)\?\(\([^\/]\+\)\(:[0-9]\+\)\)\/\?.*$/\2,\4,\6,\8\9/g' | tr ':' ','| awk -F',' '{print $4" "$5 }' ); \
  pHost=$(echo $hostport | cut -d' ' -f1); \
  pPort=$(echo $hostport | cut -d' ' -f2); \
  fi;\
  mvn -Dhttp.proxyHost=${pHost} -Dhttp.proxyPort=${pPort} -Dhttps.proxyHost=${pHost} -Dhttps.proxyPort=${pPort} -Dhttp.nonProxyHosts=${NO_PROXY} clean install;

###############################################################################

FROM openjdk:8-jre AS RUN

ARG GIT_REPO_PATH
ARG GIT_REPO_CHECKOUT_REF
ARG SERVICE_NAME
ARG SERVICE_VERSION
ARG UAI=${UAI:-UAI2008475}
ARG ENV=${ENV:-dev}
ARG SUPPORTED_BY=${SUPPORTED_BY:-dap.help@ge.com}
ARG PROJECT=${PROJECT:-dap}

ENV GIT_REPO_PATH=${GIT_REPO_PATH:-} \
  GIT_REPO_CHECKOUT_REF=${GIT_REPO_CHECKOUT_REF:-} \
  APP_HOME=/root/dev/myapp/ \
  SERVICE_NAME=${SERVICE_NAME:-} \
  SERVICE_VERSION=${SERVICE_VERSION:-} \
  UAI=${UAI:-UAI2008475} \
  ENV=${ENV:-dev} \
  SUPPORTED_BY=${SUPPORTED_BY:-dap.help@ge.com} \
  SERVICE_NAME=${SERVICE_NAME:-} \
  SERVICE_VERSION=${SERVICE_VERSION:-} \
  PROJECT=${PROJECT:-dap}

LABEL uai=${UAI} \
  env=${ENV}\
  SupportedBy=${SUPPORTED_BY} \
  service_name=${SERVICE_NAME}\
  service_version=${SERVICE_VERSION}\
  project=${PROJECT}\
  AUTHOR="Ashish Gupta <ashish.gupta5@ge.com>"

WORKDIR /root/
COPY --from=BUILD_IMAGE /usr/src/app/target/${SERVICE_NAME}-${SERVICE_VERSION}.jar ${SERVICE_NAME}-${SERVICE_VERSION}.jar
EXPOSE 8080
CMD java -jar ${SERVICE_NAME}-${SERVICE_VERSION}.jar