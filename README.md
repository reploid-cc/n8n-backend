# n8n Backend Infrastructure - Local Development Environment

[![Docker](https://img.shields.io/badge/Docker-20.10+-blue.svg)](https://www.docker.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-blue.svg)](https://www.postgresql.org/)
[![n8n](https://img.shields.io/badge/n8n-latest-orange.svg)](https://n8n.io/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Hệ thống backend infrastructure hoàn chỉnh cho n8n workflow automation chạy 100% Docker tại localhost, với khả năng hybrid worker kết nối VPS production.

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

# 2. Create environment file
cp env.txt .env
# Edit .env with your configuration

# 3. Start infrastructure
./scripts/setup.sh

# 4. Access services
# n8n: http://localhost:5678
# NocoDB: http://localhost:8080
```

---

## 📋 Project Overview

### What This Project Provides
- **🏠 Local n8n Backend:** Fast development environment (normal mode)
- **🗄️ PostgreSQL Local:** Isolated database với schema "n8n"
- **🖥️ NocoDB Interface:** Web-based database management
- **🌐 Domain Access:** Local domains với SSL/HTTPS
- **⚡ n8n Worker Local:** Hybrid worker kết nối VPS (queue mode)
- **🔧 Complete Automation:** One-command setup và management

### Architecture Overview
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Cloudflared   │    │     nginx       │    │   n8n Local     │
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
| RFC-001 | [RFC-001-Docker-Foundation.md](RFCs/RFC-001-Docker-Foundation.md) | [implementation-prompt-RFC-001.md](RFCs/implementation-prompt-RFC-001.md) | ✅ Ready | Week 1-4 |
| RFC-002 | [RFC-002-PostgreSQL-Local.md](RFCs/RFC-002-PostgreSQL-Local.md) | [implementation-prompt-RFC-002.md](RFCs/implementation-prompt-RFC-002.md) | ✅ Ready | Week 5-6 |
| RFC-003 | [RFC-003-n8n-Backend-Local.md](RFCs/RFC-003-n8n-Backend-Local.md) | [implementation-prompt-RFC-003.md](RFCs/implementation-prompt-RFC-003.md) | ✅ Ready | Week 7-10 |
| RFC-004 | [RFC-004-NocoDB-Interface.md](RFCs/RFC-004-NocoDB-Interface.md) | [implementation-prompt-RFC-004.md](RFCs/implementation-prompt-RFC-004.md) | ✅ Ready | Week 11-12 |
| RFC-005 | [RFC-005-Networking-Domain.md](RFCs/RFC-005-Networking-Domain.md) | [implementation-prompt-RFC-005.md](RFCs/implementation-prompt-RFC-005.md) | ✅ Ready | Week 13-18 |
| RFC-006 | [RFC-006-Data-Worker.md](RFCs/RFC-006-Data-Worker.md) | [implementation-prompt-RFC-006.md](RFCs/implementation-prompt-RFC-006.md) | ✅ Ready | Week 19-24 |

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

| Service | Local URL | Tunnel URL | Port | Description |
|---------|-----------|------------|------|-------------|
| **n8n Local** | [http://localhost:5678](http://localhost:5678) | [https://n8n.ai-automation.cloud](https://n8n.ai-automation.cloud) | 5678 | Main n8n interface |
| **NocoDB** | [http://localhost:8080](http://localhost:8080) | [https://nocodb.ai-automation.cloud](https://nocodb.ai-automation.cloud) | 8080 | Database web interface |
| **PostgreSQL** | `localhost:5432` | Internal only | 5432 | Database server |

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
│   ├── docker-compose.core.yml     # Core services
│   ├── docker-compose.ui.yml       # UI services
│   ├── docker-compose.network.yml  # Network services
│   └── docker-compose.worker.yml   # Worker services
│
├── 🔧 Scripts & Automation
│   ├── scripts/setup.sh             # Main setup script
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
    ├── .env                        # Environment variables
    ├── env.txt                     # Environment template
    └── .cursorrules               # AI development rules
```

---

## 🚀 Implementation Phases

### Phase 1: Foundation Infrastructure (Week 1-10)
**Goal:** Core infrastructure running locally
- ✅ **RFC-001:** Docker Foundation & Environment Setup
- ✅ **RFC-002:** PostgreSQL Local Database  
- ✅ **RFC-003:** n8n Backend Local Service

**Milestone:** n8n local backend functional với PostgreSQL

### Phase 2: Interface & Networking (Week 11-18)
**Goal:** Complete UI và domain access
- ✅ **RFC-004:** NocoDB Database Interface
- ✅ **RFC-005:** Networking & Domain Infrastructure

**Milestone:** Full UI access via domains với SSL

### Phase 3: Advanced Features (Week 19-24)
**Goal:** Data management và hybrid worker
- ✅ **RFC-006:** Data Management & n8n Worker Local

**Milestone:** Complete system với VPS integration

---

## 🔧 Environment Configuration

### Required Environment Variables
```bash
# PostgreSQL Local
POSTGRES_DB=n8n_local
POSTGRES_USER=n8n_user
POSTGRES_PASSWORD=your_secure_password_here

# n8n Configuration
N8N_HOST=n8n.ai-automation.cloud
N8N_ENCRYPTION_KEY=your_32_character_encryption_key

# Domain Configuration
BASE_DOMAIN=ai-automation.cloud
NC_AUTH_JWT_SECRET=your_jwt_secret_here
```

### Setup Instructions
1. Copy `env.txt` to `.env`
2. Fill in all required variables
3. Run `./scripts/validate-env.sh` to verify
4. Run `./scripts/setup.sh` to start

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

### Quick Diagnostics
```bash
# Check all services
./scripts/health-check-all.sh

# View service logs
docker-compose logs postgresql-local
docker-compose logs n8n-backend

# Check port usage
netstat -tlnp | grep :5678
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
- **Environment Safety:** Follow cursor_ai_rules for .env management

---

## 📊 Project Status

### Current Status: **Ready for Implementation**
- ✅ **Planning Phase:** Complete (PRD, Features, RFCs)
- ⏳ **Implementation Phase:** Ready to start RFC-001
- ⏳ **Testing Phase:** Pending implementation
- ⏳ **Deployment Phase:** Pending implementation

### Next Steps
1. **Start RFC-001 Implementation:** Docker Foundation & Environment Setup
2. **Environment Setup:** Create .env from env.txt template
3. **Validation:** Verify all prerequisites
4. **Implementation:** Follow RFC-001 specifications

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
2. **Follow sequential RFC implementation** - no parallel development
3. **Update documentation** when making changes
4. **Test thoroughly** at each phase
5. **Backup data** before major changes

**Project Version:** 1.0  
**Last Updated:** 2024  
**Maintained By:** Development Team #   n 8 n - b a c k e n d  
 