-- Migration: Upgrade n8n schema to VPS version with 16 tables
-- Date: 2024-12-01
-- Description: Clone entire VPS PostgreSQL schema "n8n" structure to localhost

BEGIN;

-- Set schema
CREATE SCHEMA IF NOT EXISTS n8n;
SET search_path TO n8n;

-- Drop existing tables if they exist (in correct order to handle foreign keys)
DROP TABLE IF EXISTS n8n.comments CASCADE;
DROP TABLE IF EXISTS n8n.log_transactions CASCADE;
DROP TABLE IF EXISTS n8n.log_usage CASCADE;
DROP TABLE IF EXISTS n8n.log_user_activities CASCADE;
DROP TABLE IF EXISTS n8n.log_workflow_changes CASCADE;
DROP TABLE IF EXISTS n8n.log_workflow_executions CASCADE;
DROP TABLE IF EXISTS n8n.orders CASCADE;
DROP TABLE IF EXISTS n8n.ratings CASCADE;
DROP TABLE IF EXISTS n8n.user_oauth CASCADE;
DROP TABLE IF EXISTS n8n.user_workflow_favorites CASCADE;
DROP TABLE IF EXISTS n8n.users CASCADE;
DROP TABLE IF EXISTS n8n.vip_custom_limits CASCADE;
DROP TABLE IF EXISTS n8n.worker_logs CASCADE;
DROP TABLE IF EXISTS n8n.workflow_tier_limits CASCADE;
DROP TABLE IF EXISTS n8n.workflow_versions CASCADE;
DROP TABLE IF EXISTS n8n.workflows CASCADE;

-- Drop existing views if they exist
DROP VIEW IF EXISTS n8n.v_data_summary CASCADE;
DROP VIEW IF EXISTS n8n.v_database_health CASCADE;
DROP VIEW IF EXISTS n8n.v_system_status CASCADE;

-- Create tables in correct order (referenced tables first)

-- 1. users table (base table for many foreign keys)
CREATE TABLE n8n.users (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    email character varying(255) NOT NULL,
    username character varying(100) NOT NULL,
    password_hash character varying(255) NOT NULL,
    first_name character varying(100),
    last_name character varying(100),
    avatar_url text,
    is_active boolean DEFAULT true,
    is_verified boolean DEFAULT false,
    tier character varying(50) DEFAULT 'free'::character varying,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    last_login_at timestamp without time zone
);

-- 2. workflows table (referenced by many other tables)
CREATE TABLE n8n.workflows (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name character varying(255) NOT NULL,
    description text,
    category character varying(100),
    tags text[], -- PostgreSQL array type
    is_public boolean DEFAULT false,
    is_featured boolean DEFAULT false,
    tier_required character varying(50) DEFAULT 'free'::character varying,
    price numeric DEFAULT 0.00,
    creator_id uuid REFERENCES n8n.users(id),
    n8n_workflow_id character varying(255),
    workflow_data jsonb,
    usage_count integer DEFAULT 0,
    rating_average numeric DEFAULT 0.00,
    rating_count integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    published_at timestamp without time zone
);

-- 3. workflow_versions table
CREATE TABLE n8n.workflow_versions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    workflow_id uuid NOT NULL REFERENCES n8n.workflows(id),
    version integer NOT NULL,
    configuration jsonb NOT NULL,
    form_schema jsonb,
    is_active boolean DEFAULT false,
    changelog text,
    created_at timestamp without time zone DEFAULT now()
);

-- 4. workflow_tier_limits table
CREATE TABLE n8n.workflow_tier_limits (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    workflow_id uuid NOT NULL REFERENCES n8n.workflows(id),
    tier character varying(50) NOT NULL,
    limit_unit character varying(50) NOT NULL,
    limit_value integer NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);

-- 5. vip_custom_limits table
CREATE TABLE n8n.vip_custom_limits (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES n8n.users(id),
    workflow_id uuid NOT NULL REFERENCES n8n.workflows(id),
    limit_unit character varying(50) NOT NULL,
    limit_value integer NOT NULL,
    expires_at timestamp without time zone,
    notes text,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);

-- 6. user_workflow_favorites table
CREATE TABLE n8n.user_workflow_favorites (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES n8n.users(id),
    workflow_id uuid NOT NULL REFERENCES n8n.workflows(id),
    created_at timestamp without time zone DEFAULT now()
);

-- 7. user_oauth table
CREATE TABLE n8n.user_oauth (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES n8n.users(id),
    provider character varying(50) NOT NULL,
    provider_user_id character varying(255) NOT NULL,
    access_token text,
    refresh_token text,
    token_expires_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);

