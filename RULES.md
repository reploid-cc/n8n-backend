# Development Rules & Guidelines
## n8n Backend Infrastructure - Local Development Environment

---

## 📋 Project Overview

**Dự án:** Hệ thống backend infrastructure hoàn chỉnh cho n8n workflow automation chạy 100% Docker tại localhost  
**Kiến trúc:** Microservices với Docker Compose, hybrid worker architecture  
**Mục tiêu:** Môi trường test/debug local nhanh hơn VPS ≥50%, với n8n worker local kết nối VPS production  
**Người dùng:** Solo Developer (Advanced level)  
**Phương pháp:** Agile development, 4 phases implementation  

---

## 🏗️ Technology Stack Definition

### Core Technologies (MUST USE)
```yaml
Container Platform:
  - Docker: latest
  - Docker Compose: latest

Database:
  - PostgreSQL: latest (alpine variant preferred)
  - Schema: "n8n" (isolated from VPS)

Backend Services:
  - n8n Local: latest (normal mode, no queue)
  - n8n Worker Local: latest (queue mode, VPS connection)

UI & Management:
  - NocoDB: latest
  - nginx: latest (alpine variant)
  - cloudflared: latest

Infrastructure:
  - Redis VPS: Existing (103.110.87.247:6379)
  - PostgreSQL VPS: Existing (shared database)
```

### Development Tools
```yaml
Scripting:
  - Bash scripts cho automation
  - Cross-platform compatibility (Windows/Linux/Mac)

Configuration:
  - .env files cho environment variables
  - YAML cho Docker Compose
  - JSON cho configuration files

Documentation:
  - Markdown cho tất cả documentation
  - Inline comments cho complex logic
```

---

## 🎯 Technical Preferences

### Naming Conventions

#### Files & Directories
```bash
# Docker Compose files
docker-compose.yml              # Main orchestration
docker-compose.core.yml         # Core services
docker-compose.ui.yml           # UI services  
docker-compose.network.yml      # Network services
docker-compose.worker.yml       # Worker services

# Scripts
scripts/setup.sh               # Main setup script
scripts/cleanup.sh             # Cleanup script
scripts/generate-mock-data.sh   # Data generation
scripts/health-check.sh         # Health monitoring

# Configuration
nginx/nginx.conf               # nginx configuration
cloudflared/config.yml         # Cloudflare tunnel config
database/migrations/           # Database migration files
```

#### Environment Variables
```bash
# Naming pattern: COMPONENT_CATEGORY_SPECIFIC
POSTGRES_DB=n8n_local
POSTGRES_USER=n8n_user
POSTGRES_PASSWORD=secure_password

# n8n specific
N8N_HOST=n8n.ai-automation.cloud
N8N_PROTOCOL=https
N8N_ENCRYPTION_KEY=your_key_here

# Domain configuration
BASE_DOMAIN=ai-automation.cloud
DOMAIN_NAME=n8n.ai-automation.cloud
```

#### Container & Service Names
```yaml
# Pattern: component (shortened names)
services:
  postgres:            # PostgreSQL cho n8n local
  n8n:                 # n8n local backend
  n8n-worker:          # n8n worker local
  nocodb:              # NocoDB interface
  nginx:               # nginx reverse proxy
  cloudflared:         # Cloudflare tunnel
```

### Code Organization

#### Directory Structure
```
n8n-backend/
├── docker-compose.yml
├── docker-compose.core.yml
├── docker-compose.ui.yml
├── docker-compose.network.yml
├── docker-compose.worker.yml
├── .env
├── env.local.txt              # Local environment reference
├── env.vps.txt                # VPS environment reference
├── README.md
├── RULES.md
├── PRD.md
├── prd-improved.md
├── features.md
├── scripts/
│   ├── setup.sh
│   ├── cleanup.sh
│   ├── generate-mock-data.sh
│   ├── health-check.sh
│   └── validate-env.sh
├── nginx/
│   ├── nginx.conf
│   ├── ssl/
│   └── logs/
├── cloudflared/
│   ├── config.yml
│   └── credentials/
├── database/
│   ├── migrations/
│   ├── seeds/
│   └── ref/                   # Reference migration files
├── docs/
│   ├── setup-guide.md
│   ├── troubleshooting.md
│   └── api-documentation.md
└── logs/
    ├── docker/
    ├── nginx/
    └── application/
```

### Architectural Patterns

#### Service Architecture
```yaml
# Microservices pattern với clear separation
Local Development Stack:
  - PostgreSQL Local (isolated database)
  - n8n Local (normal mode, fast development)
  - NocoDB (database UI)
  - nginx (reverse proxy)
  - cloudflared (external access)

Hybrid Worker Stack:
  - n8n Worker Local (queue mode)
  - Redis VPS connection (103.110.87.247)
  - PostgreSQL VPS connection (shared)
```

