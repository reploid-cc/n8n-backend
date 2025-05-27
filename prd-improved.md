# Product Requirements Document (PRD) - IMPROVED
## n8n Backend Infrastructure - Local Development Environment

---

## 📋 Executive Summary

**Project:** n8n Backend Infrastructure cho Local Development Environment  
**Version:** 2.0 (Improved)  
**Status:** Ready for Implementation  
**Timeline:** 12 tháng (4 phases)  
**Owner:** Developer/Product Owner  

### Problem Statement
Developer hiện tại gặp khó khăn trong việc test/debug n8n workflows do:
- VPS chậm cho development
- Queue mode trên VPS làm chậm testing
- Thiếu môi trường local hoàn chỉnh với dữ liệu test

### Solution Overview
Xây dựng hệ thống backend infrastructure hoàn chỉnh chạy 100% Docker tại localhost, bao gồm n8n backend, PostgreSQL, NocoDB UI, nginx reverse proxy, cloudflared tunnel, và Redis queue system.

**ROI Expected:** Giảm 70% thời gian test/debug, tăng 50% tốc độ development

---

## 🎯 Goals and Objectives

### Primary Goals (Must Have)
1. **Development Speed:** Môi trường test/debug local nhanh hơn VPS ≥50%
2. **System Reliability:** 99% uptime cho local development
3. **Data Completeness:** Database với 50-200 records mỗi table
4. **Easy Setup:** Setup time < 30 phút từ clone đến running
5. **n8n Worker Local:** Hybrid worker processing với VPS

### Secondary Goals (Should Have)
6. **Domain Access:** Local domain ai-automation.cloud
7. **UI Management:** NocoDB interface cho database management

### Technical Objectives
- 100% containerized với Docker
- Zero data loss during development
- Automatic database migrations
- Auto-generated mock data

---

## 🔍 Scope & Boundaries

### ✅ IN SCOPE (Must Have)
- **Core Infrastructure:** PostgreSQL local, n8n backend local (không queue mode)
- **UI Layer:** NocoDB database interface
- **Networking:** nginx reverse proxy, cloudflared tunnel
- **Data Management:** Auto-migrations, mock data generation
- **Configuration:** Multiple Docker Compose files, .env management
- **n8n Worker Local:** Hybrid worker kết nối Redis VPS (có queue mode)

### ✅ IN SCOPE (Should Have)
- **Domain Setup:** ai-automation.cloud local routing
- **SSL/HTTPS:** Basic SSL configuration
- **Documentation:** Setup guides, troubleshooting

### ❌ OUT OF SCOPE (Won't Have)
- Production deployment scripts
- Advanced monitoring (RedisInsight, Grafana)
- Backup/restore automation
- Multi-environment support

---

## 👤 User Personas & User Stories

### Primary Persona: Solo Developer
**Profile:** Chủ sở hữu và developer duy nhất  
**Technical Level:** Advanced  
**Primary Goals:** Fast development, reliable testing environment  

#### User Stories

**Epic 1: Environment Setup**
- **US001:** As a developer, I want to start the entire stack with one command so that I can quickly begin development
- **US002:** As a developer, I want automatic database migrations so that I don't need to manually setup schema
- **US003:** As a developer, I want pre-populated test data so that I can immediately test workflows

**Epic 2: Development Workflow**
- **US004:** As a developer, I want to access n8n via local domain so that I can test webhooks properly
- **US005:** As a developer, I want to view/edit database records via UI so that I can debug data issues
- **US006:** As a developer, I want fast API responses (<500ms) so that development is efficient

**Epic 3: Data Management**
- **US007:** As a developer, I want persistent data storage so that I don't lose work between restarts
- **US008:** As a developer, I want to easily reset test data so that I can start fresh when needed

---

## ⚙️ Functional Requirements (MoSCoW)

### 1. Core Infrastructure (MUST HAVE)
**Priority: CRITICAL**

