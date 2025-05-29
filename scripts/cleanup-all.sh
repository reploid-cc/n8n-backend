#!/bin/bash
# Comprehensive cleanup cho fresh start

set -euo pipefail

echo "🧹 Comprehensive Docker Cleanup (RFC-001)"
echo "⚠️  This will remove ALL Docker containers, volumes, and unused images!"

# Confirmation prompt
read -p "Are you sure you want to perform complete cleanup? (type 'CLEANUP' to confirm): " -r
if [ "$REPLY" != "CLEANUP" ]; then
    echo "❌ Cleanup cancelled"
    exit 0
fi

# Stop all running containers
echo "⏹️  Stopping all running containers..."
docker stop $(docker ps -aq) 2>/dev/null || echo "No running containers to stop"

# Remove all containers
echo "🗑️  Removing all containers..."
docker rm $(docker ps -aq) 2>/dev/null || echo "No containers to remove"

# Remove all volumes
echo "📦 Removing all volumes..."
docker volume rm $(docker volume ls -q) 2>/dev/null || echo "No volumes to remove"

# Remove all networks (except default)
echo "🌐 Removing custom networks..."
docker network rm $(docker network ls --filter type=custom -q) 2>/dev/null || echo "No custom networks to remove"

# Remove unused images
echo "🖼️  Removing unused images..."
docker image prune -af

# Remove build cache
echo "🗂️  Removing build cache..."
docker builder prune -af

# System prune for final cleanup
echo "🔄 Final system cleanup..."
docker system prune -af --volumes

echo "✅ Complete Docker cleanup finished!"
echo "📊 Current Docker status:"
docker system df 