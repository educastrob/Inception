FROM alpine:3.21

RUN apk add --no-cache \
    mariadb \
    mariadb-client \
    envsubst

WORKDIR /run/mysqld

RUN mkdir -p /var/log/mysql \
    && chown mysql:mysql /run/mysqld /var/log/mysql

RUN mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

COPY ./conf/mariadb-server.cnf.template /etc/my.cnf.d/

COPY ./tools/docker-entrypoint.sh /run/mariadb/entrypoint.sh

RUN chmod +x /run/mariadb/entrypoint.sh

ENTRYPOINT ["/run/mariadb/entrypoint.sh"]