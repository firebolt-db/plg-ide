-- =============================================================================
-- FIREBOLT plg-ide: AdTech Side-by-Side Comparison Demo
-- =============================================================================
-- Run after schema/01_tables.sql and data/load.sql.
-- VALUE: "Similarweb 100 QPS on 1PB; Bigabid 400X faster, 77% storage savings.
--         Aggregating indexes pre-compute campaign/publisher aggregations."
-- =============================================================================

SET enable_result_cache = FALSE;

DROP AGGREGATING INDEX IF EXISTS impressions_campaign_daily_agg;
SELECT 'CAMPAIGN BY DAY - WITHOUT INDEX' AS test_name;
SELECT campaign_id, DATE_TRUNC('day', timestamp) AS day,
       COUNT(*) AS impressions, SUM(win_price) AS spend
FROM impressions
WHERE timestamp >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY campaign_id, DATE_TRUNC('day', timestamp)
ORDER BY day DESC, impressions DESC LIMIT 20;

CREATE AGGREGATING INDEX IF NOT EXISTS impressions_campaign_daily_agg
ON impressions (campaign_id, DATE_TRUNC('day', timestamp), COUNT(*), COUNT(DISTINCT user_id), SUM(win_price), AVG(win_price));

SELECT 'CAMPAIGN BY DAY - WITH INDEX' AS test_name;
SELECT campaign_id, DATE_TRUNC('day', timestamp) AS day,
       COUNT(*) AS impressions, SUM(win_price) AS spend
FROM impressions
WHERE timestamp >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY campaign_id, DATE_TRUNC('day', timestamp)
ORDER BY day DESC, impressions DESC LIMIT 20;

SELECT '┌─────────────────────────────────────────────────────────────────┐' AS border
UNION ALL SELECT '│ AdTech: Aggregating Indexes on impressions (campaign/day)   │'
UNION ALL SELECT '│ Expected: 50-100X faster, 99%+ less data scanned          │'
UNION ALL SELECT '└─────────────────────────────────────────────────────────────────┘';

SET enable_result_cache = TRUE;
SELECT 'AdTech comparison demo complete!' AS status;
