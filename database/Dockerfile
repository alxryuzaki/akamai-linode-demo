# Define the base linux distribution.
FROM alpine:edge

# Define the maintainer of the project.
LABEL maintainer="fvilarinho@gmail.com"

# Default environment variables.
ARG FLYWAY_VERSION=9.12.0
ENV MYSQL_ROOT_PASSWORD=demo
ENV HOME_DIR=/home/user
ENV ETC_DIR=${HOME_DIR}/etc
ENV BIN_DIR=${HOME_DIR}/bin
ENV SQL_DIR=${HOME_DIR}/sql

# Install essential packages.
RUN apk update && \
    apk add --no-cache bash ca-certificates nss curl wget vim net-tools bind-tools openjdk11-jre libxml2 mariadb mariadb-client

# Install the required directories.
RUN addgroup -S group && \
    adduser -S user -G group && \
    mkdir -p ${SQL_DIR} ${BIN_DIR} ${ETC_DIR} && \
    mkdir -p /var/run/mysqld && \
    mkdir -p /var/lib/mysql && \
    mkdir -p /var/log/mysql && \
    rm -f /etc/my.cnf

# Install the version control.
RUN wget -qO- https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/${FLYWAY_VERSION}/flyway-commandline-${FLYWAY_VERSION}-linux-x64.tar.gz | tar xvz && \
    mv ./flyway-${FLYWAY_VERSION} /opt && \
    ln -s /opt/flyway-${FLYWAY_VERSION} /opt/flyway && \
    rm -rf /opt/flyway/sql && \
    rm -rf /opt/flyway/jre && \
    rm -rf /opt/flyway/drivers/h2-*.jar && \
    rm -f /opt/flyway/conf/flyway.conf && \
    ln -s /opt/flyway/flyway /usr/local/bin && \
    ln -s ${SQL_DIR} /opt/flyway/sql

# Copy the default configurations, database scripts and boot script.
COPY bin/startup.sh ${BIN_DIR}
COPY etc/my.cnf ${ETC_DIR}
COPY etc/flyway.conf ${ETC_DIR}
COPY sql/* ${SQL_DIR}/

# Set the startup.
RUN chown -R user:group ${HOME_DIR} && \
    chmod -R o-rwx ${HOME_DIR} && \
    chmod +x ${BIN_DIR}/*.sh && \
    ln -s ${ETC_DIR}/flyway.conf /opt/flyway/conf/flyway.conf && \
    ln -s ${ETC_DIR}/my.cnf /etc/my.cnf && \
    ln -s ${BIN_DIR}/startup.sh /entrypoint.sh

# Set default work directory.
WORKDIR ${HOME_DIR}

# Set the default port.
EXPOSE 3306

# Boot script
ENTRYPOINT ["/entrypoint.sh"]