-- Query Optimizer Controls Demo: Same query with user_guided mode
-- With optimizer_mode = 'user_guided', the join order in the SQL is preserved.
-- Compare plan and time to 01_baseline.sql. Use when you want predictable plans.

SET enable_result_cache = FALSE;
SET optimizer_mode = 'user_guided';

SELECT
    g.title,
    AVG(p.currentscore) AS avg_score,
    COUNT(*) AS events
FROM playstats p
JOIN games g ON p.gameid = g.gameid
WHERE p.gameid = 1
GROUP BY g.title;

-- Optional: use hint instead of session setting (only disables join reordering)
-- /*! no_join_ordering */
-- SELECT g.title, AVG(p.currentscore) AS avg_score, COUNT(*) AS events
-- FROM playstats p JOIN games g ON p.gameid = g.gameid WHERE p.gameid = 1 GROUP BY g.title;
