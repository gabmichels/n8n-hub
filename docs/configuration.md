# Configuration Reference

This document provides a detailed reference for all environment variables used in the `n8n-hub` project. These variables are defined in your `.env` file, which is based on `.env.example`.

## General Configuration

*   **`DOMAIN_NAME`**
    *   **Description**: The full domain name or IP address where n8n will be accessible.
    *   **Examples**: `n8n.yourcompany.com`, `n8n.localhost` (for local development).
    *   **Important**: For local development, if you use `n8n.localhost`, ensure it's mapped to `127.0.0.1` in your hosts file. For production, this must be a public domain pointing to your server.

## n8n Specific Configuration

*   **`N8N_USERNAME`**
    *   **Description**: The username for n8n's basic authentication.
    *   **Important**: Use a strong, unique username, especially in production.

*   **`N8N_PASSWORD`**
    *   **Description**: The password for n8n's basic authentication.
    *   **Important**: Use a strong, randomly generated password, especially in production.

*   **`N8N_ENCRYPTION_KEY`**
    *   **Description**: A key used by n8n to encrypt sensitive data (e.g., credentials) stored in its database.
    *   **Format**: A 32-character hexadecimal string (16 bytes).
    *   **Generation**: You can generate one using `openssl rand -hex 16` (Linux/macOS) or refer to `scripts/bootstrap.ps1` for Windows.
    *   **Critical**: **DO NOT CHANGE THIS KEY AFTER YOUR INITIAL SETUP.** Changing it will make all previously encrypted data (like stored credentials in workflows) inaccessible. Back this key up securely!

*   **`TZ`**
    *   **Description**: The timezone setting for the n8n container. This affects how n8n displays and processes time-based data.
    *   **Format**: Olson timezone database format (e.g., `Europe/Berlin`, `America/New_York`).
    *   **Reference**: [List of tz database time zones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)

## PostgreSQL Database Configuration

*   **`POSTGRES_DB`**
    *   **Description**: The name of the PostgreSQL database to be created for n8n.
    *   **Default**: `n8n`

*   **`POSTGRES_USER`**
    *   **Description**: The username for accessing the PostgreSQL database.
    *   **Important**: Use a strong, unique username.

*   **`POSTGRES_PASSWORD`**
    *   **Description**: The password for the PostgreSQL database user.
    *   **Important**: Use a strong, randomly generated password.

## Caddy Reverse Proxy Configuration

*   **`CADDY_EMAIL`**
    *   **Description**: Your email address. Caddy uses this to register with Let's Encrypt for automatic HTTPS certificates.
    *   **Important**: Required for production environments to obtain valid, trusted certificates. For local development with self-signed certificates, this can be left empty or set to a dummy value.

*   **`CADDY_LOG_LEVEL`**
    *   **Description**: Sets the log level for Caddy.
    *   **Values**: `DEBUG`, `INFO`, `WARN`, `ERROR`, `FATAL`.
    *   **Default**: `INFO` (if not specified). Set to `DEBUG` for verbose logging during troubleshooting.