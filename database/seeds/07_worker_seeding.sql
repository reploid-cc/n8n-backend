-- Mock Data Seeding: Worker Logs and Supporting Tables
-- Description: Create worker performance logs and supporting tables for n8n production environment
-- Tables: worker_logs, workflow_versions, workflow_tier_limits, vip_custom_limits, user_oauth

SET search_path TO n8n;

-- Clear existing data
TRUNCATE TABLE worker_logs RESTART IDENTITY CASCADE;
TRUNCATE TABLE workflow_versions RESTART IDENTITY CASCADE;
TRUNCATE TABLE workflow_tier_limits RESTART IDENTITY CASCADE;
TRUNCATE TABLE vip_custom_limits RESTART IDENTITY CASCADE;
TRUNCATE TABLE user_oauth RESTART IDENTITY CASCADE;

-- ==========================================
-- WORKFLOW_VERSIONS SEEDING (300 versions)
-- ==========================================

-- Generate versions for Free workflows (120 versions)
INSERT INTO workflow_versions (
    workflow_id, version_number, version_name, changelog, 
    created_by, is_active, metadata, created_at, updated_at
)
SELECT 
    w.id,
    CASE (generate_series(1, 120) % 3)
        WHEN 0 THEN '1.0'
        WHEN 1 THEN '1.1'
        ELSE '1.2'
    END,
    CASE (generate_series(1, 120) % 6)
        WHEN 0 THEN 'Initial Release'
        WHEN 1 THEN 'Bug Fixes'
        WHEN 2 THEN 'Performance Improvements'
        WHEN 3 THEN 'User Feedback Updates'
        WHEN 4 THEN 'Documentation Updates'
        ELSE 'Minor Enhancements'
    END,
    CASE (generate_series(1, 120) % 6)
        WHEN 0 THEN 'First stable version with basic functionality'
        WHEN 1 THEN 'Fixed webhook timeout issues and improved error handling'
        WHEN 2 THEN 'Optimized API calls and reduced execution time by 20%'
        WHEN 3 THEN 'Added user-requested features and improved UI feedback'
        WHEN 4 THEN 'Updated documentation and added usage examples'
        ELSE 'Minor bug fixes and stability improvements'
    END,
    w.created_by,
    CASE (generate_series(1, 120) % 3) WHEN 2 THEN true ELSE false END, -- Latest version active
    jsonb_build_object(
        'nodes_count', (random() * 5 + 3)::integer,
        'api_calls', (random() * 3 + 1)::integer,
        'complexity', 'simple',
        'backward_compatible', true
    ),
    w.created_at + (generate_series(1, 120) % 3) * INTERVAL '7 days',
    w.updated_at + (generate_series(1, 120) % 3) * INTERVAL '7 days'
FROM (
    SELECT id, created_by, created_at, updated_at, row_number() OVER () as rn
    FROM workflows 
    WHERE tier_required = 'free'
    ORDER BY random()
    LIMIT 40
) w
CROSS JOIN generate_series(1, 3);

