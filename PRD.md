# Product Requirements Document (PRD)
## n8n Backend Infrastructure - Local Development Environment

---

## 📋 Overview

Dự án xây dựng một hệ thống backend infrastructure hoàn chỉnh cho n8n workflow automation, chạy 100% trên Docker tại localhost. Hệ thống bao gồm n8n backend, PostgreSQL database, NocoDB UI, nginx reverse proxy, cloudflared tunnel, và n8n hybrid worker để tạo môi trường test/debug nhanh chóng và hiệu quả.

**Giá trị cốt lõi:** Tạo môi trường phát triển local mạnh mẽ, nhanh hơn VPS, với khả năng kết nối hybrid worker để xử lý queue từ VPS production.

---

## 🎯 Goals and Objectives

### Mục tiêu chính:
1. **Tăng tốc độ phát triển:** Môi trường test/debug local nhanh hơn VPS
2. **Giảm tải VPS:** Sử dụng local worker để xử lý queue khi VPS quá tải
3. **Môi trường độc lập:** Hệ thống hoàn chỉnh chạy offline với domain local
4. **Dữ liệu phong phú:** Database với 50-200 records mỗi table để test đầy đủ

### Mục tiêu kỹ thuật:
- 100% containerized với Docker
- Domain local: ai-automation.cloud
- Kết nối hybrid với VPS masteryflow.cc
- Database schema tương thích với hệ thống queue và user-tier

---

## 🔍 Scope

### ✅ Bao gồm trong phiên bản đầu:
- **n8n Backend:** Container chạy n8n với cấu hình queue mode
- **PostgreSQL Database:** Schema "n8n" với cấu trúc đầy đủ từ migration files
- **NocoDB:** Giao diện UI quản lý PostgreSQL
- **Nginx:** Reverse proxy cho domain local
- **Cloudflared:** Tunnel kết nối nginx
- **Mock Data:** 50-200 records mỗi table cho testing
- **Docker Compose:** Orchestration toàn bộ hệ thống

### ❌ Không bao gồm:
- n8n Worker (triển khai sau cùng)
- Monitoring tools (RedisInsight, Grafana)
- Production deployment scripts
- Backup/restore mechanisms

---

## 👤 User Personas

### Primary User: Developer/Owner
- **Vai trò:** Chủ sở hữu và developer duy nhất
- **Nhu cầu:** 
  - Test/debug workflow nhanh chóng
  - Môi trường phát triển ổn định
  - Dữ liệu test phong phú
- **Pain Points:**
  - VPS chậm cho việc debug
  - Queue mode trên VPS làm chậm testing
  - Thiếu môi trường local hoàn chỉnh

---

## ⚙️ Functional Requirements

### 1. Container Infrastructure
**Priority: HIGH**
- [ ] Docker Compose orchestration cho tất cả services
- [ ] Persistent volumes cho PostgreSQL data
- [ ] Network configuration cho inter-service communication
- [ ] Environment variables management

### 2. n8n Backend Service
**Priority: HIGH**
- [ ] n8n container với queue mode configuration
- [ ] Kết nối PostgreSQL schema "n8n"
- [ ] Webhook endpoints configuration
- [ ] Credential management setup

### 3. Database Layer
**Priority: HIGH**
- [ ] PostgreSQL container với schema "n8n"
- [ ] Migration scripts từ database/ref folder
- [ ] Mock data generation (50-200 records/table)
- [ ] Support cho queue system và user-tier structure

### 4. NocoDB Interface
**Priority: MEDIUM**
- [ ] NocoDB container kết nối PostgreSQL
- [ ] UI access qua nocodb.ai-automation.cloud
- [ ] Database schema visualization
- [ ] CRUD operations interface

### 5. Networking & Domain
**Priority: MEDIUM**
- [ ] Nginx reverse proxy configuration
- [ ] Domain routing: n8n.ai-automation.cloud, nocodb.ai-automation.cloud
- [ ] Cloudflared tunnel setup
- [ ] SSL/HTTPS configuration

### 6. Configuration Management
**Priority: LOW**
- [ ] Multiple Docker Compose files structure
- [ ] Environment variables từ .env file (tuân thủ cursor_ai_rules)
- [ ] Setup script cho easy deployment
- [ ] Domain, port, service mapping documentation
- [ ] Auto-generate mock data scripts

---

## 🔧 Non-Functional Requirements

### Performance
- **Startup Time:** Toàn bộ stack khởi động < 2 phút
- **Response Time:** n8n API response < 500ms
- **Database:** Query response < 100ms cho basic operations

### Scalability
- **Resource Usage:** Tối ưu cho máy local (không giới hạn RAM/CPU)
- **Data Volume:** Support 50-200 records mỗi table
- **Concurrent Users:** 1 user (developer only)

### Reliability
- **Uptime:** 99% khi chạy local
- **Data Persistence:** PostgreSQL data không bị mất khi restart
- **Error Handling:** Graceful degradation khi service fail

### Security
- **Local Access:** Chỉ accessible từ localhost
- **Credential Storage:** Secure environment variables
- **Database Access:** Protected PostgreSQL credentials

---

## 🗺️ User Journeys

### Journey 1: Khởi động hệ thống
1. Developer chạy `docker-compose up`
2. Tất cả services khởi động song song
3. Database migrations tự động chạy
4. Mock data được generate
5. Access n8n qua n8n.ai-automation.cloud
6. Access NocoDB qua nocodb.ai-automation.cloud

