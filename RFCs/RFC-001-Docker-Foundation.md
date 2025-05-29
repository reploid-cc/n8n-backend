# RFC-001: Docker Foundation & Environment Setup

## Summary
Thiết lập Docker foundation infrastructure với cleanup strategy, environment management, và network architecture. RFC này tạo nền tảng cho toàn bộ hệ thống với multiple Docker Compose files, volume management, và comprehensive cleanup procedures.

## Features Addressed
- **F001:** Docker Orchestration System (Must Have)
- **F004:** Setup Automation Scripts (Must Have)
- **F010:** Environment Configuration Management (Should Have)

## Dependencies
- **Previous RFCs:** None (Foundation RFC)
- **External Dependencies:** Docker, Docker Compose, .env file

## Builds Upon
- Clean system state (all previous containers/volumes removed)
- Fresh Docker environment
- Validated .env configuration

## Enables Future RFCs
- **RFC-002:** PostgreSQL Local Database (requires Docker foundation)
- **RFC-003:** n8n Backend Local Service (requires Docker foundation)
- **RFC-004:** NocoDB Database Interface (requires Docker foundation)
- **RFC-005:** Networking & Domain Infrastructure (requires Docker foundation)
- **RFC-006:** Data Management & n8n Worker Local (requires Docker foundation)

## Technical Approach

### Architecture Overview
```
Docker Foundation Architecture:
├── Cleanup Strategy (Remove old containers/volumes/images)
├── Multiple Docker Compose Files Structure
│   ├── docker-compose.yml (Main orchestration)
│   ├── docker-compose.core.yml (PostgreSQL, n8n local)
│   ├── docker-compose.ui.yml (NocoDB)
│   ├── docker-compose.network.yml (nginx, cloudflared)
│   └── docker-compose.worker.yml (n8n worker)
├── Docker Network: n8n-local-network (172.20.0.0/16)
├── Volume Management System
├── Environment Validation Framework
└── Setup Automation Scripts
```

### Database Schema Overview & Connections
```
Database Architecture & Schema (VPS Production Schema - 2024-12-01):
┌─────────────────────────────────────────────────────────────┐
│                    PostgreSQL Local                        │
│                   Schema: "n8n"                           │
│              VPS PRODUCTION SCHEMA CLONED                  │
│                 16 Tables + 88 Indexes                     │
├─────────────────────────────────────────────────────────────┤
│  Core User & Auth Tables:                                 │
│  ├── users (id, username, email, password_hash, tier,     │
│  │           credits_balance, is_active, created_at,      │
│  │           updated_at, last_login_at)                   │
│  │           Tier: free, pro, premium, vip               │
│  └── user_oauth (id, user_id, provider, provider_user_id, │
│                  access_token, refresh_token, expires_at, │
│                  profile_data, created_at, updated_at)    │
├─────────────────────────────────────────────────────────────┤
│  Workflow Management Tables:                              │
│  ├── workflows (id, name, description, slug, category,    │
│  │              n8n_workflow_id, is_public, is_featured,  │
│  │              tier_required, creator_id, tags,          │
│  │              configuration, created_at, updated_at)    │
│  ├── workflow_versions (id, workflow_id, version,         │
│  │                      configuration, form_schema,       │
│  │                      is_active, created_at)            │
│  └── user_workflow_favorites (id, user_id, workflow_id,   │
│                               created_at)                 │
├─────────────────────────────────────────────────────────────┤
│  Tier & Limits System:                                    │
│  ├── workflow_tier_limits (id, workflow_id, tier,         │
│  │                         limit_unit, limit_value,       │
│  │                         created_at, updated_at)        │
│  └── vip_custom_limits (id, user_id, workflow_id,         │
│                         limit_unit, limit_value,          │
│                         expires_at, created_at,           │
│                         updated_at)                       │
├─────────────────────────────────────────────────────────────┤
│  Execution & Logging Tables:                              │
│  ├── log_workflow_executions (id, workflow_id, user_id,   │
│  │                            n8n_execution_id, status,   │
│  │                            worker_container_id,        │
│  │                            start_time, end_time,       │
│  │                            execution_time_ms,          │
│  │                            input_data, output_data,    │
│  │                            error_message, created_at)  │
│  ├── log_user_activities (id, user_id, activity_type,     │
│  │                        session_id, ip_address,         │
│  │                        user_agent, activity_data,      │
│  │                        created_at)                     │
│  ├── log_workflow_changes (id, workflow_id, user_id,      │
│  │                         change_type, old_data,         │
│  │                         new_data, created_at)          │
│  ├── log_transactions (id, user_id, transaction_type,     │
│  │                     amount, currency, status,          │
│  │                     payment_id, payment_method,        │
│  │                     transaction_data, created_at)      │
│  ├── log_usage (id, user_id, resource_type, resource_id,  │
│  │              usage_count, credits_consumed,            │
│  │              usage_date, created_at)                   │
│  └── worker_logs (id, container_id, container_name,       │
│                   worker_status, cpu_usage, memory_usage, │
│                   logged_at, created_at)                  │
├─────────────────────────────────────────────────────────────┤
│  Order & Payment Tables:                                  │
│  └── orders (id, user_id, workflow_id, order_type,        │
│              purchase_date, expiry_date, is_active,       │
│              amount, currency, payment_status,            │
│              transaction_id, created_at, updated_at)      │
├─────────────────────────────────────────────────────────────┤
│  Community & Feedback Tables:                             │
│  ├── comments (id, user_id, target_type, target_id,       │
│  │              content, parent_comment_id,               │
│  │              created_at, updated_at)                   │
│  └── ratings (id, user_id, workflow_id, rating,           │
│                review, created_at, updated_at)            │
│                UNIQUE(user_id, workflow_id)               │
├─────────────────────────────────────────────────────────────┤
│  Performance Optimization (88 Indexes):                   │
│  ├── Primary Keys: 16 indexes (1 per table)              │
│  ├── Unique Constraints: 8 indexes                       │
│  │   ├── users_email_key, users_username_key             │
│  │   ├── ratings_user_id_workflow_id_key                 │
│  │   ├── user_oauth_provider_provider_user_id_key        │
│  │   ├── user_workflow_favorites_user_id_workflow_id_key │
│  │   ├── vip_custom_limits_user_id_workflow_id_limit_... │
│  │   ├── workflow_tier_limits_workflow_id_tier_limit_... │
│  │   └── workflow_versions_workflow_id_version_key       │
│  ├── Performance Indexes: 64 indexes                     │
│  │   ├── Foreign Key Indexes (user_id, workflow_id, etc)│
│  │   ├── Date/Time Indexes (created_at, logged_at, etc) │
│  │   ├── Status Indexes (tier, status, is_active, etc)  │
│  │   ├── Search Indexes (email, username, category)     │
│  │   └── Composite Indexes (multi-column optimization)  │
│  └── Advanced Features:                                   │
│      ├── GIN Indexes cho JSONB fields                    │
│      ├── Partial Indexes cho conditional queries         │
│      └── Composite Indexes cho complex queries           │
├─────────────────────────────────────────────────────────────┤
│  System Monitoring Views:                                 │
│  ├── v_data_summary (table_name, record_count,           │
│  │                   description)                        │
│  ├── v_database_health (metric, value)                   │
│  │   ├── total_tables: 19                               │
│  │   ├── total_indexes: 88                              │
│  │   └── database_size: 16 MB                           │
│  └── v_system_status (component, status, last_check)     │
└─────────────────────────────────────────────────────────────┘

Connection Flow:
PostgreSQL Local (172.21.0.10:5432) ←→ n8n Local (172.21.0.20:5678)
PostgreSQL Local (172.21.0.10:5432) ←→ NocoDB (172.21.0.30:8080)
VPS Redis (103.110.87.247:6379) ←→ n8n Worker (172.21.0.60)
VPS PostgreSQL ←→ n8n Worker (172.21.0.60)

Migration Status: ✅ VPS Schema Cloned (2024-12-01)
- 16 Production Tables Migrated
- 88 Performance Indexes Created  
- 3 System Views Functional
- 100% Data Integrity Preserved
```

