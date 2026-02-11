# Traefik Reverse Proxy

This directory contains the Traefik reverse proxy configuration for the infrastructure stack.

## Overview

Traefik is a modern HTTP reverse proxy and load balancer that makes deploying microservices easy. It automatically discovers and configures routes based on Docker labels.

## Features

- **Automatic SSL/TLS**: Uses Let's Encrypt for automatic certificate generation
- **HTTP to HTTPS Redirect**: Automatically redirects HTTP traffic to HTTPS
- **Docker Swarm Integration**: Native support for Docker Swarm mode
- **Dashboard**: Web-based dashboard for monitoring and configuration
- **Basic Authentication**: Protected dashboard access

## Configuration

### Environment Variables

- `HASHED_PASSWORD`: Hashed password for Traefik dashboard authentication (generated via ```openssl passwd -apr1 <SECRET_PASS>```)

### Networks

- `traefik_public`: External network for public access
- `volume_swarm_shared`: Shared volume for certificates

### Ports

- **80**: HTTP (redirects to HTTPS)
- **443**: HTTPS
- **8080**: Dashboard (internal)

## Using Docker Labels for Ingress Rules

Traefik automatically discovers services and creates ingress rules based on Docker labels. Here's how to configure your services:

### Basic Ingress Configuration

Add these labels to your service's `deploy.labels` section:

```yaml
deploy:
  labels:
    - "traefik.enable=true"
    - "traefik.http.routers.your-service.rule=Host(`your-service.your-domain.com`)"
    - "traefik.http.routers.your-service.entrypoints=websecure"
    - "traefik.http.routers.your-service.tls.certresolver=letsencryptresolver"
    - "traefik.http.services.your-service.loadbalancer.server.port=<SERVICE_PORT>"
```

### Label Breakdown

- `traefik.enable=true`: Enables Traefik for this service
- `traefik.http.routers.your-service.rule=Host(\`your-service.your-domain.com\`)`: Defines the hostname
- `traefik.http.routers.your-service.entrypoints=websecure`: Uses HTTPS endpoint
- `traefik.http.routers.your-service.tls.certresolver=letsencryptresolver`: Uses Let's Encrypt for SSL
- `traefik.http.services.your-service.loadbalancer.server.port=<SERVICE_PORT>`: Service port

### Adding Basic Authentication

To protect your service with basic authentication:

```yaml
deploy:
  labels:
    ...
    - "traefik.http.routers.your-service.middlewares=auth"
    - "traefik.http.middlewares.auth.basicauth.users=admin:$HASHED_PASSWORD"
```

where `HASHED_PASSWORD` is generated via ```openssl passwd -apr1 <SECRET_PASS>```)

### Network Configuration

Ensure your service is connected to the `traefik_public` network:

```yaml
networks:
  - traefik_public

networks:
  traefik_public:
    external: true
```

### Complete Example

```yaml
version: "3.8"
services:
  my-app:
    image: nginx:alpine
    networks:
      - traefik_public
    deploy:
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.my-app.rule=Host(`my-app.your-domain.com`)"
        - "traefik.http.routers.my-app.entrypoints=websecure"
        - "traefik.http.routers.my-app.tls.certresolver=letsencryptresolver"
        - "traefik.http.services.my-app.loadbalancer.server.port=80"

networks:
  traefik_public:
    external: true
```

### Available Entrypoints

- `web`: HTTP (port 80) - automatically redirects to HTTPS
- `websecure`: HTTPS (port 443) - secure endpoint

### Certificate Resolver

- `letsencryptresolver`: Uses Let's Encrypt for automatic SSL certificate generation

### Access

- **Dashboard**: https://traefik.your-domain.com
- **Authentication**: Basic auth with admin user

## Dependencies

- Docker Swarm mode
- External volumes: `volume_swarm_shared`, `volume_swarm_certificates`
- External network: `traefik_public`

## Deployment

```bash
docker stack deploy -c docker-compose.yaml traefik
```
