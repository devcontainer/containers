FROM golang:1.9 as BUILD_IMAGE

ARG ENV=${ENV:-dev}
ARG PROJECT=${PROJECT:-dap-metadata-service}
ARG REPO_GO_SRC_PATH=${REPO_GO_SRC_PATH:-github.build.ge.com/Digital-Asset-Passport/${PROJECT:-dap-metadata-service}}
ENV ENV=${ENV:-dev}
ENV PATH=${GOPATH}/bin:${PATH}

RUN go get github.com/tools/godep
WORKDIR ${GOPATH}/src/${REPO_GO_SRC_PATH}
COPY . .
COPY ./.${ENV}.env .env
RUN go get -d -v;
RUN CGO_ENABLED=0 GOOS=linux godep go build -a -installsuffix cgo -o /go/bin/app .

###############################################################################

FROM alpine:latest
ARG SERVICE_NAME
ARG SERVICE_VERSION
ARG UAI=${UAI:-UAI2008475}
ARG ENV=${ENV:-dev}
ARG SUPPORTED_BY=${SUPPORTED_BY:-dap.help@ge.com}
ARG PROJECT=${PROJECT:-dap}

ENV UAI=${UAI:-UAI2008475} \
  ENV=${ENV:-dev} \
  SUPPORTED_BY=${SUPPORTED_BY:-dap.help@ge.com} \
  SERVICE_NAME=${SERVICE_NAME:-} \
  SERVICE_VERSION=${SERVICE_VERSION:-} \
  PROJECT=${PROJECT:-dap} \
  GOPATH=/go \
  PATH=${GOPATH}/bin:${PATH}

LABEL uai=${UAI} \
  env=${ENV}\
  SupportedBy=${SUPPORTED_BY} \
  service_name=${SERVICE_NAME}\
  service_version=${SERVICE_VERSION}\
  project=${PROJECT}\
  AUTHOR="Ashish Gupta <ashish.gupta5@ge.com>"

RUN apk --no-cache add ca-certificates;

WORKDIR /root/
COPY --from=BUILD_IMAGE /go/bin/app .

EXPOSE 8080

CMD ["./app"]