#!/bin/bash


echo "init setup.sh";
ls -l /var/www/html/;
rm -rf /var/www/html/*;

sleep 10;

if [ ! -f /var/www/html/wp-config-sample.php ]; then
    echo "configs wp";

    wp core download --allow-root --path=/var/www/html;

    wp config create --allow-root \
        --path=/var/www/html \
        --dbname=$MARIADB_DATABASE \
        --dbuser=$MARIADB_USER \
        --dbpass=$MARIADB_PASSWORD \
        --dbhost=$MARIADB_HOST \
        --skip-check

    wp core install --allow-root \
        --path=/var/www/html \
        --title="Inception" \
        --url=$DOMAIN_NAME \
        --admin_user=$WORDPRESS_ROOT_USER \
        --admin_password=$WORDPRESS_ROOT_PASSWORD \
        --admin_email=$WORDPRESS_ROOT_EMAIL
    
    wp user create --allow-root	\
        --path=/var/www/html "$WORDPRESS_USER" "$WORDPRESS_EMAIL" \
        --user_pass=$WORDPRESS_PASSWORD \
        --role=$WORDPRESS_USER_ROLE
fi

exec /usr/sbin/php-fpm8.2 -F
