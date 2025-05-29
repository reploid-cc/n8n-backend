-- Mock Data Seeding: Log Workflow Executions Table
-- Description: Create 10,000 workflow executions với realistic performance metrics and success rates by tier
-- Distribution: Free (40% success), Pro (70% success), Premium (85% success), VIP (95% success)

SET search_path TO n8n;

-- Clear existing data
TRUNCATE TABLE log_workflow_executions RESTART IDENTITY CASCADE;

-- Generate executions for Free workflows (4000 executions - 40% success rate)
INSERT INTO log_workflow_executions (
    workflow_id, user_id, execution_status, execution_time_ms, error_message,
    triggered_by, execution_data, resource_usage, created_at, updated_at
)
SELECT 
    (SELECT id FROM workflows WHERE tier_required = 'free' ORDER BY random() LIMIT 1),
    (SELECT id FROM users WHERE tier = 'free' ORDER BY random() LIMIT 1),
    CASE 
        WHEN generate_series(1, 4000) % 5 < 2 THEN 'success'  -- 40% success
        WHEN generate_series(1, 4000) % 5 = 2 THEN 'error'    -- 20% error
        WHEN generate_series(1, 4000) % 5 = 3 THEN 'timeout'  -- 20% timeout
        ELSE 'failed'                                          -- 20% failed
    END,
    CASE 
        WHEN generate_series(1, 4000) % 5 < 2 THEN (random() * 5000 + 1000)::integer  -- Success: 1-6s
        ELSE (random() * 15000 + 5000)::integer                                        -- Failure: 5-20s
    END,
    CASE 
        WHEN generate_series(1, 4000) % 5 >= 2 THEN 
            CASE (generate_series(1, 4000) % 4)
                WHEN 0 THEN 'Rate limit exceeded - free tier'
                WHEN 1 THEN 'Webhook timeout - free tier limitation'
                WHEN 2 THEN 'Memory limit exceeded'
                ELSE 'API call limit reached'
            END
        ELSE NULL
    END,
    CASE (generate_series(1, 4000) % 4)
        WHEN 0 THEN 'webhook'
        WHEN 1 THEN 'manual'
        WHEN 2 THEN 'schedule'
        ELSE 'api'
    END,
    jsonb_build_object(
        'input_size_bytes', (random() * 1000 + 100)::integer,
        'output_size_bytes', CASE WHEN generate_series(1, 4000) % 5 < 2 THEN (random() * 2000 + 200)::integer ELSE 0 END,
        'steps_completed', CASE WHEN generate_series(1, 4000) % 5 < 2 THEN (random() * 5 + 3)::integer ELSE (random() * 3 + 1)::integer END,
        'api_calls_made', (random() * 5 + 1)::integer
    ),
    jsonb_build_object(
        'memory_mb', (random() * 50 + 10)::integer,  -- Free tier: 10-60MB
        'cpu_time_ms', (random() * 2000 + 500)::integer,
        'network_bytes', (random() * 10000 + 1000)::integer
    ),
    NOW() - (random() * INTERVAL '90 days'),
    NOW() - (random() * INTERVAL '90 days');