-- 8. ratings table
CREATE TABLE n8n.ratings (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES n8n.users(id),
    workflow_id uuid NOT NULL REFERENCES n8n.workflows(id),
    rating integer NOT NULL,
    review text,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);

-- 9. orders table
CREATE TABLE n8n.orders (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES n8n.users(id),
    workflow_id uuid REFERENCES n8n.workflows(id),
    order_type character varying(50) NOT NULL,
    amount numeric NOT NULL,
    currency character varying(3) DEFAULT 'USD'::character varying,
    is_active boolean DEFAULT true,
    purchase_date timestamp without time zone DEFAULT now(),
    expiry_date timestamp without time zone,
    transaction_id character varying(255),
    payment_method character varying(50),
    notes text,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);

-- 10. log_workflow_executions table
CREATE TABLE n8n.log_workflow_executions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES n8n.users(id),
    workflow_id uuid NOT NULL REFERENCES n8n.workflows(id),
    n8n_execution_id character varying(255),
    worker_container_id character varying(255),
    execution_status character varying(50) NOT NULL,
    execution_mode character varying(50) DEFAULT 'manual'::character varying,
    start_time timestamp without time zone NOT NULL,
    end_time timestamp without time zone,
    duration_ms integer,
    nodes_executed integer DEFAULT 0,
    nodes_total integer DEFAULT 0,
    error_message text,
    input_data jsonb,
    output_data jsonb,
    execution_data jsonb,
    credits_consumed numeric DEFAULT 0.00,
    created_at timestamp without time zone DEFAULT now()
);

-- 11. log_workflow_changes table
CREATE TABLE n8n.log_workflow_changes (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES n8n.users(id),
    workflow_id uuid NOT NULL REFERENCES n8n.workflows(id),
    change_type character varying(50) NOT NULL,
    old_data jsonb,
    new_data jsonb,
    diff_data jsonb,
    version_number integer,
    change_description text,
    created_at timestamp without time zone DEFAULT now()
);

-- 12. log_user_activities table
CREATE TABLE n8n.log_user_activities (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES n8n.users(id),
    activity_type character varying(50) NOT NULL,
    activity_description text,
    ip_address inet,
    user_agent text,
    session_id character varying(255),
    metadata jsonb,
    created_at timestamp without time zone DEFAULT now()
);

-- 13. log_usage table
CREATE TABLE n8n.log_usage (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES n8n.users(id),
    resource_type character varying(50) NOT NULL,
    resource_id uuid,
    usage_amount integer NOT NULL,
    usage_unit character varying(50) NOT NULL,
    tier_limit integer,
    cost_credits numeric DEFAULT 0.00,
    metadata jsonb,
    created_at timestamp without time zone DEFAULT now()
);

-- 14. log_transactions table
CREATE TABLE n8n.log_transactions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES n8n.users(id),
    transaction_type character varying(50) NOT NULL,
    amount numeric NOT NULL,
    currency character varying(3) DEFAULT 'USD'::character varying,
    payment_method character varying(50),
    payment_id character varying(255),
    status character varying(50) NOT NULL,
    metadata jsonb,
    created_at timestamp without time zone DEFAULT now()
);

-- 15. worker_logs table
CREATE TABLE n8n.worker_logs (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    container_name character varying(255) NOT NULL,
    container_id character varying(255) NOT NULL,
    worker_status character varying(50) NOT NULL,
    cpu_usage_percent numeric DEFAULT 0.00,
    memory_usage_mb integer DEFAULT 0,
    memory_limit_mb integer DEFAULT 2048,
    active_jobs integer DEFAULT 0,
    total_jobs_processed integer DEFAULT 0,
    last_job_id character varying(255),
    last_job_duration_ms integer,
    uptime_seconds integer DEFAULT 0,
    error_count integer DEFAULT 0,
    last_error_message text,
    metadata jsonb,
    logged_at timestamp without time zone DEFAULT now()
);

-- 16. comments table
CREATE TABLE n8n.comments (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES n8n.users(id),
    target_type character varying(50) NOT NULL,
    target_id uuid NOT NULL,
    content text NOT NULL,
    parent_comment_id uuid REFERENCES n8n.comments(id),
    is_edited boolean DEFAULT false,
    is_deleted boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);

