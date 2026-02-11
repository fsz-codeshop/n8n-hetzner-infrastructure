# Portainer Container Management

This directory contains the Portainer configuration for managing Docker containers and stacks.

## Overview

Portainer is a lightweight management UI that allows you to easily manage your Docker hosts, Docker Swarm clusters, and Docker containers. It provides a web-based interface for container management.

## Components

### Portainer Agent
- Runs on all nodes in the swarm
- Provides communication between Portainer and Docker daemon
- Deployed in global mode across all Linux nodes

### Portainer Server
- Web-based management interface
- Connects to agents for cluster management
- Deployed on manager nodes only

## Features

- **Container Management**: Start, stop, restart, and manage containers
- **Stack Management**: Deploy and manage Docker Compose stacks
- **Swarm Management**: Manage Docker Swarm clusters
- **Volume Management**: Create and manage Docker volumes
- **Network Management**: Configure Docker networks
- **User Management**: Multi-user support with role-based access

## Configuration

### Networks

- `traefik_public`: External network for web access
- `agent_network`: Internal network for agent communication

### Volumes

- `portainer_data`: Persistent storage for Portainer data
  - Location: `/mnt/storage-pool/portainer`

### Access

- **Web Interface**: https://portainer.your-domain.com
- **Authentication**: Set up during first access

## Dependencies

- Docker Swarm mode
- External network: `traefik_public`
- Storage volume: `/mnt/storage-pool/portainer`

## Deployment

```bash
docker stack deploy -c docker-compose.yaml portainer
```
