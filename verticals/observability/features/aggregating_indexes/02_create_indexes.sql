-- Aggregating Indexes Demo: Create Indexes (Observability)

CREATE AGGREGATING INDEX IF NOT EXISTS logs_service_daily_agg
ON logs (
    service_id,
    DATE_TRUNC('day', timestamp),
    level,
    COUNT(*),
    COUNT(DISTINCT endpoint_id),
    AVG(duration_ms)
);

CREATE AGGREGATING INDEX IF NOT EXISTS logs_endpoint_hourly_agg
ON logs (
    endpoint_id,
    DATE_TRUNC('hour', timestamp),
    COUNT(*),
    AVG(duration_ms)
);

SHOW INDEXES ON logs;