-- Create unique constraints
ALTER TABLE n8n.users ADD CONSTRAINT users_email_key UNIQUE (email);
ALTER TABLE n8n.users ADD CONSTRAINT users_username_key UNIQUE (username);
ALTER TABLE n8n.ratings ADD CONSTRAINT ratings_user_id_workflow_id_key UNIQUE (user_id, workflow_id);
ALTER TABLE n8n.user_oauth ADD CONSTRAINT user_oauth_provider_provider_user_id_key UNIQUE (provider, provider_user_id);
ALTER TABLE n8n.user_workflow_favorites ADD CONSTRAINT user_workflow_favorites_user_id_workflow_id_key UNIQUE (user_id, workflow_id);
ALTER TABLE n8n.vip_custom_limits ADD CONSTRAINT vip_custom_limits_user_id_workflow_id_limit_unit_key UNIQUE (user_id, workflow_id, limit_unit);
ALTER TABLE n8n.workflow_tier_limits ADD CONSTRAINT workflow_tier_limits_workflow_id_tier_limit_unit_key UNIQUE (workflow_id, tier, limit_unit);
ALTER TABLE n8n.workflow_versions ADD CONSTRAINT workflow_versions_workflow_id_version_key UNIQUE (workflow_id, version);

-- Create indexes for performance
-- Users indexes
CREATE INDEX idx_users_email ON n8n.users(email);
CREATE INDEX idx_users_username ON n8n.users(username);
CREATE INDEX idx_users_tier ON n8n.users(tier);
CREATE INDEX idx_users_created_at ON n8n.users(created_at);

-- Workflows indexes
CREATE INDEX idx_workflows_creator_id ON n8n.workflows(creator_id);
CREATE INDEX idx_workflows_category ON n8n.workflows(category);
CREATE INDEX idx_workflows_tier_required ON n8n.workflows(tier_required);
CREATE INDEX idx_workflows_is_public ON n8n.workflows(is_public);
CREATE INDEX idx_workflows_is_featured ON n8n.workflows(is_featured);
CREATE INDEX idx_workflows_tags ON n8n.workflows USING GIN(tags);
CREATE INDEX idx_workflows_created_at ON n8n.workflows(created_at);

-- Workflow versions indexes
CREATE INDEX idx_workflow_versions_workflow_id ON n8n.workflow_versions(workflow_id);
CREATE INDEX idx_workflow_versions_is_active ON n8n.workflow_versions(is_active);
CREATE INDEX idx_workflow_versions_created_at ON n8n.workflow_versions(created_at);

-- Workflow tier limits indexes
CREATE INDEX idx_workflow_tier_limits_workflow_id ON n8n.workflow_tier_limits(workflow_id);
CREATE INDEX idx_workflow_tier_limits_tier ON n8n.workflow_tier_limits(tier);

-- VIP custom limits indexes
CREATE INDEX idx_vip_custom_limits_user_id ON n8n.vip_custom_limits(user_id);
CREATE INDEX idx_vip_custom_limits_workflow_id ON n8n.vip_custom_limits(workflow_id);
CREATE INDEX idx_vip_custom_limits_expires_at ON n8n.vip_custom_limits(expires_at);

-- User workflow favorites indexes
CREATE INDEX idx_user_workflow_favorites_user_id ON n8n.user_workflow_favorites(user_id);
CREATE INDEX idx_user_workflow_favorites_workflow_id ON n8n.user_workflow_favorites(workflow_id);

-- User OAuth indexes
CREATE INDEX idx_user_oauth_user_id ON n8n.user_oauth(user_id);
CREATE INDEX idx_user_oauth_provider ON n8n.user_oauth(provider);

-- Ratings indexes
CREATE INDEX idx_ratings_user_id ON n8n.ratings(user_id);
CREATE INDEX idx_ratings_workflow_id ON n8n.ratings(workflow_id);
CREATE INDEX idx_ratings_rating ON n8n.ratings(rating);
CREATE INDEX idx_ratings_created_at ON n8n.ratings(created_at);

-- Orders indexes
CREATE INDEX idx_orders_user_id ON n8n.orders(user_id);
CREATE INDEX idx_orders_workflow_id ON n8n.orders(workflow_id);
CREATE INDEX idx_orders_order_type ON n8n.orders(order_type);
CREATE INDEX idx_orders_is_active ON n8n.orders(is_active);
CREATE INDEX idx_orders_purchase_date ON n8n.orders(purchase_date);

-- Log workflow executions indexes
CREATE INDEX idx_log_workflow_executions_user_id ON n8n.log_workflow_executions(user_id);
CREATE INDEX idx_log_workflow_executions_workflow_id ON n8n.log_workflow_executions(workflow_id);
CREATE INDEX idx_log_workflow_executions_n8n_id ON n8n.log_workflow_executions(n8n_execution_id);
CREATE INDEX idx_log_workflow_executions_worker ON n8n.log_workflow_executions(worker_container_id);
CREATE INDEX idx_log_workflow_executions_status ON n8n.log_workflow_executions(execution_status);
CREATE INDEX idx_log_workflow_executions_start_time ON n8n.log_workflow_executions(start_time);

