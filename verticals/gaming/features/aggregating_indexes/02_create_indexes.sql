-- Aggregating Indexes Demo: Create Indexes
-- These indexes pre-compute aggregations for common query patterns

-- =============================================================================
-- INDEX 1: Leaderboard Aggregating Index
-- Optimizes: Tournament leaderboard queries
-- Groups by: tournamentid, gameid, playerid
-- =============================================================================

CREATE AGGREGATING INDEX IF NOT EXISTS playstats_leaderboard_agg
ON playstats (
    -- Grouping columns (dimensions)
    tournamentid,
    gameid,
    playerid,
    -- Aggregation functions (measures)
    AVG(currentscore),
    SUM(currentplaytime),
    MAX(currentlevel),
    COUNT(*)
);

-- =============================================================================
-- INDEX 2: Daily Metrics Aggregating Index
-- Optimizes: DAU/MAU and daily analytics queries
-- Groups by: gameid, day (date truncated)
-- =============================================================================

CREATE AGGREGATING INDEX IF NOT EXISTS playstats_daily_agg
ON playstats (
    -- Grouping columns
    gameid,
    DATE_TRUNC('day', stattime),
    -- Aggregation functions
    SUM(currentplaytime),
    AVG(currentscore),
    COUNT(DISTINCT playerid),
    COUNT(*)
);

-- =============================================================================
-- INDEX 3: Player Statistics Aggregating Index
-- Optimizes: Player profile and history queries
-- Groups by: playerid, gameid
-- =============================================================================

CREATE AGGREGATING INDEX IF NOT EXISTS playstats_player_agg
ON playstats (
    -- Grouping columns
    playerid,
    gameid,
    -- Aggregation functions
    AVG(currentscore),
    SUM(currentplaytime),
    MAX(currentlevel),
    MIN(stattime),
    MAX(stattime),
    COUNT(*)
);

-- =============================================================================
-- INDEX 4: Tournament Overview Aggregating Index
-- Optimizes: Tournament summary and analytics queries
-- Groups by: tournamentid, gameid
-- =============================================================================

CREATE AGGREGATING INDEX IF NOT EXISTS playstats_tournament_agg
ON playstats (
    -- Grouping columns
    tournamentid,
    gameid,
    -- Aggregation functions
    AVG(currentscore),
    MAX(currentscore),
    SUM(currentplaytime),
    COUNT(DISTINCT playerid),
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
