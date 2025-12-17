#!/bin/bash
set -e

# Create Fider database and user
# This script runs automatically when postgres container is first initialized

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE USER ${FIDER_DB_USER:-fider} WITH PASSWORD '${FIDER_DB_PASSWORD:-changeme}';
    CREATE DATABASE ${FIDER_DB_NAME:-fider} OWNER ${FIDER_DB_USER:-fider};
    GRANT ALL PRIVILEGES ON DATABASE ${FIDER_DB_NAME:-fider} TO ${FIDER_DB_USER:-fider};
EOSQL

echo "Fider database and user created successfully"
