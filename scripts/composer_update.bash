#!/bin/bash -e

# input arg or set to a default
PHP_VERSION=${1:-7.4}
PHP_VARIANT=${2:-apache}
WINTER_VERSION=${3:-1.1.10}

# check if test is run in the right directory
TEST_ROOT=test
SOURCE_ROOT=..

if [ "$(basename $(pwd))" != "$TEST_ROOT" ]; then
    echo "test run in wrong directory"
    exit 1
fi

TEST_CONTAINER_NAME=test-wn-composer-update
TEST_CONTAINER_TYPE=$SOURCE_ROOT/images/php-$PHP_VERSION/$PHP_VARIANT/v$WINTER_VERSION
TEST_CONTAINER_DOCKERFILE=Dockerfile

echo "build test"
docker build -t $TEST_CONTAINER_NAME -f $TEST_CONTAINER_TYPE/$TEST_CONTAINER_DOCKERFILE $SOURCE_ROOT/templates || exit 1

echo "run test container"
docker run \
    -it \
    --rm \
    -p 8888:80 \
    -e COMPOSER_UPDATE=true \
    $TEST_CONTAINER_NAME \
    bash -c "echo 'container test run complete'; exit 0" || exit 1

echo "test done"

exit 0
