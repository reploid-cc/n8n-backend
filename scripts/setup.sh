#!/bin/bash
# Main setup script cho n8n infrastructure

set -euo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🚀 n8n Backend Infrastructure Setup (RFC-001 & RFC-002)"
echo "📁 Project root: $PROJECT_ROOT"

# Change to project root
cd "$PROJECT_ROOT"

# Step 1: Environment validation
echo "📋 Step 1: Environment validation..."
if ! ./scripts/validate-env.sh; then
    echo "❌ Environment validation failed. Please fix issues and try again."
    exit 1
fi

# Step 2: Docker prerequisites check
echo "🐳 Step 2: Docker prerequisites check..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo "❌ Docker daemon is not running"
    exit 1
fi

echo "✅ Docker prerequisites check passed"

# Step 3: Cleanup previous installation
echo "🧹 Step 3: Cleanup previous installation..."
read -p "Do you want to cleanup previous n8n installation? (y/N): " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ./scripts/cleanup-n8n.sh
fi

# Step 4: Create Docker resources
echo "📦 Step 4: Creating Docker resources..."

# Create network
if ! docker network inspect n8n-local-network &> /dev/null; then
    docker network create \
        --driver bridge \
        --subnet=172.21.0.0/16 \
        --gateway=172.21.0.1 \
        n8n-local-network
    echo "✅ Created n8n-local-network"
else
    echo "✅ n8n-local-network already exists"
fi

# Create volumes
VOLUMES=("postgres_data" "n8n_data" "nginx_logs" "cloudflared_config")
for volume in "${VOLUMES[@]}"; do
    if ! docker volume inspect "$volume" &> /dev/null; then
        docker volume create "$volume"
        echo "✅ Created volume: $volume"
    else
        echo "✅ Volume already exists: $volume"
    fi
done

# Step 5: Start core services
echo "🚀 Step 5: Starting core services..."
docker-compose -f docker-compose.yml -f docker-compose.core.yml up -d

# Step 6: Wait for services to be healthy
echo "⏳ Step 6: Waiting for services to be healthy..."
./scripts/wait-for-services.sh

# Step 7: Validate PostgreSQL (RFC-002)
echo "🔍 Step 7: Validating PostgreSQL Local Database (RFC-002)..."
if [ -f scripts/validate-migrations.sh ]; then
    chmod +x scripts/validate-migrations.sh
    bash scripts/validate-migrations.sh
else
    echo "⚠️  PostgreSQL validation script not found"
fi

# Step 8: Comprehensive health check
echo "🏥 Step 8: Comprehensive health check..."
./scripts/health-check-all.sh

echo "✅ n8n Backend Infrastructure setup completed!"
echo ""
echo "📋 Access Information:"
echo "   n8n Local: http://localhost:5678"
echo "   PostgreSQL: localhost:5432 (postgres container)"
echo "   Database: ${POSTGRES_DB} (schema: n8n)"
echo ""
echo "🎯 RFC Implementation Status:"
echo "   ✅ RFC-001: Docker Foundation & Environment Setup"
echo "   ✅ RFC-002: PostgreSQL Local Database"
echo "   ⏳ RFC-003: n8n Backend Local Service (Next)"
echo ""
echo "🔗 Next steps:"
echo "   1. Access n8n at http://localhost:5678"
echo "   2. Verify database connection in n8n"
echo "   3. Create your first workflow"
echo "   4. Continue with RFC-003 implementation" 