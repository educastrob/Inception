#!/usr/bin/env bash

# Start the MariaDB service
service mariadb start

# Run SQL commands to create the database and the admin user
mariadb -u root -e \
    "CREATE DATABASE IF NOT EXISTS ${DATABASE_NAME}; \
    CREATE USER IF NOT EXISTS '${ADMIN_NAME}'@'%' IDENTIFIED BY '${ADMIN_PASSWORD}'; \
    GRANT ALL PRIVILEGES ON ${DATABASE_NAME}.* TO '${ADMIN_NAME}'@'%'; \
    FLUSH PRIVILEGES;"

# Set root password
mysqladmin -u root password '${ROOT_PASSWORD}'

# Reload the privileges again after setting the root password
mariadb -u root -e "FLUSH PRIVILEGES;"