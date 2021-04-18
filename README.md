![Winter](./wintercms.svg)

# Docker + Winter CMS

[![Docker Hub Pulls](https://img.shields.io/docker/pulls/hiltonbanes/wintercms.svg)](https://hub.docker.com/r/hiltonbanes/wintercms/) [![Winter CMS Build 472](https://img.shields.io/badge/Winter%20CMS%20Build-472-red.svg)](https://github.com/wintercms/winter)

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

- `build.472-php7.4-apache`, `php7.4-apache`: [php7.4/apache/Dockerfile](https://github.com/mik-p/docker-wintercms/blob/master/php7.4/apache/Dockerfile)
- `build.472-php7.4-fpm`, `php7.4-fpm`: [php7.4/fpm/Dockerfile](https://github.com/mik-p/docker-wintercms/blob/master/php7.4/fpm/Dockerfile)
- `build.472-php7.2-apache`, `php7.2-apache`, `build.472`, `latest`: [php7.2/apache/Dockerfile](https://github.com/mik-p/docker-wintercms/blob/master/php7.2/apache/Dockerfile)
- `build.472-php7.2-fpm`, `php7.2-fpm`: [php7.2/fpm/Dockerfile](https://github.com/mik-p/docker-wintercms/blob/master/php7.2/fpm/Dockerfile)


### Edge Tags

- `edge-build.472-php7.4-apache`, `edge-php7.4-apache`: [php7.4/apache/Dockerfile.edge](https://github.com/mik-p/docker-wintercms/blob/master/php7.4/apache/Dockerfile.edge)
- `edge-build.472-php7.4-fpm`, `edge-php7.4-fpm`: [php7.4/fpm/Dockerfile.edge](https://github.com/mik-p/docker-wintercms/blob/master/php7.4/fpm/Dockerfile.edge)
- `edge-build.472-php7.2-apache`, `edge-php7.2-apache`, `edge-build.472`, `edge`: [php7.2/apache/Dockerfile.edge](https://github.com/mik-p/docker-wintercms/blob/master/php7.2/apache/Dockerfile.edge)
- `edge-build.472-php7.2-fpm`, `edge-php7.2-fpm`: [php7.2/fpm/Dockerfile.edge](https://github.com/mik-p/docker-wintercms/blob/master/php7.2/fpm/Dockerfile.edge)


### Develop Tags

- `develop-php7.4-apache`: [php7.4/apache/Dockerfile.develop](https://github.com/mik-p/docker-wintercms/blob/master/php7.4/apache/Dockerfile.develop)
- `develop-php7.4-fpm`: [php7.4/fpm/Dockerfile.develop](https://github.com/mik-p/docker-wintercms/blob/master/php7.4/fpm/Dockerfile.develop)
- `develop-php7.2-apache`, `develop`: [php7.2/apache/Dockerfile.develop](https://github.com/mik-p/docker-wintercms/blob/master/php7.2/apache/Dockerfile.develop)
- `develop-php7.2-fpm`: [php7.2/fpm/Dockerfile.develop](https://github.com/mik-p/docker-wintercms/blob/master/php7.2/fpm/Dockerfile.develop)

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

---

![Winter](./wintercms.svg)
