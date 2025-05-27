# RFC-002: PostgreSQL Local Database

## Summary
Thiết lập PostgreSQL container local với schema "n8n" cho n8n local development environment. RFC này tạo isolated database riêng biệt từ VPS, với auto-migrations, persistent storage, và health monitoring.

## Features Addressed
- **F002:** PostgreSQL Local Database (Must Have)

## Dependencies
- **Previous RFCs:** RFC-001 (Docker Foundation & Environment Setup)
- **External Dependencies:** Migration files trong database/ref/

## Builds Upon
- Docker orchestration system từ RFC-001
- n8n-local-network (172.20.0.0/16)
- Volume management system
- Environment validation framework

## Enables Future RFCs
- **RFC-003:** n8n Backend Local Service (requires PostgreSQL connection)
- **RFC-004:** NocoDB Database Interface (requires PostgreSQL to manage)
- **RFC-006:** Data Management (requires database cho mock data)

## Technical Approach

### Architecture Overview
```
PostgreSQL Local Architecture:
├── PostgreSQL 15+ Container (alpine)
├── Schema: "n8n" (isolated từ VPS)
├── Volume: postgres_data (persistent storage)
├── Network: n8n-local-network (172.20.0.10)
├── Migrations: Auto-execute từ database/ref/
└── Health Checks: pg_isready monitoring
```

### Database Schema Strategy
```sql
-- Schema isolation strategy
CREATE SCHEMA IF NOT EXISTS n8n;
SET search_path TO n8n;

-- Core n8n tables (from migration files)
-- Tables will be created via migration scripts
-- Schema structure follows n8n standard:
-- - users, workflows, executions
-- - credentials, settings, variables
-- - queue system tables
-- - user-tier tables
```

### Data Persistence Strategy
```yaml
# Volume mounting cho data persistence
volumes:
  postgres_data:
    driver: local
    # Mounts to: /var/lib/postgresql/data
    # Ensures: Zero data loss on container restart
```

## Detailed Implementation Specifications

### 1. PostgreSQL Service Configuration

#### Docker Compose Service (docker-compose.core.yml)
```yaml
version: '3.8'

services:
  postgresql-local:
    image: postgres:15-alpine
    container_name: postgresql-local
    restart: unless-stopped
    
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_INITDB_ARGS: "--encoding=UTF8 --locale=C"
      
    volumes:
      # Data persistence
      - postgres_data:/var/lib/postgresql/data
      # Migration scripts auto-execution
      - ./database/migrations:/docker-entrypoint-initdb.d:ro
      # Reference migrations
      - ./database/ref:/docker-entrypoint-ref:ro
      
    networks:
      n8n-local-network:
        ipv4_address: 172.20.0.10
        
    ports:
      # Internal access only (no external exposure)
      - "127.0.0.1:5432:5432"
      
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
      
    # Resource limits cho development
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '0.5'
        reservations:
          memory: 512M
          cpus: '0.25'

networks:
  n8n-local-network:
    external: true

volumes:
  postgres_data:
    external: true
```

### 2. Database Migration System

#### Migration Script Processor (database/migrations/001-init-schema.sql)
```sql
-- Initialize n8n schema
-- This script runs automatically on first container start

-- Create n8n schema
CREATE SCHEMA IF NOT EXISTS n8n;

-- Set default search path
ALTER DATABASE ${POSTGRES_DB} SET search_path TO n8n, public;

-- Create extension if needed
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Log initialization
INSERT INTO public.migration_log (script_name, executed_at) 
VALUES ('001-init-schema.sql', NOW())
ON CONFLICT DO NOTHING;

-- Note: Actual table creation will be handled by migration files
-- from database/ref/ directory in subsequent scripts
```

