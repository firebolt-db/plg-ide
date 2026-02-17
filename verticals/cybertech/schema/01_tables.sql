-- CyberTech Vertical Schema
-- Multi-cloud security audit logs (AWS CloudTrail, Azure Activity, GCP Audit)
-- Aligned with cyber-demo-blog for anomaly detection demos

-- =============================================================================
-- AWS CLOUDTRAIL EVENTS
-- =============================================================================
CREATE TABLE IF NOT EXISTS events (
    event_time TEXT NULL,
    event_name TEXT NULL,
    event_source TEXT NULL,
    username TEXT NULL,
    source_ip TEXT NULL,
    instance_id TEXT NULL,
    current_state TEXT NULL,
    previous_state TEXT NULL,
    src TEXT NULL
) PRIMARY INDEX event_name, username, event_time;

-- =============================================================================
-- AZURE ACTIVITY LOG EVENTS (multi-cloud demo)
-- =============================================================================
CREATE TABLE IF NOT EXISTS azure_events (
    event_time TEXT NULL,
    event_name TEXT NULL,
    event_source TEXT NULL,
    username TEXT NULL,
    source_ip TEXT NULL,
    instance_id TEXT NULL,
    current_state TEXT NULL,
    previous_state TEXT NULL,
    src TEXT NULL
) PRIMARY INDEX event_name, username, event_time;

-- =============================================================================
-- GCP AUDIT LOG EVENTS (multi-cloud demo)
-- =============================================================================
CREATE TABLE IF NOT EXISTS gcp_events (
    event_time TEXT NULL,
    event_name TEXT NULL,
    event_source TEXT NULL,
    username TEXT NULL,
    source_ip TEXT NULL,
    instance_id TEXT NULL,
    current_state TEXT NULL,
    previous_state TEXT NULL,
    src TEXT NULL
) PRIMARY INDEX event_name, username, event_time;

-- =============================================================================
-- VERIFICATION
-- =============================================================================
SHOW TABLES;
