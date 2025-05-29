-- Mock Data Seeding: Orders Table  
-- Description: Create 500 orders with mix of subscriptions, one-time purchases, VIP custom
-- Distribution: 200 pro orders, 200 premium orders, 100 VIP orders

SET search_path TO n8n;

-- Clear existing data
TRUNCATE TABLE orders RESTART IDENTITY CASCADE;

-- Generate Pro Subscription Orders (150 orders)
INSERT INTO orders (
    user_id, workflow_id, order_type, amount, currency, is_active,
    purchase_date, expiry_date, transaction_id, payment_method, notes, created_at, updated_at
)
SELECT 
    (SELECT id FROM users WHERE tier = 'pro' ORDER BY random() LIMIT 1),
    (SELECT id FROM workflows WHERE tier_required = 'pro' ORDER BY random() LIMIT 1),
    'monthly_subscription',
    ROUND((random() * 30 + 20)::numeric, 2), -- $20-50
    'USD',
    CASE WHEN generate_series(1, 150) % 10 = 0 THEN false ELSE true END, -- 10% inactive
    NOW() - (random() * INTERVAL '120 days'),
    NOW() + (random() * INTERVAL '30 days'), -- Active subscriptions
    'stripe_' || generate_series(1, 150) || '_' || extract(epoch from now())::bigint,
    CASE (generate_series(1, 150) % 3)
        WHEN 0 THEN 'stripe'
        WHEN 1 THEN 'paypal' 
        ELSE 'credit_card'
    END,
    'Monthly subscription for pro workflow access',
    NOW() - (random() * INTERVAL '120 days'),
    NOW() - (random() * INTERVAL '7 days');

-- Generate Pro One-time Orders (50 orders)
INSERT INTO orders (
    user_id, workflow_id, order_type, amount, currency, is_active,
    purchase_date, expiry_date, transaction_id, payment_method, notes, created_at, updated_at
)
SELECT 
    (SELECT id FROM users WHERE tier IN ('pro', 'premium') ORDER BY random() LIMIT 1),
    (SELECT id FROM workflows WHERE tier_required = 'pro' ORDER BY random() LIMIT 1),
    'one_time_purchase',
    ROUND((random() * 40 + 10)::numeric, 2), -- $10-50
    'USD',
    true, -- All one-time purchases active
    NOW() - (random() * INTERVAL '180 days'),
    NOW() + INTERVAL '365 days', -- 1 year access
    'stripe_onetime_' || g.i || '_' || extract(epoch from now())::bigint,
    CASE (g.i % 4)
        WHEN 0 THEN 'stripe'
        WHEN 1 THEN 'paypal'
        WHEN 2 THEN 'credit_card'
        ELSE 'bank_transfer'
    END,
    'One-time purchase for lifetime access',
    NOW() - (random() * INTERVAL '180 days'),
    NOW() - (random() * INTERVAL '10 days')
FROM generate_series(1, 50) AS g(i);

-- Generate Premium Subscription Orders (120 orders)
INSERT INTO orders (
    user_id, workflow_id, order_type, amount, currency, is_active,
    purchase_date, expiry_date, transaction_id, payment_method, notes, created_at, updated_at
)
SELECT 
    (SELECT id FROM users WHERE tier IN ('premium', 'vip') ORDER BY random() LIMIT 1),
    (SELECT id FROM workflows WHERE tier_required = 'premium' ORDER BY random() LIMIT 1),
    'monthly_subscription',
    ROUND((random() * 60 + 70)::numeric, 2), -- $70-130
    'USD',
    CASE WHEN g.i % 15 = 0 THEN false ELSE true END, -- 7% inactive
    NOW() - (random() * INTERVAL '90 days'),
    NOW() + (random() * INTERVAL '60 days'), -- Active subscriptions
    'stripe_premium_' || g.i || '_' || extract(epoch from now())::bigint,
    CASE (g.i % 3)
        WHEN 0 THEN 'stripe'
        WHEN 1 THEN 'paypal'
        ELSE 'enterprise_billing'
    END,
    'Premium monthly subscription with advanced features',
    NOW() - (random() * INTERVAL '90 days'),
    NOW() - (random() * INTERVAL '3 days')
