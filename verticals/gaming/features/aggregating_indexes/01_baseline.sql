-- Aggregating Indexes Demo: Baseline Queries
-- These queries run WITHOUT aggregating indexes (full table scans)

-- Disable result cache for accurate timing
SET enable_result_cache = FALSE;

-- =============================================================================
-- QUERY 1: Tournament Leaderboard
-- Show top players in a tournament, ranked by score
-- Without index: Scans ALL playstats rows for the tournament
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
-- QUERY 2: Daily Active Users (DAU)
-- Track daily player engagement for the last 30 days
-- Without index: Scans all recent playstats
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
-- QUERY 3: Player Profile Statistics
-- Show a player's performance across all games
-- Without index: Scans all playstats looking for player
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
-- QUERY 4: Tournament Overview Statistics
-- Aggregate stats per tournament
-- Without index: Full scan with tournament grouping
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
