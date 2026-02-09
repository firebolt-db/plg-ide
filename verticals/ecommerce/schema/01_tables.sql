-- E-commerce Vertical Schema
-- E-commerce Dataset Tables

-- =============================================================================
-- DIMENSION TABLES
-- =============================================================================

-- Customers table - customer profiles
CREATE TABLE IF NOT EXISTS customers (
    customer_id INT,
    email TEXT,
    first_name TEXT,
    last_name TEXT,
    registration_date DATE,
    country TEXT,
    tier TEXT,              -- 'bronze', 'silver', 'gold', 'platinum'
    total_orders INT,
    lifetime_value DECIMAL(12, 2)
) PRIMARY INDEX customer_id;

-- Products table - product catalog (wide table for late materialization demo)
CREATE TABLE IF NOT EXISTS products (
    product_id INT,
    product_name TEXT,
    category_id INT,
    brand TEXT,
    price DECIMAL(10, 2),
    cost DECIMAL(10, 2),
    description TEXT,
    specifications JSON,     -- Wide JSON column
    tags TEXT[],
    image_url TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    status TEXT             -- 'active', 'discontinued', 'out_of_stock'
) PRIMARY INDEX product_id;

-- Categories table - product hierarchy
CREATE TABLE IF NOT EXISTS categories (
    category_id INT,
    category_name TEXT,
    parent_category_id INT,
    level INT
) PRIMARY INDEX category_id;

-- Warehouses table - inventory locations
CREATE TABLE IF NOT EXISTS warehouses (
    warehouse_id INT,
    warehouse_name TEXT,
    country TEXT,
    region TEXT,
    address TEXT
) PRIMARY INDEX warehouse_id;

-- =============================================================================
-- FACT TABLES (HIGH VOLUME)
-- =============================================================================

-- Orders table - order headers
CREATE TABLE IF NOT EXISTS orders (
    order_id BIGINT,
    customer_id INT,
    order_date TIMESTAMP,
    status TEXT,            -- 'pending', 'processing', 'shipped', 'delivered', 'cancelled'
    total_amount DECIMAL(12, 2),
    shipping_cost DECIMAL(10, 2),
    tax_amount DECIMAL(10, 2),
    discount_amount DECIMAL(10, 2),
    payment_method TEXT,
    shipping_address TEXT
) PRIMARY INDEX order_id;

-- Order Items table - order line items (the star of the show)
-- This is where aggregating indexes provide massive value
CREATE TABLE IF NOT EXISTS order_items (
    order_item_id BIGINT,
    order_id BIGINT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10, 2),
    discount DECIMAL(10, 2),
    subtotal DECIMAL(12, 2),
    created_at TIMESTAMP
) PRIMARY INDEX order_item_id;

-- Inventory table - stock levels by warehouse
CREATE TABLE IF NOT EXISTS inventory (
    inventory_id BIGINT,
    product_id INT,
    warehouse_id INT,
    quantity INT,
    reserved_quantity INT,
    last_updated TIMESTAMP
) PRIMARY INDEX inventory_id;

-- =============================================================================
-- VERIFICATION
-- =============================================================================

-- Show created tables
SHOW TABLES;
