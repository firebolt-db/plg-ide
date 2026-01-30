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
-- QUERY 2: Daily Active Users (DAU)
-- Track daily player engagement for the last 30 days
-- Without index: Scans all recent playstats
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
-- QUERY 3: Player Profile Statistics
-- Show a player's performance across all games
-- Without index: Scans all playstats looking for player
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
-- QUERY 4: Tournament Overview Statistics
-- Aggregate stats per tournament
-- Without index: Full scan with tournament grouping
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
