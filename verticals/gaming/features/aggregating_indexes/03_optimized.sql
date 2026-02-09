-- Aggregating Indexes Demo: Optimized Queries
-- These are the SAME queries as 01_baseline.sql
-- But now they read from aggregating indexes instead of scanning the full table

-- Disable result cache for accurate timing
SET enable_result_cache = FALSE;

-- =============================================================================
-- QUERY 1: Tournament Leaderboard (NOW FAST!)
-- Reads from: playstats_leaderboard_agg
-- Expected: ~80X faster
-- =============================================================================

EXPLAIN ANALYZE
SELECT 
    playerid,
    AVG(currentscore) as avg_score,
    SUM(currentplaytime) as total_time,
    MAX(currentlevel) as max_level,
    COUNT(*) as events
FROM playstats
WHERE tournamentid = 1 
  AND gameid = 1
GROUP BY playerid
ORDER BY avg_score DESC
LIMIT 100;

-- =============================================================================
-- QUERY 2: Daily Active Users (NOW FAST!)
-- Reads from: playstats_daily_agg
-- Expected: ~74X faster
-- =============================================================================

EXPLAIN ANALYZE
SELECT 
    DATE_TRUNC('day', stattime) as day,
    gameid,
    COUNT(DISTINCT playerid) as dau,
    SUM(currentplaytime) as total_play_time,
    AVG(currentscore) as avg_score,
    COUNT(*) as total_events
FROM playstats
WHERE stattime >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY 1, 2
ORDER BY day DESC, dau DESC
LIMIT 50;

-- =============================================================================
-- QUERY 3: Player Profile Statistics (NOW FAST!)
-- Reads from: playstats_player_agg
-- Expected: ~43X faster
-- =============================================================================

EXPLAIN ANALYZE
SELECT 
    gameid,
    AVG(currentscore) as avg_score,
    SUM(currentplaytime) as total_time,
    MAX(currentlevel) as max_level,
    MIN(stattime) as first_played,
    MAX(stattime) as last_played,
    COUNT(*) as total_sessions
FROM playstats
WHERE playerid = 42
GROUP BY gameid
ORDER BY total_time DESC;

-- =============================================================================
-- QUERY 4: Tournament Overview Statistics (NOW FAST!)
-- Reads from: playstats_tournament_agg
-- Expected: ~50X faster
-- =============================================================================

EXPLAIN ANALYZE
SELECT 
    tournamentid,
    gameid,
    COUNT(DISTINCT playerid) as unique_players,
    AVG(currentscore) as avg_score,
    MAX(currentscore) as high_score,
    SUM(currentplaytime) as total_play_time,
    COUNT(*) as total_events
FROM playstats
GROUP BY tournamentid, gameid
ORDER BY total_events DESC
LIMIT 50;

-- Re-enable cache
SET enable_result_cache = TRUE;

-- =============================================================================
-- VERIFICATION: Confirm indexes are being used
-- Look for "AggregatingIndex" in the explain output above
-- =============================================================================
