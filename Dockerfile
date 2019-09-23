FROM nginx:stable-alpine

WORKDIR /etc/nginx

COPY docker/proxy/nginx.conf .

EXPOSE 80

ENTRYPOINT ["nginx", "-g", "daemon off;"]
