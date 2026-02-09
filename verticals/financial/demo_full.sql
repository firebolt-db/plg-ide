-- =============================================================================
-- FIREBOLT plg-ide: Financial Services Analytics Demo
-- =============================================================================
--
-- TARGET DATABASE: financial
-- Run schema/01_tables.sql and data/load.sql first.
--
-- FOR PRESENTERS:
-- "Primer achieves millisecond latency; Ezora saw 30X faster queries. Aggregating
--  indexes pre-compute transaction aggregations by account, merchant, and time
--  for real-time risk scoring and regulatory reporting."
-- =============================================================================

SELECT version() AS firebolt_version;
CREATE DATABASE IF NOT EXISTS financial;
USE DATABASE financial;

SELECT 'Connection successful!' AS status, CURRENT_DATABASE() AS database_name;

SELECT 'transactions' AS table_name, COUNT(*) AS row_count FROM transactions
UNION ALL SELECT 'accounts', COUNT(*) FROM accounts
UNION ALL SELECT 'customers', COUNT(*) FROM customers;

SET enable_result_cache = FALSE;

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║                   BASELINE: Transaction Analytics (SLOW)                  ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

SELECT '>>> BASELINE: Transaction Volume by Day <<<' AS query_name;

EXPLAIN ANALYZE
SELECT 
    DATE_TRUNC('day', timestamp) AS day,
    transaction_type,
    COUNT(*) AS tx_count,
    SUM(amount) AS total_volume,
    AVG(amount) AS avg_amount,
    COUNT(*) FILTER (WHERE fraud_flag) AS fraud_count
FROM transactions
WHERE timestamp >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE_TRUNC('day', timestamp), transaction_type
ORDER BY day DESC, total_volume DESC
LIMIT 100;

SELECT '>>> BASELINE: Merchant Performance <<<' AS query_name;

EXPLAIN ANALYZE
SELECT 
    merchant_id,
    category,
    COUNT(*) AS tx_count,
    SUM(amount) AS volume,
    AVG(risk_score) AS avg_risk_score
FROM transactions
WHERE timestamp >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY merchant_id, category
ORDER BY volume DESC
LIMIT 50;


-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║             ENABLE: Aggregating Indexes on transactions                    ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

CREATE AGGREGATING INDEX IF NOT EXISTS transactions_daily_agg
ON transactions (
    DATE_TRUNC('day', timestamp),
    transaction_type,
    COUNT(*),
    SUM(amount),
    AVG(amount)
);

CREATE AGGREGATING INDEX IF NOT EXISTS transactions_merchant_agg
ON transactions (
    merchant_id,
    category,
    DATE_TRUNC('day', timestamp),
    COUNT(*),
    SUM(amount),
    AVG(risk_score)
);

SHOW INDEXES ON transactions;


-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║                  OPTIMIZED: Same Queries (FAST!)                         ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

SELECT '>>> OPTIMIZED: Transaction Volume by Day <<<' AS query_name;

EXPLAIN ANALYZE
SELECT 
    DATE_TRUNC('day', timestamp) AS day,
    transaction_type,
    COUNT(*) AS tx_count,
    SUM(amount) AS total_volume,
    AVG(amount) AS avg_amount,
    COUNT(*) FILTER (WHERE fraud_flag) AS fraud_count
FROM transactions
WHERE timestamp >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE_TRUNC('day', timestamp), transaction_type
ORDER BY day DESC, total_volume DESC
LIMIT 100;

SELECT '>>> OPTIMIZED: Merchant Performance <<<' AS query_name;

EXPLAIN ANALYZE
SELECT 
    merchant_id,
    category,
    COUNT(*) AS tx_count,
    SUM(amount) AS volume,
    AVG(risk_score) AS avg_risk_score
FROM transactions
WHERE timestamp >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY merchant_id, category
ORDER BY volume DESC
LIMIT 50;

SET enable_result_cache = TRUE;

SELECT 'Financial demo complete! Compare baseline vs optimized timings above.' AS status;
