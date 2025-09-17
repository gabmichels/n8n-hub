# Production Deployment Guide

This guide outlines considerations and steps for deploying your `n8n-hub` to a production environment.

## 1. Choose Your Server Environment

Select a suitable server environment based on your needs:

*   **Cloud Provider (AWS, Azure, Google Cloud, DigitalOcean, Hetzner, etc.)**: Offers scalability, managed services, and often a robust infrastructure. You'll typically provision a Linux VM (e.g., Ubuntu, Debian).
*   **On-Premise Server**: For environments requiring strict data control or specific hardware.

**Minimum Server Requirements (starting point):**
*   2 vCPU (or physical cores)
*   4 GB RAM
*   50 GB SSD storage (for operating system, Docker, n8n data, PostgreSQL data)
    *   *Adjust storage based on expected workflow volume and data retention needs.*

## 2. Server Setup and Prerequisites

1.  **Operating System**: Install a clean Linux distribution (e.g., Ubuntu LTS).
2.  **Update System**:
    ```bash
    sudo apt update && sudo apt upgrade -y
    ```
3.  **Install Docker & Docker Compose**: Follow the official Docker installation guides for your OS.
    *   [Install Docker Engine](https://docs.docker.com/engine/install/ubuntu/)
    *   [Install Docker Compose](https://docs.docker.com/compose/install/)

## 3. Configure DNS

For Caddy to provision valid Let's Encrypt SSL certificates, your `DOMAIN_NAME` must correctly resolve to your server's public IP address.

1.  **Obtain Public IP**: Get the public IP address of your production server.
2.  **Create A Record**: In your domain registrar or DNS provider, create an `A` record that points your chosen `DOMAIN_NAME` (e.g., `n8n.yourcompany.com`) to your server's public IP address.
3.  **Propagation**: Wait for DNS changes to propagate (this can take from a few minutes to several hours). You can check propagation using tools like [DNS Checker](https://dnschecker.org/).

## 4. Environment Configuration

1.  **Clone Repository**: On your production server, clone the `n8n-hub` repository.
    ```bash
    git clone https://github.com/your-org/n8n-hub.git
    cd n8n-hub
    ```
2.  **Create `.env` File**:
    Copy `.env.example` to `.env` and **carefully fill in production-ready values**:
    ```bash
    cp .env.example .env
    ```
    *   **`DOMAIN_NAME`**: Your public domain (e.g., `n8n.yourcompany.com`).
    *   **`N8N_USERNAME`, `N8N_PASSWORD`**: **CRITICAL!** Use extremely strong, unique, and randomly generated credentials. Do not reuse passwords.
    *   **`N8N_ENCRYPTION_KEY`**: **CRITICAL!** Use the same key you generated during initial setup. Ensure it's backed up securely. **Never change this key in production.**
    *   **`POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`**: Use strong, unique credentials for PostgreSQL.
    *   **`CADDY_EMAIL`**: **Required!** Provide a valid email address. Caddy uses this for Let's Encrypt and important certificate expiry notifications.

## 5. Firewall Configuration

Ensure your server's firewall allows inbound traffic on the following ports:

*   **`80` (HTTP)**: Required for Let's Encrypt's `HTTP-01` challenge.
*   **`443` (HTTPS)**: For secure access to n8n.

Example for `ufw` (Uncomplicated Firewall) on Ubuntu:

```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable # if not already enabled
```

## 6. Deploy n8n-hub

From the `n8n-hub` directory, simply run:

```bash
docker compose up -d
```

Caddy will automatically request and renew Let's Encrypt certificates for your `DOMAIN_NAME`.

## 7. Post-Deployment Checks

*   **Access n8n**: Open your browser and navigate to `https://<YOUR_DOMAIN_NAME>`. Verify that HTTPS is working and n8n loads correctly.
*   **Check Logs**:
    ```bash
    docker compose logs -f n8n
    docker compose logs -f caddy
    ```
    Look for any errors, especially related to Caddy's certificate provisioning.
*   **Regular Backups**: Implement a strategy for regular backups of your `n8n_data` and `postgres_data` volumes.

## 8. Environment Hardening (Advanced)

*   **Non-root Docker**: Run Docker daemon and containers as non-root users.
*   **Resource Limits**: Define CPU and memory limits for containers in `docker-compose.yml`.
*   **Monitoring**: Integrate with monitoring solutions (Prometheus, Grafana).
*   **Security Scanning**: Regularly scan images for vulnerabilities.
*   **Automated Updates**: Set up automated updates for your OS and Docker images.
    *   Consider tools like [Watchtower](https://containrrr.dev/watchtower/) for automatic Docker image updates (use with caution in production).