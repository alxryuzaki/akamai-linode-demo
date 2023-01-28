#!/bin/bash

# Locate prerequisites installations.
KUBECTL_CMD=$(which kubectl)

# Check if the Kubectl was found.
if [ ! -f "$KUBECTL_CMD" ]; then
  echo "Kubectl is not installed! Please install it first to continue!"

  exit 1
fi

source .env

# Prepare the stack manifest.
cp -f kubernetes.yml kubernetes.yml.tmp
sed -i -e 's|${DOCKER_REGISTRY_URL}|'"$DOCKER_REGISTRY_URL"'|g' kubernetes.yml.tmp
sed -i -e 's|${DOCKER_REGISTRY_ID}|'"$DOCKER_REGISTRY_ID"'|g' kubernetes.yml.tmp
sed -i -e 's|${DATABASE_BUILD_VERSION}|'"$DATABASE_BUILD_VERSION"'|g' kubernetes.yml.tmp
sed -i -e 's|${BACKEND_BUILD_VERSION}|'"$BACKEND_BUILD_VERSION"'|g' kubernetes.yml.tmp
sed -i -e 's|${FRONTEND_BUILD_VERSION}|'"$FRONTEND_BUILD_VERSION"'|g' kubernetes.yml.tmp
cp -f kubernetes.yml.tmp kubernetes.yml

# Apply the stack.
$KUBECTL_CMD apply -f kubernetes.yml

rm -f kubernetes.yml
rm .env
