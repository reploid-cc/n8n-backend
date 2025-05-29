-- Mock Data Seeding: Logging Tables
-- Description: Create comprehensive logging data with 70,000+ records
-- Tables: log_user_activities, log_usage, log_transactions, log_workflow_changes

SET search_path TO n8n;

-- Clear existing data
TRUNCATE TABLE log_user_activities RESTART IDENTITY CASCADE;
TRUNCATE TABLE log_usage RESTART IDENTITY CASCADE;
TRUNCATE TABLE log_transactions RESTART IDENTITY CASCADE;
TRUNCATE TABLE log_workflow_changes RESTART IDENTITY CASCADE;

-- ==========================================
-- LOG_USER_ACTIVITIES SEEDING (30,000 records)
-- ==========================================

-- Generate Free Tier User Activities (15,000 activities)
INSERT INTO log_user_activities (
    user_id, activity_type, activity_description, ip_address, user_agent,
    session_id, metadata, created_at
)
SELECT 
    (SELECT id FROM users WHERE tier = 'free' ORDER BY random() LIMIT 1),
    CASE (generate_series(1, 15000) % 12)
        WHEN 0 THEN 'login'
        WHEN 1 THEN 'logout'
        WHEN 2 THEN 'workflow_view'
        WHEN 3 THEN 'workflow_download'
        WHEN 4 THEN 'profile_update'
        WHEN 5 THEN 'password_change'
        WHEN 6 THEN 'search'
        WHEN 7 THEN 'comment_post'
        WHEN 8 THEN 'rating_submit'
        WHEN 9 THEN 'favorite_add'
        WHEN 10 THEN 'api_call'
        ELSE 'rate_limit_hit'
    END,
    CASE (generate_series(1, 15000) % 12)
        WHEN 0 THEN 'User logged in successfully'
        WHEN 1 THEN 'User logged out'
        WHEN 2 THEN 'Viewed workflow: ' || (SELECT name FROM workflows ORDER BY random() LIMIT 1)
        WHEN 3 THEN 'Downloaded workflow template'
        WHEN 4 THEN 'Updated profile information'
        WHEN 5 THEN 'Changed account password'
        WHEN 6 THEN 'Searched for workflows with keyword'
        WHEN 7 THEN 'Posted comment on workflow'
        WHEN 8 THEN 'Submitted workflow rating'
        WHEN 9 THEN 'Added workflow to favorites'
        WHEN 10 THEN 'Made API call to workflow execution'
        ELSE 'Hit free tier rate limit (10 calls/day)'
    END,
    CASE (generate_series(1, 15000) % 5)
        WHEN 0 THEN '192.168.1.' || (random() * 255)::integer
        WHEN 1 THEN '10.0.0.' || (random() * 255)::integer
        WHEN 2 THEN '203.0.113.' || (random() * 255)::integer
        WHEN 3 THEN '198.51.100.' || (random() * 255)::integer
        ELSE '172.16.0.' || (random() * 255)::integer
    END,
    CASE (generate_series(1, 15000) % 6)
        WHEN 0 THEN 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        WHEN 1 THEN 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
        WHEN 2 THEN 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36'
        WHEN 3 THEN 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X)'
        WHEN 4 THEN 'Mozilla/5.0 (Android 11; Mobile; rv:68.0) Gecko/68.0'
        ELSE 'n8n-client/1.0 (API)'
    END,
    'session_' || generate_series(1, 15000) || '_free',
    jsonb_build_object(
        'tier', 'free',
        'browser', CASE (generate_series(1, 15000) % 4)
            WHEN 0 THEN 'Chrome'
            WHEN 1 THEN 'Firefox'
            WHEN 2 THEN 'Safari'
            ELSE 'Edge'
        END,
        'country', CASE (generate_series(1, 15000) % 5)
            WHEN 0 THEN 'US'
            WHEN 1 THEN 'UK'
            WHEN 2 THEN 'DE'
            WHEN 3 THEN 'FR'
            ELSE 'CA'
        END,
        'device_type', CASE (generate_series(1, 15000) % 3)
            WHEN 0 THEN 'desktop'
            WHEN 1 THEN 'mobile'
            ELSE 'tablet'
        END
    ),
    NOW() - (random() * INTERVAL '120 days');

