# Deployment Guide

## Overview

The Full Stack FastAPI Template uses Docker Compose for deployment with Traefik as reverse proxy. Two deployment modes are supported:

1. **Development:** `compose.override.yml` with live reload
2. **Production:** `compose.yml` with optimized builds

## Prerequisites

- **Docker:** 20.10+
- **Docker Compose:** 2.0+
- **Domain:** For production (with DNS configured)
- **Server:** Linux server with Docker installed

## Development Deployment

### Quick Start

```bash
# Clone repository
git clone <repository-url>
cd full-stack-fastapi-template

# Copy environment file
cp .env.example .env

# Edit .env with your values
# At minimum: SECRET_KEY, FIRST_SUPERUSER_PASSWORD, POSTGRES_PASSWORD

# Start all services
docker compose watch
```

### Services

| Service | URL | Purpose |
|---------|-----|---------|
| Frontend | http://localhost:5173 | React dev server |
| Backend | http://localhost:8000 | FastAPI server |
| API Docs | http://localhost:8000/docs | Swagger UI |
| Traefik | http://localhost:8090 | Reverse proxy dashboard |
| Adminer | http://localhost:8080 | Database admin |
| Mailcatcher | http://localhost:1080 | Email testing |

### Development Features

- **Live Reload:** Code changes auto-refresh
- **Volume Mounts:** Source code synced to containers
- **Debug Mode:** Single worker with reload
- **Email Testing:** Mailcatcher captures all emails

## Production Deployment

### Step 1: Prepare Server

```bash
# Install Docker
curl -fsSL https://get.docker.com | sh

# Install Docker Compose (if not included)
sudo apt-get install docker-compose-plugin

# Create project directory
mkdir -p /opt/myapp
cd /opt/myapp
```

### Step 2: Configure Environment

```bash
# Clone or copy project
git clone <repository-url> .

# Create production .env
cat > .env << EOF
# Domain
DOMAIN=myapp.example.com
STACK_NAME=myapp

# Security (GENERATE STRONG VALUES!)
SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_urlsafe(32))")
FIRST_SUPERUSER=admin@example.com
FIRST_SUPERUSER_PASSWORD=$(python3 -c "import secrets; print(secrets.token_urlsafe(16))")

# Database
POSTGRES_USER=postgres
POSTGRES_PASSWORD=$(python3 -c "import secrets; print(secrets.token_urlsafe(32))")
POSTGRES_DB=app

# Email (configure your SMTP)
SMTP_HOST=smtp.example.com
SMTP_USER=your-email@example.com
SMTP_PASSWORD=your-smtp-password
EMAILS_FROM_EMAIL=noreply@example.com

# Docker Images
DOCKER_IMAGE_BACKEND=myapp/backend
DOCKER_IMAGE_FRONTEND=myapp/frontend
TAG=latest
EOF
```

### Step 3: Build Images

```bash
# Build all images
docker compose -f compose.yml build

# Or build individually
docker compose -f compose.yml build backend
docker compose -f compose.yml build frontend
```

### Step 4: Create Docker Network

```bash
docker network create traefik-public
```

### Step 5: Deploy Traefik (Production)

```bash
# Deploy Traefik with Let's Encrypt
docker compose -f compose.traefik.yml up -d

# Verify Traefik is running
docker compose -f compose.traefik.yml ps
```

### Step 6: Deploy Application

```bash
# Start all services
docker compose -f compose.yml up -d

# Check status
docker compose -f compose.yml ps

# View logs
docker compose -f compose.yml logs -f
```

### Step 7: Verify Deployment

```bash
# Check backend health
curl https://api.myapp.example.com/api/v1/utils/health-check/

# Check frontend
curl https://myapp.example.com

# Check API docs
open https://api.myapp.example.com/docs
```

## Docker Compose Files

### compose.yml (Production)

```yaml
services:
  db:
    image: postgres:18
    # ... database configuration

  prestart:
    # Runs migrations before backend starts
    command: bash scripts/prestart.sh

  backend:
    # FastAPI with 4 workers
    command: fastapi run --workers 4 app/main.py

  frontend:
    # Nginx serving built React app
    image: nginx:1
```

### compose.override.yml (Development)

```yaml
services:
  proxy:
    # Traefik with dashboard
    image: traefik:3.6

  backend:
    # Single worker with reload
    command: fastapi run --reload app/main.py
    volumes:
      - ./backend:/app  # Live code sync

  frontend:
    # Vite dev server
    command: bun run dev
    volumes:
      - ./frontend:/app  # Live code sync

  mailcatcher:
    # Email testing
    image: schickling/mailcatcher
```

