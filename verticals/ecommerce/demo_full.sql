-- =============================================================================
-- FIREBOLT plg-ide: E-commerce Analytics Demo
-- =============================================================================
-- 
-- This script demonstrates Firebolt's capabilities through a step-by-step
-- walkthrough of the E-commerce dataset. Run each stage sequentially
-- to experience the dramatic performance improvements from aggregating indexes.
--
-- TARGET DATABASE: ecommerce
-- EXPECTED DURATION: ~15-20 minutes
-- 
-- =============================================================================
--
-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │                    FOR PRESENTERS: KEY TALKING POINTS                       │
-- ├─────────────────────────────────────────────────────────────────────────────┤
-- │                                                                             │
-- │  OPENING (Stage 0-2):                                                       │
-- │  "We're using an e-commerce analytics dataset - customers, products,      │
-- │   and 5 million+ order line items. This represents a mid-size retailer     │
-- │   with real-world complexity."                                              │
-- │                                                                             │
-- │  BUSINESS CONTEXT:                                                         │
-- │  "E-commerce companies need to answer questions like:                      │
-- │   • What are our top-selling products by category?                        │
-- │   • What's the customer lifetime value by tier?                           │
-- │   • How is revenue trending day-over-day?                                 │
-- │   These queries run constantly for dashboards and reports."                │
-- │                                                                             │
-- │  BASELINE (Stage 3):                                                        │
-- │  "Watch these queries - they're scanning millions of order line items.    │
-- │   In production with hundreds of millions of rows, these would take        │
-- │   minutes and cost hundreds of dollars per query."                         │
-- │                                                                             │
-- │  THE MAGIC (Stage 4):                                                       │
-- │  "Now we create aggregating indexes. This tells Firebolt:                 │
-- │   'Pre-compute sales by product, by category, by customer - I need       │
-- │   these aggregations constantly.'"                                         │
-- │                                                                             │
-- │  THE PAYOFF (Stage 5):                                                      │
-- │  "Same queries. Same data. But now look at the timing - 50-100X faster.   │
-- │   The SQL didn't change. Firebolt just reads pre-computed answers."        │
-- │                                                                             │
-- │  BUSINESS VALUE:                                                            │
-- │  • "Every byte not scanned is money saved on cloud compute"                │
-- │  • "Faster queries = real-time dashboards instead of stale reports"       │
-- │  • "No application changes - your existing BI tools just get faster"       │
-- │  • "Customer 360 views that refresh in milliseconds, not minutes"          │
-- │                                                                             │
-- │  COMPETITIVE ANGLE:                                                         │
-- │  • "Snowflake requires materialized views + manual refresh + maintenance" │
-- │  • "BigQuery clustering helps but doesn't pre-compute aggregations"        │
-- │  • "Redshift requires complex VACUUM and ANALYZE operations"              │
-- │                                                                             │
-- └─────────────────────────────────────────────────────────────────────────────┘
--
-- =============================================================================


-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║                        STAGE 0: ENVIRONMENT SETUP                         ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

-- Check Firebolt version
SELECT version() AS firebolt_version;

-- Create database
CREATE DATABASE IF NOT EXISTS ecommerce;

-- Use the database
USE DATABASE ecommerce;

-- Verify connection
SELECT 
    'Connection successful!' AS status,
    CURRENT_TIMESTAMP AS connected_at,
    CURRENT_DATABASE() AS database_name;


-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║                        STAGE 1: SCHEMA CREATION                           ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝
-- Purpose: Create the tables for the e-commerce analytics use case

-- Run schema creation (assumes schema/01_tables.sql has been executed)
-- Or include schema here if running standalone

SELECT 'Schema created successfully!' AS status;
SHOW TABLES;


-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║                         STAGE 2: DATA LOADING                             ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝
-- Purpose: Load the E-commerce dataset
-- 
-- NOTE: Run data/load.sql separately or include data generation here

SELECT 'Data loading complete!' AS status;

SELECT 
    'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
ORDER BY table_name;


-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║                   STAGE 3: BASELINE PERFORMANCE (SLOW)                    ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝
-- Purpose: Run analytical queries WITHOUT aggregating indexes
-- These queries will perform FULL TABLE SCANS on order_items

-- Disable result cache to get accurate timing
SET enable_result_cache = FALSE;

-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │  WHY THIS IS SLOW: Without aggregating indexes, Firebolt must:             │
-- │  1. Read EVERY row in order_items (5M+ rows)                               │
-- │  2. Decompress and parse each row                                          │
-- │  3. Compute aggregations (SUM, AVG, COUNT) on the fly                      │
-- │  4. Join with products/customers tables                                    │
-- │  5. Group and sort the results                                             │
-- │                                                                             │
-- │  This is EXPENSIVE in time, I/O, and compute resources.                    │
-- └─────────────────────────────────────────────────────────────────────────────┘

