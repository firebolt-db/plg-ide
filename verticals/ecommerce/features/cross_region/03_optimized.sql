-- Cross-Region Data Access Demo (Cloud only): Same COPY with cross-region
-- When connected to Firebolt Cloud, use this pattern to ingest from
-- S3 in another region. On Core, this is shown as reference only.

-- COPY INTO orders FROM 's3://bucket-in-other-region/orders/'
-- WITH (
--   TYPE = PARQUET,
--   CROSS_REGION_REQUEST_MODE = 'auto'
-- );

-- See docs/DEEP_CONTROL.md and Firebolt COPY FROM documentation.
