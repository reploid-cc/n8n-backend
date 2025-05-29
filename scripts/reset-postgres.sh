#!/bin/bash
# RFC-002: PostgreSQL Local Database - Reset Script for Development

set -euo pipefail

echo "🗑️  PostgreSQL Database Reset (RFC-002)"
echo "⚠️  This will destroy all data in the local database!"
echo ""

# Confirmation prompt
read -p "Are you sure you want to reset the database? (type 'yes' to confirm): " -r
if [ "$REPLY" != "yes" ]; then
    echo "❌ Database reset cancelled"
    exit 0
fi

echo ""
echo "🔄 Starting PostgreSQL database reset..."

# Stop PostgreSQL service
echo "⏹️  Stopping PostgreSQL service..."
docker-compose -f docker-compose.yml -f docker-compose.core.yml stop postgres

# Stop n8n service if running (depends on PostgreSQL)
echo "⏹️  Stopping n8n service..."
docker-compose -f docker-compose.yml -f docker-compose.core.yml stop n8n 2>/dev/null || echo "   n8n was not running"

# Remove containers
echo "🗑️  Removing containers..."
docker rm postgres 2>/dev/null || echo "   postgres container already removed"
docker rm n8n 2>/dev/null || echo "   n8n container already removed"

# Remove data volume
echo "🗑️  Removing data volume..."
docker volume rm postgres_data 2>/dev/null || echo "   Volume already removed"

# Remove n8n data volume as well (fresh start)
echo "🗑️  Removing n8n data volume..."
docker volume rm n8n_data 2>/dev/null || echo "   n8n volume already removed"

# Recreate volumes
echo "📦 Recreating data volumes..."
docker volume create postgres_data
docker volume create n8n_data

# Restart PostgreSQL service
echo "🚀 Starting PostgreSQL service..."
docker-compose -f docker-compose.yml -f docker-compose.core.yml up -d postgres

# Wait for database to be ready
echo "⏳ Waiting for database initialization..."
sleep 15

# Validate reset
echo "🔍 Validating database reset..."
if [ -f scripts/validate-migrations.sh ]; then
    chmod +x scripts/validate-migrations.sh
    bash scripts/validate-migrations.sh
else
    echo "⚠️  Validation script not found, skipping validation"
fi

# Restart n8n service
echo "🚀 Starting n8n service..."
docker-compose -f docker-compose.yml -f docker-compose.core.yml up -d n8n

echo ""
echo "✅ PostgreSQL database reset completed"
echo "🔗 Services should be available at:"
echo "   - PostgreSQL: localhost:5432"
echo "   - n8n: http://localhost:5678" 