# Setup Guide for n8n-hub

This guide covers both local development and production deployment of your self-hosted n8n automation hub using Docker, Caddy (for HTTPS), and PostgreSQL.

## Prerequisites

- **Docker & Docker Compose**: [Install Docker](https://docs.docker.com/get-docker/)
- **Domain (production only)**: A domain/subdomain pointing to your server

## Quick Start

1. **Clone and prepare**:
   ```bash
   git clone <your-repo> n8n-hub
   cd n8n-hub
   cp .env.example .env
   ```

2. **Choose your path**:
   - [Local Development](#local-development) - Quick setup for testing
   - [Production Deployment](#production-deployment) - Public, secure setup

---

## Local Development

Perfect for testing workflows and development.

### 1. Configure Environment
Edit `.env` for local development:
```bash
# Core settings - localhost access
N8N_HOST=localhost
N8N_PORT=5678
N8N_PROTOCOL=http
WEBHOOK_URL=http://localhost:5678/
GENERIC_TIMEZONE=Europe/Berlin

# Generate encryption key (CRITICAL!)
N8N_ENCRYPTION_KEY=<run: openssl rand -hex 16>

# Basic Auth (optional for local)
N8N_BASIC_AUTH_ACTIVE=false

# Database
POSTGRES_USER=n8n
POSTGRES_PASSWORD=supersecret
POSTGRES_DB=n8n

# Caddy (not critical for local)
CADDY_EMAIL=dev@localhost
PUBLIC_DOMAIN=n8n.localhost
```

### 2. Start Local Environment
```bash
# Generate encryption key if needed
./scripts/bootstrap.sh

# Start in local mode
docker compose --profile local up -d
```

### 3. Access n8n
- **Direct**: `http://localhost:5678`
- **Via Caddy** (optional): `https://n8n.localhost` (add to `/etc/hosts`: `127.0.0.1 n8n.localhost`)

### 4. Create First Admin
1. Open n8n in browser
2. Create your first admin user account (n8n's built-in setup)
3. Start building workflows!

---

## Production Deployment

Secure, public deployment with automatic HTTPS.

### 1. DNS Setup
Create an A record pointing your domain to your server:
```
automations.yourdomain.com → YOUR_SERVER_IP
```

### 2. Configure Environment
Edit `.env` for production:
```bash
# Core settings - your domain
N8N_HOST=automations.yourdomain.com
N8N_PORT=5678
N8N_PROTOCOL=https
WEBHOOK_URL=https://automations.yourdomain.com/
GENERIC_TIMEZONE=Europe/Berlin

# Generate STRONG encryption key
N8N_ENCRYPTION_KEY=<run: openssl rand -hex 16>

# Basic Auth (REQUIRED for public access)
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=your_admin_user
N8N_BASIC_AUTH_PASSWORD=super_strong_password

# Database - use strong passwords
POSTGRES_USER=n8n
POSTGRES_PASSWORD=very_secure_db_password
POSTGRES_DB=n8n

# Caddy - REQUIRED for Let's Encrypt
CADDY_EMAIL=your-email@yourdomain.com
PUBLIC_DOMAIN=automations.yourdomain.com
```

### 3. Deploy
```bash
# Generate encryption key and validate config
./scripts/bootstrap.sh

# Start in production mode (no exposed n8n port)
docker compose --profile prod up -d
```

### 4. Verify Deployment
1. **HTTPS**: Visit `https://automations.yourdomain.com`
2. **Basic Auth**: Enter your admin credentials
3. **Create Admin**: Set up your first n8n user
4. **Test Webhooks**: Create a simple HTTP webhook workflow

---

## Management Commands

```bash
# View status
docker compose ps

# View logs
docker compose logs -f
docker compose logs n8n
docker compose logs caddy

# Stop services
docker compose --profile <local|prod> down

# Update n8n
docker compose pull
docker compose --profile <local|prod> up -d

# Backup database
docker exec -t n8n-hub-postgres-1 pg_dump -U n8n -d n8n > backups/n8n_$(date +%F).sql
```

## Data Backup

Your data is stored in Docker volumes:
- **n8n workflows**: `n8n_data` volume
- **Database**: `postgres_data` volume
- **Certificates**: `caddy_data` volume

### Backup Script
```bash
# Create backup directory
mkdir -p backups

# Backup database
docker exec -t n8n-hub-postgres-1 pg_dump -U n8n -d n8n > backups/n8n_$(date +%F).sql

# Backup volumes (optional - for full restore)
docker run --rm -v n8n_data:/data -v $(pwd)/backups:/backup alpine tar czf /backup/n8n_data_$(date +%F).tar.gz -C /data .
docker run --rm -v postgres_data:/data -v $(pwd)/backups:/backup alpine tar czf /backup/postgres_data_$(date +%F).tar.gz -C /data .
```

## Common Issues

**Port conflicts**: Stop other services on ports 80, 443, 5678
```bash
sudo lsof -i :80
sudo lsof -i :443
```

**Wrong WEBHOOK_URL**: Webhooks fail if URL doesn't match actual access URL
- Local: `http://localhost:5678/`
- Prod: `https://yourdomain.com/`

**Database connection**: Check postgres is healthy
```bash
docker compose logs postgres
```

**Certificate issues**: Check Caddy logs and email configuration
```bash
docker compose logs caddy
```

## Next Steps

- [Configuration Reference](configuration.md)
- [Workflow Management](workflows.md)
- [Troubleshooting](troubleshooting.md)