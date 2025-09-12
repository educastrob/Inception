FROM	debian:buster

# Instala todos os programas
RUN		apt-get update
RUN		apt-get install -y nginx \
                openssl

# Nginx SSL
RUN mkdir /etc/nginx/ssl
RUN openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes \
       -out /etc/nginx/ssl/edcastro.crt \
       -keyout /etc/nginx/ssl/edcastro.key \
       -subj "/C=FR/ST=Paris/L=Paris/O=42 School/OU=edcastro/CN=edcastro/"

COPY ./conf/nginx.conf /etc/nginx/conf.d

# Nginx config
RUN mkdir -p /run/nginx

# A unica porta que o nginx vai ouvir
EXPOSE	443

# Inicia nginx
CMD ["nginx", "-g", "daemon off;"]