### Service Port & URL Mapping
```
┌─────────────────────────────────────────────────────────────┐
│                    Port & URL Reference                    │
├─────────────────────────────────────────────────────────────┤
│ Service     │ URL Local                │ URL Tunnel         │
│             │                          │                    │
│ n8n Local   │ http://localhost:5678    │ https://n8n.ai-   │
│             │                          │ automation.cloud   │
│             │                          │                    │
│ NocoDB      │ http://localhost:8080    │ https://nocodb.ai- │
│             │                          │ automation.cloud   │
│             │                          │                    │
│ PostgreSQL  │ localhost:5432           │ Internal only      │
│             │                          │                    │
│ nginx       │ localhost:80,443         │ Proxy only         │
│             │                          │                    │
│ Worker      │ Internal only            │ VPS connection     │
├─────────────────────────────────────────────────────────────┤
│ Docker Network IPs (n8n-local-network):                   │
│ ├── PostgreSQL Local: 172.21.0.10:5432                    │
│ ├── n8n Backend: 172.21.0.20:5678                         │
│ ├── NocoDB UI: 172.21.0.30:8080                           │
│ ├── nginx Proxy: 172.21.0.40:80,443                       │
│ ├── cloudflared: 172.21.0.50                              │
│ └── n8n Worker: 172.21.0.60                               │
├─────────────────────────────────────────────────────────────┤
│ Database Schema Status:                                    │
│ ├── Schema: "n8n" (VPS Production Clone)                  │
│ ├── Tables: 16 production tables                          │
│ ├── Indexes: 88 performance indexes                       │
│ ├── Views: 3 system monitoring views                      │
│ └── Migration: ✅ Complete (2024-12-01)                   │
└─────────────────────────────────────────────────────────────┘
```

## Detailed Implementation Specifications

### 1. Comprehensive Cleanup Strategy

#### Pre-Implementation Cleanup Script (scripts/cleanup-all.sh)
```bash
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
docker rm -f postgres n8n nocodb nginx cloudflared n8n-worker 2>/dev/null || echo "Containers already removed"

# Remove volumes (excluding redis_data which doesn't exist locally)
echo "📦 Removing all volumes..."
docker volume rm postgres_data n8n_data nginx_logs cloudflared_config 2>/dev/null || echo "Volumes already removed"

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
```

#### Selective Cleanup Script (scripts/cleanup-n8n.sh)
```bash
#!/bin/bash
# Selective cleanup cho n8n project only

set -euo pipefail

echo "🧹 n8n Project Cleanup (RFC-001)"

# Stop n8n related containers
echo "⏹️  Stopping n8n containers..."
docker-compose down --remove-orphans 2>/dev/null || echo "No compose services running"

# Remove n8n specific containers
echo "🗑️  Removing n8n containers..."
docker rm -f postgres n8n nocodb nginx cloudflared n8n-worker 2>/dev/null || echo "Containers already removed"

# Remove n8n specific volumes
echo "📦 Removing n8n volumes..."
docker volume rm postgres_data n8n_data nginx_logs cloudflared_config 2>/dev/null || echo "Volumes already removed"

# Remove n8n network
echo "🌐 Removing n8n network..."
docker network rm n8n-local-network 2>/dev/null || echo "Network already removed"

echo "✅ n8n project cleanup completed!"
```

### 2. Docker Compose Structure

