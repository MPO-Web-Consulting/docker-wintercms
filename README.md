![Winter](./wintercms.svg)

# Docker + Winter CMS

[![Docker Hub Pulls](https://img.shields.io/docker/pulls/hiltonbanes/wintercms.svg)](https://hub.docker.com/r/hiltonbanes/wintercms/) [![Winter CMS Build v1.1.2](https://img.shields.io/badge/Winter%20CMS%20Build-v1.1.2-red.svg)](https://github.com/wintercms/winter)

The docker images defined in this repository serve as a starting point for [Winter CMS](https://wintercms.com) projects.

Based on [official docker PHP images](https://hub.docker.com/_/php), images include dependencies required by Winter, Composer and install the [latest release](https://wintercms.com/changelog).

- [Supported Tags](#supported-tags)
- [Quick Start](#quick-start)
- [Working with Local Files](#working-with-local-files)
- [Database Support](#database-support)
- [Cron](#cron)
- [Command Line Tasks](#command-line-tasks)
- [App Environment](#app-environment)

---

## Supported Tags

- `build.v1.1.2-php7.4-apache`, `php7.4-apache`: [php7.4/apache/Dockerfile](https://github.com/mik-p/docker-wintercms/blob/master/php7.4/apache/Dockerfile)
- `build.v1.1.2-php7.4-fpm`, `php7.4-fpm`: [php7.4/fpm/Dockerfile](https://github.com/mik-p/docker-wintercms/blob/master/php7.4/fpm/Dockerfile)
- `build.v1.1.2-php7.3-apache`, `php7.3-apache`: [php7.3/apache/Dockerfile](https://github.com/mik-p/docker-wintercms/blob/master/php7.3/apache/Dockerfile)
- `build.v1.1.2-php7.3-fpm`, `php7.3-fpm`: [php7.3/fpm/Dockerfile](https://github.com/mik-p/docker-wintercms/blob/master/php7.3/fpm/Dockerfile)
- `build.v1.1.2-php7.2-apache`, `php7.2-apache`, `build.v1.1.2`, `latest`: [php7.2/apache/Dockerfile](https://github.com/mik-p/docker-wintercms/blob/master/php7.2/apache/Dockerfile)
- `build.v1.1.2-php7.2-fpm`, `php7.2-fpm`: [php7.2/fpm/Dockerfile](https://github.com/mik-p/docker-wintercms/blob/master/php7.2/fpm/Dockerfile)


### Develop Tags

- `develop-php7.4-apache`: [php7.4/apache/Dockerfile.develop](https://github.com/mik-p/docker-wintercms/blob/master/php7.4/apache/Dockerfile.develop)
- `develop-php7.4-fpm`: [php7.4/fpm/Dockerfile.develop](https://github.com/mik-p/docker-wintercms/blob/master/php7.4/fpm/Dockerfile.develop)
- `develop-php7.3-apache`: [php7.3/apache/Dockerfile.develop](https://github.com/mik-p/docker-wintercms/blob/master/php7.3/apache/Dockerfile.develop)
- `develop-php7.3-fpm`: [php7.3/fpm/Dockerfile.develop](https://github.com/mik-p/docker-wintercms/blob/master/php7.3/fpm/Dockerfile.develop)
- `develop-php7.2-apache`, `develop`: [php7.2/apache/Dockerfile.develop](https://github.com/mik-p/docker-wintercms/blob/master/php7.2/apache/Dockerfile.develop)
- `develop-php7.2-fpm`: [php7.2/fpm/Dockerfile.develop](https://github.com/mik-p/docker-wintercms/blob/master/php7.2/fpm/Dockerfile.develop)

## Quick Start

To run Winter CMS using Docker, start a container using the latest image, mapping your local port 80 to the container's port 80:

```shell
$ docker run -p 8080:80 --name winter hiltonbanes/wintercms:latest
# `CTRL-C` to stop
$ docker rm winter  # Destroys the container
```

 - Visit [http://localhost:8080](http://localhost:8080) using your browser.
 - Login to the [backend](http://localhost:8080/backend) with the username `admin` and password `admin`.
 - Hit `CTRL-C` to stop the container. Running a container in the foreground will send log outputs to your terminal.
 - Run the container in the background by passing the `-d` option:


## Working with Local Files

Using Docker volumes, you can mount local files inside a container.

The container uses the working directory `/var/www/html` for the web server document root. This is where the Winter CMS codebase resides in the container. You can replace files and folders, or introduce new ones with bind-mounted volumes:

```shell
# Developing a plugin
$ git clone git@github.com:wintercms/wn-user-plugin.git
$ cd wn-user-plugin
$ docker run -p 8080:80 --rm \
  -v $(pwd):/var/www/html/plugins/winter/user \
  hiltonbanes/wintercms:latest
```

Save yourself some keyboards strokes, utilize [docker-compose](https://docs.docker.com/compose/overview/) by introducing a `docker-compose.yml` file to your project folder:

```yml
# docker-compose.yml
version: '2.2'
services:
  web:
    image: hiltonbanes/wintercms
    ports:
      - 8080:80
    volumes:
      - $PWD:/var/www/html/plugins/winter/user
```
With the above example saved in working directory, run:

```shell
$ docker-compose up -d # start services defined in `docker-compose.yml` in the background
$ docker-compose down # stop and destroy
```


## Database Support

#### SQLite

On build, an SQLite database is created and initialized for the Docker image. With that database, users have immediate access to the backend for testing and developing themes and plugins. However, changes made to the built-in database will be lost once the container is stopped and removed.

When projects require a persistent SQLite database, copy or create a new database to the host which can be used as a bind mount:

```shell
# Create and provision a new SQLite database:
$ touch storage/database.sqlite
$ docker run --rm \
  -v $(pwd)/storage/database.sqlite:/var/www/html/storage/database.sqlite \
  hiltonbanes/wintercms php artisan winter:up

# Now run with the volume mounted to your host
$ docker run -p 8080:80 --name winter \
 -v $(pwd)/storage/database.sqlite:/var/www/html/storage/database.sqlite \
 hiltonbanes/wintercms
```

#### MySQL / Postgres

Alternatively, you can host the database using another container:

```yml
#docker-compose.yml
version: '2.2'
services:
  web:
    image: hiltonbanes/wintercms:latest
    ports:
      - 8080:80
    environment:
      - DB_TYPE=mysql
      - DB_HOST=mariadb #DB_HOST should match the service name of the database container
      - DB_DATABASE=wintercms
      - DB_USERNAME=root
      - DB_PASSWORD=root

  mariadb:
    image: mariadb:10.4
    command: --default-authentication-plugin=mysql_native_password
    ports:
      - 3306:3306
    environment:
      - MYSQL_ROOT_PASSWORD=root
      - MYSQL_DATABASE=wintercms
```
Provision a new database with `winter:up`:

```ssh
$ docker-compose up -d
$ docker-compose exec web php artisan winter:up
```

## Cron

You can start a cron process by setting the environment variable `ENABLE_CRON` to `true`:

```shell
$ docker run -p 8080:80 -e ENABLE_CRON=true hiltonbanes/wintercms:latest
```

Separate the cron process into it's own container:

```yml
#docker-compose.yml
version: '2.2'
services:
  web:
    image: hiltonbanes/wintercms:latest
    init: true
    restart: always
    ports:
      - 8080:80
    environment:
      - TZ=America/Denver
    volumes:
      - ./.env:/var/www/html/.env
      - ./plugins:/var/www/html/plugins
      - ./storage/app:/var/www/html/storage/app
      - ./storage/logs:/var/www/html/storage/logs
      - ./storage/database.sqlite:/var/www/html/storage/database.sqlite
      - ./themes:/var/www/html/themes

  cron:
    image: hiltonbanes/wintercms:latest
    init: true
    restart: always
    command: [cron, -f]
    environment:
      - TZ=America/Denver
    volumes_from:
      - web
```

## Self Signed Certificates

Sometimes encyption is useful for testing. Self signed certs can be added by extending the image in another dockerfile:

```dockerfile
# Dockerfile for apache with self signed certificates

FROM hiltonbanes/wintercms:develop-php7.4-apache

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ssl-cert && \
    rm -rf /var/lib/apt/lists/*

RUN a2enmod ssl; \
    a2ensite default-ssl;

EXPOSE 443

CMD ["apache2-foreground"]

```

From a docker compose file build with:

```yml
version: '2.2'
services:
  web:
    build: <Dockerfile> # Dockerfile should match file defined in example above
    ports:
      - 8080:80
      - 8443:443
    environment:
      - DB_TYPE=mysql
      - DB_HOST=mariadb #DB_HOST should match the service name of the database container
      - DB_DATABASE=wintercms
      - DB_USERNAME=root
      - DB_PASSWORD=root
    volumes:
      # ssl certs could also be volume mapped from elsewhere
      # - .certs/cert.pem:/etc/ssl/certs/ssl-cert-snakeoil.pem:ro
      # - .certs/key.key:/etc/ssl/private/ssl-cert-snakeoil.key:ro

  mariadb:
    image: mariadb:10.4
    command: --default-authentication-plugin=mysql_native_password
    environment:
      - MYSQL_DATABASE=wintercms
      - MYSQL_ROOT_PASSWORD=root
```

## Command Line Tasks

Run the container in the background and launch an interactive shell (bash) for the container:


```shell
$ docker run -p 8080:80 --name containername -d hiltonbanes/wintercms:latest
$ docker exec -it containername bash
```

Commands can also be run directly, without opening a shell:

```shell
# artisan
$ docker exec containername php artisan env

# composer
$ docker exec containername composer info
```

A few helper scripts have been added to the image:

```shell
# `winter` invokes `php artisan winter:"$@"`
$ docker exec containername winter up

# `artisan` invokes `php artisan "$@"`
$ docker exec containername artisan plugin:install winter.user

# `tinker` invokes `php artisan tinker`. Requires `-it` for an interactive shell
$ docker exec -it containername tinker
```


## App Environment

By default, `APP_ENV` is set to `docker`.

On image build, a default `.env` is created and [config files](./config/docker) for the `docker` app environment are copied to `/var/www/html/config/docker`. Environment variables can be used to override the included default settings via [`docker run`](https://docs.docker.com/engine/reference/run/#env-environment-variables) or [`docker-compose`](https://docs.docker.com/compose/environment-variables/).

> __Note__: Winter CMS settings stored in a site's database override the config. Active theme, mail configuration, and other settings which are saved in the database will ultimately override configuration values.

#### PHP configuration

Recommended settings for opcache and PHP are applied on image build.

Values set in `docker-wn-php.ini` can be overridden by passing one of the supported PHP environment variables defined below.

To customize the PHP configuration further, add or replace `.ini` files found in `/usr/local/etc/php/conf.d/`.

### Environment Variables


Environment variables can be passed to both docker-compose and Winter CMS.

 > Database credentials and other sensitive information should not be committed to the repository. Those required settings should be outlined in __.env.example__

 > Passing environment variables via Docker can be problematic in production. A `phpinfo()` call may leak secrets by outputting environment variables.  Consider mounting a `.env` volume or copying it to the container directly.


#### Docker Entrypoint

The following variables trigger actions run by the [entrypoint script](./docker-wn-entrypoint) at runtime.

| Variable | Default | Action |
| -------- | ------- | ------ |
| ENABLE_CRON | false | `true` starts a cron process within the container |
| FWD_REMOTE_IP | false | `true` enables remote IP forwarding from proxy (Apache) |
| GIT_CHECKOUT |  | Checkout branch, tag, commit within the container. Runs `git checkout $GIT_CHECKOUT` |
| GIT_MERGE_PR |  | Pass GitHub pull request number to merge PR within the container for testing |
| INIT_WINTER | false | `true` runs winter up on container start |
| INIT_PLUGINS | false | `true` runs composer install in plugins folders where no 'vendor' folder exists. `force` runs composer install regardless. Helpful when using git submodules for plugins. |
| PHP_DISPLAY_ERRORS | off | Override value for `display_errors` in docker-wn-php.ini |
| PHP_MEMORY_LIMIT | 128M | Override value for `memory_limit` in docker-wn-php.ini |
| PHP_POST_MAX_SIZE | 32M | Override value for `post_max_size` in docker-wn-php.ini |
| PHP_UPLOAD_MAX_FILESIZE | 32M | Override value for `upload_max_filesize` in docker-wn-php.ini |
| UNIT_TEST |  | `true` runs all Winter CMS unit tests. Pass test filename to run a specific test. |
| VERSION_INFO | false | `true` outputs container current commit, php version, and dependency info on start |
| XDEBUG_ENABLE | false | `true` enables the Xdebug PHP extension |
| XDEBUG_REMOTE_HOST | host.docker.internal | Override value for `xdebug.remote_host` in docker-xdebug-php.ini |

#### Winter CMS app environment config

List of variables used in `config/docker`

| Variable | Default |
| -------- | ------- |
| APP_DEBUG | false |
| APP_KEY | 0123456789ABCDEFGHIJKLMNOPQRSTUV |
| APP_URL | http://localhost |
| APP_LOCALE | en |
| CACHE_STORE | file |
| CMS_ACTIVE_THEME | demo |
| CMS_BACKEND_FORCE_SECURE | false |
| CMS_BACKEND_SKIN | Backend\Skins\Standard |
| CMS_BACKEND_URI | backend |
| CMS_DATABASE_TEMPLATES | false |
| CMS_DISABLE_CORE_UPDATES | true |
| CMS_EDGE_UPDATES | false  (true in `edge` images) |
| CMS_LINK_POLICY | detect |
| DB_DATABASE | - |
| DB_HOST | mysql* |
| DB_PASSWORD | - |
| DB_PORT | - |
| DB_REDIS_HOST | redis* |
| DB_REDIS_PASSWORD | null |
| DB_REDIS_PORT | 6379 |
| DB_SQLITE_PATH | storage/database.sqlite |
| DB_TYPE | sqlite |
| DB_USERNAME | - |
| MAIL_DRIVER | log |
| MAIL_FROM_ADDRESS | no-reply@domain.tld |
| MAIL_FROM_NAME | Winter CMS |
| MAIL_SMTP_ENCRYPTION | tls |
| MAIL_SMTP_HOST | - |
| MAIL_SMTP_PASSWORD | - |
| MAIL_SMTP_PORT | 587 |
| MAIL_SMTP_USERNAME | - |
| QUEUE_DRIVER | sync |
| SESSION_DRIVER | file |
| TZ\** | UTC |

<small>\* When using a container to serve a database, set the host value to the service name defined in your docker-compose.yml</small>

<small>\** Timezone applies to both container and Winter CMS  config</small>

## Nice to Have To Do's

- Replace Travis build with Docker build Github App
- Add plugin list as Environment variable to install plugins on container start
- Fix permission handling for local files
- Kubernetes templates
- Helm Chart

---

![Winter](./wintercms.svg)
