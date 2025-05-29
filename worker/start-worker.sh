#!/bin/bash

# n8n Worker Scale Management
# Usage: ./start-worker.sh <command> [options]

# Configuration
DEFAULT_REPLICAS=4
DEFAULT_CONCURRENCY=5
WORKER_PREFIX="n8n-worker"

# Show help
show_help() {
    echo "n8n Worker Scale Management"
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  start [replicas]           Start workers (default: 4)"
    echo "  stop                       Stop all workers"
    echo "  scale <replicas>           Scale workers to specified number"
    echo "  concurrency <number>       Set worker concurrency (jobs per worker)"
    echo "  config <replicas> <conc>   Configure both replicas and concurrency"
    echo "  status                     Show worker status and configuration"
    echo "  logs [lines]               Show worker logs (default: 50, use 0 to follow)"
    echo "  restart                    Restart all workers"
    echo "  update                     Update worker images and restart"
    echo "  help                       Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 start                   # Start 4 workers (default)"
    echo "  $0 start 6                 # Start 6 workers"
    echo "  $0 scale 8                 # Scale to 8 workers"
    echo "  $0 concurrency 10          # Set concurrency to 10 jobs per worker"
    echo "  $0 config 6 8              # 6 workers, 8 jobs each = 48 total capacity"
    echo "  $0 scale 0                 # Stop all workers"
    echo "  $0 logs                    # Show last 50 lines"
    echo "  $0 logs 100                # Show last 100 lines"
    echo "  $0 logs 0                  # Follow logs real-time"
    echo ""
    echo "Performance Examples:"
    echo "  $0 config 4 5              # Light: 4 workers × 5 = 20 jobs"
    echo "  $0 config 6 8              # Medium: 6 workers × 8 = 48 jobs"
    echo "  $0 config 8 10             # Heavy: 8 workers × 10 = 80 jobs"
}

# Check requirements
check_requirements() {
    if [ ! -f .env ]; then
        echo "❌ Error: .env file not found!"
        echo "Please create .env file from env.md template"
        exit 1
    fi

    if ! docker info > /dev/null 2>&1; then
        echo "❌ Error: Docker is not running!"
        exit 1
    fi
}

# Get current worker count
get_worker_count() {
    docker ps -q --filter "name=${WORKER_PREFIX}" | wc -l
}

# Generate docker-compose with scaling
generate_compose() {
    local replicas=${1:-1}
    local concurrency=${2:-$DEFAULT_CONCURRENCY}
    
    cat > docker-compose.yml << EOF
version: '3.8'

services:
  n8n-worker:
    image: n8nio/n8n:latest
    env_file:
      - .env
    command: worker
    restart: unless-stopped
    volumes:
      - n8n-worker-data:/home/node/.n8n
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      # Database Configuration - Force PostgreSQL VPS
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=103.110.87.247
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=n8ndb
      - DB_POSTGRESDB_USER=n8nuser
      - DB_POSTGRESDB_PASSWORD=Ulatroi@123
      - DB_POSTGRESDB_SCHEMA=public
      
      # Worker Configuration
      - EXECUTIONS_MODE=queue
      - N8N_HOST=0.0.0.0
      - N8N_PORT=5678
      - NODE_ENV=production
      
      # Queue Configuration
      - QUEUE_BULL_REDIS_HOST=103.110.87.247
      - QUEUE_BULL_REDIS_PORT=6379
      - QUEUE_BULL_REDIS_DB=0
      
      # Worker Settings
      - N8N_CONCURRENCY_PRODUCTION_LIMIT=$concurrency
      - N8N_RUNNERS_ENABLED=true
      - OFFLOAD_MANUAL_EXECUTIONS_TO_WORKERS=true
      - N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true
    networks:
      - worker-network
    healthcheck:
      test: ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost:5678/healthz || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    deploy:
      replicas: $replicas
      resources:
        limits:
          memory: 2G
          cpus: '1.0'
        reservations:
          memory: 512M
          cpus: '0.5'

volumes:
  n8n-worker-data:
    driver: local

networks:
  worker-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.23.0.0/16
EOF
}

# Start workers
start_workers() {
    local replicas=${1:-$DEFAULT_REPLICAS}
    local concurrency=${2:-$DEFAULT_CONCURRENCY}
    
    echo "🚀 Starting $replicas workers with concurrency $concurrency..."
    check_requirements
    
    # Stop existing workers
    stop_workers
    
    # Generate docker-compose with scaling
    generate_compose $replicas $concurrency
    
    # Start workers with scaling
    docker-compose up -d --scale n8n-worker=$replicas
    
    # Wait for startup
    echo "⏳ Waiting for workers to be ready..."
    sleep 15
    
    show_status
}

