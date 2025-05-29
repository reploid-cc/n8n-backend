#!/bin/bash

# =====================================================
# n8n Worker Local Manager
# =====================================================
# Usage:
#   ./scripts/worker-manager.sh start [workers] [concurrency]
#   ./scripts/worker-manager.sh stop
#   ./scripts/worker-manager.sh status
#   ./scripts/worker-manager.sh logs
# =====================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
COMPOSE_FILE="docker-compose.worker.yml"
ENV_FILE=".env.vps"
SERVICE_NAME="n8n-worker-local"

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if .env.vps exists
check_env_file() {
    if [ ! -f "$ENV_FILE" ]; then
        log_error ".env.vps file not found!"
        log_info "Please create .env.vps with VPS connection details"
        log_info "Copy from env.vps.txt: cp env.vps.txt .env.vps"
        exit 1
    fi
}

# Check if docker-compose.worker.yml exists
check_compose_file() {
    if [ ! -f "$COMPOSE_FILE" ]; then
        log_error "$COMPOSE_FILE not found!"
        exit 1
    fi
}

# Test VPS Redis connectivity
test_redis_connection() {
    log_info "Testing VPS Redis connectivity..."
    
    # Load environment variables
    source "$ENV_FILE"
    
    if [ -z "$QUEUE_BULL_REDIS_HOST" ]; then
        log_error "QUEUE_BULL_REDIS_HOST not set in $ENV_FILE"
        exit 1
    fi
    
    # Test connection
    if docker run --rm redis:alpine redis-cli -h "$QUEUE_BULL_REDIS_HOST" -p "${QUEUE_BULL_REDIS_PORT:-6379}" ping > /dev/null 2>&1; then
        log_success "VPS Redis connection successful ($QUEUE_BULL_REDIS_HOST:${QUEUE_BULL_REDIS_PORT:-6379})"
    else
        log_error "Cannot connect to VPS Redis ($QUEUE_BULL_REDIS_HOST:${QUEUE_BULL_REDIS_PORT:-6379})"
        log_info "Please check VPS Redis configuration and network connectivity"
        exit 1
    fi
}

# Start workers
start_workers() {
    local workers=${1:-}
    local concurrency=${2:-}
    
    check_env_file
    check_compose_file
    test_redis_connection
    
    # Set environment variables for scaling
    if [ -n "$workers" ]; then
        export N8N_WORKERS_COUNT="$workers"
        log_info "Setting worker count to: $workers"
    fi
    
    if [ -n "$concurrency" ]; then
        export N8N_CONCURRENCY="$concurrency"
        log_info "Setting concurrency to: $concurrency"
    fi
    
    log_info "Starting n8n worker local..."
    
    # Start with environment file
    docker-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d
    
    # Wait for health check
    log_info "Waiting for worker to be healthy..."
    sleep 10
    
    # Check status
    if docker-compose -f "$COMPOSE_FILE" ps | grep -q "Up"; then
        log_success "n8n worker local started successfully!"
        show_status
    else
        log_error "Failed to start n8n worker local"
        docker-compose -f "$COMPOSE_FILE" logs --tail=20
        exit 1
    fi
}

# Stop workers
stop_workers() {
    log_info "Stopping n8n worker local..."
    
    if docker-compose -f "$COMPOSE_FILE" ps | grep -q "Up"; then
        docker-compose -f "$COMPOSE_FILE" down
        log_success "n8n worker local stopped"
    else
        log_warning "n8n worker local is not running"
    fi
}

# Show status
show_status() {
    log_info "n8n Worker Local Status:"
    echo "=========================="
    
    if docker-compose -f "$COMPOSE_FILE" ps | grep -q "Up"; then
        docker-compose -f "$COMPOSE_FILE" ps
        echo ""
        
        # Show worker configuration
        log_info "Worker Configuration:"
        docker-compose -f "$COMPOSE_FILE" exec "$SERVICE_NAME" printenv | grep -E "(N8N_WORKERS_COUNT|N8N_CONCURRENCY|QUEUE_BULL_REDIS_HOST)" || true
        
        # Show Redis queue info (if accessible)
        log_info "Redis Queue Status:"
        source "$ENV_FILE"
        docker run --rm redis:alpine redis-cli -h "$QUEUE_BULL_REDIS_HOST" -p "${QUEUE_BULL_REDIS_PORT:-6379}" info replication 2>/dev/null || log_warning "Cannot access Redis info"
        
    else
        log_warning "n8n worker local is not running"
        echo "Use: $0 start [workers] [concurrency] to start"
    fi
}

# Show logs
show_logs() {
    log_info "n8n Worker Local Logs:"
    echo "======================"
    docker-compose -f "$COMPOSE_FILE" logs --tail=50 -f
}

# Main command handler
case "${1:-}" in
    "start")
        start_workers "$2" "$3"
        ;;
    "stop")
        stop_workers
        ;;
    "status")
        show_status
        ;;
    "logs")
        show_logs
        ;;
    "restart")
        stop_workers
        sleep 2
        start_workers "$2" "$3"
        ;;
    *)
        echo "n8n Worker Local Manager"
        echo "======================="
        echo "Usage: $0 {start|stop|status|logs|restart} [workers] [concurrency]"
        echo ""
        echo "Commands:"
        echo "  start [workers] [concurrency]  - Start worker(s) with optional scaling"
        echo "  stop                           - Stop all workers"
        echo "  status                         - Show worker status"
        echo "  logs                           - Show worker logs"
        echo "  restart [workers] [concurrency] - Restart workers"
        echo ""
        echo "Examples:"
        echo "  $0 start                       - Start with default settings"
        echo "  $0 start 15 20                - Start 15 workers with 20 concurrency each"
        echo "  $0 status                      - Show current status"
        echo ""
        exit 1
        ;;
esac 