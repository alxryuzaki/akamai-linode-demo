#!/bin/bash

# Locate prerequisites installations.
TERRAFORM_CMD=$(which terraform)

# Check if the Terraform was found.
if [ -z "$TERRAFORM_CMD" ]; then
  echo "Terraform is not installed! Please install it first to continue!"

  exit 1
fi

cd iac

source .env

# Create credentials.
./createCredentials.sh

# Execute the provisioning based on the IaC definition files.
$TERRAFORM_CMD init --upgrade

status=`echo $?`

if [ $status -eq 0 ]; then
  $TERRAFORM_CMD plan -var-file=$HOME/.environment.tfvars

  status=`echo $?`

  if [ $status -eq 0 ]; then
    $TERRAFORM_CMD apply -auto-approve \
                         -var-file=$HOME/.environment.tfvars

    status=`echo $?`
  fi
fi

cd ..

exit $status