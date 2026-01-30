-- Gaming Vertical Data Loading
-- Loads Ultra Fast Gaming dataset from Firebolt's public S3 bucket

-- =============================================================================
-- IMPORTANT: S3 access requires Firebolt Cloud or configured S3 credentials
-- For Firebolt Core, use the sample data generator instead
-- =============================================================================

-- Load Players (dimension table)
COPY INTO players FROM 
    's3://firebolt-sample-datasets-public-us-east-1/gaming/parquet/players/'
    WITH 
        PATTERN = '*.snappy.parquet'
        TYPE = PARQUET;

-- Load Games (dimension table)
COPY INTO games FROM 
    's3://firebolt-sample-datasets-public-us-east-1/gaming/parquet/games/'
    WITH 
        PATTERN = '*.snappy.parquet'
        TYPE = PARQUET;

-- Load Tournaments (dimension table)
COPY INTO tournaments FROM 
    's3://firebolt-sample-datasets-public-us-east-1/gaming/parquet/tournaments/'
    WITH 
        PATTERN = '*.snappy.parquet'
        TYPE = PARQUET;

-- Load PlayStats (fact table - this is the big one)
COPY INTO playstats FROM 
    's3://firebolt-sample-datasets-public-us-east-1/gaming/parquet/playstats/'
    WITH 
        PATTERN = '*.snappy.parquet'
        TYPE = PARQUET;

-- =============================================================================
-- VERIFICATION
-- =============================================================================

-- Check row counts
SELECT 'players' as table_name, COUNT(*) as row_count FROM players
UNION ALL
SELECT 'games', COUNT(*) FROM games
UNION ALL
SELECT 'tournaments', COUNT(*) FROM tournaments
UNION ALL
SELECT 'playstats', COUNT(*) FROM playstats;

-- Check playstats date range
SELECT 
    MIN(stat_time) as earliest,
    MAX(stat_time) as latest,
    COUNT(DISTINCT player_id) as unique_players,
    COUNT(DISTINCT game_id) as unique_games
FROM playstats;
