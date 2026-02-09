-- =============================================================================
-- FIREBOLT plg-ide: AdTech Comparison Demo (impact first)
-- =============================================================================
--
-- Design: Show the wow (fast query) first, then explain, then show slow for contrast.
-- Run each section in order.
--
-- Prerequisite: AdTech tables and data (schema/01_tables.sql + data/load.sql).
--
-- =============================================================================


-- =============================================================================
-- Setup: Tracker table + ensure index exists + disable result cache
-- =============================================================================
-- demo_progress records which steps have been run (for IDE or app progress).
-- Query progress: SELECT step_id, completed_at FROM demo_progress WHERE session_id = SESSION_USER() ORDER BY completed_at;
-- =============================================================================

CREATE TABLE IF NOT EXISTS demo_progress (
    session_id TEXT,
    step_id TEXT,
    completed_at TIMESTAMP
);

CREATE AGGREGATING INDEX IF NOT EXISTS impressions_campaign_daily_agg
ON impressions (campaign_id, DATE_TRUNC('day', timestamp), COUNT(*), COUNT(DISTINCT user_id), SUM(win_price), AVG(win_price));

SET enable_result_cache = FALSE;


-- =============================================================================
-- Step 1: Fast query (impact first)
-- =============================================================================
-- Campaign by day with the aggregating index. Note how fast it is.
-- -----------------------------------------------------------------------------

INSERT INTO demo_progress (session_id, step_id, completed_at) VALUES (SESSION_USER(), '1', NOW());
SELECT campaign_id, DATE_TRUNC('day', timestamp) AS day,
       COUNT(*) AS impressions, SUM(win_price) AS spend
FROM impressions
WHERE timestamp >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY campaign_id, DATE_TRUNC('day', timestamp)
ORDER BY day DESC, impressions DESC LIMIT 20;


-- =============================================================================
-- Step 2: Explain (dig in – why it's fast)
-- =============================================================================
-- Plan shows use of the aggregating index instead of a full table scan.
-- -----------------------------------------------------------------------------

INSERT INTO demo_progress (session_id, step_id, completed_at) VALUES (SESSION_USER(), '2', NOW());
EXPLAIN (LOGICAL)
SELECT campaign_id, DATE_TRUNC('day', timestamp) AS day,
       COUNT(*) AS impressions, SUM(win_price) AS spend
FROM impressions
WHERE timestamp >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY campaign_id, DATE_TRUNC('day', timestamp)
ORDER BY day DESC, impressions DESC LIMIT 20;


-- =============================================================================
-- Step 3: Drop the index
-- =============================================================================
-- -----------------------------------------------------------------------------

INSERT INTO demo_progress (session_id, step_id, completed_at) VALUES (SESSION_USER(), '3', NOW());
DROP AGGREGATING INDEX IF EXISTS impressions_campaign_daily_agg;


-- =============================================================================
-- Step 4: Same query without index (slow – the contrast)
-- =============================================================================
-- Same SELECT as step 1. Compare query time to step 1.
-- -----------------------------------------------------------------------------

INSERT INTO demo_progress (session_id, step_id, completed_at) VALUES (SESSION_USER(), '4', NOW());
SELECT campaign_id, DATE_TRUNC('day', timestamp) AS day,
       COUNT(*) AS impressions, SUM(win_price) AS spend
FROM impressions
WHERE timestamp >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY campaign_id, DATE_TRUNC('day', timestamp)
ORDER BY day DESC, impressions DESC LIMIT 20;


-- =============================================================================
-- Step 5: Restore the index (optional)
-- =============================================================================
-- -----------------------------------------------------------------------------

INSERT INTO demo_progress (session_id, step_id, completed_at) VALUES (SESSION_USER(), '5', NOW());
CREATE AGGREGATING INDEX IF NOT EXISTS impressions_campaign_daily_agg
ON impressions (campaign_id, DATE_TRUNC('day', timestamp), COUNT(*), COUNT(DISTINCT user_id), SUM(win_price), AVG(win_price));


-- =============================================================================
-- Cleanup: re-enable result cache
-- =============================================================================
-- -----------------------------------------------------------------------------

SET enable_result_cache = TRUE;

SELECT 'AdTech comparison demo complete!' AS status;

-- =============================================================================
-- END OF COMPARISON DEMO
-- =============================================================================
