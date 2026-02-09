-- =============================================================================
-- FIREBOLT plg-ide: AdTech Analytics Demo
-- =============================================================================
--
-- TARGET DATABASE: adtech
-- Run schema/01_tables.sql and data/load.sql first.
--
-- FOR PRESENTERS:
-- "AdTech companies like Similarweb run 100+ QPS on 1PB; Bigabid saw 400X faster
--  queries and 77% storage savings. Aggregating indexes pre-compute campaign and
--  publisher aggregations so dashboards and RTB analytics stay fast."
-- =============================================================================

SELECT version() AS firebolt_version;
CREATE DATABASE IF NOT EXISTS adtech;
USE DATABASE adtech;

SELECT 'Connection successful!' AS status, CURRENT_DATABASE() AS database_name;

-- Verify data (run after data/load.sql)
SELECT 'impressions' AS table_name, COUNT(*) AS row_count FROM impressions
UNION ALL SELECT 'clicks', COUNT(*) FROM clicks
UNION ALL SELECT 'campaigns', COUNT(*) FROM campaigns;

SET enable_result_cache = FALSE;

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║                   BASELINE: Campaign Performance (SLOW)                  ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

SELECT '>>> BASELINE: Campaign Impressions by Day <<<' AS query_name;

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

SELECT '>>> BASELINE: Publisher Performance <<<' AS query_name;

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


-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║             ENABLE: Aggregating Indexes on impressions                    ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

CREATE AGGREGATING INDEX IF NOT EXISTS impressions_campaign_daily_agg
ON impressions (
    campaign_id,
    DATE_TRUNC('day', timestamp),
    COUNT(*),
    COUNT(DISTINCT user_id),
    SUM(win_price),
    AVG(win_price)
);

CREATE AGGREGATING INDEX IF NOT EXISTS impressions_publisher_agg
ON impressions (
    publisher_id,
    DATE_TRUNC('day', timestamp),
    COUNT(*),
    SUM(win_price),
    COUNT(DISTINCT campaign_id),
    COUNT(DISTINCT user_id)
);

SHOW INDEXES ON impressions;


-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║                  OPTIMIZED: Same Queries (FAST!)                         ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

SELECT '>>> OPTIMIZED: Campaign Impressions by Day <<<' AS query_name;

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

SELECT '>>> OPTIMIZED: Publisher Performance <<<' AS query_name;

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

SET enable_result_cache = TRUE;

SELECT 'AdTech demo complete! Compare baseline vs optimized timings above.' AS status;
