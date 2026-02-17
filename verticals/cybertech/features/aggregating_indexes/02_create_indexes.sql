-- Aggregating Indexes Demo: Create Indexes (CyberTech)
-- Pre-compute hourly event counts per user for anomaly detection queries
-- event_name as leading column enables index use when filtering by event type

-- =============================================================================
-- INDEX 1: AWS CloudTrail - Hourly Deletes
-- Optimizes: Anomaly detection on AWS DeleteInstance events
-- Groups by: event_name, hour, username (query filters event_name = 'DeleteInstance')
-- =============================================================================

CREATE AGGREGATING INDEX IF NOT EXISTS aws_hourly_deletes_idx ON events (
    event_name,
    DATE_TRUNC('hour', event_time::timestamp),
    username,
    COUNT(*)
);

-- =============================================================================
-- INDEX 2: Azure Activity - Hourly Deletes
-- Optimizes: Anomaly detection on Azure delete operations
-- Groups by: event_name, hour, username (query filters event_name ILIKE '%delete%')
-- =============================================================================

CREATE AGGREGATING INDEX IF NOT EXISTS azure_hourly_deletes_idx ON azure_events (
    event_name,
    DATE_TRUNC('hour', event_time::timestamp),
    username,
    COUNT(*)
);

-- =============================================================================
-- INDEX 3: GCP Audit - Hourly Deletes
-- Optimizes: Anomaly detection on GCP delete operations
-- Groups by: event_name, hour, username (query filters event_name ILIKE '%delete%')
-- =============================================================================

CREATE AGGREGATING INDEX IF NOT EXISTS gcp_hourly_deletes_idx ON gcp_events (
    event_name,
    DATE_TRUNC('hour', event_time::timestamp),
    username,
    COUNT(*)
);

-- =============================================================================
-- VERIFICATION
-- =============================================================================

SHOW INDEXES ON events;
SHOW INDEXES ON azure_events;
SHOW INDEXES ON gcp_events;
