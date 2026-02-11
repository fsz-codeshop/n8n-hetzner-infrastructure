# ============================================
# Infisical Provider Configuration
# ============================================
provider "infisical" {
  auth = {
    universal = {
      client_id     = var.infisical_client_id
      client_secret = var.infisical_client_secret
    }
  }
}

# ============================================
# Hetzner Cloud Provider Configuration
# ============================================
# Uses HCLOUD_TOKEN fetched from Infisical (via variables.tf)
provider "hcloud" {
  token = local.hcloud_token
}

# ============================================
# Cloudflare Provider Configuration
# ============================================
provider "cloudflare" {
  api_token = local.cloudflare_token
}

# ============================================
# Portainer Provider Configuration
# ============================================

provider "portainer" {
  # Temporary direct IP to bypass Cloudflare Access issue with resources
  endpoint        = "https://${hcloud_server.eu_manager_01.ipv4_address}:9443"
  api_user        = "admin"
  api_password    = random_password.portainer_password.result
  skip_ssl_verify = true

  # Custom headers - Disabled for direct access
  # custom_headers = {
  #   "CF-Access-Client-Id"     = cloudflare_zero_trust_access_service_token.terraform_portainer.client_id
  #   "CF-Access-Client-Secret" = cloudflare_zero_trust_access_service_token.terraform_portainer.client_secret
  # }
}


# ============================================
# Data Sources - Validate API Connection
# ============================================

# List available datacenters (validates API connectivity)
data "hcloud_datacenters" "available" {}

# List available server types
data "hcloud_server_types" "available" {}

# List available locations
data "hcloud_locations" "available" {}

# ============================================
# Local Values
# ============================================
locals {
  # Common tags for all resources
  common_labels = {
    project     = var.project_name
    environment = var.environment
    managed_by  = "terraform"
  }
}
