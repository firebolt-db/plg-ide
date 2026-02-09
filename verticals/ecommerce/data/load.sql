-- E-commerce Vertical Data Loading
-- Loads E-commerce dataset from Firebolt's public S3 bucket OR generates sample data

-- =============================================================================
-- OPTION A: Generate sample data via SQL (DEFAULT - works everywhere)
-- =============================================================================
-- Creates: 100K customers, 10K products, 1M orders, 5M order items
-- Approximate load time: 10-60 seconds depending on engine size

-- Insert sample customers
INSERT INTO customers (customer_id, email, first_name, last_name, registration_date, country, tier, total_orders, lifetime_value)
SELECT 
    seq AS customer_id,
    'customer_' || seq::TEXT || '@example.com' AS email,
    'Customer' AS first_name,
    seq::TEXT AS last_name,
    DATE '2020-01-01' + (seq % 1825) AS registration_date,
    CASE seq % 10 
        WHEN 0 THEN 'USA' WHEN 1 THEN 'UK' WHEN 2 THEN 'Germany' 
        WHEN 3 THEN 'France' WHEN 4 THEN 'Canada' WHEN 5 THEN 'Australia'
        WHEN 6 THEN 'Japan' WHEN 7 THEN 'Brazil' WHEN 8 THEN 'India' 
        ELSE 'Spain' 
    END AS country,
    CASE seq % 4 
        WHEN 0 THEN 'bronze' WHEN 1 THEN 'silver' WHEN 2 THEN 'gold' 
        ELSE 'platinum' 
    END AS tier,
    (seq % 100) AS total_orders,
    (seq % 10000)::DECIMAL(12,2) AS lifetime_value
FROM generate_series(1, 100000) AS t(seq);

-- Insert sample categories
INSERT INTO categories (category_id, category_name, parent_category_id, level)
SELECT 
    seq AS category_id,
    'Category_' || seq::TEXT AS category_name,
    CASE WHEN seq > 10 THEN (seq % 10) ELSE NULL END AS parent_category_id,
    CASE WHEN seq <= 10 THEN 1 ELSE 2 END AS level
FROM generate_series(1, 50) AS t(seq);

-- Insert sample products
INSERT INTO products (product_id, product_name, category_id, brand, price, cost, description, status, created_at, updated_at)
SELECT 
    seq AS product_id,
    'Product_' || seq::TEXT AS product_name,
    (seq % 50) + 1 AS category_id,
    'Brand_' || (seq % 20)::TEXT AS brand,
    (50 + (seq % 500))::DECIMAL(10,2) AS price,
    (30 + (seq % 300))::DECIMAL(10,2) AS cost,
    'Description for product ' || seq::TEXT AS description,
    CASE seq % 20 WHEN 0 THEN 'out_of_stock' WHEN 1 THEN 'discontinued' ELSE 'active' END AS status,
    TIMESTAMP '2022-01-01 00:00:00' + INTERVAL '1 day' * (seq % 730) AS created_at,
    TIMESTAMP '2022-01-01 00:00:00' + INTERVAL '1 day' * (seq % 730) AS updated_at
FROM generate_series(1, 10000) AS t(seq);

-- Insert sample warehouses
INSERT INTO warehouses (warehouse_id, warehouse_name, country, region, address)
SELECT 
    seq AS warehouse_id,
    'Warehouse_' || seq::TEXT AS warehouse_name,
    CASE seq % 5 
        WHEN 0 THEN 'USA' WHEN 1 THEN 'UK' WHEN 2 THEN 'Germany' 
        WHEN 3 THEN 'France' ELSE 'Canada' 
    END AS country,
    'Region_' || (seq % 3)::TEXT AS region,
    'Address ' || seq::TEXT AS address
FROM generate_series(1, 20) AS t(seq);

-- Insert sample orders
INSERT INTO orders (order_id, customer_id, order_date, status, total_amount, shipping_cost, tax_amount, discount_amount, payment_method)
SELECT 
    seq AS order_id,
    (seq % 100000) + 1 AS customer_id,
    TIMESTAMP '2023-01-01 00:00:00' + INTERVAL '1 second' * seq AS order_date,
    CASE seq % 5 
        WHEN 0 THEN 'pending' WHEN 1 THEN 'processing' WHEN 2 THEN 'shipped' 
        WHEN 3 THEN 'delivered' ELSE 'cancelled' 
    END AS status,
    (100 + (seq % 1000))::DECIMAL(12,2) AS total_amount,
    (10 + (seq % 50))::DECIMAL(10,2) AS shipping_cost,
    (total_amount * 0.1)::DECIMAL(10,2) AS tax_amount,
    (seq % 20)::DECIMAL(10,2) AS discount_amount,
    CASE seq % 4 
        WHEN 0 THEN 'credit_card' WHEN 1 THEN 'paypal' WHEN 2 THEN 'debit_card' 
        ELSE 'bank_transfer' 
    END AS payment_method
