#!/bin/bash
# RFC-002: PostgreSQL Local Database - Migration Validation Script
# Validate database migrations and schema

set -euo pipefail

# Source environment variables
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Database connection parameters
DB_HOST="172.21.0.10"
DB_PORT="5432"
DB_NAME="${POSTGRES_DB}"
DB_USER="${POSTGRES_USER}"

# Wait for database to be ready
wait_for_database() {
    echo "⏳ Waiting for PostgreSQL to be ready..."
    
    local retries=30
    for i in $(seq 1 $retries); do
        if docker exec postgres pg_isready -U "${DB_USER}" -d "${DB_NAME}"; then
            echo "✅ PostgreSQL is ready"
            return 0
        fi
        echo "⏳ Attempt $i/$retries - waiting..."
        sleep 2
    done
    
    echo "❌ PostgreSQL failed to become ready"
    return 1
}

# Validate schema exists
validate_schema() {
    echo "🔍 Validating n8n schema..."
    
    local schema_exists=$(docker exec postgres psql -U "${DB_USER}" -d "${DB_NAME}" -tAc \
        "SELECT EXISTS(SELECT 1 FROM information_schema.schemata WHERE schema_name = 'n8n');")
    
    if [ "$schema_exists" = "t" ]; then
        echo "✅ Schema 'n8n' exists"
    else
        echo "❌ Schema 'n8n' not found"
        return 1
    fi
}

# Validate migration tracking
validate_migrations() {
    echo "🔍 Validating migration tracking..."
    
    local migration_table_exists=$(docker exec postgres psql -U "${DB_USER}" -d "${DB_NAME}" -tAc \
        "SELECT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'migration_log');")
    
    if [ "$migration_table_exists" = "t" ]; then
        echo "✅ Migration tracking table exists"
        
        # Show executed migrations
        echo "📋 Executed migrations:"
        docker exec postgres psql -U "${DB_USER}" -d "${DB_NAME}" -c \
            "SELECT script_name, executed_at FROM public.migration_log ORDER BY executed_at;"
    else
        echo "❌ Migration tracking table not found"
        return 1
    fi
}

# Check database connectivity
check_connectivity() {
    echo "🔍 Testing database connectivity..."
    
    if docker exec postgres psql -U "${DB_USER}" -d "${DB_NAME}" -c "SELECT version();"; then
        echo "✅ Database connectivity successful"
    else
        echo "❌ Database connectivity failed"
        return 1
    fi
}

# Validate search path
validate_search_path() {
    echo "🔍 Validating search path..."
    
    local search_path=$(docker exec postgres psql -U "${DB_USER}" -d "${DB_NAME}" -tAc \
        "SHOW search_path;")
    
    if [[ "$search_path" == *"n8n"* ]]; then
        echo "✅ Search path includes n8n schema: $search_path"
    else
        echo "⚠️  Search path may not include n8n schema: $search_path"
    fi
}

# Check table count in n8n schema
check_table_count() {
    echo "🔍 Checking tables in n8n schema..."
    
    local table_count=$(docker exec postgres psql -U "${DB_USER}" -d "${DB_NAME}" -tAc \
        "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'n8n';")
    
    echo "📊 Tables in n8n schema: $table_count"
    
    if [ "$table_count" -gt 0 ]; then
        echo "📋 Tables in n8n schema:"
        docker exec postgres psql -U "${DB_USER}" -d "${DB_NAME}" -c \
            "SELECT table_name FROM information_schema.tables WHERE table_schema = 'n8n' ORDER BY table_name;"
    fi
}

# Main validation process
main() {
    echo "🔍 Validating PostgreSQL Local Database (RFC-002)..."
    
    wait_for_database
    validate_schema
    validate_migrations
    check_connectivity
    validate_search_path
    check_table_count
    
    echo "✅ PostgreSQL Local Database validation completed successfully!"
}

main "$@" 