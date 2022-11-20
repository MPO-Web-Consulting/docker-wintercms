FROM php:8.1-fpm

RUN apt-get update && apt-get install -y cron git-core jq unzip vim zip \
	libjpeg-dev libpng-dev libpq-dev libsqlite3-dev libwebp-dev libzip-dev && \
	rm -rf /var/lib/apt/lists/* && \
	docker-php-ext-configure zip --with-zip && \
	docker-php-ext-configure gd --with-jpeg --with-webp && \
	docker-php-ext-install exif gd mysqli opcache pdo_pgsql pdo_mysql zip

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

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

ENV COMPOSER_ALLOW_SUPERUSER=1

RUN curl -sS https://getcomposer.org/installer | php -- --2 --install-dir=/usr/local/bin --filename=composer



COPY config/docker /usr/src/wintercms-config-docker

ENV WINTERCMS_TAG v1.2.1
ENV WINTERCMS_CHECKSUM fb112c51a7c065d08f92b39bad0f82ca053e52e8
ENV WINTERCMS_CORE_BUILD v1.2.1

RUN git clone https://github.com/wintercms/winter.git -b $WINTERCMS_TAG --depth 1 . && \
	# match build dependencies
	echo "Update composer.json: Set explicit build references for winter module dependencies" && \
	sed -i.orig "s/\(\"winter\/\([storm|system|backend|cms]*\)\": \"\(~1.0\)\"\)/\"winter\/\2\": \"<=${WINTERCMS_TAG#v}\"/g" composer.json && \
	egrep -o "['\"]winter\/[storm|system|backend|cms]*['\"]\s*:\s*['\"](.+?)['\"]" composer.json && \
	# download dependencies
	composer install --no-interaction --prefer-dist --no-scripts && \
	composer clearcache && \
	# ensure modules are in sync with the repo after composer install
	git status && git checkout modules/. && \
	# remove git repo
	rm -rf .git && \
	# setup docker env
	echo 'APP_ENV=docker' > .env && \
	mv /usr/src/wintercms-config-docker config/docker && \
	# setup database
	touch storage/database.sqlite && \
	chmod 666 storage/database.sqlite && \
	php artisan winter:up && \
	# add Winter Drivers
	# php artisan plugin:install winter.drivers && \
	# permissions
	chown -R www-data:www-data /var/www/html && \
	find . -type d \( -path './plugins' -or  -path './storage' -or  -path './themes' -or  -path './plugins/*' -or  -path './storage/*' -or  -path './themes/*' \) -exec chmod g+ws {} \;


RUN echo "* * * * * /usr/local/bin/php /var/www/html/artisan schedule:run > /proc/1/fd/1 2>/proc/1/fd/2" > /etc/cron.d/winter-cron && \
	crontab /etc/cron.d/winter-cron

RUN echo 'exec php artisan "$@"' > /usr/local/bin/artisan && \
	echo 'exec php artisan tinker' > /usr/local/bin/tinker && \
	echo '[ $# -eq 0 ] && exec php artisan winter || exec php artisan winter:"$@"' > /usr/local/bin/winter && \
	sed -i '1s;^;#!/bin/bash\n[ "$PWD" != "/var/www/html" ] \&\& echo " - Helper must be run from /var/www/html" \&\& exit 1\n;' /usr/local/bin/artisan /usr/local/bin/tinker /usr/local/bin/winter && \
	chmod +x /usr/local/bin/artisan /usr/local/bin/tinker /usr/local/bin/winter

COPY docker-wn-entrypoint /usr/local/bin/

ENTRYPOINT ["docker-wn-entrypoint"]
CMD ["php-fpm"]
