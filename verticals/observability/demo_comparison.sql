-- =============================================================================
-- FIREBOLT plg-ide: Observability Side-by-Side Comparison Demo
-- =============================================================================
-- Run after schema/01_tables.sql and data/load.sql.
-- VALUE: "TLDCRM replaced DataDog at 8M requests/day. Aggregating indexes
--         pre-compute metrics by service/endpoint/time for fast dashboards."
-- =============================================================================

SET enable_result_cache = FALSE;

DROP AGGREGATING INDEX IF EXISTS logs_service_daily_agg;
SELECT 'LOGS BY SERVICE/DAY - WITHOUT INDEX' AS test_name;
SELECT service_id, DATE_TRUNC('day', timestamp) AS day,
       COUNT(*) AS log_count, AVG(duration_ms) AS avg_duration_ms
FROM logs
WHERE timestamp >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY service_id, DATE_TRUNC('day', timestamp)
ORDER BY day DESC, log_count DESC LIMIT 20;

CREATE AGGREGATING INDEX IF NOT EXISTS logs_service_daily_agg
ON logs (service_id, DATE_TRUNC('day', timestamp), level, COUNT(*), COUNT(DISTINCT endpoint_id), AVG(duration_ms));

SELECT 'LOGS BY SERVICE/DAY - WITH INDEX' AS test_name;
SELECT service_id, DATE_TRUNC('day', timestamp) AS day,
       COUNT(*) AS log_count, AVG(duration_ms) AS avg_duration_ms
FROM logs
WHERE timestamp >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY service_id, DATE_TRUNC('day', timestamp)
ORDER BY day DESC, log_count DESC LIMIT 20;

SELECT 'Observability comparison demo complete!' AS status;
SET enable_result_cache = TRUE;
