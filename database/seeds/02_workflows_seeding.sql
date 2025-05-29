-- Mock Data Seeding: Workflows Table
-- Description: Create 200+ workflows across all user tiers with realistic business scenarios
-- Distribution: 150 Free, 80 Pro, 50 Premium, 20 VIP workflows

SET search_path TO n8n;

-- Clear existing data
TRUNCATE TABLE workflows RESTART IDENTITY CASCADE;

-- Generate Free Workflows (150 workflows)
INSERT INTO workflows (
    name, description, category, tags, is_public, is_featured,
    tier_required, price, creator_id, n8n_workflow_id, workflow_data,
    usage_count, rating_average, rating_count, created_at, updated_at, published_at
)
SELECT 
    'Free Workflow ' || gs.n,
    'Basic free workflow for ' ||
    CASE (gs.n % 8)
        WHEN 0 THEN 'simple automation'
        WHEN 1 THEN 'email notifications'
        WHEN 2 THEN 'webhook processing'
        WHEN 3 THEN 'social media posting'
        WHEN 4 THEN 'data collection'
        WHEN 5 THEN 'file management'
        WHEN 6 THEN 'calendar sync'
        ELSE 'task automation'
    END,
    CASE (gs.n % 8)
        WHEN 0 THEN 'Automation'
        WHEN 1 THEN 'Email'
        WHEN 2 THEN 'Webhook'
        WHEN 3 THEN 'Social Media'
        WHEN 4 THEN 'Data'
        WHEN 5 THEN 'File Management'
        WHEN 6 THEN 'Calendar'
        ELSE 'Tasks'
    END,
    ARRAY[
        'free', 'basic',
        CASE (gs.n % 4)
            WHEN 0 THEN 'simple'
            WHEN 1 THEN 'automation'
            WHEN 2 THEN 'notification'
            ELSE 'webhook'
        END
    ],
    CASE WHEN gs.n % 2 = 0 THEN true ELSE false END, -- 50% public
    CASE WHEN gs.n % 10 = 0 THEN true ELSE false END, -- 10% featured
    'free',
    '0.00', -- Free (string type)
    (SELECT id FROM users WHERE tier = 'free' ORDER BY random() LIMIT 1),
    'free_workflow_' || gs.n || '_n8n_id',
    jsonb_build_object(
        'nodes', jsonb_build_array(
            jsonb_build_object('type', 'trigger', 'name', 'webhook'),
            jsonb_build_object('type', 'action', 'name', 'function'),
            jsonb_build_object('type', 'action', 'name', 'email')
        ),
        'connections', jsonb_build_object(),
        'version', 1
    ),
    (random() * 500 + 50)::integer, -- Usage count 50-550
    ROUND((random() * 2 + 2.5)::numeric, 2)::text, -- Rating 2.5-4.5 (string type)
    (random() * 50 + 10)::integer, -- Rating count 10-60
    NOW() - (random() * INTERVAL '180 days'),
    NOW() - (random() * INTERVAL '30 days'),
    NOW() - (random() * INTERVAL '150 days')
FROM generate_series(1, 150) gs(n);

