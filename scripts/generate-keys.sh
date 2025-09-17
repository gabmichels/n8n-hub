#!/bin/bash

# Generates a strong hexadecimal encryption key suitable for N8N_ENCRYPTION_KEY

echo "Generating a new N8N_ENCRYPTION_KEY..."
ENCRYPTION_KEY=$(openssl rand -hex 16)
echo ""
echo "---------------------------------------------------------------------"
echo "  Your new N8N_ENCRYPTION_KEY is: ${ENCRYPTION_KEY}"
echo "---------------------------------------------------------------------"
echo ""
echo "Please update the N8N_ENCRYPTION_KEY variable in your .env file with this value."
echo "CRITICAL: Do not change this key after initial setup, or you will lose access to encrypted data."
echo "Back up this key securely!"