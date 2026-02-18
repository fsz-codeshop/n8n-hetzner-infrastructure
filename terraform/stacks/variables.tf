variable "infisical_client_id" {
  type = string
}
variable "infisical_client_secret" {
  type      = string
  sensitive = true
}
variable "infisical_project_id" {
  type = string
}
variable "infisical_environment" {
  type    = string
  default = "prod"
}
variable "cluster_domain" {
  type = string
}
variable "cloudflare_account_id" {
  type = string
}
variable "portainer_endpoint_id" {
  type    = number
  default = 1
}

# Fetch common secrets
data "infisical_secrets" "smtp" {
  env_slug     = var.infisical_environment
  workspace_id = var.infisical_project_id
  folder_path  = "/SMTP"
}

data "infisical_secrets" "root" {
  env_slug     = var.infisical_environment
  workspace_id = var.infisical_project_id
  folder_path  = "/"
}

data "infisical_secrets" "cloudflare" {
  env_slug     = var.infisical_environment
  workspace_id = var.infisical_project_id
  folder_path  = "/CLOUDFLARE"
}

locals {
  n8n_postgres_user    = "n8n_user"
  umbler_smtp_user     = data.infisical_secrets.smtp.secrets["UMBLER_SMTP_USER"].value
  umbler_smtp_password = data.infisical_secrets.smtp.secrets["UMBLER_SMTP_PASSWORD"].value
  n8n_editor_url       = "n8n.${var.cluster_domain}"

  # Core secrets from Infisical (dynamically synced from core to root folder)
  portainer_admin_password        = data.infisical_secrets.root.secrets["PORTAINER_ADMIN_PASSWORD"].value
  cloudflare_access_client_id     = data.infisical_secrets.cloudflare.secrets["CLOUDFLARE_ACCESS_TERRAFORM_CLIENT_ID"].value
  cloudflare_access_client_secret = data.infisical_secrets.cloudflare.secrets["CLOUDFLARE_ACCESS_TERRAFORM_CLIENT_SECRET"].value
}