-- Generate Pro Workflows (80 workflows)  
INSERT INTO workflows (
    name, description, category, tags, is_public, is_featured,
    tier_required, price, creator_id, n8n_workflow_id, workflow_data,
    usage_count, rating_average, rating_count, created_at, updated_at, published_at
)
SELECT 
    'Pro Workflow ' || gs.n,
    'Professional workflow for ' ||
    CASE (gs.n % 6)
        WHEN 0 THEN 'advanced automation'
        WHEN 1 THEN 'CRM integration'
        WHEN 2 THEN 'lead generation'
        WHEN 3 THEN 'data processing'
        WHEN 4 THEN 'email campaigns'
        ELSE 'business intelligence'
    END,
    CASE (gs.n % 6)
        WHEN 0 THEN 'Automation'
        WHEN 1 THEN 'CRM'
        WHEN 2 THEN 'Lead Generation'
        WHEN 3 THEN 'Data Processing'
        WHEN 4 THEN 'Email Marketing'
        ELSE 'Business Intelligence'
    END,
    ARRAY[
        'pro', 'business',
        CASE (gs.n % 4)
            WHEN 0 THEN 'crm'
            WHEN 1 THEN 'automation'
            WHEN 2 THEN 'analytics'
            ELSE 'integration'
        END
    ],
    CASE WHEN gs.n % 3 = 0 THEN true ELSE false END, -- 33% public
    CASE WHEN gs.n % 8 = 0 THEN true ELSE false END, -- 12.5% featured
    'pro',
    ROUND((random() * 40 + 10)::numeric, 2)::text, -- Price $10-50 (string type)
    (SELECT id FROM users WHERE tier IN ('pro', 'premium', 'vip') ORDER BY random() LIMIT 1),
    'pro_workflow_' || gs.n || '_n8n_id',
    jsonb_build_object(
        'nodes', jsonb_build_array(
            jsonb_build_object('type', 'trigger', 'name', 'webhook'),
            jsonb_build_object('type', 'action', 'name', 'http_request'),
            jsonb_build_object('type', 'action', 'name', 'database'),
            jsonb_build_object('type', 'action', 'name', 'email'),
            jsonb_build_object('type', 'condition', 'name', 'if_condition')
        ),
        'connections', jsonb_build_object(),
        'version', 1
    ),
    (random() * 2000 + 500)::integer, -- Usage count 500-2500
    ROUND((random() * 1.5 + 3.5)::numeric, 2)::text, -- Rating 3.5-5.0 (string type)
    (random() * 100 + 20)::integer, -- Rating count 20-120
    NOW() - (random() * INTERVAL '120 days'),
    NOW() - (random() * INTERVAL '7 days'),
    NOW() - (random() * INTERVAL '90 days')
FROM generate_series(1, 80) gs(n);

-- Generate Premium Workflows (50 workflows)
INSERT INTO workflows (
    name, description, category, tags, is_public, is_featured,
    tier_required, price, creator_id, n8n_workflow_id, workflow_data,
    usage_count, rating_average, rating_count, created_at, updated_at, published_at
)
SELECT 
    'Premium Workflow ' || gs.n,
    'Enterprise-grade workflow for ' ||
    CASE (gs.n % 5)
        WHEN 0 THEN 'data synchronization'
        WHEN 1 THEN 'advanced analytics'
        WHEN 2 THEN 'multi-system integration'
        WHEN 3 THEN 'automated reporting'
        ELSE 'complex business processes'
    END,
    CASE (gs.n % 5)
        WHEN 0 THEN 'Data Sync'
        WHEN 1 THEN 'Analytics'
        WHEN 2 THEN 'Integration'
        WHEN 3 THEN 'Reporting'
        ELSE 'Business Process'
    END,
    ARRAY[
        'premium', 'enterprise',
        CASE (gs.n % 4)
            WHEN 0 THEN 'analytics'
            WHEN 1 THEN 'sync'
            WHEN 2 THEN 'reporting'
            ELSE 'process'
        END,
        'advanced'
    ],
    CASE WHEN gs.n % 4 = 0 THEN true ELSE false END, -- 25% public
    CASE WHEN gs.n % 5 = 0 THEN true ELSE false END, -- 20% featured
    'premium',
    ROUND((random() * 80 + 50)::numeric, 2)::text, -- Price $50-130 (string type)
    (SELECT id FROM users WHERE tier IN ('premium', 'vip') ORDER BY random() LIMIT 1),
    'premium_workflow_' || gs.n || '_n8n_id',
    jsonb_build_object(
        'nodes', jsonb_build_array(
            jsonb_build_object('type', 'trigger', 'name', 'schedule'),
            jsonb_build_object('type', 'action', 'name', 'database_query'),
            jsonb_build_object('type', 'action', 'name', 'data_transform'),
            jsonb_build_object('type', 'action', 'name', 'api_call'),
            jsonb_build_object('type', 'action', 'name', 'email_report'),
            jsonb_build_object('type', 'condition', 'name', 'switch'),
            jsonb_build_object('type', 'action', 'name', 'error_handler')
        ),
        'connections', jsonb_build_object(),
        'version', 1
    ),
    (random() * 1500 + 1000)::integer, -- Usage count 1000-2500
    ROUND((random() * 1 + 4)::numeric, 2)::text, -- Rating 4.0-5.0 (string type)
    (random() * 80 + 40)::integer, -- Rating count 40-120
    NOW() - (random() * INTERVAL '90 days'),
    NOW() - (random() * INTERVAL '3 days'),
    NOW() - (random() * INTERVAL '60 days')
