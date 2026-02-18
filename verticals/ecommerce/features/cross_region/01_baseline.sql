-- Cross-Region Data Access Demo (Cloud only): COPY without cross-region
-- When connected to Firebolt Cloud, COPY normally reads from S3 in the same region.
-- On Core, this is shown as reference only.

-- Standard COPY (same-region S3)
-- COPY INTO orders FROM 's3://my-bucket/orders/'
-- WITH (TYPE = PARQUET);

-- If the bucket is in another region, use 02_cross_region.sql.
