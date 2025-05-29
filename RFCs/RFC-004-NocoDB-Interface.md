# RFC-004: NocoDB Database Interface

## Summary
Thiết lập NocoDB container để cung cấp web-based UI cho PostgreSQL database management. RFC này tạo database interface cho CRUD operations, schema visualization, và data management.

## Features Addressed
- **F006:** NocoDB Database Interface (Should Have)

## Dependencies
- **Previous RFCs:** RFC-001 (Docker Foundation), RFC-002 (PostgreSQL Local)
- **External Dependencies:** NocoDB Docker image

## Builds Upon
- Docker orchestration system từ RFC-001
- PostgreSQL local database từ RFC-002
- n8n-local-network (172.20.0.30)

## Enables Future RFCs
- **RFC-005:** Networking & Domain Infrastructure (requires NocoDB service to route)

## Technical Approach

### Architecture Overview
```
NocoDB Interface Architecture:
├── NocoDB Container (latest)
├── PostgreSQL Connection (172.20.0.10:5432)
├── Network: n8n-local-network (172.20.0.30)
├── UI Access: nocodb.ai-automation.cloud
└── Health Checks: HTTP endpoint
```

## Detailed Implementation Specifications

### 1. NocoDB Service Configuration (docker-compose.ui.yml)
```yaml
services:
  nocodb:
    image: nocodb/nocodb:latest
    container_name: nocodb
    restart: unless-stopped
    
    environment:
      NC_DB: "pg://postgres:5432?u=${POSTGRES_USER}&p=${POSTGRES_PASSWORD}&d=${POSTGRES_DB}"
      NC_AUTH_JWT_SECRET: ${NC_AUTH_JWT_SECRET}
      NC_PUBLIC_URL: https://nocodb.${BASE_DOMAIN}
      
    networks:
      n8n-local-network:
        ipv4_address: 172.20.0.30
        
    ports:
      - "127.0.0.1:8080:8080"
      
    depends_on:
      postgres:
        condition: service_healthy
        
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:8080/api/v1/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
```

## Acceptance Criteria

### F006: NocoDB Database Interface
- [ ] NocoDB latest container running successfully
- [ ] PostgreSQL connection working
- [ ] UI accessible via 172.20.0.30:8080
- [ ] CRUD operations functional
- [ ] Schema visualization working
- [ ] Health check endpoint responding
- [ ] Environment variables từ .env working

---

**RFC Status:** Ready for Implementation  
**Complexity:** Low  
**Estimated Effort:** 1 week  
**Previous RFC:** RFC-003 (n8n Backend Local)  
**Next RFC:** RFC-005 (Networking & Domain) 