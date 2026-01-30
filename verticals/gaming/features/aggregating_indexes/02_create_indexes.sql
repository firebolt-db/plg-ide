-- Aggregating Indexes Demo: Create Indexes
-- These indexes pre-compute aggregations for common query patterns

-- =============================================================================
-- INDEX 1: Leaderboard Aggregating Index
-- Optimizes: Tournament leaderboard queries
-- Groups by: tournament_id, game_id, player_id
-- =============================================================================

CREATE AGGREGATING INDEX IF NOT EXISTS playstats_leaderboard_agg
ON playstats (
    -- Grouping columns (dimensions)
    tournament_id,
    game_id,
    player_id,
    -- Aggregation functions (measures)
    AVG(current_score),
    SUM(current_play_time),
    MAX(current_level),
    COUNT(*)
);

-- =============================================================================
-- INDEX 2: Daily Metrics Aggregating Index
-- Optimizes: DAU/MAU and daily analytics queries
-- Groups by: game_id, day (date truncated)
-- =============================================================================

CREATE AGGREGATING INDEX IF NOT EXISTS playstats_daily_agg
ON playstats (
    -- Grouping columns
    game_id,
    DATE_TRUNC('day', stat_time),
    -- Aggregation functions
    SUM(current_play_time),
    AVG(current_score),
    COUNT(DISTINCT player_id),
    COUNT(*)
);

-- =============================================================================
-- INDEX 3: Player Statistics Aggregating Index
-- Optimizes: Player profile and history queries
-- Groups by: player_id, game_id
-- =============================================================================

CREATE AGGREGATING INDEX IF NOT EXISTS playstats_player_agg
ON playstats (
    -- Grouping columns
    player_id,
    game_id,
    -- Aggregation functions
    AVG(current_score),
    SUM(current_play_time),
    MAX(current_level),
    MIN(stat_time),
    MAX(stat_time),
    COUNT(*)
);

-- =============================================================================
-- INDEX 4: Tournament Overview Aggregating Index
-- Optimizes: Tournament summary and analytics queries
-- Groups by: tournament_id, game_id
-- =============================================================================

CREATE AGGREGATING INDEX IF NOT EXISTS playstats_tournament_agg
ON playstats (
    -- Grouping columns
    tournament_id,
    game_id,
    -- Aggregation functions
    AVG(current_score),
    MAX(current_score),
    SUM(current_play_time),
    COUNT(DISTINCT player_id),
    COUNT(*)
);

-- =============================================================================
-- VERIFICATION
-- =============================================================================

-- Show all indexes on playstats
SHOW INDEXES ON playstats;

-- Check index sizes (when available)
SELECT 
    index_name,
    table_name,
    index_type
FROM information_schema.indexes
WHERE table_name = 'playstats'
ORDER BY index_name;
