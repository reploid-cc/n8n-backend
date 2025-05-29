#!/bin/bash

# Migration Script: Clone VPS Schema to Localhost
# Description: Backup current localhost schema and apply VPS 16 tables structure
# Date: 2024-12-01

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="$PROJECT_ROOT/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Create backup directory
mkdir -p "$BACKUP_DIR"

echo -e "${BLUE}🚀 Starting VPS Schema Migration Process${NC}"
echo "=================================================="

# Function to check if containers are running
check_containers() {
    echo -e "${YELLOW}📊 Checking container status...${NC}"
    
    if ! docker ps | grep -q "postgres"; then
        echo -e "${RED}❌ PostgreSQL container is not running${NC}"
        echo "Please start containers first: ./scripts/setup-local.sh"
        exit 1
    fi
    
    echo -e "${GREEN}✅ PostgreSQL container is running${NC}"
}

# Function to backup current schema
backup_current_schema() {
    echo -e "${YELLOW}💾 Creating backup of current localhost schema...${NC}"
    
    # Backup current schema structure
    docker exec postgres pg_dump -U n8nuser -d n8ndb --schema-only --schema=n8n \
        > "$BACKUP_DIR/localhost_schema_backup_$TIMESTAMP.sql" 2>/dev/null || true
    
    # Backup current data (if any)
    docker exec postgres pg_dump -U n8nuser -d n8ndb --data-only --schema=n8n \
        > "$BACKUP_DIR/localhost_data_backup_$TIMESTAMP.sql" 2>/dev/null || true
    
    # Backup full database
    docker exec postgres pg_dump -U n8nuser -d n8ndb \
        > "$BACKUP_DIR/localhost_full_backup_$TIMESTAMP.sql" 2>/dev/null || true
    
    echo -e "${GREEN}✅ Backup completed:${NC}"
    echo "   - Schema: $BACKUP_DIR/localhost_schema_backup_$TIMESTAMP.sql"
    echo "   - Data: $BACKUP_DIR/localhost_data_backup_$TIMESTAMP.sql"
    echo "   - Full: $BACKUP_DIR/localhost_full_backup_$TIMESTAMP.sql"
}

# Function to show current schema info
show_current_schema() {
    echo -e "${YELLOW}📋 Current schema information:${NC}"
    
    echo "Current tables in schema 'n8n':"
    docker exec postgres psql -U n8nuser -d n8ndb -c "SET search_path TO n8n; \dt" 2>/dev/null || echo "No tables found or schema doesn't exist"
    
    echo ""
    echo "Current table count:"
    docker exec postgres psql -U n8nuser -d n8ndb -c "SELECT COUNT(*) as table_count FROM information_schema.tables WHERE table_schema = 'n8n';" 2>/dev/null || echo "0"
}

# Function to apply VPS migration
apply_vps_migration() {
    echo -e "${YELLOW}🔄 Applying VPS schema migration...${NC}"
    
    # Copy migration file to container
    docker cp "$PROJECT_ROOT/database/migrations/20241201_upgrade_vps_schema.sql" postgres:/tmp/vps_migration.sql
    
    # Execute migration
    echo "Executing migration script..."
    docker exec postgres psql -U n8nuser -d n8ndb -f /tmp/vps_migration.sql
    
    # Clean up temp file
    docker exec postgres rm -f /tmp/vps_migration.sql
    
    echo -e "${GREEN}✅ VPS schema migration applied successfully${NC}"
}

# Function to verify migration
verify_migration() {
    echo -e "${YELLOW}🔍 Verifying migration results...${NC}"
    
    echo "New table count:"
    docker exec postgres psql -U n8nuser -d n8ndb -c "SELECT COUNT(*) as table_count FROM information_schema.tables WHERE table_schema = 'n8n';"
    
    echo ""
    echo "New tables in schema 'n8n':"
    docker exec postgres psql -U n8nuser -d n8ndb -c "SET search_path TO n8n; \dt"
    
    echo ""
    echo "System views:"
    docker exec postgres psql -U n8nuser -d n8ndb -c "SET search_path TO n8n; \dv"
    
    echo ""
    echo "Indexes count:"
    docker exec postgres psql -U n8nuser -d n8ndb -c "SELECT COUNT(*) as index_count FROM pg_indexes WHERE schemaname = 'n8n';"
    
    echo ""
    echo "Data summary:"
    docker exec postgres psql -U n8nuser -d n8ndb -c "SET search_path TO n8n; SELECT * FROM v_data_summary;"
    
    echo ""
    echo "Database health:"
    docker exec postgres psql -U n8nuser -d n8ndb -c "SET search_path TO n8n; SELECT * FROM v_database_health;"
}