#### FR001: Docker Orchestration
- **Requirement:** Multiple Docker Compose files cho service groups
- **Acceptance Criteria:**
  - [ ] docker-compose.core.yml (PostgreSQL, n8n, Redis)
  - [ ] docker-compose.ui.yml (NocoDB)
  - [ ] docker-compose.network.yml (nginx, cloudflared)
  - [ ] Single command startup: `./scripts/setup.sh`
  - [ ] All services start within 2 minutes
- **Dependencies:** Docker, Docker Compose installed

#### FR002: Database Layer
- **Requirement:** PostgreSQL với schema "n8n" và auto-migrations
- **Acceptance Criteria:**
  - [ ] PostgreSQL 15+ container
  - [ ] Schema "n8n" tự động tạo
  - [ ] Migration scripts từ database/ref/ tự động chạy
  - [ ] Persistent volume mounting
  - [ ] Health check endpoint
- **Dependencies:** Migration files trong database/ref/

#### FR003: n8n Backend Service Local
- **Requirement:** n8n container local cho test/debug (KHÔNG queue mode)
- **Acceptance Criteria:**
  - [ ] n8n version latest
  - [ ] Normal mode (không queue)
  - [ ] Kết nối PostgreSQL local schema "n8n"
  - [ ] Environment variables từ .env
  - [ ] Webhook endpoints functional
  - [ ] API response time < 500ms
- **Dependencies:** PostgreSQL local, .env file

#### FR004: PostgreSQL Local Database
- **Requirement:** PostgreSQL local riêng biệt cho n8n local
- **Acceptance Criteria:**
  - [ ] PostgreSQL latest container
  - [ ] Schema "n8n" riêng cho local
  - [ ] Persistent data storage
  - [ ] Health check endpoint
  - [ ] Isolated từ VPS database
- **Dependencies:** None

### 2. User Interface (SHOULD HAVE)
**Priority: HIGH**

#### FR005: NocoDB Interface
- **Requirement:** Database UI cho PostgreSQL management
- **Acceptance Criteria:**
  - [ ] NocoDB latest version
  - [ ] Kết nối PostgreSQL database
  - [ ] Access via nocodb.ai-automation.cloud
  - [ ] CRUD operations functional
  - [ ] Schema visualization
- **Dependencies:** PostgreSQL, nginx

### 3. Networking & Domain (SHOULD HAVE)
**Priority: MEDIUM**

#### FR006: Reverse Proxy
- **Requirement:** nginx reverse proxy cho domain routing
- **Acceptance Criteria:**
  - [ ] nginx latest stable
  - [ ] Domain routing: n8n.ai-automation.cloud → n8n:5678
  - [ ] Domain routing: nocodb.ai-automation.cloud → nocodb:8080
  - [ ] SSL/HTTPS configuration
  - [ ] Health check endpoints
- **Dependencies:** Domain DNS setup

#### FR007: Tunnel Service
- **Requirement:** cloudflared tunnel cho external access
- **Acceptance Criteria:**
  - [ ] cloudflared latest version
  - [ ] Tunnel configuration
  - [ ] Domain mapping setup
  - [ ] Automatic reconnection
- **Dependencies:** nginx, Cloudflare account

### 4. n8n Worker Local (MUST HAVE)
**Priority: CRITICAL**

#### FR008: n8n Worker Local
- **Requirement:** n8n worker local cho hybrid processing với VPS
- **Acceptance Criteria:**
  - [ ] n8n worker latest container
  - [ ] Kết nối Redis VPS (103.110.57.247:6379)
  - [ ] Kết nối PostgreSQL VPS cho shared database
  - [ ] Queue mode enabled cho worker
  - [ ] Auto-scaling dựa trên queue backlog
  - [ ] Sync credentials và workflows từ VPS
  - [ ] Callback URLs vẫn trỏ về VPS domain (n8n.masteryflow.cc)
- **Dependencies:** VPS Redis accessible, VPS PostgreSQL accessible

### 5. Data Management (SHOULD HAVE)
**Priority: MEDIUM**

#### FR009: Mock Data Generation
- **Requirement:** Auto-generate test data cho development
- **Acceptance Criteria:**
  - [ ] Script generate 50-200 records per table
  - [ ] Realistic data patterns
  - [ ] Support cho queue system tables
  - [ ] Support cho user-tier tables
  - [ ] Idempotent execution
