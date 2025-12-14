#!/usr/bin/env bash

# WordPress database setup using wp-cli
# The wp-cli creates the WordPress configuration file with the provided database credentials
wp --allow-root config create \
    --dbname="$DATABASE_NAME" \
    --dbuser="$ADMIN_NAME" \
    --dbpass="$ADMIN_PASSWORD" \
    --dbhost=mariadb \
    --dbprefix="wp_"

# WordPress installation
# The wp-cli command installs WordPress with the provided parameters: site title, URL, and admin credentials
wp core install --allow-root \
    --path=/var/www/html \
    --title="$WP_TITLE" \
    --url="$DOMAIN" \
    --admin_user="$ADMIN_NAME" \
    --admin_password="$ADMIN_PASSWORD" \
    --admin_email="$ADMIN_EMAIL"

# Creating an additional user
# The wp-cli creates a new user with the given username, email, and password
wp user create --allow-root \
    --path=/var/www/html \
    "$USER_NAME" \
    "$USER_EMAIL" \
    --user_pass="$USER_PASSWORD" \
    --role='author'

# Activating the default WordPress theme (Twenty Twenty-Four)
wp --allow-root theme activate twentytwentyfour

# Ensuring PHP-FPM is running to process PHP requests
exec php-fpm7.4 -F