FROM generate_series(1, 120) AS g(i);

-- Generate Premium One-time Orders (80 orders)
INSERT INTO orders (
    user_id, workflow_id, order_type, amount, currency, is_active,
    purchase_date, expiry_date, transaction_id, payment_method, notes, created_at, updated_at
)
SELECT 
    (SELECT id FROM users WHERE tier IN ('premium', 'vip') ORDER BY random() LIMIT 1),
    (SELECT id FROM workflows WHERE tier_required = 'premium' ORDER BY random() LIMIT 1),
    'one_time_purchase',
    ROUND((random() * 80 + 50)::numeric, 2), -- $50-130
    'USD',
    true,
    NOW() - (random() * INTERVAL '150 days'),
    NOW() + INTERVAL '365 days',
    'stripe_premium_onetime_' || g.i || '_' || extract(epoch from now())::bigint,
    CASE (g.i % 4)
        WHEN 0 THEN 'stripe'
        WHEN 1 THEN 'paypal'
        WHEN 2 THEN 'enterprise_billing'
        ELSE 'wire_transfer'
    END,
    'Premium one-time purchase with enterprise support',
    NOW() - (random() * INTERVAL '150 days'),
    NOW() - (random() * INTERVAL '5 days')
FROM generate_series(1, 80) AS g(i);

-- Generate VIP Custom Development Orders (70 orders)
INSERT INTO orders (
    user_id, workflow_id, order_type, amount, currency, is_active,
    purchase_date, expiry_date, transaction_id, payment_method, notes, created_at, updated_at
)
SELECT 
    (SELECT id FROM users WHERE tier = 'vip' ORDER BY random() LIMIT 1),
    (SELECT id FROM workflows WHERE tier_required = 'vip' ORDER BY random() LIMIT 1),
    'custom_development',
    ROUND((random() * 300 + 200)::numeric, 2), -- $200-500
    'USD',
    true,
    NOW() - (random() * INTERVAL '90 days'),
    NOW() + INTERVAL '730 days', -- 2 years access
    'vip_custom_' || g.i || '_' || extract(epoch from now())::bigint,
    CASE (g.i % 3)
        WHEN 0 THEN 'wire_transfer'
        WHEN 1 THEN 'enterprise_billing'
        ELSE 'crypto'
    END,
    'VIP custom workflow development with dedicated support',
    NOW() - (random() * INTERVAL '90 days'),
    NOW() - (random() * INTERVAL '1 day')
FROM generate_series(1, 70) AS g(i);

-- Generate VIP Subscription Orders (30 orders)
INSERT INTO orders (
    user_id, workflow_id, order_type, amount, currency, is_active,
    purchase_date, expiry_date, transaction_id, payment_method, notes, created_at, updated_at
)
SELECT 
    (SELECT id FROM users WHERE tier = 'vip' ORDER BY random() LIMIT 1),
    (SELECT id FROM workflows WHERE tier_required = 'vip' ORDER BY random() LIMIT 1),
    'annual_subscription',
    ROUND((random() * 1000 + 2000)::numeric, 2), -- $2000-3000 annual
    'USD',
    true,
    NOW() - (random() * INTERVAL '60 days'),
    NOW() + INTERVAL '365 days',
    'vip_annual_' || g.i || '_' || extract(epoch from now())::bigint,
    CASE (g.i % 2)
        WHEN 0 THEN 'enterprise_billing'
        ELSE 'wire_transfer'
    END,
    'VIP annual subscription with unlimited access',
    NOW() - (random() * INTERVAL '60 days'),
    NOW() - (random() * INTERVAL '1 day')
FROM generate_series(1, 30) AS g(i);

