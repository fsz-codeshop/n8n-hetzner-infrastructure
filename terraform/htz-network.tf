# ============================================
# Private Network
# ============================================
resource "hcloud_network" "network_1" {
  name              = "network-1"
  ip_range          = "10.0.0.0/16"
  delete_protection = true

  labels = merge(
    local.common_labels,
    {
      network = "private"
    }
  )
}

# Subnet for the network
resource "hcloud_network_subnet" "network_1_subnet" {
  network_id   = hcloud_network.network_1.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}