-- Generate versions for Pro workflows (120 versions)
INSERT INTO workflow_versions (
    workflow_id, version_number, version_name, changelog,
    created_by, is_active, metadata, created_at, updated_at
)
SELECT 
    w.id,
    CASE (generate_series(1, 120) % 4)
        WHEN 0 THEN '1.0'
        WHEN 1 THEN '1.1'
        WHEN 2 THEN '2.0'
        ELSE '2.1'
    END,
    CASE (generate_series(1, 120) % 8)
        WHEN 0 THEN 'Initial Pro Release'
        WHEN 1 THEN 'CRM Integration'
        WHEN 2 THEN 'Advanced Features'
        WHEN 3 THEN 'Performance Optimization'
        WHEN 4 THEN 'Security Enhancements'
        WHEN 5 THEN 'API Rate Limit Improvements'
        WHEN 6 THEN 'Business Logic Updates'
        ELSE 'Enterprise Compatibility'
    END,
    CASE (generate_series(1, 120) % 8)
        WHEN 0 THEN 'Professional version with enhanced business features'
        WHEN 1 THEN 'Added Salesforce, HubSpot, and Pipedrive integrations'
        WHEN 2 THEN 'Implemented advanced workflow conditions and loops'
        WHEN 3 THEN 'Improved execution speed and reduced resource usage'
        WHEN 4 THEN 'Enhanced security with encrypted credential storage'
        WHEN 5 THEN 'Increased API rate limits for pro users'
        WHEN 6 THEN 'Updated business logic for better lead qualification'
        ELSE 'Added compatibility with enterprise systems'
    END,
    w.created_by,
    CASE (generate_series(1, 120) % 4) WHEN 3 THEN true ELSE false END,
    jsonb_build_object(
        'nodes_count', (random() * 8 + 5)::integer,
        'api_calls', (random() * 10 + 5)::integer,
        'complexity', 'medium',
        'pro_features', ARRAY['crm_integration', 'advanced_scheduling'],
        'backward_compatible', true
    ),
    w.created_at + (generate_series(1, 120) % 4) * INTERVAL '14 days',
    w.updated_at + (generate_series(1, 120) % 4) * INTERVAL '14 days'
FROM (
    SELECT id, created_by, created_at, updated_at, row_number() OVER () as rn
    FROM workflows 
    WHERE tier_required = 'pro'
    ORDER BY random()
    LIMIT 30
) w
CROSS JOIN generate_series(1, 4);

-- Generate versions for Premium workflows (40 versions)
INSERT INTO workflow_versions (
    workflow_id, version_number, version_name, changelog,
    created_by, is_active, metadata, created_at, updated_at
)
SELECT 
    w.id,
    CASE (generate_series(1, 40) % 2)
        WHEN 0 THEN '1.0'
        ELSE '2.0'
    END,
    CASE (generate_series(1, 40) % 4)
        WHEN 0 THEN 'Enterprise Initial'
        WHEN 1 THEN 'Advanced Analytics'
        WHEN 2 THEN 'Compliance Update'
        ELSE 'Performance Enterprise'
    END,
    CASE (generate_series(1, 40) % 4)
        WHEN 0 THEN 'Enterprise-grade workflow with advanced features'
        WHEN 1 THEN 'Added advanced analytics and business intelligence'
        WHEN 2 THEN 'Updated for SOX compliance and audit requirements'
        ELSE 'Optimized for high-volume enterprise operations'
    END,
    w.created_by,
    CASE (generate_series(1, 40) % 2) WHEN 1 THEN true ELSE false END,
    jsonb_build_object(
        'nodes_count', (random() * 15 + 10)::integer,
        'api_calls', (random() * 30 + 15)::integer,
        'complexity', 'high',
        'enterprise_features', ARRAY['analytics', 'compliance', 'audit_trail'],
        'sla_tier', 'gold'
    ),
    w.created_at + (generate_series(1, 40) % 2) * INTERVAL '30 days',
    w.updated_at + (generate_series(1, 40) % 2) * INTERVAL '30 days'
FROM (
    SELECT id, created_by, created_at, updated_at, row_number() OVER () as rn
    FROM workflows 
    WHERE tier_required = 'premium'
    ORDER BY random()
    LIMIT 20
) w
CROSS JOIN generate_series(1, 2);

-- Generate versions for VIP workflows (20 versions)
INSERT INTO workflow_versions (
    workflow_id, version_number, version_name, changelog,
    created_by, is_active, metadata, created_at, updated_at
)
SELECT 
    w.id,
    '1.0',
    'VIP Exclusive',
    'Custom-developed workflow for VIP client requirements',
    w.created_by,
    true,
    jsonb_build_object(
        'nodes_count', (random() * 25 + 15)::integer,
        'api_calls', (random() * 100 + 50)::integer,
        'complexity', 'expert',
        'custom_features', ARRAY['white_label', 'custom_nodes', 'dedicated_support'],
        'development_hours', (random() * 40 + 20)::integer
    ),
    w.created_at,
    w.updated_at
