#!/bin/bash -e

# helper script to start a test server

# parse args
while getopts ":he:" opt; do
    case ${opt} in
        h )
            echo "Usage: start_server.bash [PHP_VERSION] [PHP_VARIANT] [WINTER_VERSION]"
            echo "  PHP_VERSION: PHP version to use (default: 7.4)"
            echo "  PHP_VARIANT: PHP variant to use (default: apache)"
            echo "  WINTER_VERSION: Winter CMS version to use (default: 1.1.10)"
            echo
            echo "  -e: add an environment variable to the test container"
            echo "  -h: show this help message"
            echo
            echo "Example: start_server.bash 7.4 apache 1.1.10"
            echo "Example: start_server.bash -e ENV_VAR=value 7.4 apache 1.1.10"
            echo
            echo " some common environment variables:"
            echo "  -e INIT_WINTER=true"
            echo "  -e CMS_ADMIN_PASSWORD=password"
            echo "  -e COMPOSER_UPDATE=true"
            echo "  -e COMPOSER_MERGE_PLUGINS=true"
            echo "  -e COMPOSER_REQUIRE=winter/wn-drivers-plugin"
            exit 0
            ;;
        # add env vars here
        e )
            # variable must have an = sign
            if [[ ! $OPTARG =~ .*=.* ]]; then
                echo "Invalid env argument: '$OPTARG', require arguments in the form 'ENV_VAR=value'" 1>&2
                exit 1
            fi
            # add to array
            ENV_VARS+=("$OPTARG")
            echo "add env: $OPTARG"
            ;;
        \? )
            echo "Invalid Option: -$OPTARG" 1>&2
            exit 1
            ;;
        : )
            echo "Invalid Option: -$OPTARG requires an argument" 1>&2
            exit 1
            ;;
    esac
done

# shift to remove the parsed args
shift $((OPTIND -1))

# input arg or set to a default
# v1.1.10
PHP_VERSION=${1:-7.4}
PHP_VARIANT=${2:-apache}
WINTER_VERSION=${3:-1.1.10}

# v1.2.4
# PHP_VERSION=${1:-8.2}
# PHP_VARIANT=${2:-apache}
# WINTER_VERSION=${3:-1.2.4}

# echo test vars
echo "===TEST VARS==="
echo "PHP_VERSION: $PHP_VERSION"
echo "PHP_VARIANT: $PHP_VARIANT"
echo "WINTER_VERSION: $WINTER_VERSION"
echo "===TEST STARTED==="

# remember the current path
CURRENT_PATH=$(pwd)
# change to the script directory
cd "$(dirname "$0")"

# this makes the source root path available to the script relative to the script path
SOURCE_ROOT=$(pwd)/..

# docker command variables
TEST_CONTAINER_NAME=test-wn-start-server
TEST_CONTAINER_TYPE=$SOURCE_ROOT/images/php-$PHP_VERSION/$PHP_VARIANT/v$WINTER_VERSION
TEST_CONTAINER_DOCKERFILE=Dockerfile

# run docker build or exit with error
echo "---build test container---"
docker build -t $TEST_CONTAINER_NAME -f $TEST_CONTAINER_TYPE/$TEST_CONTAINER_DOCKERFILE $SOURCE_ROOT/templates || (echo "===TEST FAILED (BUILD)===" && exit 1)

# for each env var, add it to the docker run command
for ENV_VAR in "${ENV_VARS[@]}"; do
    TEST_CONTAINER_ENV_VARS+=" -e $ENV_VAR"
done
echo "TEST_CONTAINER_ENV_VARS: $TEST_CONTAINER_ENV_VARS"

# run docker run command to test the container
# exit with error if the container fails
echo "---run test container---"
docker run \
    -it \
    --rm \
    -p 8888:80 \
    -p 8443:443 \
    $TEST_CONTAINER_ENV_VARS \
    $TEST_CONTAINER_NAME /bin/bash || (echo "===TEST FAILED (RUN)===" && exit 1)

echo "===TEST DONE==="

# go back to the current path
cd $CURRENT_PATH

exit 0
