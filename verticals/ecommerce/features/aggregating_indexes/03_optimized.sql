-- Aggregating Indexes Demo: Optimized Queries (E-commerce)
-- Same queries as 01_baseline.sql - now read from aggregating indexes

-- Disable result cache for accurate timing
SET enable_result_cache = FALSE;

-- =============================================================================
-- QUERY 1: Product Sales by Category (NOW FAST!)
-- Reads from: order_items_product_sales_agg
-- Expected: ~80X faster
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
-- QUERY 2: Daily Revenue Trends (NOW FAST!)
-- Reads from: order_items_daily_agg
-- Expected: ~90X faster
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
-- QUERY 3: Top Products by Revenue (NOW FAST!)
-- Reads from: order_items_product_sales_agg
-- Expected: ~70X faster
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
-- QUERY 4: Brand Performance (NOW FAST!)
-- Reads from: order_items_product_sales_agg
-- Expected: ~70X faster
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
