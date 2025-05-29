#!/bin/bash
# =====================================================
# === LOCAL ENVIRONMENT SETUP SCRIPT ===
# =====================================================
# RFC-003: n8n Backend Local Service Setup
# This script sets up the local development environment

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

echo -e "${BLUE}🚀 Starting n8n Backend Local Environment Setup...${NC}"

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

# Validate environment file
validate_environment() {
    echo -e "${BLUE}📋 Validating local environment...${NC}"
    
    if [ ! -f "$PROJECT_ROOT/.env.local" ]; then
        print_error ".env.local file not found!"
        echo "Please create .env.local from env.local.txt:"
        echo "  cp env.local.txt .env.local"
        echo "  # Edit .env.local with your values"
        exit 1
    fi
    
    # Check required variables
    local required_vars=("POSTGRES_USER" "POSTGRES_PASSWORD" "POSTGRES_DB" "N8N_ENCRYPTION_KEY")
    local missing_vars=()
    
    for var in "${required_vars[@]}"; do
        if ! grep -q "^${var}=" "$PROJECT_ROOT/.env.local" || grep -q "^${var}=$" "$PROJECT_ROOT/.env.local"; then
            missing_vars+=("$var")
        fi
    done
    
    if [ ${#missing_vars[@]} -ne 0 ]; then
        print_error "Missing or empty required variables in .env.local:"
        printf '  %s\n' "${missing_vars[@]}"
        exit 1
    fi
    
    print_status "Environment validation passed"
}

# Check Docker
check_docker() {
    echo -e "${BLUE}🐳 Checking Docker...${NC}"
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed or not in PATH"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        print_error "Docker daemon is not running"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed or not in PATH"
        exit 1
    fi
    
    print_status "Docker is ready"
}

# Setup Docker networks and volumes
setup_infrastructure() {
    echo -e "${BLUE}🏗️  Setting up infrastructure...${NC}"
    
    # Create network if not exists
    if ! docker network ls | grep -q "n8n-local-network"; then
        docker network create --driver bridge --subnet=172.21.0.0/16 n8n-local-network
        print_status "Created Docker network: n8n-local-network"
    else
        print_status "Docker network already exists: n8n-local-network"
    fi
    
    # Create volumes if not exist
    local volumes=("postgres_data" "n8n_data")
    for volume in "${volumes[@]}"; do
        if ! docker volume ls | grep -q "$volume"; then
            docker volume create "$volume"
            print_status "Created Docker volume: $volume"
        else
            print_status "Docker volume already exists: $volume"
        fi
    done
}

# Start core services
start_core_services() {
    echo -e "${BLUE}📦 Starting core services...${NC}"
    
    cd "$PROJECT_ROOT"
    
    # Start PostgreSQL and n8n
    docker-compose --env-file .env.local -f docker-compose.yml -f docker-compose.core.yml up -d
    
    print_status "Core services started"
}

# Wait for services to be healthy
wait_for_services() {
    echo -e "${BLUE}⏳ Waiting for services to be healthy...${NC}"
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        echo "Attempt $attempt/$max_attempts..."
        
        # Check PostgreSQL
        if docker exec postgres pg_isready -U "$(grep POSTGRES_USER .env.local | cut -d'=' -f2)" -d "$(grep POSTGRES_DB .env.local | cut -d'=' -f2)" &> /dev/null; then
            print_status "PostgreSQL is ready"
            break
        fi
        
        if [ $attempt -eq $max_attempts ]; then
            print_error "PostgreSQL failed to become ready"
            exit 1
        fi
        
        sleep 5
        ((attempt++))
    done
    
    # Wait a bit more for n8n
    echo "Waiting for n8n to initialize..."
    sleep 30
    
    # Check n8n health
    if curl -f http://localhost:5678/healthz &> /dev/null; then
        print_status "n8n is ready"
    else
        print_warning "n8n may still be initializing"
    fi
}

# Display access information
show_access_info() {
    echo -e "${GREEN}"
    echo "=============================================="
    echo "🎉 LOCAL ENVIRONMENT SETUP COMPLETE!"
    echo "=============================================="
    echo -e "${NC}"
    
    echo "📍 Access URLs:"
    echo "  🔗 n8n Local:    http://localhost:5678"
    echo "  🔗 PostgreSQL:   localhost:5432"
    echo ""
    
    echo "📊 Service Status:"
    docker-compose --env-file .env.local -f docker-compose.yml -f docker-compose.core.yml ps
    
    echo ""
    echo "🔧 Useful Commands:"
    echo "  View logs:        docker-compose --env-file .env.local logs -f"
    echo "  Stop services:    docker-compose --env-file .env.local down"
    echo "  Health check:     ./scripts/health-check-local.sh"
    echo ""
    
    echo -e "${YELLOW}📝 Next Steps:${NC}"
    echo "  1. Access n8n at http://localhost:5678"
    echo "  2. Create your first workflow"
    echo "  3. Test local development environment"
    echo "  4. Proceed to RFC-004 (NocoDB Interface)"
}

# Main execution
main() {
    validate_environment
    check_docker
    setup_infrastructure
    start_core_services
    wait_for_services
    show_access_info
}

# Run main function
main "$@" 