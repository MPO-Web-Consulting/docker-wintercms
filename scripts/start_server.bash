#!/bin/bash -e

# input arg or set to a default
PHP_VERSION=${1:-7.4}
PHP_VARIANT=${2:-apache}
WINTER_VERSION=${3:-1.1.10}

# check if test is run in the right directory
TEST_ROOT=scripts
SOURCE_ROOT=..

if [ "$(basename $(pwd))" != "$TEST_ROOT" ]; then
    echo "test run in wrong directory"
    exit 1
fi

TEST_CONTAINER_NAME=test-wn-start-server
TEST_CONTAINER_TYPE=$SOURCE_ROOT/images/php-$PHP_VERSION/$PHP_VARIANT/v$WINTER_VERSION
TEST_CONTAINER_DOCKERFILE=Dockerfile

echo "build test"
docker build -t $TEST_CONTAINER_NAME -f $TEST_CONTAINER_TYPE/$TEST_CONTAINER_DOCKERFILE $SOURCE_ROOT/templates || exit 1

echo "run test container"
docker run \
    -it \
    --rm \
    -p 8888:80 \
    -e INIT_WINTER=true \
    -e CMS_ADMIN_PASSWORD=password \
    $TEST_CONTAINER_NAME || exit 1

echo "test done"

exit 0
