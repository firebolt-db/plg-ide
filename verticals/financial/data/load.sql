-- Financial Services Vertical Data Loading
-- Generates sample financial services data for demos

-- =============================================================================
-- Generate sample data via SQL (works everywhere)
-- =============================================================================
-- Creates: 100K customers, 500K accounts, 10M transactions, 10K portfolios
-- Approximate load time: 30-120 seconds depending on engine size

-- Insert sample customers
INSERT INTO customers (customer_id, first_name, last_name, email, registration_date, risk_tier, kyc_status, country)
SELECT 
    seq AS customer_id,
    'Customer' AS first_name,
    seq::TEXT AS last_name,
    'customer_' || seq::TEXT || '@bank.com' AS email,
    DATE '2020-01-01' + (seq % 1825) AS registration_date,
    CASE seq % 3 
        WHEN 0 THEN 'low' WHEN 1 THEN 'medium' ELSE 'high' 
    END AS risk_tier,
    CASE seq % 100 
        WHEN 0 THEN 'pending' WHEN 1 THEN 'rejected' ELSE 'verified' 
    END AS kyc_status,
    CASE seq % 10 
        WHEN 0 THEN 'USA' WHEN 1 THEN 'UK' WHEN 2 THEN 'Germany' 
        WHEN 3 THEN 'France' WHEN 4 THEN 'Canada' WHEN 5 THEN 'Australia'
        WHEN 6 THEN 'Japan' WHEN 7 THEN 'Brazil' WHEN 8 THEN 'India' 
        ELSE 'Spain' 
    END AS country
FROM generate_series(1, 100000) AS t(seq);

-- Insert sample merchants
INSERT INTO merchants (merchant_id, merchant_name, category, risk_score)
SELECT 
    seq AS merchant_id,
    'Merchant_' || seq::TEXT AS merchant_name,
    CASE seq % 5 
        WHEN 0 THEN 'retail' WHEN 1 THEN 'restaurant' WHEN 2 THEN 'gas' 
        WHEN 3 THEN 'online' ELSE 'atm' 
    END AS category,
    (1.0 + (seq % 50) / 10.0)::DECIMAL(5,2) AS risk_score
FROM generate_series(1, 10000) AS t(seq);

-- Insert sample securities
INSERT INTO securities (security_id, symbol, name, asset_class, exchange, sector)
SELECT 
    seq AS security_id,
    'SYM' || LPAD(seq::TEXT, 4, '0') AS symbol,
    'Security_' || seq::TEXT AS name,
    CASE seq % 4 
        WHEN 0 THEN 'equity' WHEN 1 THEN 'bond' WHEN 2 THEN 'commodity' 
        ELSE 'crypto' 
    END AS asset_class,
    CASE seq % 5 
        WHEN 0 THEN 'NYSE' WHEN 1 THEN 'NASDAQ' WHEN 2 THEN 'LSE' 
        WHEN 3 THEN 'TSE' ELSE 'OTC' 
    END AS exchange,
    'Sector_' || (seq % 10)::TEXT AS sector
FROM generate_series(1, 10000) AS t(seq);

-- Insert sample accounts
INSERT INTO accounts (account_id, customer_id, account_type, balance, currency, opened_date, status)
SELECT 
    seq AS account_id,
    (seq % 100000) + 1 AS customer_id,
    CASE seq % 4 
        WHEN 0 THEN 'checking' WHEN 1 THEN 'savings' WHEN 2 THEN 'investment' 
        ELSE 'credit' 
    END AS account_type,
    (1000 + (seq % 100000))::DECIMAL(15,2) AS balance,
    CASE seq % 5 
        WHEN 0 THEN 'USD' WHEN 1 THEN 'EUR' WHEN 2 THEN 'GBP' 
        WHEN 3 THEN 'JPY' ELSE 'CAD' 
    END AS currency,
    DATE '2020-01-01' + (seq % 1825) AS opened_date,
    CASE seq % 100 
        WHEN 0 THEN 'closed' WHEN 1 THEN 'frozen' ELSE 'active' 
    END AS status
