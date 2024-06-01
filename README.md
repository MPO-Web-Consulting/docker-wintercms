[![Winter](./docs/images/wintercms.svg)](https://wintercms.com)

# Docker + Winter CMS

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Open in Visual Studio Code](https://img.shields.io/badge/vscode-dev-blue)](https://open.vscode.dev/MPO-Web-Consulting/docker-wintercms)
![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/mpo-web-consulting/docker-wintercms/8.2-apache-v1.2.4.yml)
![GitHub issues](https://img.shields.io/github/issues-raw/MPO-Web-Consulting/docker-wintercms)
[![Maintainability](https://api.codeclimate.com/v1/badges/7e554101c0b2db003d47/maintainability)](https://codeclimate.com/github/MPO-Web-Consulting/docker-wintercms/maintainability)
[![Docker Hub Pulls](https://img.shields.io/docker/pulls/hiltonbanes/wintercms.svg)](https://hub.docker.com/r/hiltonbanes/wintercms/)
[![Winter CMS Build v1.2.4](https://img.shields.io/badge/Winter%20CMS%20Build-v1.2.4-blueviolet.svg)](https://github.com/wintercms/winter)

[![Buy me a tree](https://img.shields.io/badge/Buy%20me%20a%20tree-%F0%9F%8C%B3-green)](https://ecologi.com/mik-p-online?gift-trees)
[![Plant a Tree for Production](https://img.shields.io/badge/dynamic/json?color=brightgreen&label=Plant%20Tree&query=%24.total&url=https%3A%2F%2Fpublic.offset.earth%2Fusers%2Ftreeware%2Ftrees)](https://plant.treeware.earth/MPO-Web-Consulting/docker-wintercms)

The docker images defined in this repository serve as a starting point for [Winter CMS](https://wintercms.com) projects.

Based on [official docker PHP images](https://hub.docker.com/_/php), images include dependencies required by Winter, Composer and install the [latest release](https://wintercms.com/changelog).

- [Supported Tags](#supported-tags)
- [Quick Start](#quick-start)
- [Working with Local Files](#working-with-local-files)
- [Database Support](#database-support)
- [Cron](#cron)
- [Command Line Tasks](#command-line-tasks)
- [App Environment](#app-environment)

## Supported Versions

![PHP7.4](https://img.shields.io/badge/PHP-7.4-teal.svg)
![PHP8.0](https://img.shields.io/badge/PHP-8.0-teal.svg)
![PHP8.1](https://img.shields.io/badge/PHP-8.1-teal.svg)
![PHP8.2](https://img.shields.io/badge/PHP-8.2-teal.svg)
![Apache](https://img.shields.io/badge/Web%20Server-Apache-teal.svg)
![FPM](https://img.shields.io/badge/Web%20Server-FPM-teal.svg)

![WinterCMS](https://img.shields.io/badge/WinterCMS-v1.1.8-blueviolet.svg)
![WinterCMS](https://img.shields.io/badge/WinterCMS-v1.1.9-blueviolet.svg)
![WinterCMS](https://img.shields.io/badge/WinterCMS-v1.1.10-blueviolet.svg)
![WinterCMS](https://img.shields.io/badge/WinterCMS-v1.2.0-blueviolet.svg)
![WinterCMS](https://img.shields.io/badge/WinterCMS-v1.2.1-blueviolet.svg)
![WinterCMS](https://img.shields.io/badge/WinterCMS-v1.2.2-blueviolet.svg)
![WinterCMS](https://img.shields.io/badge/WinterCMS-v1.2.3-blueviolet.svg)
![WinterCMS](https://img.shields.io/badge/WinterCMS-v1.2.4-blueviolet.svg)

### Supported Tags

Tags are combinations of PHP version, web server, and Winter CMS build. The `latest` tag is the most recent release of Winter CMS on the most recent PHP version and with Apache.

The following tags are examples:

| Winter CMS Build | PHP Version | Web Server | Tag |
| ---------------- | ----------- | ---------- | --- |
| 1.2.4 | 8.2 | Apache | `8.2-apache-v1.2.4`, `latest` |
| 1.2.3 | 8.0 | FPM | `8.0-fpm-v1.2.3` |

## Quick Start

To run Winter CMS using Docker, start a container using the latest image, mapping your local port 80 to the container's port 80:

```bash
$ docker run -p 8080:80 --name winter ghcr.io/mpo-web-consulting/wintercms:latest
# `CTRL-C` to stop
$ docker rm winter  # Destroys the container
```

- Visit [http://localhost:8080](http://localhost:8080) using your browser.
- Login to the [backend](http://localhost:8080/backend) with the username `admin`
- The password for `admin` is generated on first load and printed into the container logs.
- Hit `CTRL-C` to stop the container. Running a container in the foreground will send log outputs to your terminal.
- Run the container in the background by passing the `-d` option:

### Kubernetes

There are some example templates in the [kubernetes](./kubernetes) directory. Change the `secrets` and `ingress` files to support your environment requirements. Make sure to install [cert-manager](https://cert-manager.io/) to generate ssl certificates for secure ingress.

```bash
# start winter using kubernetes templates
kubectl apply -f kubernetes/
# to update deployment
kubectl apply -f kubernetes/
# to remove from cluster
kubectl delete -f kubernetes/
```

> __Note__: The kubernetes templates were tested in a Microk8s kubernetes cluster with default (hostpath) storage class. Depending on your cluster this will need to be changed in the `storage` template files.

## Working with Local Files

Using Docker volumes, you can mount local files inside a container.

The container uses the working directory `/var/www/html` for the web server document root. This is where the Winter CMS codebase resides in the container. You can replace files and folders, or introduce new ones with bind-mounted volumes:

```shell
# Developing a plugin
$ git clone git@github.com:wintercms/wn-user-plugin.git
$ cd wn-user-plugin
$ docker run -p 8080:80 --rm \
  -v $(pwd):/var/www/html/plugins/winter/user \
  ghcr.io/mpo-web-consulting/wintercms:latest
```

Save yourself some keyboards strokes, utilize [docker-compose](https://docs.docker.com/compose/overview/) by introducing a `docker-compose.yml` file to your project folder:

```yml
# docker-compose.yml
version: '2.2'
services:
  web:
    image: ghcr.io/mpo-web-consulting/wintercms
    ports:
      - 8080:80
    volumes:
      - $PWD:/var/www/html/plugins/winter/user
```

With the above example saved in working directory, run:

```shell
docker-compose up -d # start services defined in `docker-compose.yml` in the background
docker-compose down # stop and destroy
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
  ghcr.io/mpo-web-consulting/wintercms php artisan winter:up

# Now run with the volume mounted to your host
$ docker run -p 8080:80 --name winter \
 -v $(pwd)/storage/database.sqlite:/var/www/html/storage/database.sqlite \
 ghcr.io/mpo-web-consulting/wintercms
```

#### MySQL / Postgres

Alternatively, you can host the database using another container:

```yml
#docker-compose.yml
version: '2.2'
services:
  web:
    image: ghcr.io/mpo-web-consulting/wintercms:latest
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
docker-compose up -d
docker-compose exec web php artisan winter:up
```

## Cron

You can start a cron process by setting the environment variable `ENABLE_CRON` to `true`:

```shell
docker run -p 8080:80 -e ENABLE_CRON=true ghcr.io/mpo-web-consulting/wintercms:latest
```

Separate the cron process into it's own container:

```yml
#docker-compose.yml
version: '2.2'
services:
  web:
    image: ghcr.io/mpo-web-consulting/wintercms:latest
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
    image: ghcr.io/mpo-web-consulting/wintercms:latest
    init: true
    restart: always
    command: [cron, -f]
    environment:
      - TZ=America/Denver
    volumes_from:
      - web
```

## Self Signed Certificates & Let's Encrypt

The apache images are configured to use self signed certificates by default.

```yaml
version: '2.2'
services:
  web:
    image: ghcr.io/mpo-web-consulting/wintercms:latest
    ports:
      - 8080:80
      - 8443:443 # ssl port
```

To use Let's Encrypt, set the environment variable `INIT_CERTBOT` to `true` and provide the domain and email address for the certificate.

```yaml
version: '2.2'
services:
  web:
    image: ghcr.io/mpo-web-consulting/wintercms:latest
    ports:
      - 80:80 # needs to be exposed for certbot to work
      - 443:443 # needs to be exposed for certbot to work
    environment:
      - INIT_CERTBOT=true
      - LETSENCRYPT_HOST=example.com
      - LETSENCRYPT_EMAIL=user@domain.tld
```

## Command Line Tasks

Run the container in the background and launch an interactive shell (bash) for the container:

```shell
docker run -p 8080:80 --name containername -d ghcr.io/mpo-web-consulting/wintercms:latest
docker exec -it containername bash
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

> __Note__: There are other examples with different environment variables set up in the [examples](./examples) and [test](./test) directories.

## App Environment

By default, `APP_ENV` is set to `docker`.

On image build, a default `.env` is created and [config files](./config/docker) for the `docker` app environment are copied to `/var/www/html/config/docker`. Environment variables can be used to override the included default settings via [`docker run`](https://docs.docker.com/engine/reference/run/#env-environment-variables) or [`docker-compose`](https://docs.docker.com/compose/environment-variables/).

> __Note__: Winter CMS settings stored in a site's database override the config. Active theme, mail configuration, and other settings which are saved in the database will ultimately override configuration values.

### PHP configuration

Recommended settings for opcache and PHP are applied on image build.

Values set in `docker-wn-php.ini` can be overridden by passing one of the supported PHP environment variables defined below.

To customize the PHP configuration further, add or replace `.ini` files found in `/usr/local/etc/php/conf.d/`.

### Environment Variables

Environment variables can be passed to both docker-compose and Winter CMS.

 > Database credentials and other sensitive information should not be committed to the repository. Those required settings should be outlined in __.env.example__
 >
 > Passing environment variables via Docker can be problematic in production. A `phpinfo()` call may leak secrets by outputting environment variables.  Consider mounting a `.env` volume or copying it to the container directly.

### Docker Entrypoint

The following variables trigger actions run by the [entrypoint script](./docker-wn-entrypoint) at runtime.

| Variable | Default | Action |
| -------- | ------- | ------ |
| ENABLE_CRON | false | `true` starts a cron process within the container |
| FWD_REMOTE_IP | false | `true` enables remote IP forwarding from proxy (Apache) |
| INIT_WINTER | false | `true` runs winter up on container start |
| CMS_ADMIN_PASSWORD |  | Sets CMS admin password if INIT_WINTER `true` |
| COMPOSER_MERGE_PLUGINS | false | `true` adds merge plugins into the base composer.json. This should only run once |
| COMPOSER_UPDATE | false | `true` runs composer update in the base laravel directory to update winter and plugins |
| COMPOSER_REQUIRE |  | runs composer require with the provided space seperated list of winter plugins (or any required composer package). This should only run once |
| PHP_DISPLAY_ERRORS | off | Override value for `display_errors` in docker-wn-php.ini |
| PHP_MEMORY_LIMIT | 128M | Override value for `memory_limit` in docker-wn-php.ini |
| PHP_POST_MAX_SIZE | 32M | Override value for `post_max_size` in docker-wn-php.ini |
| PHP_UPLOAD_MAX_FILESIZE | 32M | Override value for `upload_max_filesize` in docker-wn-php.ini |
| VERSION_INFO | false | `true` outputs container current commit, php version, and dependency info on start |
| INIT_CERTBOT | false | `true` runs certbot to generate ssl certificates for the container. This should only run once |
| LETSENCRYPT_HOST |  | Sets the domain for certbot to generate a certificate for |
| LETSENCRYPT_EMAIL |  | Sets the email for certbot to use when generating a certificate |

### Winter CMS app environment config

List of variables used in `config/docker`

| Variable | Default |
| -------- | ------- |
| APP_DEBUG | false |
| APP_KEY | 0123456789ABCDEFGHIJKLMNOPQRSTUV |
| APP_URL | <http://localhost> |
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
| MAIL_FROM_ADDRESS | <no-reply@domain.tld> |
| MAIL_FROM_NAME | Winter CMS |
| MAIL_SMTP_ENCRYPTION | tls |
| MAIL_SMTP_HOST | - |
| MAIL_SMTP_PASSWORD | - |
| MAIL_SMTP_PORT | 587 |
| MAIL_SMTP_USERNAME | - |
| QUEUE_DRIVER | sync |
| SESSION_DRIVER | file |
| FILESYSTEM_S3_KEY | - |
| FILESYSTEM_S3_SECRET | - |
| FILESYSTEM_S3_REGION | - |
| FILESYSTEM_S3_BUCKET | - |
| FILESYSTEM_S3_URL | - |
| FILESYSTEM_S3_ENDPOINT | - |
| CMS_MEDIA_DISK | local |
| CMS_MEDIA_FOLDER | media |
| CMS_MEDIA_PATH | /storage/app/media |
| TZ\** | UTC |

<small>\* When using a container to serve a database, set the host value to the service name defined in your docker-compose.yml</small>

<small>\** Timezone applies to both container and Winter CMS  config</small>

## Development

Create a virtual environment and install the requirements:

```bash
# create virtual environment
python3 -m venv .venv
source venv/bin/activate
pip install -r requirements.txt
```

### Building Images

The images are built using [docker build](https://docs.docker.com/engine/reference/commandline/build/). To build an image, run the following command:

```bash
# build an image
docker build -t ghcr.io/mpo-web-consulting/wintercms:latest -f images/php-8.2/apache/v1.2.4/Dockerfile ./templates
```

### Generating Images and Actions

The images and actions are generated from templates using [Jinja2](https://jinja.palletsprojects.com/en/3.0.x/). The templates are located in the `templates` directory. The images are defined in `images.yaml`.

Use the following commands to generate the images and github actions files:

```bash
# generate Dockerfiles for all images
python3 scripts/generate_images.py templates/Dockerfile.j2 images images.yaml

# generate actions for all images
python3 scripts/generate_actions.py templates/action.yml.j2 images .github/workflows
```

### Adding a new Winter CMS Build

To add a new Winter CMS build, update the `images.yaml` file with the new version and run the generate scripts.

### Testing

The tests are run using [pytest](https://docs.pytest.org/en/6.2.x/). The tests are located in the `tests` directory.

```bash
# run tests
python -m pytest tests
```

## Licence

[![MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Treeware](https://img.shields.io/badge/Treeware-%F0%9F%8C%B3-green.svg)](https://treeware.earth)

This Package is licensed under MIT - Copyright (c) 2016 Aspen Digital - aspendigital.com

This package is [Treeware](https://treeware.earth). If you use it in production, then we ask that you [__buy the world a tree__](https://plant.treeware.earth/MPO-Web-Consulting/docker-wintercms) to thank us for our work. By contributing to the Treeware forest you’ll be creating employment for local families and restoring wildlife habitats.

[![Winter](./docs/images/wintercms.svg)](https://wintercms.com)
