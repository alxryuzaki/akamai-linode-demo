#!/bin/bash

# Locate prerequisites installations.
DOCKER_COMPOSE_CMD=$(which docker-compose)

# Check if the Docker Compose is installed.
if [ ! -f "$DOCKER_COMPOSE_CMD" ]; then
  echo "Docker Compose is not installed! Please install it first to continue!"

  exit 1
fi

# Stop the containers.
cd iac

source .env

$DOCKER_COMPOSE_CMD down

cd ..