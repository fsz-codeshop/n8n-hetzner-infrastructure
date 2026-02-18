terraform {
  required_version = ">= 1.7.0"

  required_providers {
    portainer = {
      source  = "portainer/portainer"
      version = "~> 1.24"
    }
    infisical = {
      source  = "infisical/infisical"
      version = "~> 0.11.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }

  # Dedicated state for stacks to avoid chicken-and-egg problem with core infra
  # Run: source ../.env && terraform init -backend-config="endpoint=https://$TF_VAR_cloudflare_account_id.r2.cloudflarestorage.com"
  backend "s3" {
    bucket = "terraform-state"
    key    = "initial-setup/stacks/terraform.tfstate"
    region = "auto"

    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
  }
}

# Accessing core infrastructure state
data "terraform_remote_state" "core" {
  backend = "s3"
  config = {
    bucket = "terraform-state"
    key    = "initial-setup/terraform.tfstate"
    region = "auto"
    endpoints = {
      s3 = "https://${var.cloudflare_account_id}.r2.cloudflarestorage.com"
    }

    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
  }
}
