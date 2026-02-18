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
