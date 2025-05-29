-- Mock Data Seeding: Community Features (Comments, Ratings, Favorites)
-- Description: Create realistic community engagement data
-- Tables: comments, ratings, user_workflow_favorites

SET search_path TO n8n;

-- Clear existing data
TRUNCATE TABLE comments RESTART IDENTITY CASCADE;
TRUNCATE TABLE ratings RESTART IDENTITY CASCADE;
TRUNCATE TABLE user_workflow_favorites RESTART IDENTITY CASCADE;

-- ==========================================
-- COMMENTS SEEDING (2000+ comments)
-- ==========================================

-- Generate comments for Free workflows (1000 comments)
INSERT INTO comments (
    user_id, target_type, target_id, parent_comment_id, content, is_edited,
    is_deleted, created_at, updated_at
)
SELECT 
    (SELECT id FROM users ORDER BY random() LIMIT 1),
    'workflow',
    (SELECT id FROM workflows WHERE tier_required = 'free' ORDER BY random() LIMIT 1),
    NULL, -- Root comments
    CASE (gs.n % 10)
        WHEN 0 THEN 'Great workflow! Very helpful for beginners.'
        WHEN 1 THEN 'Simple but effective automation.'
        WHEN 2 THEN 'Works perfectly for my basic needs.'
        WHEN 3 THEN 'Easy to understand and implement.'
        WHEN 4 THEN 'Thanks for sharing this workflow!'
        WHEN 5 THEN 'Exactly what I was looking for.'
        WHEN 6 THEN 'Could you add more customization options?'
        WHEN 7 THEN 'Free version works well for testing.'
        WHEN 8 THEN 'Good starting point for automation.'
        ELSE 'Recommended for free tier users.'
    END,
    CASE WHEN gs.n % 15 = 0 THEN true ELSE false END, -- 6.7% edited
    CASE WHEN gs.n % 50 = 0 THEN true ELSE false END, -- 2% deleted
    NOW() - (random() * INTERVAL '30 days'),
    NOW() - (random() * INTERVAL '15 days')
FROM generate_series(1, 1000) gs(n);

-- Generate reply comments for Free workflows (300 replies)
INSERT INTO comments (
    user_id, target_type, target_id, parent_comment_id, content, is_edited,
    is_deleted, created_at, updated_at
)
SELECT 
    (SELECT id FROM users ORDER BY random() LIMIT 1),
    'workflow',
    c.target_id,
    c.id, -- Parent comment
    CASE (gs.n % 8)
        WHEN 0 THEN 'Thanks for the feedback!'
        WHEN 1 THEN 'Glad it helped you.'
        WHEN 2 THEN 'Will consider adding more features.'
        WHEN 3 THEN 'You can modify it for your needs.'
        WHEN 4 THEN 'Check the documentation for more options.'
        WHEN 5 THEN 'Feel free to fork and customize.'
        WHEN 6 THEN 'Updated the workflow based on your suggestion.'
        ELSE 'Thanks for using it!'
    END,
    false, -- Replies rarely edited
    false, -- Replies rarely deleted
    c.created_at + (random() * INTERVAL '5 days'),
    c.created_at + (random() * INTERVAL '10 days')
FROM generate_series(1, 300) gs(n)
CROSS JOIN (
    SELECT id, target_id, created_at 
    FROM comments 
    WHERE parent_comment_id IS NULL 
    ORDER BY random() 
    LIMIT 300
) c;

-- Generate comments for Pro workflows (600 comments)
INSERT INTO comments (
    user_id, target_type, target_id, parent_comment_id, content, is_edited,
    is_deleted, created_at, updated_at
)
SELECT 
    (SELECT id FROM users WHERE tier IN ('pro', 'premium', 'vip') ORDER BY random() LIMIT 1),
    'workflow',
    (SELECT id FROM workflows WHERE tier_required = 'pro' ORDER BY random() LIMIT 1),
    NULL,
    CASE (gs.n % 12)
        WHEN 0 THEN 'Excellent pro workflow! Well worth the investment.'
        WHEN 1 THEN 'Professional quality automation solution.'
        WHEN 2 THEN 'Saves me hours of manual work daily.'
        WHEN 3 THEN 'Great integration with our CRM system.'
        WHEN 4 THEN 'Perfect for business use cases.'
        WHEN 5 THEN 'Documentation could be more detailed.'
        WHEN 6 THEN 'Works flawlessly with our enterprise setup.'
        WHEN 7 THEN 'ROI justified within the first week.'
        WHEN 8 THEN 'Support team was very helpful.'
        WHEN 9 THEN 'Would recommend to other businesses.'
        WHEN 10 THEN 'Customization options are comprehensive.'
        ELSE 'Professional grade workflow delivery.'
    END,
    CASE WHEN gs.n % 20 = 0 THEN true ELSE false END, -- 5% edited
    CASE WHEN gs.n % 100 = 0 THEN true ELSE false END, -- 1% deleted
    NOW() - (random() * INTERVAL '60 days'),
    NOW() - (random() * INTERVAL '10 days')
