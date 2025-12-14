FROM debian:oldstable

RUN apt update \
	&& apt upgrade \
	&& apt install -y nginx openssl curl gettext

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-subj "/C=BR/ST=SP/L=Sao Paulo/O=42SP/CN=edcastro.42.fr" \
	-keyout /etc/ssl/ft_private.key \
	-out /etc/ssl/ft_certificate.crt

COPY ./conf/nginx.conf /etc/nginx/conf.d/

ENTRYPOINT ["nginx"]
CMD ["-g", "daemon off;"]
