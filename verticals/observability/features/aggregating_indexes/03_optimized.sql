-- Aggregating Indexes Demo: Optimized Queries (Observability)

SET enable_result_cache = FALSE;

EXPLAIN ANALYZE
SELECT 
    service_id,
    DATE_TRUNC('day', timestamp) AS day,
    level,
    COUNT(*) AS log_count,
    COUNT(DISTINCT endpoint_id) AS endpoints,
    AVG(duration_ms) AS avg_duration_ms
FROM logs
WHERE timestamp >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY service_id, DATE_TRUNC('day', timestamp), level
ORDER BY day DESC, log_count DESC
LIMIT 100;

EXPLAIN ANALYZE
SELECT 
    service_id,
    COUNT(*) FILTER (WHERE level = 'ERROR') AS error_count,
    COUNT(*) AS total_count
FROM logs
WHERE timestamp >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY service_id
ORDER BY error_count DESC
LIMIT 50;

EXPLAIN ANALYZE
SELECT 
    endpoint_id,
    DATE_TRUNC('hour', timestamp) AS hour,
    COUNT(*) AS request_count,
    AVG(duration_ms) AS avg_duration_ms
FROM logs
WHERE timestamp >= CURRENT_DATE - INTERVAL '1 day'
GROUP BY endpoint_id, DATE_TRUNC('hour', timestamp)
ORDER BY hour DESC, request_count DESC
LIMIT 100;
