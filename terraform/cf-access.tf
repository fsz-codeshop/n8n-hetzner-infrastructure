# ============================================
# Cloudflare Zero Trust Access (ZTNA)
# ============================================

# Google Identity Provider (Manually created in GCP Console)
resource "cloudflare_zero_trust_access_identity_provider" "google" {
  account_id = var.cloudflare_account_id
  name       = "Google"
  type       = "google"
  config = {
    client_id     = local.cloudflare_google_client_id
    client_secret = local.cloudflare_google_client_secret
  }
}

# Service Token for Terraform to bypass Access/IDP
resource "cloudflare_zero_trust_access_service_token" "terraform_portainer" {
  account_id = var.cloudflare_account_id
  name       = "Terraform Portainer Access"
  duration   = "8760h" # 1 Year
}

# Policy 1: Allow only emails from the cluster domain
resource "cloudflare_zero_trust_access_policy" "allow_domain_emails" {
  account_id = var.cloudflare_account_id
  name       = "Allow ${var.cluster_domain} Domain Emails"
  decision   = "allow"

  include = [
    {
      email_domain = {
        domain = var.cluster_domain
      }
    }
  ]
}

# Policy 2: Allow Terraform Service Account (Non-Identity)
resource "cloudflare_zero_trust_access_policy" "allow_terraform_sa" {
  account_id = var.cloudflare_account_id
  name       = "Allow Terraform Service Account"
  decision   = "non_identity"

  include = [
    {
      service_token = {
        token_id = cloudflare_zero_trust_access_service_token.terraform_portainer.id
      }
    }
  ]
}

# Application to protect the entire domain and subdomains
resource "cloudflare_zero_trust_access_application" "default_protection" {
  account_id                = var.cloudflare_account_id
  name                      = "Default Domain Protection"
  domain                    = "*.${var.cluster_domain}"
  type                      = "self_hosted"
  session_duration          = "24h"
  auto_redirect_to_identity = true
  allowed_idps              = [cloudflare_zero_trust_access_identity_provider.google.id]

  policies = [
    {
      id = cloudflare_zero_trust_access_policy.allow_domain_emails.id
    },
    {
      id = cloudflare_zero_trust_access_policy.allow_terraform_sa.id
    }
  ]
}

# Root Domain protection (Wildcard doesn't always cover the root)
resource "cloudflare_zero_trust_access_application" "root_protection" {
  account_id                = var.cloudflare_account_id
  name                      = "Root Domain Protection"
  domain                    = var.cluster_domain
  type                      = "self_hosted"
  session_duration          = "24h"
  auto_redirect_to_identity = true
  allowed_idps              = [cloudflare_zero_trust_access_identity_provider.google.id]

  policies = [
    {
      id = cloudflare_zero_trust_access_policy.allow_domain_emails.id
    },
    {
      id = cloudflare_zero_trust_access_policy.allow_terraform_sa.id
    }
  ]
}
