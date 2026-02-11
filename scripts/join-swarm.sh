#!/bin/bash
set -e

LOG_FILE="/var/log/join-swarm.log"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Starting Swarm Join Service..."

TOKEN_FILE="/mnt/storage-pool/swarm-tokens/swarm-worker-token"

# 1. Wait for Token (from Manager)
log "Waiting for Swarm Token at $TOKEN_FILE..."
RETRIES=0
MAX_RETRIES=60 # 10 minutes (Manager needs to boot, mount gluster, init swarm, write token)

while [ ! -f "$TOKEN_FILE" ] && [ $RETRIES -lt $MAX_RETRIES ]; do
  log "Token not found yet, checking again in 10s ($RETRIES/$MAX_RETRIES)..."
  sleep 10
  RETRIES=$((RETRIES+1))
done

if [ ! -f "$TOKEN_FILE" ]; then
  log "ERROR: Timeout waiting for Swarm Token."
  exit 1
fi

# 2. Join Swarm
log "Attempting to join Swarm..."
MANAGER_IP="10.0.1.10"

# Check if already joined
if docker info | grep -q "Swarm: active"; then
   log "Node is already part of a Swarm."
else
   JOIN_RETRIES=0
   MAX_JOIN_RETRIES=60 # 10 minutes
   joined=false

   while [ $JOIN_RETRIES -lt $MAX_JOIN_RETRIES ]; do
     # Read token inside loop to pick up fresh data if manager rewrote it
     TOKEN=$(cat "$TOKEN_FILE" 2>/dev/null || echo "")
     
     if [ -n "$TOKEN" ] && docker swarm join --token "$TOKEN" "$MANAGER_IP":2377; then
       log "Successfully joined the Swarm!"
       joined=true
       break
     else
       log "Join failed (invalid token or manager not ready). Retrying in 10s ($JOIN_RETRIES/$MAX_JOIN_RETRIES)..."
       sleep 10
       JOIN_RETRIES=$((JOIN_RETRIES+1))
     fi
   done

   if [ "$joined" = false ]; then
     log "ERROR: Failed to join Swarm after $MAX_JOIN_RETRIES attempts."
     exit 1
   fi
fi

log "Swarm Join Service Completed Successfully."