-- Generate executions for Pro workflows (3500 executions - 70% success rate)
INSERT INTO log_workflow_executions (
    workflow_id, user_id, execution_status, execution_time_ms, error_message,
    triggered_by, execution_data, resource_usage, created_at, updated_at
)
SELECT 
    (SELECT id FROM workflows WHERE tier_required = 'pro' ORDER BY random() LIMIT 1),
    (SELECT id FROM users WHERE tier IN ('pro', 'premium', 'vip') ORDER BY random() LIMIT 1),
    CASE 
        WHEN generate_series(1, 3500) % 10 < 7 THEN 'success'  -- 70% success
        WHEN generate_series(1, 3500) % 10 = 7 THEN 'error'    -- 10% error
        WHEN generate_series(1, 3500) % 10 = 8 THEN 'timeout'  -- 10% timeout
        ELSE 'failed'                                           -- 10% failed
    END,
    CASE 
        WHEN generate_series(1, 3500) % 10 < 7 THEN (random() * 8000 + 500)::integer   -- Success: 0.5-8.5s
        ELSE (random() * 12000 + 3000)::integer                                         -- Failure: 3-15s
    END,
    CASE 
        WHEN generate_series(1, 3500) % 10 >= 7 THEN 
            CASE (generate_series(1, 3500) % 5)
                WHEN 0 THEN 'API rate limit exceeded'
                WHEN 1 THEN 'External service timeout'
                WHEN 2 THEN 'Data validation error'
                WHEN 3 THEN 'Authentication failed'
                ELSE 'Network connectivity issue'
            END
        ELSE NULL
    END,
    CASE (generate_series(1, 3500) % 5)
        WHEN 0 THEN 'webhook'
        WHEN 1 THEN 'schedule'
        WHEN 2 THEN 'manual'
        WHEN 3 THEN 'api'
        ELSE 'trigger'
    END,
    jsonb_build_object(
        'input_size_bytes', (random() * 5000 + 500)::integer,
        'output_size_bytes', CASE WHEN generate_series(1, 3500) % 10 < 7 THEN (random() * 10000 + 1000)::integer ELSE 0 END,
        'steps_completed', CASE WHEN generate_series(1, 3500) % 10 < 7 THEN (random() * 8 + 5)::integer ELSE (random() * 4 + 2)::integer END,
        'api_calls_made', (random() * 15 + 5)::integer
    ),
    jsonb_build_object(
        'memory_mb', (random() * 150 + 50)::integer,  -- Pro tier: 50-200MB
        'cpu_time_ms', (random() * 5000 + 1000)::integer,
        'network_bytes', (random() * 50000 + 5000)::integer
    ),
    NOW() - (random() * INTERVAL '60 days'),
    NOW() - (random() * INTERVAL '60 days');

-- Generate executions for Premium workflows (2000 executions - 85% success rate)
INSERT INTO log_workflow_executions (
    workflow_id, user_id, execution_status, execution_time_ms, error_message,
    triggered_by, execution_data, resource_usage, created_at, updated_at
)
SELECT 
    (SELECT id FROM workflows WHERE tier_required = 'premium' ORDER BY random() LIMIT 1),
    (SELECT id FROM users WHERE tier IN ('premium', 'vip') ORDER BY random() LIMIT 1),
    CASE 
        WHEN generate_series(1, 2000) % 20 < 17 THEN 'success'  -- 85% success
        WHEN generate_series(1, 2000) % 20 = 17 THEN 'error'    -- 5% error
        WHEN generate_series(1, 2000) % 20 = 18 THEN 'timeout'  -- 5% timeout
        ELSE 'failed'                                            -- 5% failed
    END,
    CASE 
        WHEN generate_series(1, 2000) % 20 < 17 THEN (random() * 10000 + 200)::integer  -- Success: 0.2-10.2s
        ELSE (random() * 8000 + 2000)::integer                                           -- Failure: 2-10s
    END,
    CASE 
        WHEN generate_series(1, 2000) % 20 >= 17 THEN 
            CASE (generate_series(1, 2000) % 4)
                WHEN 0 THEN 'Complex data processing timeout'
                WHEN 1 THEN 'External API unavailable'
                WHEN 2 THEN 'Database connection timeout'
                ELSE 'Resource allocation failed'
            END
        ELSE NULL
    END,
    CASE (generate_series(1, 2000) % 4)
        WHEN 0 THEN 'schedule'
        WHEN 1 THEN 'api'
        WHEN 2 THEN 'webhook'
        ELSE 'manual'
    END,
    jsonb_build_object(
        'input_size_bytes', (random() * 20000 + 2000)::integer,
        'output_size_bytes', CASE WHEN generate_series(1, 2000) % 20 < 17 THEN (random() * 50000 + 5000)::integer ELSE 0 END,
        'steps_completed', CASE WHEN generate_series(1, 2000) % 20 < 17 THEN (random() * 15 + 8)::integer ELSE (random() * 6 + 3)::integer END,
        'api_calls_made', (random() * 30 + 10)::integer
    ),
    jsonb_build_object(
        'memory_mb', (random() * 300 + 100)::integer,  -- Premium tier: 100-400MB
        'cpu_time_ms', (random() * 10000 + 2000)::integer,
        'network_bytes', (random() * 200000 + 20000)::integer
    ),
    NOW() - (random() * INTERVAL '45 days'),
    NOW() - (random() * INTERVAL '45 days');

