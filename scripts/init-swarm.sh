#!/bin/bash
set -e

LOG_FILE="/var/log/init-swarm.log"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Starting Swarm Initialization Service..."

# 1. Mount GlusterFS (Wait for Data Node)
mkdir -p /mnt/storage-pool

log "Waiting for GlusterFS volume on eu-data-01..."
RETRIES=0
MAX_RETRIES=60 # 10 minutes

while [ $RETRIES -lt $MAX_RETRIES ]; do
  if mountpoint -q /mnt/storage-pool; then
     log "GlusterFS already mounted."
     break
  fi
  
  # Use backup-volfile-servers for HA (Phase 2 readiness)
  # If eu-data-01 is down, the client will contact eu-data-02 to fetch the volfile.
  if mount -t glusterfs -o backup-volfile-servers=eu-data-02 eu-data-01:storage-pool /mnt/storage-pool; then
    log "Successfully mounted GlusterFS volume!"
    break
  fi
  
  log "Mount failed, retrying in 10s ($RETRIES/$MAX_RETRIES)..."
  sleep 10
  RETRIES=$((RETRIES+1))
done

if [ $RETRIES -eq $MAX_RETRIES ]; then
  log "ERROR: Failed to mount GlusterFS volume after timeout!"
  exit 1
fi

# Persist in fstab
if ! grep -q "storage-pool" /etc/fstab; then
  echo "eu-data-01:storage-pool /mnt/storage-pool glusterfs defaults,backup-volfile-servers=eu-data-02,_netdev,x-systemd.automount 0 0" >> /etc/fstab
fi

# 2. Initialize Swarm (Manager Only)
if [ "$(hostname)" == "eu-manager-01" ]; then
  log "Loading cluster environment variables..."
  if [ -f /root/.traefik.env ]; then
    set -a
    source /root/.traefik.env
    set +a
  fi

  log "Clearing old swarm tokens from shared storage..."
  rm -rf /mnt/storage-pool/swarm-tokens

  # Check if already in Swarm
  if docker info | grep -q "Swarm: active"; then
     log "Swarm already active."
  else
     log "Initializing Docker Swarm..."
     docker swarm init --advertise-addr 10.0.1.10
  fi
  
  # 3. Export Tokens
  log "Exporting Swarm tokens to shared storage..."
  mkdir -p /mnt/storage-pool/swarm-tokens
  docker swarm join-token worker -q > /mnt/storage-pool/swarm-tokens/swarm-worker-token
  docker swarm join-token manager -q > /mnt/storage-pool/swarm-tokens/swarm-manager-token
  log "Tokens exported successfully."
  
  # 4. Create Networks with MTU 1450 (Hetzner Requirement)
  log "Configuring Networks..."
  
  for net in n8n_network traefik_public agent_network internal_network; do
    if ! docker network inspect $net >/dev/null 2>&1; then
       log "Creating overlay network '$net' (MTU 1450)..."
       docker network create --driver overlay --attachable --opt com.docker.network.driver.mtu=1450 $net
    fi
  done
  
  # 5. Deploy Traefik Stack First (Required for Portainer Init via Domain)
  if ! docker stack ls | grep -q traefik; then
     log "Deploying Traefik Stack..."
     if [ ! -z "${TRAEFIK_WEB_PASSWORD:-}" ]; then
       export HASHED_PASSWORD=$(htpasswd -nb -B admin "$TRAEFIK_WEB_PASSWORD" | cut -d ":" -f 2)
       mkdir -p /mnt/storage-pool/traefik/letsencrypt
       docker stack deploy -c /root/traefik-stack.yml traefik
       log "Traefik stack deployed!"
     else
       log "WARNING: TRAEFIK_WEB_PASSWORD not found."
     fi
  else
     log "Traefik stack already running."
  fi

  # 6. Deploy Portainer Stack
  if ! docker stack ls | grep -q portainer; then
     log "Deploying Portainer Stack..."
     mkdir -p /mnt/storage-pool/portainer
     mkdir -p /mnt/storage-pool/n8n
     mkdir -p /mnt/storage-pool/tools_db
     
     docker stack deploy -c /root/portainer-stack.yml portainer
     log "Portainer stack deployed!"
     
     # Initialize Portainer Admin via internal network (Bypassing Traefik/Cloudflare)
     if [ ! -z "${PORTAINER_PASSWORD:-}" ]; then
       log "Waiting for Portainer API to be ready via internal network..."
       READY=0
       # Use a temporary helper container to reach the Portainer service internally
       for i in {1..60}; do
         if docker run --rm --network traefik_public curlimages/curl:latest -s http://portainer_portainer:9000/api/system/status | grep -q '"InstanceID"'; then
           READY=1
           break
         fi
         sleep 10
       done
       
       if [ $READY -eq 1 ]; then
         log "Initializing Portainer admin user via helper container..."
         docker run --rm --network traefik_public curlimages/curl:latest -s -X POST http://portainer_portainer:9000/api/users/admin/init \
           -H "Content-Type: application/json" \
           -d "{\"Username\":\"admin\",\"Password\":\"$PORTAINER_PASSWORD\"}"
         log "Portainer initialized successfully."
       else
         log "ERROR: Portainer API failed to become ready internally after 10 minutes."
       fi
     fi
  else
     log "Portainer stack already running."
  fi

  # 7. Apply Labels
  log "Applying Node Labels..."
  
  # Label Manager (Self)
  if ! docker node inspect self --format '{{.Spec.Labels.role}}' | grep -q "n8n-server"; then
     log "Labeling Manager node (role=n8n-server)..."
     docker node update --label-add role=n8n-server $(hostname)
  fi
else
  log "Not primary manager, skipping Swarm Init."
fi

log "Swarm Initialization Service Completed Successfully."
