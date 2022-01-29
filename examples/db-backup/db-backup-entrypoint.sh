#!/bin/bash
set -e

echo "installing driver plugin dependencies..."
composer require winter/wn-drivers-plugin

# original entrypoint script
docker-wn-entrypoint

exec "$@"