FROM generate_series(1, 500000) AS t(seq);

-- Insert sample transactions (the high-volume table - 10M rows)
INSERT INTO transactions (transaction_id, account_id, merchant_id, timestamp, amount, currency, transaction_type, category, risk_score, status, location_country, device_type, fraud_flag)
SELECT 
    seq AS transaction_id,
    (seq % 500000) + 1 AS account_id,
    (seq % 10000) + 1 AS merchant_id,
    TIMESTAMP '2024-01-01 00:00:00' + INTERVAL '1 second' * seq AS timestamp,
    (10 + (seq % 1000))::DECIMAL(15,2) AS amount,
    CASE seq % 5 
        WHEN 0 THEN 'USD' WHEN 1 THEN 'EUR' WHEN 2 THEN 'GBP' 
        WHEN 3 THEN 'JPY' ELSE 'CAD' 
    END AS currency,
    CASE seq % 4 
        WHEN 0 THEN 'debit' WHEN 1 THEN 'credit' WHEN 2 THEN 'transfer' 
        ELSE 'withdrawal' 
    END AS transaction_type,
    CASE seq % 5 
        WHEN 0 THEN 'groceries' WHEN 1 THEN 'gas' WHEN 2 THEN 'dining' 
        WHEN 3 THEN 'shopping' ELSE 'atm' 
    END AS category,
    (1.0 + (seq % 50) / 10.0)::DECIMAL(5,2) AS risk_score,
    CASE seq % 100 
        WHEN 0 THEN 'failed' WHEN 1 THEN 'reversed' WHEN 2 THEN 'pending' 
        ELSE 'completed' 
    END AS status,
    CASE seq % 10 
        WHEN 0 THEN 'USA' WHEN 1 THEN 'UK' WHEN 2 THEN 'Germany' 
        WHEN 3 THEN 'France' WHEN 4 THEN 'Canada' WHEN 5 THEN 'Australia'
        WHEN 6 THEN 'Japan' WHEN 7 THEN 'Brazil' WHEN 8 THEN 'India' 
        ELSE 'Spain' 
    END AS location_country,
    CASE seq % 3 
        WHEN 0 THEN 'mobile' WHEN 1 THEN 'desktop' ELSE 'card' 
    END AS device_type,
    (seq % 1000) = 0 AS fraud_flag
FROM generate_series(1, 10000000) AS t(seq);

-- Insert sample portfolios
INSERT INTO portfolios (portfolio_id, customer_id, portfolio_name, total_value, last_updated)
SELECT 
    seq AS portfolio_id,
    (seq % 100000) + 1 AS customer_id,
    'Portfolio_' || seq::TEXT AS portfolio_name,
    (10000 + (seq % 1000000))::DECIMAL(15,2) AS total_value,
    TIMESTAMP '2024-01-01 00:00:00' + INTERVAL '1 day' * (seq % 365) AS last_updated
FROM generate_series(1, 10000) AS t(seq);

-- =============================================================================
-- VERIFICATION
-- =============================================================================

-- Check row counts
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'merchants', COUNT(*) FROM merchants
UNION ALL
SELECT 'securities', COUNT(*) FROM securities
UNION ALL
SELECT 'accounts', COUNT(*) FROM accounts
UNION ALL
SELECT 'transactions', COUNT(*) FROM transactions
UNION ALL
SELECT 'portfolios', COUNT(*) FROM portfolios
ORDER BY table_name;

-- Check transactions date range and stats
SELECT 
    MIN(timestamp) AS earliest_transaction,
    MAX(timestamp) AS latest_transaction,
    COUNT(DISTINCT account_id) AS unique_accounts,
    COUNT(DISTINCT merchant_id) AS unique_merchants,
    SUM(amount) AS total_volume,
    COUNT(*) FILTER (WHERE fraud_flag = TRUE) AS fraud_count
FROM transactions;