FROM generate_series(1, 600) gs(n);

-- Generate comments for Premium workflows (400 comments)
INSERT INTO comments (
    user_id, target_type, target_id, parent_comment_id, content, is_edited,
    is_deleted, created_at, updated_at
)
SELECT 
    (SELECT id FROM users WHERE tier IN ('premium', 'vip') ORDER BY random() LIMIT 1),
    'workflow',
    (SELECT id FROM workflows WHERE tier_required = 'premium' ORDER BY random() LIMIT 1),
    NULL,
    CASE (gs.n % 10)
        WHEN 0 THEN 'Enterprise-grade solution. Highly recommended.'
        WHEN 1 THEN 'Complex workflows handled with ease.'
        WHEN 2 THEN 'Advanced features justify the premium price.'
        WHEN 3 THEN 'Seamless integration across multiple systems.'
        WHEN 4 THEN 'Performance optimization is outstanding.'
        WHEN 5 THEN 'Analytics and reporting features are powerful.'
        WHEN 6 THEN 'Scalability meets our enterprise requirements.'
        WHEN 7 THEN 'Priority support exceeded expectations.'
        WHEN 8 THEN 'Custom configurations work perfectly.'
        ELSE 'Premium tier benefits are clearly visible.'
    END,
    CASE WHEN gs.n % 25 = 0 THEN true ELSE false END, -- 4% edited
    false, -- Premium users rarely delete comments
    NOW() - (random() * INTERVAL '45 days'),
    NOW() - (random() * INTERVAL '5 days')
FROM generate_series(1, 400) gs(n);

-- Generate comments for VIP workflows (200 comments)
INSERT INTO comments (
    user_id, target_type, target_id, parent_comment_id, content, is_edited,
    is_deleted, created_at, updated_at
)
SELECT 
    (SELECT id FROM users WHERE tier = 'vip' ORDER BY random() LIMIT 1),
    'workflow',
    (SELECT id FROM workflows WHERE tier_required = 'vip' ORDER BY random() LIMIT 1),
    NULL,
    CASE (gs.n % 8)
        WHEN 0 THEN 'Exclusive VIP workflow exceeded all expectations.'
        WHEN 1 THEN 'Custom development delivered exactly what we needed.'
        WHEN 2 THEN 'White-label solution integrated perfectly.'
        WHEN 3 THEN 'Dedicated support team is exceptional.'
        WHEN 4 THEN 'Bespoke features align with our unique requirements.'
        WHEN 5 THEN 'Enterprise architecture scales beautifully.'
        WHEN 6 THEN 'Custom API integrations work flawlessly.'
        ELSE 'VIP tier provides unmatched value and service.'
    END,
    CASE WHEN gs.n % 30 = 0 THEN true ELSE false END, -- 3.3% edited
    false, -- VIP users never delete comments
    NOW() - (random() * INTERVAL '30 days'),
    NOW() - (random() * INTERVAL '2 days')
FROM generate_series(1, 200) gs(n);

-- ==========================================
-- RATINGS SEEDING (1500+ ratings)
-- ==========================================

-- Generate ratings for Free workflows (800 ratings)
INSERT INTO ratings (
    user_id, workflow_id, rating, review, created_at, updated_at
)
SELECT 
    (SELECT id FROM users ORDER BY random() LIMIT 1),
    (SELECT id FROM workflows WHERE tier_required = 'free' ORDER BY random() LIMIT 1),
    CASE 
        WHEN random() < 0.1 THEN 2 -- 10% low ratings
        WHEN random() < 0.3 THEN 3 -- 20% average ratings
        WHEN random() < 0.7 THEN 4 -- 40% good ratings
        ELSE 5 -- 30% excellent ratings
    END,
    CASE (gs.n % 8)
        WHEN 0 THEN 'Good basic functionality for free tier.'
        WHEN 1 THEN 'Simple to use and understand.'
        WHEN 2 THEN 'Works as advertised.'
        WHEN 3 THEN 'Great for getting started with automation.'
        WHEN 4 THEN 'Free version has some limitations but useful.'
        WHEN 5 THEN 'Perfect for small-scale automation needs.'
        WHEN 6 THEN 'Would recommend upgrading to pro for more features.'
        ELSE 'Solid foundation for automation beginners.'
    END,
    NOW() - (random() * INTERVAL '45 days'),
    NOW() - (random() * INTERVAL '30 days')
