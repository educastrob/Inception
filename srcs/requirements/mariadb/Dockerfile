FROM debian:oldstable

ARG MARIADB_HOST
ARG MARIADB_ROOT
ARG MARIADB_ROOT_PASSWORD
ARG MARIADB_DATABASE
ARG MARIADB_USER
ARG MARIADB_PASSWORD

RUN apt update \
	&& apt upgrade \
	&& apt install -y mariadb-server

COPY ./tools/init.sh /usr/local/bin/init.sh

RUN mkdir -p /var/run/mysqld /run/mysqld \
	&& chown -R mysql:mysql /var/run/mysqld /run/mysqld \
	&& chmod 755 /var/run/mysqld /run/mysqld \
	&& chmod +x /usr/local/bin/init.sh

RUN sed -i "s/127.0.0.1/0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf 

ENTRYPOINT ["/usr/local/bin/init.sh"]
