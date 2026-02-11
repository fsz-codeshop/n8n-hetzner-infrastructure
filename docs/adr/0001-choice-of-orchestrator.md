# ADR 0001: Choice of Container Orchestrator

## Status
Accepted

## Date
2026-01-31

## Context
The project requires a production-ready environment for n8n. The solution needs to support horizontal scaling, high availability, and easy management while keeping operational costs and complexity low.

Options considered:
1. **Kubernetes (k8s)**
2. **Docker Swarm**
3. **Direct service install**

## Decision
We chose **Docker Swarm**.

## Rationale
- **Simplicity**: Swarm is integrated into Docker. It doesnt require additional management plane components (like k8s master nodes) which saves on resource costs (RAM/CPU).
- **Learning Curve**: The team is already familiar with Docker Compose, and Swarm uses almost identical syntax.
- **n8n Compatibility**: n8n's "Queue Mode" naturally fits Swarm's "service scaling" model.
- **Resource Efficiency**: On small to medium clusters (like CX22 nodes), k8s overhead would consume 20-30% of available resources just for the control plane. Swarm overhead is negligible.
- **Native Security**: Swarm's raft-based consensus and automated TLS management for node communication provide sufficient security without complex CNI configurations.

## Consequences
- **Positive**: Rapid deployment, low operational overhead, lower server costs.
- **Negative**: Less ecosystem support compared to k8s (e.g., fewer Helm-like packages), limited advanced networking policies without external tools.
- **Mitigation**: Use Traefik for advanced routing and Hetzner Firewalls for network isolation.

---

## 📝 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-01-31 | Initial version |
