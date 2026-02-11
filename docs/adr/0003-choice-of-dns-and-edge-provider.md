# ADR-0003: Choice of Edge & DNS Management Provider

## Date
2026-01-31

## Status
Accepted

## Context
We need a robust solution for DNS management, SSL/TLS termination, and edge security. The infrastructure is primarily hosted on Hetzner Cloud, but we need an abstraction layer for domain routing that provides high availability and advanced security features.

## Alternatives Considered
- **Maintain Domain Registrar DNS**: Using the default DNS nameservers provided by the domain registrar (e.g., Umbler, GoDaddy).
- **Self-Hosted DNS (Bind/PowerDNS)**: Managing our own DNS servers on the cluster.
- **Provider-Specific DNS (Hetzner DNS)**: Using Hetzner's integrated DNS service.

## Decision
We decided to use **Cloudflare** as the primary DNS and Edge provider for the entire infrastructure.

## Rationale
- **Security First**: Cloudflare provides built-in DDoS protection, Web Application Firewall (WAF), and Bot Management even in its Free Tier.
- **Advanced Features**: Integration with **Cloudflare Access (ZTNA)** for protecting internal tools (like Portainer or n8n admin) without a traditional VPN.
- **Infrastructure Performance**: Global CDN capabilities and optimized routing via Argo (optional) improve latency for users across different regions.
- **Future-Proofing**: Supports advanced functionalities we plan to use, such as Cloudflare Workers for edge logic and R2 for S3-compatible storage (already used for Terraform Remote State).
- **Cost-Efficiency**: The Free Tier is extremely generous and covers almost all current needs, while paid tiers remain highly competitive for professional scaling.
- **Developer Experience**: Robust Terraform provider support, allowing us to manage DNS records as code (IaC) alongside our Hetzner resources.

## Consequences
- **Positive**:
    - Centralized management for DNS, Security, and Edge logic.
    - Simplified SSL management (Universal SSL).
    - Remote state management via R2.
- **Negative**:
    - Adds another external dependency to the stack.
    - Requires changing nameservers at the domain registrar level.
- **Neutral**:
    - Shift in DNS management workflow (must use Cloudflare dashboard or Terraform instead of registrar UI).

## Notes
Currently integrated in Terraform via `cf-dns.tf` and `cf-access.tf`.

---

## 📝 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-01-31 | Initial record of choice for Cloudflare |
