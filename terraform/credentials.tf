# ============================================
# Core Credentials & Secrets
# ============================================

resource "random_password" "portainer_password" {
  length  = 32
  special = false
}

resource "infisical_secret" "portainer_admin_password" {
  name         = "PORTAINER_ADMIN_PASSWORD"
  value        = random_password.portainer_password.result
  env_slug     = var.infisical_environment
  workspace_id = var.infisical_project_id
  folder_path  = "/"
}

# Sync the dynamic token created in cf-access.tf to Infisical for the stacks layer
resource "infisical_secret" "cf_access_client_id" {
  name         = "CLOUDFLARE_ACCESS_TERRAFORM_CLIENT_ID"
  value        = cloudflare_zero_trust_access_service_token.terraform_portainer.client_id
  env_slug     = var.infisical_environment
  workspace_id = var.infisical_project_id
  folder_path  = "/CLOUDFLARE"
}

resource "infisical_secret" "cf_access_client_secret" {
  name         = "CLOUDFLARE_ACCESS_TERRAFORM_CLIENT_SECRET"
  value        = cloudflare_zero_trust_access_service_token.terraform_portainer.client_secret
  env_slug     = var.infisical_environment
  workspace_id = var.infisical_project_id
  folder_path  = "/CLOUDFLARE"
}

