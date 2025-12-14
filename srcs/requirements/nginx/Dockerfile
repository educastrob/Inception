FROM debian:oldstable

# Updates the system, installs Nginx and OpenSSL, and cleans up unnecessary packages
RUN apt update -y && apt upgrade -y \
    && apt install nginx openssl -y \
    && apt-get clean

# Generates a self-signed SSL certificate using OpenSSL
	RUN openssl req -batch -x509 -sha256 -nodes -newkey rsa:2048 -days 365 \
	-keyout /etc/ssl/private/edcastro.key \
	-out /etc/ssl/certs/edcastro.crt \
	-subj "/C=Br/ST=SP/L=Sao Paulo/O=42sp/CN=edcastro.42.fr"

# Copies the custom Nginx configuration to the Nginx configuration directory
COPY	conf/nginx.conf /etc/nginx/conf.d

# Adjusts the permissions of the directory where web files are stored
RUN chmod 755 /var/www/html
RUN chown -R www-data:www-data /var/www

# Command to run Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]