FROM generate_series(1, 1000000) AS t(seq);

-- Insert sample order items (the high-volume table - 5M rows)
INSERT INTO order_items (order_item_id, order_id, product_id, quantity, unit_price, discount, subtotal, created_at)
SELECT 
    seq AS order_item_id,
    (seq % 1000000) + 1 AS order_id,
    (seq % 10000) + 1 AS product_id,
    (seq % 5) + 1 AS quantity,
    (50 + (seq % 500))::DECIMAL(10,2) AS unit_price,
    (seq % 10)::DECIMAL(10,2) AS discount,
    (quantity * unit_price - discount)::DECIMAL(12,2) AS subtotal,
    TIMESTAMP '2023-01-01 00:00:00' + INTERVAL '1 second' * (seq % 1000000) AS created_at
FROM generate_series(1, 5000000) AS t(seq);

-- Insert sample inventory
INSERT INTO inventory (inventory_id, product_id, warehouse_id, quantity, reserved_quantity, last_updated)
SELECT 
    seq AS inventory_id,
    (seq % 10000) + 1 AS product_id,
    (seq % 20) + 1 AS warehouse_id,
    (seq % 1000) + 10 AS quantity,
    (seq % 50) AS reserved_quantity,
    TIMESTAMP '2024-01-01 00:00:00' + INTERVAL '1 hour' * (seq % 8760) AS last_updated
FROM generate_series(1, 200000) AS t(seq);

-- =============================================================================
-- VERIFICATION
-- =============================================================================

-- Check row counts
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'categories', COUNT(*) FROM categories
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'warehouses', COUNT(*) FROM warehouses
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'inventory', COUNT(*) FROM inventory
ORDER BY table_name;

-- Check order_items date range and stats
SELECT 
    MIN(created_at) AS earliest_order,
    MAX(created_at) AS latest_order,
    COUNT(DISTINCT order_id) AS unique_orders,
    COUNT(DISTINCT product_id) AS unique_products,
    SUM(subtotal) AS total_revenue
FROM order_items;

-- =============================================================================
-- OPTION B: Load from S3 (ADVANCED - for larger datasets)
-- =============================================================================
-- If you want BILLION-row scale testing, use Firebolt's public sample datasets.
-- 
-- PREREQUISITES:
--   1. You must be on Firebolt Cloud (not Core)
--   2. Your engine must have access to AWS S3 us-east-1 region
--   3. First TRUNCATE the tables created above, then run these COPY commands:
--
-- TRUNCATE TABLE customers;
-- TRUNCATE TABLE categories;
-- TRUNCATE TABLE products;
-- TRUNCATE TABLE warehouses;
-- TRUNCATE TABLE orders;
-- TRUNCATE TABLE order_items;
-- TRUNCATE TABLE inventory;
--
-- COPY INTO customers FROM 's3://firebolt-sample-datasets-public-us-east-1/ecommerce/parquet/customers/'
--     WITH PATTERN = '*.snappy.parquet' TYPE = PARQUET;
--
-- COPY INTO categories FROM 's3://firebolt-sample-datasets-public-us-east-1/ecommerce/parquet/categories/'
--     WITH PATTERN = '*.snappy.parquet' TYPE = PARQUET;
--
-- COPY INTO products FROM 's3://firebolt-sample-datasets-public-us-east-1/ecommerce/parquet/products/'
--     WITH PATTERN = '*.snappy.parquet' TYPE = PARQUET;
--
-- COPY INTO warehouses FROM 's3://firebolt-sample-datasets-public-us-east-1/ecommerce/parquet/warehouses/'
--     WITH PATTERN = '*.snappy.parquet' TYPE = PARQUET;
--
-- COPY INTO orders FROM 's3://firebolt-sample-datasets-public-us-east-1/ecommerce/parquet/orders/'
--     WITH PATTERN = '*.snappy.parquet' TYPE = PARQUET;
--
-- COPY INTO order_items FROM 's3://firebolt-sample-datasets-public-us-east-1/ecommerce/parquet/order_items/'
--     WITH PATTERN = '*.snappy.parquet' TYPE = PARQUET;
--
-- COPY INTO inventory FROM 's3://firebolt-sample-datasets-public-us-east-1/ecommerce/parquet/inventory/'
--     WITH PATTERN = '*.snappy.parquet' TYPE = PARQUET;
--
-- NOTE: The S3 dataset contains 412M rows in order_items. Load time depends 
-- on your engine size. Expect 10-30 minutes for a small engine.
