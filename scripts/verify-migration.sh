#!/bin/bash

# Migration Verification Script
# Description: Compare localhost schema with VPS expected results
# Date: 2024-12-01

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 VPS Schema Migration Verification${NC}"
echo "=========================================="

# Expected VPS tables
expected_tables=(
    "comments"
    "log_transactions"
    "log_usage"
    "log_user_activities"
    "log_workflow_changes"
    "log_workflow_executions"
    "orders"
    "ratings"
    "user_oauth"
    "user_workflow_favorites"
    "users"
    "vip_custom_limits"
    "worker_logs"
    "workflow_tier_limits"
    "workflow_versions"
    "workflows"
)

echo -e "${YELLOW}📊 Checking localhost tables...${NC}"

# Get actual tables from localhost
echo "Localhost tables in schema 'n8n':"
docker exec postgres psql -U n8nuser -d n8ndb -t -c "SELECT table_name FROM information_schema.tables WHERE table_schema = 'n8n' AND table_type = 'BASE TABLE' ORDER BY table_name;"

echo ""
echo "Expected VPS tables:"
printf '%s\n' "${expected_tables[@]}"

echo ""
echo -e "${YELLOW}📈 Table count comparison:${NC}"
localhost_count=$(docker exec postgres psql -U n8nuser -d n8ndb -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'n8n' AND table_type = 'BASE TABLE';" | tr -d ' ')
expected_count=${#expected_tables[@]}

echo "Localhost tables: $localhost_count"
echo "Expected tables: $expected_count"

if [ "$localhost_count" -eq "$expected_count" ]; then
    echo -e "${GREEN}✅ Table count matches${NC}"
else
    echo -e "${RED}❌ Table count mismatch${NC}"
fi

echo ""
echo -e "${YELLOW}🗂️ Checking specific tables...${NC}"

missing_tables=()
for table in "${expected_tables[@]}"; do
    exists=$(docker exec postgres psql -U n8nuser -d n8ndb -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'n8n' AND table_name = '$table';" | tr -d ' ')
    if [ "$exists" -eq "1" ]; then
        echo -e "${GREEN}✅ $table${NC}"
    else
        echo -e "${RED}❌ $table (missing)${NC}"
        missing_tables+=("$table")
    fi
done

if [ ${#missing_tables[@]} -eq 0 ]; then
    echo -e "${GREEN}🎉 All expected tables present!${NC}"
else
    echo -e "${RED}⚠️  Missing tables: ${missing_tables[*]}${NC}"
fi

echo ""
echo -e "${YELLOW}📋 System views check:${NC}"

views=("v_data_summary" "v_database_health" "v_system_status")
for view in "${views[@]}"; do
    exists=$(docker exec postgres psql -U n8nuser -d n8ndb -t -c "SELECT COUNT(*) FROM information_schema.views WHERE table_schema = 'n8n' AND table_name = '$view';" | tr -d ' ')
    if [ "$exists" -eq "1" ]; then
        echo -e "${GREEN}✅ $view${NC}"
    else
        echo -e "${RED}❌ $view (missing)${NC}"
    fi
done

echo ""
echo -e "${YELLOW}🔗 Index verification:${NC}"
index_count=$(docker exec postgres psql -U n8nuser -d n8ndb -t -c "SELECT COUNT(*) FROM pg_indexes WHERE schemaname = 'n8n';" | tr -d ' ')
echo "Total indexes: $index_count"

if [ "$index_count" -gt "80" ]; then
    echo -e "${GREEN}✅ Index count looks good (>80)${NC}"
else
    echo -e "${YELLOW}⚠️  Index count might be low${NC}"
fi

echo ""
echo -e "${YELLOW}🧪 Testing data access:${NC}"

# Test basic queries on key tables
test_tables=("users" "workflows" "comments" "ratings")
for table in "${test_tables[@]}"; do
    if docker exec postgres psql -U n8nuser -d n8ndb -c "SET search_path TO n8n; SELECT COUNT(*) FROM $table;" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ $table accessible${NC}"
    else
        echo -e "${RED}❌ $table not accessible${NC}"
    fi
done

echo ""
echo -e "${YELLOW}📊 Data summary from views:${NC}"
if docker exec postgres psql -U n8nuser -d n8ndb -c "SET search_path TO n8n; SELECT * FROM v_data_summary;" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Data summary view working${NC}"
    docker exec postgres psql -U n8nuser -d n8ndb -c "SET search_path TO n8n; SELECT * FROM v_data_summary;"
else
    echo -e "${RED}❌ Data summary view not working${NC}"
fi

echo ""
echo -e "${YELLOW}🏥 Database health:${NC}"
if docker exec postgres psql -U n8nuser -d n8ndb -c "SET search_path TO n8n; SELECT * FROM v_database_health;" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Database health view working${NC}"
    docker exec postgres psql -U n8nuser -d n8ndb -c "SET search_path TO n8n; SELECT * FROM v_database_health;"
else
    echo -e "${RED}❌ Database health view not working${NC}"
fi

echo ""
echo -e "${BLUE}Verification completed.${NC}" 