-- =============================================================================
-- FIREBOLT plg-ide: Financial Services Side-by-Side Comparison Demo
-- =============================================================================
-- Run after schema/01_tables.sql and data/load.sql.
-- VALUE: "Primer: millisecond latency. Ezora: 30X faster. Aggregating indexes
--         pre-compute transaction aggregations for risk and regulatory reporting."
-- =============================================================================

SET enable_result_cache = FALSE;

DROP AGGREGATING INDEX IF EXISTS transactions_daily_agg;
SELECT 'TRANSACTION VOLUME BY DAY - WITHOUT INDEX' AS test_name;
SELECT DATE_TRUNC('day', timestamp) AS day, transaction_type,
       COUNT(*) AS tx_count, SUM(amount) AS total_volume
FROM transactions
WHERE timestamp >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY DATE_TRUNC('day', timestamp), transaction_type
ORDER BY day DESC, total_volume DESC LIMIT 20;

CREATE AGGREGATING INDEX IF NOT EXISTS transactions_daily_agg
ON transactions (DATE_TRUNC('day', timestamp), transaction_type, COUNT(*), SUM(amount), AVG(amount));

SELECT 'TRANSACTION VOLUME BY DAY - WITH INDEX' AS test_name;
SELECT DATE_TRUNC('day', timestamp) AS day, transaction_type,
       COUNT(*) AS tx_count, SUM(amount) AS total_volume
FROM transactions
WHERE timestamp >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY DATE_TRUNC('day', timestamp), transaction_type
ORDER BY day DESC, total_volume DESC LIMIT 20;

SELECT '┌─────────────────────────────────────────────────────────────────┐' AS border
UNION ALL SELECT '│ Financial: Aggregating Indexes on transactions (daily)   │'
UNION ALL SELECT '│ Expected: 50-100X faster, 99%+ less data scanned          │'
UNION ALL SELECT '└─────────────────────────────────────────────────────────────────┘';

SET enable_result_cache = TRUE;
SELECT 'Financial comparison demo complete!' AS status;
