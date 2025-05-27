# RFC-006: Data Management & n8n Worker Local

## Summary
Thiết lập mock data generation và n8n Worker Local cho hybrid processing. RFC này tạo data management system với 50-200 records/table và n8n worker local kết nối VPS Redis + PostgreSQL với auto-scaling capability.

## Features Addressed
- **F005:** Mock Data Generation (Should Have)
- **F009:** n8n Worker Local (Must Have)

## Dependencies
- **Previous RFCs:** RFC-001 (Docker Foundation), RFC-002 (PostgreSQL Local), RFC-005 (Networking)
- **External Dependencies:** VPS Redis (103.110.57.247:6379), VPS PostgreSQL

## Builds Upon
- Complete local infrastructure từ RFC-001 đến RFC-005
- n8n-local-network (172.20.0.60)
- Networking infrastructure cho VPS connectivity

## Enables Future RFCs
- Complete system functionality (Final RFC)

## Technical Approach

### Architecture Overview
```
Data Management & n8n Worker Architecture:
├── Mock Data Generation Scripts
│   ├── 50-200 records per table
│   ├── Realistic data patterns
│   └── Queue system & user-tier support
├── n8n Worker Local (172.20.0.60)
│   ├── Queue mode enabled
│   ├── VPS Redis connection (103.110.57.247:6379)
│   ├── VPS PostgreSQL connection
│   ├── Auto-scaling mechanism
│   └── Callback URLs → n8n.masteryflow.cc
```

## Detailed Implementation Specifications

### 1. Mock Data Generation (scripts/generate-mock-data.sh)
```bash
#!/bin/bash
# Generate mock data cho development testing

set -euo pipefail

generate_users() {
    echo "👥 Generating user data..."
    docker exec postgresql-local psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -c "
        INSERT INTO n8n.users (email, firstName, lastName, password, globalRole)
        SELECT 
            'user' || generate_series(1,100) || '@example.com',
            'User' || generate_series(1,100),
            'Test' || generate_series(1,100),
            '\$2b\$10\$hash',
            CASE WHEN generate_series(1,100) % 10 = 0 THEN 'admin' ELSE 'user' END;
    "
}

generate_workflows() {
    echo "🔄 Generating workflow data..."
    # Generate 50-200 workflows với realistic patterns
}

generate_executions() {
    echo "⚡ Generating execution data..."
    # Generate execution history với various statuses
}

main() {
    echo "📊 Generating Mock Data (RFC-006)..."
    generate_users
    generate_workflows
    generate_executions
    echo "✅ Mock data generation completed"
}

main "$@"
```

### 2. n8n Worker Local Configuration (docker-compose.worker.yml)
```yaml
services:
  n8n-worker:
    image: n8nio/n8n:latest
    container_name: n8n-worker
    restart: unless-stopped
    
    environment:
      # Worker mode configuration
      EXECUTIONS_MODE: queue
      QUEUE_BULL_REDIS_HOST: 103.110.57.247
      QUEUE_BULL_REDIS_PORT: 6379
      
      # VPS Database connection
      DB_TYPE: postgresdb
      DB_POSTGRESDB_HOST: ${VPS_POSTGRES_HOST}
      DB_POSTGRESDB_PORT: 5432
      DB_POSTGRESDB_DATABASE: ${VPS_POSTGRES_DB}
      DB_POSTGRESDB_USER: ${VPS_POSTGRES_USER}
      DB_POSTGRESDB_PASSWORD: ${VPS_POSTGRES_PASSWORD}
      DB_POSTGRESDB_SCHEMA: n8n
      
      # Worker configuration
      N8N_ENCRYPTION_KEY: ${N8N_ENCRYPTION_KEY}
      WEBHOOK_URL: https://n8n.masteryflow.cc/
      
      # Auto-scaling
      QUEUE_WORKER_TIMEOUT: 120
      
    networks:
      n8n-local-network:
        ipv4_address: 172.20.0.60
        
    depends_on:
      - nginx-proxy
      
    healthcheck:
      test: ["CMD-SHELL", "ps aux | grep -v grep | grep n8n || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
```

### 3. Auto-scaling Script (scripts/autoscale-worker.sh)
```bash
#!/bin/bash
# Auto-scaling mechanism cho n8n worker

set -euo pipefail

check_queue_backlog() {
    # Check Redis queue length
    local queue_length=$(redis-cli -h 103.110.57.247 -p 6379 llen bull:n8n:waiting 2>/dev/null || echo "0")
    echo "$queue_length"
}

scale_workers() {
    local queue_length=$1
    
    if [ "$queue_length" -gt 50 ]; then
        echo "🔄 High queue backlog ($queue_length), scaling up..."
        docker-compose -f docker-compose.worker.yml up -d --scale n8n-worker=3
    elif [ "$queue_length" -lt 10 ]; then
        echo "📉 Low queue backlog ($queue_length), scaling down..."
        docker-compose -f docker-compose.worker.yml up -d --scale n8n-worker=1
    fi
}

main() {
    local queue_length=$(check_queue_backlog)
    echo "📊 Queue backlog: $queue_length jobs"
    scale_workers "$queue_length"
}

main "$@"
```

## Acceptance Criteria

### F005: Mock Data Generation
- [ ] Script generate 50-200 records per table
- [ ] Realistic data patterns implemented
- [ ] Queue system tables populated
- [ ] User-tier tables populated (Free, Pro, Premium, VIP)
- [ ] Idempotent execution working
- [ ] Data reset functionality available
- [ ] Performance targets met (< 5 minutes generation)

### F009: n8n Worker Local
- [ ] n8n worker latest container running
- [ ] Queue mode enabled và functional
- [ ] VPS Redis connection working (103.110.57.247:6379)
- [ ] VPS PostgreSQL connection working
- [ ] Auto-scaling mechanism functional
- [ ] Credentials sync từ VPS working
- [ ] Callback URLs pointing to n8n.masteryflow.cc
- [ ] Worker health monitoring working
- [ ] Error handling và retry logic implemented

---

**RFC Status:** Ready for Implementation  
**Complexity:** High  
**Estimated Effort:** 2-3 weeks  
**Previous RFC:** RFC-005 (Networking & Domain)  
**Next RFC:** None (Final RFC) 