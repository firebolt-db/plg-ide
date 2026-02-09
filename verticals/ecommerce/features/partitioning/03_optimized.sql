-- Partitioning Demo: Optimized Queries (E-commerce)
-- Same queries as 01_baseline.sql - table is partitioned by DATE_TRUNC('month', created_at)
-- so the engine only reads partitions that overlap the filter (partition pruning)

SET enable_result_cache = FALSE;

-- =============================================================================
-- QUERY 1: Daily revenue for last 30 days (OPTIMIZED - partition pruning)
-- With partitioning: Only scans partition(s) for the last 30 days
-- Expected: Fewer rows scanned, faster response
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
-- QUERY 2: Order count by day for last 7 days (OPTIMIZED)
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
