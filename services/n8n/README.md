# n8n Workflow Automation

This directory contains the n8n configuration for workflow automation and integration platform.

## Overview

n8n is a fair-code licensed workflow automation tool that helps you automate tasks across different services. It provides a visual workflow editor and supports hundreds of integrations.

## Features

- **Visual Workflow Editor**: Drag-and-drop interface for creating workflows
- **Extensive Integrations**: 200+ nodes for various services and APIs
- **Queue-based Execution**: Scalable execution with Redis queue
- **Database Storage**: PostgreSQL backend for workflow and execution data
- **SMTP Support**: Email notifications and alerts
- **Community Packages**: Support for custom nodes and packages
- **Metrics & Monitoring**: Built-in metrics collection
- **Data Pruning**: Automatic cleanup of old execution data

## Configuration

### Database Configuration

- **Type**: PostgreSQL
- **Database**: `n8n_queue`
- **Host**: `tools_db_postgres`
- **User**: `n8n_user`
- **Password**: Set via `POSTGRES_PASSWORD` environment variable in portainer UI

### Redis Queue

- **Host**: `n8n_redis`
- **Port**: `6379`
- **Database**: `1`
- **Dual Stack**: Enabled

### Networks

- `traefik_public`: External network for web access
- `internal_network`: Internal network for database and Redis communication

### Volumes

- `n8n_data`: Persistent storage for n8n data

### Access

- **Web Interface**: https://n8n.your-domain.com
- **Authentication**: Set up during first access

## Data Retention

- **Execution Data**: Automatically pruned after 14 days (336 hours)
- **Manual Cleanup**: Available through n8n interface

## Dependencies

- Docker Swarm mode
- External networks: `traefik_public`, `internal_network`
- PostgreSQL service (`tools_db`)
- Redis service (`n8n_redis`)
- Environment variables: See configuration section above

## Deployment

```bash
docker stack deploy -c docker-compose.yaml n8n
```