-- Generate executions for VIP workflows (500 executions - 95% success rate)
INSERT INTO log_workflow_executions (
    workflow_id, user_id, execution_status, execution_time_ms, error_message,
    triggered_by, execution_data, resource_usage, created_at, updated_at
)
SELECT 
    (SELECT id FROM workflows WHERE tier_required = 'vip' ORDER BY random() LIMIT 1),
    (SELECT id FROM users WHERE tier = 'vip' ORDER BY random() LIMIT 1),
    CASE 
        WHEN generate_series(1, 500) % 20 < 19 THEN 'success'  -- 95% success
        ELSE 'error'                                            -- 5% error (no timeouts/failures for VIP)
    END,
    CASE 
        WHEN generate_series(1, 500) % 20 < 19 THEN (random() * 15000 + 100)::integer  -- Success: 0.1-15.1s
        ELSE (random() * 5000 + 1000)::integer                                          -- Error: 1-6s
    END,
    CASE 
        WHEN generate_series(1, 500) % 20 >= 19 THEN 
            'External service maintenance - retrying with backup endpoint'
        ELSE NULL
    END,
    CASE (generate_series(1, 500) % 3)
        WHEN 0 THEN 'api'
        WHEN 1 THEN 'schedule'
        ELSE 'manual'
    END,
    jsonb_build_object(
        'input_size_bytes', (random() * 100000 + 10000)::integer,
        'output_size_bytes', CASE WHEN generate_series(1, 500) % 20 < 19 THEN (random() * 500000 + 50000)::integer ELSE 0 END,
        'steps_completed', CASE WHEN generate_series(1, 500) % 20 < 19 THEN (random() * 25 + 15)::integer ELSE (random() * 8 + 5)::integer END,
        'api_calls_made', (random() * 100 + 20)::integer,
        'custom_features_used', ARRAY['enterprise_auth', 'custom_nodes', 'priority_queue']
    ),
    jsonb_build_object(
        'memory_mb', (random() * 1000 + 200)::integer,  -- VIP tier: 200-1200MB
        'cpu_time_ms', (random() * 20000 + 5000)::integer,
        'network_bytes', (random() * 1000000 + 100000)::integer,
        'priority_level', 'high'
    ),
    NOW() - (random() * INTERVAL '30 days'),
    NOW() - (random() * INTERVAL '30 days');

