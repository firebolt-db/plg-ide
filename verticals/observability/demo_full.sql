-- =============================================================================
-- FIREBOLT plg-ide: Observability / Log Analytics Demo
-- =============================================================================
--
-- TARGET DATABASE: observability
-- Run schema/01_tables.sql and data/load.sql first.
--
-- FOR PRESENTERS:
-- "TLDCRM replaced DataDog with Firebolt at 8M requests/day. Aggregating
--  indexes pre-compute metrics by service, endpoint, and time bucket so
--  dashboards and alerting stay fast at scale."
-- =============================================================================

SELECT version() AS firebolt_version;
CREATE DATABASE IF NOT EXISTS observability;
USE DATABASE observability;

SELECT 'Connection successful!' AS status, CURRENT_DATABASE() AS database_name;

SELECT 'logs' AS table_name, COUNT(*) AS row_count FROM logs
UNION ALL SELECT 'metrics', COUNT(*) FROM metrics
UNION ALL SELECT 'services', COUNT(*) FROM services;

SET enable_result_cache = FALSE;

-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║                   BASELINE: Log Metrics (SLOW)                            ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

SELECT '>>> BASELINE: Log Count by Service and Day <<<' AS query_name;

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

SELECT '>>> BASELINE: Error Rate by Service <<<' AS query_name;

EXPLAIN ANALYZE
SELECT 
    service_id,
    COUNT(*) FILTER (WHERE level = 'ERROR') AS error_count,
    COUNT(*) AS total_count,
    COUNT(*) FILTER (WHERE level = 'ERROR') * 100.0 / NULLIF(COUNT(*), 0) AS error_rate_pct
FROM logs
WHERE timestamp >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY service_id
ORDER BY error_count DESC
LIMIT 50;


-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║             ENABLE: Aggregating Indexes on logs                            ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

CREATE AGGREGATING INDEX IF NOT EXISTS logs_service_daily_agg
ON logs (
    service_id,
    DATE_TRUNC('day', timestamp),
    level,
    COUNT(*),
    COUNT(DISTINCT endpoint_id),
    AVG(duration_ms)
);

CREATE AGGREGATING INDEX IF NOT EXISTS logs_service_level_agg
ON logs (
    service_id,
    DATE_TRUNC('day', timestamp),
    COUNT(*)
);

SHOW INDEXES ON logs;


-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║                  OPTIMIZED: Same Queries (FAST!)                         ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

SELECT '>>> OPTIMIZED: Log Count by Service and Day <<<' AS query_name;

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

SELECT '>>> OPTIMIZED: Error Rate by Service <<<' AS query_name;

EXPLAIN ANALYZE
SELECT 
    service_id,
    COUNT(*) FILTER (WHERE level = 'ERROR') AS error_count,
    COUNT(*) AS total_count,
    COUNT(*) FILTER (WHERE level = 'ERROR') * 100.0 / NULLIF(COUNT(*), 0) AS error_rate_pct
FROM logs
WHERE timestamp >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY service_id
ORDER BY error_count DESC
LIMIT 50;

SET enable_result_cache = TRUE;

SELECT 'Observability demo complete! Compare baseline vs optimized timings above.' AS status;
