FROM php:8.3.16-fpm-alpine3.20

WORKDIR /var/www
COPY ./my_project .

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN apk update && apk upgrade && apk --no-cache add 7zip nginx icu-dev icu-libs bash \
    && apk --no-cache add --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing/ dart-sass \
    && apk add --no-cache dart-sass \
    && composer require symfonycasts/sass-bundle \
    && docker-php-ext-install intl \
    && composer install --no-interaction --optimize-autoloader\
    && php bin/console assets:install\
    && php bin/console asset-map:compile\
    && chown -R www-data:www-data /var/www

COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/default.conf /etc/nginx/sites-available/default
COPY config/default.conf /etc/nginx/conf.d/default.conf

COPY config/php.ini /usr/local/etc/php/php.ini

CMD ["sh", "-c", "nginx -g 'daemon off;' & php-fpm"]


EXPOSE 80