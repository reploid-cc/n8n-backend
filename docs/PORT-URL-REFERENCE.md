# Port & URL Reference - Updated RFC-005 Complete

⚠️ **CRITICAL REFERENCE** - Always check this file before adding new services to prevent port conflicts!

## Service Access URLs

| Service | URL External | URL Local | Port | IP Address | Status | RFC |
|---------|--------------|-----------|------|------------|--------|-----|
| **n8n Local** | [https://n8n.ai-automation.cloud](https://n8n.ai-automation.cloud) | [http://localhost:5678](http://localhost:5678) | 5678 | 172.21.0.20 | ✅ Working | RFC-003 |
| **PostgreSQL** | Internal only | `localhost:5432` | 5432 | 172.21.0.10 | ✅ Active | RFC-002 |
| **NocoDB** | [https://nocodb.ai-automation.cloud](https://nocodb.ai-automation.cloud) | [http://localhost:8080](http://localhost:8080) | 8080 | 172.21.0.30 | ✅ Working | RFC-004 |
| **nginx** | Proxy only | localhost:80,443 | 80,443 | 172.21.0.40 | ✅ Active | RFC-005 |
| **cloudflared** | Tunnel active | Internal only | - | 172.21.0.50 | ✅ Active | RFC-005 |
| **n8n Worker** | VPS connection | Internal only | - | 172.21.0.60 | 🔄 RFC-006 | RFC-006 |

## Network Configuration

### Docker Network: n8n-local-network
- **Subnet:** 172.21.0.0/16
- **Gateway:** 172.21.0.1
- **Driver:** bridge
- **Status:** ✅ Active (RFC-001)

### Static IP Assignments
```
172.21.0.10 - postgres (RFC-002) ✅
172.21.0.20 - n8n (RFC-003) ✅
172.21.0.30 - nocodb (RFC-004) ✅
172.21.0.40 - nginx (RFC-005) ✅
172.21.0.50 - cloudflared (RFC-005) ✅
172.21.0.60 - n8n-worker (RFC-006) 🔄
```

## Volume Mapping

| Volume Name | Mount Point | Container | Purpose | Size Estimate |
|-------------|-------------|-----------|---------|---------------|
| `postgres_data` | `/var/lib/postgresql/data` | postgres | PostgreSQL data persistence | 1-5GB |
| `n8n_data` | `/home/node/.n8n` | n8n | n8n workflows and settings | 100MB-1GB |
| `nginx_logs` | `/var/log/nginx` | nginx | nginx access and error logs | 10-100MB |
| `cloudflared_config` | `/home/nonroot/.cloudflared` | cloudflared | Cloudflare tunnel config | 1-10MB |

## Environment Variables Reference

### Required Variables (RFC-001)
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

### Optional Variables (Future RFCs)
```bash
# VPS Connection (RFC-006)
VPS_POSTGRES_HOST=<IP_VPS>
VPS_POSTGRES_USER=<VPS_USER>
VPS_POSTGRES_PASSWORD=<VPS_PASSWORD>
VPS_POSTGRES_DB=<VPS_DB>

# Redis VPS (RFC-006)
QUEUE_BULL_REDIS_HOST=103.110.87.247
QUEUE_BULL_REDIS_PORT=6379

# SSL Configuration (RFC-005)
LETSENCRYPT_EMAIL=your_email@domain.com
```

## Database Schema Overview

### VPS Production Schema Cloned (2024-12-01)
- **Status:** ✅ **PRODUCTION SCHEMA MIGRATED**
- **Total Tables:** 16 production tables from VPS
- **Total Indexes:** 88 performance-optimized indexes
- **System Views:** 3 monitoring views
- **Migration File:** `database/migrations/20241201_upgrade_vps_schema.sql`

### Core Tables (16 VPS Production Tables):
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

### System Monitoring Views:
- **v_data_summary** - Data overview và record counts
- **v_database_health** - Database health metrics (19 tables, 88 indexes, 16 MB)
- **v_system_status** - System component status

### Performance Features:
- **88 Indexes Total:** Primary keys, unique constraints, performance indexes
- **Advanced Indexing:** GIN indexes cho JSONB, composite indexes, partial indexes
- **Foreign Key Integrity:** Complete referential integrity across all tables
- **Tier System Support:** Advanced user tier logic (free/pro/premium/vip)
- **Credit System:** Usage tracking và credit consumption logic

## Health Check Commands

### Service Health
```bash
# Check all services
./scripts/health-check-all.sh

# Check specific service
docker inspect --format='{{.State.Health.Status}}' postgres
docker inspect --format='{{.State.Health.Status}}' n8n

# Check network and volumes
docker network inspect n8n-local-network
docker volume inspect postgres_data
```

### Connectivity Tests
```bash
# PostgreSQL connectivity
docker exec postgres pg_isready -U $POSTGRES_USER -d $POSTGRES_DB

# n8n API connectivity
curl -f http://localhost:5678/healthz

# Resource usage
docker stats --no-stream
```

## Troubleshooting

### Common Issues
1. **Port 5678 already in use**
   - Check: `netstat -tlnp | grep :5678`
   - Solution: Stop conflicting service or change port

2. **Port 5432 already in use**
   - Check: `netstat -tlnp | grep :5432`
   - Solution: Stop local PostgreSQL or change port

3. **Network subnet conflict**
   - Check: `docker network ls`
   - Solution: Use different subnet in docker-compose.yml

4. **Volume permission issues**
   - Check: `docker volume inspect postgres_data`
   - Solution: Verify Docker has proper permissions

### Service Logs
```bash
# View service logs
docker-compose logs postgres
docker-compose logs n8n
docker-compose logs nocodb

# Follow logs in real-time
docker-compose logs -f postgres
docker-compose logs -f n8n
docker-compose logs -f nocodb
```

## Implementation Status

### ✅ Completed RFCs
- ✅ **RFC-001:** Docker Foundation & Environment Setup + VPS Schema Migration
- ✅ **RFC-002:** PostgreSQL Local Database + VPS Production Schema
- ✅ **RFC-003:** n8n Backend Local Service
- ✅ **RFC-004:** NocoDB Database Interface
- ✅ **RFC-005:** Networking & Domain Infrastructure

### 🎉 VPS Schema Migration Complete (2024-12-01)
- ✅ **16 Production Tables** cloned from VPS
- ✅ **88 Performance Indexes** created
- ✅ **3 System Views** functional
- ✅ **100% Data Integrity** preserved
- ✅ **Zero Downtime** migration với backup safety

### 🔄 Current RFC
- 🔄 **RFC-006:** Data Management & n8n Worker VPS (Phase 3)
  - Mock data generation cho 16 tables
  - n8n Worker Local với VPS connectivity
  - Auto-scaling based on queue backlog
  - Production integration với enhanced schema

### External Access Status
- **n8n:** https://n8n.ai-automation.cloud ✅ **WORKING**
- **NocoDB:** https://nocodb.ai-automation.cloud ✅ **WORKING**
- **Cloudflare Tunnel:** 4 connections active ✅ **HEALTHY**

### Performance Metrics Achieved
- **Setup Time:** < 30 minutes ✅
- **API Response:** < 500ms ✅
- **Container Startup:** < 2 minutes ✅
- **Service Health:** 100% healthy containers ✅
- **External Access:** Verified working ✅
- **Database Performance:** 88 indexes, 16 MB optimized ✅

## Security Notes

### Network Security
- All services run on internal Docker network
- Only necessary ports exposed to localhost
- No direct external access to databases
- SSL/HTTPS will be implemented in RFC-005

### Data Security
- PostgreSQL data encrypted at rest
- Environment variables for sensitive data
- No hardcoded credentials in code
- Backup procedures will be implemented

---

**⚠️ IMPORTANT:** Always update this file when:
- Adding new services
- Changing port mappings
- Modifying network configuration
- Adding new environment variables

**Last Updated:** RFC-005 Complete - External Access Verified  
**Next Update:** RFC-006 Implementation

---

## 🔗 Quick Access Links

### External URLs (WORKING)
- **n8n Interface:** [https://n8n.ai-automation.cloud](https://n8n.ai-automation.cloud)
- **NocoDB Interface:** [https://nocodb.ai-automation.cloud](https://nocodb.ai-automation.cloud)

### Local Development URLs
- **n8n Local:** [http://localhost:5678](http://localhost:5678)
- **NocoDB Local:** [http://localhost:8080](http://localhost:8080)
- **PostgreSQL:** `psql -h localhost -p 5432 -U ${POSTGRES_USER} -d ${POSTGRES_DB}`

### Health Check Commands
```bash
# Check all services
docker ps

# Check external access
curl -f https://n8n.ai-automation.cloud
curl -f https://nocodb.ai-automation.cloud

# Check cloudflared tunnel
docker logs cloudflared --tail 10
```

---

## 🌐 Network Configuration

### Docker Network Details
```yaml
Network Name: n8n-local-network
Driver: bridge
Subnet: 172.21.0.0/16
Gateway: 172.21.0.1
```

### IP Address Allocation
```
172.21.0.1    - Gateway
172.21.0.10   - postgres
172.21.0.20   - n8n
172.21.0.30   - nocodb
172.21.0.40   - nginx
172.21.0.50   - cloudflared
172.21.0.60   - n8n-worker
172.21.0.70   - [Reserved for future services]
172.21.0.80   - [Reserved for future services]
172.21.0.90   - [Reserved for future services]
```

---

## 📦 Volume Mapping

| Volume Name | Mount Point | Container | Purpose | Size Estimate |
|-------------|-------------|-----------|---------|---------------|
| `postgres_data` | `/var/lib/postgresql/data` | postgres | PostgreSQL data persistence | 1-5GB |
| `n8n_data` | `/home/node/.n8n` | n8n | n8n workflows and settings | 100MB-1GB |
| `nginx_logs` | `/var/log/nginx` | nginx | nginx access and error logs | 10-100MB |
| `cloudflared_config` | `/home/nonroot/.cloudflared` | cloudflared | Cloudflare tunnel config | 1-10MB |

---

## 🔧 Environment Variables Reference

### Required Variables
```bash
# PostgreSQL Local Configuration
POSTGRES_DB=n8n_local
POSTGRES_USER=n8n_user
POSTGRES_PASSWORD=your_secure_password_here

# n8n Configuration
N8N_HOST=n8n.ai-automation.cloud
N8N_ENCRYPTION_KEY=your_32_character_encryption_key
N8N_PROTOCOL=https

# Domain Configuration
BASE_DOMAIN=ai-automation.cloud
DOMAIN_NAME=n8n.ai-automation.cloud

# NocoDB Configuration
NC_AUTH_JWT_SECRET=your_jwt_secret_here

# SSL Configuration
LETSENCRYPT_EMAIL=your_email@domain.com
```

### Optional Variables (VPS Integration)
```bash
# VPS Database Connection (for n8n Worker)
VPS_POSTGRES_HOST=your_vps_ip
VPS_POSTGRES_USER=n8n_vps_user
VPS_POSTGRES_PASSWORD=vps_password
VPS_POSTGRES_DB=n8n_vps

# VPS Redis Connection
VPS_REDIS_HOST=103.110.87.247
VPS_REDIS_PORT=6379

# Webhook Configuration
WEBHOOK_URL=https://n8n.masteryflow.cc/
```

---

## 🚨 Port Conflict Prevention

### Ports Currently Used
- **5432** - PostgreSQL (localhost only)
- **5678** - n8n Backend (localhost only)
- **8080** - NocoDB (localhost only)
- **80** - nginx HTTP (public)
- **443** - nginx HTTPS (public)

### Ports Reserved for Future Use
- **3000** - Monitoring dashboard (future)
- **9090** - Prometheus (future)
- **3001** - Grafana (future)

### How to Check Port Availability
```bash
# Check if port is in use
netstat -tlnp | grep :5678
lsof -i :5678

# Check all Docker container ports
docker ps --format "table {{.Names}}\t{{.Ports}}"

# Check network connectivity
docker network inspect n8n-local-network
```

---

## 🔍 Troubleshooting Common Issues

### Port Conflicts
```bash
# Problem: Port already in use
# Solution: Find and stop conflicting process
sudo lsof -i :5678
sudo kill -9 <PID>

# Or change port in docker-compose file
ports:
  - "127.0.0.1:5679:5678"  # Use different external port
```

### Network Issues
```bash
# Problem: Cannot connect between containers
# Solution: Check network configuration
docker network inspect n8n-local-network

# Verify container IPs
docker inspect postgres | grep IPAddress
docker inspect n8n | grep IPAddress
```

### Domain Resolution Issues
```bash
# Problem: Domain not resolving locally
# Solution: Add to hosts file (Windows: C:\Windows\System32\drivers\etc\hosts)
127.0.0.1 n8n.ai-automation.cloud
127.0.0.1 nocodb.ai-automation.cloud
```

### SSL Certificate Issues
```bash
# Problem: SSL certificate errors
# Solution: Check certificate validity
openssl x509 -in nginx/ssl/cert.pem -text -noout

# Generate self-signed certificate for development
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx/ssl/key.pem \
  -out nginx/ssl/cert.pem \
  -subj "/CN=*.ai-automation.cloud"
```

---

## 📊 Health Check Commands

### Service Status
```bash
# Check all services
./scripts/health-check-all.sh

# Check specific service
docker inspect --format='{{.State.Health.Status}}' postgres
docker inspect --format='{{.State.Health.Status}}' n8n

# Check service logs
docker-compose logs postgres
docker-compose logs n8n
docker-compose logs nocodb
```

### Network Connectivity
```bash
# Test database connection
docker exec postgres pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}

# Test n8n API
curl -f http://localhost:5678/healthz

# Test NocoDB
curl -f http://localhost:8080/api/v1/health

# Test internal network connectivity
docker exec n8n ping postgres
docker exec nocodb ping postgres
```

---

## 🔄 Service Management Commands

### Start/Stop Services
```bash
# Start all services
docker-compose -f docker-compose.yml -f docker-compose.core.yml up -d

# Start specific service group
docker-compose -f docker-compose.yml -f docker-compose.ui.yml up -d

# Stop all services
docker-compose down

# Restart specific service
docker-compose restart postgres
```

### View Service Information
```bash
# List all containers
docker ps

# View resource usage
docker stats

# View network information
docker network ls
docker network inspect n8n-local-network

# View volume information
docker volume ls
docker volume inspect postgres_data
```

---

## 📚 Related Documentation

- **Setup Guide:** [docs/setup-guide.md](./setup-guide.md)
- **Troubleshooting:** [docs/troubleshooting.md](./troubleshooting.md)
- **API Documentation:** [docs/api-documentation.md](./api-documentation.md)
- **Development Guide:** [docs/development-guide.md](./development-guide.md)

---

## 📝 Change Log

| Date | Change | Author | RFC |
|------|--------|--------|-----|
| 2024 | Initial port allocation | System | RFC-001 |
| 2024 | Added NocoDB configuration | System | RFC-004 |
| 2024 | Added nginx proxy configuration | System | RFC-005 |
| 2024 | Added n8n worker configuration | System | RFC-006 |

---

**⚠️ IMPORTANT NOTES:**
1. **Always update this file** when adding new services or changing ports
2. **Check port availability** before assigning new ports
3. **Use localhost binding** (127.0.0.1) for security
4. **Document any changes** in the change log section
5. **Test connectivity** after any network changes

**Document Version:** 1.0  
**Last Updated:** 2024  
**Maintained By:** Development Team 