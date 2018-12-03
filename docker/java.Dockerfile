FROM maven:3.5.2-jdk-8-slim AS BUILD_IMAGE
WORKDIR /usr/src/app
COPY . .
RUN mvn clean install;

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
RUN env;
COPY --from=BUILD_IMAGE /usr/src/app/target/${SERVICE_NAME}-${SERVICE_VERSION}.jar ${SERVICE_NAME}-${SERVICE_VERSION}.jar
EXPOSE 8080
CMD java -jar ${SERVICE_NAME}-${SERVICE_VERSION}.jar