FROM generate_series(1, 50) gs(n);

-- Generate VIP Workflows (20 workflows)
INSERT INTO workflows (
    name, description, category, tags, is_public, is_featured,
    tier_required, price, creator_id, n8n_workflow_id, workflow_data,
    usage_count, rating_average, rating_count, created_at, updated_at, published_at
)
SELECT 
    'VIP Exclusive ' || gs.n,
    'VIP-only custom workflow for ' ||
    CASE (gs.n % 4)
        WHEN 0 THEN 'enterprise automation'
        WHEN 1 THEN 'custom integrations'
        WHEN 2 THEN 'white-label solutions'
        ELSE 'bespoke business processes'
    END,
    CASE (gs.n % 4)
        WHEN 0 THEN 'Enterprise'
        WHEN 1 THEN 'Custom Integration'
        WHEN 2 THEN 'White Label'
        ELSE 'Bespoke'
    END,
    ARRAY['vip', 'exclusive', 'custom', 'enterprise', 'bespoke'],
    false, -- VIP workflows not public
    true, -- All VIP workflows featured
    'vip',
    ROUND((random() * 200 + 200)::numeric, 2)::text, -- Price $200-400 (string type)
    (SELECT id FROM users WHERE tier = 'vip' ORDER BY random() LIMIT 1),
    'vip_workflow_' || gs.n || '_n8n_id',
    jsonb_build_object(
        'nodes', jsonb_build_array(
            jsonb_build_object('type', 'trigger', 'name', 'advanced_webhook'),
            jsonb_build_object('type', 'action', 'name', 'custom_function'),
            jsonb_build_object('type', 'action', 'name', 'multi_database'),
            jsonb_build_object('type', 'action', 'name', 'complex_transform'),
            jsonb_build_object('type', 'action', 'name', 'enterprise_api'),
            jsonb_build_object('type', 'action', 'name', 'custom_notification'),
            jsonb_build_object('type', 'condition', 'name', 'advanced_logic'),
            jsonb_build_object('type', 'action', 'name', 'audit_log')
        ),
        'connections', jsonb_build_object(),
        'version', 1,
        'custom_config', jsonb_build_object('vip_features', true)
    ),
    (random() * 500 + 100)::integer, -- Usage count 100-600 (exclusive)
    ROUND((random() * 0.5 + 4.5)::numeric, 2)::text, -- Rating 4.5-5.0 (string type)
    (random() * 30 + 10)::integer, -- Rating count 10-40 (fewer users)
    NOW() - (random() * INTERVAL '60 days'),
    NOW() - (random() * INTERVAL '1 day'),
    NOW() - (random() * INTERVAL '30 days')
FROM generate_series(1, 20) gs(n);

