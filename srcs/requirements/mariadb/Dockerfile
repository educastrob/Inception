# Use an oldstable Debian base image
FROM debian:oldstable

# Define environment variables that will be passed during the build
ARG ADMIN_NAME
ARG ADMIN_PASSWORD
ARG DATABASE_NAME
ARG ROOT_PASSWORD

# Update the system and install the MariaDB server, cleaning up package cache
RUN apt update -y && apt upgrade -y \
    && apt install mariadb-server -y \
    && rm -rf /var/lib/apt/lists/*

# Create the directory for MySQL process and set permissions
    RUN mkdir -p /var/run/mysqld \
	&& chown -R mysql:mysql /var/run/mysqld \
	&& chmod 777 /var/run/mysqld

# Copy the MariaDB configuration file into the container
COPY cnf/my.cnf /etc/mysql/my.cnf

# Copy the initialization script into the container
COPY conf/run.sh /tmp/run.sh

# Change script permissions and execute it to set up the database
RUN chmod 777 /tmp/run.sh && bash /tmp/run.sh

# Command to safely start the MariaDB service
CMD ["mysqld_safe"]