#### Main Orchestration (docker-compose.yml)
```yaml
version: '3.8'

# Main orchestration file - defines shared resources
networks:
  n8n-local-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
          gateway: 172.20.0.1

volumes:
  # Core data volumes
  postgres_data:
    driver: local
    name: postgres_data
  n8n_data:
    driver: local
    name: n8n_data
  nginx_logs:
    driver: local
    name: nginx_logs
  cloudflared_config:
    driver: local
    name: cloudflared_config

# Include other compose files
# Usage: docker-compose -f docker-compose.yml -f docker-compose.core.yml up -d
```

#### Core Services (docker-compose.core.yml)
```yaml
version: '3.8'

services:
  postgres:
    image: postgres:latest
    container_name: postgres
    restart: unless-stopped
    
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_INITDB_ARGS: "--encoding=UTF8 --locale=C"
      
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database/migrations:/docker-entrypoint-initdb.d:ro
      - ./database/ref:/docker-entrypoint-ref:ro
      
    networks:
      n8n-local-network:
        ipv4_address: 172.20.0.10
        
    ports:
      - "127.0.0.1:5432:5432"
      
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
      
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '0.5'

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

networks:
  n8n-local-network:
    external: true

volumes:
  postgres_data:
    external: true
  n8n_data:
    external: true
```

### 3. Environment Management System

#### Environment Validation Script (scripts/validate-env.sh)
```bash
#!/bin/bash
# Comprehensive environment validation

set -euo pipefail

# Required environment variables
REQUIRED_VARS=(
    "POSTGRES_DB"
    "POSTGRES_USER" 
    "POSTGRES_PASSWORD"
    "N8N_HOST"
    "N8N_ENCRYPTION_KEY"
    "BASE_DOMAIN"
    "NC_AUTH_JWT_SECRET"
)

# Optional but recommended variables
OPTIONAL_VARS=(
    "VPS_POSTGRES_HOST"
    "VPS_POSTGRES_USER"
    "VPS_POSTGRES_PASSWORD"
    "VPS_POSTGRES_DB"
    "LETSENCRYPT_EMAIL"
)

validate_env_file() {
    if [ ! -f .env ]; then
        echo "❌ .env file not found!"
        echo "📋 Please create .env file from env.txt template"
        echo "💡 Copy env.txt to .env and fill in the values"
        return 1
    fi
    echo "✅ .env file exists"
}

validate_required_vars() {
    echo "🔍 Validating required environment variables..."
    local missing_vars=()
    
    for var in "${REQUIRED_VARS[@]}"; do
        if [ -z "${!var:-}" ]; then
            missing_vars+=("$var")
        else
            echo "✅ $var is set"
        fi
    done
    
    if [ ${#missing_vars[@]} -gt 0 ]; then
        echo "❌ Missing required variables:"
        printf '   - %s\n' "${missing_vars[@]}"
        return 1
    fi
}

validate_password_strength() {
    echo "🔒 Validating password strength..."
    
    if [ ${#POSTGRES_PASSWORD} -lt 12 ]; then
        echo "❌ POSTGRES_PASSWORD must be at least 12 characters"
        return 1
    fi
    
    if [ ${#N8N_ENCRYPTION_KEY} -lt 32 ]; then
        echo "❌ N8N_ENCRYPTION_KEY must be at least 32 characters"
        return 1
    fi
    
    echo "✅ Password strength validation passed"
}

validate_domain_format() {
    echo "🌐 Validating domain format..."
    
    if [[ ! "$N8N_HOST" =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        echo "❌ N8N_HOST format invalid: $N8N_HOST"
        return 1
    fi
    
    if [[ ! "$BASE_DOMAIN" =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        echo "❌ BASE_DOMAIN format invalid: $BASE_DOMAIN"
        return 1
    fi
    
    echo "✅ Domain format validation passed"
}

check_optional_vars() {
    echo "📋 Checking optional variables..."
    
    for var in "${OPTIONAL_VARS[@]}"; do
        if [ -n "${!var:-}" ]; then
            echo "✅ $var is set"
        else
            echo "⚠️  $var is not set (optional)"
        fi
    done
}

main() {
    echo "🔍 Environment Validation (RFC-001)..."
    
    # Source .env file
    if [ -f .env ]; then
        set -a
        source .env
        set +a
    fi
    
    local exit_code=0
    
    validate_env_file || exit_code=1
    validate_required_vars || exit_code=1
    validate_password_strength || exit_code=1
    validate_domain_format || exit_code=1
    check_optional_vars
    
    if [ $exit_code -eq 0 ]; then
        echo "✅ Environment validation passed!"
    else
        echo "❌ Environment validation failed!"
        echo "📋 Please check your .env file and fix the issues above"
    fi
    
    return $exit_code
}

main "$@"
```

### 4. Setup Automation System

