#!/bin/bash
# =====================================================
# === ENVIRONMENT VALIDATION SCRIPT ===
# =====================================================
# Validates both .env.local and .env.vps files

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

echo -e "${BLUE}🔍 Environment Validation Script${NC}"

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

# Validate local environment
validate_local_env() {
    echo -e "${BLUE}📋 Validating local environment (.env.local)...${NC}"
    
    if [ ! -f "$PROJECT_ROOT/.env.local" ]; then
        print_error ".env.local file not found!"
        echo "Please create .env.local from env.local.txt:"
        echo "  cp env.local.txt .env.local"
        echo "  # Edit .env.local with your values"
        return 1
    fi
    
    # Check required variables for local environment
    local required_vars=("POSTGRES_USER" "POSTGRES_PASSWORD" "POSTGRES_DB" "N8N_ENCRYPTION_KEY" "NC_AUTH_JWT_SECRET")
    local missing_vars=()
    
    for var in "${required_vars[@]}"; do
        if ! grep -q "^${var}=" "$PROJECT_ROOT/.env.local" || grep -q "^${var}=your_" "$PROJECT_ROOT/.env.local" || grep -q "^${var}=$" "$PROJECT_ROOT/.env.local"; then
            missing_vars+=("$var")
        fi
    done
    
    if [ ${#missing_vars[@]} -ne 0 ]; then
        print_error "Missing or placeholder values in .env.local:"
        printf '  %s\n' "${missing_vars[@]}"
        return 1
    fi
    
    # Validate encryption key length
    local encryption_key=$(grep "^N8N_ENCRYPTION_KEY=" "$PROJECT_ROOT/.env.local" | cut -d'=' -f2)
    if [ ${#encryption_key} -ne 32 ]; then
        print_error "N8N_ENCRYPTION_KEY must be exactly 32 characters"
        return 1
    fi
    
    print_status "Local environment validation passed"
    return 0
}

# Validate VPS environment
validate_vps_env() {
    echo -e "${BLUE}📋 Validating VPS environment (.env.vps)...${NC}"
    
    if [ ! -f "$PROJECT_ROOT/.env.vps" ]; then
        print_warning ".env.vps file not found (optional for RFC-006)"
        echo "To create .env.vps for VPS worker:"
        echo "  cp env.vps.txt .env.vps"
        echo "  # Edit .env.vps with your VPS values"
        return 0
    fi
    
    # Check required variables for VPS environment
    local required_vars=("N8N_ENCRYPTION_KEY" "QUEUE_BULL_REDIS_HOST" "DB_POSTGRESDB_HOST" "DB_POSTGRESDB_USER" "DB_POSTGRESDB_PASSWORD" "N8N_WORKERS_COUNT")
    local missing_vars=()
    
    for var in "${required_vars[@]}"; do
        if ! grep -q "^${var}=" "$PROJECT_ROOT/.env.vps" || grep -q "^${var}=your_" "$PROJECT_ROOT/.env.vps" || grep -q "^${var}=$" "$PROJECT_ROOT/.env.vps"; then
            missing_vars+=("$var")
        fi
    done
    
    if [ ${#missing_vars[@]} -ne 0 ]; then
        print_error "Missing or placeholder values in .env.vps:"
        printf '  %s\n' "${missing_vars[@]}"
        return 1
    fi
    
    # Validate encryption key length
    local encryption_key=$(grep "^N8N_ENCRYPTION_KEY=" "$PROJECT_ROOT/.env.vps" | cut -d'=' -f2)
    if [ ${#encryption_key} -ne 32 ]; then
        print_error "N8N_ENCRYPTION_KEY must be exactly 32 characters"
        return 1
    fi
    
    # Check if encryption keys match (if both files exist)
    if [ -f "$PROJECT_ROOT/.env.local" ]; then
        local local_key=$(grep "^N8N_ENCRYPTION_KEY=" "$PROJECT_ROOT/.env.local" | cut -d'=' -f2)
        local vps_key=$(grep "^N8N_ENCRYPTION_KEY=" "$PROJECT_ROOT/.env.vps" | cut -d'=' -f2)
        
        if [ "$local_key" != "$vps_key" ]; then
            print_error "N8N_ENCRYPTION_KEY mismatch between .env.local and .env.vps"
            echo "Both environments must use the same encryption key for compatibility"
            return 1
        fi
        
        print_status "Encryption keys match between environments"
    fi
    
    print_status "VPS environment validation passed"
    return 0
}

# Main validation
main() {
    cd "$PROJECT_ROOT"
    
    local local_valid=0
    local vps_valid=0
    
    # Validate local environment
    if validate_local_env; then
        local_valid=1
    fi
    
    # Validate VPS environment
    if validate_vps_env; then
        vps_valid=1
    fi
    
    echo ""
    echo -e "${BLUE}📊 Validation Summary:${NC}"
    
    if [ $local_valid -eq 1 ]; then
        print_status "Local environment (.env.local) - Ready for RFC-003"
    else
        print_error "Local environment (.env.local) - Needs configuration"
    fi
    
    if [ -f ".env.vps" ]; then
        if [ $vps_valid -eq 1 ]; then
            print_status "VPS environment (.env.vps) - Ready for RFC-006"
        else
            print_error "VPS environment (.env.vps) - Needs configuration"
        fi
    else
        print_warning "VPS environment (.env.vps) - Not configured (optional)"
    fi
    
    echo ""
    if [ $local_valid -eq 1 ]; then
        echo -e "${GREEN}🚀 Ready to run: ./scripts/setup-local.sh${NC}"
    else
        echo -e "${YELLOW}📝 Next steps:${NC}"
        echo "  1. cp env.local.txt .env.local"
        echo "  2. Edit .env.local with your values"
        echo "  3. Run this script again to validate"
    fi
}

# Run main function
main "$@"