### Journey 2: Test workflow
1. Developer tạo/import workflow trong n8n
2. Configure credentials và connections
3. Test workflow với mock data
4. Debug issues nhanh chóng
5. Verify results trong NocoDB

### Journey 3: Database management
1. Developer access NocoDB interface
2. Browse/edit database records
3. Add test data cho workflows
4. Monitor database performance
5. Export/backup data nếu cần

---

## 📊 Success Metrics

### Technical Metrics
- **Setup Time:** < 30 phút từ clone repo đến running system
- **Performance:** Local testing nhanh hơn VPS ít nhất 50%
- **Reliability:** Zero data loss trong quá trình development
- **Coverage:** 100% database schema từ migration files

### Business Metrics
- **Development Speed:** Giảm 70% thời gian test/debug workflow
- **Resource Efficiency:** Giảm tải VPS production
- **Developer Experience:** Môi trường development hoàn chỉnh

---

## 📅 Timeline

### Phase 1: Core Infrastructure (Tháng 1-3)
- [ ] Docker Compose setup
- [ ] PostgreSQL + schema migration
- [ ] n8n backend configuration
- [ ] Basic networking

### Phase 2: UI & Domain (Tháng 4-6)
- [ ] NocoDB integration
- [ ] Nginx reverse proxy
- [ ] Domain configuration
- [ ] Cloudflared tunnel

### Phase 3: Data & Testing (Tháng 7-9)
- [ ] Mock data generation
- [ ] Testing workflows
- [ ] Performance optimization
- [ ] Documentation

### Phase 4: Integration & Worker (Tháng 10-12)
- [ ] n8n Worker integration
- [ ] Hybrid worker testing
- [ ] Final optimization
- [ ] Production readiness

---

## 🏗️ System Architecture

### Container Stack
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Cloudflared   │    │     Nginx       │    │      n8n        │
│   (Tunnel)      │◄──►│ (Reverse Proxy) │◄──►│   (Backend)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                       │
                                ▼                       ▼
                       ┌─────────────────┐    ┌─────────────────┐
                       │     NocoDB      │    │   PostgreSQL    │
                       │   (Database UI) │◄──►│   (Database)    │
                       └─────────────────┘    └─────────────────┘
```

### Database Schema Structure
- **Core Tables:** Users, workflows, executions
- **Queue System:** Job queues, worker status
- **User Tiers:** Free, Pro, Premium, VIP
- **Logging:** Execution logs, usage tracking

---

## ✅ Technical Decisions

### Docker Compose Structure: **Multiple Files**
```
docker-compose.yml              # Main orchestration
docker-compose.core.yml         # Core services (PostgreSQL, n8n)
docker-compose.ui.yml           # UI services (NocoDB)
docker-compose.network.yml      # Network services (nginx, cloudflared)
docker-compose.worker.yml       # Worker services (phase 4)
```

**Lý do:** Modularity, flexibility, dễ maintenance và scalability

### Environment Variables: **Dual Environment Files**
- Sử dụng file `.env.local` cho local development (từ env.local.txt)
- Sử dụng file `.env.vps` cho VPS worker (từ env.vps.txt)
- Reference files với clear instructions

### Data Seeding: **Auto-generate**
- Script tự động generate 50-200 records mỗi table
- Chạy sau khi database migrations hoàn thành
- Dữ liệu mock realistic cho testing

### Network Security: **Open localhost**
- Tất cả services accessible từ localhost
- Không cần whitelist IPs
- Focus vào development experience

### Confirmed Assumptions:
1. **Local Development:** Chỉ chạy trên localhost, không cần production security
2. **Resource Unlimited:** Máy local đủ mạnh để chạy toàn bộ stack
3. **Data Persistence:** PostgreSQL data cần lưu vĩnh viễn
4. **Domain Local:** ai-automation.cloud sẽ point về localhost

---

## 📋 Technical Specifications

### Docker Compose Architecture
```yaml
# docker-compose.core.yml
services:
  postgresql:
    - Database với schema "n8n"
    - Persistent volumes
    - Auto-migration scripts
  n8n:
    - Backend service với queue mode
    - Kết nối PostgreSQL schema "n8n"
    - Environment từ .env file

# docker-compose.ui.yml  
services:
  nocodb:
    - Database UI interface
    - Kết nối PostgreSQL
    - Web interface port 8080

# docker-compose.network.yml
services:
  nginx:
    - Reverse proxy cho domain routing
    - SSL/HTTPS configuration
  cloudflared:
    - Tunnel service
    - Domain mapping
```

### Setup Commands
```bash
# Start tất cả services
docker-compose -f docker-compose.yml \
  -f docker-compose.core.yml \
  -f docker-compose.ui.yml \
  -f docker-compose.network.yml up -d

# Hoặc sử dụng script
./scripts/setup.sh
```

### Domain Mapping
```
n8n.ai-automation.cloud → nginx → n8n:5678
nocodb.ai-automation.cloud → nginx → nocodb:8080
```

### Database Schema
- Base schema từ migration files trong database/ref/
- Support cho queue system (queue.md requirements)
- Support cho user-tier system (user-tier.md requirements)
- Mock data: 50-200 records per table

---

## 🔄 Future Enhancements

### Phase 2 Features:
- n8n Worker integration với hybrid mode
- RedisInsight cho queue monitoring
- Backup/restore mechanisms
- Performance monitoring dashboard

### Long-term Vision:
- Production deployment scripts
- CI/CD integration
- Multi-environment support
- Advanced monitoring và alerting

---

**Document Version:** 1.0  
**Created:** 2024  
**Owner:** Developer/Product Owner  
**Status:** Ready for Implementation 