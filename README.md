# n8n Backend Infrastructure - Local Development Environment

[![Docker](https://img.shields.io/badge/Docker-20.10+-blue.svg)](https://www.docker.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-17+-blue.svg)](https://www.postgresql.org/)
[![n8n](https://img.shields.io/badge/n8n-latest-orange.svg)](https://n8n.io/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Hệ thống backend infrastructure hoàn chỉnh cho n8n workflow automation chạy 100% Docker tại localhost, với khả năng hybrid worker kết nối VPS production. **Enhanced với VPS Production Schema (16 tables, 88 indexes).**

---

## 🚀 Quick Start

### Prerequisites
- Docker 20.10+
- Docker Compose 2.0+
- 8GB RAM minimum
- 20GB free disk space

### 30-Second Setup
```bash
# 1. Clone repository
git clone <repository-url>
cd n8n-backend

# 2. Create environment files
cp env.local.txt .env.local
cp env.vps.txt .env.vps
# Edit .env.local and .env.vps with your configuration

# 3. Start local infrastructure
./scripts/setup-local.sh

# 4. Access services
# n8n Local: https://n8n.ai-automation.cloud
# NocoDB: https://nocodb.ai-automation.cloud
```

---

## 📋 Project Overview

### What This Project Provides
- **🏠 n8n Backend Local:** Fast development environment (normal mode)
- **🗄️ PostgreSQL Local:** VPS Production Schema với 16 tables + 88 indexes
- **🖥️ NocoDB Interface:** Web-based database management với production data structure
- **🌐 Domain Access:** External domains với Cloudflare tunnel
- **⚡ n8n Worker VPS:** Hybrid worker kết nối VPS (queue mode)
- **🔧 Complete Automation:** Dual-environment setup và management

### 🎉 VPS Schema Migration Complete (2024-12-01)
- ✅ **16 Production Tables** cloned from VPS
- ✅ **88 Performance Indexes** optimized for production workloads
- ✅ **3 System Views** for monitoring và health checks
- ✅ **Advanced Features:** User tiers, workflow versioning, comprehensive logging
- ✅ **Production Parity:** Localhost environment matches VPS exactly

### Database Schema Highlights
```sql
-- Advanced user management với tier system
users (free, pro, premium, vip), user_oauth, user_workflow_favorites

-- Comprehensive workflow system
workflows, workflow_versions, workflow_tier_limits, vip_custom_limits

-- Production-grade logging
log_workflow_executions, log_workflow_changes, log_user_activities
log_usage, log_transactions, worker_logs

-- Community features
ratings, orders, comments

-- System monitoring
v_data_summary, v_database_health, v_system_status
```

### Architecture Overview
```
EXTERNAL ACCESS (WORKING):
External Users → Cloudflare → Tunnel → nginx → Backend Services
                                              ├── n8n (172.21.0.20:5678)
                                              └── nocodb (172.21.0.30:8080)
                                                      ↓
                                              PostgreSQL (172.21.0.10:5432)
                                              ├── 16 Production Tables
                                              ├── 88 Performance Indexes
                                              └── 3 System Views

VPS ENVIRONMENT (.env.vps):
                       ┌─────────────────┐    ┌─────────────────┐
                       │ n8n Worker VPS  │    │   Redis VPS     │
                       │ (Hybrid Worker) │◄──►│ (103.110.87.247)│
                       └─────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │ PostgreSQL VPS  │
                       │ (Shared Schema) │
                       └─────────────────┘
```

---

## 📚 Documentation Index

### 🏗️ Implementation Documentation
| Document | Description | Status |
|----------|-------------|--------|
| [PRD.md](PRD.md) | Product Requirements Document | ✅ Complete |
| [prd-improved.md](prd-improved.md) | Enhanced PRD với detailed specs | ✅ Complete |
| [features.md](features.md) | Feature specifications (11 features) | ✅ Complete |
| [RULES.md](RULES.md) | Development rules và guidelines | ✅ Complete |

### 📋 RFC Implementation Roadmap
| RFC | Document | Implementation Prompt | Status | Timeline |
|-----|----------|----------------------|--------|----------|
| RFC-001 | [RFC-001-Docker-Foundation.md](RFCs/RFC-001-Docker-Foundation.md) | [implementation-prompt-RFC-001.md](RFCs/implementation-prompt-RFC-001.md) | ✅ Complete | Week 1-4 |
| RFC-002 | [RFC-002-PostgreSQL-Local.md](RFCs/RFC-002-PostgreSQL-Local.md) | [implementation-prompt-RFC-002.md](RFCs/implementation-prompt-RFC-002.md) | ✅ Complete | Week 5-6 |
| RFC-003 | [RFC-003-n8n-Backend-Local.md](RFCs/RFC-003-n8n-Backend-Local.md) | [implementation-prompt-RFC-003.md](RFCs/implementation-prompt-RFC-003.md) | ✅ Complete | Week 7-10 |
| RFC-004 | [RFC-004-NocoDB-Interface.md](RFCs/RFC-004-NocoDB-Interface.md) | [implementation-prompt-RFC-004.md](RFCs/implementation-prompt-RFC-004.md) | ✅ Complete | Week 11-12 |
| RFC-005 | [RFC-005-Networking-Domain.md](RFCs/RFC-005-Networking-Domain.md) | [implementation-prompt-RFC-005.md](RFCs/implementation-prompt-RFC-005.md) | ✅ Complete | Week 13-18 |
| RFC-006 | [RFC-006-Data-Worker.md](RFCs/RFC-006-Data-Worker.md) | [implementation-prompt-RFC-006.md](RFCs/implementation-prompt-RFC-006.md) | 🔄 Ready | Week 19-24 |

### 🔧 Technical Reference
| Document | Description | Purpose |
|----------|-------------|---------|
| [docs/PORT-URL-REFERENCE.md](docs/PORT-URL-REFERENCE.md) | Port & URL mapping reference | 🚨 **CRITICAL** - Prevent conflicts |
| [docs/setup-guide.md](docs/setup-guide.md) | Detailed setup instructions | Step-by-step setup |
| [docs/troubleshooting.md](docs/troubleshooting.md) | Common issues và solutions | Problem resolution |
| [docs/api-documentation.md](docs/api-documentation.md) | API endpoints documentation | Development reference |

### 📊 Memory Bank (AI Context)
| Document | Description | Purpose |
|----------|-------------|---------|
| [memory-bank/sumup.md](memory-bank/sumup.md) | Master index và navigator | AI context navigation |
| [memory-bank/progress.md](memory-bank/progress.md) | Current progress tracking | Implementation status |
| [memory-bank/activeContext.md](memory-bank/activeContext.md) | Current work focus | Active development context |

---

## 🌐 Service Access URLs

### ✅ External Access (WORKING)
| Service | External URL | Local URL | Port | Description |
|---------|--------------|-----------|------|-------------|
| **n8n Local** | [https://n8n.ai-automation.cloud](https://n8n.ai-automation.cloud) | [http://localhost:5678](http://localhost:5678) | 5678 | Main n8n interface |
| **NocoDB** | [https://nocodb.ai-automation.cloud](https://nocodb.ai-automation.cloud) | [http://localhost:8080](http://localhost:8080) | 8080 | Database web interface |
| **PostgreSQL Local** | Internal only | `localhost:5432` | 5432 | Local database server |

### VPS Environment (.env.vps)
| Service | VPS URL | Port | Description |
|---------|---------|------|-------------|
| **n8n VPS** | [https://n8n.masteryflow.cc](https://n8n.masteryflow.cc) | 443 | Production n8n |
| **Redis VPS** | `103.110.87.247:6379` | 6379 | Queue system |
| **PostgreSQL VPS** | `103.110.87.247:5432` | 5432 | Production database |

**⚠️ IMPORTANT:** Always check [docs/PORT-URL-REFERENCE.md](docs/PORT-URL-REFERENCE.md) before making changes!

---

## 🏗️ Project Structure

```
n8n-backend/
├── 📋 Documentation
│   ├── README.md                    # This file
│   ├── PRD.md                       # Product requirements
│   ├── features.md                  # Feature specifications
│   └── RULES.md                     # Development guidelines
│
├── 🏗️ RFCs (Implementation Roadmap)
│   ├── RFCS.md                      # Master RFC index
│   ├── RFC-001-Docker-Foundation.md
│   ├── RFC-002-PostgreSQL-Local.md
│   ├── RFC-003-n8n-Backend-Local.md
│   ├── RFC-004-NocoDB-Interface.md
│   ├── RFC-005-Networking-Domain.md
│   ├── RFC-006-Data-Worker.md
│   └── implementation-prompt-RFC-*.md
│
├── 🐳 Docker Configuration
│   ├── docker-compose.yml          # Main orchestration
│   ├── docker-compose.core.yml     # Core services (local)
│   ├── docker-compose.ui.yml       # UI services (local)
│   ├── docker-compose.network.yml  # Network services (local)
│   └── docker-compose.worker.yml   # Worker services (VPS)
│
├── 🔧 Scripts & Automation
│   ├── scripts/setup-local.sh       # Local environment setup
│   ├── scripts/setup-vps.sh         # VPS worker setup
│   ├── scripts/cleanup-all.sh       # Complete cleanup
│   ├── scripts/cleanup-n8n.sh       # Selective cleanup
│   ├── scripts/validate-env.sh      # Environment validation
│   ├── scripts/health-check-all.sh  # Health monitoring
│   └── scripts/wait-for-services.sh # Service monitoring
│
├── 🗄️ Database
│   ├── database/migrations/         # Auto-migration scripts
│   ├── database/ref/               # Reference migrations
│   └── database/seeds/             # Mock data scripts
│
├── 🌐 Network Configuration
│   ├── nginx/nginx.conf            # Reverse proxy config
│   ├── nginx/ssl/                  # SSL certificates
│   └── cloudflared/config.yml      # Tunnel configuration
│
├── 📚 Documentation
│   ├── docs/PORT-URL-REFERENCE.md  # 🚨 Port mapping reference
│   ├── docs/setup-guide.md         # Setup instructions
│   ├── docs/troubleshooting.md     # Problem resolution
│   └── docs/api-documentation.md   # API reference
│
├── 🧠 Memory Bank (AI Context)
│   ├── memory-bank/sumup.md        # Master navigator
│   ├── memory-bank/progress.md     # Progress tracking
│   └── memory-bank/activeContext.md # Current focus
│
└── ⚙️ Configuration
    ├── .env.local                  # Local environment variables
    ├── .env.vps                    # VPS environment variables
    ├── env.local.txt               # Local environment template
    ├── env.vps.txt                 # VPS environment template
    └── .cursorrules               # AI development rules
```

---

## 🚀 Implementation Phases

### Phase 1: Foundation Infrastructure (Week 1-10) ✅ COMPLETE + VPS ENHANCED
**Goal:** Core infrastructure running locally với production schema
- ✅ **RFC-001:** Docker Foundation & Environment Setup + VPS Schema Migration
- ✅ **RFC-002:** PostgreSQL Local Database + VPS Production Schema (16 tables, 88 indexes)
- ✅ **RFC-003:** n8n Backend Local Service

**Milestone:** n8n local backend functional với VPS production schema

### Phase 2: Interface & Networking (Week 11-18) ✅ COMPLETE
**Goal:** Complete UI và domain access
- ✅ **RFC-004:** NocoDB Database Interface với production data structure
- ✅ **RFC-005:** Networking & Domain Infrastructure

**Milestone:** Full UI access via domains với external access verified

### 🎉 VPS Schema Migration Achievement (2024-12-01)
**Status:** ✅ **PRODUCTION SCHEMA SUCCESSFULLY CLONED**
- ✅ **16 Production Tables** migrated from VPS
- ✅ **88 Performance Indexes** optimized for production workloads
- ✅ **3 System Views** for real-time monitoring
- ✅ **Advanced Features:** User tiers (free/pro/premium/vip), workflow versioning, comprehensive logging
- ✅ **Production Parity:** Localhost environment matches VPS exactly

### Phase 3: Advanced Features (Week 19-24) 🔄 READY FOR ENHANCED IMPLEMENTATION
**Goal:** Data management và hybrid worker với production schema
- 🔄 **RFC-006:** Data Management & n8n Worker VPS
  - Mock data generation cho 16 production tables
  - n8n Worker Local với VPS connectivity
  - Auto-scaling based on queue backlog
  - Production integration với enhanced schema

**Milestone:** Complete system với VPS integration và production-grade data

---

## 🔧 Environment Configuration

### Dual Environment Setup

#### Local Environment (.env.local)
```bash
# PostgreSQL Local
POSTGRES_USER=n8nuser
POSTGRES_PASSWORD=your_secure_password_here
POSTGRES_DB=n8ndb

# n8n Local Backend
N8N_HOST=localhost
N8N_PROTOCOL=http
N8N_ENCRYPTION_KEY=your_32_character_encryption_key

# Domain Configuration
BASE_DOMAIN=ai-automation.cloud
NC_AUTH_JWT_SECRET=your_jwt_secret_here
```

#### VPS Environment (.env.vps)
```bash
# VPS Connection
N8N_HOST=103.110.87.247
N8N_PROTOCOL=https
N8N_ENCRYPTION_KEY=your_32_character_encryption_key

# Redis VPS
QUEUE_BULL_REDIS_HOST=103.110.87.247
QUEUE_BULL_REDIS_PORT=6379

# PostgreSQL VPS
DB_POSTGRESDB_HOST=103.110.87.247
DB_POSTGRESDB_DATABASE=n8nsupport_vps
```

### Setup Instructions
1. Copy `env.local.txt` to `.env.local`
2. Copy `env.vps.txt` to `.env.vps`
3. Fill in all required variables
4. Run `./scripts/validate-env.sh` to verify
5. Run `./scripts/setup-local.sh` for local environment
6. Run `./scripts/setup-vps.sh` for VPS worker

---

## 🗄️ Database Schema

### Core n8n Tables
- `users` - User accounts và authentication
- `workflows` - Workflow definitions
- `executions` - Workflow execution history
- `credentials` - Stored credentials

### Extended Tables (New Features)
- `user_favorites` - User workflow favorites
- `comments` - Comments on workflows/executions
- `ratings` - Workflow ratings và reviews

### Queue System Tables
- `execution_queue` - Job queue management
- `worker_status` - Worker health tracking
- `job_logs` - Execution logging

---

## 🔍 Troubleshooting

### Common Issues
1. **Port conflicts:** Check [PORT-URL-REFERENCE.md](docs/PORT-URL-REFERENCE.md)
2. **Environment issues:** Run `./scripts/validate-env.sh`
3. **Service health:** Run `./scripts/health-check-all.sh`
4. **Network problems:** Check Docker network configuration

### Environment-Specific Issues
```bash
# Local environment diagnostics
./scripts/health-check-local.sh

# VPS worker diagnostics
./scripts/health-check-vps.sh

# Cross-environment validation
./scripts/validate-environments.sh
```

### Get Help
- **Troubleshooting Guide:** [docs/troubleshooting.md](docs/troubleshooting.md)
- **Port Reference:** [docs/PORT-URL-REFERENCE.md](docs/PORT-URL-REFERENCE.md)
- **Setup Guide:** [docs/setup-guide.md](docs/setup-guide.md)

---

## 🤝 Contributing

### Development Workflow
1. Read [RULES.md](RULES.md) for development guidelines
2. Check current progress in [memory-bank/progress.md](memory-bank/progress.md)
3. Follow RFC implementation sequence
4. Update documentation when making changes

### Implementation Rules
- **Sequential Implementation:** Complete each RFC before moving to next
- **Documentation First:** Update docs before coding
- **Port Management:** Always check PORT-URL-REFERENCE.md
- **Environment Safety:** Use appropriate .env.local or .env.vps files

---

## 📊 Project Status

### Current Status: **Phase 2 Complete - RFC-005 Verified Working**
- ✅ **Planning Phase:** Complete (PRD, Features, RFCs)
- ✅ **Implementation Phase:** RFC-001 đến RFC-005 Complete
- ✅ **External Access:** n8n.ai-automation.cloud, nocodb.ai-automation.cloud verified working
- 🔄 **Phase 3 Ready:** RFC-006 Data Management & n8n Worker VPS

### Next Steps
1. **RFC-006 Implementation:** Data Management & n8n Worker VPS
2. **Mock Data Generation:** Create realistic test data cho development
3. **VPS Worker Setup:** n8n worker local kết nối VPS Redis và PostgreSQL
4. **Performance Validation:** Monitor system performance với external access

### Key Achievements
- **5/6 RFCs Complete:** 83% overall project completion
- **External Access Working:** Both domains accessible và verified
- **All Performance Targets Met:** Setup time, API response, container startup
- **5/5 Services Healthy:** postgres, n8n, nocodb, nginx, cloudflared

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **n8n Team** - For the amazing workflow automation platform
- **NocoDB Team** - For the excellent database UI
- **Docker Community** - For containerization technology
- **PostgreSQL Team** - For the robust database system

---

**⚠️ IMPORTANT REMINDERS:**
1. **Always check [PORT-URL-REFERENCE.md](docs/PORT-URL-REFERENCE.md)** before adding services
2. **Use correct environment file** (.env.local vs .env.vps)
3. **Follow sequential RFC implementation** - no parallel development
4. **Update documentation** when making changes
5. **Test thoroughly** at each phase
6. **Backup data** before major changes

**Project Version:** 2.0 (Dual Environment)  
**Last Updated:** 2024  
**Maintained By:** Development Team