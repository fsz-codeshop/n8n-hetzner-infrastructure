# ADR-0004: Automated Swarm Stack Deployment via Terraform

## Date
2026-02-11

## Status
Accepted

## Context
Deploying Swarm stacks manually via Portainer UI or SSH is error-prone, hard to version, and creates a "configuration drift" between what is in Git and what is running. We need a way to treat the entire application stack as code (IaC) alongside the infrastructure.

## Alternatives Considered
- **Manual Stack Management**: Using Portainer UI or `docker stack deploy` over SSH.
- **Portainer Git Integration (UI-based)**: Using Portainer's feature to pull from Git, but managed inside Portainer.
- **Terraform Portainer Provider**: Using Terraform to define stacks and environment variables.

## Decision
We decided to use the **Terraform Portainer Provider** to automate the deployment of all core stacks (`traefik`, `tools_db`, `n8n`).

## Rationale
- **Single Source of Truth**: Terraform becomes the orchestrator for both infrastructure (VMs, Networks) and service layer (Stacks, Configs).
- **Environment Parity**: Secrets from Infisical are automatically mapped to Stack environment variables during `terraform apply`.
- **Dependency Management**: We can enforce that databases (`tools_db`) are created before applications (`n8n`) using Terraform's `depends_on`.
- **Auditability**: All stack configurations are versioned in Git and changes are visible in `terraform plan`.

## Consequences
- **Positive**:
    - Consistent and repeatable deployments.
    - Improved security through automated secret injection.
    - Easier scaling and disaster recovery.
- **Negative**:
    - Adds a layer of complexity to Terraform manifests.
    - Requires the Portainer API to be reachable by the Terraform executor.
- **Neutral**:
    - Need to maintain the Portainer provider configuration and API keys.

## Notes
Implemented in `terraform/portainer-stacks.tf`.

---

## 📝 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-02-11 | Initial record of the move to automated stack deployments |