- **Dependencies:** Database migrations completed

#### FR010: Configuration Management
- **Requirement:** Centralized configuration management
- **Acceptance Criteria:**
  - [ ] .env file template
  - [ ] Environment validation script
  - [ ] Service configuration documentation
  - [ ] Port mapping documentation
- **Dependencies:** None

---

## 🔧 Non-Functional Requirements

### Performance Requirements
| Metric | Target | Measurement |
|--------|--------|-------------|
| Startup Time | < 2 minutes | All services healthy |
| API Response | < 500ms | n8n API endpoints |
| Database Query | < 100ms | Basic CRUD operations |
| Memory Usage | < 8GB total | All containers combined |
| CPU Usage | < 50% average | During normal operations |

### Reliability Requirements
| Metric | Target | Measurement |
|--------|--------|-------------|
| Uptime | 99% | During development hours |
| Data Persistence | 100% | No data loss on restart |
| Error Recovery | < 30 seconds | Service auto-restart |
| Backup Frequency | Daily | Automatic PostgreSQL backup |

### Security Requirements
- **Access Control:** Localhost only access
- **Credential Storage:** Secure environment variables
- **Database Security:** Protected PostgreSQL credentials
- **Network Security:** Internal Docker networks only

### Scalability Requirements
- **Resource Scaling:** Support up to 200 records per table
- **Service Scaling:** Individual service restart capability
- **Storage Scaling:** Expandable PostgreSQL volumes

---

## 🏗️ Technical Architecture

### System Architecture Diagram
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Cloudflared   │    │     Nginx       │    │   n8n Local     │
│   (Tunnel)      │◄──►│ (Reverse Proxy) │◄──►│   (Backend)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                       │
                                ▼                       ▼
                       ┌─────────────────┐    ┌─────────────────┐
                       │     NocoDB      │    │ PostgreSQL Local│
                       │   (Database UI) │◄──►│   (Database)    │
                       └─────────────────┘    └─────────────────┘

                       ┌─────────────────┐    ┌─────────────────┐
                       │ n8n Worker Local│    │   Redis VPS     │
                       │ (Hybrid Worker) │◄──►│ (103.110.57.247)│
                       └─────────────────┘    └─────────────────┘
```

### Technology Stack
| Component | Technology | Version | Purpose |
|-----------|------------|---------|---------|
| Container | Docker | Latest | Containerization |
| Orchestration | Docker Compose | Latest | Service management |
| Database Local | PostgreSQL | Latest | Local data store |
| Backend Local | n8n | Latest | Local workflow test/debug |
| Worker Local | n8n | Latest | Hybrid worker cho VPS |
| UI | NocoDB | Latest | Database interface |
| Proxy | nginx | Latest | Reverse proxy |
| Tunnel | cloudflared | Latest | External access |

### Network Architecture
```yaml
networks:
  n8n-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16

services:
  postgresql: 172.20.0.10:5432
  redis: 172.20.0.11:6379
  n8n: 172.20.0.20:5678
  nocodb: 172.20.0.30:8080
  nginx: 172.20.0.40:80,443
  cloudflared: 172.20.0.50
```

---

## 📋 Technical Specifications

### Docker Compose Structure
```yaml
# docker-compose.yml (Main orchestration)
version: '3.8'
networks:
  n8n-network:
    driver: bridge

# docker-compose.core.yml
services:
  postgresql:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database/migrations:/docker-entrypoint-initdb.d
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  n8n:
    image: n8nio/n8n:1.92.2
    environment:
      DB_TYPE: postgresdb
      DB_POSTGRESDB_HOST: postgresql
      DB_POSTGRESDB_PORT: 5432
      DB_POSTGRESDB_DATABASE: ${POSTGRES_DB}
      DB_POSTGRESDB_USER: ${POSTGRES_USER}
      DB_POSTGRESDB_PASSWORD: ${POSTGRES_PASSWORD}
      DB_POSTGRESDB_SCHEMA: n8n
      QUEUE_BULL_REDIS_HOST: redis
      QUEUE_BULL_REDIS_PORT: 6379
      N8N_HOST: ${N8N_HOST}
      N8N_PROTOCOL: https
      EXECUTIONS_MODE: queue
    depends_on:
      postgresql:
        condition: service_healthy
      redis:
        condition: service_healthy
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:5678/healthz || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3

