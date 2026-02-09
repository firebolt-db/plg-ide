-- Partitioning Demo: Baseline Queries (E-commerce)
-- These queries run on order_items WITHOUT partition pruning (full table scan)
-- Table is not partitioned by date, so the engine must read all data for date-range filters

SET enable_result_cache = FALSE;

-- =============================================================================
-- QUERY 1: Daily revenue for last 30 days (BASELINE - no partition pruning)
-- Without partitioning: Scans entire order_items table
-- =============================================================================

EXPLAIN ANALYZE
SELECT
    DATE_TRUNC('day', oi.created_at) AS day,
    COUNT(DISTINCT oi.order_id) AS order_count,
    SUM(oi.quantity) AS total_quantity,
    SUM(oi.subtotal) AS total_revenue
FROM order_items oi
WHERE oi.created_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE_TRUNC('day', oi.created_at)
ORDER BY day DESC
LIMIT 30;

-- =============================================================================
-- QUERY 2: Order count by day for last 7 days (BASELINE)
-- =============================================================================

EXPLAIN ANALYZE
SELECT
    DATE_TRUNC('day', oi.created_at) AS day,
    COUNT(*) AS line_count,
    SUM(oi.subtotal) AS revenue
FROM order_items oi
WHERE oi.created_at >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY DATE_TRUNC('day', oi.created_at)
ORDER BY day;