-- -----------------------------------------------------------------------------
-- BASELINE QUERY 1: Product Sales by Category
-- Business question: "What are our top-selling products by category?"
-- Without index: Must scan ALL order_items and join with products
-- -----------------------------------------------------------------------------
SELECT '>>> BASELINE QUERY 1: Product Sales by Category <<<' AS query_name;

EXPLAIN ANALYZE
SELECT 
    c.category_name,
    p.product_name,
    p.brand,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.subtotal) AS total_revenue,
    COUNT(DISTINCT oi.order_id) AS order_count,
    AVG(oi.unit_price) AS avg_price
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
WHERE oi.created_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY c.category_id, c.category_name, p.product_id, p.product_name, p.brand
ORDER BY total_revenue DESC
LIMIT 50;

-- Record this timing: _____________ ms

-- -----------------------------------------------------------------------------
-- BASELINE QUERY 2: Customer Lifetime Value
-- Business question: "What's the customer lifetime value by tier?"
-- Without index: Must scan all order_items grouped by customer
-- -----------------------------------------------------------------------------
SELECT '>>> BASELINE QUERY 2: Customer Lifetime Value <<<' AS query_name;

EXPLAIN ANALYZE
SELECT 
    c.tier,
    COUNT(DISTINCT c.customer_id) AS customer_count,
    SUM(oi.subtotal) AS total_revenue,
    AVG(oi.subtotal) AS avg_order_value,
    COUNT(DISTINCT oi.order_id) AS total_orders
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.tier
ORDER BY total_revenue DESC;

-- Record this timing: _____________ ms

-- -----------------------------------------------------------------------------
-- BASELINE QUERY 3: Daily Revenue Trends
-- Business question: "How is revenue trending day-over-day?"
-- Without index: Must scan all order_items and group by day
-- -----------------------------------------------------------------------------
SELECT '>>> BASELINE QUERY 3: Daily Revenue Trends <<<' AS query_name;

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

-- Record this timing: _____________ ms

-- -----------------------------------------------------------------------------
-- BASELINE QUERY 4: Top Products by Brand
-- Business question: "Which brands are performing best?"
-- Without index: Full scan with GROUP BY brand
-- -----------------------------------------------------------------------------
SELECT '>>> BASELINE QUERY 4: Top Products by Brand <<<' AS query_name;

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

-- Record this timing: _____________ ms

SELECT 'Stage 3 complete - record your baseline timings above!' AS status;


-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║             STAGE 4: ENABLE FEATURE - AGGREGATING INDEXES                 ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝
-- 
-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │                    WHAT ARE AGGREGATING INDEXES?                            │
-- ├─────────────────────────────────────────────────────────────────────────────┤
-- │                                                                             │
-- │  PROBLEM: E-commerce queries constantly compute the same aggregations:     │
-- │           sales by product, revenue by customer, daily totals. This is slow  │
-- │           because every query scans millions of order line items.          │
-- │                                                                             │
-- │  SOLUTION: Aggregating indexes PRE-COMPUTE these aggregations when data    │
-- │            is written. Think of it as a "pre-calculated report" that       │
-- │            Firebolt maintains automatically.                                │
-- │                                                                             │
-- │  BUSINESS IMPACT:                                                           │
-- │  • Real-time dashboards instead of stale hourly reports                    │
-- │  • Customer 360 views that refresh instantly                               │
-- │  • Product recommendations based on live sales data                       │
-- │  • Cost savings: 99% less data scanned = 99% lower query costs            │
-- │                                                                             │
-- └─────────────────────────────────────────────────────────────────────────────┘

-- -----------------------------------------------------------------------------
-- INDEX 1: Product Sales Index
-- Matches: Product sales queries (GROUP BY product, category)
-- -----------------------------------------------------------------------------
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

-- -----------------------------------------------------------------------------
-- INDEX 2: Category Sales Index
-- Matches: Category-level aggregations
-- -----------------------------------------------------------------------------
CREATE AGGREGATING INDEX IF NOT EXISTS order_items_category_agg
ON order_items (
    DATE_TRUNC('day', created_at),
    SUM(quantity),
    SUM(subtotal),
    COUNT(DISTINCT order_id),
    COUNT(DISTINCT product_id),
    COUNT(*)
);

