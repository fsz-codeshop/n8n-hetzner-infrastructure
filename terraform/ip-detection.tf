# ============================================
# Current Public IP Detection
# ============================================
# Automatically detect the public IP addresses of the machine
# running Terraform for use in firewall rules

# Get current public IPv4 address
data "http" "current_ipv4" {
  url = "https://api.ipify.org"

  request_headers = {
    Accept = "text/plain"
  }
}

# Get current public IPv6 address (if available)
data "http" "current_ipv6" {
  url = "https://api64.ipify.org"

  request_headers = {
    Accept = "text/plain"
  }
}

# ============================================
# Local values for IP addresses
# ============================================
locals {
  # Trim whitespace and format as CIDR
  current_ipv4 = "${trimspace(data.http.current_ipv4.response_body)}/32"
  current_ipv6 = can(regex("^[0-9a-fA-F:]+$", trimspace(data.http.current_ipv6.response_body))) ? "${trimspace(data.http.current_ipv6.response_body)}/128" : null

  # Combine IPv4 and IPv6 for firewall rules
  admin_ips = compact([
    local.current_ipv4,
    local.current_ipv6
  ])
}

# ============================================
# Outputs - Current IP Detection
# ============================================

output "detected_ipv4" {
  description = "Your current public IPv4 address"
  value       = local.current_ipv4
}

output "detected_ipv6" {
  description = "Your current public IPv6 address (if available)"
  value       = local.current_ipv6 != null ? local.current_ipv6 : "IPv6 not detected"
}

output "admin_ips_whitelist" {
  description = "Admin IPs automatically whitelisted in firewall"
  value       = local.admin_ips
}
