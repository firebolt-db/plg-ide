-- Automated Column Statistics Demo: Same query with statistics enabled
-- Same query as 01_baseline.sql. With column statistics, the optimizer
-- knows that filtering playstats by gameid leaves many rows (few distinct
-- gameids), so it chooses a better join order (e.g. build from games,
-- probe from filtered playstats). Compare query time to baseline.

SET enable_result_cache = FALSE;

SELECT
    g.title,
    AVG(p.currentscore) AS avg_score,
    COUNT(*) AS events
FROM playstats p
JOIN games g ON p.gameid = g.gameid
WHERE p.gameid = 1
GROUP BY g.title;

-- Optional: see improved cardinality estimates in the plan
-- EXPLAIN (STATISTICS) SELECT g.title, AVG(p.currentscore) AS avg_score, COUNT(*) AS events
-- FROM playstats p JOIN games g ON p.gameid = g.gameid WHERE p.gameid = 1 GROUP BY g.title;