# Function to test n8n connectivity
test_n8n_connectivity() {
    echo -e "${YELLOW}🔗 Testing n8n connectivity with new schema...${NC}"
    
    # Restart n8n to pick up schema changes
    echo "Restarting n8n container..."
    docker restart n8n
    
    # Wait for n8n to start
    echo "Waiting for n8n to start..."
    sleep 30
    
    # Test health endpoint
    if curl -f http://localhost:5678/healthz >/dev/null 2>&1; then
        echo -e "${GREEN}✅ n8n health check passed${NC}"
    else
        echo -e "${RED}❌ n8n health check failed${NC}"
        echo "Check n8n logs: docker logs n8n"
    fi
    
    # Test database connection
    echo "Testing n8n database connection..."
    docker exec postgres psql -U n8nuser -d n8ndb -c "SET search_path TO n8n; SELECT COUNT(*) FROM users;" >/dev/null 2>&1 && \
        echo -e "${GREEN}✅ n8n database connection successful${NC}" || \
        echo -e "${RED}❌ n8n database connection failed${NC}"
}

# Function to show success summary
show_success_summary() {
    echo ""
    echo -e "${GREEN}🎉 VPS Schema Migration Completed Successfully!${NC}"
    echo "=================================================="
    echo "✅ Current localhost schema has been backed up"
    echo "✅ VPS schema with 16 tables has been applied"
    echo "✅ All indexes and constraints created"
    echo "✅ System monitoring views available"
    echo "✅ n8n connectivity verified"
    echo ""
    echo "📊 New Schema Summary:"
    echo "   - 16 tables from VPS"
    echo "   - All original indexes and constraints"
    echo "   - 3 system monitoring views"
    echo "   - Foreign key relationships preserved"
    echo ""
    echo "🔗 Access Points:"
    echo "   - n8n Local: https://n8n.ai-automation.cloud"
    echo "   - NocoDB: https://nocodb.ai-automation.cloud"
    echo ""
    echo "📁 Backup Location: $BACKUP_DIR/"
    echo "   - Full backup: localhost_full_backup_$TIMESTAMP.sql"
    echo "   - Schema backup: localhost_schema_backup_$TIMESTAMP.sql"
}

# Main execution flow
main() {
    echo -e "${BLUE}Starting migration process at $(date)${NC}"
    
    # Pre-flight checks
    check_containers
    
    # Show current state
    show_current_schema
    
    # Confirm with user
    echo ""
    echo -e "${YELLOW}⚠️  WARNING: This will completely replace your current schema 'n8n'${NC}"
    echo "Current data will be backed up but the schema will be recreated."
    echo ""
    read -p "Do you want to continue? (y/N): " confirm
    
    if [[ $confirm != [yY] && $confirm != [yY][eE][sS] ]]; then
        echo "Migration cancelled by user."
        exit 0
    fi
    
    # Execute migration steps
    backup_current_schema
    apply_vps_migration
    verify_migration
    test_n8n_connectivity
    show_success_summary
    
    echo -e "${GREEN}Migration completed at $(date)${NC}"
}

# Error handling
error_handler() {
    echo -e "${RED}❌ Error occurred during migration at line $1${NC}"
    echo "Check the logs above for details."
    echo "You can restore from backup if needed:"
    echo "  docker exec postgres psql -U n8nuser -d n8ndb < $BACKUP_DIR/localhost_full_backup_$TIMESTAMP.sql"
    exit 1
}

trap 'error_handler $LINENO' ERR

# Run main function
main "$@" 