-- Generate Pro Tier User Activities (10,000 activities)
INSERT INTO log_user_activities (
    user_id, activity_type, activity_description, ip_address, user_agent,
    session_id, metadata, created_at
)
SELECT 
    (SELECT id FROM users WHERE tier = 'pro' ORDER BY random() LIMIT 1),
    CASE (generate_series(1, 10000) % 15)
        WHEN 0 THEN 'login'
        WHEN 1 THEN 'logout'
        WHEN 2 THEN 'workflow_create'
        WHEN 3 THEN 'workflow_edit'
        WHEN 4 THEN 'workflow_publish'
        WHEN 5 THEN 'workflow_execute'
        WHEN 6 THEN 'api_call'
        WHEN 7 THEN 'subscription_manage'
        WHEN 8 THEN 'payment_update'
        WHEN 9 THEN 'integration_setup'
        WHEN 10 THEN 'crm_sync'
        WHEN 11 THEN 'export_data'
        WHEN 12 THEN 'support_ticket'
        WHEN 13 THEN 'team_invite'
        ELSE 'analytics_view'
    END,
    CASE (generate_series(1, 10000) % 15)
        WHEN 0 THEN 'Pro user logged in'
        WHEN 1 THEN 'Pro user logged out'
        WHEN 2 THEN 'Created new workflow for business automation'
        WHEN 3 THEN 'Modified existing workflow configuration'
        WHEN 4 THEN 'Published workflow to marketplace'
        WHEN 5 THEN 'Executed workflow with pro features'
        WHEN 6 THEN 'API call with increased rate limits'
        WHEN 7 THEN 'Managed monthly subscription'
        WHEN 8 THEN 'Updated payment method'
        WHEN 9 THEN 'Configured CRM integration'
        WHEN 10 THEN 'Synchronized CRM data'
        WHEN 11 THEN 'Exported workflow execution data'
        WHEN 12 THEN 'Created support ticket'
        WHEN 13 THEN 'Invited team member to workspace'
        ELSE 'Viewed analytics dashboard'
    END,
    CASE (generate_series(1, 10000) % 4)
        WHEN 0 THEN '203.0.113.' || (random() * 255)::integer
        WHEN 1 THEN '198.51.100.' || (random() * 255)::integer
        WHEN 2 THEN '172.16.0.' || (random() * 255)::integer
        ELSE '10.0.0.' || (random() * 255)::integer
    END,
    'Mozilla/5.0 (Business Environment) AppleWebKit/537.36',
    'session_' || generate_series(1, 10000) || '_pro',
    jsonb_build_object(
        'tier', 'pro',
        'subscription_status', 'active',
        'api_calls_remaining', (random() * 1000 + 500)::integer,
        'workspace_id', 'ws_' || (random() * 1000)::integer,
        'features_used', ARRAY['crm_integration', 'advanced_scheduling']
    ),
    NOW() - (random() * INTERVAL '90 days');

-- Generate Premium Tier User Activities (3,500 activities)
INSERT INTO log_user_activities (
    user_id, activity_type, activity_description, ip_address, user_agent,
    session_id, metadata, created_at
)
SELECT 
    (SELECT id FROM users WHERE tier = 'premium' ORDER BY random() LIMIT 1),
    CASE (generate_series(1, 3500) % 12)
        WHEN 0 THEN 'login'
        WHEN 1 THEN 'enterprise_sync'
        WHEN 2 THEN 'data_export'
        WHEN 3 THEN 'analytics_query'
        WHEN 4 THEN 'batch_processing'
        WHEN 5 THEN 'api_integration'
        WHEN 6 THEN 'compliance_audit'
        WHEN 7 THEN 'performance_optimization'
        WHEN 8 THEN 'multi_region_deploy'
        WHEN 9 THEN 'security_scan'
        WHEN 10 THEN 'backup_create'
        ELSE 'admin_action'
    END,
    CASE (generate_series(1, 3500) % 12)
        WHEN 0 THEN 'Premium user enterprise login'
        WHEN 1 THEN 'Synchronized with enterprise systems'
        WHEN 2 THEN 'Exported large dataset (10M+ records)'
        WHEN 3 THEN 'Executed advanced analytics query'
        WHEN 4 THEN 'Processed batch of 50K+ items'
        WHEN 5 THEN 'Integrated with premium API endpoints'
        WHEN 6 THEN 'Performed compliance audit'
        WHEN 7 THEN 'Optimized workflow performance'
        WHEN 8 THEN 'Deployed to multiple regions'
        WHEN 9 THEN 'Executed security scan'
        WHEN 10 THEN 'Created enterprise backup'
        ELSE 'Performed administrative action'
    END,
    '10.0.0.' || (random() * 255)::integer, -- Enterprise network
    'Mozilla/5.0 (Enterprise) n8n-premium/1.0',
    'session_' || generate_series(1, 3500) || '_premium',
    jsonb_build_object(
        'tier', 'premium',
        'enterprise_id', 'ent_' || (random() * 100)::integer,
        'sla_tier', 'gold',
        'dedicated_support', true,
        'compliance_status', 'SOX_compliant'
    ),
    NOW() - (random() * INTERVAL '60 days');