#### Main Setup Script (scripts/setup.sh)
```bash
#!/bin/bash
# Main setup script cho n8n infrastructure

set -euo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🚀 n8n Backend Infrastructure Setup (RFC-001)"
echo "📁 Project root: $PROJECT_ROOT"

# Change to project root
cd "$PROJECT_ROOT"

# Step 1: Environment validation
echo "📋 Step 1: Environment validation..."
if ! ./scripts/validate-env.sh; then
    echo "❌ Environment validation failed. Please fix issues and try again."
    exit 1
fi

# Step 2: Docker prerequisites check
echo "🐳 Step 2: Docker prerequisites check..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo "❌ Docker daemon is not running"
    exit 1
fi

echo "✅ Docker prerequisites check passed"

# Step 3: Cleanup previous installation
echo "🧹 Step 3: Cleanup previous installation..."
read -p "Do you want to cleanup previous n8n installation? (y/N): " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ./scripts/cleanup-n8n.sh
fi

# Step 4: Create Docker resources
echo "📦 Step 4: Creating Docker resources..."

# Create network
if ! docker network inspect n8n-local-network &> /dev/null; then
    docker network create \
        --driver bridge \
        --subnet=172.20.0.0/16 \
        --gateway=172.20.0.1 \
        n8n-local-network
    echo "✅ Created n8n-local-network"
else
    echo "✅ n8n-local-network already exists"
fi

# Create volumes
VOLUMES=("postgres_data" "n8n_data" "nginx_logs" "cloudflared_config")
for volume in "${VOLUMES[@]}"; do
    if ! docker volume inspect "$volume" &> /dev/null; then
        docker volume create "$volume"
        echo "✅ Created volume: $volume"
    else
        echo "✅ Volume already exists: $volume"
    fi
done

# Step 5: Start core services
echo "🚀 Step 5: Starting core services..."
docker-compose -f docker-compose.yml -f docker-compose.core.yml up -d

# Step 6: Wait for services to be healthy
echo "⏳ Step 6: Waiting for services to be healthy..."
./scripts/wait-for-services.sh

# Step 7: Validate installation
echo "🔍 Step 7: Validating installation..."
./scripts/health-check-all.sh

echo "✅ n8n Backend Infrastructure setup completed!"
echo ""
echo "📋 Access Information:"
echo "   n8n Local: http://localhost:5678"
echo "   PostgreSQL: localhost:5432"
echo ""
echo "🔗 Next steps:"
echo "   1. Access n8n at http://localhost:5678"
echo "   2. Create your first workflow"
echo "   3. Continue with RFC-002 implementation"
```

#### Service Wait Script (scripts/wait-for-services.sh)
```bash
#!/bin/bash
# Wait for services to be healthy

set -euo pipefail

wait_for_service() {
    local service_name=$1
    local max_attempts=30
    local attempt=1
    
    echo "⏳ Waiting for $service_name to be healthy..."
    
    while [ $attempt -le $max_attempts ]; do
        if docker inspect --format='{{.State.Health.Status}}' "$service_name" 2>/dev/null | grep -q "healthy"; then
            echo "✅ $service_name is healthy"
            return 0
        fi
        
        echo "   Attempt $attempt/$max_attempts - waiting..."
        sleep 10
        ((attempt++))
    done
    
    echo "❌ $service_name failed to become healthy"
    return 1
}

main() {
    echo "⏳ Waiting for all services to be healthy..."
    
    local services=("postgres" "n8n")
    local exit_code=0
    
    for service in "${services[@]}"; do
        wait_for_service "$service" || exit_code=1
    done
    
    if [ $exit_code -eq 0 ]; then
        echo "✅ All services are healthy!"
    else
        echo "❌ Some services failed to become healthy"
        echo "📋 Check logs with: docker-compose logs"
    fi
    
    return $exit_code
}

main "$@"
```

### 5. Health Monitoring System

#### Comprehensive Health Check (scripts/health-check-all.sh)
```bash
#!/bin/bash
# Comprehensive health check cho all services

set -euo pipefail

check_docker_resources() {
    echo "🐳 Checking Docker resources..."
    
    # Check network
    if docker network inspect n8n-local-network &> /dev/null; then
        echo "✅ n8n-local-network exists"
    else
        echo "❌ n8n-local-network missing"
        return 1
    fi
    
    # Check volumes
    local volumes=("postgres_data" "n8n_data")
    for volume in "${volumes[@]}"; do
        if docker volume inspect "$volume" &> /dev/null; then
            echo "✅ Volume $volume exists"
        else
            echo "❌ Volume $volume missing"
            return 1
        fi
    done
}

check_service_health() {
    local service=$1
    local health_status=$(docker inspect --format='{{.State.Health.Status}}' "$service" 2>/dev/null || echo "unknown")
    
    case $health_status in
        "healthy")
            echo "✅ $service is healthy"
            return 0
            ;;
        "unhealthy")
            echo "❌ $service is unhealthy"
            return 1
            ;;
        "starting")
            echo "⏳ $service is starting"
            return 1
            ;;
        *)
            echo "❓ $service status unknown"
            return 1
            ;;
    esac
}

check_connectivity() {
    echo "🔗 Checking service connectivity..."
    
    # Check PostgreSQL
    if docker exec postgres pg_isready -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" &> /dev/null; then
        echo "✅ PostgreSQL connectivity OK"
    else
        echo "❌ PostgreSQL connectivity failed"
        return 1
    fi
    
    # Check n8n API
    if curl -f http://localhost:5678/healthz &> /dev/null; then
        echo "✅ n8n API connectivity OK"
    else
        echo "❌ n8n API connectivity failed"
        return 1
    fi
}

show_resource_usage() {
    echo "📊 Resource usage:"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
}

main() {
    echo "🏥 Comprehensive Health Check (RFC-001)..."
    
    local exit_code=0
    
    check_docker_resources || exit_code=1
    
    local services=("postgres" "n8n")
    for service in "${services[@]}"; do
        check_service_health "$service" || exit_code=1
    done
    
    check_connectivity || exit_code=1
    show_resource_usage
    
    if [ $exit_code -eq 0 ]; then
        echo "✅ All health checks passed!"
    else
        echo "❌ Some health checks failed"
        echo "📋 Check individual service logs for details"
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
```

## Extended Database Schema Specifications

### Complete Database Schema Implementation (từ database/ref migrations)

#### Core Schema & Extensions
```sql
-- Create schema and extensions
CREATE SCHEMA IF NOT EXISTS n8n;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

#### User & Authentication Tables
```sql
-- Users table (20230801_002)
CREATE TABLE n8n.users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR NOT NULL UNIQUE,
    username VARCHAR UNIQUE NOT NULL,
    password VARCHAR,
    avatar_url VARCHAR,
    is_vip BOOLEAN DEFAULT false,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_users_email ON n8n.users(email);
