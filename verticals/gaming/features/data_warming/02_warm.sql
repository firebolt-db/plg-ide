-- Data Warming Demo: Warm the table into cache
-- A full scan (e.g. CHECKSUM) loads table data into the engine cache.
-- After this, repeat queries often read from cache and run faster.

SET enable_result_cache = FALSE;

SELECT CHECKSUM(*) FROM playstats;

-- Optional: warm a subset by partition or filter
-- SELECT CHECKSUM(*) FROM playstats WHERE gameid = 1;
