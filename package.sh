#!/bin/bash

# Locate prerequisites installations.
DOCKER_COMPOSE_CMD=$(which docker-compose)
GIT_CMD=$(which git)

# Check if the Docker Compose is installed.
if [ ! -f "$DOCKER_COMPOSE_CMD" ]; then
  echo "Docker Compose is not installed! Please install it first to continue!"

  exit 1
fi

# Check if the Git is installed.
if [ ! -f "$GIT_CMD" ]; then
  echo "Git is not installed! Please install it first to continue!"

  exit 1
fi

# Versioning.
export DATABASE_BUILD_VERSION=$($GIT_CMD log -n 1 --pretty=format:%H -- database)
export BACKEND_BUILD_VERSION=$($GIT_CMD log -n 1 --pretty=format:%H -- backend)
export FRONTEND_BUILD_VERSION=$($GIT_CMD log -n 1 --pretty=format:%H -- frontend)

# Create environment variables file.
cd iac

echo "DOCKER_REGISTRY_URL=$DOCKER_REGISTRY_URL" > .env
echo "DOCKER_REGISTRY_ID=$DOCKER_REGISTRY_ID" >> .env
echo "DATABASE_BUILD_VERSION=$DATABASE_BUILD_VERSION" >> .env
echo "BACKEND_BUILD_VERSION=$BACKEND_BUILD_VERSION" >> .env
echo "FRONTEND_BUILD_VERSION=$FRONTEND_BUILD_VERSION" >> .env

source .env

# Build Docker images.
$DOCKER_COMPOSE_CMD build

cd ..