-- Create specific demo executions for business scenarios
INSERT INTO log_workflow_executions (
    workflow_id, user_id, execution_status, execution_time_ms, error_message,
    triggered_by, execution_data, resource_usage, created_at, updated_at
) VALUES
    -- Successful free execution
    ((SELECT id FROM workflows WHERE name = 'free_autoInbox_fb'),
     (SELECT id FROM users WHERE username = 'demo_free_01'),
     'success', 3200, NULL, 'webhook',
     jsonb_build_object('input_size_bytes', 450, 'output_size_bytes', 1200, 'steps_completed', 4, 'api_calls_made', 2),
     jsonb_build_object('memory_mb', 25, 'cpu_time_ms', 1800, 'network_bytes', 3500),
     NOW() - INTERVAL '1 hour', NOW() - INTERVAL '1 hour'),
    
    -- Failed free execution (rate limited)
    ((SELECT id FROM workflows WHERE name = 'free_autoInbox_fb'),
     (SELECT id FROM users WHERE username = 'demo_free_01'),
     'failed', 8500, 'Rate limit exceeded - free tier limit 10 calls/day reached', 'webhook',
     jsonb_build_object('input_size_bytes', 380, 'output_size_bytes', 0, 'steps_completed', 2, 'api_calls_made', 1),
     jsonb_build_object('memory_mb', 18, 'cpu_time_ms', 2100, 'network_bytes', 1200),
     NOW() - INTERVAL '30 minutes', NOW() - INTERVAL '30 minutes'),
    
    -- Successful pro execution
    ((SELECT id FROM workflows WHERE name = 'pro_emailMarketing_auto'),
     (SELECT id FROM users WHERE username = 'demo_pro_01'),
     'success', 5400, NULL, 'schedule',
     jsonb_build_object('input_size_bytes', 2500, 'output_size_bytes', 8500, 'steps_completed', 7, 'api_calls_made', 12),
     jsonb_build_object('memory_mb', 85, 'cpu_time_ms', 4200, 'network_bytes', 25000),
     NOW() - INTERVAL '2 hours', NOW() - INTERVAL '2 hours'),
    
    -- Successful premium execution
    ((SELECT id FROM workflows WHERE name = 'premium_dataSync_api'),
     (SELECT id FROM users WHERE username = 'demo_premium_01'),
     'success', 12800, NULL, 'api',
     jsonb_build_object('input_size_bytes', 15000, 'output_size_bytes', 45000, 'steps_completed', 12, 'api_calls_made', 25),
     jsonb_build_object('memory_mb', 180, 'cpu_time_ms', 8500, 'network_bytes', 120000),
     NOW() - INTERVAL '3 hours', NOW() - INTERVAL '3 hours'),
    
    -- Successful VIP execution
    ((SELECT id FROM workflows WHERE name = 'vip_enterprise_automation'),
     (SELECT id FROM users WHERE username = 'demo_vip_01'),
     'success', 25600, NULL, 'manual',
     jsonb_build_object('input_size_bytes', 80000, 'output_size_bytes', 250000, 'steps_completed', 18, 'api_calls_made', 45, 'custom_features_used', ARRAY['enterprise_auth', 'custom_nodes']),
     jsonb_build_object('memory_mb', 450, 'cpu_time_ms', 18000, 'network_bytes', 650000, 'priority_level', 'high'),
     NOW() - INTERVAL '4 hours', NOW() - INTERVAL '4 hours');

-- Verification queries
SELECT 
    w.tier_required,
    COUNT(*) as execution_count,
    ROUND(AVG(execution_time_ms), 2) as avg_execution_time_ms,
    SUM(CASE WHEN execution_status = 'success' THEN 1 ELSE 0 END) as successful_executions,
    ROUND((SUM(CASE WHEN execution_status = 'success' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) as success_rate_percent
FROM log_workflow_executions e
JOIN workflows w ON e.workflow_id = w.id
GROUP BY w.tier_required
ORDER BY 
    CASE w.tier_required 
        WHEN 'free' THEN 1 
        WHEN 'pro' THEN 2 
        WHEN 'premium' THEN 3 
        WHEN 'vip' THEN 4 
    END;

-- Total execution count
SELECT COUNT(*) as total_executions FROM log_workflow_executions;

-- Execution status distribution
SELECT execution_status, COUNT(*) as count
FROM log_workflow_executions
GROUP BY execution_status
ORDER BY count DESC;

-- Resource usage by tier
SELECT 
    w.tier_required,
    ROUND(AVG((resource_usage->>'memory_mb')::integer), 2) as avg_memory_mb,
    ROUND(AVG((resource_usage->>'cpu_time_ms')::integer), 2) as avg_cpu_time_ms
FROM log_workflow_executions e
JOIN workflows w ON e.workflow_id = w.id
WHERE resource_usage IS NOT NULL
GROUP BY w.tier_required;

-- Success message
SELECT 'Log workflow executions seeding completed successfully! 10,000+ executions created with realistic performance metrics.' as status; 