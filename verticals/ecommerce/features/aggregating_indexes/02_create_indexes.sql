-- Aggregating Indexes Demo: Create Indexes (E-commerce)
-- These indexes pre-compute aggregations for common query patterns

-- =============================================================================
-- INDEX 1: Product Sales Aggregating Index
-- Optimizes: Product/category sales queries
-- Groups by: product_id, day (date truncated)
-- =============================================================================

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

-- =============================================================================
-- INDEX 2: Daily Revenue Aggregating Index
-- Optimizes: Daily/weekly/monthly revenue trends
-- Groups by: day (date truncated)
-- =============================================================================

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
-- INDEX 3: Order-Level Aggregating Index (for customer analytics)
-- Optimizes: Customer lifetime value via orders join
-- Groups by: order_id
-- =============================================================================

CREATE AGGREGATING INDEX IF NOT EXISTS order_items_order_agg
ON order_items (
    order_id,
    SUM(subtotal),
    SUM(quantity),
    COUNT(DISTINCT product_id),
    COUNT(*)
);

-- =============================================================================
-- VERIFICATION
-- =============================================================================

SHOW INDEXES ON order_items;
