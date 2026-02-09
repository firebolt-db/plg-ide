-- Aggregating Indexes Demo: Optimized Queries (Financial)

SET enable_result_cache = FALSE;

EXPLAIN ANALYZE
SELECT 
    DATE_TRUNC('day', timestamp) AS day,
    transaction_type,
    COUNT(*) AS tx_count,
    SUM(amount) AS total_volume,
    AVG(amount) AS avg_amount
FROM transactions
WHERE timestamp >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE_TRUNC('day', timestamp), transaction_type
ORDER BY day DESC, total_volume DESC
LIMIT 100;

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

EXPLAIN ANALYZE
SELECT 
    account_id,
    DATE_TRUNC('day', timestamp) AS day,
    COUNT(*) AS tx_count,
    SUM(amount) AS daily_volume
FROM transactions
WHERE timestamp >= CURRENT_DATE - INTERVAL '14 days'
GROUP BY account_id, DATE_TRUNC('day', timestamp)
ORDER BY day DESC, daily_volume DESC
LIMIT 100;