CREATE INDEX idx_users_username ON n8n.users(username);

-- User OAuth table (20230801_003)
CREATE TABLE n8n.user_oauth (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES n8n.users(id) ON DELETE CASCADE,
    provider VARCHAR(50) NOT NULL,
    provider_user_id VARCHAR NOT NULL,
    access_token VARCHAR,
    refresh_token VARCHAR,
    profile_data JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(provider, provider_user_id)
);
CREATE INDEX idx_user_oauth_user_id ON n8n.user_oauth(user_id);
CREATE INDEX idx_user_oauth_provider ON n8n.user_oauth(provider);
```

#### Workflow Management Tables
```sql
-- Workflows table (20230802_001)
CREATE TABLE n8n.workflows (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    slug VARCHAR UNIQUE,
    n8n_workflow_id VARCHAR(255),
    is_public BOOLEAN NOT NULL DEFAULT false,
    current_version_id UUID,
    input JSONB,
    output JSONB,
    doc_url VARCHAR,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_workflows_name ON n8n.workflows(name);
CREATE INDEX idx_workflows_is_public ON n8n.workflows(is_public);

-- Workflow versions table (20230802_002)
CREATE TABLE n8n.workflow_versions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workflow_id UUID NOT NULL REFERENCES n8n.workflows(id) ON DELETE CASCADE,
    version INTEGER NOT NULL,
    configuration JSONB NOT NULL,
    form_schema JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(workflow_id, version)
);
CREATE INDEX idx_workflow_versions_workflow_id ON n8n.workflow_versions(workflow_id);

-- Add foreign key to workflows.current_version_id
ALTER TABLE n8n.workflows 
ADD CONSTRAINT fk_workflows_current_version 
FOREIGN KEY (current_version_id) REFERENCES n8n.workflow_versions(id) ON DELETE SET NULL;

-- User workflow favorites table (20230803_001)
CREATE TABLE n8n.user_workflow_favorites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES n8n.users(id) ON DELETE CASCADE,
    workflow_id UUID NOT NULL REFERENCES n8n.workflows(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, workflow_id)
);
CREATE INDEX idx_user_workflow_favorites_user_id ON n8n.user_workflow_favorites(user_id);
CREATE INDEX idx_user_workflow_favorites_workflow_id ON n8n.user_workflow_favorites(workflow_id);
```

#### Tier & Limits System
```sql
-- Workflow tier limits table (20230803_002)
CREATE TABLE n8n.workflow_tier_limits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workflow_id UUID NOT NULL REFERENCES n8n.workflows(id) ON DELETE CASCADE,
    tier VARCHAR(50) NOT NULL, -- 'free', 'pro', 'premium', 'vip'
    limit_unit VARCHAR(50) NOT NULL, -- 'executions_per_day', 'execution_time_sec', etc.
    limit_value INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(workflow_id, tier, limit_unit)
);
CREATE INDEX idx_workflow_tier_limits_workflow_id ON n8n.workflow_tier_limits(workflow_id);
CREATE INDEX idx_workflow_tier_limits_tier ON n8n.workflow_tier_limits(tier);

-- VIP custom limits table (20230804_003)
CREATE TABLE n8n.vip_custom_limits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES n8n.users(id) ON DELETE CASCADE,
    workflow_id UUID NOT NULL REFERENCES n8n.workflows(id) ON DELETE CASCADE,
    limit_unit VARCHAR(50) NOT NULL,
    limit_value INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, workflow_id, limit_unit)
);
CREATE INDEX idx_vip_custom_limits_user_id ON n8n.vip_custom_limits(user_id);
CREATE INDEX idx_vip_custom_limits_workflow_id ON n8n.vip_custom_limits(workflow_id);
```

#### Order & Payment System
```sql
-- Orders table (20230804_002)
CREATE TABLE n8n.orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES n8n.users(id) ON DELETE CASCADE,
    workflow_id UUID NOT NULL REFERENCES n8n.workflows(id) ON DELETE CASCADE,
    purchase_date TIMESTAMP NOT NULL DEFAULT NOW(),
    expiry_date TIMESTAMP,
    is_active BOOLEAN NOT NULL DEFAULT true,
    transaction_id VARCHAR,
    note TEXT,
    is_vip BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_orders_user_id ON n8n.orders(user_id);
CREATE INDEX idx_orders_workflow_id ON n8n.orders(workflow_id);
CREATE INDEX idx_orders_is_active ON n8n.orders(is_active);
CREATE INDEX idx_orders_expiry_date ON n8n.orders(expiry_date);
```

#### Execution & Logging System
```sql
-- Log workflow executions table (20230804_001)
CREATE TABLE n8n.log_workflow_executions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workflow_id UUID NOT NULL REFERENCES n8n.workflows(id) ON DELETE CASCADE,
    workflow_version_id UUID REFERENCES n8n.workflow_versions(id) ON DELETE SET NULL,
    user_id UUID REFERENCES n8n.users(id) ON DELETE SET NULL,
    order_id UUID REFERENCES n8n.orders(id) ON DELETE SET NULL, -- Added in 20230806_001
    status VARCHAR(50) NOT NULL, -- 'pending', 'running', 'completed', 'failed'
    input_data JSONB,
    output_data JSONB,
    error_message TEXT,
    started_at TIMESTAMP NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMP,
    execution_time_ms INTEGER
);
CREATE INDEX idx_log_workflow_executions_workflow_id ON n8n.log_workflow_executions(workflow_id);
CREATE INDEX idx_log_workflow_executions_user_id ON n8n.log_workflow_executions(user_id);
CREATE INDEX idx_log_workflow_executions_status ON n8n.log_workflow_executions(status);
CREATE INDEX idx_log_workflow_executions_started_at ON n8n.log_workflow_executions(started_at);
CREATE INDEX idx_log_workflow_executions_order_id ON n8n.log_workflow_executions(order_id);

