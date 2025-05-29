# RFC-003: n8n Backend Local Service

## Summary
Thiết lập n8n container local cho test/debug workflows trong normal mode (KHÔNG queue mode). RFC này tạo n8n backend service kết nối với PostgreSQL local, với webhook configuration và API endpoints cho development environment.

## Features Addressed
- **F003:** n8n Backend Local Service (Must Have)

## Dependencies
- **Previous RFCs:** RFC-001 (Docker Foundation), RFC-002 (PostgreSQL Local)
- **External Dependencies:** n8n Docker image, PostgreSQL connection

## Builds Upon
- Docker orchestration system từ RFC-001
- PostgreSQL local database từ RFC-002
- n8n-local-network (172.20.0.20)
- Environment validation framework

## Enables Future RFCs
- **RFC-005:** Networking & Domain Infrastructure (requires n8n service to route)
- **RFC-006:** Data Management (requires n8n for workflow testing)

## Technical Approach

### Architecture Overview
```
n8n Backend Local Architecture:
├── n8n Container (latest, normal mode)
├── PostgreSQL Connection (172.20.0.10:5432)
├── Network: n8n-local-network (172.20.0.20)
├── Volume: n8n_data (workflows, credentials)
├── Environment: .env configuration
└── Health Checks: /healthz endpoint
```

## Detailed Implementation Specifications

### 1. n8n Service Configuration (docker-compose.core.yml)
```yaml
services:
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    
    environment:
      # Database configuration
      DB_TYPE: postgresdb
      DB_POSTGRESDB_HOST: postgres
      DB_POSTGRESDB_PORT: 5432
      DB_POSTGRESDB_DATABASE: ${POSTGRES_DB}
      DB_POSTGRESDB_USER: ${POSTGRES_USER}
      DB_POSTGRESDB_PASSWORD: ${POSTGRES_PASSWORD}
      DB_POSTGRESDB_SCHEMA: n8n
      
      # n8n configuration
      N8N_HOST: ${N8N_HOST}
      N8N_PROTOCOL: https
      N8N_PORT: 5678
      WEBHOOK_URL: https://${N8N_HOST}/
      
      # Execution mode (NORMAL, not queue)
      EXECUTIONS_MODE: regular
      
      # Security
      N8N_ENCRYPTION_KEY: ${N8N_ENCRYPTION_KEY}
      
    volumes:
      - n8n_data:/home/node/.n8n
      
    networks:
      n8n-local-network:
        ipv4_address: 172.20.0.20
        
    ports:
      - "127.0.0.1:5678:5678"
      
    depends_on:
      postgres:
        condition: service_healthy
        
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:5678/healthz || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
```

### 2. Health Check Script (scripts/health-check-n8n.sh)
```bash
#!/bin/bash
# n8n Backend health monitoring

set -euo pipefail

check_n8n_api() {
    if curl -f http://172.20.0.20:5678/healthz; then
        echo "✅ n8n API is responding"
        return 0
    else
        echo "❌ n8n API is not responding"
        return 1
    fi
}

check_database_connection() {
    # Test database connectivity through n8n
    local response=$(curl -s http://172.20.0.20:5678/rest/settings || echo "error")
    if [[ "$response" != "error" ]]; then
        echo "✅ n8n database connection working"
        return 0
    else
        echo "❌ n8n database connection failed"
        return 1
    fi
}

main() {
    echo "🏥 n8n Backend Health Check (RFC-003)..."
    
    local exit_code=0
    check_n8n_api || exit_code=1
    check_database_connection || exit_code=1
    
    return $exit_code
}

main "$@"
```

## Acceptance Criteria

### F003: n8n Backend Local Service
- [ ] n8n latest container running successfully
- [ ] Normal mode (không queue mode) configured
- [ ] PostgreSQL local connection working
- [ ] API endpoints responding (< 500ms)
- [ ] Webhook configuration functional
- [ ] Environment variables từ .env working
- [ ] Health check endpoint /healthz responding
- [ ] Volume n8n_data mounted correctly
- [ ] Access via 172.20.0.20:5678
- [ ] Database schema "n8n" accessible
- [ ] Workflow import/export functional

---

**RFC Status:** Ready for Implementation  
**Complexity:** Medium  
**Estimated Effort:** 1-2 weeks  
**Previous RFC:** RFC-002 (PostgreSQL Local)  
**Next RFC:** RFC-004 (NocoDB Interface) 