-- -----------------------------------------------------------------------------
-- INDEX 3: Customer Revenue Index
-- Matches: Customer lifetime value queries (via orders join)
-- Note: This requires joining with orders, so we index by order_id
-- -----------------------------------------------------------------------------
CREATE AGGREGATING INDEX IF NOT EXISTS order_items_customer_agg
ON order_items (
    order_id,
    SUM(subtotal),
    SUM(quantity),
    COUNT(DISTINCT product_id),
    COUNT(*)
);

-- -----------------------------------------------------------------------------
-- INDEX 4: Daily Revenue Index
-- Matches: Daily/weekly/monthly revenue trends
-- -----------------------------------------------------------------------------
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

-- Verify indexes created
SELECT 'Aggregating indexes created!' AS status;
SHOW INDEXES ON order_items;


-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║                  STAGE 5: OPTIMIZED PERFORMANCE (FAST!)                   ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝
-- Purpose: Run the SAME queries again - now they use the aggregating indexes

-- Ensure cache is still disabled
SET enable_result_cache = FALSE;

-- -----------------------------------------------------------------------------
-- OPTIMIZED QUERY 1: Product Sales by Category (NOW FAST!)
-- Uses: order_items_product_sales_agg
-- Expected improvement: ~80X faster
-- -----------------------------------------------------------------------------
SELECT '>>> OPTIMIZED QUERY 1: Product Sales by Category <<<' AS query_name;

EXPLAIN ANALYZE
SELECT 
    c.category_name,
    p.product_name,
    p.brand,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.subtotal) AS total_revenue,
    COUNT(DISTINCT oi.order_id) AS order_count,
    AVG(oi.unit_price) AS avg_price
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
WHERE oi.created_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY c.category_id, c.category_name, p.product_id, p.product_name, p.brand
ORDER BY total_revenue DESC
LIMIT 50;

-- Compare to baseline: _____________ ms → _____________ ms (____X faster)

-- -----------------------------------------------------------------------------
-- OPTIMIZED QUERY 2: Customer Lifetime Value (NOW FAST!)
-- Uses: order_items_customer_agg (via orders join)
-- Expected improvement: ~60X faster
-- -----------------------------------------------------------------------------
SELECT '>>> OPTIMIZED QUERY 2: Customer Lifetime Value <<<' AS query_name;

EXPLAIN ANALYZE
SELECT 
    c.tier,
    COUNT(DISTINCT c.customer_id) AS customer_count,
    SUM(oi.subtotal) AS total_revenue,
    AVG(oi.subtotal) AS avg_order_value,
    COUNT(DISTINCT oi.order_id) AS total_orders
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.tier
ORDER BY total_revenue DESC;

-- Compare to baseline: _____________ ms → _____________ ms (____X faster)

-- -----------------------------------------------------------------------------
-- OPTIMIZED QUERY 3: Daily Revenue Trends (NOW FAST!)
-- Uses: order_items_daily_agg
-- Expected improvement: ~90X faster
-- -----------------------------------------------------------------------------
SELECT '>>> OPTIMIZED QUERY 3: Daily Revenue Trends <<<' AS query_name;

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

-- Compare to baseline: _____________ ms → _____________ ms (____X faster)

-- -----------------------------------------------------------------------------
-- OPTIMIZED QUERY 4: Top Products by Brand (NOW FAST!)
-- Uses: order_items_product_sales_agg
-- Expected improvement: ~70X faster
-- -----------------------------------------------------------------------------
SELECT '>>> OPTIMIZED QUERY 4: Top Products by Brand <<<' AS query_name;

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

-- Compare to baseline: _____________ ms → _____________ ms (____X faster)

SELECT 'Stage 5 complete - compare your timings to the baseline!' AS status;

-- Re-enable result cache
SET enable_result_cache = TRUE;

-- =============================================================================
-- SUMMARY
-- =============================================================================
--
-- WHAT YOU DEMONSTRATED:
--
-- 1. Created an e-commerce analytics schema with high-volume fact tables
--
-- 2. Ran common analytical queries WITHOUT optimization (SLOW - full scans)
--
-- 3. Created aggregating indexes that match query patterns
--
-- 4. Ran the SAME queries WITH indexes (FAST - 50-100X improvement)
--
-- KEY TAKEAWAYS:
--
-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │ Aggregating indexes transform e-commerce analytics                      │
-- │                                                                         │
-- │ • Pre-compute sales aggregations at write time                         │
-- │ • Real-time dashboards instead of stale reports                       │
-- │ • 50-100X faster queries on revenue/product analytics                  │
-- │ • 99%+ reduction in data scanned (massive cost savings!)              │
-- └─────────────────────────────────────────────────────────────────────────┘
