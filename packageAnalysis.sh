#!/bin/bash

# Locate prerequisites installations.
SNYK_CMD=$(which snyk)

# Check if the Snyk was found.
if [ ! -f "$SNYK_CMD" ]; then
  echo "Snyk is not installed! Please install it first to continue!"

  exit 1
fi

cd iac

source .env

# Execute packaging analysis for the database image.
$SNYK_CMD container test --app-vulns --severity-threshold=high $DOCKER_REGISTRY_URL/$DOCKER_REGISTRY_ID/demo-database:$DATABASE_BUILD_VERSION --file=../database/Dockerfile

status=$(echo $?)

# Check if there is any vulnerability.
if [ $status -eq 0 ]; then
  # Execute packaging analysis for the backend image.
	$SNYK_CMD container test --app-vulns --severity-threshold=high $DOCKER_REGISTRY_URL/$DOCKER_REGISTRY_ID/demo-backend:$BACKEND_BUILD_VERSION --file=../backend/Dockerfile

	status=`echo $?`

  # Check if there is any vulnerability.
	if [ $status -eq 0 ]; then
    # Execute packaging analysis for the frontend image.
		$SNYK_CMD container test --app-vulns --severity-threshold=high $DOCKER_REGISTRY_URL/$DOCKER_REGISTRY_ID/demo-frontend:$FRONTEND_BUILD_VERSION --file=../frontend/Dockerfile

		status=`echo $?`
	fi
fi

# Return if there is any vulnerability.
exit $status