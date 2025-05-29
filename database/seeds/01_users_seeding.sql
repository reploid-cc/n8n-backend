-- Mock Data Seeding: Users Table
-- Description: Create 1000 users across 4 tiers with realistic distribution
-- Distribution: 600 free (60%), 250 pro (25%), 120 premium (12%), 30 vip (3%)

SET search_path TO n8n;

-- Clear existing data
TRUNCATE TABLE users RESTART IDENTITY CASCADE;

-- Generate Free Users (600 users - 60%)
INSERT INTO users (
    email, username, password_hash, first_name, last_name, 
    avatar_url, is_active, is_verified, tier, created_at, updated_at, last_login_at
) 
SELECT 
    'free_user_' || generate_series(1, 600) || '@example.com',
    'free_user_' || generate_series(1, 600),
    '$2b$10$hash_free_user_' || generate_series(1, 600),
    'Free',
    'User ' || generate_series(1, 600),
    'https://avatar.example.com/free/' || generate_series(1, 600) || '.jpg',
    CASE WHEN generate_series(1, 600) % 20 = 0 THEN false ELSE true END, -- 5% inactive
    CASE WHEN generate_series(1, 600) % 10 = 0 THEN false ELSE true END, -- 10% unverified
    'free',
    NOW() - (random() * INTERVAL '180 days'), -- Created within last 6 months
    NOW() - (random() * INTERVAL '30 days'),  -- Updated within last month
    CASE 
        WHEN generate_series(1, 600) % 5 = 0 THEN NULL -- 20% never logged in
        ELSE NOW() - (random() * INTERVAL '7 days')    -- Logged in last week
    END;

-- Generate Pro Users (250 users - 25%)
INSERT INTO users (
    email, username, password_hash, first_name, last_name, 
    avatar_url, is_active, is_verified, tier, created_at, updated_at, last_login_at
)
SELECT 
    'pro_user_' || generate_series(1, 250) || '@business.com',
    'pro_user_' || generate_series(1, 250),
    '$2b$10$hash_pro_user_' || generate_series(1, 250),
    'Pro',
    'User ' || generate_series(1, 250),
    'https://avatar.example.com/pro/' || generate_series(1, 250) || '.jpg',
    CASE WHEN generate_series(1, 250) % 50 = 0 THEN false ELSE true END, -- 2% inactive
    true, -- All pro users verified
    'pro',
    NOW() - (random() * INTERVAL '120 days'), -- Created within last 4 months
    NOW() - (random() * INTERVAL '7 days'),   -- Updated within last week
    NOW() - (random() * INTERVAL '3 days');   -- Logged in last 3 days

-- Generate Premium Users (120 users - 12%)
INSERT INTO users (
    email, username, password_hash, first_name, last_name, 
    avatar_url, is_active, is_verified, tier, created_at, updated_at, last_login_at
)
SELECT 
    'premium_user_' || generate_series(1, 120) || '@enterprise.com',
    'premium_user_' || generate_series(1, 120),
    '$2b$10$hash_premium_user_' || generate_series(1, 120),
    'Premium',
    'User ' || generate_series(1, 120),
    'https://avatar.example.com/premium/' || generate_series(1, 120) || '.jpg',
    true, -- All premium users active
    true, -- All premium users verified
    'premium',
    NOW() - (random() * INTERVAL '90 days'),  -- Created within last 3 months
    NOW() - (random() * INTERVAL '3 days'),   -- Updated within last 3 days
    NOW() - (random() * INTERVAL '1 day');    -- Logged in last day

-- Generate VIP Users (30 users - 3%)
INSERT INTO users (
    email, username, password_hash, first_name, last_name, 
    avatar_url, is_active, is_verified, tier, created_at, updated_at, last_login_at
)
SELECT 
    'vip_user_' || generate_series(1, 30) || '@vip.com',
    'vip_user_' || generate_series(1, 30),
    '$2b$10$hash_vip_user_' || generate_series(1, 30),
    'VIP',
    'User ' || generate_series(1, 30),
    'https://avatar.example.com/vip/' || generate_series(1, 30) || '.jpg',
    true, -- All VIP users active
    true, -- All VIP users verified
    'vip',
    NOW() - (random() * INTERVAL '60 days'),  -- Created within last 2 months
    NOW() - (random() * INTERVAL '1 day'),    -- Updated within last day
    NOW() - (random() * INTERVAL '12 hours'); -- Logged in last 12 hours

