FROM debian:oldstable

ENV ADMIN_NAME=${ADMIN_NAME}
ENV ADMIN_PASSWORD=${ADMIN_PASSWORD}
ENV DATABASE_HOST=${DATABASE_HOST}

# Setting the working directory to /var/www/html where WordPress will be installed
WORKDIR /var/www/html

# Install necessary packages
RUN apt update -y && apt upgrade -y \
    && apt install -y php7.4 php-fpm php-mysql mariadb-client wget curl -y \
    && rm -rf /var/lib/apt/lists/*

# wp-cli plugin to simplify the connection and setup of WordPress with the MariaDB database.
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

RUN chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp

# Change PHP-FPM listen configuration
RUN echo "listen = 0.0.0.0:9000" >> /etc/php/7.4/fpm/pool.d/www.conf

# Create /run/php directory for the socket
RUN mkdir -p /run/php

# Download and extract WordPress
RUN wget https://wordpress.org/latest.tar.gz -O latest.tar.gz \
    && tar -xvzf latest.tar.gz \
    && mv wordpress/* /var/www/html/ \
    && rm -rf wordpress latest.tar.gz

COPY /conf/run.sh /tmp/wp_setup.sh

RUN chmod 777 /tmp/wp_setup.sh

# Start PHP-FPM
CMD ["/tmp/wp_setup.sh"]
