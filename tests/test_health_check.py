"""
This file contains a test that checks the health of the WinterCMS container.
"""

import time
import docker
import pytest
import logging

# get the logger
LOGGER = logging.getLogger(__name__)

# Create a Docker client
client = docker.from_env()


def is_container_healthy(container):
    """
    Check if a given container is healthy.

    Args:
        container: The container object to check.

    Returns:
        bool: True if the container is healthy, False otherwise.
    """
    response = client.containers.get(container.id).attrs['State']
    return response['Health']['Status'] == 'healthy'


@pytest.mark.parametrize("image", ["ghcr.io/mpo-web-consulting/wintercms:latest"])
def test_container_health(image):
    """
    Test the health of a container running a specified image.

    :param image: The image of the container to test
    :return: None
    """
    # if image CMD is apache then use curl to check health
    # if image CMD is php-fpm then use php-fpm to check health
    if client.images.pull(image).attrs['Config']['Cmd'] == ['apache2-foreground']:
        health_check_command = "curl --fail http://localhost/ || exit 1"
    elif client.images.pull(image).attrs['Config']['Cmd'] == ['php-fpm']:
        health_check_command = "php-fpm -t || exit 1"
    else:
        pytest.fail("Image CMD not supported")

    # Run the container
    LOGGER.info("Running container %s", image)
    container = client.containers.run(image, environment={"INIT_WINTER": "true"}, detach=True, healthcheck={
                                      "test": health_check_command, "interval": 30000000})

    try:
        # Wait for the container to become healthy
        LOGGER.info("Checking container health")
        for _ in range(20):  # Timeout after 20 attempts
            if is_container_healthy(container):
                LOGGER.info("Container is healthy")
                break
            time.sleep(2)
        else:
            pytest.fail("Container did not become healthy")

    finally:
        # Ensure the container is removed
        container.remove(force=True)
