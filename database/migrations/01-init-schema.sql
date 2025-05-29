-- Comprehensive n8n Database Schema Migration
-- Compiled from database/ref migration files for RFC-001

-- Create schema and extensions (20230801_001)
CREATE SCHEMA IF NOT EXISTS n8n;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table (20230801_002)
CREATE TABLE n8n.users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR NOT NULL UNIQUE,
    username VARCHAR UNIQUE NOT NULL,
    password VARCHAR,
    avatar_url VARCHAR,
    is_vip BOOLEAN DEFAULT false,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_users_email ON n8n.users(email);
CREATE INDEX idx_users_username ON n8n.users(username);

-- User OAuth table (20230801_003)
CREATE TABLE n8n.user_oauth (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES n8n.users(id) ON DELETE CASCADE,
    provider VARCHAR(50) NOT NULL,
    provider_user_id VARCHAR NOT NULL,
    access_token VARCHAR,
    refresh_token VARCHAR,
    profile_data JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(provider, provider_user_id)
);
CREATE INDEX idx_user_oauth_user_id ON n8n.user_oauth(user_id);
CREATE INDEX idx_user_oauth_provider ON n8n.user_oauth(provider);

-- Workflows table (20230802_001)
CREATE TABLE n8n.workflows (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    slug VARCHAR UNIQUE,
    n8n_workflow_id VARCHAR(255),
    is_public BOOLEAN NOT NULL DEFAULT false,
    current_version_id UUID,
    input JSONB,
    output JSONB,
    doc_url VARCHAR,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_workflows_name ON n8n.workflows(name);
CREATE INDEX idx_workflows_is_public ON n8n.workflows(is_public);

-- Workflow versions table (20230802_002)
CREATE TABLE n8n.workflow_versions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workflow_id UUID NOT NULL REFERENCES n8n.workflows(id) ON DELETE CASCADE,
    version INTEGER NOT NULL,
    configuration JSONB NOT NULL,
    form_schema JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(workflow_id, version)
);
CREATE INDEX idx_workflow_versions_workflow_id ON n8n.workflow_versions(workflow_id);

-- Add foreign key to workflows.current_version_id
ALTER TABLE n8n.workflows 
ADD CONSTRAINT fk_workflows_current_version 
FOREIGN KEY (current_version_id) REFERENCES n8n.workflow_versions(id) ON DELETE SET NULL;

-- User workflow favorites table (20230803_001)
CREATE TABLE n8n.user_workflow_favorites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES n8n.users(id) ON DELETE CASCADE,
    workflow_id UUID NOT NULL REFERENCES n8n.workflows(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, workflow_id)
);
CREATE INDEX idx_user_workflow_favorites_user_id ON n8n.user_workflow_favorites(user_id);
CREATE INDEX idx_user_workflow_favorites_workflow_id ON n8n.user_workflow_favorites(workflow_id);

-- Workflow tier limits table (20230803_002)
CREATE TABLE n8n.workflow_tier_limits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workflow_id UUID NOT NULL REFERENCES n8n.workflows(id) ON DELETE CASCADE,
    tier VARCHAR(50) NOT NULL, -- 'free', 'pro', 'premium', 'vip'
    limit_unit VARCHAR(50) NOT NULL, -- 'executions_per_day', 'execution_time_sec', etc.
    limit_value INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(workflow_id, tier, limit_unit)
);
CREATE INDEX idx_workflow_tier_limits_workflow_id ON n8n.workflow_tier_limits(workflow_id);
CREATE INDEX idx_workflow_tier_limits_tier ON n8n.workflow_tier_limits(tier);

-- Log workflow executions table (20230804_001)
CREATE TABLE n8n.log_workflow_executions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workflow_id UUID NOT NULL REFERENCES n8n.workflows(id) ON DELETE CASCADE,
    workflow_version_id UUID REFERENCES n8n.workflow_versions(id) ON DELETE SET NULL,
    user_id UUID REFERENCES n8n.users(id) ON DELETE SET NULL,
    order_id UUID, -- Will be added as FK later in 20230806_001
    status VARCHAR(50) NOT NULL, -- 'pending', 'running', 'completed', 'failed'
    input_data JSONB,
    output_data JSONB,
    error_message TEXT,
    started_at TIMESTAMP NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMP,
    execution_time_ms INTEGER
);
CREATE INDEX idx_log_workflow_executions_workflow_id ON n8n.log_workflow_executions(workflow_id);
CREATE INDEX idx_log_workflow_executions_user_id ON n8n.log_workflow_executions(user_id);
CREATE INDEX idx_log_workflow_executions_status ON n8n.log_workflow_executions(status);
CREATE INDEX idx_log_workflow_executions_started_at ON n8n.log_workflow_executions(started_at);

-- Orders table (20230804_002)
CREATE TABLE n8n.orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES n8n.users(id) ON DELETE CASCADE,
    workflow_id UUID NOT NULL REFERENCES n8n.workflows(id) ON DELETE CASCADE,
    purchase_date TIMESTAMP NOT NULL DEFAULT NOW(),
    expiry_date TIMESTAMP,
    is_active BOOLEAN NOT NULL DEFAULT true,
    transaction_id VARCHAR,
    note TEXT,
    is_vip BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_orders_user_id ON n8n.orders(user_id);
CREATE INDEX idx_orders_workflow_id ON n8n.orders(workflow_id);
CREATE INDEX idx_orders_is_active ON n8n.orders(is_active);
CREATE INDEX idx_orders_expiry_date ON n8n.orders(expiry_date);

