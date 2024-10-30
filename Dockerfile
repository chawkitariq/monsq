FROM composer AS installer

COPY composer.json /app
COPY composer.lock /app

RUN composer install

FROM php:8.2-fpm

RUN apt-get update && apt-get install -y \
		nginx \
		libfreetype-dev \
		libjpeg62-turbo-dev \
		libpng-dev \
	&& docker-php-ext-configure gd --with-freetype --with-jpeg \
	&& docker-php-ext-install -j$(nproc) gd mysqli

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

COPY nginx.conf /etc/nginx/nginx.conf

COPY ./ /var/www/html

COPY --from=installer /app/vendor /var/www/html/vendor

EXPOSE 80

CMD ["sh", "-c", "php-fpm & nginx -g 'daemon off;'"]