-- Cross-Region Data Access Demo (Cloud only): Enable cross-region COPY
-- When connected to Firebolt Cloud, set CROSS_REGION_REQUEST_MODE to read
-- from S3 in a different region. On Core, this is shown as reference only.

-- COPY with cross-region enabled (Cloud)
-- COPY INTO orders FROM 's3://bucket-in-other-region/orders/'
-- WITH (
--   TYPE = PARQUET,
--   CROSS_REGION_REQUEST_MODE = 'auto'  -- or 'enforced'
-- );

-- Modes: disabled (default), auto, enforced.