# docker-compose.ui.yml
services:
  nocodb:
    image: nocodb/nocodb:latest
    environment:
      NC_DB: "pg://postgresql:5432?u=${POSTGRES_USER}&p=${POSTGRES_PASSWORD}&d=${POSTGRES_DB}"
      NC_AUTH_JWT_SECRET: ${NC_AUTH_JWT_SECRET}
    depends_on:
      postgresql:
        condition: service_healthy

# docker-compose.network.yml
services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/ssl:/etc/nginx/ssl
    depends_on:
      - n8n
      - nocodb

  cloudflared:
    image: cloudflare/cloudflared:latest
    command: tunnel --config /etc/cloudflared/config.yml run
    volumes:
      - ./cloudflared:/etc/cloudflared
    depends_on:
      - nginx
```

### Environment Variables (.env)
**Lưu ý:** Bạn đã có file .env với dữ liệu chuẩn xác. Tham khảo env.txt cho cấu trúc. Nếu cần cập nhật, chỉ cần cập nhật env.txt và báo thay đổi .env.

**Cấu trúc chính từ env.txt:**
```bash
# PostgreSQL Local Credentials
POSTGRES_USER=
POSTGRES_PASSWORD=
POSTGRES_DB=

# NocoDB JWT Secret
NC_AUTH_JWT_SECRET=

# Domain Configuration
DOMAIN_NAME=n8n.ai-automation.cloud
BASE_DOMAIN=ai-automation.cloud
LETSENCRYPT_EMAIL=reploid.cc@gmail.com

# n8n Worker Local (kết nối VPS)
DB_POSTGRESDB_HOST=<IP_VPS>
QUEUE_BULL_REDIS_HOST=103.110.57.247
N8N_ENCRYPTION_KEY=<GIỐNG_VPS>
WEBHOOK_URL=https://n8n.masteryflow.cc/
```

### Setup Scripts
```bash
#!/bin/bash
# scripts/setup.sh

echo "🚀 Starting n8n Backend Infrastructure..."

# Validate environment
if [ ! -f .env ]; then
    echo "❌ .env file not found. Please create from env.txt template"
    exit 1
fi

# Start core services first
echo "📦 Starting core services..."
docker-compose -f docker-compose.yml -f docker-compose.core.yml up -d

# Wait for database
echo "⏳ Waiting for database..."
sleep 30

# Start UI services
echo "🖥️ Starting UI services..."
docker-compose -f docker-compose.yml -f docker-compose.ui.yml up -d

# Start network services
echo "🌐 Starting network services..."
docker-compose -f docker-compose.yml -f docker-compose.network.yml up -d

# Generate mock data
echo "📊 Generating mock data..."
./scripts/generate-mock-data.sh