-- Generate VIP Tier User Activities (1,500 activities)
INSERT INTO log_user_activities (
    user_id, activity_type, activity_description, ip_address, user_agent,
    session_id, metadata, created_at
)
SELECT 
    (SELECT id FROM users WHERE tier = 'vip' ORDER BY random() LIMIT 1),
    CASE (generate_series(1, 1500) % 8)
        WHEN 0 THEN 'login'
        WHEN 1 THEN 'custom_development'
        WHEN 2 THEN 'white_label_deploy'
        WHEN 3 THEN 'api_partnership'
        WHEN 4 THEN 'dedicated_support'
        WHEN 5 THEN 'custom_integration'
        WHEN 6 THEN 'strategic_consultation'
        ELSE 'exclusive_feature'
    END,
    CASE (generate_series(1, 1500) % 8)
        WHEN 0 THEN 'VIP user exclusive access'
        WHEN 1 THEN 'Custom workflow development session'
        WHEN 2 THEN 'White-label platform deployment'
        WHEN 3 THEN 'API partnership configuration'
        WHEN 4 THEN 'Dedicated support consultation'
        WHEN 5 THEN 'Custom enterprise integration'
        WHEN 6 THEN 'Strategic planning consultation'
        ELSE 'Access to exclusive VIP features'
    END,
    '172.16.0.' || (random() * 255)::integer, -- VIP network
    'Mozilla/5.0 (VIP-Client) n8n-vip/1.0',
    'session_' || generate_series(1, 1500) || '_vip',
    jsonb_build_object(
        'tier', 'vip',
        'account_manager', 'dedicated',
        'custom_features', true,
        'white_label', true,
        'sla_tier', 'platinum',
        'priority_support', true
    ),
    NOW() - (random() * INTERVAL '45 days');

-- ==========================================
-- LOG_USAGE SEEDING (20,000 records)
-- ==========================================

-- Generate Free Tier Usage Logs (8,000 records)
INSERT INTO log_usage (
    user_id, resource_type, usage_amount, usage_unit, billing_cycle,
    tier_limit, cost_per_unit, metadata, created_at
)
SELECT 
    (SELECT id FROM users WHERE tier = 'free' ORDER BY random() LIMIT 1),
    CASE (generate_series(1, 8000) % 5)
        WHEN 0 THEN 'api_calls'
        WHEN 1 THEN 'workflow_executions'
        WHEN 2 THEN 'data_transfer'
        WHEN 3 THEN 'storage'
        ELSE 'compute_time'
    END,
    CASE (generate_series(1, 8000) % 5)
        WHEN 0 THEN (random() * 10 + 1)::integer     -- API calls: 1-10
        WHEN 1 THEN (random() * 5 + 1)::integer      -- Executions: 1-5
        WHEN 2 THEN (random() * 100 + 10)::integer   -- Data transfer MB: 10-100
        WHEN 3 THEN (random() * 50 + 5)::integer     -- Storage MB: 5-50
        ELSE (random() * 30 + 5)::integer            -- Compute seconds: 5-30
    END,
    CASE (generate_series(1, 8000) % 5)
        WHEN 0 THEN 'calls'
        WHEN 1 THEN 'executions'
        WHEN 2 THEN 'MB'
        WHEN 3 THEN 'MB'
        ELSE 'seconds'
    END,
    'daily',
    CASE (generate_series(1, 8000) % 5)
        WHEN 0 THEN 10    -- API calls limit
        WHEN 1 THEN 5     -- Executions limit
        WHEN 2 THEN 100   -- Data transfer limit
        WHEN 3 THEN 50    -- Storage limit
        ELSE 30           -- Compute time limit
    END,
    0.00, -- Free tier
    jsonb_build_object(
        'tier', 'free',
        'rate_limited', CASE WHEN random() < 0.2 THEN true ELSE false END,
        'warning_sent', CASE WHEN random() < 0.1 THEN true ELSE false END
    ),
    NOW() - (random() * INTERVAL '120 days');

