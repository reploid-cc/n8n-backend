#!/bin/bash
# =====================================================
# === LOCAL ENVIRONMENT HEALTH CHECK ===
# =====================================================
# RFC-003: n8n Backend Local Service Health Monitoring

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}🏥 n8n Local Environment Health Check${NC}"
echo "=============================================="

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Global exit code
EXIT_CODE=0

# Check if .env.local exists
check_environment() {
    echo -e "${BLUE}📋 Checking environment configuration...${NC}"
    
    if [ ! -f "$PROJECT_ROOT/.env.local" ]; then
        print_error ".env.local file not found"
        EXIT_CODE=1
        return 1
    fi
    
    print_status "Environment file exists"
    return 0
}

# Check Docker containers
check_containers() {
    echo -e "${BLUE}🐳 Checking Docker containers...${NC}"
    
    local containers=("postgres" "n8n")
    local all_running=true
    
    for container in "${containers[@]}"; do
        if docker ps --filter "name=$container" --filter "status=running" | grep -q "$container"; then
            local status=$(docker inspect --format='{{.State.Health.Status}}' "$container" 2>/dev/null || echo "no-healthcheck")
            if [ "$status" = "healthy" ]; then
                print_status "$container is running and healthy"
            elif [ "$status" = "no-healthcheck" ]; then
                print_status "$container is running (no health check)"
            else
                print_warning "$container is running but status: $status"
            fi
        else
            print_error "$container is not running"
            all_running=false
            EXIT_CODE=1
        fi
    done
    
    return 0
}

# Check PostgreSQL connectivity
check_postgresql() {
    echo -e "${BLUE}🗄️  Checking PostgreSQL...${NC}"
    
    if ! docker exec postgres pg_isready -U n8nuser -d n8ndb &> /dev/null; then
        print_error "PostgreSQL is not accepting connections"
        EXIT_CODE=1
        return 1
    fi
    
    print_status "PostgreSQL is accepting connections"
    
    # Check schema exists
    local schema_exists=$(docker exec postgres psql -U n8nuser -d n8ndb -tAc \
        "SELECT EXISTS(SELECT 1 FROM information_schema.schemata WHERE schema_name = 'n8n');" 2>/dev/null || echo "f")
    
    if [ "$schema_exists" = "t" ]; then
        print_status "Schema 'n8n' exists"
    else
        print_error "Schema 'n8n' not found"
        EXIT_CODE=1
    fi
    
    # Check table count
    local table_count=$(docker exec postgres psql -U n8nuser -d n8ndb -tAc \
        "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'n8n';" 2>/dev/null || echo "0")
    
    if [ "$table_count" -gt 0 ]; then
        print_status "Database has $table_count tables in 'n8n' schema"
    else
        print_warning "No tables found in 'n8n' schema"
    fi
    
    return 0
}

# Check n8n API
check_n8n_api() {
    echo -e "${BLUE}🔧 Checking n8n API...${NC}"
    
    # Check health endpoint
    if curl -f -s http://localhost:5678/healthz > /dev/null 2>&1; then
        print_status "n8n health endpoint responding"
    else
        print_error "n8n health endpoint not responding"
        EXIT_CODE=1
        return 1
    fi
    
    # Measure response time
    local response_time=$(curl -o /dev/null -s -w '%{time_total}' http://localhost:5678/healthz 2>/dev/null || echo "999")
    local response_ms=$(echo "$response_time * 1000" | bc 2>/dev/null || echo "999")
    
    if (( $(echo "$response_ms < 500" | bc -l) )); then
        print_status "n8n API response time: ${response_ms}ms (< 500ms target)"
    else
        print_warning "n8n API response time: ${response_ms}ms (> 500ms target)"
    fi
    
    # Check if web interface is accessible
    if curl -f -s http://localhost:5678 > /dev/null 2>&1; then
        print_status "n8n web interface accessible"
    else
        print_warning "n8n web interface may not be ready"
    fi
    
    return 0
}

# Check network connectivity
check_network() {
    echo -e "${BLUE}🌐 Checking network configuration...${NC}"
    
    # Check if network exists
    if docker network ls | grep -q "n8n-local-network"; then
        print_status "Docker network 'n8n-local-network' exists"
    else
        print_error "Docker network 'n8n-local-network' not found"
        EXIT_CODE=1
    fi
    
    # Check container IPs
    local postgres_ip=$(docker inspect postgres --format '{{range $net, $conf := .NetworkSettings.Networks}}{{if eq $net "n8n-local-network"}}{{$conf.IPAddress}}{{end}}{{end}}' 2>/dev/null || echo "")
    local n8n_ip=$(docker inspect n8n --format '{{range $net, $conf := .NetworkSettings.Networks}}{{if eq $net "n8n-local-network"}}{{$conf.IPAddress}}{{end}}{{end}}' 2>/dev/null || echo "")
    
    if [ -n "$postgres_ip" ]; then
        print_status "PostgreSQL IP: $postgres_ip"
    else
        print_error "PostgreSQL not connected to n8n-local-network"
        EXIT_CODE=1
    fi
    
    if [ -n "$n8n_ip" ]; then
        print_status "n8n IP: $n8n_ip"
    else
        print_error "n8n not connected to n8n-local-network"
        EXIT_CODE=1
    fi
    
    return 0
}

# Check volumes
check_volumes() {
    echo -e "${BLUE}💾 Checking Docker volumes...${NC}"
    
    local volumes=("postgres_data" "n8n_data")
    
    for volume in "${volumes[@]}"; do
        if docker volume ls | grep -q "$volume"; then
            print_status "Volume '$volume' exists"
        else
            print_error "Volume '$volume' not found"
            EXIT_CODE=1
        fi
    done
    
    return 0
}

# Performance metrics
show_performance_metrics() {
    echo -e "${BLUE}📊 Performance Metrics...${NC}"
    
    # Container resource usage
    echo "Container Resource Usage:"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" postgres n8n 2>/dev/null || echo "Unable to get stats"
    
    # Database size
    local db_size=$(docker exec postgres psql -U n8nuser -d n8ndb -tAc \
        "SELECT pg_size_pretty(pg_database_size('n8ndb'));" 2>/dev/null || echo "Unknown")
    echo "Database size: $db_size"
    
    # Uptime
    local postgres_uptime=$(docker inspect postgres --format='{{.State.StartedAt}}' 2>/dev/null || echo "Unknown")
    local n8n_uptime=$(docker inspect n8n --format='{{.State.StartedAt}}' 2>/dev/null || echo "Unknown")
    echo "PostgreSQL started: $postgres_uptime"
    echo "n8n started: $n8n_uptime"
}

# Main execution
main() {
    check_environment
    check_containers
    check_postgresql
    check_n8n_api
    check_network
    check_volumes
    show_performance_metrics
    
    echo ""
    echo "=============================================="
    if [ $EXIT_CODE -eq 0 ]; then
        echo -e "${GREEN}🎉 All health checks passed!${NC}"
        echo -e "${GREEN}Local environment is healthy and ready.${NC}"
    else
        echo -e "${RED}❌ Some health checks failed!${NC}"
        echo -e "${YELLOW}Please review the issues above.${NC}"
    fi
    echo "=============================================="
    
    exit $EXIT_CODE
}

# Run main function
main "$@" 