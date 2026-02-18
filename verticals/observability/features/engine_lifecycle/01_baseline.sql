-- Engine Lifecycle Demo (Cloud only): Inspect current engine settings
-- When connected to Firebolt Cloud, you can inspect engine configuration.
-- On Core, this is shown as reference only; run on Cloud to demo.

-- List engines and key settings (Cloud)
SELECT engine_name, region, spec, auto_stop
FROM information_schema.engines
LIMIT 5;

-- Optional: show auto_vacuum and scaling (Cloud-specific columns may vary)
-- SHOW ENGINES;
