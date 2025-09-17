#!/bin/bash

# Bootstrap script for n8n-hub on Linux/macOS

set -e  # Exit on any error

echo "🚀 Starting n8n-hub setup..."

# Check if .env exists
if [ ! -f .env ]; then
    echo "📋 Creating .env from .env.example..."
    cp .env.example .env
    echo "⚠️  .env file created. Please edit it with your configurations."
    echo "📖 See docs/setup.md for setup instructions."
    exit 1
fi

# Check for required tools
echo "🔧 Checking for Docker and Docker Compose..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! command -v docker compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose."
    exit 1
fi

# Generate encryption key if needed
if grep -q "N8N_ENCRYPTION_KEY=REPLACE_ME_WITH_RANDOM" .env; then
    echo "🔑 Generating N8N_ENCRYPTION_KEY..."
    
    # Check if openssl is available
    if command -v openssl &> /dev/null; then
        ENCRYPTION_KEY=$(openssl rand -hex 16)
    else
        # Fallback for systems without openssl
        ENCRYPTION_KEY=$(head -c 16 /dev/urandom | xxd -p)
    fi
    
    # Update .env file
    if [ "$(uname)" = "Darwin" ]; then
        # macOS sed
        sed -i '' "s/^N8N_ENCRYPTION_KEY=REPLACE_ME_WITH_RANDOM$/N8N_ENCRYPTION_KEY=${ENCRYPTION_KEY}/" .env
    else
        # Linux sed
        sed -i "s/^N8N_ENCRYPTION_KEY=REPLACE_ME_WITH_RANDOM$/N8N_ENCRYPTION_KEY=${ENCRYPTION_KEY}/" .env
    fi
    echo "✅ Generated and saved N8N_ENCRYPTION_KEY"
else
    echo "✅ N8N_ENCRYPTION_KEY already configured"
fi

# Detect mode based on configuration
N8N_HOST=$(grep ^N8N_HOST= .env | cut -d= -f2- | tr -d '"' | tr -d "'")
N8N_PROTOCOL=$(grep ^N8N_PROTOCOL= .env | cut -d= -f2- | tr -d '"' | tr -d "'")

if [[ "$N8N_HOST" == "localhost" && "$N8N_PROTOCOL" == "http" ]]; then
    MODE="local"
    echo "🏠 Detected LOCAL mode configuration"
    ACCESS_URL="http://localhost:5678"
else
    MODE="prod"
    echo "🌐 Detected PRODUCTION mode configuration"
    ACCESS_URL="${N8N_PROTOCOL}://${N8N_HOST}"
fi

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p workflows/examples workflows/backups

# Validate docker compose configuration
echo "🔍 Validating Docker Compose configuration..."
if ! docker compose --profile $MODE config > /dev/null; then
    echo "❌ Docker Compose configuration is invalid. Check your .env file."
    exit 1
fi

# Start the stack
echo "🐳 Starting n8n-hub in $MODE mode..."
docker compose --profile $MODE up -d

echo ""
echo "🎉 n8n-hub setup complete!"
echo "📍 Access n8n at: $ACCESS_URL"
echo ""
echo "📋 Next steps:"
if [ "$MODE" = "local" ]; then
    echo "  1. Open $ACCESS_URL in your browser"
    echo "  2. Create your first admin user"
    echo "  3. Start building workflows!"
else
    echo "  1. Ensure DNS points to this server"
    echo "  2. Open $ACCESS_URL in your browser"
    echo "  3. Enter Basic Auth credentials (check .env)"
    echo "  4. Create your first admin user"
fi
echo ""
echo "🔍 Monitor with: docker compose logs -f"
echo "🛑 Stop with: docker compose --profile $MODE down"