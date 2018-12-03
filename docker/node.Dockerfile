FROM node:8-alpine AS BUILD_STAGE

WORKDIR /usr/src/app

COPY package.json .

RUN yarn install --production

COPY . .

RUN bower install --allow-root --production

RUN ./node_modules/.bin/gulp dist

################################################################################

FROM node:8-alpine AS PROD

ARG VCAP_APP_PORT=${VCAP_APP_PORT:-5000}
ARG node_env=$node_env:-release}
ARG uaa_service_label=${uaa_service_label:-predix-uaa}
ARG NEW_RELIC_APP_NAME=${NEW_RELIC_APP_NAME:-dap-configure-release}
ARG NEW_RELIC_KEY=${NEW_RELIC_KEY:-e03bc89d928dbbb725caabecd26ea6c1a085f9e0}
ARG ENABLE_NEWRELIC_MONITORING=${ENABLE_NEWRELIC_MONITORING:-true}
ARG logger_level=${ENABLE_NEWRELIC_MONITORING:-info}

ENV VCAP_APP_PORT=${VCAP_APP_PORT:-5000}
ENV node_env=$node_env:-release}
ENV uaa_service_label=${uaa_service_label:-predix-uaa}
ENV NEW_RELIC_APP_NAME=${NEW_RELIC_APP_NAME:-dap-configure-release}
ENV NEW_RELIC_KEY=${NEW_RELIC_KEY:-e03bc89d928dbbb725caabecd26ea6c1a085f9e0}
ENV ENABLE_NEWRELIC_MONITORING=${ENABLE_NEWRELIC_MONITORING:-true}
ENV logger_level=${ENABLE_NEWRELIC_MONITORING:-info}

WORKDIR /usr/src/app

COPY --from=BUILD_STAGE /usr/src/app/dist /usr/src/app

EXPOSE ${VCAP_APP_PORT}

CMD node server/app.js
