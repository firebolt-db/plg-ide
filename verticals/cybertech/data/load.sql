-- CyberTech Vertical Data Loading
-- Generates synthetic multi-cloud security audit events via SQL (works on Core and Cloud)

-- =============================================================================
-- OPTION A: Generate sample data via SQL (DEFAULT - works everywhere)
-- =============================================================================
-- Creates: ~100K events per table (AWS, Azure, GCP)
-- Includes DeleteInstance and similar destructive events for anomaly detection demos
-- Approximate load time: 30-90 seconds depending on engine size

-- AWS CloudTrail events
INSERT INTO events (event_time, event_name, event_source, username, source_ip, instance_id, current_state, previous_state, src)
SELECT
    TIMESTAMP '2024-01-01 00:00:00' + INTERVAL '1 second' * (seq % 2592000) AS event_time,
    CASE (seq % 12)
        WHEN 0 THEN 'DescribeInstances'
        WHEN 1 THEN 'GetObject'
        WHEN 2 THEN 'PutObject'
        WHEN 3 THEN 'ListBuckets'
        WHEN 4 THEN 'ConsoleLogin'
        WHEN 5 THEN 'StartInstances'
        WHEN 6 THEN 'StopInstances'
        WHEN 7 THEN 'RunInstances'
        WHEN 8 THEN 'DeleteInstance'
        WHEN 9 THEN 'DeleteSecurityGroup'
        WHEN 10 THEN 'DeleteObject'
        ELSE 'CreateSecurityGroup'
    END AS event_name,
    CASE (seq % 3) WHEN 0 THEN 'ec2.amazonaws.com' WHEN 1 THEN 's3.amazonaws.com' ELSE 'iam.amazonaws.com' END AS event_source,
    'user.aws_' || ((seq % 30) + 1)::TEXT AS username,
    '10.' || (seq % 256)::TEXT || '.' || ((seq * 7 % 256))::TEXT || '.' || ((seq * 13 % 254) + 1)::TEXT AS source_ip,
    'i-' || (1000 + (seq % 9000))::TEXT AS instance_id,
    NULL AS current_state,
    NULL AS previous_state,
    NULL AS src
FROM generate_series(1, 100000) AS t(seq);

-- Azure Activity Log events
INSERT INTO azure_events (event_time, event_name, event_source, username, source_ip, instance_id, current_state, previous_state, src)
SELECT
    TIMESTAMP '2024-01-01 00:00:00' + INTERVAL '1 second' * (seq % 2592000) AS event_time,
    CASE (seq % 6)
        WHEN 0 THEN 'Microsoft.Compute/virtualMachines/read'
        WHEN 1 THEN 'Microsoft.Storage/storageAccounts/read'
        WHEN 2 THEN 'Microsoft.Compute/virtualMachines/start/action'
        WHEN 3 THEN 'Microsoft.Compute/virtualMachines/deallocate/action'
        WHEN 4 THEN 'Microsoft.Compute/virtualMachines/delete'
        ELSE 'Microsoft.Storage/storageAccounts/delete'
    END AS event_name,
    'microsoft.compute' AS event_source,
    'user.azure_' || ((seq % 25) + 1)::TEXT AS username,
    '10.' || (seq % 256)::TEXT || '.' || ((seq * 11 % 256))::TEXT || '.' || ((seq * 17 % 254) + 1)::TEXT AS source_ip,
    'vm-' || (1000 + (seq % 9000))::TEXT AS instance_id,
    NULL AS current_state,
    NULL AS previous_state,
    NULL AS src
FROM generate_series(1, 100000) AS t(seq);

-- GCP Audit Log events
INSERT INTO gcp_events (event_time, event_name, event_source, username, source_ip, instance_id, current_state, previous_state, src)
SELECT
    TIMESTAMP '2024-01-01 00:00:00' + INTERVAL '1 second' * (seq % 2592000) AS event_time,
    CASE (seq % 6)
        WHEN 0 THEN 'compute.instances.get'
        WHEN 1 THEN 'storage.objects.get'
        WHEN 2 THEN 'compute.instances.start'
        WHEN 3 THEN 'compute.instances.stop'
        WHEN 4 THEN 'compute.instances.delete'
        ELSE 'storage.buckets.delete'
    END AS event_name,
    'compute.googleapis.com' AS event_source,
    'user.gcp_' || ((seq % 20) + 1)::TEXT AS username,
    '10.' || (seq % 256)::TEXT || '.' || ((seq * 19 % 256))::TEXT || '.' || ((seq * 23 % 254) + 1)::TEXT AS source_ip,
    'gce-' || (1000 + (seq % 9000))::TEXT AS instance_id,
    NULL AS current_state,
    NULL AS previous_state,
    NULL AS src
FROM generate_series(1, 100000) AS t(seq);

-- =============================================================================
-- VERIFICATION
-- =============================================================================

SELECT 'events' AS table_name, COUNT(*) AS row_count FROM events
UNION ALL SELECT 'azure_events', COUNT(*) FROM azure_events
UNION ALL SELECT 'gcp_events', COUNT(*) FROM gcp_events
ORDER BY table_name;

SELECT
    'events' AS source,
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE event_name = 'DeleteInstance') AS deletes
FROM events
UNION ALL
SELECT 'azure_events', COUNT(*), COUNT(*) FILTER (WHERE event_name ILIKE '%delete%') FROM azure_events
UNION ALL
SELECT 'gcp_events', COUNT(*), COUNT(*) FILTER (WHERE event_name ILIKE '%delete%') FROM gcp_events;

-- =============================================================================
-- OPTION B: Load from S3 Parquet (Firebolt Cloud only)
-- =============================================================================
-- If you have Parquet files from Synthetic-demo-data or cyber-demo-blog generators:
--
-- 1. Run the generators to create Parquet files and upload to your S3 bucket
-- 2. Create an external stage or use READ_PARQUET with credentials
-- 3. Replace placeholders below with your bucket and credentials
--
-- TRUNCATE TABLE events;
-- INSERT INTO events SELECT ... FROM READ_PARQUET(URL => 's3://YOUR_BUCKET/demo_cyber/', ...);
--
-- See cyber-demo-blog INSERT_STATEMENT.sql and data_generation/ for schema mapping.
-- See Synthetic-demo-data generators/cybersecurity.py for batch export.
