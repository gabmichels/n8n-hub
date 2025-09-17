# Bootstrap script for n8n-hub on Windows (PowerShell)

param(
    [string]$Mode = "auto"  # auto, local, prod
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 Starting n8n-hub setup..." -ForegroundColor Green

# Check if .env exists
if (-not (Test-Path .env)) {
    Write-Host "📋 Creating .env from .env.example..." -ForegroundColor Yellow
    Copy-Item .env.example .env
    Write-Host "⚠️  .env file created. Please edit it with your configurations." -ForegroundColor Yellow
    Write-Host "📖 See docs/setup.md for setup instructions." -ForegroundColor Cyan
    Exit 1
}

# Check for required tools
Write-Host "🔧 Checking for Docker and Docker Compose..." -ForegroundColor Blue
try {
    $null = docker info 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Docker is not running"
    }
} catch {
    Write-Host "❌ Docker is not installed or not running. Please install Docker Desktop." -ForegroundColor Red
    Exit 1
}

try {
    $null = docker compose version 2>&1
    if ($LASTEXITCODE -ne 0) {
        $null = docker-compose version 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "Docker Compose not found"
        }
    }
} catch {
    Write-Host "❌ Docker Compose is not available. Please update Docker Desktop." -ForegroundColor Red
    Exit 1
}

# Generate encryption key if needed
$envContent = Get-Content .env -Raw
if ($envContent -match "N8N_ENCRYPTION_KEY=REPLACE_ME_WITH_RANDOM") {
    Write-Host "🔑 Generating N8N_ENCRYPTION_KEY..." -ForegroundColor Blue
    
    # Generate a random 32-character hexadecimal string
    $bytes = New-Object byte[] 16
    $rng = [System.Security.Cryptography.RNGCryptoServiceProvider]::Create()
    $rng.GetBytes($bytes)
    $encryptionKey = [System.BitConverter]::ToString($bytes) -replace '-', ''
    $rng.Dispose()
    
    # Update .env file
    $envContent = $envContent -replace "N8N_ENCRYPTION_KEY=REPLACE_ME_WITH_RANDOM", "N8N_ENCRYPTION_KEY=$encryptionKey"
    $envContent | Set-Content .env -NoNewline
    
    Write-Host "✅ Generated and saved N8N_ENCRYPTION_KEY" -ForegroundColor Green
} else {
    Write-Host "✅ N8N_ENCRYPTION_KEY already configured" -ForegroundColor Green
}

# Detect mode based on configuration
$n8nHost = (Get-Content .env | Select-String -Pattern "^N8N_HOST=").ToString().Split('=', 2)[1].Trim('"').Trim("'")
$n8nProtocol = (Get-Content .env | Select-String -Pattern "^N8N_PROTOCOL=").ToString().Split('=', 2)[1].Trim('"').Trim("'")

if ($Mode -eq "auto") {
    if ($n8nHost -eq "localhost" -and $n8nProtocol -eq "http") {
        $detectedMode = "local"
        Write-Host "🏠 Detected LOCAL mode configuration" -ForegroundColor Cyan
        $accessUrl = "http://localhost:5678"
    } else {
        $detectedMode = "prod"
        Write-Host "🌐 Detected PRODUCTION mode configuration" -ForegroundColor Cyan
        $accessUrl = "${n8nProtocol}://${n8nHost}"
    }
} else {
    $detectedMode = $Mode
    Write-Host "🎯 Using specified mode: $detectedMode" -ForegroundColor Cyan
}

# Create necessary directories
Write-Host "📁 Creating directories..." -ForegroundColor Blue
New-Item -ItemType Directory -Force -Path "workflows/examples" | Out-Null
New-Item -ItemType Directory -Force -Path "workflows/backups" | Out-Null

# Validate docker compose configuration
Write-Host "🔍 Validating Docker Compose configuration..." -ForegroundColor Blue
try {
    $null = docker compose --profile $detectedMode config 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Invalid configuration"
    }
} catch {
    Write-Host "❌ Docker Compose configuration is invalid. Check your .env file." -ForegroundColor Red
    Exit 1
}

# Start the stack
Write-Host "🐳 Starting n8n-hub in $detectedMode mode..." -ForegroundColor Green
docker compose --profile $detectedMode up -d

Write-Host ""
Write-Host "🎉 n8n-hub setup complete!" -ForegroundColor Green
Write-Host "📍 Access n8n at: $accessUrl" -ForegroundColor Yellow
Write-Host ""
Write-Host "📋 Next steps:" -ForegroundColor Cyan
if ($detectedMode -eq "local") {
    Write-Host "  1. Open $accessUrl in your browser" -ForegroundColor White
    Write-Host "  2. Create your first admin user" -ForegroundColor White
    Write-Host "  3. Start building workflows!" -ForegroundColor White
} else {
    Write-Host "  1. Ensure DNS points to this server" -ForegroundColor White
    Write-Host "  2. Open $accessUrl in your browser" -ForegroundColor White
    Write-Host "  3. Enter Basic Auth credentials (check .env)" -ForegroundColor White
    Write-Host "  4. Create your first admin user" -ForegroundColor White
}
Write-Host ""
Write-Host "🔍 Monitor with: docker compose logs -f" -ForegroundColor Cyan
Write-Host "🛑 Stop with: docker compose --profile $detectedMode down" -ForegroundColor Cyan