-- Log user activities table (20230805_001)
CREATE TABLE n8n.log_user_activities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES n8n.users(id) ON DELETE SET NULL,
    activity_type VARCHAR(50) NOT NULL,
    activity_data JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_log_user_activities_user_id ON n8n.log_user_activities(user_id);
CREATE INDEX idx_log_user_activities_activity_type ON n8n.log_user_activities(activity_type);
CREATE INDEX idx_log_user_activities_created_at ON n8n.log_user_activities(created_at);

-- Log workflow changes table (20230805_001)
CREATE TABLE n8n.log_workflow_changes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workflow_id UUID NOT NULL REFERENCES n8n.workflows(id) ON DELETE CASCADE,
    user_id UUID REFERENCES n8n.users(id) ON DELETE SET NULL,
    change_type VARCHAR(50) NOT NULL, -- 'created', 'updated', 'deleted', 'published'
    change_data JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_log_workflow_changes_workflow_id ON n8n.log_workflow_changes(workflow_id);
CREATE INDEX idx_log_workflow_changes_user_id ON n8n.log_workflow_changes(user_id);
CREATE INDEX idx_log_workflow_changes_change_type ON n8n.log_workflow_changes(change_type);
CREATE INDEX idx_log_workflow_changes_created_at ON n8n.log_workflow_changes(created_at);

-- Log transactions table (20230805_001)
CREATE TABLE n8n.log_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES n8n.users(id) ON DELETE SET NULL,
    order_id UUID REFERENCES n8n.orders(id) ON DELETE SET NULL,
    transaction_type VARCHAR(50) NOT NULL, -- 'purchase', 'refund', etc.
    amount DECIMAL(10, 2),
    currency VARCHAR(3) DEFAULT 'USD',
    status VARCHAR(50) NOT NULL, -- 'success', 'failed', 'pending'
    payment_method VARCHAR(50),
    transaction_data JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_log_transactions_user_id ON n8n.log_transactions(user_id);
CREATE INDEX idx_log_transactions_order_id ON n8n.log_transactions(order_id);
CREATE INDEX idx_log_transactions_transaction_type ON n8n.log_transactions(transaction_type);
CREATE INDEX idx_log_transactions_status ON n8n.log_transactions(status);
CREATE INDEX idx_log_transactions_created_at ON n8n.log_transactions(created_at);

-- Log usage table (20230805_001, modified in 20230806_001)
CREATE TABLE n8n.log_usage (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES n8n.users(id) ON DELETE SET NULL,
    workflow_id UUID REFERENCES n8n.workflows(id) ON DELETE CASCADE,
    resource_type VARCHAR(50) NOT NULL, -- 'workflow_execution', 'api_call', etc.
    usage_count INTEGER NOT NULL DEFAULT 1, -- Renamed from 'count' in 20230806_001
    usage_date DATE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_log_usage_user_id ON n8n.log_usage(user_id);
CREATE INDEX idx_log_usage_workflow_id ON n8n.log_usage(workflow_id);
CREATE INDEX idx_log_usage_resource_type ON n8n.log_usage(resource_type);
CREATE INDEX idx_log_usage_usage_date ON n8n.log_usage(usage_date);
```

#### Extended Tables (New Requirements)
```sql
-- Comments Table (New requirement)
CREATE TABLE n8n.comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES n8n.users(id) ON DELETE CASCADE,
    target_type VARCHAR(50) NOT NULL, -- 'workflow', 'execution', 'user'
    target_id UUID NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    CONSTRAINT chk_target_type CHECK (target_type IN ('workflow', 'execution', 'user')),
    CONSTRAINT chk_content_length CHECK (LENGTH(content) > 0 AND LENGTH(content) <= 5000)
);
CREATE INDEX idx_comments_user_id ON n8n.comments(user_id);
CREATE INDEX idx_comments_target ON n8n.comments(target_type, target_id);
CREATE INDEX idx_comments_created_at ON n8n.comments(created_at);

-- Ratings Table (New requirement)
CREATE TABLE n8n.ratings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES n8n.users(id) ON DELETE CASCADE,
    workflow_id UUID NOT NULL REFERENCES n8n.workflows(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL,
    review TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    CONSTRAINT chk_rating_range CHECK (rating >= 1 AND rating <= 5),
    CONSTRAINT chk_review_length CHECK (review IS NULL OR LENGTH(review) <= 2000),
    CONSTRAINT uk_user_workflow_rating UNIQUE (user_id, workflow_id)
);
CREATE INDEX idx_ratings_user_id ON n8n.ratings(user_id);
CREATE INDEX idx_ratings_workflow_id ON n8n.ratings(workflow_id);
CREATE INDEX idx_ratings_rating ON n8n.ratings(rating);
CREATE INDEX idx_ratings_created_at ON n8n.ratings(created_at);

-- Triggers for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_comments_updated_at 
    BEFORE UPDATE ON n8n.comments 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ratings_updated_at 
    BEFORE UPDATE ON n8n.ratings 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