#### Network Architecture
```yaml
# Docker networks với proper isolation
networks:
  n8n-local-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.21.0.0/16

# Static IP assignments
postgres: 172.21.0.10
n8n: 172.21.0.20
nocodb: 172.21.0.30
nginx: 172.21.0.40
cloudflared: 172.21.0.50
n8n-worker: 172.21.0.60
```

---

## 🔧 Development Standards

### Docker Standards

#### Container Configuration
```yaml
# MUST include cho mọi service
healthcheck:
  test: ["CMD", "appropriate-health-check"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s

# MUST include cho data services
volumes:
  - service_data:/data/path
  
# MUST include cho dependent services
depends_on:
  dependency:
    condition: service_healthy

# MUST use cho production-ready
restart: unless-stopped
```

#### Volume Management
```yaml
# Naming pattern: servicename_datatype
volumes:
  postgres_data:
    driver: local
  n8n_data:
    driver: local
  nginx_logs:
    driver: local
  cloudflared_config:
    driver: local
```

### Environment Management

#### .env File Rules
```bash
# MUST follow cursor_ai_rules
# - Không tự ý tạo hoặc sửa .env
# - Chỉ cập nhật env.txt và báo user
# - Tất cả changes phải được approve

# MUST include validation
if [ ! -f .env.local ]; then
    echo "❌ .env.local file not found. Please create from env.local.txt"
    exit 1
fi

# MUST validate required variables
required_vars=("POSTGRES_DB" "POSTGRES_USER" "POSTGRES_PASSWORD")
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "❌ Required variable $var is not set"
        exit 1
    fi
done
```

### Performance Requirements

#### Response Time Standards
```yaml
Service Performance Targets:
  - n8n API response: < 500ms
  - Database queries: < 100ms
  - UI responsiveness: < 2 seconds
  - Domain resolution: < 1 second
  - Container startup: < 2 minutes total
  - Setup process: < 30 minutes
```

#### Resource Optimization
```yaml
Memory Limits:
  - postgres: 1GB
  - n8n: 2GB
  - n8n-worker: 2GB
  - nocodb: 512MB
  - nginx: 256MB
  - cloudflared: 256MB

CPU Limits:
  - Total system usage: < 50% average
  - Individual service: < 25% per service
```

### Security Practices

#### Network Security
```yaml
# MUST implement
- Internal Docker networks only
- No direct external access to databases
- nginx as single entry point
- SSL/HTTPS for all external access

# MUST NOT implement
- Direct database port exposure
- Unencrypted external connections
- Default passwords
- Hardcoded credentials
```

#### Credential Management
```bash
# MUST use environment variables
DB_PASSWORD=${POSTGRES_PASSWORD}

# MUST NOT use hardcoded values
# DB_PASSWORD=hardcoded_password  # ❌ NEVER

# MUST validate credential strength
if [ ${#POSTGRES_PASSWORD} -lt 12 ]; then
    echo "❌ Password must be at least 12 characters"
    exit 1
fi
```

---

## 🧪 Testing Requirements

### Health Check Standards
```bash
# MUST implement cho mọi service
postgres_health_check() {
    docker exec postgres pg_isready -U ${POSTGRES_USER}
}

n8n_health_check() {
    curl -f http://localhost:5678/healthz || exit 1
}

redis_health_check() {
    docker exec redis redis-cli ping
}
```

### Integration Testing
```yaml
Test Categories:
  - Service startup sequence
  - Database connectivity
  - API endpoint functionality
  - Domain routing
  - SSL certificate validation
  - Worker VPS connectivity

Success Criteria:
  - All services healthy
  - All endpoints responding
  - Data persistence verified
  - Performance targets met
```

### Error Handling Standards
```bash
# MUST implement comprehensive error handling
set -euo pipefail  # Exit on error, undefined vars, pipe failures

error_handler() {
    echo "❌ Error occurred in script at line $1"
    cleanup_on_error
    exit 1
}
trap 'error_handler $LINENO' ERR

# MUST provide meaningful error messages
if ! docker --version &> /dev/null; then
    echo "❌ Docker is not installed or not running"
    echo "📋 Please install Docker and try again"
    exit 1
fi
```

---

## 📊 Implementation Priorities

