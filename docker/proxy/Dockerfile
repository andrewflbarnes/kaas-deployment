FROM nginx:stable-alpine

WORKDIR /etc/nginx

COPY nginx.conf .

EXPOSE 80

ENTRYPOINT ["nginx", "-g", "daemon off;"]