-- Create specific demo orders for business scenarios
INSERT INTO orders (
    user_id, workflow_id, order_type, amount, currency, is_active,
    purchase_date, expiry_date, transaction_id, payment_method, notes, created_at, updated_at
) VALUES
    -- Pro demo orders
    ((SELECT id FROM users WHERE username = 'demo_pro_02'), 
     (SELECT id FROM workflows WHERE name = 'pro_emailMarketing_auto'),
     'monthly_subscription', 29.99, 'USD', true,
     NOW() - INTERVAL '30 days', NOW() + INTERVAL '30 days',
     'stripe_demo_pro_02_monthly', 'stripe',
     'Demo pro monthly subscription', NOW() - INTERVAL '30 days', NOW()),
     
    -- Premium demo orders
    ((SELECT id FROM users WHERE username = 'demo_premium_02'),
     (SELECT id FROM workflows WHERE name = 'premium_crm_integration'),
     'one_time_purchase', 129.99, 'USD', true,
     NOW() - INTERVAL '45 days', NOW() + INTERVAL '365 days',
     'stripe_demo_premium_02_onetime', 'stripe',
     'Demo premium one-time purchase', NOW() - INTERVAL '45 days', NOW()),
     
    -- VIP demo orders
    ((SELECT id FROM users WHERE username = 'demo_vip_02'),
     (SELECT id FROM workflows WHERE name = 'vip_enterprise_automation'),
     'custom_development', 299.99, 'USD', true,
     NOW() - INTERVAL '60 days', NOW() + INTERVAL '730 days',
     'vip_demo_custom_dev', 'enterprise_billing',
     'VIP custom development demo order', NOW() - INTERVAL '60 days', NOW()),
     
    -- Failed payment demo order (for scenario 8)
    ((SELECT id FROM users WHERE username = 'demo_pro_03'),
     (SELECT id FROM workflows WHERE name = 'pro_leadGeneration_fb'),
     'monthly_subscription', 39.99, 'USD', false,
     NOW() - INTERVAL '90 days', NOW() - INTERVAL '10 days',
     'stripe_demo_failed_payment', 'stripe',
     'Failed payment - account suspended, 7 days grace period', NOW() - INTERVAL '90 days', NOW() - INTERVAL '10 days');

-- Generate some expired/cancelled orders for realism
INSERT INTO orders (
    user_id, workflow_id, order_type, amount, currency, is_active,
    purchase_date, expiry_date, transaction_id, payment_method, notes, created_at, updated_at
)
SELECT 
    (SELECT id FROM users WHERE tier IN ('pro', 'premium') ORDER BY random() LIMIT 1),
    (SELECT id FROM workflows WHERE tier_required IN ('pro', 'premium') ORDER BY random() LIMIT 1),
    'monthly_subscription',
    ROUND((random() * 50 + 20)::numeric, 2),
    'USD',
    false, -- Cancelled/expired
    NOW() - (random() * INTERVAL '365 days'),
    NOW() - (random() * INTERVAL '60 days'), -- Expired
    'cancelled_' || g.i || '_' || extract(epoch from now())::bigint,
    CASE (g.i % 3)
        WHEN 0 THEN 'stripe'
        WHEN 1 THEN 'paypal'
        ELSE 'credit_card'
    END,
    'Cancelled subscription - ' || 
    CASE (g.i % 3)
        WHEN 0 THEN 'payment failed'
        WHEN 1 THEN 'user requested cancellation'
        ELSE 'expired without renewal'
    END,
    NOW() - (random() * INTERVAL '365 days'),
    NOW() - (random() * INTERVAL '30 days')
FROM generate_series(1, 30) AS g(i);

-- Verification queries
SELECT 
    order_type,
    COUNT(*) as order_count,
    ROUND(AVG(amount), 2) as avg_amount,
    SUM(CASE WHEN is_active THEN 1 ELSE 0 END) as active_orders
FROM orders 
GROUP BY order_type 
ORDER BY order_count DESC;

-- Total order count and revenue
SELECT 
    COUNT(*) as total_orders,
    ROUND(SUM(amount), 2) as total_revenue,
    ROUND(SUM(CASE WHEN is_active THEN amount ELSE 0 END), 2) as active_revenue
FROM orders;

-- Payment method distribution
SELECT payment_method, COUNT(*) as order_count
FROM orders 
GROUP BY payment_method 
ORDER BY order_count DESC;

-- Orders by user tier
SELECT 
    u.tier,
    COUNT(o.*) as order_count,
    ROUND(AVG(o.amount), 2) as avg_amount
FROM orders o
JOIN users u ON o.user_id = u.id
GROUP BY u.tier
ORDER BY order_count DESC;

-- Success message
SELECT 'Orders seeding completed successfully! 500+ orders created with realistic payment scenarios.' as status; 