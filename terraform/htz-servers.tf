# ============================================
# Servers - Using Direct Resources
# ============================================
# NOTE: The official Hetzner module v1.0.0 has a bug with server_type data source
# Using direct resources until module is fixed

# ============================================
# Manager Server (eu-manager-01)
# ============================================
resource "hcloud_server" "eu_manager_01" {
  name        = "eu-manager-01"
  server_type = var.manager_server_type # Dynamic type
  image       = "ubuntu-24.04"
  location    = var.cluster_location

  ssh_keys = [hcloud_ssh_key.admin.id]

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  network {
    network_id = hcloud_network.network_1.id
    ip         = "10.0.1.10"
  }

  firewall_ids = [hcloud_firewall.cluster_firewall.id]

  labels = merge(
    local.common_labels,
    {
      role    = "manager"
      os      = "ubuntu-24.04"
      cluster = var.cluster_name
    }
  )



  user_data = templatefile("${path.module}/cloud-init.tftpl", {
    hostname                   = "eu-manager-01"
    node_role                  = "manager"
    cluster_public_key         = tls_private_key.cluster_key.public_key_openssh
    base64_cluster_private_key = base64encode(tls_private_key.cluster_key.private_key_openssh)
    base64_portainer_stack     = base64encode(file("${path.module}/../services/portainer/docker-compose.yaml"))
    base64_traefik_stack       = base64encode(file("${path.module}/../services/traefik/docker-compose.yaml"))
    base64_node_script         = base64encode(file("${path.module}/../scripts/init-swarm.sh"))
    base64_label_script        = base64encode(file("${path.module}/../scripts/swarm-label-node.sh"))
    cloudflare_token           = local.cloudflare_token
    cloudflare_email           = local.cloudflare_email
    traefik_password           = local.traefik_dashboard_password
    cluster_domain             = var.cluster_domain
    portainer_password         = random_password.portainer_password.result
  })

  lifecycle {
    ignore_changes = [user_data]
  }

  # Protection
  keep_disk          = true
  backups            = false
  delete_protection  = false
  rebuild_protection = false

  depends_on = [
    hcloud_network_subnet.network_1_subnet,
    hcloud_server.eu_data_01 # Wait for data server (GlusterFS) to be ready
  ]
}

# ============================================
# Data Server (eu-data-01)
# ============================================
resource "hcloud_server" "eu_data_01" {
  name        = "eu-data-01"
  server_type = var.data_server_type # Dynamic type
  image       = "ubuntu-24.04"
  location    = var.cluster_location

  ssh_keys = [hcloud_ssh_key.admin.id]

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  network {
    network_id = hcloud_network.network_1.id
    ip         = "10.0.1.20"
  }

  firewall_ids = [hcloud_firewall.cluster_firewall.id]

  labels = merge(
    local.common_labels,
    {
      role    = "data"
      os      = "ubuntu-24.04"
      cluster = var.cluster_name
    }
  )

  user_data = templatefile("${path.module}/cloud-init.tftpl", {
    hostname                   = "eu-data-01"
    node_role                  = "data"
    cluster_public_key         = tls_private_key.cluster_key.public_key_openssh
    base64_cluster_private_key = "" # Not used on data nodes
    base64_portainer_stack     = "" # Not used on data nodes
    base64_traefik_stack       = "" # Not used on data nodes
    base64_node_script         = base64encode(file("${path.module}/../scripts/join-swarm.sh"))
    base64_label_script        = "" # Only Manager labels nodes
    cloudflare_token           = ""
    cloudflare_email           = ""
    traefik_password           = ""
    cluster_domain             = var.cluster_domain
    portainer_password         = ""
  })

  lifecycle {
    ignore_changes = [user_data]
  }

  # Protection
  keep_disk          = true
  backups            = false
  delete_protection  = false
  rebuild_protection = false

  depends_on = [
    hcloud_network_subnet.network_1_subnet
  ]
}

# ============================================
# Volumes
# ============================================

# Data server - PostgreSQL volume
resource "hcloud_volume" "volume_postgres_01" {
  name              = "volume-postgres-01"
  size              = 10
  location          = var.cluster_location
  format            = "ext4"
  delete_protection = true

  lifecycle {
    prevent_destroy = true
  }

  labels = merge(
    local.common_labels,
    {
      purpose = "postgres-data"
      server  = "eu-data-01"
    }
  )
}

resource "hcloud_volume_attachment" "volume_postgres_01_attachment" {
  volume_id = hcloud_volume.volume_postgres_01.id
  server_id = hcloud_server.eu_data_01.id
  automount = true
}

# Data server - Shared data volume
resource "hcloud_volume" "volume_shared_01" {
  name              = "volume-shared-01"
  size              = 10
  location          = var.cluster_location
  format            = "ext4"
  delete_protection = true

  lifecycle {
    prevent_destroy = true
  }

  labels = merge(
    local.common_labels,
    {
      purpose = "shared-data"
      server  = "eu-data-01"
    }
  )
}

resource "hcloud_volume_attachment" "volume_shared_01_attachment" {
  volume_id = hcloud_volume.volume_shared_01.id
  server_id = hcloud_server.eu_data_01.id
  automount = true
}
