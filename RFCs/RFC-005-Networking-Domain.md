# RFC-005: Networking & Domain Infrastructure

## Summary
Thiết lập nginx reverse proxy và cloudflared tunnel cho domain access. RFC này tạo networking infrastructure với SSL/HTTPS, domain routing (n8n.ai-automation.cloud, nocodb.ai-automation.cloud), và external access capability.

## Features Addressed
- **F007:** Nginx Reverse Proxy (Should Have)
- **F008:** Cloudflared Tunnel Service (Should Have)

## Dependencies
- **Previous RFCs:** RFC-001 (Docker Foundation), RFC-003 (n8n Backend), RFC-004 (NocoDB)
- **External Dependencies:** nginx, cloudflared, SSL certificates

## Builds Upon
- Docker orchestration system từ RFC-001
- n8n backend service từ RFC-003
- NocoDB interface từ RFC-004
- n8n-local-network (172.20.0.40, 172.20.0.50)

## Enables Future RFCs
- **RFC-006:** Data Management & n8n Worker Local (requires complete networking)

## Technical Approach

### Architecture Overview
```
Networking & Domain Architecture:
├── nginx Reverse Proxy (172.20.0.40)
│   ├── n8n.ai-automation.cloud → n8n-backend:5678
│   └── nocodb.ai-automation.cloud → nocodb-ui:8080
├── cloudflared Tunnel (172.20.0.50)
├── SSL/HTTPS Configuration
└── Domain Routing & Load Balancing
```

## Detailed Implementation Specifications

### 1. nginx Configuration (docker-compose.network.yml)
```yaml
services:
  nginx-proxy:
    image: nginx:alpine
    container_name: nginx-proxy
    restart: unless-stopped
    
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
      - nginx_logs:/var/log/nginx
      
    networks:
      n8n-local-network:
        ipv4_address: 172.20.0.40
        
    ports:
      - "80:80"
      - "443:443"
      
    depends_on:
      - n8n-backend
      - nocodb-ui
      
    healthcheck:
      test: ["CMD", "nginx", "-t"]
      interval: 30s
      timeout: 10s
      retries: 3

  cloudflared-tunnel:
    image: cloudflare/cloudflared:latest
    container_name: cloudflared-tunnel
    restart: unless-stopped
    
    command: tunnel --config /etc/cloudflared/config.yml run
    
    volumes:
      - ./cloudflared:/etc/cloudflared:ro
      - cloudflared_config:/home/nonroot/.cloudflared
      
    networks:
      n8n-local-network:
        ipv4_address: 172.20.0.50
        
    depends_on:
      - nginx-proxy
```

### 2. nginx Configuration (nginx/nginx.conf)
```nginx
events {
    worker_connections 1024;
}

http {
    upstream n8n_backend {
        server 172.20.0.20:5678;
    }
    
    upstream nocodb_ui {
        server 172.20.0.30:8080;
    }
    
    server {
        listen 80;
        server_name n8n.ai-automation.cloud;
        return 301 https://$server_name$request_uri;
    }
    
    server {
        listen 443 ssl;
        server_name n8n.ai-automation.cloud;
        
        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;
        
        location / {
            proxy_pass http://n8n_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
    
    server {
        listen 443 ssl;
        server_name nocodb.ai-automation.cloud;
        
        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;
        
        location / {
            proxy_pass http://nocodb_ui;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

## Acceptance Criteria

### F007: Nginx Reverse Proxy
- [ ] nginx alpine container running successfully
- [ ] Domain routing: n8n.ai-automation.cloud → n8n:5678
- [ ] Domain routing: nocodb.ai-automation.cloud → nocodb:8080
- [ ] SSL/HTTPS configuration working
- [ ] Health check endpoint responding
- [ ] Load balancing functional
- [ ] Error page handling working

### F008: Cloudflared Tunnel Service
- [ ] cloudflared latest container running
- [ ] Tunnel configuration working
- [ ] Domain mapping setup complete
- [ ] Automatic reconnection functional
- [ ] External access working
- [ ] Security policies applied

---

**RFC Status:** Ready for Implementation  
**Complexity:** High  
**Estimated Effort:** 2 weeks  
**Previous RFC:** RFC-004 (NocoDB Interface)  
**Next RFC:** RFC-006 (Data Management & n8n Worker) 