# Stop workers
stop_workers() {
    echo "🛑 Stopping all workers..."
    docker-compose down
    echo "✅ All workers stopped"
}

# Scale workers
scale_workers() {
    local replicas=$1
    if [ -z "$replicas" ]; then
        echo "❌ Error: Please specify number of replicas"
        echo "Usage: $0 scale <replicas>"
        exit 1
    fi
    
    echo "📊 Scaling to $replicas workers..."
    
    # Get current concurrency from running container
    local current_concurrency=$DEFAULT_CONCURRENCY
    if [ $(get_worker_count) -gt 0 ]; then
        current_concurrency=$(docker inspect $(docker ps -q --filter "name=${WORKER_PREFIX}" | head -1) --format '{{range .Config.Env}}{{if contains "N8N_CONCURRENCY_PRODUCTION_LIMIT" .}}{{.}}{{end}}{{end}}' | cut -d'=' -f2 2>/dev/null || echo $DEFAULT_CONCURRENCY)
    fi
    
    # Regenerate compose and scale
    generate_compose $replicas $current_concurrency
    docker-compose up -d --scale n8n-worker=$replicas
    
    echo "⏳ Waiting for scaling to complete..."
    sleep 10
    show_status
}

# Set concurrency
set_concurrency() {
    local concurrency=$1
    if [ -z "$concurrency" ]; then
        echo "❌ Error: Please specify concurrency number"
        echo "Usage: $0 concurrency <number>"
        exit 1
    fi
    
    local current_replicas=$(get_worker_count)
    if [ $current_replicas -eq 0 ]; then
        current_replicas=$DEFAULT_REPLICAS
    fi
    
    echo "🔧 Setting concurrency to $concurrency (current workers: $current_replicas)..."
    start_workers $current_replicas $concurrency
}

# Configure both replicas and concurrency
configure_workers() {
    local replicas=$1
    local concurrency=$2
    
    if [ -z "$replicas" ] || [ -z "$concurrency" ]; then
        echo "❌ Error: Please specify both replicas and concurrency"
        echo "Usage: $0 config <replicas> <concurrency>"
        exit 1
    fi
    
    echo "⚙️ Configuring $replicas workers with $concurrency concurrency..."
    start_workers $replicas $concurrency
}

# Show status
show_status() {
    echo "📊 Worker Status:"
    echo "=================="
    
    local worker_count=$(get_worker_count)
    echo "🔢 Active Workers: $worker_count"
    
    if [ $worker_count -gt 0 ]; then
        echo ""
        echo "📋 Worker Details:"
        docker ps --filter "name=${WORKER_PREFIX}" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        
        echo ""
        echo "💾 Resource Usage:"
        docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" $(docker ps -q --filter "name=${WORKER_PREFIX}")
        
        echo ""
        echo "🌐 Access Points:"
        local i=1
        for container in $(docker ps --filter "name=${WORKER_PREFIX}" --format "{{.Names}}"); do
            echo "  Worker $i: http://localhost:$((5678+i))"
            i=$((i+1))
        done
        
        echo ""
        echo "⚡ Total Capacity:"
        local concurrency=$(docker inspect $(docker ps -q --filter "name=${WORKER_PREFIX}" | head -1) --format '{{range .Config.Env}}{{if contains "N8N_CONCURRENCY_PRODUCTION_LIMIT" .}}{{.}}{{end}}{{end}}' | cut -d'=' -f2 2>/dev/null || echo "5")
        local total_capacity=$((worker_count * concurrency))
        echo "  Workers: $worker_count × Concurrency: $concurrency = Total: $total_capacity jobs"
    fi
    
    echo ""
    echo "🔍 Health Check:"
    docker-compose ps
}

# Show logs
show_logs() {
    local lines=${1:-50}
    
    if [ "$lines" = "0" ]; then
        echo "📋 Following worker logs (Ctrl+C to stop):"
        docker-compose logs -f
    else
        echo "📋 Last $lines lines of worker logs:"
        docker-compose logs --tail=$lines
    fi
}

# Restart workers
restart_workers() {
    echo "🔄 Restarting all workers..."
    docker-compose restart
    echo "⏳ Waiting for restart to complete..."
    sleep 10
    show_status
}

# Update workers
update_workers() {
    echo "📥 Updating worker images..."
    docker-compose pull
    restart_workers
}

# Main script logic
case "${1:-help}" in
    start)
        start_workers $2 $3
        ;;
    stop)
        stop_workers
        ;;
    scale)
        scale_workers $2
        ;;
    concurrency)
        set_concurrency $2
        ;;
    config)
        configure_workers $2 $3
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs $2
        ;;
    restart)
        restart_workers
        ;;
    update)
        update_workers
        ;;
    help|*)
        show_help
        ;;
esac 