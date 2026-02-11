# Troubleshooting Guide - n8n Infrastructure

This document lists the most common issues encountered during the deployment and operation of the n8n cluster, along with their solutions.

---

## 🛠️ Infrastructure & Provisioning

### 1. Terraform Backend (R2) Initialization Failure
**Symptom:** `Error: Backend initialization required` or `403 Forbidden` when running `terraform init`.
- **Cause**: Missing or incorrect Cloudflare R2 credentials in `.env`.
- **Fix**: Run `./scripts/setup-env.sh` again and ensure `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are correct. Verify that `TF_VAR_cloudflare_account_id` matches your Cloudflare Account ID.

### 2. Cloud-Init Bootstrapping Failure
**Symptom:** Server is up but Docker is missing, or Swarm isn't initialized.
- **Diagnostics**: SSH into the node and run `tail -f /var/log/cloud-init-output.log`.
- **Fix**: Check for network errors during `apt-get` or permission issues. If it's a persistent failure, recreate the node: `terraform taint hcloud_server.eu_manager_01 && terraform apply`.

### 3. Worker Node Failing to Join Swarm
**Symptom:** `docker node ls` only shows the manager.
- **Diagnostics**: On the worker, run `journalctl -u docker`. Look for "manager unreachable" or "join token rejected".
- **Fix**: Ensure the Private Network (VLAN) is active and the worker can ping `10.0.1.10`. Verify the join token if joining manually.

---

## 🐋 Docker Swarm & Stacks

### 4. Service Stuck in "Pending" or "Starting"
**Symptom:** `docker service ls` shows 0/1 replicas.
- **Diagnostics**: `docker service ps <service_name> --no-trunc`.
- **Fix**: 
  - **No suitable node**: Check `placement.constraints` (e.g., node needs `role=data`).
  - **Insufficient resources**: Check if the node has enough CPU/RAM left.
  - **Volume mount failed**: Ensure Hetzner Volumes are correctly attached.

### 5. n8n Database Connection Error
**Symptom:** n8n logs show `Connection terminated unexpectedly` or `getaddrinfo ENOTFOUND tools-db_postgres`.
- **Cause**: Services are on different networks or the DB hasn't finished initializing.
- **Fix**: Ensure both services share the `internal_network` overlay. Check `tools_db` stack status in Portainer.

### 6. Secrets Injection Failure
**Symptom:** Container crashes with "missing environment variable" or "permission denied" on secret file.
- **Fix**: Verify in Portainer that the secret is correctly linked to the stack. Ensure the variable names in `docker-compose.yaml` match the keys in Infisical.

---

## 🌐 Networking & Ingress

### 7. Traefik SSL Certificate (LE) Not Generating
**Symptom:** Accessing n8n shows "Your connection is not private".
- **Diagnostics**: `docker service logs traefik_traefik`. Look for "acme: error" or "challenge failed".
- **Fix**: Ensure DNS records in Cloudflare point to the Manager's public IP. Wait for propagation. Check for LE rate limits.

### 8. Portainer / n8n Not Accessible via Domain
**Symptom:** 404 Page Not Found from Traefik.
- **Fix**: Check `traefik.http.routers.n8n.rule` labels in `docker-compose.yaml`. Ensure the domain matches exactly. Verify `traefik.swarm.network` is set to `traefik_public`.

---

## 💾 Storage & Data

### 9. Persistent Data Loss After Restart
**Symptom:** n8n workflows disappear or DB resets.
- **Cause**: Volumes are using local paths instead of dedicated Hetzner Volumes or bind mounts.
- **Fix**: Verify `volumes` section in Compose files. Paths should point to `/mnt/storage-pool` (GlusterFS) or `/mnt/postgres-data`.

### 10. PostgreSQL Permission Denied (PGDATA)
**Symptom:** Postgres container logs show `initdb: error: could not create directory "/var/lib/postgresql/data/pgdata"`.
- **Fix**: On the host, ensure the mount point has correct ownership: `chown -R 999:999 /mnt/postgres-data/pgdata` (999 is the default Postgres UID).

---

## 📝 version History
| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-02-11 | Initial troubleshooting guide |
