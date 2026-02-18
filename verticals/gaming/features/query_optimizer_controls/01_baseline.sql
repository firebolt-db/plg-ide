-- Query Optimizer Controls Demo: Baseline (cost-based optimizer)
-- Run a join with the default cost-based optimizer. The planner may reorder
-- joins. Note the query plan and time; then run 02_set_user_guided.sql
-- and 03_optimized.sql to compare with user_guided mode.

SET enable_result_cache = FALSE;

-- Join playstats with games. Default optimizer chooses join order.
SELECT
    g.title,
    AVG(p.currentscore) AS avg_score,
    COUNT(*) AS events
FROM playstats p
JOIN games g ON p.gameid = g.gameid
WHERE p.gameid = 1
GROUP BY g.title;

-- Optional: see the plan (cost-based join order)
-- EXPLAIN (LOGICAL) SELECT g.title, AVG(p.currentscore) AS avg_score, COUNT(*) AS events
-- FROM playstats p JOIN games g ON p.gameid = g.gameid WHERE p.gameid = 1 GROUP BY g.title;
