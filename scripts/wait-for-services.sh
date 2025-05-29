#!/bin/bash
# Wait for services to be healthy

set -euo pipefail

echo "⏳ Waiting for services to be healthy..."

# Wait for PostgreSQL
echo "🔍 Checking PostgreSQL..."
timeout=60
counter=0
while [ $counter -lt $timeout ]; do
    if docker exec postgres pg_isready -U ${POSTGRES_USER:-postgres} &> /dev/null; then
        echo "✅ PostgreSQL is ready"
        break
    fi
    echo "⏳ PostgreSQL not ready yet... ($counter/$timeout)"
    sleep 2
    counter=$((counter + 2))
done

if [ $counter -ge $timeout ]; then
    echo "❌ PostgreSQL failed to start within $timeout seconds"
    exit 1
fi

# Wait for n8n
echo "🔍 Checking n8n..."
timeout=120
counter=0
while [ $counter -lt $timeout ]; do
    if curl -f http://localhost:5678/healthz &> /dev/null; then
        echo "✅ n8n is ready"
        break
    fi
    echo "⏳ n8n not ready yet... ($counter/$timeout)"
    sleep 3
    counter=$((counter + 3))
done

if [ $counter -ge $timeout ]; then
    echo "❌ n8n failed to start within $timeout seconds"
    exit 1
fi

echo "✅ All services are healthy!" 