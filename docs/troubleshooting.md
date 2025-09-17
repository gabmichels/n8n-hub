# Troubleshooting Guide

This guide provides solutions to common issues you might encounter when setting up or running your `n8n-hub`.

## 1. Docker Compose Issues

### Problem: `docker compose up -d` fails or services don't start.

**Possible Solutions**:

*   **Check Docker Status**: Ensure Docker is running.
    ```bash
    docker info
    ```
*   **Check Logs**: Inspect the logs of individual services to identify the error.
    ```bash
    docker compose logs -f n8n
    docker compose logs -f caddy
    docker compose logs -f postgres
    ```
*   **Resource Exhaustion**: Ensure your system has enough RAM and CPU. Docker containers can be resource-intensive.
*   **Port Conflicts**: Another application on your host might be using ports 80, 443, or 5678.
    *   **Linux**: `sudo netstat -tulpn | grep -E "80|443|5678"`
    *   **Windows (PowerShell)**: `Get-NetTCPConnection | Where-Object { $_.LocalPort -eq 80 -or $_.LocalPort -eq 443 -or $_.LocalPort -eq 5678 }`
*   **YAML Syntax**: Double-check `docker-compose.yml` and `docker-compose.override.yml` for indentation or syntax errors.

### Problem: `permission denied` when creating volumes or directories.

**Possible Solutions**:

*   Ensure the user running Docker has appropriate permissions. On Linux, your user should be part of the `docker` group.
    ```bash
    sudo usermod -aG docker $USER
    newgrp docker # You might need to log out and back in for changes to take effect
    ```
*   Verify permissions of the n8n-hub project directory.

## 2. HTTPS / Caddy Issues

### Problem: `https://<DOMAIN_NAME>` is not working or shows a certificate error (after initial setup).

**Possible Solutions**:

*   **DNS Resolution**: Ensure your `DOMAIN_NAME` correctly points to your server's public IP address. Use `nslookup` or `dig` (Linux/macOS) / `Resolve-DnsName` (Windows PowerShell) to verify.
*   **Firewall**: Confirm that ports 80 and 443 are open on your server's firewall.
*   **Caddy Logs**: Check Caddy logs for errors related to certificate provisioning.
    ```bash
    docker compose logs -f caddy
    ```
    Look for messages from Let's Encrypt.
*   **Caddyfile Syntax**: Verify `Caddyfile` for any syntax errors.
*   **Local Development**: If using `n8n.localhost`, ensure it's mapped in your hosts file (`127.0.0.1 n8n.localhost`). If you see "Your connection is not private" for `n8n.localhost`, this is expected for self-signed certificates; you can usually bypass it.

### Problem: Caddy cannot obtain Let's Encrypt certificates (production).

**Possible Solutions**:

*   **`CADDY_EMAIL`**: Ensure `CADDY_EMAIL` is set to a valid email in your `.env` file.
*   **DNS `A` Record**: Double-check that your `DOMAIN_NAME` A record points to the correct public IP of your server.
*   **Firewall**: Ports 80 and 443 *must* be open for Caddy to complete the ACME challenge.
*   **Rate Limits**: If you've tried too many times, Let's Encrypt might temporarily rate-limit your domain. Wait a few hours.

## 3. n8n Interface Issues

### Problem: n8n workflow editor doesn't load or shows blank page.

**Possible Solutions**:

*   **Browser Cache**: Clear your browser's cache and cookies for the n8n domain.
*   **`WEBHOOK_URL`**: Ensure `WEBHOOK_URL` in `.env` is correctly set, including `https://` and your full `DOMAIN_NAME`.
*   **n8n Logs**: Check n8n container logs for errors.
    ```bash
    docker compose logs -f n8n
    ```
*   **Nginx/Caddy Config**: Verify your reverse proxy (Caddyfile) is correctly forwarding headers and traffic to n8n. Ensure `header_up Host {http.request.host}` etc. are present.

### Problem: Cannot log in to n8n.

**Possible Solutions**:

*   **`N8N_USERNAME`, `N8N_PASSWORD`**: Verify these credentials in your `.env` file match what you're entering.
*   **Encryption Key**: If you changed `N8N_ENCRYPTION_KEY` after initializing n8n, you will lose access to credentials and potentially experience login issues if the old key encrypted user hashes. **Never change this key in production.**

## 4. PostgreSQL Database Issues

### Problem: n8n cannot connect to PostgreSQL.

**Possible Solutions**:

*   **PostgreSQL Logs**: Check PostgreSQL container logs for errors.
    ```bash
    docker compose logs -f postgres
    ```
*   **Environment Variables**: Double-check `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD` in `.env` and in `docker-compose.yml` for n8n's database connection.
*   **Network**: Ensure `n8n` and `postgres` services are on the same Docker network (`n8n_network`).

## 5. General Tips

*   **Restart Services**: After making changes to `.env` or `docker-compose.yml`, always restart your stack:
    ```bash
    docker compose down
    docker compose up -d
    ```
*   **Rebuild Images**: Sometimes, local caching can cause issues. Force a rebuild:
    ```bash
    docker compose build --no-cache
    docker compose up -d
    ```
*   **Seek Help**: If you're stuck, provide detailed logs, your `.env` (with sensitive info redacted), `docker-compose.yml`, and `Caddyfile` when asking for assistance.