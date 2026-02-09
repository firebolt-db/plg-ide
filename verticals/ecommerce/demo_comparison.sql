-- =============================================================================
-- FIREBOLT plg-ide: E-commerce Comparison Demo (impact first)
-- =============================================================================
--
-- Design: Show the wow (fast query) first, then explain, then show slow for contrast.
-- Run each section in order.
--
-- Prerequisite: E-commerce tables and data (schema/01_tables.sql + data/load.sql).
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

CREATE AGGREGATING INDEX IF NOT EXISTS order_items_daily_agg
ON order_items (
    DATE_TRUNC('day', created_at),
    SUM(subtotal),
    SUM(quantity),
    COUNT(DISTINCT order_id),
    COUNT(DISTINCT product_id),
    AVG(subtotal),
    COUNT(*)
);

SET enable_result_cache = FALSE;


-- =============================================================================
-- Step 1: Fast query (impact first)
-- =============================================================================
-- Daily revenue with the aggregating index. Note how fast it is.
-- -----------------------------------------------------------------------------

INSERT INTO demo_progress (session_id, step_id, completed_at) VALUES (SESSION_USER(), '1', NOW());
SELECT 
    DATE_TRUNC('day', created_at) AS day,
    COUNT(DISTINCT order_id) AS order_count,
    SUM(subtotal) AS total_revenue,
    AVG(subtotal) AS avg_order_value
FROM order_items
WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE_TRUNC('day', created_at)
ORDER BY day DESC
LIMIT 30;


-- =============================================================================
-- Step 2: Explain (dig in – why it's fast)
-- =============================================================================
-- Plan shows use of the aggregating index instead of a full table scan.
-- -----------------------------------------------------------------------------

INSERT INTO demo_progress (session_id, step_id, completed_at) VALUES (SESSION_USER(), '2', NOW());
EXPLAIN (LOGICAL)
SELECT 
    DATE_TRUNC('day', created_at) AS day,
    COUNT(DISTINCT order_id) AS order_count,
    SUM(subtotal) AS total_revenue,
    AVG(subtotal) AS avg_order_value
FROM order_items
WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE_TRUNC('day', created_at)
ORDER BY day DESC
LIMIT 30;


-- =============================================================================
-- Step 3: Drop the index
-- =============================================================================
-- -----------------------------------------------------------------------------

INSERT INTO demo_progress (session_id, step_id, completed_at) VALUES (SESSION_USER(), '3', NOW());
DROP AGGREGATING INDEX IF EXISTS order_items_daily_agg;


-- =============================================================================
-- Step 4: Same query without index (slow – the contrast)
-- =============================================================================
-- Same SELECT as step 1. Compare query time to step 1.
-- -----------------------------------------------------------------------------

INSERT INTO demo_progress (session_id, step_id, completed_at) VALUES (SESSION_USER(), '4', NOW());
SELECT 
    DATE_TRUNC('day', created_at) AS day,
    COUNT(DISTINCT order_id) AS order_count,
    SUM(subtotal) AS total_revenue,
    AVG(subtotal) AS avg_order_value
FROM order_items
WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE_TRUNC('day', created_at)
ORDER BY day DESC
LIMIT 30;


-- =============================================================================
-- Step 5: Restore the index (optional)
-- =============================================================================
-- -----------------------------------------------------------------------------

INSERT INTO demo_progress (session_id, step_id, completed_at) VALUES (SESSION_USER(), '5', NOW());
CREATE AGGREGATING INDEX IF NOT EXISTS order_items_daily_agg
ON order_items (
    DATE_TRUNC('day', created_at),
    SUM(subtotal),
    SUM(quantity),
    COUNT(DISTINCT order_id),
    COUNT(DISTINCT product_id),
    AVG(subtotal),
    COUNT(*)
);


-- =============================================================================
-- Cleanup: re-enable result cache
-- =============================================================================
-- -----------------------------------------------------------------------------

SET enable_result_cache = TRUE;

SELECT 'E-commerce comparison demo complete!' AS status;

-- =============================================================================
-- END OF COMPARISON DEMO
-- =============================================================================
