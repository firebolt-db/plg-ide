-- =============================================================================
-- FIREBOLT plg-ide: Side-by-Side Comparison Demo (impact first)
-- =============================================================================
--
-- Design: Show the wow (fast query) first, then explain, then show slow for contrast.
-- Run each section in order.
--
-- Prerequisite: Gaming tables and data (schema/01_tables.sql + data/load.sql, or demo_full.sql).
--
-- =============================================================================


-- =============================================================================
-- Setup: Tracker table + ensure index exists + disable result cache
-- =============================================================================
-- demo_progress records which steps have been run (for IDE or app progress).
-- Query progress: SELECT step_id, completed_at FROM demo_progress WHERE session_id = SESSION_USER() ORDER BY completed_at;
-- We create the index here so the first query (step 1) is fast – impact first.
-- =============================================================================

CREATE TABLE IF NOT EXISTS demo_progress (
    session_id TEXT,
    step_id TEXT,
    completed_at TIMESTAMP
);

CREATE AGGREGATING INDEX IF NOT EXISTS playstats_leaderboard_agg
ON playstats (
    tournamentid, gameid, playerid,
    AVG(currentscore), SUM(currentplaytime), MAX(currentlevel), COUNT(*)
);

SET enable_result_cache = FALSE;


-- =============================================================================
-- Step 1: Fast query (impact first)
-- =============================================================================
-- Run the leaderboard query with the aggregating index. Note how fast it is –
-- that’s the wow. Same query later without the index will be much slower.
-- -----------------------------------------------------------------------------

INSERT INTO demo_progress (session_id, step_id, completed_at) VALUES (SESSION_USER(), '1', NOW());
SELECT 
    playerid,
    AVG(currentscore) AS avg_score,
    SUM(currentplaytime) AS total_time,
    MAX(currentlevel) AS max_level,
    COUNT(*) AS events
FROM playstats
WHERE tournamentid = 1 AND gameid = 1
GROUP BY playerid
ORDER BY avg_score DESC
LIMIT 10;


-- =============================================================================
-- Step 2: Explain (dig in – why it’s fast)
-- =============================================================================
-- See how Firebolt runs this query: the plan shows use of the aggregating index
-- (pre-computed aggregates) instead of a full table scan.
-- -----------------------------------------------------------------------------

INSERT INTO demo_progress (session_id, step_id, completed_at) VALUES (SESSION_USER(), '2', NOW());
EXPLAIN (LOGICAL)
SELECT 
    playerid,
    AVG(currentscore) AS avg_score,
    SUM(currentplaytime) AS total_time,
    MAX(currentlevel) AS max_level,
    COUNT(*) AS events
FROM playstats
WHERE tournamentid = 1 AND gameid = 1
GROUP BY playerid
ORDER BY avg_score DESC
LIMIT 10;


-- =============================================================================
-- Step 3: Drop the index
-- =============================================================================
-- Remove the aggregating index so the next run of the same query does a full scan.
-- -----------------------------------------------------------------------------

INSERT INTO demo_progress (session_id, step_id, completed_at) VALUES (SESSION_USER(), '3', NOW());
DROP AGGREGATING INDEX IF EXISTS playstats_leaderboard_agg;


-- =============================================================================
-- Step 4: Same query without index (slow – the contrast)
-- =============================================================================
-- Same SELECT as step 1. Compare query time: without the index, Firebolt scans
-- raw playstats. At scale this cost grows; the index (step 1) reads pre-aggregated
-- data instead. Impact first, then you’ve seen why it matters.
-- -----------------------------------------------------------------------------

INSERT INTO demo_progress (session_id, step_id, completed_at) VALUES (SESSION_USER(), '4', NOW());
SELECT 
    playerid,
    AVG(currentscore) AS avg_score,
    SUM(currentplaytime) AS total_time,
    MAX(currentlevel) AS max_level,
    COUNT(*) AS events
FROM playstats
WHERE tournamentid = 1 AND gameid = 1
GROUP BY playerid
ORDER BY avg_score DESC
LIMIT 10;


-- =============================================================================
-- Step 5: Restore the index (optional)
-- =============================================================================
-- Re-create the index so you can run the fast query again.
-- -----------------------------------------------------------------------------

INSERT INTO demo_progress (session_id, step_id, completed_at) VALUES (SESSION_USER(), '5', NOW());
CREATE AGGREGATING INDEX IF NOT EXISTS playstats_leaderboard_agg
ON playstats (
    tournamentid, gameid, playerid,
    AVG(currentscore), SUM(currentplaytime), MAX(currentlevel), COUNT(*)
);


-- =============================================================================
-- Cleanup: re-enable result cache
-- =============================================================================
-- Restores normal cache behavior for subsequent queries.
-- =============================================================================

SET enable_result_cache = TRUE;

SELECT 'Comparison demo complete!' AS status;

-- =============================================================================
-- END OF COMPARISON DEMO
-- =============================================================================