-- Create specific demo users for business scenarios
INSERT INTO users (
    email, username, password_hash, first_name, last_name, 
    avatar_url, is_active, is_verified, tier, created_at, updated_at, last_login_at
) VALUES
    -- Free tier demo users
    ('demo_free_01@example.com', 'demo_free_01', '$2b$10$demo_hash_free_01', 'Demo', 'Free User 01', 
     'https://avatar.example.com/demo/free_01.jpg', true, true, 'free', NOW() - INTERVAL '30 days', NOW(), NOW() - INTERVAL '1 hour'),
    
    -- Pro tier demo users
    ('demo_pro_01@business.com', 'demo_pro_01', '$2b$10$demo_hash_pro_01', 'Demo', 'Pro User 01', 
     'https://avatar.example.com/demo/pro_01.jpg', true, true, 'pro', NOW() - INTERVAL '60 days', NOW(), NOW() - INTERVAL '30 minutes'),
    ('demo_pro_02@business.com', 'demo_pro_02', '$2b$10$demo_hash_pro_02', 'Demo', 'Pro User 02', 
     'https://avatar.example.com/demo/pro_02.jpg', true, true, 'pro', NOW() - INTERVAL '45 days', NOW(), NOW() - INTERVAL '2 hours'),
    ('demo_pro_03@business.com', 'demo_pro_03', '$2b$10$demo_hash_pro_03', 'Demo', 'Pro User 03', 
     'https://avatar.example.com/demo/pro_03.jpg', false, true, 'pro', NOW() - INTERVAL '90 days', NOW() - INTERVAL '10 days', NOW() - INTERVAL '15 days'),
    
    -- Premium tier demo users  
    ('demo_premium_01@enterprise.com', 'demo_premium_01', '$2b$10$demo_hash_premium_01', 'Demo', 'Premium User 01', 
     'https://avatar.example.com/demo/premium_01.jpg', true, true, 'premium', NOW() - INTERVAL '45 days', NOW(), NOW() - INTERVAL '15 minutes'),
    ('demo_premium_02@enterprise.com', 'demo_premium_02', '$2b$10$demo_hash_premium_02', 'Demo', 'Premium User 02', 
     'https://avatar.example.com/demo/premium_02.jpg', true, true, 'premium', NOW() - INTERVAL '30 days', NOW(), NOW() - INTERVAL '45 minutes'),
    
    -- VIP tier demo users
    ('demo_vip_01@vip.com', 'demo_vip_01', '$2b$10$demo_hash_vip_01', 'Demo', 'VIP User 01', 
     'https://avatar.example.com/demo/vip_01.jpg', true, true, 'vip', NOW() - INTERVAL '30 days', NOW(), NOW() - INTERVAL '10 minutes'),
    ('demo_vip_02@vip.com', 'demo_vip_02', '$2b$10$demo_hash_vip_02', 'Demo', 'VIP User 02', 
     'https://avatar.example.com/demo/vip_02.jpg', true, true, 'vip', NOW() - INTERVAL '60 days', NOW(), NOW() - INTERVAL '5 minutes');

-- Verification query
SELECT 
    tier,
    COUNT(*) as user_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
FROM users 
GROUP BY tier 
ORDER BY 
    CASE tier 
        WHEN 'free' THEN 1 
        WHEN 'pro' THEN 2 
        WHEN 'premium' THEN 3 
        WHEN 'vip' THEN 4 
    END;

-- Total user count
SELECT COUNT(*) as total_users FROM users;

-- Active/Inactive breakdown
SELECT 
    tier,
    SUM(CASE WHEN is_active THEN 1 ELSE 0 END) as active_users,
    SUM(CASE WHEN NOT is_active THEN 1 ELSE 0 END) as inactive_users
FROM users 
GROUP BY tier;

-- Success message
SELECT 'Users seeding completed successfully! 1000+ users created across 4 tiers.' as status; 