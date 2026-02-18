-- Parallelism Controls Demo: Baseline (default thread count)
-- Run with default max_threads. Note query time and resource usage.
-- Then run 02_set_max_threads.sql and 03_optimized.sql to limit parallelism.

SET enable_result_cache = FALSE;

-- Aggregation over impressions (or campaigns if impressions not loaded).
SELECT
    campaign_id,
    COUNT(*) AS events,
    SUM(1) AS total
FROM impressions
GROUP BY campaign_id
ORDER BY events DESC
LIMIT 10;
