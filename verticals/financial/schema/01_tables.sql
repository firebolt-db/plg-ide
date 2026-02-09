-- Financial Services Vertical Schema
-- Financial Services Dataset Tables

-- =============================================================================
-- DIMENSION TABLES
-- =============================================================================

-- Customers table - customer accounts
CREATE TABLE IF NOT EXISTS customers (
    customer_id INT,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    registration_date DATE,
    risk_tier TEXT,         -- 'low', 'medium', 'high'
    kyc_status TEXT,        -- 'pending', 'verified', 'rejected'
    country TEXT
) PRIMARY INDEX customer_id;

-- Accounts table - bank accounts
CREATE TABLE IF NOT EXISTS accounts (
    account_id BIGINT,
    customer_id INT,
    account_type TEXT,      -- 'checking', 'savings', 'investment', 'credit'
    balance DECIMAL(15, 2),
    currency TEXT,
    opened_date DATE,
    status TEXT             -- 'active', 'closed', 'frozen'
) PRIMARY INDEX account_id;

-- Securities table - security definitions
CREATE TABLE IF NOT EXISTS securities (
    security_id INT,
    symbol TEXT,
    name TEXT,
    asset_class TEXT,       -- 'equity', 'bond', 'commodity', 'crypto'
    exchange TEXT,
    sector TEXT
) PRIMARY INDEX security_id;

-- Merchants table - merchant definitions
CREATE TABLE IF NOT EXISTS merchants (
    merchant_id INT,
    merchant_name TEXT,
    category TEXT,          -- 'retail', 'restaurant', 'gas', 'online', 'atm'
    risk_score DECIMAL(5, 2)
) PRIMARY INDEX merchant_id;

-- =============================================================================
-- FACT TABLES (HIGH VOLUME)
-- =============================================================================

-- Transactions table - transaction events (the star of the show)
-- This is where aggregating indexes provide massive value
CREATE TABLE IF NOT EXISTS transactions (
    transaction_id BIGINT,
    account_id BIGINT,
    merchant_id INT,
    timestamp TIMESTAMP,
    amount DECIMAL(15, 2),
    currency TEXT,
    transaction_type TEXT,  -- 'debit', 'credit', 'transfer', 'withdrawal'
    category TEXT,          -- 'groceries', 'gas', 'dining', 'shopping', 'atm'
    risk_score DECIMAL(5, 2),
    status TEXT,            -- 'pending', 'completed', 'failed', 'reversed'
    location_country TEXT,
    location_city TEXT,
    device_type TEXT,
    fraud_flag BOOLEAN
) PRIMARY INDEX transaction_id;

-- Portfolios table - investment portfolios
CREATE TABLE IF NOT EXISTS portfolios (
    portfolio_id INT,
    customer_id INT,
    portfolio_name TEXT,
    holdings JSON,          -- Array of {security_id, quantity, purchase_price}
    total_value DECIMAL(15, 2),
    last_updated TIMESTAMP
) PRIMARY INDEX portfolio_id;

-- =============================================================================
-- VERIFICATION
-- =============================================================================

-- Show created tables
SHOW TABLES;
