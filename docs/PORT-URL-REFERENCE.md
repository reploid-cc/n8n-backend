# Port & URL Reference Guide
## n8n Backend Infrastructure - Local Development Environment

---

## 📋 Overview

File này chứa tất cả thông tin về ports, URLs, và network configuration để tránh conflicts và giúp developers dễ dàng tham chiếu khi phát triển.

**⚠️ QUAN TRỌNG:** Luôn kiểm tra file này trước khi thêm services mới hoặc thay đổi port configuration!

---

## 🌐 Service Access URLs

| Service | URL Local | URL Tunnel | Port | IP Address | Container Name | Description |
|---------|-----------|------------|------|------------|----------------|-------------|
| **n8n Local** | [http://localhost:5678](http://localhost:5678) | [https://n8n.ai-automation.cloud](https://n8n.ai-automation.cloud) | 5678 | 172.20.0.20 | n8n-backend | Main n8n interface (normal mode) |
| **NocoDB** | [http://localhost:8080](http://localhost:8080) | [https://nocodb.ai-automation.cloud](https://nocodb.ai-automation.cloud) | 8080 | 172.20.0.30 | nocodb-ui | Database web interface |
| **PostgreSQL** | localhost:5432 | Internal only | 5432 | 172.20.0.10 | postgresql-local | Database server |
| **nginx** | localhost:80,443 | Proxy only | 80,443 | 172.20.0.40 | nginx-proxy | Reverse proxy |
| **cloudflared** | Internal only | Tunnel service | - | 172.20.0.50 | cloudflared-tunnel | Cloudflare tunnel |
| **n8n Worker** | Internal only | VPS connection | - | 172.20.0.60 | n8n-worker | Queue worker (hybrid mode) |

---

## 🔗 Quick Access Links

### Development URLs
- **n8n Interface:** [http://localhost:5678](http://localhost:5678)
- **Database UI:** [http://localhost:8080](http://localhost:8080)
- **PostgreSQL:** `psql -h localhost -p 5432 -U ${POSTGRES_USER} -d ${POSTGRES_DB}`

### Production URLs (via Tunnel)
- **n8n Production:** [https://n8n.ai-automation.cloud](https://n8n.ai-automation.cloud)
- **NocoDB Production:** [https://nocodb.ai-automation.cloud](https://nocodb.ai-automation.cloud)

---

## 🌐 Network Configuration

### Docker Network Details
```yaml
Network Name: n8n-local-network
Driver: bridge
Subnet: 172.20.0.0/16
Gateway: 172.20.0.1
```

### IP Address Allocation
```
172.20.0.1    - Gateway
172.20.0.10   - PostgreSQL Local
172.20.0.20   - n8n Backend Local
172.20.0.30   - NocoDB UI
172.20.0.40   - nginx Proxy
172.20.0.50   - cloudflared Tunnel
172.20.0.60   - n8n Worker Local
172.20.0.70   - [Reserved for future services]
172.20.0.80   - [Reserved for future services]
172.20.0.90   - [Reserved for future services]
```

---

## 📦 Volume Mapping

| Volume Name | Mount Point | Container | Purpose | Size Estimate |
|-------------|-------------|-----------|---------|---------------|
| `postgres_data` | `/var/lib/postgresql/data` | postgresql-local | PostgreSQL data persistence | 1-5GB |
| `n8n_data` | `/home/node/.n8n` | n8n-backend | n8n workflows and settings | 100MB-1GB |
| `nginx_logs` | `/var/log/nginx` | nginx-proxy | nginx access and error logs | 10-100MB |
| `cloudflared_config` | `/home/nonroot/.cloudflared` | cloudflared-tunnel | Cloudflare tunnel config | 1-10MB |
| `redis_data` | `/data` | redis (future) | Redis data persistence | 100MB-1GB |

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
VPS_REDIS_HOST=103.110.57.247
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
- **6379** - Redis (when implemented locally)
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
docker inspect postgresql-local | grep IPAddress
docker inspect n8n-backend | grep IPAddress
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
docker inspect --format='{{.State.Health.Status}}' postgresql-local
docker inspect --format='{{.State.Health.Status}}' n8n-backend

# Check service logs
docker-compose logs postgresql-local
docker-compose logs n8n-backend
docker-compose logs nocodb-ui
```

### Network Connectivity
```bash
# Test database connection
docker exec postgresql-local pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}

# Test n8n API
curl -f http://localhost:5678/healthz

# Test NocoDB
curl -f http://localhost:8080/api/v1/health

# Test internal network connectivity
docker exec n8n-backend ping postgresql-local
docker exec nocodb-ui ping postgresql-local
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
docker-compose restart postgresql-local
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