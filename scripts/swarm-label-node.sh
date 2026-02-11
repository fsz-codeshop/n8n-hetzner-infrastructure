#!/bin/bash
set -e

NODE_NAME="$1"
NODE_ROLE="$2"
MAX_RETRIES=60
COUNT=0

if [ -z "$NODE_NAME" ] || [ -z "$NODE_ROLE" ]; then
  echo "Usage: $0 <node_name> <node_role>"
  exit 1
fi

echo "Waiting for node '$NODE_NAME' to join the Swarm..."

while [ $COUNT -lt $MAX_RETRIES ]; do
  # Check if node exists in swarm list
  if docker node ls --format '{{.Hostname}}' | grep -q "^${NODE_NAME}$"; then
    echo "Node '$NODE_NAME' found. Checking labels..."
    
    # Check if label is already applied to avoid redundant updates
    CURRENT_LABEL=$(docker node inspect "$NODE_NAME" --format '{{.Spec.Labels.role}}' 2>/dev/null || true)
    
    if [ "$CURRENT_LABEL" == "$NODE_ROLE" ]; then
       echo "Node '$NODE_NAME' is already labeled as '$NODE_ROLE'."
       exit 0
    fi

    echo "Applying label 'role=$NODE_ROLE' to '$NODE_NAME'..."
    if docker node update --label-add role="$NODE_ROLE" "$NODE_NAME"; then
       echo "Successfully labeled '$NODE_NAME'."
       exit 0
    else
       echo "Failed to label node. Retrying..."
    fi
  fi
  
  sleep 10
  COUNT=$((COUNT+1))
  echo "Waiting... ($COUNT/$MAX_RETRIES)"
done

echo "Timeout waiting for node '$NODE_NAME' to join Swarm."
exit 1
