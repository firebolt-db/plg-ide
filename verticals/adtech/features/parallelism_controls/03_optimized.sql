-- Parallelism Controls Demo: Same query with limited threads
-- With max_threads = 4, the query uses at most 4 threads per node.
-- Compare time and behavior to 01_baseline.sql (may be slightly slower but more predictable).

SET enable_result_cache = FALSE;
SET max_threads = 4;

SELECT
    campaign_id,
    COUNT(*) AS events,
    SUM(1) AS total
FROM impressions
GROUP BY campaign_id
ORDER BY events DESC
LIMIT 10;

-- Or per-query only: SELECT ... WITH (max_threads = 4);