echo "✅ Setup complete!"
echo "🔗 n8n: https://n8n.ai-automation.cloud"
echo "🔗 NocoDB: https://nocodb.ai-automation.cloud"
```

---

## 🗺️ User Journeys & Acceptance Scenarios

### Journey 1: First-Time Setup
**Scenario:** Developer sets up environment for first time

**Steps:**
1. Clone repository
2. Copy env.txt to .env and configure
3. Run `./scripts/setup.sh`
4. Access n8n at n8n.ai-automation.cloud
5. Access NocoDB at nocodb.ai-automation.cloud

**Acceptance Criteria:**
- [ ] Setup completes in < 30 minutes
- [ ] All services are healthy
- [ ] Database contains mock data
- [ ] Both UIs are accessible
- [ ] No manual intervention required

### Journey 2: Daily Development
**Scenario:** Developer starts work on existing environment

**Steps:**
1. Run `docker-compose up`
2. All services start automatically
3. Data persists from previous session
4. Begin workflow development

**Acceptance Criteria:**
- [ ] Startup time < 2 minutes
- [ ] All data persisted
- [ ] Services auto-recover from failures
- [ ] Performance meets SLA

### Journey 3: Workflow Testing
**Scenario:** Developer tests new workflow

**Steps:**
1. Create workflow in n8n
2. Configure with test credentials
3. Execute with mock data
4. Debug issues using NocoDB
5. Iterate quickly

**Acceptance Criteria:**
- [ ] Workflow execution < 5 seconds
- [ ] Mock data available for testing
- [ ] Debug information accessible
- [ ] No data corruption

---

## 📊 Success Metrics & KPIs

### Technical KPIs
| Metric | Baseline | Target | Measurement Method |
|--------|----------|--------|--------------------|
| Setup Time | 2+ hours | < 30 minutes | Time from clone to running |
| Development Speed | VPS baseline | +50% faster | Workflow test cycles |
| System Reliability | 90% | 99% uptime | Service monitoring |
| API Response Time | 1000ms | < 500ms | Automated testing |
| Data Integrity | 95% | 100% | Validation scripts |

### Business KPIs
| Metric | Target | Impact |
|--------|--------|--------|
| Development Productivity | +70% | Faster feature delivery |
| VPS Resource Usage | -50% | Cost reduction |
| Developer Satisfaction | 9/10 | Better experience |
| Time to Market | -30% | Faster releases |

### Monitoring & Alerting
- **Health Checks:** All services every 30 seconds
- **Performance Monitoring:** Response time tracking
- **Error Tracking:** Automatic error detection
- **Resource Monitoring:** CPU/Memory usage alerts

---

## 📅 Implementation Timeline & Milestones

### Phase 1: Foundation (Tháng 1-3)
**Goal:** Core infrastructure running locally

**Milestones:**
- **M1.1 (Week 2):** Docker Compose structure complete
- **M1.2 (Week 4):** PostgreSQL + migrations working
- **M1.3 (Week 6):** n8n backend functional
- **M1.4 (Week 8):** Redis queue system integrated
- **M1.5 (Week 10):** Basic networking setup
- **M1.6 (Week 12):** Phase 1 testing complete

**Deliverables:**
- [ ] Working Docker Compose files
- [ ] Database with schema
- [ ] n8n backend with queue mode
- [ ] Basic documentation

**Success Criteria:**
- All core services start successfully
- n8n can execute basic workflows
- Data persists between restarts

### Phase 2: User Interface (Tháng 4-6)
**Goal:** Complete UI and domain access

**Milestones:**
- **M2.1 (Week 14):** NocoDB integration
- **M2.2 (Week 16):** nginx reverse proxy
- **M2.3 (Week 18):** Domain configuration
- **M2.4 (Week 20):** SSL/HTTPS setup
- **M2.5 (Week 22):** cloudflared tunnel
- **M2.6 (Week 24):** Phase 2 testing complete

**Deliverables:**
- [ ] NocoDB database UI
- [ ] Domain-based access
- [ ] SSL certificates
- [ ] External tunnel access

**Success Criteria:**
- UIs accessible via domains
- SSL working properly
- External access functional

### Phase 3: Data & Optimization (Tháng 7-9)
**Goal:** Rich test data and performance optimization

**Milestones:**
- **M3.1 (Week 26):** Mock data generation scripts
- **M3.2 (Week 28):** Performance optimization
- **M3.3 (Week 30):** Testing framework
- **M3.4 (Week 32):** Documentation complete
- **M3.5 (Week 34):** User acceptance testing
- **M3.6 (Week 36):** Phase 3 sign-off

**Deliverables:**
- [ ] Automated mock data generation
- [ ] Performance tuning
- [ ] Complete documentation
- [ ] Testing procedures

**Success Criteria:**
- Performance targets met
- Rich test data available
- Documentation complete

### Phase 4: n8n Worker Local & Finalization (Tháng 10-12)
**Goal:** n8n Worker Local integration và hoàn thiện hệ thống

**Milestones:**
- **M4.1 (Week 38):** n8n Worker Local setup
- **M4.2 (Week 40):** VPS integration testing
- **M4.3 (Week 42):** Auto-scaling validation
- **M4.4 (Week 44):** Performance testing
- **M4.5 (Week 46):** Final optimization
- **M4.6 (Week 48):** Project completion

**Deliverables:**
- [ ] n8n Worker Local integration
- [ ] Hybrid worker functionality
- [ ] Auto-scaling mechanism
- [ ] Complete system testing
- [ ] Final documentation

**Success Criteria:**
- n8n Worker Local functional
- VPS integration working
- Auto-scaling hoạt động đúng
- All requirements met

---

## 🚨 Risk Assessment & Mitigation

### Technical Risks
| Risk | Probability | Impact | Mitigation Strategy |
|------|-------------|--------|-------------------|
| Docker compatibility issues | Medium | High | Version lock, testing matrix |
| Database migration failures | Low | High | Backup strategy, rollback plan |
| Network configuration problems | Medium | Medium | Incremental setup, testing |
| Performance degradation | Low | Medium | Monitoring, optimization |

### Business Risks
| Risk | Probability | Impact | Mitigation Strategy |
|------|-------------|--------|-------------------|
| Timeline delays | Medium | Medium | Agile approach, MVP focus |
| Resource constraints | Low | High | Phased implementation |
| Scope creep | Medium | Medium | Clear boundaries, change control |

### Mitigation Strategies
1. **Incremental Development:** Build and test incrementally
2. **Backup Plans:** Always have rollback procedures
3. **Documentation:** Maintain comprehensive documentation
4. **Testing:** Automated testing at each phase
5. **Monitoring:** Continuous health monitoring

---

## 🧪 Testing Strategy

### Testing Levels
1. **Unit Testing:** Individual service functionality
2. **Integration Testing:** Service-to-service communication
3. **System Testing:** End-to-end workflows
4. **Performance Testing:** Load and stress testing
5. **User Acceptance Testing:** Real-world scenarios

### Test Cases
#### Core Functionality
- [ ] Database connection and migrations
- [ ] n8n workflow execution
- [ ] Queue system functionality
- [ ] UI accessibility
- [ ] Domain routing

#### Performance Tests
- [ ] Startup time < 2 minutes
- [ ] API response < 500ms
- [ ] Database query < 100ms
- [ ] Memory usage < 8GB
- [ ] CPU usage < 50%

#### Error Scenarios
- [ ] Service failure recovery
- [ ] Network interruption handling
- [ ] Data corruption prevention
- [ ] Resource exhaustion handling

---

## 📚 Documentation Requirements

### Technical Documentation
- [ ] Architecture overview
- [ ] API documentation
- [ ] Database schema documentation
- [ ] Configuration guide
- [ ] Troubleshooting guide

### User Documentation
- [ ] Setup instructions
- [ ] User guide
- [ ] FAQ
- [ ] Best practices
- [ ] Performance tuning

### Operational Documentation
- [ ] Deployment procedures
- [ ] Monitoring setup
- [ ] Backup procedures
- [ ] Disaster recovery

---

## 🔄 Maintenance & Support

### Ongoing Maintenance
- Regular Docker image updates
- Security patches
- Performance monitoring
- Bug fixes và improvements

### Support Documentation
- Troubleshooting guides
- Performance tuning tips
- Best practices
- FAQ updates

---

## ✅ Definition of Done

### Phase Completion Criteria
- [ ] All functional requirements implemented
- [ ] All acceptance criteria met
- [ ] Performance targets achieved
- [ ] Documentation complete
- [ ] Testing passed
- [ ] User acceptance obtained

### Project Completion Criteria
- [ ] All phases completed successfully
- [ ] System meets all requirements
- [ ] Performance SLAs met
- [ ] Documentation delivered
- [ ] Training completed
- [ ] Handover successful

---

**Document Version:** 2.0 (Improved)  
**Last Updated:** 2024  
**Next Review:** After Phase 1 completion  
**Approval Status:** Pending stakeholder review 