-- Generate Pro Tier Usage Logs (7,000 records)
INSERT INTO log_usage (
    user_id, resource_type, usage_amount, usage_unit, billing_cycle,
    tier_limit, cost_per_unit, metadata, created_at
)
SELECT 
    (SELECT id FROM users WHERE tier = 'pro' ORDER BY random() LIMIT 1),
    CASE (generate_series(1, 7000) % 6)
        WHEN 0 THEN 'api_calls'
        WHEN 1 THEN 'workflow_executions'
        WHEN 2 THEN 'data_transfer'
        WHEN 3 THEN 'storage'
        WHEN 4 THEN 'compute_time'
        ELSE 'premium_features'
    END,
    CASE (generate_series(1, 7000) % 6)
        WHEN 0 THEN (random() * 1000 + 50)::integer    -- API calls: 50-1000
        WHEN 1 THEN (random() * 100 + 10)::integer     -- Executions: 10-100
        WHEN 2 THEN (random() * 1000 + 100)::integer   -- Data transfer MB: 100-1000
        WHEN 3 THEN (random() * 500 + 50)::integer     -- Storage MB: 50-500
        WHEN 4 THEN (random() * 300 + 60)::integer     -- Compute seconds: 60-300
        ELSE (random() * 20 + 5)::integer              -- Premium features: 5-20
    END,
    CASE (generate_series(1, 7000) % 6)
        WHEN 0 THEN 'calls'
        WHEN 1 THEN 'executions'
        WHEN 2 THEN 'MB'
        WHEN 3 THEN 'MB'
        WHEN 4 THEN 'seconds'
        ELSE 'features'
    END,
    'monthly',
    CASE (generate_series(1, 7000) % 6)
        WHEN 0 THEN 10000   -- API calls limit
        WHEN 1 THEN 1000    -- Executions limit
        WHEN 2 THEN 10000   -- Data transfer limit
        WHEN 3 THEN 5000    -- Storage limit
        WHEN 4 THEN 30000   -- Compute time limit
        ELSE 100            -- Premium features limit
    END,
    CASE (generate_series(1, 7000) % 6)
        WHEN 0 THEN 0.01
        WHEN 1 THEN 0.10
        WHEN 2 THEN 0.05
        WHEN 3 THEN 0.02
        WHEN 4 THEN 0.03
        ELSE 1.00
    END,
    jsonb_build_object(
        'tier', 'pro',
        'subscription_id', 'sub_pro_' || (random() * 1000)::integer,
        'overage_protection', true
    ),
    NOW() - (random() * INTERVAL '90 days');

-- Generate Premium Tier Usage Logs (3,500 records)
INSERT INTO log_usage (
    user_id, resource_type, usage_amount, usage_unit, billing_cycle,
    tier_limit, cost_per_unit, metadata, created_at
)
SELECT 
    (SELECT id FROM users WHERE tier = 'premium' ORDER BY random() LIMIT 1),
    CASE (generate_series(1, 3500) % 7)
        WHEN 0 THEN 'api_calls'
        WHEN 1 THEN 'workflow_executions'
        WHEN 2 THEN 'data_transfer'
        WHEN 3 THEN 'storage'
        WHEN 4 THEN 'compute_time'
        WHEN 5 THEN 'enterprise_features'
        ELSE 'analytics_queries'
    END,
    CASE (generate_series(1, 3500) % 7)
        WHEN 0 THEN (random() * 10000 + 1000)::integer   -- API calls: 1000-10000
        WHEN 1 THEN (random() * 1000 + 100)::integer     -- Executions: 100-1000
        WHEN 2 THEN (random() * 10000 + 1000)::integer   -- Data transfer MB: 1000-10000
        WHEN 3 THEN (random() * 5000 + 500)::integer     -- Storage MB: 500-5000
        WHEN 4 THEN (random() * 3600 + 600)::integer     -- Compute seconds: 600-3600
        WHEN 5 THEN (random() * 50 + 10)::integer        -- Enterprise features: 10-50
        ELSE (random() * 100 + 20)::integer              -- Analytics queries: 20-100
    END,
    CASE (generate_series(1, 3500) % 7)
        WHEN 0 THEN 'calls'
        WHEN 1 THEN 'executions'
        WHEN 2 THEN 'MB'
        WHEN 3 THEN 'MB'
        WHEN 4 THEN 'seconds'
        WHEN 5 THEN 'features'
        ELSE 'queries'
    END,
    'monthly',
    CASE (generate_series(1, 3500) % 7)
        WHEN 0 THEN 100000  -- API calls limit
        WHEN 1 THEN 10000   -- Executions limit
        WHEN 2 THEN 100000  -- Data transfer limit
        WHEN 3 THEN 50000   -- Storage limit
        WHEN 4 THEN 360000  -- Compute time limit
        WHEN 5 THEN 1000    -- Enterprise features limit
        ELSE 10000          -- Analytics queries limit
    END,
    CASE (generate_series(1, 3500) % 7)
        WHEN 0 THEN 0.005
        WHEN 1 THEN 0.05
        WHEN 2 THEN 0.02
        WHEN 3 THEN 0.01
        WHEN 4 THEN 0.02
        WHEN 5 THEN 2.00
        ELSE 0.50
    END,
    jsonb_build_object(
        'tier', 'premium',
        'enterprise_id', 'ent_' || (random() * 100)::integer,
        'unlimited_features', ARRAY['analytics', 'compliance']
    ),
    NOW() - (random() * INTERVAL '60 days');