#### Performance Optimization (20230807_001, 20230807_002)
```sql
-- Advanced indexes for search optimization
CREATE INDEX IF NOT EXISTS idx_workflows_name_description ON n8n.workflows 
USING gin(to_tsvector('simple', name || ' ' || COALESCE(description, '')));

CREATE INDEX IF NOT EXISTS idx_workflow_executions_workflow_id_status ON n8n.log_workflow_executions(workflow_id, status);
CREATE INDEX IF NOT EXISTS idx_workflow_executions_started_at ON n8n.log_workflow_executions(started_at DESC);
CREATE INDEX IF NOT EXISTS idx_workflows_is_public ON n8n.workflows(is_public) WHERE is_public = true;

-- JSON indexes for performance
CREATE INDEX IF NOT EXISTS idx_workflow_executions_input_jsonb ON n8n.log_workflow_executions USING gin(input_data::jsonb);
CREATE INDEX IF NOT EXISTS idx_workflow_executions_output_jsonb ON n8n.log_workflow_executions USING gin(output_data::jsonb);

-- Date-based indexes
CREATE INDEX IF NOT EXISTS idx_workflow_executions_date ON n8n.log_workflow_executions(DATE(started_at));

-- Materialized view for daily workflow statistics
CREATE MATERIALIZED VIEW IF NOT EXISTS n8n.mv_daily_workflow_stats AS
SELECT
    DATE(started_at) AS execution_date,
    workflow_id,
    COUNT(*) AS total_executions,
    SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) AS successful_executions,
    SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) AS failed_executions,
    AVG(execution_time_ms) AS avg_duration_ms,
    MAX(execution_time_ms) AS max_duration_ms,
    MIN(execution_time_ms) AS min_duration_ms
FROM n8n.log_workflow_executions
WHERE started_at IS NOT NULL
GROUP BY DATE(started_at), workflow_id
ORDER BY DATE(started_at) DESC, workflow_id;

CREATE UNIQUE INDEX IF NOT EXISTS idx_mv_daily_workflow_stats_date_workflow
ON n8n.mv_daily_workflow_stats(execution_date, workflow_id);

-- Materialized view for top workflows
CREATE MATERIALIZED VIEW IF NOT EXISTS n8n.mv_top_workflows AS
SELECT
    w.id AS workflow_id,
    w.name AS workflow_name,
    COUNT(we.id) AS execution_count,
    SUM(CASE WHEN we.status = 'completed' THEN 1 ELSE 0 END) AS successful_count,
    SUM(CASE WHEN we.status = 'failed' THEN 1 ELSE 0 END) AS error_count,
    AVG(we.execution_time_ms) AS avg_duration_ms,
    MAX(we.execution_time_ms) AS max_duration_ms,
    COUNT(DISTINCT uwf.user_id) AS user_count
FROM n8n.workflows w
LEFT JOIN n8n.log_workflow_executions we ON w.id = we.workflow_id
LEFT JOIN n8n.user_workflow_favorites uwf ON w.id = uwf.workflow_id
GROUP BY w.id, w.name
ORDER BY execution_count DESC;

CREATE UNIQUE INDEX IF NOT EXISTS idx_mv_top_workflows_workflow_id
ON n8n.mv_top_workflows(workflow_id);

-- Materialized view for workflow tier statistics (simplified version)
CREATE MATERIALIZED VIEW IF NOT EXISTS n8n.mv_workflow_tier_stats AS
SELECT
    wtl.tier,
    COUNT(DISTINCT wtl.workflow_id) AS workflow_count,
    COUNT(DISTINCT we.id) AS total_executions,
    AVG(we.execution_time_ms) AS avg_execution_time,
    COUNT(DISTINCT uwf.user_id) AS user_count
FROM n8n.workflow_tier_limits wtl
LEFT JOIN n8n.log_workflow_executions we ON wtl.workflow_id = we.workflow_id
LEFT JOIN n8n.user_workflow_favorites uwf ON wtl.workflow_id = uwf.workflow_id
GROUP BY wtl.tier
ORDER BY wtl.tier;

CREATE UNIQUE INDEX IF NOT EXISTS idx_mv_workflow_tier_stats_tier
ON n8n.mv_workflow_tier_stats(tier);

-- Function to refresh all materialized views
CREATE OR REPLACE FUNCTION n8n.refresh_all_materialized_views()
RETURNS void AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY n8n.mv_daily_workflow_stats;
    REFRESH MATERIALIZED VIEW CONCURRENTLY n8n.mv_top_workflows;
    REFRESH MATERIALIZED VIEW CONCURRENTLY n8n.mv_workflow_tier_stats;
END;
$$ LANGUAGE plpgsql;
```

## Acceptance Criteria

### F001: Docker Orchestration System
- [ ] Multiple Docker Compose files structure implemented
- [ ] docker-compose.yml (main), docker-compose.core.yml created
- [ ] n8n-local-network (172.20.0.0/16) created successfully
- [ ] All required volumes created (postgres_data, n8n_data, etc.)
- [ ] Health checks implemented cho all services
- [ ] Service dependencies configured correctly
- [ ] Resource limits applied appropriately
- [ ] Graceful shutdown working

### F004: Setup Automation Scripts
- [ ] setup.sh script khởi động tất cả services
- [ ] cleanup-all.sh comprehensive cleanup working
- [ ] cleanup-n8n.sh selective cleanup working
- [ ] validate-env.sh environment validation working
- [ ] wait-for-services.sh service monitoring working
- [ ] health-check-all.sh comprehensive monitoring working
- [ ] Error handling và rollback implemented
- [ ] Progress indicators working
- [ ] Setup time < 30 phút achieved
- [ ] Idempotent execution working

### F010: Environment Configuration Management
- [ ] .env file validation working
- [ ] Required variables validation implemented
- [ ] Password strength validation working
- [ ] Domain format validation working
- [ ] Configuration backup/restore working
- [ ] Environment-specific configs supported
- [ ] Error reporting comprehensive
- [ ] Documentation complete

