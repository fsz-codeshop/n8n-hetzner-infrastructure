# ============================================
# Global Variables
# ============================================

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Project name for resource labeling"
  type        = string
  default     = "n8n-infrastructure"
}

# ============================================
# Cluster Configuration
# ============================================

variable "cluster_name" {
  description = "Cluster identifier"
  type        = string
  default     = "cluster-1"
}

variable "cluster_location" {
  description = "Hetzner Cloud location for the cluster (nbg1, fsn1, hel1, ash, hil)"
  type        = string
  default     = "nbg1"
}

variable "cluster_domain" {
  description = "Main domain name for the cluster (e.g. example.com)"
  type        = string
}

variable "manager_server_type" {
  description = "Server type for the manager node"
  type        = string
  default     = "cx23" # 2 vCPU, 4GB RAM
}

variable "data_server_type" {
  description = "Server type for the data node"
  type        = string
  default     = "cx23" # 2 vCPU, 4GB RAM
}

# ============================================
# Infisical Configuration
# ============================================

variable "infisical_client_id" {
  description = "Infisical Universal Auth Client ID (from Authentication section)"
  type        = string
}

variable "infisical_client_secret" {
  description = "Infisical Machine Identity Client Secret (from TF_VAR_infisical_client_secret)"
  type        = string
  sensitive   = true
}

variable "infisical_project_id" {
  description = "Infisical Project ID"
  type        = string
}

variable "infisical_environment" {
  description = "Infisical Environment (dev, staging, prod)"
  type        = string
  default     = "prod"
}

# ============================================
# Feature Toggles
# ============================================

variable "enable_n8n_mcp" {
  description = "Enable n8n MCP server deployment in Cloudflare"
  type        = bool
  default     = false
}

variable "cloudflare_account_id" {
  description = "Cloudflare Account ID"
  type        = string
}

variable "portainer_endpoint_id" {
  description = "Portainer Endpoint/Environment ID"
  type        = number
  default     = 1
}

# ============================================
# Secrets from Infisical
# ============================================

# Fetch secrets from Infisical folders
data "infisical_secrets" "hetzner" {
  env_slug     = var.infisical_environment
  workspace_id = var.infisical_project_id
  folder_path  = "/HETZNER"
}

data "infisical_secrets" "cloudflare" {
  env_slug     = var.infisical_environment
  workspace_id = var.infisical_project_id
  folder_path  = "/CLOUDFLARE"
}

data "infisical_secrets" "gcp" {
  env_slug     = var.infisical_environment
  workspace_id = var.infisical_project_id
  folder_path  = "/GCP"
}

data "infisical_secrets" "n8n" {
  env_slug     = var.infisical_environment
  workspace_id = var.infisical_project_id
  folder_path  = "/n8n"
}

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

# Secrets as locals
locals {
  # Secrets fetched from Infisical
  hcloud_token                    = data.infisical_secrets.hetzner.secrets["HETZNER_TERRAFORM_API_KEY"].value
  cloudflare_token                = data.infisical_secrets.cloudflare.secrets["CLOUDFLARE_TERRAFORM_API_TOKEN"].value
  cloudflare_email                = data.infisical_secrets.cloudflare.secrets["CLOUDFLARE_EMAIL"].value
  traefik_dashboard_password      = data.infisical_secrets.root.secrets["TRAEFIK_WEB_PASSWORD"].value
  cloudflare_account_id           = var.cloudflare_account_id
  cloudflare_google_client_id     = data.infisical_secrets.cloudflare.secrets["CLOUDFLARE_GOOGLE_CLIENT_ID"].value
  cloudflare_google_client_secret = data.infisical_secrets.cloudflare.secrets["CLOUDFLARE_GOOGLE_CLIENT_SECRET"].value

  # SMTP Credentials from Infisical
  umbler_smtp_user     = data.infisical_secrets.smtp.secrets["UMBLER_SMTP_USER"].value
  umbler_smtp_password = data.infisical_secrets.smtp.secrets["UMBLER_SMTP_PASSWORD"].value

  # Add more secrets here as needed:
  n8n_editor_url = "n8n.${var.cluster_domain}"
  portainer_url  = "portainer.${var.cluster_domain}"
}