-- Generate VIP Tier Usage Logs (1,500 records)  
INSERT INTO log_usage (
    user_id, resource_type, usage_amount, usage_unit, billing_cycle,
    tier_limit, cost_per_unit, metadata, created_at
)
SELECT 
    (SELECT id FROM users WHERE tier = 'vip' ORDER BY random() LIMIT 1),
    CASE (generate_series(1, 1500) % 5)
        WHEN 0 THEN 'unlimited_api_calls'
        WHEN 1 THEN 'unlimited_executions'
        WHEN 2 THEN 'custom_development_hours'
        WHEN 3 THEN 'dedicated_support_hours'
        ELSE 'white_label_deployments'
    END,
    CASE (generate_series(1, 1500) % 5)
        WHEN 0 THEN (random() * 100000 + 10000)::integer  -- API calls: 10K-100K
        WHEN 1 THEN (random() * 10000 + 1000)::integer    -- Executions: 1K-10K
        WHEN 2 THEN (random() * 40 + 5)::integer          -- Dev hours: 5-40
        WHEN 3 THEN (random() * 20 + 2)::integer          -- Support hours: 2-20
        ELSE (random() * 5 + 1)::integer                  -- Deployments: 1-5
    END,
    CASE (generate_series(1, 1500) % 5)
        WHEN 0 THEN 'calls'
        WHEN 1 THEN 'executions'
        WHEN 2 THEN 'hours'
        WHEN 3 THEN 'hours'
        ELSE 'deployments'
    END,
    'annual',
    -1, -- Unlimited
    CASE (generate_series(1, 1500) % 5)
        WHEN 0 THEN 0.00   -- Unlimited API
        WHEN 1 THEN 0.00   -- Unlimited executions
        WHEN 2 THEN 500.00 -- Custom development
        WHEN 3 THEN 300.00 -- Dedicated support
        ELSE 1000.00       -- White-label deployment
    END,
    jsonb_build_object(
        'tier', 'vip',
        'unlimited', true,
        'custom_pricing', true,
        'dedicated_infrastructure', true
    ),
    NOW() - (random() * INTERVAL '45 days');

-- ==========================================
-- LOG_TRANSACTIONS SEEDING (8,000 records)
-- ==========================================

