-- Aggregating Indexes Demo: Optimized Queries (CyberTech)
-- Same queries as 01_baseline.sql - now read from aggregating indexes
-- Expected: 10-100X faster with indexes

-- Disable result cache for accurate timing
SET enable_result_cache = FALSE;

-- =============================================================================
-- QUERY 1: AWS - Hourly Delete Events per User (NOW FAST!)
-- Reads from: aws_hourly_deletes_idx
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
-- QUERY 2: Azure - Hourly Delete Events per User (NOW FAST!)
-- Reads from: azure_hourly_deletes_idx
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
-- QUERY 3: GCP - Hourly Delete Events per User (NOW FAST!)
-- Reads from: gcp_hourly_deletes_idx
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
-- QUERY 4: Cross-Cloud Anomaly Summary (NOW FAST!)
-- Reads from: all three aggregating indexes
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
