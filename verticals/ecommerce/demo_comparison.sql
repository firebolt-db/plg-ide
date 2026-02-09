-- =============================================================================
-- FIREBOLT plg-ide: E-commerce Side-by-Side Comparison Demo
-- =============================================================================
-- Run this AFTER demo_full.sql (or schema + data/load.sql) has set up data.
--
-- VALUE PROPOSITION:
-- "Firebolt's aggregating indexes deliver 50-100X faster queries with 99%+ 
--  reduction in data scanned. For e-commerce: real-time dashboards, customer 360 
--  in milliseconds, and cost savings proportional to data volume."
-- =============================================================================

SET enable_result_cache = FALSE;

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║              COMPARISON 1: DAILY REVENUE TRENDS                           ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

DROP AGGREGATING INDEX IF EXISTS order_items_daily_agg;

SELECT 'DAILY REVENUE - WITHOUT INDEX' AS test_name, NOW() AS started_at;

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

SELECT 'DAILY REVENUE - WITH INDEX' AS test_name, NOW() AS started_at;

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


-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║              COMPARISON 2: PRODUCT SALES BY BRAND                         ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

DROP AGGREGATING INDEX IF EXISTS order_items_product_sales_agg;

SELECT 'PRODUCT SALES BY BRAND - WITHOUT INDEX' AS test_name, NOW() AS started_at;

SELECT 
    p.brand,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.subtotal) AS total_revenue,
    COUNT(DISTINCT oi.order_id) AS order_count
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
WHERE oi.created_at >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY p.brand
ORDER BY total_revenue DESC
LIMIT 20;

CREATE AGGREGATING INDEX IF NOT EXISTS order_items_product_sales_agg
ON order_items (
    product_id,
    DATE_TRUNC('day', created_at),
    SUM(quantity),
    SUM(subtotal),
    COUNT(DISTINCT order_id),
    AVG(unit_price),
    COUNT(*)
);

SELECT 'PRODUCT SALES BY BRAND - WITH INDEX' AS test_name, NOW() AS started_at;

SELECT 
    p.brand,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.subtotal) AS total_revenue,
    COUNT(DISTINCT oi.order_id) AS order_count
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
WHERE oi.created_at >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY p.brand
ORDER BY total_revenue DESC
LIMIT 20;


-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║                    VALUE PROPOSITION SUMMARY                             ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

SELECT 
    '┌─────────────────────────────────────────────────────────────────┐' AS border
UNION ALL SELECT 
    '│         FIREBOLT AGGREGATING INDEX - E-COMMERCE                 │'
UNION ALL SELECT 
    '├─────────────────────────────────────────────────────────────────┤'
UNION ALL SELECT 
    '│ Feature: Aggregating Indexes on order_items                     │'
UNION ALL SELECT 
    '│ Dataset: E-commerce (5M+ order line items)                      │'
UNION ALL SELECT 
    '│                                                                 │'
UNION ALL SELECT 
    '│ Expected: 50-100X faster, 99%+ less data scanned                │'
UNION ALL SELECT 
    '│ Business: Real-time dashboards, customer 360, cost savings     │'
UNION ALL SELECT 
    '└─────────────────────────────────────────────────────────────────┘';


-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║                         DATA INSIGHTS QUERIES                             ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

SELECT 
    c.tier,
    COUNT(DISTINCT o.customer_id) AS customers,
    SUM(oi.subtotal) AS total_revenue,
    AVG(oi.subtotal) AS avg_order_value
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
WHERE oi.created_at >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY c.tier
ORDER BY total_revenue DESC;

SELECT 
    p.category_id,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.subtotal) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
WHERE oi.created_at >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY p.category_id
ORDER BY revenue DESC
LIMIT 10;

SET enable_result_cache = TRUE;

SELECT 'E-commerce comparison demo complete!' AS status;
