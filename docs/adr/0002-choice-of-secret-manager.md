# ADR 0002: Choice of Secret Manager

## Status
Accepted

## Date
2026-01-31

## Context
The infrastructure requires a secure and centralized way to manage secrets (API keys, passwords, certificates) across Terraform provisioning and Docker Swarm deployment. The goal is to avoid hardcoded secrets and prevent "secret leakage" in the repository.

Options considered:
1. **HashiCorp Vault**
2. **Cloudflare Secrets / Variables**
3. **Infisical**

## Decision
We chose **Infisical**.

## Rationale
- **Cloud vs Self-Hosted**: HashiCorp Vault is the industry standard but requires a complex self-hosted setup (overhead) or a expensive paid cloud plan. Infisical offers a very generous free cloud tier.
- **Ecosystem Integration**: While Cloudflare Secrets are great for applications running *on* Cloudflare (Workers/Pages), they are less suited for multi-provider infrastructure (Hetzner + Docker Swarm).
- **Developer Experience**: Infisical provides a modern UI and a robust Terraform Provider that is easy to integrate.
- **API and CLI**: It has a powerful API and CLI that allows for dynamic secret injection (hybrid model) without complex authentication logic.
- **Free Tier**: The cloud-managed free tier is sufficient for the current project scale, reducing operational costs.

## Consequences
- **Positive**: Centralized secret management, integrated with Terraform, low operational cost, enhanced security.
- **Negative**: Adds a dependency on an external SaaS provider (Infisical Cloud).
- **Mitigation**: Infisical is open-source, allowing for a future self-hosted migration if the cloud plan becomes a limitation or for higher data sovereignty.

---

## 📝 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-01-31 | Initial version |