FROM generate_series(1, 800) gs(n);

-- Generate ratings for Pro workflows (500 ratings)
INSERT INTO ratings (
    user_id, workflow_id, rating, review, created_at, updated_at
)
SELECT 
    (SELECT id FROM users WHERE tier IN ('pro', 'premium', 'vip') ORDER BY random() LIMIT 1),
    (SELECT id FROM workflows WHERE tier_required = 'pro' ORDER BY random() LIMIT 1),
    CASE 
        WHEN random() < 0.05 THEN 3 -- 5% average ratings
        WHEN random() < 0.25 THEN 4 -- 20% good ratings
        ELSE 5 -- 75% excellent ratings
    END,
    CASE (gs.n % 10)
        WHEN 0 THEN 'Professional quality workflow with excellent ROI.'
        WHEN 1 THEN 'Advanced features justify the pro pricing.'
        WHEN 2 THEN 'Reliable and efficient automation solution.'
        WHEN 3 THEN 'Great integration capabilities.'
        WHEN 4 THEN 'Support team is responsive and helpful.'
        WHEN 5 THEN 'Saves significant time on business processes.'
        WHEN 6 THEN 'Customization options meet our needs perfectly.'
        WHEN 7 THEN 'Performance optimization is noticeable.'
        WHEN 8 THEN 'Worth every penny for business automation.'
        ELSE 'Highly recommend for professional use.'
    END,
    NOW() - (random() * INTERVAL '60 days'),
    NOW() - (random() * INTERVAL '15 days')
FROM generate_series(1, 500) gs(n);

-- Generate ratings for Premium workflows (300 ratings)
INSERT INTO ratings (
    user_id, workflow_id, rating, review, created_at, updated_at
)
SELECT 
    (SELECT id FROM users WHERE tier IN ('premium', 'vip') ORDER BY random() LIMIT 1),
    (SELECT id FROM workflows WHERE tier_required = 'premium' ORDER BY random() LIMIT 1),
    CASE 
        WHEN random() < 0.1 THEN 4 -- 10% good ratings
        ELSE 5 -- 90% excellent ratings
    END,
    CASE (gs.n % 8)
        WHEN 0 THEN 'Enterprise-grade solution with exceptional performance.'
        WHEN 1 THEN 'Advanced analytics and reporting are outstanding.'
        WHEN 2 THEN 'Seamless multi-system integration capabilities.'
        WHEN 3 THEN 'Premium support exceeded our expectations.'
        WHEN 4 THEN 'Scalability handles our enterprise workload perfectly.'
        WHEN 5 THEN 'Custom configurations provide exactly what we need.'
        WHEN 6 THEN 'ROI achieved within the first month of implementation.'
        ELSE 'Premium tier delivers unmatched value for enterprises.'
    END,
    NOW() - (random() * INTERVAL '30 days'),
    NOW() - (random() * INTERVAL '10 days')
FROM generate_series(1, 300) gs(n);

-- Generate ratings for VIP workflows (150 ratings)
INSERT INTO ratings (
    user_id, workflow_id, rating, review, created_at, updated_at
)
SELECT 
    (SELECT id FROM users WHERE tier = 'vip' ORDER BY random() LIMIT 1),
    (SELECT id FROM workflows WHERE tier_required = 'vip' ORDER BY random() LIMIT 1),
    5, -- VIP workflows always get 5 stars
    CASE (gs.n % 6)
        WHEN 0 THEN 'Bespoke solution tailored perfectly to our requirements.'
        WHEN 1 THEN 'White-label implementation exceeded all expectations.'
        WHEN 2 THEN 'Dedicated support team provides unparalleled service.'
        WHEN 3 THEN 'Custom development delivered exactly what we envisioned.'
        WHEN 4 THEN 'Enterprise architecture scales beyond our current needs.'
        ELSE 'VIP tier provides unmatched customization and support.'
    END,
    NOW() - (random() * INTERVAL '15 days'),
    NOW() - (random() * INTERVAL '5 days')
