# Fider Setup Guide

Fider is an open-source customer feedback platform that allows you to collect and prioritize feature requests from your users.

## Prerequisites

- crowd-wisdom-infra deployed and running
- DNS A record for your Fider subdomain (e.g., `feedback.crowd-wisdom.com`)

## Configuration

### 1. Required Environment Variables

Add the following to your `.env` file:

```bash
# Fider Host (required - your subdomain)
FIDER_HOST=feedback.crowd-wisdom.com
FIDER_BASE_URL=https://feedback.crowd-wisdom.com

# Database credentials
FIDER_DB_USER=fider
FIDER_DB_PASSWORD=your_strong_password
FIDER_DB_NAME=fider

# JWT Secret (required - generate a random 64-character string)
FIDER_JWT_SECRET=your_jwt_secret
```

### 2. Generate JWT Secret

```bash
# Linux/macOS
openssl rand -hex 32

# Windows PowerShell
-join ((48..57) + (65..90) + (97..122) | Get-Random -Count 64 | ForEach-Object {[char]$_})
```

### 3. Email Configuration (Optional)

For email notifications (password resets, notifications):

```bash
FIDER_EMAIL_NOREPLY=noreply@crowd-wisdom.com
FIDER_EMAIL_SMTP_HOST=smtp.your-provider.com
FIDER_EMAIL_SMTP_PORT=587
FIDER_EMAIL_SMTP_USERNAME=your_smtp_user
FIDER_EMAIL_SMTP_PASSWORD=your_smtp_password
FIDER_EMAIL_SMTP_ENABLE_STARTTLS=true
```

## Deployment

### Start Services

```bash
# Start all services including Fider
docker compose --profile prod up -d

# Or restart just Fider
docker compose --profile prod restart fider
```

### Check Logs

```bash
# View Fider logs
docker compose logs -f fider

# Check health status
docker compose ps
```

### Verify Health

```bash
curl https://feedback.crowd-wisdom.com/api/health
```

## Initial Setup

1. Navigate to `https://feedback.crowd-wisdom.com`
2. Complete the initial setup wizard:
   - Set your site name
   - Create admin account
   - Configure your first feedback board
3. Share the link with your users

## Database Management

Fider uses a separate database within the shared PostgreSQL instance.

### Backup Fider Database

```bash
# Backup to local file
docker compose exec postgres pg_dump -U fider -d fider > backups/fider_$(date +%F).sql

# Or using docker exec directly
docker exec crowd-wisdom-infra-postgres-1 pg_dump -U fider -d fider > backups/fider_backup.sql
```

### Restore Fider Database

```bash
# Restore from backup
docker compose exec -T postgres psql -U fider -d fider < backups/fider_backup.sql
```

### Access Fider Database

```bash
docker compose exec postgres psql -U fider -d fider
```

### Common SQL Commands

```sql
-- List all tables
\dt

-- View all ideas/posts
SELECT * FROM posts LIMIT 10;

-- View all users
SELECT * FROM users LIMIT 10;

-- Check database size
SELECT pg_size_pretty(pg_database_size('fider'));
```

## Troubleshooting

### Fider Won't Start

1. **Check database connectivity:**
   ```bash
   docker compose logs fider | grep -i database
   ```

2. **Verify environment variables are set:**
   ```bash
   docker compose config | grep FIDER
   ```

3. **Ensure PostgreSQL init script ran:**
   ```bash
   docker compose exec postgres psql -U postgres -c "\l" | grep fider
   ```

   If the fider database doesn't exist, create it manually:
   ```bash
   docker compose exec postgres psql -U postgres -c "CREATE USER fider WITH PASSWORD 'your_password';"
   docker compose exec postgres psql -U postgres -c "CREATE DATABASE fider OWNER fider;"
   ```

### Cannot Access Fider

1. **Check Caddy is proxying correctly:**
   ```bash
   docker compose logs caddy | grep fider
   ```

2. **Verify DNS is pointing to your server:**
   ```bash
   nslookup feedback.crowd-wisdom.com
   ```

3. **Check Fider health endpoint:**
   ```bash
   curl -I https://feedback.crowd-wisdom.com/api/health
   ```

### Email Not Working

1. **Check SMTP settings** - verify host, port, and credentials
2. **Check Fider logs for email errors:**
   ```bash
   docker compose logs fider | grep -i email
   ```
3. **Test SMTP connection** from another tool to verify credentials

### JWT Secret Issues

If you see authentication errors after changing the JWT secret:
- All existing sessions will be invalidated
- Users will need to log in again
- This is expected behavior

## Resource Usage

Fider is configured with the following resource limits:

| Resource | Limit | Reservation |
|----------|-------|-------------|
| CPU | 0.5 cores | 0.2 cores |
| Memory | 512MB | 256MB |

Adjust these in `docker-compose.yml` if needed for your workload.

## Updating Fider

```bash
# Pull latest image
docker compose pull fider

# Restart with new image
docker compose --profile prod up -d fider
```

Fider handles database migrations automatically on startup.
