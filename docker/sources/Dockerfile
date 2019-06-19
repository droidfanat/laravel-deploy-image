FROM artjoker/laravel_app:latest

ENV NGINX_VERSION 1.14.2

RUN apk add --no-cache --virtual .persistent-deps nginx

COPY /nginx/etc/fastcgi_params /etc/nginx/fastcgi_params
COPY /nginx/etc/html /usr/share/nginx/html
COPY /nginx/etc/html-errorpages /usr/share/nginx/html-errorpages
COPY /nginx/etc/errorpages.conf /etc/nginx/errorpages.conf
COPY /nginx/etc/nginx.conf /etc/nginx/nginx.conf

COPY /sources/app-entrypoint.sh /app-entrypoint.sh
COPY /deploy /deploy

COPY /app /app
RUN     if [ -L public/storage ]; then \
            unlink public/storage; \
            php artisan storage:link; \
        fi \
    && chmod 777 /app/bootstrap/cache \
    && chmod 750 /deploy/laravel-deploy* \
    && chmod 750 /app/docker/deploy/after-deploy*

WORKDIR /app
ENTRYPOINT []
CMD []
VOLUME /app
EXPOSE 80