-- Generate Pro Transaction Logs (3,500 records)
INSERT INTO log_transactions (
    user_id, order_id, transaction_type, amount, currency, payment_method,
    transaction_status, payment_gateway_response, metadata, created_at
)
SELECT 
    u.id,
    o.id,
    CASE (generate_series(1, 3500) % 6)
        WHEN 0 THEN 'subscription_payment'
        WHEN 1 THEN 'one_time_purchase'
        WHEN 2 THEN 'refund'
        WHEN 3 THEN 'chargeback'
        WHEN 4 THEN 'failed_payment'
        ELSE 'subscription_renewal'
    END,
    CASE (generate_series(1, 3500) % 6)
        WHEN 0 THEN ROUND((random() * 40 + 20)::numeric, 2)  -- Subscription: $20-60
        WHEN 1 THEN ROUND((random() * 80 + 10)::numeric, 2)  -- One-time: $10-90
        WHEN 2 THEN ROUND((random() * 50 + 10)::numeric, 2) * -1  -- Refund: -$10-60
        WHEN 3 THEN ROUND((random() * 60 + 20)::numeric, 2) * -1  -- Chargeback: -$20-80
        WHEN 4 THEN 0.00  -- Failed payment
        ELSE ROUND((random() * 50 + 25)::numeric, 2)         -- Renewal: $25-75
    END,
    'USD',
    CASE (generate_series(1, 3500) % 4)
        WHEN 0 THEN 'stripe'
        WHEN 1 THEN 'paypal'
        WHEN 2 THEN 'credit_card'
        ELSE 'bank_transfer'
    END,
    CASE (generate_series(1, 3500) % 10)
        WHEN 0 THEN 'failed'
        WHEN 1 THEN 'refunded'
        WHEN 8 THEN 'disputed'
        WHEN 9 THEN 'pending'
        ELSE 'completed'
    END,
    jsonb_build_object(
        'gateway_transaction_id', 'txn_' || generate_series(1, 3500) || '_' || extract(epoch from now())::bigint,
        'response_code', CASE (generate_series(1, 3500) % 10)
            WHEN 0 THEN '4001'  -- Failed
            WHEN 1 THEN '2000'  -- Refunded
            WHEN 8 THEN '4010'  -- Disputed
            WHEN 9 THEN '1000'  -- Pending
            ELSE '0000'         -- Success
        END,
        'processing_time_ms', (random() * 3000 + 500)::integer
    ),
    jsonb_build_object(
        'tier', 'pro',
        'subscription_cycle', 'monthly',
        'auto_renewal', true,
        'invoice_id', 'inv_' || generate_series(1, 3500)
    ),
    NOW() - (random() * INTERVAL '90 days')
FROM (
    SELECT u.id, o.id, row_number() OVER () as rn
    FROM users u 
    JOIN orders o ON u.id = o.user_id 
    WHERE u.tier = 'pro'
    ORDER BY random()
    LIMIT 3500
) AS u_o
WHERE u_o.rn <= 3500;

-- Generate Premium Transaction Logs (3,000 records)
INSERT INTO log_transactions (
    user_id, order_id, transaction_type, amount, currency, payment_method,
    transaction_status, payment_gateway_response, metadata, created_at
)
SELECT 
    u.id,
    o.id,
    CASE (generate_series(1, 3000) % 5)
        WHEN 0 THEN 'subscription_payment'
        WHEN 1 THEN 'enterprise_purchase'
        WHEN 2 THEN 'custom_development'
        WHEN 3 THEN 'support_package'
        ELSE 'subscription_renewal'
    END,
    CASE (generate_series(1, 3000) % 5)
        WHEN 0 THEN ROUND((random() * 100 + 70)::numeric, 2)   -- Subscription: $70-170
        WHEN 1 THEN ROUND((random() * 500 + 200)::numeric, 2)  -- Enterprise: $200-700
        WHEN 2 THEN ROUND((random() * 2000 + 500)::numeric, 2) -- Custom dev: $500-2500
        WHEN 3 THEN ROUND((random() * 300 + 100)::numeric, 2)  -- Support: $100-400
        ELSE ROUND((random() * 150 + 80)::numeric, 2)          -- Renewal: $80-230
    END,
    'USD',
    CASE (generate_series(1, 3000) % 3)
        WHEN 0 THEN 'enterprise_billing'
        WHEN 1 THEN 'wire_transfer'
        ELSE 'stripe'
    END,
    CASE (generate_series(1, 3000) % 20)
        WHEN 0 THEN 'pending'
        WHEN 19 THEN 'failed'
        ELSE 'completed'
    END,
    jsonb_build_object(
        'gateway_transaction_id', 'ent_txn_' || generate_series(1, 3000) || '_' || extract(epoch from now())::bigint,
        'response_code', CASE (generate_series(1, 3000) % 20)
            WHEN 0 THEN '1000'  -- Pending
            WHEN 19 THEN '4001' -- Failed
            ELSE '0000'         -- Success
        END,
        'processing_time_ms', (random() * 5000 + 1000)::integer
    ),
    jsonb_build_object(
        'tier', 'premium',
        'enterprise_id', 'ent_' || (random() * 100)::integer,
        'purchase_order', 'PO_' || generate_series(1, 3000),
        'contract_id', 'contract_' || (random() * 500)::integer
    ),
    NOW() - (random() * INTERVAL '60 days')
