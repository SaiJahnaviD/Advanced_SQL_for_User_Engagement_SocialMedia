

Instagram User Analytics — Advanced SQL Project

use ig_clone;

1. Data Quality & Sanity Checks

1.1 Total records overview

SELECT 
    (SELECT COUNT(*) FROM users)  AS total_users,
    (SELECT COUNT(*) FROM photos) AS total_photos,
    (SELECT COUNT(*) FROM likes)  AS total_likes,
    (SELECT COUNT(*) FROM tags)   AS total_tags;


1.2 Users with duplicate usernames (data issue check)

SELECT username, COUNT(*) AS occurrences
FROM users
GROUP BY username
HAVING COUNT(*) > 1;


1.3 Photos with zero likes (content quality check)

SELECT p.id AS photo_id, p.user_id
FROM photos p
LEFT JOIN likes l ON p.id = l.photo_id
WHERE l.photo_id IS NULL;



2. Marketing Analytics 

2.1 Most Loyal Users (Oldest + Active users)

SELECT 
    u.id,
    u.username,
    u.created_at,
    COUNT(p.id) AS total_posts
FROM users u
LEFT JOIN photos p ON u.id = p.user_id
GROUP BY u.id, u.username, u.created_at
ORDER BY u.created_at ASC, total_posts DESC
LIMIT 5;


2.2 Inactive Users (Never Posted)

SELECT 
    u.id,
    u.username
FROM users u
LEFT JOIN photos p ON u.id = p.user_id
WHERE p.id IS NULL;


2.3 Engagement Distribution (Power Users vs Casual Users)

SELECT 
    post_bucket,
    COUNT(*) AS user_count
FROM (
    SELECT 
        u.id,
        CASE
            WHEN COUNT(p.id) = 0 THEN 'Inactive'
            WHEN COUNT(p.id) BETWEEN 1 AND 2 THEN 'Low Activity'
            WHEN COUNT(p.id) BETWEEN 3 AND 5 THEN 'Medium Activity'
            ELSE 'High Activity'
        END AS post_bucket
    FROM users u
    LEFT JOIN photos p ON u.id = p.user_id
    GROUP BY u.id
) t
GROUP BY post_bucket;



2.4 Most Liked Photo (Contest Winner)

SELECT 
    p.id AS photo_id,
    u.username,
    COUNT(l.user_id) AS total_likes
FROM photos p
JOIN likes l ON p.id = l.photo_id
JOIN users u ON p.user_id = u.id
GROUP BY p.id, u.username
ORDER BY total_likes DESC
LIMIT 1;


2.5 Hashtag Effectiveness (Not just popularity)

SELECT 
    t.tag_name,
    COUNT(pt.photo_id) AS total_usage,
    COUNT(DISTINCT l.user_id) AS total_likes
FROM tags t
JOIN photo_tags pt ON t.id = pt.tag_id
LEFT JOIN likes l ON pt.photo_id = l.photo_id
GROUP BY t.tag_name
ORDER BY total_likes DESC
LIMIT 5;


2.6 Best Day for Ad Campaign (Improved)

SELECT 
    DAYNAME(created_at) AS day_of_week,
    COUNT(*) AS registrations
FROM users
GROUP BY day_of_week
ORDER BY registrations DESC;





3. Investor Metrics 

3.1 Average Posts Per User (Clean Version)
SELECT 
    ROUND(COUNT(p.id) / COUNT(DISTINCT p.user_id), 2) AS avg_posts_per_active_user
FROM photos p;



3.2 Platform Engagement Ratio
SELECT 
    ROUND(COUNT(p.id) / COUNT(u.id), 2) AS posts_to_users_ratio
FROM users u
LEFT JOIN photos p ON u.id = p.user_id;



3.3 User Like Behavior (Engagement Intensity)
SELECT 
    u.id,
    u.username,
    COUNT(l.photo_id) AS total_likes_given
FROM users u
LEFT JOIN likes l ON u.id = l.user_id
GROUP BY u.id, u.username
ORDER BY total_likes_given DESC;

3.4 Bot / Fake Account Detection (Improved Logic)

Criteria: 1. Liked almost all photos      2. Posted zero photos

WITH total_photos AS (
    SELECT COUNT(*) AS cnt FROM photos
),
user_likes AS (
    SELECT user_id, COUNT(photo_id) AS liked_photos
    FROM likes
    GROUP BY user_id
),
user_posts AS (
    SELECT user_id, COUNT(*) AS total_posts
    FROM photos
    GROUP BY user_id
)
SELECT 
    u.id,
    u.username,
    ul.liked_photos,
    tp.cnt AS total_photos
FROM users u
JOIN user_likes ul ON u.id = ul.user_id
LEFT JOIN user_posts up ON u.id = up.user_id
CROSS JOIN total_photos tp
WHERE ul.liked_photos >= 0.9 * tp.cnt
  AND IFNULL(up.total_posts, 0) = 0;

- Much stronger and more realistic than “liked everything” logic



4. Retention Proxy (Advanced SQL – DS Level)

SELECT 
    DATE_FORMAT(created_at, '%Y-%m') AS signup_month,
    COUNT(*) AS users_registered
FROM users
GROUP BY signup_month
ORDER BY signup_month;

























