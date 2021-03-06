FROM ashtr/devbox:ami AS BUILD_IMAGE
ARG ENV=${ENV:-dev}
ENV ENV=${ENV:-dev}

WORKDIR /usr/src/app

COPY package.json .

RUN set -ex; \
  if [ ! -z ${HTTP_PROXY} ] && type yarn >/dev/null 2>&1; then \
  echo "Setting Proxy to ${HTTP_PROXY}"; \
  yarn config set proxy ${HTTP_PROXY}; \
  yarn config set https-proxy ${HTTP_PROXY}; \
  yarn config set strict-ssl false ; \
  npm config set proxy ${HTTP_PROXY}; \
  npm config set https-proxy ${HTTP_PROXY}; \
  npm config set http-proxy ${HTTP_PROXY}; \
  fi; \
  yarn install
ENV PATH=/usr/src/app/node_modules/.bin:/node_modules/.bin:$PATH

COPY . .

RUN set -eux;\
  if [ ! -z ${HTTPS_PROXY} ]; then \
  if [ ! -f ./.bowerrc ]; then \
  echo '{}' > ./.bowerrc; \
  fi;\
  jq --argjson obj "{ \"proxy\": \"${HTTP_PROXY}\", \"https-proxy\": \"${HTTP_PROXY}\", \"strict-ssl\": false }" '. + $obj' < ./.bowerrc > temp && mv temp ./.bowerrc; \
  fi; \
  bower install --allow-root --production

RUN gulp dist

################################################################################

FROM node:8-alpine AS PROD

ARG VCAP_APP_PORT=${VCAP_APP_PORT:-5000}
ARG node_env=$node_env:-release}
ARG uaa_service_label=${uaa_service_label:-predix-uaa}
ARG NEW_RELIC_APP_NAME=${NEW_RELIC_APP_NAME:-dap-configure-release}
ARG NEW_RELIC_KEY=${NEW_RELIC_KEY:-e03bc89d928dbbb725caabecd26ea6c1a085f9e0}
ARG ENABLE_NEWRELIC_MONITORING=${ENABLE_NEWRELIC_MONITORING:-true}
ARG logger_level=${ENABLE_NEWRELIC_MONITORING:-info}

ENV VCAP_APP_PORT=${VCAP_APP_PORT}
ENV node_env=$node_env}
ENV uaa_service_label=${uaa_service_label}
ENV NEW_RELIC_APP_NAME=${NEW_RELIC_APP_NAME}
ENV NEW_RELIC_KEY=${NEW_RELIC_KEY}
ENV ENABLE_NEWRELIC_MONITORING=${ENABLE_NEWRELIC_MONITORING}
ENV logger_level=${ENABLE_NEWRELIC_MONITORING}

WORKDIR /usr/src/app

COPY --from=BUILD_IMAGE /usr/src/app/dist /usr/src/app

EXPOSE ${VCAP_APP_PORT}

CMD node server/app.js
