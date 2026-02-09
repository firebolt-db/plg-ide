-- =============================================================================
-- FIREBOLT plg-ide: Observability Comparison Demo (impact first)
-- =============================================================================
--
-- Design: Show the wow (fast query) first, then explain, then show slow for contrast.
-- Run each section in order.
--
-- Prerequisite: Observability tables and data (schema/01_tables.sql + data/load.sql).
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

CREATE AGGREGATING INDEX IF NOT EXISTS logs_service_daily_agg
ON logs (service_id, DATE_TRUNC('day', timestamp), level, COUNT(*), COUNT(DISTINCT endpoint_id), AVG(duration_ms));

SET enable_result_cache = FALSE;


-- =============================================================================
-- Step 1: Fast query (impact first)
-- =============================================================================
-- Logs by service/day with the aggregating index. Note how fast it is.
-- -----------------------------------------------------------------------------

INSERT INTO demo_progress (session_id, step_id, completed_at) VALUES (SESSION_USER(), '1', NOW());
SELECT service_id, DATE_TRUNC('day', timestamp) AS day,
       COUNT(*) AS log_count, AVG(duration_ms) AS avg_duration_ms
FROM logs
WHERE timestamp >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY service_id, DATE_TRUNC('day', timestamp)
ORDER BY day DESC, log_count DESC LIMIT 20;


-- =============================================================================
-- Step 2: Explain (dig in – why it's fast)
-- =============================================================================
-- Plan shows use of the aggregating index instead of a full table scan.
-- -----------------------------------------------------------------------------

INSERT INTO demo_progress (session_id, step_id, completed_at) VALUES (SESSION_USER(), '2', NOW());
EXPLAIN (LOGICAL)
SELECT service_id, DATE_TRUNC('day', timestamp) AS day,
       COUNT(*) AS log_count, AVG(duration_ms) AS avg_duration_ms
FROM logs
WHERE timestamp >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY service_id, DATE_TRUNC('day', timestamp)
ORDER BY day DESC, log_count DESC LIMIT 20;


-- =============================================================================
-- Step 3: Drop the index
-- =============================================================================
-- -----------------------------------------------------------------------------

INSERT INTO demo_progress (session_id, step_id, completed_at) VALUES (SESSION_USER(), '3', NOW());
DROP AGGREGATING INDEX IF EXISTS logs_service_daily_agg;


-- =============================================================================
-- Step 4: Same query without index (slow – the contrast)
-- =============================================================================
-- Same SELECT as step 1. Compare query time to step 1.
-- -----------------------------------------------------------------------------

INSERT INTO demo_progress (session_id, step_id, completed_at) VALUES (SESSION_USER(), '4', NOW());
SELECT service_id, DATE_TRUNC('day', timestamp) AS day,
       COUNT(*) AS log_count, AVG(duration_ms) AS avg_duration_ms
FROM logs
WHERE timestamp >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY service_id, DATE_TRUNC('day', timestamp)
ORDER BY day DESC, log_count DESC LIMIT 20;


-- =============================================================================
-- Step 5: Restore the index (optional)
-- =============================================================================
-- -----------------------------------------------------------------------------

INSERT INTO demo_progress (session_id, step_id, completed_at) VALUES (SESSION_USER(), '5', NOW());
CREATE AGGREGATING INDEX IF NOT EXISTS logs_service_daily_agg
ON logs (service_id, DATE_TRUNC('day', timestamp), level, COUNT(*), COUNT(DISTINCT endpoint_id), AVG(duration_ms));


-- =============================================================================
-- Cleanup: re-enable result cache
-- =============================================================================
-- -----------------------------------------------------------------------------

SET enable_result_cache = TRUE;

SELECT 'Observability comparison demo complete!' AS status;

-- =============================================================================
-- END OF COMPARISON DEMO
-- =============================================================================