FROM (
    SELECT id, created_by, created_at, updated_at
    FROM workflows 
    WHERE tier_required = 'vip'
    ORDER BY random()
    LIMIT 20
) w;

-- ==========================================
-- WORKFLOW_TIER_LIMITS SEEDING (4 records)
-- ==========================================

INSERT INTO workflow_tier_limits (
    tier, max_executions_per_day, max_api_calls_per_day, max_workflow_complexity,
    max_nodes_per_workflow, max_data_size_mb, priority_level, created_at, updated_at
) VALUES
    ('free', 5, 10, 'simple', 5, 10, 'low', NOW(), NOW()),
    ('pro', 1000, 10000, 'medium', 20, 100, 'medium', NOW(), NOW()),
    ('premium', 10000, 100000, 'high', 50, 1000, 'high', NOW(), NOW()),
    ('vip', -1, -1, 'expert', -1, -1, 'critical', NOW(), NOW());

-- ==========================================
-- VIP_CUSTOM_LIMITS SEEDING (30 records)
-- ==========================================

INSERT INTO vip_custom_limits (
    user_id, custom_executions_limit, custom_api_calls_limit, custom_data_size_mb,
    custom_nodes_limit, priority_override, dedicated_infrastructure, metadata,
    created_at, updated_at
)
SELECT 
    id,
    CASE (generate_series(1, 30) % 3)
        WHEN 0 THEN 50000
        WHEN 1 THEN 100000
        ELSE -1 -- Unlimited
    END,
    CASE (generate_series(1, 30) % 3)
        WHEN 0 THEN 500000
        WHEN 1 THEN 1000000
        ELSE -1 -- Unlimited
    END,
    CASE (generate_series(1, 30) % 3)
        WHEN 0 THEN 10000
        WHEN 1 THEN 50000
        ELSE -1 -- Unlimited
    END,
    -1, -- Unlimited nodes for all VIP
    'critical',
    true,
    jsonb_build_object(
        'account_manager', 'dedicated_' || generate_series(1, 30),
        'sla_response_time', '1_hour',
        'custom_features', ARRAY['white_label', 'api_partnership', 'custom_development'],
        'contract_value', (random() * 100000 + 25000)::integer,
        'support_level', 'platinum'
    ),
    NOW() - (random() * INTERVAL '180 days'),
    NOW() - (random() * INTERVAL '180 days')
FROM (
    SELECT id FROM users WHERE tier = 'vip' ORDER BY random() LIMIT 30
) vip_users;

-- ==========================================
-- USER_OAUTH SEEDING (400 connections)
-- ==========================================

-- Generate OAuth connections for all user tiers
INSERT INTO user_oauth (
    user_id, provider, provider_user_id, access_token, refresh_token,
    token_expires_at, scope, provider_data, created_at, updated_at
)
SELECT 
    u.id,
    CASE (generate_series(1, 400) % 8)
        WHEN 0 THEN 'google'
        WHEN 1 THEN 'microsoft'
        WHEN 2 THEN 'salesforce'
        WHEN 3 THEN 'hubspot'
        WHEN 4 THEN 'slack'
        WHEN 5 THEN 'github'
        WHEN 6 THEN 'linkedin'
        ELSE 'facebook'
    END,
    'provider_user_' || generate_series(1, 400) || '_' || u.tier,
    encode(gen_random_bytes(32), 'base64'),
    encode(gen_random_bytes(32), 'base64'),
    NOW() + INTERVAL '3600 seconds',
    CASE (generate_series(1, 400) % 8)
        WHEN 0 THEN 'https://www.googleapis.com/auth/spreadsheets https://www.googleapis.com/auth/drive'
        WHEN 1 THEN 'https://graph.microsoft.com/User.Read https://graph.microsoft.com/Mail.Send'
        WHEN 2 THEN 'api full refresh_token'
        WHEN 3 THEN 'contacts oauth'
        WHEN 4 THEN 'channels:read chat:write'
        WHEN 5 THEN 'repo user'
        WHEN 6 THEN 'r_basicprofile r_emailaddress'
        ELSE 'email public_profile'
    END,
    jsonb_build_object(
        'email', 'oauth_' || generate_series(1, 400) || '@example.com',
        'name', 'OAuth User ' || generate_series(1, 400),
        'profile_url', 'https://provider.com/user/' || generate_series(1, 400),
        'tier_allowed', u.tier,
        'permissions', ARRAY['read', 'write']
    ),
    NOW() - (random() * INTERVAL '90 days'),
    NOW() - (random() * INTERVAL '90 days')
