# n8n Worker Local

Pure worker mode để consume jobs từ VPS Redis queue và thực thi workflows.

## 🎯 Mục Đích

Worker local này hoạt động hoàn toàn independent và chỉ có một nhiệm vụ:
- **Lấy jobs từ Redis VPS** (103.110.87.247:6379)
- **Thực thi workflows** locally
- **Không cần database access** - pure queue consumer

## 🏗️ Architecture

```
VPS n8n → Redis VPS (queue) → Worker Local → Execute Workflows
```

## 📋 Setup Instructions

### 1. Tạo Environment File
```bash
# Copy template và điền thông tin VPS
cp env.md .env

# Chỉnh sửa các values cần thiết:
# - QUEUE_BULL_REDIS_PASSWORD
# - DB_POSTGRESDB_USER 
# - DB_POSTGRESDB_PASSWORD
# - N8N_ENCRYPTION_KEY
```

### 2. Start Worker
```bash
# Make script executable
chmod +x start-worker.sh

# Start worker
./start-worker.sh
```

### 3. Verify Connection
```bash
# Check worker logs
docker-compose logs -f

# Check worker health
docker-compose ps
```

## 🔧 Configuration Files

- **`env.md`** - Environment template (DO NOT edit directly)
- **`.env`** - Actual environment values (create from env.md)
- **`docker-compose.yml`** - Worker container configuration
- **`start-worker.sh`** - Startup script

## 📊 Worker Access

- **Worker Dashboard:** http://localhost:5679
- **Container Name:** n8n-worker-local
- **Network:** worker-network (172.22.0.0/16)

## 🚀 Usage

```bash
# Start worker
./start-worker.sh

# View logs
docker-compose logs -f

# Stop worker
docker-compose down

# Restart worker
docker-compose restart
```

## 🔍 Troubleshooting

### Connection Issues
```bash
# Test VPS Redis connection
docker exec n8n-worker-local redis-cli -h 103.110.87.247 -p 6379 ping

# Check worker logs
docker-compose logs n8n-worker
```

### Health Check
```bash
# Check container health
docker-compose ps

# Manual health check
curl http://localhost:5679/healthz
```

## 📝 Notes

- Worker chạy trên port **5679** để tránh conflict với n8n local (5678)
- Memory limit: 2GB, CPU limit: 1 core
- Worker hoàn toàn independent, không ảnh hưởng đến local n8n setup
- Sử dụng separate network (172.22.0.0/16) để tránh conflict 