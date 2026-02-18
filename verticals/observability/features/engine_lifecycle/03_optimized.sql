-- Engine Lifecycle Demo (Cloud only): Create engine with scaling
-- When connected to Firebolt Cloud, you can create engines with min/max clusters.
-- On Core, this is shown as reference only.

-- Example: create engine with auto-scaling (Cloud)
-- CREATE ENGINE my_engine WITH
--   MIN_CLUSTERS = 1,
--   MAX_CLUSTERS = 5,
--   AUTO_START = true;

-- After creation, queries use this engine; it scales with concurrency.
-- Idle timeout (auto-stop) is typically set in the Firebolt Cloud UI.