FROM (
    SELECT id, tier FROM users ORDER BY random() LIMIT 400
) u;

-- ==========================================
-- WORKER_LOGS SEEDING (5,000 records)
-- ==========================================

-- Generate Worker Performance Logs
INSERT INTO worker_logs (
    worker_id, execution_id, task_type, task_status, processing_time_ms,
    memory_usage_mb, cpu_usage_percent, queue_wait_time_ms, error_details,
    metadata, created_at
)
SELECT 
    'worker_' || (generate_series(1, 5000) % 10 + 1),
    (SELECT id FROM log_workflow_executions ORDER BY random() LIMIT 1),
    CASE (generate_series(1, 5000) % 6)
        WHEN 0 THEN 'workflow_execution'
        WHEN 1 THEN 'webhook_processing'
        WHEN 2 THEN 'scheduled_task'
        WHEN 3 THEN 'api_request'
        WHEN 4 THEN 'data_processing'
        ELSE 'cleanup_task'
    END,
    CASE 
        WHEN generate_series(1, 5000) % 10 < 8 THEN 'completed'
        WHEN generate_series(1, 5000) % 10 = 8 THEN 'failed'
        ELSE 'timeout'
    END,
    CASE 
        WHEN generate_series(1, 5000) % 10 < 8 THEN (random() * 10000 + 500)::integer  -- Success: 0.5-10.5s
        ELSE (random() * 30000 + 5000)::integer                                        -- Failure: 5-35s
    END,
    (random() * 500 + 50)::integer,  -- Memory: 50-550MB
    (random() * 80 + 10)::integer,   -- CPU: 10-90%
    (random() * 5000 + 100)::integer, -- Queue wait: 0.1-5.1s
    CASE 
        WHEN generate_series(1, 5000) % 10 >= 8 THEN 
            CASE (generate_series(1, 5000) % 4)
                WHEN 0 THEN 'Memory limit exceeded during execution'
                WHEN 1 THEN 'Network timeout connecting to external API'
                WHEN 2 THEN 'Worker overload - too many concurrent tasks'
                ELSE 'Database connection timeout'
            END
        ELSE NULL
    END,
    jsonb_build_object(
        'worker_version', '1.' || (random() * 10)::integer,
        'queue_position', (random() * 100)::integer,
        'retry_count', CASE WHEN generate_series(1, 5000) % 10 >= 8 THEN (random() * 3)::integer ELSE 0 END,
        'resource_pool', CASE (generate_series(1, 5000) % 3)
            WHEN 0 THEN 'standard'
            WHEN 1 THEN 'high_memory'
            ELSE 'high_cpu'
        END,
        'region', CASE (generate_series(1, 5000) % 4)
            WHEN 0 THEN 'us-east-1'
            WHEN 1 THEN 'eu-west-1'
            WHEN 2 THEN 'ap-southeast-1'
            ELSE 'us-west-2'
        END
    ),
    NOW() - (random() * INTERVAL '30 days');

