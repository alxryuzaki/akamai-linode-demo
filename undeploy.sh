#!/bin/bash

# Locate prerequisites installations.
TERRAFORM_CMD=$(which terraform)

if [ -z "$TERRAFORM_CMD" ]; then
  echo "Terraform is not installed! Please install it first to continue!"

  exit 1
fi

cd iac

source .env

# Create credentials.
./createCredentials.sh

# Execute the de-provisioning based on the IaC definition files.
$TERRAFORM_CMD init --upgrade
$TERRAFORM_CMD destroy -auto-approve \
                       -var-file=$HOME/.environment.tfvars

cd ..