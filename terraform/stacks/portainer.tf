# ============================================
# Password Generation
# ============================================

resource "random_password" "postgres_admin_password" {
  length  = 32
  special = false # PostgreSQL can be fussy with certain characters
}

resource "random_password" "postgres_n8n_password" {
  length  = 32
  special = false # PostgreSQL can be fussy with certain characters
}

resource "random_password" "n8n_redis_password" {
  length  = 32
  special = false
}

resource "random_password" "n8n_encryption_key" {
  length  = 32
  special = false
}

# ============================================
# Infisical Secrets (Managed by Terraform)
# ============================================

resource "infisical_secret" "tools_db_postgres_admin_user" {
  name         = "TOOLS_DB_POSTGRES_ADMIN_USER"
  value        = "postgres"
  env_slug     = var.infisical_environment
  workspace_id = var.infisical_project_id
  folder_path  = "/"
}

resource "infisical_secret" "tools_db_postgres_admin_password" {
  name         = "TOOLS_DB_POSTGRES_ADMIN_PASSWORD"
  value        = random_password.postgres_admin_password.result
  env_slug     = var.infisical_environment
  workspace_id = var.infisical_project_id
  folder_path  = "/"
}

resource "infisical_secret" "tools_db_postgres_n8n_user" {
  name         = "TOOLS_DB_POSTGRES_N8N_USER"
  value        = local.n8n_postgres_user
  env_slug     = var.infisical_environment
  workspace_id = var.infisical_project_id
  folder_path  = "/n8n"
}

resource "infisical_secret" "tools_db_postgres_n8n_password" {
  name         = "TOOLS_DB_POSTGRES_N8N_PASSWORD"
  value        = random_password.postgres_n8n_password.result
  env_slug     = var.infisical_environment
  workspace_id = var.infisical_project_id
  folder_path  = "/n8n"
}

resource "infisical_secret" "n8n_redis_password" {
  name         = "N8N_REDIS_PASSWORD"
  value        = random_password.n8n_redis_password.result
  env_slug     = var.infisical_environment
  workspace_id = var.infisical_project_id
  folder_path  = "/n8n"
}

resource "infisical_secret" "n8n_encryption_key" {
  name         = "N8N_ENCRYPTION_KEY"
  value        = random_password.n8n_encryption_key.result
  env_slug     = var.infisical_environment
  workspace_id = var.infisical_project_id
  folder_path  = "/n8n"
}

# ============================================
# Database Initialization Scripts
# ============================================

resource "null_resource" "tools_db_init_script" {
  # Trigger update if the script file changes
  triggers = {
    script_content = file("${path.module}/../../services/tools_db/n8n-init-db.sh")
  }

  connection {
    type        = "ssh"
    user        = "root"
    private_key = data.terraform_remote_state.core.outputs.ssh_key_location != "" ? file(data.terraform_remote_state.core.outputs.ssh_key_location) : "dummy"
    host        = data.terraform_remote_state.core.outputs.manager_ipv4
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /mnt/storage-pool/tools_db",
      "cat > /mnt/storage-pool/tools_db/n8n-init-db.sh <<'EOF'\n${self.triggers.script_content}\nEOF",
      "chmod +x /mnt/storage-pool/tools_db/n8n-init-db.sh"
    ]
  }
}

# ============================================
# Tools Database Stack
# ============================================

resource "portainer_stack" "tools_db" {
  name            = "tools-db"
  endpoint_id     = var.portainer_endpoint_id
  deployment_type = "swarm"
  method          = "file"
  stack_file_path = "${path.module}/../../services/tools_db/docker-compose.yaml"

  env {
    name  = "POSTGRES_ADMIN_USER"
    value = "postgres"
  }
  env {
    name  = "POSTGRES_ADMIN_PASSWORD"
    value = random_password.postgres_admin_password.result
  }
  env {
    name  = "POSTGRES_N8N_USER"
    value = local.n8n_postgres_user
  }
  env {
    name  = "POSTGRES_N8N_PASSWORD"
    value = random_password.postgres_n8n_password.result
  }

  depends_on = [null_resource.tools_db_init_script]
}

# ============================================
# n8n Stack
# ============================================

resource "portainer_stack" "n8n" {
  name            = "n8n"
  endpoint_id     = var.portainer_endpoint_id
  deployment_type = "swarm"
  method          = "file"
  stack_file_path = "${path.module}/../../services/n8n/docker-compose.yaml"

  env {
    name  = "POSTGRES_USER"
    value = local.n8n_postgres_user
  }
  env {
    name  = "POSTGRES_PASSWORD"
    value = random_password.postgres_n8n_password.result
  }
  env {
    name  = "REDIS_PASSWORD"
    value = random_password.n8n_redis_password.result
  }
  env {
    name  = "N8N_ENCRYPTION_KEY"
    value = random_password.n8n_encryption_key.result
  }
  env {
    name  = "N8N_EDITOR_URL"
    value = local.n8n_editor_url
  }

  env {
    name  = "SMTP_SENDER"
    value = local.umbler_smtp_user
  }
  env {
    name  = "SMTP_USER"
    value = local.umbler_smtp_user
  }
  env {
    name  = "SMTP_PASSWORD"
    value = local.umbler_smtp_password
  }
  env {
    name  = "SMTP_HOST"
    value = "smtp.umbler.com"
  }
  env {
    name  = "SMTP_PORT"
    value = "587"
  }

  depends_on = [portainer_stack.tools_db]
}