FROM (
    SELECT u.id, o.id, row_number() OVER () as rn
    FROM users u 
    JOIN orders o ON u.id = o.user_id 
    WHERE u.tier = 'premium'
    ORDER BY random()
    LIMIT 3000
) AS u_o
WHERE u_o.rn <= 3000;

-- Generate VIP Transaction Logs (1,500 records)
INSERT INTO log_transactions (
    user_id, order_id, transaction_type, amount, currency, payment_method,
    transaction_status, payment_gateway_response, metadata, created_at
)
SELECT 
    u.id,
    o.id,
    CASE (generate_series(1, 1500) % 4)
        WHEN 0 THEN 'annual_subscription'
        WHEN 1 THEN 'custom_development'
        WHEN 2 THEN 'white_label_license'
        ELSE 'strategic_partnership'
    END,
    CASE (generate_series(1, 1500) % 4)
        WHEN 0 THEN ROUND((random() * 2000 + 2000)::numeric, 2)  -- Annual: $2K-4K
        WHEN 1 THEN ROUND((random() * 5000 + 5000)::numeric, 2)  -- Custom: $5K-10K
        WHEN 2 THEN ROUND((random() * 10000 + 10000)::numeric, 2) -- White-label: $10K-20K
        ELSE ROUND((random() * 50000 + 25000)::numeric, 2)       -- Partnership: $25K-75K
    END,
    'USD',
    CASE (generate_series(1, 1500) % 3)
        WHEN 0 THEN 'wire_transfer'
        WHEN 1 THEN 'enterprise_billing'
        ELSE 'crypto'
    END,
    CASE (generate_series(1, 1500) % 50)
        WHEN 0 THEN 'pending'
        ELSE 'completed'
    END,
    jsonb_build_object(
        'gateway_transaction_id', 'vip_txn_' || generate_series(1, 1500) || '_' || extract(epoch from now())::bigint,
        'response_code', CASE (generate_series(1, 1500) % 50)
            WHEN 0 THEN '1000'  -- Pending
            ELSE '0000'         -- Success
        END,
        'processing_time_ms', (random() * 10000 + 2000)::integer
    ),
    jsonb_build_object(
        'tier', 'vip',
        'account_manager', 'dedicated',
        'custom_contract', true,
        'strategic_value', 'high',
        'white_label', true
    ),
    NOW() - (random() * INTERVAL '45 days')
FROM (
    SELECT u.id, o.id, row_number() OVER () as rn
    FROM users u 
    JOIN orders o ON u.id = o.user_id 
    WHERE u.tier = 'vip'
    ORDER BY random()
    LIMIT 1500
) AS u_o
WHERE u_o.rn <= 1500;

-- ==========================================
-- LOG_WORKFLOW_CHANGES SEEDING (12,000 records)
-- ==========================================

