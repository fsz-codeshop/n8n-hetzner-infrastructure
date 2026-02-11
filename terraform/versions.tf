terraform {
  required_version = ">= 1.7.0"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
    infisical = {
      source  = "infisical/infisical"
      version = "~> 0.11.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.11"
    }
    portainer = {
      source  = "portainer/portainer"
      version = "~> 1.24"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Backend configuration: Cloudflare R2 (S3-Compatible)
  # Run: source ../.env && terraform init -backend-config="endpoint=https://$TF_VAR_cloudflare_account_id.r2.cloudflarestorage.com"
  backend "s3" {
    bucket = "terraform-state"
    key    = "initial-setup/terraform.tfstate"
    region = "auto"

    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
  }
}
