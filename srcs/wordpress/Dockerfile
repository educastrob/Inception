FROM wordpress:php8.2-fpm-alpine

# Instalar extensões extras se precisar
RUN docker-php-ext-install mysqli

# Copiar configs customizadas (se existir)
# COPY wp-config.php /var/www/html/

WORKDIR /var/www/html

EXPOSE 9000