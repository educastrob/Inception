FROM alpine:3.21

RUN apk add --no-cache \
    php83 \
    php83-fpm \
    php83-mysqli \
    php83-curl \
    php83-xml \
    php83-zlib \
    php83-mbstring \
    php83-opcache \
    php83-phar \
    php83-pecl-redis \
    php83-tokenizer \
    php83-ctype \
    envsubst \
    netcat-openbsd \
    wget

WORKDIR /var/www/html/wordpress

RUN addgroup -g 1001 inception \
    && adduser -D -s /bin/ash -u 1001 -G inception www-data

RUN wget https://wordpress.org/latest.tar.gz \
    && tar -xzf latest.tar.gz --strip-components=1 \
    && rm latest.tar.gz

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O wp-cli \
    && chmod +x wp-cli \
    && mv wp-cli /bin/wp-cli

RUN mkdir -p /run/wordpress

COPY ./conf/www.conf.template /etc/php83/php-fpm.d/
COPY ./tools/docker-entrypoint.sh /run/wordpress/entrypoint.sh

RUN chmod +x /run/wordpress/entrypoint.sh

EXPOSE 9000

CMD ["/run/wordpress/entrypoint.sh"]