### Complete Database Schema (từ database/ref migrations)
- [ ] Schema "n8n" và uuid-ossp extension created
- [ ] Core User & Auth tables: users, user_oauth
- [ ] Workflow Management tables: workflows, workflow_versions, user_workflow_favorites
- [ ] Tier & Limits tables: workflow_tier_limits, vip_custom_limits
- [ ] Order & Payment tables: orders
- [ ] Execution & Logging tables: log_workflow_executions, log_user_activities, log_workflow_changes, log_transactions, log_usage
- [ ] Extended tables: comments, ratings (new requirements)
- [ ] All foreign key relationships working với proper CASCADE/SET NULL
- [ ] All indexes created cho performance (basic + advanced GIN indexes)
- [ ] Materialized views: mv_daily_workflow_stats, mv_top_workflows
- [ ] Performance optimization functions: refresh_all_materialized_views()
- [ ] Triggers implemented cho updated_at fields
- [ ] Data integrity constraints enforced (CHECK constraints, UNIQUE constraints)
- [ ] Schema fixes applied (order_id FK, usage_count rename)

## Documentation Requirements

### Port & URL Reference Documentation
```markdown
# Port & URL Reference

## Service Access URLs

| Service | URL Local | URL Tunnel | Port | IP Address | Description |
|---------|-----------|------------|------|------------|-------------|
| n8n Local | http://localhost:5678 | https://n8n.ai-automation.cloud | 5678 | 172.20.0.20 | Main n8n interface |
| NocoDB | http://localhost:8080 | https://nocodb.ai-automation.cloud | 8080 | 172.20.0.30 | Database web interface |
| PostgreSQL | localhost:5432 | Internal only | 5432 | 172.20.0.10 | Database server |
| nginx | localhost:80,443 | Proxy only | 80,443 | 172.20.0.40 | Reverse proxy |
| n8n Worker | Internal only | VPS connection | - | 172.20.0.60 | Queue worker |

## Network Configuration

- **Network Name:** n8n-local-network
- **Subnet:** 172.20.0.0/16
- **Gateway:** 172.20.0.1
- **Driver:** bridge

## Volume Mapping

| Volume Name | Mount Point | Purpose |
|-------------|-------------|---------|
| postgres_data | /var/lib/postgresql/data | PostgreSQL data persistence |
| n8n_data | /home/node/.n8n | n8n workflows and settings |
| nginx_logs | /var/log/nginx | nginx access and error logs |
| cloudflared_config | /home/nonroot/.cloudflared | Cloudflare tunnel config |

## Environment Variables Reference

### Required Variables
- POSTGRES_DB, POSTGRES_USER, POSTGRES_PASSWORD
- N8N_HOST, N8N_ENCRYPTION_KEY
- BASE_DOMAIN, NC_AUTH_JWT_SECRET

### Optional Variables  
- VPS_POSTGRES_HOST, VPS_POSTGRES_USER, VPS_POSTGRES_PASSWORD
- LETSENCRYPT_EMAIL

## Troubleshooting

### Common Issues
1. **Port conflicts:** Check if ports 5678, 8080, 5432 are available
2. **Permission issues:** Ensure Docker has proper permissions
3. **Network conflicts:** Check if 172.20.0.0/16 subnet is available
4. **Volume mounting:** Verify Docker volume permissions

### Health Check Commands
```bash
# Check all services
./scripts/health-check-all.sh

# Check specific service
docker inspect --format='{{.State.Health.Status}}' postgres
docker inspect --format='{{.State.Health.Status}}' n8n

# View logs
docker-compose logs postgres
docker-compose logs n8n
```
```

---

**RFC Status:** Ready for Implementation  
**Complexity:** Medium  
**Estimated Effort:** 1 week  
**Previous RFC:** None (Foundation)  
**Next RFC:** RFC-002 (PostgreSQL Local Database) 

## Database Schema Architecture

### PostgreSQL Schema "n8n" - VPS Enhanced Version
**Status:** ✅ **UPGRADED TO VPS VERSION (2024-12-01)**

**Migration Completed:** Clone 16 tables từ VPS PostgreSQL về localhost thành công

#### Core Tables (16 tables từ VPS):
1. **users** - User accounts với tier system (free, pro, premium, vip)
2. **workflows** - Workflow definitions với metadata và versioning
3. **workflow_versions** - Version control system cho workflows
4. **workflow_tier_limits** - Tier-based resource limits
5. **vip_custom_limits** - Custom limits cho VIP users
6. **user_workflow_favorites** - User favorite workflows
7. **user_oauth** - OAuth provider integrations
8. **ratings** - Workflow ratings và reviews system
9. **orders** - Purchase orders và subscription management
10. **log_workflow_executions** - Comprehensive execution tracking
11. **log_workflow_changes** - Change history và audit trail
12. **log_user_activities** - User activity logging
13. **log_usage** - Resource usage tracking với credit system
14. **log_transactions** - Payment transaction history
15. **worker_logs** - Worker performance monitoring
16. **comments** - Comments system cho workflows và executions

#### System Views (3 monitoring views):
1. **v_data_summary** - Data overview và record counts
2. **v_database_health** - Database health metrics
3. **v_system_status** - System component status

#### Performance Optimization:
- **Total Indexes:** 88 performance-optimized indexes
- **Unique Constraints:** 8 business logic constraints
- **Foreign Keys:** Complete referential integrity
- **GIN Indexes:** Advanced indexing cho JSONB và array fields

#### Migration Details:
- **Migration File:** `database/migrations/20241201_upgrade_vps_schema.sql`
- **Migration Script:** `scripts/migrate-vps-schema.sh`
- **Backup Created:** Full backup before migration (safety first)
- **Verification:** `scripts/verify-migration.sh` confirms 100% success

## Implementation Status

### ✅ COMPLETE: Enhanced Database Foundation
- **PostgreSQL v17:** Performance-optimized container
- **VPS Schema:** 16 tables cloned from production VPS
- **Complete Indexing:** 88 indexes cho optimal performance
- **System Monitoring:** 3 views cho health tracking
- **Data Integrity:** Full constraints và foreign keys
- **Migration Safety:** Backup và verification systems 