#### Migration Processor (database/migrations/002-process-ref-migrations.sql)
```sql
-- Process migration files from database/ref/
-- This script copies and executes reference migrations

-- Create migration tracking table
CREATE TABLE IF NOT EXISTS public.migration_log (
    id SERIAL PRIMARY KEY,
    script_name VARCHAR(255) UNIQUE NOT NULL,
    executed_at TIMESTAMP DEFAULT NOW(),
    checksum VARCHAR(64)
);

-- Set schema context
SET search_path TO n8n;

-- Note: This script will be enhanced to process files from /docker-entrypoint-ref/
-- For now, it establishes the framework for migration processing
```

#### Migration Validation Script (scripts/validate-migrations.sh)
```bash
#!/bin/bash
# Validate database migrations and schema

set -euo pipefail

# Database connection parameters
DB_HOST="172.20.0.10"
DB_PORT="5432"
DB_NAME="${POSTGRES_DB}"
DB_USER="${POSTGRES_USER}"

# Wait for database to be ready
wait_for_database() {
    echo "⏳ Waiting for PostgreSQL to be ready..."
    
    local retries=30
    for i in $(seq 1 $retries); do
        if docker exec postgresql-local pg_isready -U "${DB_USER}" -d "${DB_NAME}"; then
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
    
    local schema_exists=$(docker exec postgresql-local psql -U "${DB_USER}" -d "${DB_NAME}" -tAc \
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
    
    local migration_table_exists=$(docker exec postgresql-local psql -U "${DB_USER}" -d "${DB_NAME}" -tAc \
        "SELECT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'migration_log');")
    
    if [ "$migration_table_exists" = "t" ]; then
        echo "✅ Migration tracking table exists"
        
        # Show executed migrations
        echo "📋 Executed migrations:"
        docker exec postgresql-local psql -U "${DB_USER}" -d "${DB_NAME}" -c \
            "SELECT script_name, executed_at FROM public.migration_log ORDER BY executed_at;"
    else
        echo "❌ Migration tracking table not found"
        return 1
    fi
}

# Check database connectivity
check_connectivity() {
    echo "🔍 Testing database connectivity..."
    
    if docker exec postgresql-local psql -U "${DB_USER}" -d "${DB_NAME}" -c "SELECT version();"; then
        echo "✅ Database connectivity successful"
    else
        echo "❌ Database connectivity failed"
        return 1
    fi
}

# Main validation process
main() {
    echo "🔍 Validating PostgreSQL Local Database (RFC-002)..."
    
    wait_for_database
    validate_schema
    validate_migrations
    check_connectivity
    
    echo "✅ PostgreSQL Local Database validation completed successfully!"
}

main "$@"
```

### 3. Health Monitoring System

#### Database Health Check (scripts/health-check-postgres.sh)
```bash
#!/bin/bash
# Comprehensive PostgreSQL health monitoring

set -euo pipefail

# Health check functions
check_container_running() {
    if docker ps --filter "name=postgresql-local" --filter "status=running" | grep -q postgresql-local; then
        echo "✅ PostgreSQL container is running"
        return 0
    else
        echo "❌ PostgreSQL container is not running"
        return 1
    fi
}

check_database_ready() {
    if docker exec postgresql-local pg_isready -U "${POSTGRES_USER}" -d "${POSTGRES_DB}"; then
        echo "✅ PostgreSQL is accepting connections"
        return 0
    else
        echo "❌ PostgreSQL is not ready"
        return 1
    fi
}

check_schema_accessible() {
    local schema_check=$(docker exec postgresql-local psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -tAc \
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
    local connections=$(docker exec postgresql-local psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -tAc \
        "SELECT count(*) FROM pg_stat_activity;")
    echo "   Active connections: $connections"
    
    # Database size
    local db_size=$(docker exec postgresql-local psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -tAc \
        "SELECT pg_size_pretty(pg_database_size('${POSTGRES_DB}'));")
    echo "   Database size: $db_size"
    
    # Uptime
    local uptime=$(docker exec postgresql-local psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -tAc \
        "SELECT date_trunc('second', now() - pg_postmaster_start_time());")
    echo "   Uptime: $uptime"
}

# Main health check
main() {
    echo "🏥 PostgreSQL Health Check (RFC-002)..."
    
    local exit_code=0
    
    check_container_running || exit_code=1
    check_database_ready || exit_code=1
    check_schema_accessible || exit_code=1
    check_performance
    
    if [ $exit_code -eq 0 ]; then
        echo "✅ PostgreSQL health check passed"
    else
        echo "❌ PostgreSQL health check failed"
    fi
    
    return $exit_code
}

main "$@"
```

