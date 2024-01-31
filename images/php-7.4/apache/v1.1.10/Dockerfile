# this dockerfile is generated from a template
# do not modify it directly, modify the template instead
# template: templates/Dockerfile.develop.j2

FROM php:7.4-apache

# Install dependencies
RUN apt-get update && apt-get upgrade --no-install-recommends -y && \
    apt-get install --no-install-recommends -y \
    curl \
    cron \
    zip \
    unzip \
    libjpeg-dev \
    libpng-dev \
    libpq-dev \
    libwebp-dev \
    libsqlite3-dev \
    libonig-dev \
    libssl-dev \
    libxml2-dev \
    libzip-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# install default ssl site conf for apache
RUN apt-get update && \
	apt-get install -y --no-install-recommends \
	ssl-cert \
	certbot \
	python3-certbot-apache \
	at && \
	apt-get clean && rm -rf /var/lib/apt/lists/*

RUN a2enmod ssl; \
	a2ensite default-ssl;

EXPOSE 80
EXPOSE 443
# Install PHP extensions
RUN docker-php-ext-configure zip --with-zip && \
	docker-php-ext-configure gd --with-jpeg --with-webp && \
    docker-php-ext-install \
    exif \
    gd \
    mysqli \
    pdo \
    pdo_sqlite \
    pdo_pgsql \
    pdo_mysql \
    simplexml \
    zip \
    opcache

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Recommended opcache settings - https://secure.php.net/manual/en/opcache.installation.php
RUN { \
	echo 'opcache.memory_consumption=128'; \
	echo 'opcache.interned_strings_buffer=8'; \
	echo 'opcache.max_accelerated_files=4000'; \
	echo 'opcache.revalidate_freq=2'; \
	echo 'opcache.fast_shutdown=1'; \
	echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/docker-wn-opcache.ini

RUN { \
	echo 'log_errors=on'; \
	echo 'display_errors=off'; \
	echo 'upload_max_filesize=32M'; \
	echo 'post_max_size=32M'; \
	echo 'memory_limit=128M'; \
    echo 'expose_php=off'; \
	} > /usr/local/etc/php/conf.d/docker-wn-php.ini

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --2 --install-dir=/usr/local/bin --filename=composer

# install wintercms, set laravel env, and create database
RUN composer create-project --prefer-dist wintercms/winter:1.1.10 . && \
    echo 'APP_ENV=docker' > .env && \
	touch storage/database.sqlite

# get laravel env config files
COPY config/docker config/docker

# install winter
RUN php artisan migrate
# RUN php artisan winter:install

# permissions
RUN chown -R www-data:www-data /var/www/html && \
    find . -type d \( -path './plugins' -or  -path './storage' -or  -path './themes' -or  -path './plugins/*' -or  -path './storage/*' -or  -path './themes/*' \) -exec chmod g+ws {} \;

# Initialize crontab for the Winter CMS scheduler
RUN echo "* * * * * /usr/local/bin/php /var/www/html/artisan schedule:run > /proc/1/fd/1 2>/proc/1/fd/2" > /etc/cron.d/winter-cron && \
	crontab /etc/cron.d/winter-cron

# enable mod rewrite
RUN a2enmod rewrite
# copy fix permissions script
COPY docker-wn-fix-permissions /usr/local/bin/

# entrypoint
COPY docker-wn-entrypoint /usr/local/bin/
ENTRYPOINT ["docker-wn-entrypoint"]

# command
CMD ["apache2-foreground"]