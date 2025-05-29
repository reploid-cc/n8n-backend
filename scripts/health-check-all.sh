#!/bin/bash
# Comprehensive health check for all services

set -euo pipefail

echo "🔍 Comprehensive Health Check (RFC-001 & RFC-002)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check_docker_resources() {
    echo "📦 Checking Docker Resources..."
    
    # Check network
    if docker network inspect n8n-local-network &> /dev/null; then
        echo -e "✅ Network: ${GREEN}n8n-local-network${NC}"
    else
        echo -e "❌ Network: ${RED}n8n-local-network not found${NC}"
        return 1
    fi
    
    # Check volumes
    local volumes=("postgres_data" "n8n_data")
    for volume in "${volumes[@]}"; do
        if docker volume inspect "$volume" &> /dev/null; then
            echo -e "✅ Volume: ${GREEN}$volume${NC}"
        else
            echo -e "❌ Volume: ${RED}$volume not found${NC}"
            return 1
        fi
    done
}

check_service_health() {
    echo "🏥 Checking Service Health..."
    
    # Check PostgreSQL (RFC-002)
    if docker ps --filter "name=postgres" --filter "status=running" | grep -q postgres; then
        if docker exec postgres pg_isready -U ${POSTGRES_USER:-postgres} &> /dev/null; then
            echo -e "✅ PostgreSQL: ${GREEN}Running and Ready${NC}"
        else
            echo -e "⚠️  PostgreSQL: ${YELLOW}Running but not ready${NC}"
        fi
    else
        echo -e "❌ PostgreSQL: ${RED}Not running${NC}"
        return 1
    fi
    
    # Check n8n
    if docker ps --filter "name=n8n" --filter "status=running" | grep -q n8n; then
        if curl -f http://localhost:5678/healthz &> /dev/null; then
            echo -e "✅ n8n: ${GREEN}Running and Healthy${NC}"
        else
            echo -e "⚠️  n8n: ${YELLOW}Running but not healthy${NC}"
        fi
    else
        echo -e "❌ n8n: ${RED}Not running${NC}"
        return 1
    fi
}

check_connectivity() {
    echo "🔗 Checking Connectivity..."
    
    # Test PostgreSQL connection (RFC-002)
    if docker exec postgres psql -U ${POSTGRES_USER:-postgres} -d ${POSTGRES_DB:-postgres} -c "SELECT 1;" &> /dev/null; then
        echo -e "✅ PostgreSQL Connection: ${GREEN}OK${NC}"
    else
        echo -e "❌ PostgreSQL Connection: ${RED}Failed${NC}"
        return 1
    fi
    
    # Test n8n API
    if curl -f http://localhost:5678/healthz &> /dev/null; then
        echo -e "✅ n8n API: ${GREEN}OK${NC}"
    else
        echo -e "❌ n8n API: ${RED}Failed${NC}"
        return 1
    fi
}

check_database_schema() {
    echo "🗄️  Checking Database Schema (RFC-002)..."
    
    # Check if n8n schema exists
    local schema_exists=$(docker exec postgres psql -U ${POSTGRES_USER:-postgres} -d ${POSTGRES_DB:-postgres} -tAc \
        "SELECT EXISTS(SELECT 1 FROM information_schema.schemata WHERE schema_name = 'n8n');" 2>/dev/null || echo "f")
    
    if [ "$schema_exists" = "t" ]; then
        echo -e "✅ n8n Schema: ${GREEN}Exists${NC}"
        
        # Count tables in n8n schema
        local table_count=$(docker exec postgres psql -U ${POSTGRES_USER:-postgres} -d ${POSTGRES_DB:-postgres} -tAc \
            "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'n8n';" 2>/dev/null || echo "0")
        echo -e "📊 Tables in n8n schema: ${GREEN}$table_count${NC}"
    else
        echo -e "❌ n8n Schema: ${RED}Not found${NC}"
        return 1
    fi
    
    # Check migration log
    local migration_table_exists=$(docker exec postgres psql -U ${POSTGRES_USER:-postgres} -d ${POSTGRES_DB:-postgres} -tAc \
        "SELECT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'migration_log');" 2>/dev/null || echo "f")
    
    if [ "$migration_table_exists" = "t" ]; then
        local migration_count=$(docker exec postgres psql -U ${POSTGRES_USER:-postgres} -d ${POSTGRES_DB:-postgres} -tAc \
            "SELECT COUNT(*) FROM public.migration_log;" 2>/dev/null || echo "0")
        echo -e "✅ Migration Log: ${GREEN}$migration_count migrations executed${NC}"
    else
        echo -e "⚠️  Migration Log: ${YELLOW}Not found${NC}"
    fi
}

show_resource_usage() {
    echo "📊 Resource Usage..."
    
    # Show container stats
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" postgres n8n 2>/dev/null || echo "⚠️  Could not get container stats"
}

show_network_info() {
    echo "🌐 Network Information..."
    
    # Show container IPs
    local postgres_ip=$(docker inspect postgres --format '{{range $net, $conf := .NetworkSettings.Networks}}{{if eq $net "n8n-local-network"}}{{$conf.IPAddress}}{{end}}{{end}}' 2>/dev/null || echo "N/A")
    local n8n_ip=$(docker inspect n8n --format '{{range $net, $conf := .NetworkSettings.Networks}}{{if eq $net "n8n-local-network"}}{{$conf.IPAddress}}{{end}}{{end}}' 2>/dev/null || echo "N/A")
    
    echo -e "   PostgreSQL IP: ${GREEN}$postgres_ip${NC}"
    echo -e "   n8n IP: ${GREEN}$n8n_ip${NC}"
}

main() {
    local exit_code=0
    
    check_docker_resources || exit_code=1
    echo ""
    check_service_health || exit_code=1
    echo ""
    check_connectivity || exit_code=1
    echo ""
    check_database_schema || exit_code=1
    echo ""
    show_network_info
    echo ""
    show_resource_usage
    echo ""
    
    if [ $exit_code -eq 0 ]; then
        echo -e "🎉 ${GREEN}All health checks passed!${NC}"
        echo ""
        echo "🎯 RFC Implementation Status:"
        echo -e "   ✅ ${GREEN}RFC-001: Docker Foundation & Environment Setup${NC}"
        echo -e "   ✅ ${GREEN}RFC-002: PostgreSQL Local Database${NC}"
        echo ""
        echo "🔗 Access URLs:"
        echo "   n8n: http://localhost:5678"
        echo "   PostgreSQL: localhost:5432 (postgres)"
    else
        echo -e "❌ ${RED}Some health checks failed${NC}"
        echo "📋 Check logs with: docker logs <container_name>"
    fi
    
    return $exit_code
}

# Source environment variables
if [ -f .env ]; then
    set -a
    source .env
    set +a
fi

main "$@" 