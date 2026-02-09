-- Aggregating Indexes Demo: Optimized Queries (AdTech)
-- Same queries - now read from aggregating indexes

SET enable_result_cache = FALSE;

-- Campaign performance by day (uses impressions_campaign_daily_agg)
EXPLAIN ANALYZE
SELECT 
    campaign_id,
    DATE_TRUNC('day', timestamp) AS day,
    COUNT(*) AS impressions,
    COUNT(DISTINCT user_id) AS unique_users,
    SUM(win_price) AS spend,
    AVG(win_price) AS avg_cpm
FROM impressions
WHERE timestamp >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY campaign_id, DATE_TRUNC('day', timestamp)
ORDER BY day DESC, impressions DESC
LIMIT 100;

-- Publisher performance (uses impressions_publisher_agg)
EXPLAIN ANALYZE
SELECT 
    publisher_id,
    COUNT(*) AS impressions,
    SUM(win_price) AS revenue,
    COUNT(DISTINCT campaign_id) AS campaigns_served,
    COUNT(DISTINCT user_id) AS unique_users
FROM impressions
WHERE timestamp >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY publisher_id
ORDER BY revenue DESC
LIMIT 50;

-- Device breakdown (uses impressions_device_agg)
EXPLAIN ANALYZE
SELECT 
    campaign_id,
    device_type,
    COUNT(*) AS impressions,
    SUM(win_price) AS spend
FROM impressions
WHERE timestamp >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY campaign_id, device_type
ORDER BY spend DESC
LIMIT 50;

-- Geo performance (uses impressions_geo_daily_agg)
EXPLAIN ANALYZE
SELECT 
    geo_country,
    DATE_TRUNC('day', timestamp) AS day,
    COUNT(*) AS impressions,
    SUM(win_price) AS spend
FROM impressions
WHERE timestamp >= CURRENT_DATE - INTERVAL '14 days'
GROUP BY geo_country, DATE_TRUNC('day', timestamp)
ORDER BY day DESC, spend DESC
LIMIT 100;