-- Generate Workflow Change Logs (12,000 records)
INSERT INTO log_workflow_changes (
    workflow_id, user_id, change_type, change_description, old_version,
    new_version, diff_data, metadata, created_at
)
SELECT 
    (SELECT id FROM workflows ORDER BY random() LIMIT 1),
    (SELECT id FROM users ORDER BY random() LIMIT 1),
    CASE (generate_series(1, 12000) % 10)
        WHEN 0 THEN 'create'
        WHEN 1 THEN 'update'
        WHEN 2 THEN 'publish'
        WHEN 3 THEN 'unpublish'
        WHEN 4 THEN 'version_update'
        WHEN 5 THEN 'node_add'
        WHEN 6 THEN 'node_remove'
        WHEN 7 THEN 'configuration_change'
        WHEN 8 THEN 'metadata_update'
        ELSE 'archive'
    END,
    CASE (generate_series(1, 12000) % 10)
        WHEN 0 THEN 'Created new workflow'
        WHEN 1 THEN 'Updated workflow configuration'
        WHEN 2 THEN 'Published workflow to marketplace'
        WHEN 3 THEN 'Unpublished workflow from marketplace'
        WHEN 4 THEN 'Updated workflow to new version'
        WHEN 5 THEN 'Added new node to workflow'
        WHEN 6 THEN 'Removed node from workflow'
        WHEN 7 THEN 'Changed node configuration'
        WHEN 8 THEN 'Updated workflow metadata'
        ELSE 'Archived workflow'
    END,
    CASE 
        WHEN generate_series(1, 12000) % 10 = 0 THEN NULL
        ELSE '1.' || (random() * 10)::integer
    END,
    CASE 
        WHEN generate_series(1, 12000) % 10 = 9 THEN NULL -- Archived
        ELSE '1.' || (random() * 10 + 1)::integer
    END,
    jsonb_build_object(
        'nodes_changed', ARRAY['node_' || (random() * 10)::integer],
        'properties_modified', ARRAY['configuration', 'credentials'],
        'lines_added', (random() * 50)::integer,
        'lines_removed', (random() * 30)::integer
    ),
    jsonb_build_object(
        'editor_type', CASE (generate_series(1, 12000) % 3)
            WHEN 0 THEN 'web'
            WHEN 1 THEN 'api'
            ELSE 'desktop'
        END,
        'change_size', CASE (generate_series(1, 12000) % 3)
            WHEN 0 THEN 'small'
            WHEN 1 THEN 'medium'
            ELSE 'large'
        END,
        'automated', CASE WHEN random() < 0.1 THEN true ELSE false END
    ),
    NOW() - (random() * INTERVAL '180 days');

-- Create specific demo logging entries
INSERT INTO log_user_activities (
    user_id, activity_type, activity_description, ip_address, user_agent,
    session_id, metadata, created_at
) VALUES
    -- Demo rate limiting scenario
    ((SELECT id FROM users WHERE username = 'demo_free_01'),
     'rate_limit_hit', 'Hit free tier rate limit (10 calls/day) - upgrade suggested',
     '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
     'session_demo_free_01_rate_limit',
     jsonb_build_object('tier', 'free', 'calls_today', 11, 'limit', 10, 'upgrade_prompted', true),
     NOW() - INTERVAL '1 hour'),
     
    -- Demo pro analytics access
    ((SELECT id FROM users WHERE username = 'demo_pro_01'),
     'analytics_view', 'Accessed pro analytics dashboard with conversion metrics',
     '203.0.113.50', 'Mozilla/5.0 (Business) AppleWebKit/537.36',
     'session_demo_pro_01_analytics',
     jsonb_build_object('tier', 'pro', 'dashboard', 'conversion_analytics', 'metrics_viewed', ARRAY['conversion_rate', 'roi']),
     NOW() - INTERVAL '2 hours');

-- Verification queries
-- User activities by tier and type
SELECT 
    u.tier,
    la.activity_type,
    COUNT(*) as activity_count
FROM log_user_activities la
JOIN users u ON la.user_id = u.id
GROUP BY u.tier, la.activity_type
ORDER BY u.tier, activity_count DESC;

-- Usage summary by tier
SELECT 
    u.tier,
    lu.resource_type,
    COUNT(*) as usage_records,
    ROUND(AVG(lu.usage_amount), 2) as avg_usage
FROM log_usage lu
JOIN users u ON lu.user_id = u.id
GROUP BY u.tier, lu.resource_type
ORDER BY u.tier, avg_usage DESC;

-- Transaction summary by tier
SELECT 
    u.tier,
    lt.transaction_type,
    COUNT(*) as transaction_count,
    ROUND(SUM(lt.amount), 2) as total_amount
FROM log_transactions lt
JOIN users u ON lt.user_id = u.id
GROUP BY u.tier, lt.transaction_type
ORDER BY total_amount DESC;

-- Workflow changes summary
SELECT 
    change_type,
    COUNT(*) as change_count
FROM log_workflow_changes
GROUP BY change_type
ORDER BY change_count DESC;

-- Total logging records created
SELECT 
    'user_activities' as log_type, COUNT(*) as total FROM log_user_activities
UNION ALL
SELECT 
    'usage_logs' as log_type, COUNT(*) as total FROM log_usage
UNION ALL
SELECT 
    'transactions' as log_type, COUNT(*) as total FROM log_transactions
UNION ALL
SELECT 
    'workflow_changes' as log_type, COUNT(*) as total FROM log_workflow_changes;

-- Success message
SELECT 'Logging seeding completed successfully! 70,000+ comprehensive logging records created across all tables.' as status; 