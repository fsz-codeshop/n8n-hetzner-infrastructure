# Changelog

All notable changes to this project will be documented in this file.

## 1.0.0 (2026-02-11)

### 🚀 Initial Production Release

Consolidated project infrastructure and documentation into its first stable version.

### ⚙️ Infrastructure
- **Hetzner Cloud + Terraform**: Full IaC for provisioning cluster nodes and private networking.
- **Docker Swarm**: Native orchestration with automated initialization via Cloud-init.
- **Secret Management**: Native Infisical integration for secure secret injection across all layers.
- **Automated Stacks**: Terraform-managed deployment for Traefik, Portainer, PostgreSQL, and n8n.
- **State Management**: Secure remote state storage using Cloudflare R2.

### 🦐 Services
- **n8n (Queue Mode)**: Primary automation engine with Redis and PostgreSQL backend.
- **Traefik v3**: Edge proxy with automated Let's Encrypt SSL and Swarm service discovery.
- **Portainer 2.33.0**: Management UI with agent-based cluster monitoring.
- **tools_db**: Tuned PostgreSQL 16 persistence layer for application data.

### 📋 Documentation
- **Architecture**: Unified system design, security premises, and resource allocation guides.
- **Troubleshooting**: Comprehensive guide covering the top 10 most common cluster issues.
- **Refined Structure**: Minimalist documentation footprint with focused READMEs per service.

### 🔐 Security
- **Defense in Depth**: Layered protection via Hetzner Firewalls, VPC isolation, and ZTNA.
- **Zero Secret Policy**: No hardcoded secrets in git; everything is versioned in Infisical.
- **Host Hardening**: SSH keys only, root disabled, and automatic security patching.
