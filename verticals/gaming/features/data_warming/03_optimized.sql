-- Data Warming Demo: Same query after warm-up
-- Run after 02_warm.sql. Data is in cache; this run typically shows
-- lower bytes read from storage and faster time than 01_baseline.sql.

SET enable_result_cache = FALSE;

SELECT
    gameid,
    COUNT(*) AS events,
    AVG(currentscore) AS avg_score
FROM playstats
GROUP BY gameid
ORDER BY events DESC
LIMIT 10;
