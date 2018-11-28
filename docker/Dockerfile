ARG GIT_USER_NAME
ARG GIT_USER_EMAIL
ARG HTTP_PROXY
ARG GOPATH
ARG JAVA_HOME
ARG MAVEN_HOME
ARG MAVEN_CONFIG
FROM amazonlinux:2 as build

# Generally a good idea to have these, extensions sometimes need them
ENV LANG=en_US.UTF-8 \
  LANGUAGE=en_US:en \
  LC_ALL=en_US.UTF-8 \
  COLORTERM=truecolor \
  TERM=xterm-256color \
  PYTHONIOENCODING=UTF-8 \
  GIT_USER_NAME=${GIT_USER_NAME:-"Ashish Gupta"} \
  GIT_USER_EMAIL=${GIT_USER_EMAIL:-"ashish.gupta5@ge.com"} \
  PATH=/root/.local/bin:/usr/local/bin:/node_modules/.bin:$PATH

LABEL AUTHOR="${GIT_USER_NAME} <${GIT_USER_EMAIL}>"

# Amazon default repo.list pacakges
RUN yum update -y; \
  # Install build packages
  yum install -y fontconfig mkfontdir; \
  # Install required packages
  yum install -y python-pip python3-pip wget git openssl tree zsh; \
  # Install dumb-init
  wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64; \
  chmod +x /usr/local/bin/dumb-init; \
  # clean yum packages
  yum clean all; \
  rm -rf /var/cache/yum;

## Packages from epel registry
#RUN set -eux; \
#  yum groupinstall -y "Development Tools"; \
#  # stow and neovim are epel pacakges
#  wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm; \
#  yum install -y ./epel-release-latest-7.noarch.rpm neovim; \
#  rm ./epel-release-latest-7.noarch.rpm; \
#  # clean yum packages
#  yum clean all; \
#  rm -rf /var/cache/yum;

# generate ssh keys
RUN set -eux; \
  ssh-keygen -q -t rsa -b 4096 -C ${GIT_USER_EMAIL} -N '' -f "${HOME}/.ssh/id_rsa"; \
  cp "${HOME}/.ssh/id_rsa.pub" "${HOME}/.ssh/authorized_keys"; \
  for key in /etc/ssh/ssh_host_*key.pub; do \ 
  echo "localhost $(cat ${key})" >> "${HOME}/.ssh/known_hosts";\
  done; \
  eval "$(ssh-agent -s)"; \
  ssh-add "${HOME}/.ssh/id_rsa"

# So that all process that we start are child of dumb-init
ENTRYPOINT [ "dumb-init", "--" ]
CMD ["zsh", "--"]

################################################################################
#============ Install SAWS for awscli ============#
# Install saws for awscli
RUN set -eux; \
  pip3 install --user saws;
#============ ./Install SAWS for awscli ==========#
################################################################################


################################################################################
#============ Install Java, Maven, SpringBoot ============#
ENV JAVA_HOME=${JAVA_HOME:-/usr/lib/jvm/java} \
  MAVEN_HOME=${MAVEN_HOME:-/usr/share/maven} \
  MAVEN_CONFIG=${MAVEN_CONFIG:-/root/.m2} \
  APP_TARGET=${APP_TARGET:-target} \
  JAVA_OPTS=${JAVA_OPTS:-}
RUN set -eux; \
  yum install -y maven; \
  yum clean all; \
  rm -rf /var/cache/yum;
#============ ./Install Java, Maven, SpringBoot ==========#
################################################################################


################################################################################
#============ Install Golang ============#
ENV GOPATH=${GOPATH:-/go}
RUN set -eux; \
  mkdir -p ${GOPATH}; \
  chmod -R 777 ${GOPATH}; \
  yum -y install golang; \
  yum clean all; \
  rm -rf /var/cache/yum;
#============ ./Install Golang ==========#
################################################################################


################################################################################
#============ Install Javascript, Typescript ============#
# Install node and yarn
RUN set -eux; \
  curl --silent --location https://rpm.nodesource.com/setup_8.x | bash -; \
  yum install -y nodejs; \
  curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo; \
  yum install -y yarn; \
  yum clean all; \
  rm -rf /var/cache/yum;

RUN set -eux; \
  # Install yarn packages
  yarn global add typescript parcel-bundler gulp bower neovim ts-node jest ts-jest tern;
#============ ./Install Javascript, Typescript ==========#
################################################################################
