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
    player_id,
    AVG(current_score) as avg_score,
    SUM(current_play_time) as total_time,
    MAX(current_level) as max_level,
    COUNT(*) as events
FROM playstats
WHERE tournament_id = 1 
  AND game_id = 1
GROUP BY player_id
ORDER BY avg_score DESC
LIMIT 100;

-- =============================================================================
-- QUERY 2: Daily Active Users (NOW FAST!)
-- Reads from: playstats_daily_agg
-- Expected: ~74X faster
-- =============================================================================

EXPLAIN ANALYZE
SELECT 
    DATE_TRUNC('day', stat_time) as day,
    game_id,
    COUNT(DISTINCT player_id) as dau,
    SUM(current_play_time) as total_play_time,
    AVG(current_score) as avg_score,
    COUNT(*) as total_events
FROM playstats
WHERE stat_time >= CURRENT_DATE - INTERVAL '30 days'
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
    game_id,
    AVG(current_score) as avg_score,
    SUM(current_play_time) as total_time,
    MAX(current_level) as max_level,
    MIN(stat_time) as first_played,
    MAX(stat_time) as last_played,
    COUNT(*) as total_sessions
FROM playstats
WHERE player_id = 42
GROUP BY game_id
ORDER BY total_time DESC;

-- =============================================================================
-- QUERY 4: Tournament Overview Statistics (NOW FAST!)
-- Reads from: playstats_tournament_agg
-- Expected: ~50X faster
-- =============================================================================

EXPLAIN ANALYZE
SELECT 
    tournament_id,
    game_id,
    COUNT(DISTINCT player_id) as unique_players,
    AVG(current_score) as avg_score,
    MAX(current_score) as high_score,
    SUM(current_play_time) as total_play_time,
    COUNT(*) as total_events
FROM playstats
GROUP BY tournament_id, game_id
ORDER BY total_events DESC
LIMIT 50;

-- Re-enable cache
SET enable_result_cache = TRUE;

-- =============================================================================
-- VERIFICATION: Confirm indexes are being used
-- Look for "AggregatingIndex" in the explain output above
-- =============================================================================
