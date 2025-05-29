#!/bin/bash
# Selective cleanup cho n8n project only

set -euo pipefail

echo "🧹 n8n Project Cleanup (RFC-001)"

# Stop n8n related containers
echo "⏹️  Stopping n8n containers..."
docker-compose down --remove-orphans 2>/dev/null || echo "No compose services running"

# Remove containers (using actual short names)
docker rm -f postgres n8n nocodb nginx cloudflared n8n-worker 2>/dev/null || echo "Containers already removed"

# Remove volumes (excluding redis_data which doesn't exist locally)
docker volume rm postgres_data n8n_data nginx_logs cloudflared_config 2>/dev/null || echo "Volumes already removed"

# Remove n8n network
echo "🌐 Removing n8n network..."
docker network rm n8n-local-network 2>/dev/null || echo "Network already removed"

echo "✅ n8n project cleanup completed!" 