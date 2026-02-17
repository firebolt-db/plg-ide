-- Aggregating Indexes Demo: Baseline Queries (CyberTech)
-- These queries run WITHOUT aggregating indexes (full table scans)
-- Use case: Multi-cloud anomaly detection (hourly deletes per user)

-- Disable result cache for accurate timing
SET enable_result_cache = FALSE;

-- =============================================================================
-- QUERY 1: AWS - Hourly Delete Events per User
-- Without index: Full scan of events table filtering for DeleteInstance
-- Anomaly detection baseline: users with unusually high delete counts
-- =============================================================================

EXPLAIN ANALYZE
SELECT
    DATE_TRUNC('hour', event_time::timestamp) AS hour,
    username,
    COUNT(*) AS deletes
FROM events
WHERE event_name = 'DeleteInstance'
GROUP BY 1, 2
ORDER BY deletes DESC
LIMIT 20;

-- =============================================================================
-- QUERY 2: Azure - Hourly Delete Events per User
-- Without index: Full scan of azure_events filtering for delete operations
-- =============================================================================

EXPLAIN ANALYZE
SELECT
    DATE_TRUNC('hour', event_time::timestamp) AS hour,
    username,
    COUNT(*) AS deletes
FROM azure_events
WHERE event_name ILIKE '%delete%'
GROUP BY 1, 2
ORDER BY deletes DESC
LIMIT 20;

-- =============================================================================
-- QUERY 3: GCP - Hourly Delete Events per User
-- Without index: Full scan of gcp_events filtering for delete operations
-- =============================================================================

EXPLAIN ANALYZE
SELECT
    DATE_TRUNC('hour', event_time::timestamp) AS hour,
    username,
    COUNT(*) AS deletes
FROM gcp_events
WHERE event_name ILIKE '%delete%'
GROUP BY 1, 2
ORDER BY deletes DESC
LIMIT 20;

-- =============================================================================
-- QUERY 4: Cross-Cloud Anomaly Summary
-- Without index: Union of three full scans
-- =============================================================================

EXPLAIN ANALYZE
SELECT
    'AWS' AS cloud,
    username,
    COUNT(*) AS delete_count
FROM events
WHERE event_name = 'DeleteInstance'
GROUP BY username
UNION ALL
SELECT 'Azure', username, COUNT(*)
FROM azure_events
WHERE event_name ILIKE '%delete%'
GROUP BY username
UNION ALL
SELECT 'GCP', username, COUNT(*)
FROM gcp_events
WHERE event_name ILIKE '%delete%'
GROUP BY username
ORDER BY delete_count DESC
LIMIT 30;
