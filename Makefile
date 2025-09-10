# RUN NO DOCKER NGINX
# sudo docker run --name inception-nginx-ssl \
#   -p 80:80 -p 443:443 \
#   -v ~/Inception/srcs/nginx/index.html:/usr/share/nginx/html/index.html:ro \
#   -v ~/Inception/srcs/nginx/default.conf:/etc/nginx/conf.d/default.conf:ro \
#   -v ~/Inception/srcs/nginx/certs:/etc/nginx/certs:ro \
#   -d nginx:stable-alpine