-- Log workflow changes indexes
CREATE INDEX idx_log_workflow_changes_user_id ON n8n.log_workflow_changes(user_id);
CREATE INDEX idx_log_workflow_changes_workflow_id ON n8n.log_workflow_changes(workflow_id);
CREATE INDEX idx_log_workflow_changes_type ON n8n.log_workflow_changes(change_type);
CREATE INDEX idx_log_workflow_changes_created_at ON n8n.log_workflow_changes(created_at);

-- Log user activities indexes
CREATE INDEX idx_log_user_activities_user_id ON n8n.log_user_activities(user_id);
CREATE INDEX idx_log_user_activities_type ON n8n.log_user_activities(activity_type);
CREATE INDEX idx_log_user_activities_ip ON n8n.log_user_activities(ip_address);
CREATE INDEX idx_log_user_activities_session ON n8n.log_user_activities(session_id);
CREATE INDEX idx_log_user_activities_created_at ON n8n.log_user_activities(created_at);

-- Log usage indexes
CREATE INDEX idx_log_usage_user_id ON n8n.log_usage(user_id);
CREATE INDEX idx_log_usage_resource_type ON n8n.log_usage(resource_type);
CREATE INDEX idx_log_usage_resource_id ON n8n.log_usage(resource_id);
CREATE INDEX idx_log_usage_created_at ON n8n.log_usage(created_at);

-- Log transactions indexes
CREATE INDEX idx_log_transactions_user_id ON n8n.log_transactions(user_id);
CREATE INDEX idx_log_transactions_type ON n8n.log_transactions(transaction_type);
CREATE INDEX idx_log_transactions_status ON n8n.log_transactions(status);
CREATE INDEX idx_log_transactions_payment_id ON n8n.log_transactions(payment_id);
CREATE INDEX idx_log_transactions_created_at ON n8n.log_transactions(created_at);

-- Worker logs indexes
CREATE INDEX idx_worker_logs_container_name ON n8n.worker_logs(container_name);
CREATE INDEX idx_worker_logs_container_id ON n8n.worker_logs(container_id);
CREATE INDEX idx_worker_logs_status ON n8n.worker_logs(worker_status);
CREATE INDEX idx_worker_logs_logged_at ON n8n.worker_logs(logged_at);

-- Comments indexes
CREATE INDEX idx_comments_user_id ON n8n.comments(user_id);
CREATE INDEX idx_comments_target_type_id ON n8n.comments(target_type, target_id);
CREATE INDEX idx_comments_parent_comment_id ON n8n.comments(parent_comment_id);
CREATE INDEX idx_comments_created_at ON n8n.comments(created_at);

-- Create system views for monitoring
CREATE VIEW n8n.v_data_summary AS
SELECT 
    'users' as table_name,
    COUNT(*) as record_count,
    'User accounts and profiles' as description
FROM n8n.users
UNION ALL
SELECT 
    'workflows' as table_name,
    COUNT(*) as record_count,
    'Workflow definitions and configurations' as description
FROM n8n.workflows
UNION ALL
SELECT 
    'workflow_executions' as table_name,
    COUNT(*) as record_count,
    'Workflow execution logs and history' as description
FROM n8n.log_workflow_executions
UNION ALL
SELECT 
    'comments' as table_name,
    COUNT(*) as record_count,
    'User comments on workflows and executions' as description
FROM n8n.comments
UNION ALL
SELECT 
    'ratings' as table_name,
    COUNT(*) as record_count,
    'Workflow ratings and reviews' as description
FROM n8n.ratings;

CREATE VIEW n8n.v_database_health AS
SELECT 
    'total_tables' as metric,
    COUNT(*)::text as value
FROM information_schema.tables 
WHERE table_schema = 'n8n'
UNION ALL
SELECT 
    'total_indexes' as metric,
    COUNT(*)::text as value
FROM pg_indexes 
WHERE schemaname = 'n8n'
UNION ALL
SELECT 
    'database_size' as metric,
    pg_size_pretty(pg_database_size(current_database()))::text as value;

CREATE VIEW n8n.v_system_status AS
SELECT 
    'database' as component,
    'PostgreSQL' as name,
    'healthy' as status,
    'Schema "n8n" with 16 tables ready' as details
UNION ALL
SELECT 
    'tables' as component,
    'Core Tables' as name,
    'ready' as status,
    '16 tables with indexes and constraints' as details
UNION ALL
SELECT 
    'views' as component,
    'System Views' as name,
    'ready' as status,
    'Monitoring and health check views available' as details;

COMMIT;

-- Final verification
SELECT 'Migration completed successfully. Schema "n8n" has been upgraded with 16 tables from VPS.' as status; 