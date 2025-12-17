# Server Operations Guide

This guide covers SSH access, initial server setup, and day-to-day operations for your crowd-wisdom-infra production server on Hetzner VPS.

## Prerequisites
- SSH key pair generated (see [deployment.md](deployment.md) for details)
- VPS IP: `91.98.146.64`

## Services & Domains
| Service | Domain | Port (local) |
|---------|--------|--------------|
| n8n | n8n.crowd-wisdom.com | 5678 |
| Fider | feedback.crowd-wisdom.com | 3015 |
| PostHog Proxy | e.crowd-wisdom.com | - |

## DNS Requirements
Add A records pointing to the VPS IP (`91.98.146.64`):
- `n8n.crowd-wisdom.com`
- `feedback.crowd-wisdom.com`
- `e.crowd-wisdom.com`

## SSH Access
Connect to the server using SSH:
```bash
ssh root@91.98.146.64
```
- Use your SSH key for authentication (no password needed if key is added).
- If prompted for password, use the root password from Hetzner console.

## Initial Server Setup
Run these commands once after provisioning the VPS:

1. **Update the system**:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

2. **Install Docker**:
   ```bash
   curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh
   ```

3. **Add user to Docker group** (log out and back in after this):
   ```bash
   sudo usermod -aG docker $USER
   ```

4. **Install Docker Compose**:
   ```bash
   sudo apt install docker-compose-plugin
   ```

5. **Configure firewall**:
   ```bash
   sudo ufw allow 22/tcp && sudo ufw allow 80/tcp && sudo ufw allow 443/tcp && sudo ufw enable
   ```

## Deploying crowd-wisdom-infra
1. **Clone the repository**:
   ```bash
   git clone https://github.com/gabmichels/n8n-hub.git
   cd n8n-hub
   ```

2. **Configure environment**:
   ```bash
   cp .env.example .env
   nano .env  # Edit with production values (domain, passwords, etc.)
   ```

   Key production settings:
   ```bash
   # Core
   N8N_HOST=n8n.crowd-wisdom.com
   N8N_PROTOCOL=https
   WEBHOOK_URL=https://n8n.crowd-wisdom.com/

   # Fider (feedback platform)
   FIDER_HOST=feedback.crowd-wisdom.com
   FIDER_BASE_URL=https://feedback.crowd-wisdom.com

   # PostHog proxy (analytics)
   POSTHOG_PROXY_HOST=e.crowd-wisdom.com
   ```

3. **Deploy**:
   ```bash
   docker compose --profile prod up -d
   ```

## Updating the Deployment
When you've made changes locally and pushed to git:

1. **SSH into the server**:
   ```bash
   ssh root@91.98.146.64
   cd n8n-hub
   ```

2. **Pull latest changes**:
   ```bash
   git pull origin main
   ```

3. **Recreate containers with new config**:
   ```bash
   docker compose --profile prod down
   docker compose --profile prod up -d
   ```

4. **Verify services are healthy**:
   ```bash
   docker compose ps
   ```

## Day-to-Day Operations

### Check Service Status
```bash
docker compose ps
```

### View Logs
- n8n logs:
  ```bash
  docker compose logs -f n8n-hub
  ```
- Fider logs:
  ```bash
  docker compose logs -f fider
  ```
- Caddy logs:
  ```bash
  docker compose logs -f caddy
  ```
- All logs:
  ```bash
  docker compose logs -f
  ```

### Restart Services
```bash
docker compose restart
```

### Quick Update (no config changes)
```bash
git pull origin main
docker compose --profile prod up -d --force-recreate
```

### Update Environment Variables
If you change .env values:
```bash
docker compose --profile prod down
docker compose --profile prod up -d
```

### Backup Data
- n8n data:
  ```bash
  docker run --rm -v n8n_data:/data -v $(pwd):/backup alpine tar czf /backup/n8n_data_$(date +%Y%m%d_%H%M).tgz -C /data .
  ```
- PostgreSQL (all databases):
  ```bash
  docker exec n8n-hub-postgres-1 pg_dump -U n8n n8n > n8n_db_$(date +%Y%m%d_%H%M).sql
  docker exec n8n-hub-postgres-1 pg_dump -U fider fider > fider_db_$(date +%Y%m%d_%H%M).sql
  ```

### Monitor Resources
```bash
htop  # Install with: sudo apt install htop
df -h  # Disk usage
docker stats  # Container resources
```

### Access Services
- **n8n**: https://n8n.crowd-wisdom.com (use N8N_BASIC_AUTH_USER/PASSWORD from .env)
- **Fider**: https://feedback.crowd-wisdom.com
- **PostHog Proxy**: https://e.crowd-wisdom.com (proxies to eu.posthog.com)

## Troubleshooting

### SSL Certificate Issues
- Check Caddy logs for errors.
- Ensure DNS points to VPS IP.
- Wait 5-10 minutes for Let's Encrypt provisioning.

### Environment Variables Not Updating
- Force recreate containers:
  ```bash
  docker compose up -d --force-recreate
  ```
- Check container env:
  ```bash
  docker exec -it n8n-hub-n8n-hub-1 env | grep VARIABLE_NAME
  ```

### Port Conflicts
- Check what's using ports:
  ```bash
  sudo netstat -tulpn | grep :80
  sudo netstat -tulpn | grep :443
  ```

### Out of Disk Space
- Clean Docker:
  ```bash
  docker system prune -a
  ```
- Check largest files:
  ```bash
  du -h / | sort -hr | head -20
  ```

### Firewall Issues
- Check status:
  ```bash
  sudo ufw status
  ```
- Allow additional ports if needed:
  ```bash
  sudo ufw allow PORT/tcp
  ```

## Security Notes
- Keep SSH keys secure.
- Use strong passwords in .env.
- Regularly update the system: `sudo apt update && sudo apt upgrade`.
- Monitor logs for suspicious activity.

## Support
If issues persist, check [troubleshooting.md](troubleshooting.md) or contact support.