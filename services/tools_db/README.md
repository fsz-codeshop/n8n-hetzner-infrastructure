# Tools DB Stack

Shared data infrastructure for the cluster, providing high-performance PostgreSQL services.

## 📋 Overview

The `tools_db` stack is responsible for hosting common persistence services. Currently, it provides a tuned PostgreSQL 16 instance used by n8n.

### Component

| Service | Image | Description |
|---------|-------|-------------|
| **PostgreSQL** | `postgres:16-alpine` | High-availability database with custom tuning for n8n workloads. |

## 🛠️ Configuration

### PostgreSQL Tuning
- **Max Connections**: 500
- **Shared Buffers**: 640MB (Tuned for ~2.5GB RAM)

### Environment Variables
These are injected via Portainer from the Infisical vault:
- `POSTGRES_ADMIN_USER`: Superuser for the cluster.
- `POSTGRES_ADMIN_PASSWORD`: Superuser password.
- `POSTGRES_N8N_USER`: Dedicated user for n8n.
- `POSTGRES_N8N_PASSWORD`: Dedicated password for n8n.

### Storage & Persistence
- **Volume**: `postgres_data`
- **Host Path**: `/mnt/postgres-data/pgdata` (Hetzner Dedicated Volume)
- **Initialization**: Custom scripts mounted from `/mnt/storage-pool/tools_db` (GlusterFS).

## 🌐 Networking
- **Network**: `internal_network` (Isolated VPC Overlay)
- **Exposure**: Internal only. No external ports are exposed by default.

## 🚀 Management
Redeploy or update via Portainer:
1. Select `tools_db` stack.
2. Update environment variables if necessary.
3. Pulse "Update the stack".

Or via CLI (after login to manager):
```bash
docker stack deploy -c services/tools_db/docker-compose.yaml tools_db
```

---
## 📝 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-02-11 | Initial version |
