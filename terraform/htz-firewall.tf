# ============================================
# Hetzner Cloud Firewall (Public Access Only)
# ============================================
# NOTE: Hetzner Cloud Firewalls do NOT filter traffic on Private Networks.
# Internal communication (Swarm, GlusterFS) via 10.0.1.x is always allowed 
# within the Network and must be managed via OS-level firewall (UFW) if needed.

resource "hcloud_firewall" "cluster_firewall" {
  name = "cluster-public-firewall"

  labels = merge(
    local.common_labels,
    {
      firewall_type = "public"
    }
  )

  # SSH - Admin (auto-detected IP)
  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "22"
    source_ips  = local.admin_ips
    description = "SSH - Admin Access"
  }

  # Portainer API - Direct Access (Admin Only) - Moved to Traefik
  # rule {
  #   direction   = "in"
  #   protocol    = "tcp"
  #   port        = "9443"
  #   source_ips  = local.admin_ips
  #   description = "Portainer API - Direct Access"
  # }

  # PING - ALL
  rule {
    direction = "in"
    protocol  = "icmp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
    description = "ICMP - Monitoring"
  }

  # HTTP/HTTPS - Public Web Traffic (Traefik)
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "80"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
    description = "HTTP - Redirect to HTTPS"
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "443"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
    description = "HTTPS - Public Access"
  }
}
