# Terraform definition.
terraform {
  # Store the state in the Cloud.
  cloud {
    organization = "fvilarinho"

    workspaces {
      name = "demo"
    }
  }
  # Required providers.
  required_providers {
    linode = {
      source  = "linode/linode"
    }
    akamai = {
      source = "akamai/akamai"
    }
  }
}