### 4. Database Management Tools

#### Database Reset Script (scripts/reset-postgres.sh)
```bash
#!/bin/bash
# Reset PostgreSQL database cho development

set -euo pipefail

echo "🗑️  PostgreSQL Database Reset (RFC-002)"
echo "⚠️  This will destroy all data in the local database!"

# Confirmation prompt
read -p "Are you sure you want to reset the database? (type 'yes' to confirm): " -r
if [ "$REPLY" != "yes" ]; then
    echo "❌ Database reset cancelled"
    exit 0
fi

# Stop PostgreSQL service
echo "⏹️  Stopping PostgreSQL service..."
docker-compose stop postgresql-local

# Remove data volume
echo "🗑️  Removing data volume..."
docker volume rm postgres_data 2>/dev/null || echo "⚠️  Volume already removed"

# Recreate volume
echo "📦 Recreating data volume..."
docker volume create postgres_data

# Restart PostgreSQL service
echo "🚀 Starting PostgreSQL service..."
docker-compose up -d postgresql-local

# Wait for database to be ready
echo "⏳ Waiting for database initialization..."
sleep 10

# Validate reset
./scripts/validate-migrations.sh

echo "✅ PostgreSQL database reset completed"
```

## Acceptance Criteria

### F002: PostgreSQL Local Database
- [ ] PostgreSQL 15+ container running successfully
- [ ] Schema "n8n" created và accessible
- [ ] Database isolated hoàn toàn từ VPS database
- [ ] Persistent volume postgres_data mounted correctly
- [ ] Health check endpoint responding (pg_isready)
- [ ] Migration system functional
- [ ] Auto-migration từ database/ref/ working
- [ ] Database accessible via 172.20.0.10:5432
- [ ] Environment variables từ .env working
- [ ] Zero data loss on container restart
- [ ] Resource limits applied correctly
- [ ] Connection pooling configured
- [ ] Performance targets met (< 100ms query response)

## API Contracts & Interfaces

### Database Connection Interface
```yaml
Host: 172.20.0.10
Port: 5432
Database: ${POSTGRES_DB}
Schema: n8n
User: ${POSTGRES_USER}
Password: ${POSTGRES_PASSWORD}

Connection String Format:
postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@172.20.0.10:5432/${POSTGRES_DB}?schema=n8n
```

### Health Check Interface
```bash
# Container health check
docker exec postgresql-local pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}
# Exit codes: 0 = ready, 1 = not ready

# Schema validation
./scripts/validate-migrations.sh
# Exit codes: 0 = valid, 1 = invalid

# Performance check
./scripts/health-check-postgres.sh
# Exit codes: 0 = healthy, 1 = unhealthy
```

### Migration Interface
```sql
-- Migration tracking table
public.migration_log (
    id SERIAL PRIMARY KEY,
    script_name VARCHAR(255) UNIQUE,
    executed_at TIMESTAMP,
    checksum VARCHAR(64)
)

-- Schema context
SET search_path TO n8n;
```

## Performance Considerations

### Resource Optimization
- **Memory Limit:** 1GB max, 512MB reserved
- **CPU Limit:** 0.5 cores max, 0.25 cores reserved
- **Storage:** SSD recommended cho better I/O
- **Connection Pooling:** Built-in PostgreSQL pooling

### Query Performance
- **Target Response Time:** < 100ms cho basic queries
- **Index Strategy:** Auto-created by n8n migrations
- **Query Optimization:** EXPLAIN ANALYZE monitoring
- **Connection Management:** Persistent connections

### Monitoring Metrics
```sql
-- Key performance queries
SELECT * FROM pg_stat_activity;
SELECT * FROM pg_stat_database;
SELECT pg_size_pretty(pg_database_size('${POSTGRES_DB}'));
```

