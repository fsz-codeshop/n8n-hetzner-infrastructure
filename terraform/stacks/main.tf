provider "infisical" {
  auth = {
    universal = {
      client_id     = var.infisical_client_id
      client_secret = var.infisical_client_secret
    }
  }
}

provider "portainer" {
  endpoint = "https://portainer.${var.cluster_domain}"
  api_user = "admin"
  # We use the password from Infisical
  api_password = local.portainer_admin_password

  # Custom headers for Cloudflare Access
  custom_headers = {
    "CF-Access-Client-Id"     = local.cloudflare_access_client_id
    "CF-Access-Client-Secret" = local.cloudflare_access_client_secret
  }
}
