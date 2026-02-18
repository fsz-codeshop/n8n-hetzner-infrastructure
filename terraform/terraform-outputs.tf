# ============================================
# Server Outputs
# ============================================

output "manager_info" {
  description = "Manager server information"
  value = {
    id         = hcloud_server.eu_manager_01.id
    name       = hcloud_server.eu_manager_01.name
    status     = hcloud_server.eu_manager_01.status
    ipv4       = hcloud_server.eu_manager_01.ipv4_address
    ipv6       = hcloud_server.eu_manager_01.ipv6_address
    private_ip = try(tolist(hcloud_server.eu_manager_01.network)[0].ip, null)
    location   = hcloud_server.eu_manager_01.location
    cluster    = var.cluster_name
  }
}

output "data_info" {
  description = "Data server information"
  value = {
    id         = hcloud_server.eu_data_01.id
    name       = hcloud_server.eu_data_01.name
    status     = hcloud_server.eu_data_01.status
    ipv4       = hcloud_server.eu_data_01.ipv4_address
    ipv6       = hcloud_server.eu_data_01.ipv6_address
    private_ip = try(tolist(hcloud_server.eu_data_01.network)[0].ip, null)
    location   = hcloud_server.eu_data_01.location
    cluster    = var.cluster_name
  }
}

# ============================================
# Volume Information
# ============================================
output "volumes_info" {
  description = "Volumes information"
  value = {
    postgres = {
      name         = hcloud_volume.volume_postgres_01.name
      size         = hcloud_volume.volume_postgres_01.size
      linux_device = hcloud_volume.volume_postgres_01.linux_device
      attached_to  = hcloud_server.eu_data_01.name
    }
    shared = {
      name         = hcloud_volume.volume_shared_01.name
      size         = hcloud_volume.volume_shared_01.size
      linux_device = hcloud_volume.volume_shared_01.linux_device
      attached_to  = hcloud_server.eu_data_01.name
    }
  }
}

# ============================================
# SSH Key Information
# ============================================
output "ssh_key_location" {
  description = "Location of the private SSH key"
  value       = abspath("${path.root}/../ssh-keys/admin-key.pem")
}

# ============================================
# Core Integration Outputs (for stacks/)
# ============================================

output "manager_ipv4" {
  value = hcloud_server.eu_manager_01.ipv4_address
}