-- Create specific demo worker logs for business scenarios
INSERT INTO worker_logs (
    worker_id, execution_id, task_type, task_status, processing_time_ms,
    memory_usage_mb, cpu_usage_percent, queue_wait_time_ms, error_details,
    metadata, created_at
) VALUES
    -- Successful free tier execution
    ('worker_free_01', 
     (SELECT id FROM log_workflow_executions ORDER BY created_at DESC LIMIT 1),
     'workflow_execution', 'completed', 3200, 45, 25, 1200, NULL,
     jsonb_build_object('worker_version', '1.5', 'tier', 'free', 'optimization_level', 'basic'),
     NOW() - INTERVAL '1 hour'),
    
    -- Failed free tier execution due to limits
    ('worker_free_01',
     (SELECT id FROM log_workflow_executions WHERE execution_status = 'failed' ORDER BY created_at DESC LIMIT 1),
     'workflow_execution', 'failed', 8500, 65, 80, 5000, 'Free tier memory limit (60MB) exceeded',
     jsonb_build_object('worker_version', '1.5', 'tier', 'free', 'limit_exceeded', 'memory'),
     NOW() - INTERVAL '30 minutes'),
    
    -- Pro tier high performance
    ('worker_pro_01',
     (SELECT id FROM log_workflow_executions e JOIN workflows w ON e.workflow_id = w.id WHERE w.tier_required = 'pro' ORDER BY e.created_at DESC LIMIT 1),
     'workflow_execution', 'completed', 5400, 150, 35, 800, NULL,
     jsonb_build_object('worker_version', '1.8', 'tier', 'pro', 'optimization_level', 'enhanced'),
     NOW() - INTERVAL '2 hours'),
    
    -- VIP tier exclusive performance
    ('worker_vip_dedicated_01',
     (SELECT id FROM log_workflow_executions e JOIN workflows w ON e.workflow_id = w.id WHERE w.tier_required = 'vip' ORDER BY e.created_at DESC LIMIT 1),
     'workflow_execution', 'completed', 25600, 800, 45, 50, NULL,
     jsonb_build_object('worker_version', '2.0', 'tier', 'vip', 'dedicated_infrastructure', true, 'priority', 'critical'),
     NOW() - INTERVAL '4 hours');

-- Verification queries
-- Workflow versions summary
SELECT 
    w.tier_required,
    COUNT(wv.*) as version_count,
    COUNT(CASE WHEN wv.is_active THEN 1 END) as active_versions
FROM workflow_versions wv
JOIN workflows w ON wv.workflow_id = w.id
GROUP BY w.tier_required
ORDER BY version_count DESC;

-- VIP custom limits summary
SELECT 
    COUNT(*) as vip_users_with_custom_limits,
    COUNT(CASE WHEN custom_executions_limit = -1 THEN 1 END) as unlimited_executions,
    COUNT(CASE WHEN custom_api_calls_limit = -1 THEN 1 END) as unlimited_api_calls
FROM vip_custom_limits;

-- OAuth connections by provider
SELECT 
    provider,
    COUNT(*) as connection_count
FROM user_oauth
GROUP BY provider
ORDER BY connection_count DESC;

-- Worker performance summary
SELECT 
    task_status,
    COUNT(*) as task_count,
    ROUND(AVG(processing_time_ms), 2) as avg_processing_time_ms,
    ROUND(AVG(memory_usage_mb), 2) as avg_memory_usage_mb
FROM worker_logs
GROUP BY task_status
ORDER BY task_count DESC;

-- Supporting tables record count
SELECT 
    'workflow_versions' as table_name, COUNT(*) as total FROM workflow_versions
UNION ALL
SELECT 
    'workflow_tier_limits' as table_name, COUNT(*) as total FROM workflow_tier_limits
UNION ALL
SELECT 
    'vip_custom_limits' as table_name, COUNT(*) as total FROM vip_custom_limits
UNION ALL
SELECT 
    'user_oauth' as table_name, COUNT(*) as total FROM user_oauth
UNION ALL
SELECT 
    'worker_logs' as table_name, COUNT(*) as total FROM worker_logs;

-- Success message
SELECT 'Worker and supporting tables seeding completed successfully! 5,000+ worker logs and comprehensive supporting data created.' as status; 