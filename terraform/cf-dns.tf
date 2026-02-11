# ============================================
# Cloudflare DNS Configuration
# ============================================

# Fetch Zone ID for the cluster domain
data "cloudflare_zone" "antrox" {
  filter = {
    name = var.cluster_domain
  }
}

# Wildcard A record pointing to Manager IP
resource "cloudflare_dns_record" "wildcard" {
  zone_id = data.cloudflare_zone.antrox.id
  name    = "*"
  content = hcloud_server.eu_manager_01.ipv4_address
  type    = "A"
  proxied = true # Required for Cloudflare Access (ZTNA)
  ttl     = 1    # Automatic
}

# Optional: Root A record
resource "cloudflare_dns_record" "root" {
  zone_id = data.cloudflare_zone.antrox.id
  name    = "@"
  content = hcloud_server.eu_manager_01.ipv4_address
  type    = "A"
  proxied = true # Required for Cloudflare Access (ZTNA)
  ttl     = 1
}
