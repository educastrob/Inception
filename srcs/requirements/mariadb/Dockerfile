FROM debian:oldstable

ARG MARIADB_USER
ARG MARIADB_PASSWORD
ARG MARIADB_DATABASE
ARG MARIADB_ROOT_PASSWORD

# Export as environment variables for the script
ENV MARIADB_USER=$MARIADB_USER
ENV MARIADB_PASSWORD=$MARIADB_PASSWORD
ENV MARIADB_DATABASE=$MARIADB_DATABASE
ENV MARIADB_ROOT_PASSWORD=$MARIADB_ROOT_PASSWORD

# Install mariadb
RUN apt update && apt upgrade -y && apt install -y mariadb-server && rm -rf /var/lib/apt/lists/*

# Create and set permissions for MySQL directories
RUN mkdir -p /var/run/mysqld /var/lib/mysql && \
    chown -R mysql:mysql /var/run/mysqld /var/lib/mysql && \
    chmod 777 /var/run/mysqld

# Copy configuration
COPY /conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
RUN chmod 644 /etc/mysql/mariadb.conf.d/50-server.cnf

# Copy setup script
COPY /tools/setup.sh /tmp/setup.sh
RUN chmod +x /tmp/setup.sh

EXPOSE 3306

ENTRYPOINT ["/tmp/setup.sh"]