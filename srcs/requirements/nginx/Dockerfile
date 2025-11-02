FROM alpine:3.21

RUN apk add --no-cache \
    nginx \
    openssl \
    envsubst

WORKDIR /run/nginx

RUN addgroup -g 1000 inception \
    && addgroup nginx inception

COPY ./conf/nginx.conf.template /etc/nginx/

COPY ./tools/docker-entrypoint.sh /run/nginx/entrypoint.sh

RUN chmod +x /run/nginx/entrypoint.sh

ENTRYPOINT ["/run/nginx/entrypoint.sh"]