-- VIP custom limits table (20230804_003)
CREATE TABLE n8n.vip_custom_limits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES n8n.users(id) ON DELETE CASCADE,
    workflow_id UUID NOT NULL REFERENCES n8n.workflows(id) ON DELETE CASCADE,
    limit_unit VARCHAR(50) NOT NULL,
    limit_value INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, workflow_id, limit_unit)
);
CREATE INDEX idx_vip_custom_limits_user_id ON n8n.vip_custom_limits(user_id);
CREATE INDEX idx_vip_custom_limits_workflow_id ON n8n.vip_custom_limits(workflow_id);

-- Log tables (20230805_001)
CREATE TABLE n8n.log_user_activities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES n8n.users(id) ON DELETE SET NULL,
    activity_type VARCHAR(50) NOT NULL,
    activity_data JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_log_user_activities_user_id ON n8n.log_user_activities(user_id);
CREATE INDEX idx_log_user_activities_activity_type ON n8n.log_user_activities(activity_type);
CREATE INDEX idx_log_user_activities_created_at ON n8n.log_user_activities(created_at);

CREATE TABLE n8n.log_workflow_changes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workflow_id UUID NOT NULL REFERENCES n8n.workflows(id) ON DELETE CASCADE,
    user_id UUID REFERENCES n8n.users(id) ON DELETE SET NULL,
    change_type VARCHAR(50) NOT NULL, -- 'created', 'updated', 'deleted', 'published'
    change_data JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_log_workflow_changes_workflow_id ON n8n.log_workflow_changes(workflow_id);
CREATE INDEX idx_log_workflow_changes_user_id ON n8n.log_workflow_changes(user_id);
CREATE INDEX idx_log_workflow_changes_change_type ON n8n.log_workflow_changes(change_type);
CREATE INDEX idx_log_workflow_changes_created_at ON n8n.log_workflow_changes(created_at);

CREATE TABLE n8n.log_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES n8n.users(id) ON DELETE SET NULL,
    order_id UUID REFERENCES n8n.orders(id) ON DELETE SET NULL,
    transaction_type VARCHAR(50) NOT NULL, -- 'purchase', 'refund', etc.
    amount DECIMAL(10, 2),
    currency VARCHAR(3) DEFAULT 'USD',
    status VARCHAR(50) NOT NULL, -- 'success', 'failed', 'pending'
    payment_method VARCHAR(50),
    transaction_data JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_log_transactions_user_id ON n8n.log_transactions(user_id);
CREATE INDEX idx_log_transactions_order_id ON n8n.log_transactions(order_id);
CREATE INDEX idx_log_transactions_transaction_type ON n8n.log_transactions(transaction_type);
CREATE INDEX idx_log_transactions_status ON n8n.log_transactions(status);
CREATE INDEX idx_log_transactions_created_at ON n8n.log_transactions(created_at);

CREATE TABLE n8n.log_usage (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES n8n.users(id) ON DELETE SET NULL,
    workflow_id UUID REFERENCES n8n.workflows(id) ON DELETE CASCADE,
    resource_type VARCHAR(50) NOT NULL, -- 'workflow_execution', 'api_call', etc.
    usage_count INTEGER NOT NULL DEFAULT 1, -- Will be renamed from 'count' in 20230806_001
    usage_date DATE NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_log_usage_user_id ON n8n.log_usage(user_id);
CREATE INDEX idx_log_usage_workflow_id ON n8n.log_usage(workflow_id);
CREATE INDEX idx_log_usage_resource_type ON n8n.log_usage(resource_type);
CREATE INDEX idx_log_usage_usage_date ON n8n.log_usage(usage_date);

-- Schema fixes (20230806_001)
-- Add foreign key for order_id in log_workflow_executions
ALTER TABLE n8n.log_workflow_executions 
ADD CONSTRAINT fk_log_workflow_executions_order_id 
FOREIGN KEY (order_id) REFERENCES n8n.orders(id) ON DELETE SET NULL;

CREATE INDEX idx_log_workflow_executions_order_id ON n8n.log_workflow_executions(order_id);

-- Extended Tables (New Requirements)
-- Comments Table
CREATE TABLE n8n.comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES n8n.users(id) ON DELETE CASCADE,
    target_type VARCHAR(50) NOT NULL, -- 'workflow', 'execution', 'user'
    target_id UUID NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    CONSTRAINT chk_target_type CHECK (target_type IN ('workflow', 'execution', 'user')),
    CONSTRAINT chk_content_length CHECK (LENGTH(content) > 0 AND LENGTH(content) <= 5000)
);
CREATE INDEX idx_comments_user_id ON n8n.comments(user_id);
CREATE INDEX idx_comments_target ON n8n.comments(target_type, target_id);
CREATE INDEX idx_comments_created_at ON n8n.comments(created_at);

-- Ratings Table
CREATE TABLE n8n.ratings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES n8n.users(id) ON DELETE CASCADE,
    workflow_id UUID NOT NULL REFERENCES n8n.workflows(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL,
    review TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    CONSTRAINT chk_rating_range CHECK (rating >= 1 AND rating <= 5),
    CONSTRAINT chk_review_length CHECK (review IS NULL OR LENGTH(review) <= 2000),
    CONSTRAINT uk_user_workflow_rating UNIQUE (user_id, workflow_id)
);
CREATE INDEX idx_ratings_user_id ON n8n.ratings(user_id);
CREATE INDEX idx_ratings_workflow_id ON n8n.ratings(workflow_id);
CREATE INDEX idx_ratings_rating ON n8n.ratings(rating);
CREATE INDEX idx_ratings_created_at ON n8n.ratings(created_at);

-- Triggers for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_comments_updated_at 
    BEFORE UPDATE ON n8n.comments 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ratings_updated_at 
    BEFORE UPDATE ON n8n.ratings 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();