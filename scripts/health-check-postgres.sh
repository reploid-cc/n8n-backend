#!/bin/bash
# RFC-002: PostgreSQL Local Database - Comprehensive Health Monitoring

set -euo pipefail

# Source environment variables
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Health check functions
check_container_running() {
    if docker ps --filter "name=postgres" --filter "status=running" | grep -q postgres; then
        echo "✅ PostgreSQL container is running"
        return 0
    else
        echo "❌ PostgreSQL container is not running"
        return 1
    fi
}

check_database_ready() {
    if docker exec postgres pg_isready -U "${POSTGRES_USER}" -d "${POSTGRES_DB}"; then
        echo "✅ PostgreSQL is accepting connections"
        return 0
    else
        echo "❌ PostgreSQL is not ready"
        return 1
    fi
}

check_schema_accessible() {
    local schema_check=$(docker exec postgres psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -tAc \
        "SELECT COUNT(*) FROM information_schema.schemata WHERE schema_name = 'n8n';")
    
    if [ "$schema_check" = "1" ]; then
        echo "✅ Schema 'n8n' is accessible"
        return 0
    else
        echo "❌ Schema 'n8n' is not accessible"
        return 1
    fi
}

check_performance() {
    echo "📊 Database performance metrics:"
    
    # Connection count
    local connections=$(docker exec postgres psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -tAc \
        "SELECT count(*) FROM pg_stat_activity;")
    echo "   Active connections: $connections"
    
    # Database size
    local db_size=$(docker exec postgres psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -tAc \
        "SELECT pg_size_pretty(pg_database_size('${POSTGRES_DB}'));")
    echo "   Database size: $db_size"
    
    # Uptime
    local uptime=$(docker exec postgres psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -tAc \
        "SELECT date_trunc('second', now() - pg_postmaster_start_time());")
    echo "   Uptime: $uptime"
    
    # Memory usage
    local memory_usage=$(docker stats postgres --no-stream --format "table {{.MemUsage}}" | tail -n 1)
    echo "   Memory usage: $memory_usage"
    
    # CPU usage
    local cpu_usage=$(docker stats postgres --no-stream --format "table {{.CPUPerc}}" | tail -n 1)
    echo "   CPU usage: $cpu_usage"
}

check_network_connectivity() {
    echo "🌐 Network connectivity check:"
    
    # Check if container is on correct network
    local network_info=$(docker inspect postgres --format '{{range $net, $conf := .NetworkSettings.Networks}}{{$net}}: {{$conf.IPAddress}}{{end}}')
    echo "   Network info: $network_info"
    
    # Check if IP is correct
    local container_ip=$(docker inspect postgres --format '{{range $net, $conf := .NetworkSettings.Networks}}{{if eq $net "n8n-local-network"}}{{$conf.IPAddress}}{{end}}{{end}}')
    if [ "$container_ip" = "172.21.0.10" ]; then
        echo "✅ Container has correct IP address: $container_ip"
    else
        echo "⚠️  Container IP may be incorrect: $container_ip (expected: 172.21.0.10)"
    fi
}

check_volume_mount() {
    echo "💾 Volume mount check:"
    
    # Check if data directory exists and is writable
    local data_check=$(docker exec postgres test -w /var/lib/postgresql/data && echo "writable" || echo "not writable")
    echo "   Data directory: $data_check"
    
    # Check volume size
    local volume_size=$(docker exec postgres df -h /var/lib/postgresql/data | tail -n 1 | awk '{print $2 " used: " $3 " available: " $4}')
    echo "   Volume size: $volume_size"
}

check_migration_status() {
    echo "📋 Migration status check:"
    
    # Check if migration log table exists
    local migration_table_exists=$(docker exec postgres psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -tAc \
        "SELECT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'migration_log');")
    
    if [ "$migration_table_exists" = "t" ]; then
        echo "✅ Migration tracking table exists"
        
        # Count executed migrations
        local migration_count=$(docker exec postgres psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -tAc \
            "SELECT COUNT(*) FROM public.migration_log;")
        echo "   Executed migrations: $migration_count"
        
        # Show latest migration
        local latest_migration=$(docker exec postgres psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -tAc \
            "SELECT script_name FROM public.migration_log ORDER BY executed_at DESC LIMIT 1;")
        echo "   Latest migration: $latest_migration"
    else
        echo "❌ Migration tracking table not found"
    fi
}

test_query_performance() {
    echo "⚡ Query performance test:"
    
    # Simple query performance test
    local start_time=$(date +%s%N)
    docker exec postgres psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -c "SELECT 1;" > /dev/null
    local end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 ))
    
    echo "   Simple query time: ${duration}ms"
    
    if [ $duration -lt 100 ]; then
        echo "✅ Query performance is good (< 100ms)"
    else
        echo "⚠️  Query performance may be slow (> 100ms)"
    fi
}

# Main health check
main() {
    echo "🏥 PostgreSQL Health Check (RFC-002)..."
    echo "================================================"
    
    local exit_code=0
    
    check_container_running || exit_code=1
    echo ""
    
    check_database_ready || exit_code=1
    echo ""
    
    check_schema_accessible || exit_code=1
    echo ""
    
    check_network_connectivity
    echo ""
    
    check_volume_mount
    echo ""
    
    check_migration_status
    echo ""
    
    check_performance
    echo ""
    
    test_query_performance
    echo ""
    
    echo "================================================"
    if [ $exit_code -eq 0 ]; then
        echo "✅ PostgreSQL health check passed"
    else
        echo "❌ PostgreSQL health check failed"
    fi
    
    return $exit_code
}

main "$@" 