-- Aggregating Indexes Demo: Baseline Queries (E-commerce)
-- These queries run WITHOUT aggregating indexes (full table scans)

-- Disable result cache for accurate timing
SET enable_result_cache = FALSE;

-- =============================================================================
-- QUERY 1: Product Sales by Category
-- Without index: Scans ALL order_items and joins with products
-- =============================================================================

EXPLAIN ANALYZE
SELECT 
    p.category_id,
    p.brand,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.subtotal) AS total_revenue,
    COUNT(DISTINCT oi.order_id) AS order_count,
    AVG(oi.unit_price) AS avg_price
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
WHERE oi.created_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY p.category_id, p.brand
ORDER BY total_revenue DESC
LIMIT 50;

-- =============================================================================
-- QUERY 2: Daily Revenue Trends
-- Without index: Scans all order_items and group by day
-- =============================================================================

EXPLAIN ANALYZE
SELECT 
    DATE_TRUNC('day', oi.created_at) AS day,
    COUNT(DISTINCT oi.order_id) AS order_count,
    COUNT(DISTINCT oi.product_id) AS unique_products_sold,
    SUM(oi.quantity) AS total_quantity,
    SUM(oi.subtotal) AS total_revenue,
    AVG(oi.subtotal) AS avg_order_value
FROM order_items oi
WHERE oi.created_at >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY DATE_TRUNC('day', oi.created_at)
ORDER BY day DESC
LIMIT 90;

-- =============================================================================
-- QUERY 3: Top Products by Revenue
-- Without index: Full scan with product grouping
-- =============================================================================

EXPLAIN ANALYZE
SELECT 
    oi.product_id,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.subtotal) AS total_revenue,
    COUNT(DISTINCT oi.order_id) AS order_count,
    AVG(oi.unit_price) AS avg_price
FROM order_items oi
WHERE oi.created_at >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY oi.product_id
ORDER BY total_revenue DESC
LIMIT 20;

-- =============================================================================
-- QUERY 4: Brand Performance
-- Without index: Full scan with brand grouping via join
-- =============================================================================

EXPLAIN ANALYZE
SELECT 
    p.brand,
    COUNT(DISTINCT p.product_id) AS product_count,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.subtotal) AS total_revenue,
    AVG(oi.unit_price) AS avg_price
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
WHERE oi.created_at >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY p.brand
ORDER BY total_revenue DESC
LIMIT 20;