### Phase-based Development
```yaml
Phase 1 (CRITICAL - Must Have):
  - F001: Docker Orchestration System
  - F002: PostgreSQL Local Database
  - F003: n8n Backend Local Service
  - F004: Setup Automation Scripts

Phase 2 (HIGH - Should Have):
  - F006: NocoDB Database Interface
  - F007: Nginx Reverse Proxy
  - F008: Cloudflared Tunnel Service

Phase 3 (MEDIUM - Should Have):
  - F005: Mock Data Generation
  - F010: Environment Configuration Management

Phase 4 (CRITICAL - Must Have):
  - F009: n8n Worker Local
```

### Quality Thresholds
```yaml
Minimum Acceptance Criteria:
  - All health checks passing
  - Setup time < 30 minutes
  - API response time < 500ms
  - Zero data loss on restart
  - 100% environment validation
  - Complete documentation

Performance Gates:
  - Load testing passed
  - Memory usage within limits
  - CPU usage within limits
  - Network connectivity stable
```

---

## 📝 Documentation Standards

### Code Documentation
```bash
# MUST include function headers
#######################################
# Setup PostgreSQL local database
# Globals:
#   POSTGRES_DB, POSTGRES_USER, POSTGRES_PASSWORD
# Arguments:
#   None
# Returns:
#   0 if successful, 1 on error
#######################################
setup_postgresql() {
    # Implementation
}
```

### Configuration Documentation
```yaml
# MUST document all configuration options
services:
  postgres:
    # PostgreSQL container cho n8n local development
    # Isolated từ VPS database để tránh conflicts
    image: postgres:latest
    environment:
      # Database credentials từ .env file
      POSTGRES_DB: ${POSTGRES_DB}
```

### README Requirements
```markdown
# MUST include trong mọi README
## Prerequisites
## Quick Start
## Configuration
## Troubleshooting
## API Documentation
## Contributing Guidelines
```

---

## 🚨 General Guidelines

### Requirement Adherence
```yaml
MUST Follow:
  - PRD specifications exactly
  - Feature acceptance criteria completely
  - Performance targets precisely
  - Security requirements strictly

MUST NOT:
  - Deviate from specified architecture
  - Skip health checks
  - Use hardcoded values
  - Ignore error handling
```

### Code Quality Standards
```bash
# MUST implement
- Comprehensive error handling
- Meaningful variable names
- Clear function documentation
- Consistent formatting
- No TODO comments in production
- No placeholder implementations

# Code review checklist
- [ ] All functions documented
- [ ] Error handling implemented
- [ ] Health checks included
- [ ] Performance optimized
- [ ] Security validated
```

### Communication Guidelines
```yaml
When to Ask Questions:
  - Requirements unclear or ambiguous
  - Technical constraints discovered
  - Performance targets unachievable
  - Security concerns identified
  - Integration issues found

How to Ask:
  - Specific technical details
  - Proposed solutions included
  - Impact assessment provided
  - Alternative approaches suggested
```

### Uncertainty Handling
```bash
# When facing ambiguity
1. Check PRD and features.md first
2. Look for similar patterns in codebase
3. Choose most conservative approach
4. Document assumptions made
5. Ask for clarification if critical

# Example
# ASSUMPTION: Using latest PostgreSQL version
# REASON: PRD specifies "latest" for all components
# IMPACT: May need version lock for stability
```

---

## 🔄 Maintenance & Updates

### Version Management
```yaml
Update Strategy:
  - Use latest stable versions
  - Test compatibility before updating
  - Document version changes
  - Maintain backward compatibility

Monitoring:
  - Regular health checks
  - Performance monitoring
  - Error rate tracking
  - Resource usage monitoring
```

### Backup & Recovery
```bash
# MUST implement
- Automated PostgreSQL backups
- Configuration file backups
- Recovery procedures documented
- Disaster recovery tested

# Backup schedule
daily_backup() {
    docker exec postgres pg_dump -U ${POSTGRES_USER} ${POSTGRES_DB} > backup_$(date +%Y%m%d).sql
}
```

---

## ✅ Compliance Checklist

### Before Implementation
- [ ] PRD requirements understood
- [ ] Features acceptance criteria clear
- [ ] Technical architecture approved
- [ ] Environment setup validated
- [ ] Dependencies identified

### During Development
- [ ] Code quality standards met
- [ ] Error handling implemented
- [ ] Health checks included
- [ ] Documentation updated
- [ ] Performance targets monitored

### Before Deployment
- [ ] All tests passing
- [ ] Performance benchmarks met
- [ ] Security validation complete
- [ ] Documentation complete
- [ ] Backup procedures tested

---

**Document Version:** 1.0  
**Created:** 2024  
**Last Updated:** 2024  
**Status:** Active Development Guidelines  
**Compliance:** Mandatory for all development work