FROM generate_series(1, 150) gs(n);

-- ==========================================
-- USER WORKFLOW FAVORITES (800+ favorites)
-- ==========================================

-- Generate favorites with proper uniqueness
INSERT INTO user_workflow_favorites (user_id, workflow_id, created_at)
SELECT DISTINCT
    u.id as user_id,
    w.id as workflow_id,
    NOW() - (random() * INTERVAL '60 days')
FROM (
    SELECT id, ROW_NUMBER() OVER (ORDER BY random()) as rn 
    FROM users 
    ORDER BY random() 
    LIMIT 400
) u
CROSS JOIN (
    SELECT id, ROW_NUMBER() OVER (ORDER BY random()) as rn 
    FROM workflows 
    ORDER BY random() 
    LIMIT 2
) w
WHERE (u.rn + w.rn) % 3 = 0; -- Create some randomness while avoiding duplicates

-- Generate specific favorites for demo scenarios
INSERT INTO user_workflow_favorites (user_id, workflow_id, created_at)
SELECT DISTINCT
    (SELECT id FROM users WHERE username = 'demo_free_01'),
    (SELECT id FROM workflows WHERE name LIKE '%Free%' ORDER BY random() LIMIT 1),
    NOW() - INTERVAL '10 days'
WHERE NOT EXISTS (
    SELECT 1 FROM user_workflow_favorites 
    WHERE user_id = (SELECT id FROM users WHERE username = 'demo_free_01')
    AND workflow_id = (SELECT id FROM workflows WHERE name LIKE '%Free%' ORDER BY random() LIMIT 1)
);

INSERT INTO user_workflow_favorites (user_id, workflow_id, created_at)
SELECT DISTINCT
    (SELECT id FROM users WHERE username = 'demo_pro_01'),
    (SELECT id FROM workflows WHERE name LIKE '%Pro%' ORDER BY random() LIMIT 1),
    NOW() - INTERVAL '5 days'
WHERE NOT EXISTS (
    SELECT 1 FROM user_workflow_favorites 
    WHERE user_id = (SELECT id FROM users WHERE username = 'demo_pro_01')
    AND workflow_id = (SELECT id FROM workflows WHERE name LIKE '%Pro%' ORDER BY random() LIMIT 1)
);

INSERT INTO user_workflow_favorites (user_id, workflow_id, created_at)
SELECT DISTINCT
    (SELECT id FROM users WHERE username = 'demo_premium_01'),
    (SELECT id FROM workflows WHERE name LIKE '%Premium%' ORDER BY random() LIMIT 1),
    NOW() - INTERVAL '3 days'
WHERE NOT EXISTS (
    SELECT 1 FROM user_workflow_favorites 
    WHERE user_id = (SELECT id FROM users WHERE username = 'demo_premium_01')
    AND workflow_id = (SELECT id FROM workflows WHERE name LIKE '%Premium%' ORDER BY random() LIMIT 1)
);

-- Verification queries
-- Rating distribution
SELECT 
    rating,
    COUNT(*) as rating_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) as percentage
FROM ratings
GROUP BY rating
ORDER BY rating;

-- Favorites by tier
SELECT 
    w.tier_required as tier,
    COUNT(f.id) as favorites_count
FROM user_workflow_favorites f
JOIN workflows w ON f.workflow_id = w.id
GROUP BY w.tier_required
ORDER BY favorites_count DESC;

-- Community metrics summary
SELECT 
    'comments' as metric,
    COUNT(*) as total
FROM comments
UNION ALL
SELECT 
    'ratings' as metric,
    COUNT(*) as total
FROM ratings
UNION ALL
SELECT 
    'favorites' as metric,
    COUNT(*) as total
FROM user_workflow_favorites;

-- Average ratings by tier
SELECT 
    w.tier_required,
    ROUND(AVG(r.rating), 2) as avg_rating,
    COUNT(r.id) as total_ratings
FROM ratings r
JOIN workflows w ON r.workflow_id = w.id
GROUP BY w.tier_required
ORDER BY avg_rating DESC;

-- Success message
SELECT 'Community features seeding completed successfully! 2000+ comments, 1500+ ratings, 800+ favorites created.' as status; 