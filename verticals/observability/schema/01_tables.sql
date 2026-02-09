-- Observability Vertical Schema
-- Observability/Log Analytics Dataset Tables

-- =============================================================================
-- DIMENSION TABLES
-- =============================================================================

-- Services table - microservice definitions
CREATE TABLE IF NOT EXISTS services (
    service_id INT,
    service_name TEXT,
    team TEXT,
    environment TEXT,       -- 'production', 'staging', 'development'
    version TEXT,
    language TEXT           -- 'python', 'java', 'go', 'node'
) PRIMARY INDEX service_id;

-- Endpoints table - API endpoints
CREATE TABLE IF NOT EXISTS endpoints (
    endpoint_id INT,
    service_id INT,
    path TEXT,
    method TEXT,            -- 'GET', 'POST', 'PUT', 'DELETE'
    route_pattern TEXT
) PRIMARY INDEX endpoint_id;

-- =============================================================================
-- FACT TABLES (HIGH VOLUME)
-- =============================================================================

-- Logs table - log events (the star of the show)
-- This is where aggregating indexes provide massive value
CREATE TABLE IF NOT EXISTS logs (
    log_id BIGINT,
    service_id INT,
    endpoint_id INT,
    timestamp TIMESTAMP,
    level TEXT,            -- 'DEBUG', 'INFO', 'WARN', 'ERROR', 'FATAL'
    message TEXT,
    trace_id TEXT,
    span_id TEXT,
    user_id TEXT,
    request_id TEXT,
    status_code INT,
    duration_ms INT,
    metadata JSON
) PRIMARY INDEX log_id;

-- Metrics table - time-series metrics
CREATE TABLE IF NOT EXISTS metrics (
    metric_id BIGINT,
    service_id INT,
    timestamp TIMESTAMP,
    metric_name TEXT,      -- 'request_count', 'error_count', 'latency_ms'
    value DECIMAL(15, 4),
    tags JSON,
    unit TEXT             -- 'count', 'ms', 'bytes', 'percent'
) PRIMARY INDEX metric_id;

-- Traces table - distributed trace spans
CREATE TABLE IF NOT EXISTS traces (
    trace_id TEXT,
    span_id TEXT,
    service_id INT,
    parent_span_id TEXT,
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    duration_ms INT,
    operation_name TEXT,
    status TEXT,          -- 'ok', 'error'
    tags JSON,
    logs JSON[]
) PRIMARY INDEX (trace_id, span_id);

-- =============================================================================
-- VERIFICATION
-- =============================================================================

-- Show created tables
SHOW TABLES;
