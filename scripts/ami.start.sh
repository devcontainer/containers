#! /usr/bin/env bash
yum update -y;

# Install maven
yum install -y maven curl tar;
mkdir -p ${HOME}/.m2

### SOME ENV NEEDS TO BE SET ###
export JAVA_HOME=/usr/lib/jvm/java
export MAVEN_HOME=/usr/share/maven
export MAVEN_CONFIG=/root/.m2
export APP_TARGET=${APP_TARGET:-target}
export JAVA_OPTS=${JAVA_OPTS:-}
# echo "---> Starting Spring Boot application"

### HOW TO RUN JAVA JAR FILES ###
# java $JAVA_OPTS -jar `find $APP_TARGET -maxdepth 1 -regex ".*\(jar\|war\)"`

### HOW TO RUN MAVEN SPRINGBOOT APP ###


# Install go
mkdir -p /go;
chmod -R 777 /go;
yum -y install git golang;
yum clean all
export GOPATH=/go

# Install go
curl -sL https://rpm.nodesource.com/setup_8.x | bash -;
yum install -y nodejs;
curl -o- -L https://yarnpkg.com/install.sh | bash;
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:${MAVEN_HOME}:$PATH"


tail -f /dev/null