## Security Considerations

### Access Control
- **Network Isolation:** Internal Docker network only
- **Port Binding:** 127.0.0.1:5432 (localhost only)
- **Authentication:** Password-based với strong passwords
- **Schema Isolation:** Dedicated "n8n" schema

### Data Protection
- **Encryption:** At-rest encryption via Docker volumes
- **Backup Strategy:** Volume-based backups
- **Access Logging:** PostgreSQL built-in logging
- **Credential Management:** Environment variables only

### Security Validation
```bash
# Security check script
check_security() {
    # Verify no external exposure
    netstat -tlnp | grep :5432
    
    # Verify password strength
    [ ${#POSTGRES_PASSWORD} -ge 12 ]
    
    # Verify schema isolation
    psql -c "SHOW search_path;"
}
```

## Testing Strategy

### Unit Tests
- Container startup và health checks
- Migration script execution
- Schema creation validation
- Environment variable handling

### Integration Tests
- Database connectivity từ other containers
- Schema accessibility tests
- Performance benchmarking
- Data persistence validation

### Performance Tests
```bash
# Performance test script
performance_test() {
    # Connection time test
    time docker exec postgresql-local psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -c "SELECT 1;"
    
    # Query performance test
    docker exec postgresql-local psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -c "
        EXPLAIN ANALYZE SELECT * FROM information_schema.tables LIMIT 10;
    "
    
    # Concurrent connection test
    for i in {1..10}; do
        docker exec postgresql-local psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -c "SELECT pg_sleep(0.1);" &
    done
    wait
}
```

## Error Handling

### Common Error Scenarios
1. **Container startup failures**
   - Detection: Health check failures
   - Recovery: Container restart với exponential backoff

2. **Migration failures**
   - Detection: Migration script errors
   - Recovery: Rollback mechanism và manual intervention

3. **Connection failures**
   - Detection: pg_isready failures
   - Recovery: Connection retry với timeout

4. **Volume mounting issues**
   - Detection: Data persistence failures
   - Recovery: Volume recreation và data restoration

5. **Resource exhaustion**
   - Detection: Memory/CPU limit breaches
   - Recovery: Resource limit adjustment

### Error Recovery Mechanisms
```bash
# Auto-recovery script
recover_postgres() {
    echo "🔄 Attempting PostgreSQL recovery..."
    
    # Stop service
    docker-compose stop postgresql-local
    
    # Check volume integrity
    docker volume inspect postgres_data
    
    # Restart with clean state
    docker-compose up -d postgresql-local
    
    # Validate recovery
    ./scripts/validate-migrations.sh
}
```

## Future Considerations

### Scalability
- Read replica support cho performance
- Connection pooling optimization
- Partitioning strategy cho large tables
- Backup/restore automation

### Monitoring Integration
- PostgreSQL metrics export
- Performance dashboard integration
- Alert system cho critical issues
- Log aggregation setup

### Advanced Features
- Point-in-time recovery
- Automated backup scheduling
- Database migration versioning
- Performance tuning automation

## Implementation Notes

### Technical Decisions
1. **PostgreSQL 15 Alpine:** Balance of features và size
2. **Schema Isolation:** Prevents conflicts với VPS database
3. **Volume Persistence:** Ensures data durability
4. **Health Checks:** Proactive monitoring và recovery

### Assumptions
- Migration files available trong database/ref/
- Environment variables properly configured
- Docker foundation từ RFC-001 functional
- Sufficient host resources available

### Constraints
- Must be isolated từ VPS database
- Must support n8n schema requirements
- Must follow cursor_ai_rules cho environment management
- Must integrate với Docker foundation từ RFC-001

---

**RFC Status:** Ready for Implementation  
**Complexity:** Low  
**Estimated Effort:** 1 week  
**Previous RFC:** RFC-001 (Docker Foundation)  
**Next RFC:** RFC-003 (n8n Backend Local Service) 