### compose.traefik.yml (Production Traefik)

```yaml
services:
  traefik:
    image: traefik:3.6
    command:
      - --providers.docker
      - --entrypoints.web.address=:80
      - --entrypoints.websecure.address=:443
      - --certificatesresolvers.le.acme.email=admin@example.com
      - --certificatesresolvers.le.acme.storage=/letsencrypt/acme.json
      - --certificatesresolvers.le.acme.httpchallenge.entrypoint=web
```

## SSL/TLS Configuration

### Automatic HTTPS (Let's Encrypt)

Traefik automatically obtains SSL certificates:

1. **HTTP Challenge:** Traefik responds to Let's Encrypt validation
2. **Certificate Storage:** Stored in `/letsencrypt/acme.json`
3. **Auto-Renewal:** Certificates renew before expiry

### Manual SSL (Optional)

```yaml
# compose.traefik.yml
volumes:
  - ./certs:/certs:ro

command:
  - --entrypoints.websecure.http.tls.certResolver=le
  - --entrypoints.websecure.http.tls.domains[0].main=myapp.example.com
```

## CI/CD Deployment

### GitHub Actions

```yaml
# .github/workflows/deploy-production.yml
name: Deploy Production

on:
  release:
    types: [published]

jobs:
  deploy:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4

      - name: Build images
        run: docker compose -f compose.yml build

      - name: Deploy
        run: |
          docker compose -f compose.yml down
          docker compose -f compose.yml up -d
```

### Self-Hosted Runner

1. Install GitHub Actions runner on server
2. Register with repository
3. Label as `self-hosted`
4. Deployments trigger on push/release

## Database Management

### Backup

```bash
# Backup database
docker compose exec db pg_dump -U postgres app > backup.sql

# Automated backup (cron)
0 2 * * * docker compose exec -T db pg_dump -U postgres app > /backups/app-$(date +\%Y\%m\%d).sql
```

### Restore

```bash
# Restore database
cat backup.sql | docker compose exec -T db psql -U postgres app
```

### Migrations

```bash
# Run migrations
docker compose exec backend alembic upgrade head

# Create new migration
docker compose exec backend alembic revision --autogenerate -m "Description"
```

## Monitoring

### Health Checks

```bash
# Backend health
curl https://api.myapp.example.com/api/v1/utils/health-check/

# Database health
docker compose exec db pg_isready -U postgres
```

### Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f backend
docker compose logs -f frontend

# Last 100 lines
docker compose logs --tail=100 backend
```

### Sentry (Optional)

Configure in `.env`:

```bash
SENTRY_DSN=https://your-sentry-dsn@sentry.io/project-id
```

Errors automatically reported to Sentry.

## Scaling

### Horizontal Scaling

```bash
# Scale backend to 3 instances
docker compose -f compose.yml up -d --scale backend=3

# Traefik automatically load balances
```

### Database Scaling

For high-traffic applications:

1. **Read Replicas:** Configure PostgreSQL replication
2. **Connection Pooling:** Use PgBouncer
3. **Caching:** Add Redis for session/cache

## Troubleshooting

### Container Won't Start

```bash
# Check logs
docker compose logs backend

# Check status
docker compose ps

# Restart service
docker compose restart backend
```

### Database Connection Errors

```bash
# Check database is running
docker compose ps db

# Check database logs
docker compose logs db

# Test connection
docker compose exec backend python -c "from app.core.db import engine; print(engine.connect())"
```

### SSL Certificate Issues

```bash
# Check Traefik logs
docker compose -f compose.traefik.yml logs

# Force certificate renewal
docker compose -f compose.traefik.yml down
docker volume rm traefik-public-acme
docker compose -f compose.traefik.yml up -d
```

### CORS Errors

```bash
# Check CORS configuration
grep CORS .env

# Update BACKEND_CORS_ORIGINS
BACKEND_CORS_ORIGINS="https://myapp.example.com,https://api.myapp.example.com"
```

## Security Checklist

- [ ] Change all default passwords in `.env`
- [ ] Generate strong `SECRET_KEY`
- [ ] Enable HTTPS (automatic with Traefik)
- [ ] Configure firewall (allow 80, 443 only)
- [ ] Regular security updates
- [ ] Database backups automated
- [ ] Monitor error logs (Sentry)
- [ ] Restrict SSH access

## Links

- [Development Guide - Backend](./development-guide-backend.md)
- [Development Guide - Frontend](./development-guide-frontend.md)
- [Architecture](./architecture-backend.md)
