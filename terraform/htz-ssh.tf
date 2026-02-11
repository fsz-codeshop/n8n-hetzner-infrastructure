# ============================================
# User Access Key (Admin)
# ============================================

# Generate SSH key pair for admin access
resource "tls_private_key" "ssh_key" {
  algorithm = "ED25519"
}

# Save private key locally
resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_openssh
  filename        = "${path.module}/../ssh-keys/admin-key.pem"
  file_permission = "0600"
}

# Save public key locally (optional, for reference)
resource "local_file" "public_key" {
  content  = tls_private_key.ssh_key.public_key_openssh
  filename = "${path.module}/../ssh-keys/admin-key.pub"
}

# Upload public key to Hetzner
resource "hcloud_ssh_key" "admin" {
  name       = "admin-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
  labels     = local.common_labels
}

# ============================================
# Cluster Internal Key (Manager -> Worker/Data)
# ============================================

# Generate internal SSH key pair for cluster communication
resource "tls_private_key" "cluster_key" {
  algorithm = "ED25519"
}

# Save internal private key locally (backup/debug)
resource "local_sensitive_file" "cluster_private_key" {
  content         = tls_private_key.cluster_key.private_key_openssh
  filename        = "${path.module}/../ssh-keys/cluster-internal-key.pem"
  file_permission = "0600"
}
