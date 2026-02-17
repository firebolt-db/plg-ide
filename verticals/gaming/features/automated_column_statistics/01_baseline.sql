-- Automated Column Statistics Demo: Baseline (no statistics)
-- Join playstats with games and filter by gameid. Without column statistics,
-- the optimizer does not know that filtering by gameid leaves many rows
-- (one game has many play events), so it may choose a suboptimal join order.
-- Run this, note the query plan and time; then run 02_add_statistics.sql
-- and 03_optimized.sql to see the improvement.

SET enable_result_cache = FALSE;

-- Query: average score and event count per game title for game 1.
-- Filter playstats by gameid = 1 (low selectivity: one game, many rows).
-- Without ndistinct stats on playstats.gameid, the optimizer may assume
-- the filter is very selective and put playstats on the build side (wrong).
SELECT
    g.title,
    AVG(p.currentscore) AS avg_score,
    COUNT(*) AS events
FROM playstats p
JOIN games g ON p.gameid = g.gameid
WHERE p.gameid = 1
GROUP BY g.title;

-- Optional: see the plan and cardinality estimates (no stats yet)
-- EXPLAIN (STATISTICS) SELECT g.title, AVG(p.currentscore) AS avg_score, COUNT(*) AS events
-- FROM playstats p JOIN games g ON p.gameid = g.gameid WHERE p.gameid = 1 GROUP BY g.title;
