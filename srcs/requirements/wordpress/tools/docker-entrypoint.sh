#!/bin/ash

echo "Starting WordPress setup..."

until nc -z $MARIADB_HOST $MARIADB_PORT; do
    echo "Waiting for MariaDB..."
    sleep 2
done

echo "Configuring PHP-FPM..."
envsubst '$WORDPRESS_PORT' \
< /etc/php83/php-fpm.d/www.conf.template \
> /etc/php83/php-fpm.d/www.conf

if [ ! -f wp-config.php ]; then
    echo "Creating wp-config.php..."
    until wp-cli config create \
        --dbhost="$MARIADB_HOST:$MARIADB_PORT" \
        --dbname="$MARIADB_DATABASE" \
        --dbuser="$MARIADB_USER" \
        --dbpass="$(cat /run/secrets/mariadb_user_password)" \
        --dbprefix="wp_" \
        --allow-root; do
        echo "Failed to create config, retrying..."
        sleep 5
    done

    echo "define('WP_HOME', 'https://$WORDPRESS_DOMAIN');" >> wp-config.php
    echo "define('WP_SITEURL', 'https://$WORDPRESS_DOMAIN');" >> wp-config.php
    echo "\$_SERVER['HTTPS'] = 'on';" >> wp-config.php
    echo "\$_SERVER['SERVER_PORT'] = '443';" >> wp-config.php
fi

if ! wp-cli core is-installed --allow-root; then
    echo "Installing WordPress..."
    
    wp-cli core install \
        --url="https://$WORDPRESS_DOMAIN" \
        --title="$WORDPRESS_TITLE" \
        --admin_user="$WORDPRESS_ROOT" \
        --admin_password="$(cat /run/secrets/wordpress_root_password)" \
        --admin_email="$WORDPRESS_ROOT_EMAIL" \
        --skip-email \
        --allow-root

    wp-cli user create \
        "$WORDPRESS_USER" \
        "$WORDPRESS_USER_EMAIL" \
        --user_pass="$(cat /run/secrets/wordpress_user_password)" \
        --role="author" \
        --allow-root

    wp-cli option update home "https://$WORDPRESS_DOMAIN" --allow-root
    wp-cli option update siteurl "https://$WORDPRESS_DOMAIN" --allow-root
    
    wp-cli rewrite structure "/%postname%/" --allow-root
    wp-cli rewrite flush --allow-root

    echo "WordPress installation completed!"
fi

chown -R www-data:www-data /var/www/html/wordpress
chmod -R 755 /var/www/html/wordpress

echo "WordPress is ready!"

exec php-fpm83 -F