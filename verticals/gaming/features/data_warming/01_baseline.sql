-- Data Warming Demo: Cold run (no prior warm-up)
-- Run this query without warming the table. Note query time and bytes read.
-- Then run 02_warm.sql to load data into cache, then 03_optimized.sql
-- to see the same query benefit from cache.

SET enable_result_cache = FALSE;

-- Query that scans playstats. First run = cold (reads from storage).
SELECT
    gameid,
    COUNT(*) AS events,
    AVG(currentscore) AS avg_score
FROM playstats
GROUP BY gameid
ORDER BY events DESC
LIMIT 10;
