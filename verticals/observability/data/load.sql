-- Observability Vertical Data Loading
-- Generates sample observability data for demos

-- =============================================================================
-- Generate sample data via SQL (works everywhere)
-- =============================================================================
-- Creates: 1K services, 10K endpoints, 10M logs, 1M metrics, 5M traces
-- Approximate load time: 30-120 seconds depending on engine size

-- Insert sample services
INSERT INTO services (service_id, service_name, team, environment, version, language)
SELECT 
    seq AS service_id,
    'service_' || seq::TEXT AS service_name,
    'team_' || (seq % 20)::TEXT AS team,
    CASE seq % 3 
        WHEN 0 THEN 'production' WHEN 1 THEN 'staging' ELSE 'development' 
    END AS environment,
    'v' || (seq % 10)::TEXT || '.' || (seq % 5)::TEXT || '.' || (seq % 10)::TEXT AS version,
    CASE seq % 5 
        WHEN 0 THEN 'python' WHEN 1 THEN 'java' WHEN 2 THEN 'go' 
        WHEN 3 THEN 'node' ELSE 'rust' 
    END AS language
FROM generate_series(1, 1000) AS t(seq);

-- Insert sample endpoints
INSERT INTO endpoints (endpoint_id, service_id, path, method, route_pattern)
SELECT 
    seq AS endpoint_id,
    (seq % 1000) + 1 AS service_id,
    '/api/v' || (seq % 3)::TEXT || '/endpoint/' || seq::TEXT AS path,
    CASE seq % 4 
        WHEN 0 THEN 'GET' WHEN 1 THEN 'POST' WHEN 2 THEN 'PUT' 
        ELSE 'DELETE' 
    END AS method,
    '/api/v*/endpoint/*' AS route_pattern
FROM generate_series(1, 10000) AS t(seq);

-- Insert sample logs (the high-volume table - 10M rows)
INSERT INTO logs (log_id, service_id, endpoint_id, timestamp, level, message, trace_id, span_id, status_code, duration_ms)
SELECT 
    seq AS log_id,
    (seq % 1000) + 1 AS service_id,
    (seq % 10000) + 1 AS endpoint_id,
    TIMESTAMP '2024-01-01 00:00:00' + INTERVAL '1 millisecond' * seq AS timestamp,
    CASE seq % 100 
        WHEN 0 THEN 'ERROR' WHEN 1 THEN 'WARN' WHEN 2 THEN 'DEBUG' 
        ELSE 'INFO' 
    END AS level,
    CASE seq % 100 
        WHEN 0 THEN 'Error processing request: ' || seq::TEXT
        WHEN 1 THEN 'Warning: Slow query detected: ' || seq::TEXT
        WHEN 2 THEN 'Debug: Processing step ' || seq::TEXT
        ELSE 'Info: Request processed successfully: ' || seq::TEXT
    END AS message,
    'trace_' || (seq % 100000)::TEXT AS trace_id,
    'span_' || seq::TEXT AS span_id,
    CASE seq % 100 
        WHEN 0 THEN 500
        WHEN 1 THEN 404
        WHEN 2 THEN 403
        ELSE 200
    END AS status_code,
    (10 + (seq % 1000)) AS duration_ms
FROM generate_series(1, 10000000) AS t(seq);

-- Insert sample metrics (1M rows)
INSERT INTO metrics (metric_id, service_id, timestamp, metric_name, value, unit)
SELECT 
    seq AS metric_id,
    (seq % 1000) + 1 AS service_id,
    TIMESTAMP '2024-01-01 00:00:00' + INTERVAL '1 second' * (seq % 86400) AS timestamp,
    CASE seq % 5 
        WHEN 0 THEN 'request_count'
        WHEN 1 THEN 'error_count'
        WHEN 2 THEN 'latency_ms'
        WHEN 3 THEN 'cpu_percent'
        ELSE 'memory_bytes'
    END AS metric_name,
    CASE seq % 5 
        WHEN 0 THEN (seq % 1000)::DECIMAL(15,4)
        WHEN 1 THEN (seq % 100)::DECIMAL(15,4)
        WHEN 2 THEN (10 + (seq % 500))::DECIMAL(15,4)
        WHEN 3 THEN (20 + (seq % 80))::DECIMAL(15,4)
        ELSE (1000000 + (seq % 9000000))::DECIMAL(15,4)
    END AS value,
    CASE seq % 5 
        WHEN 0 THEN 'count'
        WHEN 1 THEN 'count'
        WHEN 2 THEN 'ms'
        WHEN 3 THEN 'percent'
        ELSE 'bytes'
    END AS unit
FROM generate_series(1, 1000000) AS t(seq);

-- Insert sample traces (5M rows)
INSERT INTO traces (trace_id, span_id, service_id, parent_span_id, start_time, end_time, duration_ms, operation_name, status)
SELECT 
    'trace_' || (seq % 100000)::TEXT AS trace_id,
    'span_' || seq::TEXT AS span_id,
    (seq % 1000) + 1 AS service_id,
    CASE WHEN seq % 10 = 0 THEN NULL ELSE 'span_' || (seq - 1)::TEXT END AS parent_span_id,
    TIMESTAMP '2024-01-01 00:00:00' + INTERVAL '1 millisecond' * seq AS start_time,
    TIMESTAMP '2024-01-01 00:00:00' + INTERVAL '1 millisecond' * seq + INTERVAL '1 millisecond' * (10 + (seq % 1000)) AS end_time,
    (10 + (seq % 1000)) AS duration_ms,
    'operation_' || (seq % 100)::TEXT AS operation_name,
    CASE seq % 100 WHEN 0 THEN 'error' ELSE 'ok' END AS status
FROM generate_series(1, 5000000) AS t(seq);

-- =============================================================================
-- VERIFICATION
-- =============================================================================

-- Check row counts
SELECT 'services' AS table_name, COUNT(*) AS row_count FROM services
UNION ALL
SELECT 'endpoints', COUNT(*) FROM endpoints
UNION ALL
SELECT 'logs', COUNT(*) FROM logs
UNION ALL
SELECT 'metrics', COUNT(*) FROM metrics
UNION ALL
SELECT 'traces', COUNT(*) FROM traces
ORDER BY table_name;

-- Check logs date range and stats
SELECT 
    MIN(timestamp) AS earliest_log,
    MAX(timestamp) AS latest_log,
    COUNT(DISTINCT service_id) AS unique_services,
    COUNT(DISTINCT endpoint_id) AS unique_endpoints,
    COUNT(*) FILTER (WHERE level = 'ERROR') AS error_count,
    COUNT(*) FILTER (WHERE level = 'WARN') AS warn_count
FROM logs;