-- Create specific demo workflows for business scenarios
INSERT INTO workflows (
    name, description, category, tags, is_public, is_featured,
    tier_required, price, creator_id, n8n_workflow_id, workflow_data,
    usage_count, rating_average, rating_count, created_at, updated_at, published_at
) VALUES
    -- Free tier demo workflows
    ('free_autoInbox_fb', 'Free Auto Inbox Facebook Integration', 'Social Media', 
     ARRAY['free', 'facebook', 'inbox'], true, false, 'free', '0.00',
     (SELECT id FROM users WHERE username = 'demo_free_01'),
     'free_autoInbox_fb_n8n_id',
     jsonb_build_object('nodes', jsonb_build_array(), 'limit_calls_per_day', 10),
     250, '4.2', 35, NOW() - INTERVAL '60 days', NOW(), NOW() - INTERVAL '45 days'),
    
    -- Pro tier demo workflows  
    ('pro_emailMarketing_auto', 'Pro Email Marketing Automation', 'Email Marketing',
     ARRAY['pro', 'email', 'marketing'], true, true, 'pro', '29.99',
     (SELECT id FROM users WHERE username = 'demo_pro_01'),
     'pro_emailMarketing_auto_n8n_id',
     jsonb_build_object('nodes', jsonb_build_array(), 'limit_calls_per_day', 100),
     1200, '4.6', 89, NOW() - INTERVAL '90 days', NOW(), NOW() - INTERVAL '75 days'),
     
    ('pro_leadGeneration_fb', 'Pro Lead Generation Facebook', 'Lead Generation',
     ARRAY['pro', 'leads', 'facebook'], false, false, 'pro', '39.99',
     (SELECT id FROM users WHERE username = 'demo_pro_02'),
     'pro_leadGeneration_fb_n8n_id',
     jsonb_build_object('nodes', jsonb_build_array(), 'limit_calls_per_day', 200),
     800, '4.4', 67, NOW() - INTERVAL '75 days', NOW(), NOW() - INTERVAL '60 days'),
    
    -- Premium tier demo workflows
    ('premium_dataSync_api', 'Premium Data Sync API Integration', 'Data Sync',
     ARRAY['premium', 'api', 'sync'], false, true, 'premium', '89.99',
     (SELECT id FROM users WHERE username = 'demo_premium_01'),
     'premium_dataSync_api_n8n_id',
     jsonb_build_object('nodes', jsonb_build_array(), 'limit_calls_per_day', 1000),
     2200, '4.8', 156, NOW() - INTERVAL '45 days', NOW(), NOW() - INTERVAL '30 days'),
     
    -- VIP tier demo workflows
    ('vip_enterprise_automation', 'VIP Enterprise Automation Suite', 'Enterprise',
     ARRAY['vip', 'enterprise', 'custom'], false, true, 'vip', '299.99',
     (SELECT id FROM users WHERE username = 'demo_vip_01'),
     'vip_enterprise_automation_n8n_id',
     jsonb_build_object('nodes', jsonb_build_array(), 'custom_features', true),
     450, '5.0', 28, NOW() - INTERVAL '30 days', NOW(), NOW() - INTERVAL '15 days');

-- Verification queries
-- Workflow count by tier
SELECT 
    tier_required,
    COUNT(*) as workflow_count,
    COUNT(CASE WHEN is_public THEN 1 END) as public_count,
    COUNT(CASE WHEN is_featured THEN 1 END) as featured_count
FROM workflows
GROUP BY tier_required
ORDER BY 
    CASE tier_required 
        WHEN 'free' THEN 1 
        WHEN 'pro' THEN 2 
        WHEN 'premium' THEN 3 
        WHEN 'vip' THEN 4 
    END;

-- Price analysis by tier (excluding free)
SELECT 
    tier_required,
    COUNT(*) as workflow_count,
    ROUND(AVG(price::numeric), 2) as avg_price,
    ROUND(MIN(price::numeric), 2) as min_price,
    ROUND(MAX(price::numeric), 2) as max_price
FROM workflows
WHERE tier_required != 'free'
GROUP BY tier_required;

-- Category distribution
SELECT 
    category,
    COUNT(*) as workflow_count
FROM workflows
GROUP BY category
ORDER BY workflow_count DESC;

-- Total workflow count
SELECT COUNT(*) as total_workflows FROM workflows;

-- Rating analysis - fixed function
SELECT 
    tier_required,
    ROUND(AVG(rating_average::numeric), 2) as avg_rating,
    ROUND(AVG(rating_count), 0) as avg_rating_count
FROM workflows
GROUP BY tier_required;

-- Success message
SELECT 'Workflows seeding completed successfully! 300+ workflows created across all tiers.' as status; 