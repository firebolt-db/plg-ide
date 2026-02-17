-- =============================================================================
-- FIREBOLT plg-ide: Ultra Fast Gaming Demo
-- =============================================================================
-- 
-- This script demonstrates Firebolt's capabilities through a step-by-step
-- walkthrough of the Ultra Fast Gaming dataset. Run each stage sequentially
-- to experience the dramatic performance improvements from aggregating indexes.
--
-- TARGET DATABASE: ultrafast
-- EXPECTED DURATION: ~10-15 minutes
-- 
-- =============================================================================
--
-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │                         PREREQUISITES BY RUNTIME                            │
-- ├─────────────────────────────────────────────────────────────────────────────┤
-- │                                                                             │
-- │  FIREBOLT CORE (Local Docker):                                              │
-- │    ✓ Docker running with Firebolt Core container                           │
-- │    ✓ No account or credentials needed                                      │
-- │    ✓ Connect to: http://localhost:3473                                     │
-- │                                                                             │
-- │  FIREBOLT CLOUD (New Account):                                              │
-- │    1. Sign up at https://go.firebolt.io/ (free trial available)            │
-- │    2. Create an ENGINE (start with 'S' size for demos)                     │
-- │       → In UI: Engines → Create Engine → Name it → Start it                │
-- │    3. Create a DATABASE called 'ultrafast'                                 │
-- │       → In UI: Databases → Create Database → Name: ultrafast               │
-- │    4. Connect your SQL client to the engine                                │
-- │       → Use service account credentials (Govern → Service Accounts)        │
-- │                                                                             │
-- │  NOTE: The demo generates its own sample data - no external data needed!   │
-- │                                                                             │
-- └─────────────────────────────────────────────────────────────────────────────┘
--
-- =============================================================================
--
-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │                    FOR PRESENTERS: KEY TALKING POINTS                       │
-- ├─────────────────────────────────────────────────────────────────────────────┤
-- │                                                                             │
-- │  OPENING (Stage 0-2):                                                       │
-- │  "We're using a gaming analytics dataset - players, tournaments, and       │
-- │   500,000+ gameplay events. This is a realistic scale for proof-of-value." │
-- │                                                                             │
-- │  BASELINE (Stage 3):                                                        │
-- │  "Watch these queries - they're running full table scans. In production    │
-- │   with billions of rows, these would take minutes or even timeout."        │
-- │                                                                             │
-- │  THE MAGIC (Stage 4):                                                       │
-- │  "Now we create aggregating indexes. This is ONE LINE of SQL that tells    │
-- │   Firebolt: 'I care about these aggregations - pre-compute them for me.'  │
-- │   We create four indexes: leaderboards, DAU/MAU daily metrics, player     │
-- │   profiles, and tournament stats. Each accelerates different query types."│
-- │                                                                             │
-- │  THE PAYOFF (Stage 5):                                                      │
-- │  "Same queries. Same data. But now look at the timing - 50-100X faster.    │
-- │   The SQL didn't change. Firebolt just reads pre-computed answers."        │
-- │                                                                             │
-- │  THE PROOF (Stage 6):                                                       │
-- │  "Don't believe me? Watch - I'll drop the index and the query slows down.  │
-- │   Re-create it, and boom - fast again. The index IS the performance."      │
-- │                                                                             │
-- │  BUSINESS VALUE:                                                            │
-- │  • "Every byte not scanned is money saved on cloud compute"                │
-- │  • "Faster queries = more concurrent users on the same hardware"           │
-- │  • "No application changes - your existing SQL just gets faster"           │
-- │                                                                             │
-- │  COMPETITIVE ANGLE:                                                         │
-- │  • "ClickHouse requires materialized views + manual refresh"               │
-- │  • "Snowflake has no equivalent - you pay for every scan"                  │
-- │  • "BigQuery clustering helps but doesn't pre-compute aggregations"        │
-- │                                                                             │
-- └─────────────────────────────────────────────────────────────────────────────┘
--
-- =============================================================================


-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║                        STAGE 0: ENVIRONMENT SETUP                         ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝
-- Purpose: Verify connection and prepare the database
-- Run this first to ensure your environment is ready
--
-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │  FIREBOLT CLOUD USERS: Before running this stage:                          │
-- │                                                                             │
-- │  1. Ensure you have an ENGINE running (Engines → Start)                    │
-- │  2. If CREATE DATABASE fails, create 'ultrafast' database via the UI:      │
-- │     → Databases → Create Database → Name: ultrafast → Create               │
-- │  3. Then connect your SQL client to the 'ultrafast' database               │
-- │                                                                             │
-- │  FIREBOLT CORE USERS: Just run the commands below - everything works!      │
-- └─────────────────────────────────────────────────────────────────────────────┘

-- Check Firebolt version (verifies your connection is working)
SELECT version() AS firebolt_version;

-- Create database (works on Core; Cloud may require UI creation first)
CREATE DATABASE IF NOT EXISTS ultrafast;

-- Use the database
-- NOTE: In some SQL clients, you may need to reconnect with database=ultrafast
USE DATABASE ultrafast;

-- Verify connection
SELECT 
    'Connection successful!' AS status,
    CURRENT_TIMESTAMP AS connected_at,
    CURRENT_DATABASE() AS database_name;


-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║                        STAGE 1: SCHEMA CREATION                           ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝
-- Purpose: Create the tables for the gaming analytics use case
-- These represent a typical gaming platform's data model

-- -----------------------------------------------------------------------------
-- DIMENSION TABLES (aligned with Firebolt.io Ultra Fast Gaming schema)
-- -----------------------------------------------------------------------------

-- Players table - user accounts
CREATE DIMENSION TABLE IF NOT EXISTS players (
    playerid INTEGER NULL,
    nickname TEXT NULL,
    email TEXT NULL,
    agecategory TEXT NULL,
    platforms ARRAY(TEXT NULL) NULL,
    registeredon DATE NULL,
    issubscribedtonewsletter BOOLEAN NULL,
    internalprobabilitytowin DOUBLE PRECISION NULL,
    source_file_name TEXT NULL,
    source_file_timestamp TIMESTAMP NULL
) PRIMARY INDEX agecategory, registeredon;

-- Games table - game catalog
CREATE DIMENSION TABLE IF NOT EXISTS games (
    gameid INTEGER NULL,
    title TEXT NULL,
    abbreviation TEXT NULL,
    series TEXT NULL,
    version NUMERIC(10, 2) NULL,
    gamedescription TEXT NULL,
    category TEXT NULL,
    launchdate DATE NULL,
    author TEXT NULL,
    supportedplatforms ARRAY(TEXT NULL) NULL,
    gameconfiguration TEXT NULL,
    source_file_name TEXT NULL,
    source_file_timestamp TIMESTAMP NULL
) PRIMARY INDEX gameid, title;

-- Tournaments table - competitive events
CREATE DIMENSION TABLE IF NOT EXISTS tournaments (
    tournamentid INTEGER NULL,
    name TEXT NULL,
    gameid INTEGER NULL,
    totalprizedollars INTEGER NULL,
    startdatetime TIMESTAMP NULL,
    enddatetime TIMESTAMP NULL,
    rulesdefinition TEXT NULL,
    source_file_name TEXT NULL,
    source_file_timestamp TIMESTAMP NULL
) PRIMARY INDEX tournamentid;

-- -----------------------------------------------------------------------------
-- FACT TABLE (high-volume event data)
-- -----------------------------------------------------------------------------

-- PlayStats table - game play events
-- This is where aggregating indexes provide MASSIVE value
-- In production, this table often has billions of rows
CREATE TABLE IF NOT EXISTS playstats (
    gameid INTEGER NULL,
    playerid INTEGER NULL,
    stattime TIMESTAMP NULL,
    selectedcar TEXT NULL,
    currentlevel INTEGER NULL,
    currentspeed REAL NULL,
    currentplaytime BIGINT NULL,
    currentscore BIGINT NULL,
    event TEXT NULL,
    errorcode TEXT NULL,
    tournamentid INTEGER NULL,
    source_file_name TEXT NULL,
    source_file_timestamp TIMESTAMP NULL
) PRIMARY INDEX tournamentid, gameid, playerid, stattime;

-- Verify tables created
SELECT 'Schema created successfully!' AS status;
SHOW TABLES;


-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║                         STAGE 2: DATA LOADING                             ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝
-- Purpose: Load the Ultra Fast Gaming dataset
-- 
-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │  IMPORTANT: This demo uses generate_series() to create sample data.        │
-- │                                                                             │
-- │  WHY? This approach works identically on:                                   │
-- │    ✓ Firebolt Core (local Docker)                                          │
-- │    ✓ Firebolt Cloud (brand new account with no S3 setup)                   │
-- │                                                                             │
-- │  The demo creates 500K events - enough to show meaningful performance      │
-- │  differences without requiring external data sources.                       │
-- │                                                                             │
-- │  For LARGER datasets (millions/billions of rows), see OPTION B below       │
-- │  which loads from Firebolt's public S3 sample datasets.                    │
-- └─────────────────────────────────────────────────────────────────────────────┘

-- =============================================================================
-- OPTION A: Generate sample data via SQL (DEFAULT - works everywhere)
-- =============================================================================
-- Creates: 10K players, 100 games, 500 tournaments, 500K play events
-- Approximate load time: 5-30 seconds depending on engine size

-- Insert sample players (Firebolt.io schema columns)
INSERT INTO players (playerid, nickname, email, agecategory, platforms, registeredon, issubscribedtonewsletter, internalprobabilitytowin)
SELECT 
    seq AS playerid,
    'player_' || seq::TEXT AS nickname,
    'player_' || seq::TEXT || '@gaming.com' AS email,
    CASE seq % 4 WHEN 0 THEN 'junior' WHEN 1 THEN 'adult' WHEN 2 THEN 'senior' ELSE 'all' END AS agecategory,
    CASE seq % 3 WHEN 0 THEN ARRAY['pc'] WHEN 1 THEN ARRAY['console'] ELSE ARRAY['mobile'] END AS platforms,
    DATE '2023-01-01' + (seq % 365) AS registeredon,
    (seq % 2) = 0 AS issubscribedtonewsletter,
    (seq % 100) / 100.0 AS internalprobabilitytowin
FROM generate_series(1, 10000) AS t(seq);

-- Insert sample games (Firebolt.io schema columns)
INSERT INTO games (gameid, title, category, launchdate)
SELECT 
    seq AS gameid,
    'Game_' || seq::TEXT AS title,
    CASE seq % 5 WHEN 0 THEN 'Action' WHEN 1 THEN 'RPG' WHEN 2 THEN 'Strategy' WHEN 3 THEN 'Sports' ELSE 'Puzzle' END AS category,
    DATE '2020-01-01' + (seq * 30) AS launchdate
FROM generate_series(1, 100) AS t(seq);

-- Insert sample tournaments (Firebolt.io schema columns)
INSERT INTO tournaments (tournamentid, name, gameid, totalprizedollars, startdatetime, enddatetime)
SELECT 
    seq AS tournamentid,
    'Tournament_' || seq::TEXT AS name,
    (seq % 100) + 1 AS gameid,
    seq * 1000 AS totalprizedollars,
    TIMESTAMP '2024-01-01 00:00:00' + INTERVAL '1 day' * seq AS startdatetime,
    TIMESTAMP '2024-01-01 00:00:00' + INTERVAL '1 day' * seq + INTERVAL '7 days' AS enddatetime
FROM generate_series(1, 500) AS t(seq);

-- Insert sample playstats (Firebolt.io schema columns - 500K rows for demo)
INSERT INTO playstats (gameid, playerid, stattime, selectedcar, currentlevel, currentspeed, currentplaytime, currentscore, event, errorcode, tournamentid)
SELECT 
    (seq % 100) + 1 AS gameid,
    (seq % 10000) + 1 AS playerid,
    TIMESTAMP '2024-01-01 00:00:00' + INTERVAL '1 second' * seq AS stattime,
    'car_' || (seq % 10)::TEXT AS selectedcar,
    (seq % 100) + 1 AS currentlevel,
    (seq % 200) / 10.0 AS currentspeed,
    (seq % 3600) + 60 AS currentplaytime,
    (seq % 10000) + 100 AS currentscore,
    'play' AS event,
    NULL AS errorcode,
    (seq % 500) + 1 AS tournamentid
FROM generate_series(1, 500000) AS t(seq);

-- Verify data loaded
SELECT 'Data loading complete!' AS status;

SELECT 
    'players' AS table_name, COUNT(*) AS row_count FROM players
UNION ALL SELECT 'games', COUNT(*) FROM games
UNION ALL SELECT 'tournaments', COUNT(*) FROM tournaments
UNION ALL SELECT 'playstats', COUNT(*) FROM playstats
ORDER BY table_name;

-- =============================================================================
-- OPTION B: Load from S3 (ADVANCED - for larger datasets)
-- =============================================================================
-- If you want BILLION-row scale testing, use Firebolt's public sample datasets.
-- 
-- PREREQUISITES:
--   1. You must be on Firebolt Cloud (not Core)
--   2. Your engine must have access to AWS S3 us-east-1 region
--   3. First TRUNCATE the tables created above, then run these COPY commands:
--
-- TRUNCATE TABLE players;
-- TRUNCATE TABLE games;  
-- TRUNCATE TABLE tournaments;
-- TRUNCATE TABLE playstats;
--
-- COPY INTO players FROM 's3://firebolt-sample-datasets-public-us-east-1/gaming/parquet/players/'
--     WITH PATTERN = '*.snappy.parquet' TYPE = PARQUET;
--
-- COPY INTO games FROM 's3://firebolt-sample-datasets-public-us-east-1/gaming/parquet/games/'
--     WITH PATTERN = '*.snappy.parquet' TYPE = PARQUET;
--
-- COPY INTO tournaments FROM 's3://firebolt-sample-datasets-public-us-east-1/gaming/parquet/tournaments/'
--     WITH PATTERN = '*.snappy.parquet' TYPE = PARQUET;
--
-- COPY INTO playstats FROM 's3://firebolt-sample-datasets-public-us-east-1/gaming/parquet/playstats/'
--     WITH PATTERN = '*.snappy.parquet' TYPE = PARQUET;
--
-- NOTE: The S3 dataset contains ~1 billion rows in playstats. Load time depends 
-- on your engine size. Expect 5-15 minutes for a small engine.
-- =============================================================================


-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║                   STAGE 3: BASELINE PERFORMANCE (SLOW)                    ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝
-- Purpose: Run analytical queries WITHOUT aggregating indexes
-- These queries will perform FULL TABLE SCANS on playstats
-- 
-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │                 HOW TO READ EXPLAIN ANALYZE OUTPUT                          │
-- ├─────────────────────────────────────────────────────────────────────────────┤
-- │                                                                             │
-- │  When you run EXPLAIN ANALYZE, look for these key metrics:                 │
-- │                                                                             │
-- │  1. EXECUTION TIME (bottom of output)                                      │
-- │     - "Time: X.XXX seconds" - total query time                             │
-- │     - BASELINE: Will be hundreds of milliseconds to seconds                │
-- │     - OPTIMIZED: Will be single-digit milliseconds                         │
-- │                                                                             │
-- │  2. ROWS SCANNED (look for "rows" in the plan)                             │
-- │     - "Scan playstats: 500,000 rows" = FULL TABLE SCAN (bad without index) │
-- │     - "Scan playstats_*_agg: 500 rows" = INDEX SCAN (good with index)      │
-- │                                                                             │
-- │  3. BYTES READ                                                              │
-- │     - Higher = more I/O = more cost = slower                               │
-- │     - With indexes: expect 99%+ reduction                                  │
-- │                                                                             │
-- │  4. OPERATION TYPE                                                          │
-- │     - "TableScan" = reading raw data (slow)                                │
-- │     - "ReadFromAggregatingIndex" = reading pre-computed data (fast!)       │
-- │                                                                             │
-- │  WRITE DOWN THESE NUMBERS! You'll compare them in Stage 5.                 │
-- │                                                                             │
-- └─────────────────────────────────────────────────────────────────────────────┘
-- 
-- IMPORTANT: We disable the result cache to ensure fair timing comparisons.
-- In production, you'd leave caching ON for even better performance.

-- Disable result cache to get accurate timing
SET enable_result_cache = FALSE;

-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │  WHY THIS IS SLOW: Without aggregating indexes, Firebolt must:             │
-- │  1. Read EVERY row in playstats (500K+ rows)                               │
-- │  2. Decompress and parse each row                                          │
-- │  3. Compute aggregations (SUM, AVG, COUNT) on the fly                      │
-- │  4. Group and sort the results                                             │
-- │                                                                             │
-- │  This is EXPENSIVE in time, I/O, and compute resources.                    │
-- └─────────────────────────────────────────────────────────────────────────────┘

-- -----------------------------------------------------------------------------
-- BASELINE QUERY 1: Tournament Leaderboard
-- Business question: "Who are the top players in tournament 1?"
-- Without index: Must scan ALL playstats rows for the tournament
-- -----------------------------------------------------------------------------
SELECT '>>> BASELINE QUERY 1: Tournament Leaderboard <<<' AS query_name;

EXPLAIN ANALYZE
SELECT 
    p.playerid,
    p.nickname,
    AVG(ps.currentscore) AS avg_score,
    SUM(ps.currentplaytime) AS total_play_time_seconds,
    MAX(ps.currentlevel) AS max_level_reached,
    COUNT(*) AS total_events
FROM playstats ps
JOIN players p ON ps.playerid = p.playerid
WHERE ps.tournamentid = 1 
  AND ps.gameid = 1
GROUP BY p.playerid, p.nickname
ORDER BY avg_score DESC
LIMIT 20;

-- Record this timing: _____________ ms

-- -----------------------------------------------------------------------------
-- BASELINE QUERY 2: Daily Active Users (DAU)
-- Business question: "What's our daily engagement over the last 30 days?"
-- Without index: Must scan all recent playstats and compute aggregates
-- -----------------------------------------------------------------------------
SELECT '>>> BASELINE QUERY 2: Daily Active Users <<<' AS query_name;

EXPLAIN ANALYZE
SELECT 
    DATE_TRUNC('day', stattime) AS day,
    gameid,
    COUNT(DISTINCT playerid) AS daily_active_users,
    SUM(currentplaytime) AS total_play_time_seconds,
    AVG(currentscore) AS avg_score,
    COUNT(*) AS total_events
FROM playstats
WHERE stattime >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE_TRUNC('day', stattime), gameid
ORDER BY day DESC, daily_active_users DESC
LIMIT 50;

-- Record this timing: _____________ ms

-- -----------------------------------------------------------------------------
-- BASELINE QUERY 3: Player Profile
-- Business question: "Show me player 42's stats across all games"
-- Without index: Must scan all playstats looking for playerid = 42
-- -----------------------------------------------------------------------------
SELECT '>>> BASELINE QUERY 3: Player Profile <<<' AS query_name;

EXPLAIN ANALYZE
SELECT 
    g.title,
    AVG(ps.currentscore) AS avg_score,
    SUM(ps.currentplaytime) AS total_play_time_seconds,
    MAX(ps.currentlevel) AS max_level,
    MIN(ps.stattime) AS first_played,
    MAX(ps.stattime) AS last_played,
    COUNT(*) AS total_sessions
FROM playstats ps
JOIN games g ON ps.gameid = g.gameid
WHERE ps.playerid = 42
GROUP BY g.gameid, g.title
ORDER BY total_play_time_seconds DESC;

-- Record this timing: _____________ ms

-- -----------------------------------------------------------------------------
-- BASELINE QUERY 4: Tournament Overview
-- Business question: "Give me stats for all tournaments"
-- Without index: Full scan with GROUP BY tournament
-- -----------------------------------------------------------------------------
SELECT '>>> BASELINE QUERY 4: Tournament Overview <<<' AS query_name;

EXPLAIN ANALYZE
SELECT 
    t.name,
    t.totalprizedollars,
    COUNT(DISTINCT ps.playerid) AS unique_players,
    AVG(ps.currentscore) AS avg_score,
    MAX(ps.currentscore) AS high_score,
    SUM(ps.currentplaytime) AS total_play_time_seconds,
    COUNT(*) AS total_events
FROM playstats ps
JOIN tournaments t ON ps.tournamentid = t.tournamentid
GROUP BY t.tournamentid, t.name, t.totalprizedollars
ORDER BY total_events DESC
LIMIT 50;

-- Record this timing: _____________ ms

SELECT 'Stage 3 complete - record your baseline timings above!' AS status;


-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║             STAGE 4: ENABLE FEATURE - AGGREGATING INDEXES                 ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝
-- 
-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │                    WHAT ARE AGGREGATING INDEXES?                            │
-- ├─────────────────────────────────────────────────────────────────────────────┤
-- │                                                                             │
-- │  PROBLEM: Analytical queries often compute the same aggregations over and  │
-- │           over (SUM, AVG, COUNT, etc.) on billions of rows. This is slow   │
-- │           and expensive because every query must scan the full table.      │
-- │                                                                             │
-- │  SOLUTION: Aggregating indexes PRE-COMPUTE these aggregations when data    │
-- │            is written, not when it's queried. Think of it as a "cheat      │
-- │            sheet" that Firebolt maintains automatically.                   │
-- │                                                                             │
-- │  HOW IT WORKS:                                                              │
-- │  1. You define an index with GROUP BY columns + aggregation functions      │
-- │  2. When data is INSERTed, Firebolt updates the pre-computed results       │
-- │  3. When a query matches the pattern, Firebolt reads the tiny index        │
-- │     instead of scanning millions/billions of rows                          │
-- │                                                                             │
-- │  RESULT:                                                                    │
-- │  • 50-100X faster queries (seconds → milliseconds)                         │
-- │  • 99%+ less data scanned (GB → KB)                                        │
-- │  • No code changes - your SQL stays exactly the same                       │
-- │  • Cost savings proportional to data reduction                             │
-- │                                                                             │
-- │  BUSINESS VALUE:                                                            │
-- │  • Dashboard refresh: 30 seconds → 300ms = happy users                     │
-- │  • Query costs: $100/day → $1/day = 99% cost reduction                     │
-- │  • Concurrency: 10 users → 1000 users without hardware changes            │
-- │                                                                             │
-- └─────────────────────────────────────────────────────────────────────────────┘
-- 
-- TALKING POINT: "Aggregating indexes are like having a team of analysts who 
-- pre-calculate every possible report overnight, so when you ask a question 
-- in the morning, they just hand you the answer instantly."

-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │                 HOW TO DESIGN AN AGGREGATING INDEX                          │
-- ├─────────────────────────────────────────────────────────────────────────────┤
-- │                                                                             │
-- │  SYNTAX:                                                                    │
-- │    CREATE AGGREGATING INDEX index_name ON table_name (                      │
-- │        grouping_column_1,           -- Your GROUP BY columns               │
-- │        grouping_column_2,           -- (dimensions you filter/group on)    │
-- │        AGG_FUNCTION(measure_col),   -- Your aggregations                   │
-- │        AGG_FUNCTION(measure_col)    -- (the numbers you compute)           │
-- │    );                                                                       │
-- │                                                                             │
-- │  RULES:                                                                     │
-- │  1. List GROUP BY columns first (these become your filter dimensions)      │
-- │  2. List aggregation functions after (these get pre-computed)              │
-- │  3. Supported functions: SUM, AVG, COUNT, COUNT(DISTINCT), MIN, MAX        │
-- │  4. One index can serve multiple queries with same GROUP BY pattern        │
-- │                                                                             │
-- │  TIP: Look at your slow queries. What are the GROUP BY columns?            │
-- │       What aggregations do you compute? That's your index definition.      │
-- │                                                                             │
-- └─────────────────────────────────────────────────────────────────────────────┘

-- -----------------------------------------------------------------------------
-- INDEX 1: Leaderboard Index
-- Matches: Tournament leaderboard queries (GROUP BY tournament, game, player)
-- 
-- WHY THESE COLUMNS?
-- • tournamentid, gameid: We filter by these (WHERE tournamentid = X)
-- • playerid: We group by this (GROUP BY playerid)
-- • AVG(currentscore): We compute this in the SELECT
-- • SUM, MAX, COUNT: Other aggregations we need
-- -----------------------------------------------------------------------------
CREATE AGGREGATING INDEX IF NOT EXISTS playstats_leaderboard_agg
ON playstats (
    tournamentid,
    gameid,
    playerid,
    AVG(currentscore),
    SUM(currentplaytime),
    MAX(currentlevel),
    COUNT(*)
);

-- -----------------------------------------------------------------------------
-- INDEX 2: Daily Metrics Index
-- Matches: DAU/MAU queries (GROUP BY day, game)
-- -----------------------------------------------------------------------------
CREATE AGGREGATING INDEX IF NOT EXISTS playstats_daily_agg
ON playstats (
    gameid,
    DATE_TRUNC('day', stattime),
    SUM(currentplaytime),
    AVG(currentscore),
    COUNT(DISTINCT playerid),
    COUNT(*)
);

-- -----------------------------------------------------------------------------
-- INDEX 3: Player Stats Index
-- Matches: Player profile queries (GROUP BY player, game)
-- -----------------------------------------------------------------------------
CREATE AGGREGATING INDEX IF NOT EXISTS playstats_player_agg
ON playstats (
    playerid,
    gameid,
    AVG(currentscore),
    SUM(currentplaytime),
    MAX(currentlevel),
    MIN(stattime),
    MAX(stattime),
    COUNT(*)
);

-- -----------------------------------------------------------------------------
-- INDEX 4: Tournament Stats Index
-- Matches: Tournament overview queries (GROUP BY tournament, game)
-- -----------------------------------------------------------------------------
CREATE AGGREGATING INDEX IF NOT EXISTS playstats_tournament_agg
ON playstats (
    tournamentid,
    gameid,
    AVG(currentscore),
    MAX(currentscore),
    SUM(currentplaytime),
    COUNT(DISTINCT playerid),
    COUNT(*)
);

-- Verify indexes created
SELECT 'Aggregating indexes created!' AS status;
SHOW INDEXES ON playstats;


-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║                  STAGE 5: OPTIMIZED PERFORMANCE (FAST!)                   ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝
-- Purpose: Run the SAME queries again - now they use the aggregating indexes
-- 
-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │                    WHAT TO LOOK FOR IN THE OUTPUT                           │
-- ├─────────────────────────────────────────────────────────────────────────────┤
-- │                                                                             │
-- │  CONFIRM THE INDEX IS BEING USED:                                          │
-- │  • Look for "ReadFromAggregatingIndex" or the index name in the plan       │
-- │  • If you see "TableScan playstats" instead, the index isn't matching      │
-- │                                                                             │
-- │  EXPECTED IMPROVEMENTS:                                                     │
-- │  ┌────────────────┬─────────────────┬──────────────────┬──────────────┐    │
-- │  │ Metric         │ Without Index   │ With Index       │ Improvement  │    │
-- │  ├────────────────┼─────────────────┼──────────────────┼──────────────┤    │
-- │  │ Query Time     │ 500-2000ms      │ 5-50ms           │ 50-100X      │    │
-- │  │ Rows Scanned   │ 500,000+        │ 500-5,000        │ 99%+ less    │    │
-- │  │ Bytes Read     │ 50-200 MB       │ 50-500 KB        │ 99%+ less    │    │
-- │  └────────────────┴─────────────────┴──────────────────┴──────────────┘    │
-- │                                                                             │
-- │  WHY IT'S FAST NOW:                                                         │
-- │  • Firebolt reads pre-computed aggregates from a tiny index                │
-- │  • Instead of 500K rows → reads ~500 pre-aggregated rows                   │
-- │  • Same SQL, automatic optimization, no code changes needed                │
-- │                                                                             │
-- │  TALKING POINT: "The query didn't change. The data didn't change.          │
-- │  We just told Firebolt which aggregations we care about, and it            │
-- │  pre-computes them for us. That's the power of aggregating indexes."       │
-- │                                                                             │
-- └─────────────────────────────────────────────────────────────────────────────┘

-- Ensure cache is still disabled
SET enable_result_cache = FALSE;

-- -----------------------------------------------------------------------------
-- OPTIMIZED QUERY 1: Tournament Leaderboard (NOW FAST!)
-- Uses: playstats_leaderboard_agg
-- Expected improvement: ~80X faster
-- -----------------------------------------------------------------------------
SELECT '>>> OPTIMIZED QUERY 1: Tournament Leaderboard <<<' AS query_name;

EXPLAIN ANALYZE
SELECT 
    p.playerid,
    p.nickname,
    AVG(ps.currentscore) AS avg_score,
    SUM(ps.currentplaytime) AS total_play_time_seconds,
    MAX(ps.currentlevel) AS max_level_reached,
    COUNT(*) AS total_events
FROM playstats ps
JOIN players p ON ps.playerid = p.playerid
WHERE ps.tournamentid = 1 
  AND ps.gameid = 1
GROUP BY p.playerid, p.nickname
ORDER BY avg_score DESC
LIMIT 20;

-- Compare to baseline: _____________ ms → _____________ ms (____X faster)

-- -----------------------------------------------------------------------------
-- OPTIMIZED QUERY 2: Daily Active Users (NOW FAST!)
-- Uses: playstats_daily_agg
-- Expected improvement: ~74X faster
-- -----------------------------------------------------------------------------
SELECT '>>> OPTIMIZED QUERY 2: Daily Active Users <<<' AS query_name;

EXPLAIN ANALYZE
SELECT 
    DATE_TRUNC('day', stattime) AS day,
    gameid,
    COUNT(DISTINCT playerid) AS daily_active_users,
    SUM(currentplaytime) AS total_play_time_seconds,
    AVG(currentscore) AS avg_score,
    COUNT(*) AS total_events
FROM playstats
WHERE stattime >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE_TRUNC('day', stattime), gameid
ORDER BY day DESC, daily_active_users DESC
LIMIT 50;

-- Compare to baseline: _____________ ms → _____________ ms (____X faster)

-- -----------------------------------------------------------------------------
-- OPTIMIZED QUERY 3: Player Profile (NOW FAST!)
-- Uses: playstats_player_agg
-- Expected improvement: ~43X faster
-- -----------------------------------------------------------------------------
SELECT '>>> OPTIMIZED QUERY 3: Player Profile <<<' AS query_name;

EXPLAIN ANALYZE
SELECT 
    g.title,
    AVG(ps.currentscore) AS avg_score,
    SUM(ps.currentplaytime) AS total_play_time_seconds,
    MAX(ps.currentlevel) AS max_level,
    MIN(ps.stattime) AS first_played,
    MAX(ps.stattime) AS last_played,
    COUNT(*) AS total_sessions
FROM playstats ps
JOIN games g ON ps.gameid = g.gameid
WHERE ps.playerid = 42
GROUP BY g.gameid, g.title
ORDER BY total_play_time_seconds DESC;

-- Compare to baseline: _____________ ms → _____________ ms (____X faster)

-- -----------------------------------------------------------------------------
-- OPTIMIZED QUERY 4: Tournament Overview (NOW FAST!)
-- Uses: playstats_tournament_agg
-- Expected improvement: ~50X faster
-- -----------------------------------------------------------------------------
SELECT '>>> OPTIMIZED QUERY 4: Tournament Overview <<<' AS query_name;

EXPLAIN ANALYZE
SELECT 
    t.name,
    t.totalprizedollars,
    COUNT(DISTINCT ps.playerid) AS unique_players,
    AVG(ps.currentscore) AS avg_score,
    MAX(ps.currentscore) AS high_score,
    SUM(ps.currentplaytime) AS total_play_time_seconds,
    COUNT(*) AS total_events
FROM playstats ps
JOIN tournaments t ON ps.tournamentid = t.tournamentid
GROUP BY t.tournamentid, t.name, t.totalprizedollars
ORDER BY total_events DESC
LIMIT 50;

-- Compare to baseline: _____________ ms → _____________ ms (____X faster)

SELECT 'Stage 5 complete - compare your timings to the baseline!' AS status;


-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║                        STAGE 6: PROVE THE VALUE                           ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝
-- Purpose: Demonstrate that the improvement comes FROM the indexes
-- We'll drop an index, show the query slows down, then re-create it
--
-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │                         WHY THIS MATTERS                                    │
-- ├─────────────────────────────────────────────────────────────────────────────┤
-- │                                                                             │
-- │  Skeptical customers might say: "Maybe the data was cached" or "Maybe      │
-- │  it's just query optimization." This stage PROVES the index is the cause:  │
-- │                                                                             │
-- │  1. Run query with index → FAST                                            │
-- │  2. DROP the index                                                         │
-- │  3. Run SAME query → SLOW (proves index was responsible)                   │
-- │  4. Re-create index → FAST again (proves causality)                        │
-- │                                                                             │
-- │  TALKING POINT: "This is not magic or caching. When the index exists,      │
-- │  Firebolt reads pre-computed data. When it doesn't, it scans the table.    │
-- │  You control your performance by choosing what to pre-compute."            │
-- │                                                                             │
-- └─────────────────────────────────────────────────────────────────────────────┘

-- -----------------------------------------------------------------------------
-- STEP 1: Verify current fast performance
-- -----------------------------------------------------------------------------
SELECT '>>> Verifying fast performance with index <<<' AS step;

EXPLAIN ANALYZE
SELECT 
    tournamentid,
    COUNT(DISTINCT playerid) AS unique_players,
    AVG(currentscore) AS avg_score,
    MAX(currentscore) AS high_score
FROM playstats
GROUP BY tournamentid
ORDER BY unique_players DESC
LIMIT 10;

-- This should be FAST (using playstats_tournament_agg)

-- -----------------------------------------------------------------------------
-- STEP 2: Drop the tournament aggregating index
-- -----------------------------------------------------------------------------
SELECT '>>> Dropping tournament index - watch performance degrade <<<' AS step;

DROP AGGREGATING INDEX IF EXISTS playstats_tournament_agg;

-- -----------------------------------------------------------------------------
-- STEP 3: Run the SAME query - now it's SLOW again
-- -----------------------------------------------------------------------------
SELECT '>>> Same query WITHOUT index - should be SLOW <<<' AS step;

EXPLAIN ANALYZE
SELECT 
    tournamentid,
    COUNT(DISTINCT playerid) AS unique_players,
    AVG(currentscore) AS avg_score,
    MAX(currentscore) AS high_score
FROM playstats
GROUP BY tournamentid
ORDER BY unique_players DESC
LIMIT 10;

-- This should be SLOW (full table scan)
-- PROOF: The aggregating index was responsible for the speedup!

-- -----------------------------------------------------------------------------
-- STEP 4: Re-create the index to restore performance
-- -----------------------------------------------------------------------------
SELECT '>>> Re-creating index - performance restored! <<<' AS step;

CREATE AGGREGATING INDEX IF NOT EXISTS playstats_tournament_agg
ON playstats (
    tournamentid,
    gameid,
    AVG(currentscore),
    MAX(currentscore),
    SUM(currentplaytime),
    COUNT(DISTINCT playerid),
    COUNT(*)
);

-- Verify it's fast again
EXPLAIN ANALYZE
SELECT 
    tournamentid,
    COUNT(DISTINCT playerid) AS unique_players,
    AVG(currentscore) AS avg_score,
    MAX(currentscore) AS high_score
FROM playstats
GROUP BY tournamentid
ORDER BY unique_players DESC
LIMIT 10;

SELECT 'Stage 6 complete - proof that aggregating indexes are the key!' AS status;


-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║                      STAGE 7: CLEANUP (OPTIONAL)                          ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝
-- Purpose: Reset the environment for the next demo
-- Only run this if you want to start fresh

/*
-- Drop all aggregating indexes
DROP AGGREGATING INDEX IF EXISTS playstats_leaderboard_agg;
DROP AGGREGATING INDEX IF EXISTS playstats_daily_agg;
DROP AGGREGATING INDEX IF EXISTS playstats_player_agg;
DROP AGGREGATING INDEX IF EXISTS playstats_tournament_agg;

-- Drop all tables
DROP TABLE IF EXISTS playstats;
DROP TABLE IF EXISTS tournaments;
DROP TABLE IF EXISTS games;
DROP TABLE IF EXISTS players;

-- Verify cleanup
SHOW TABLES;
*/

-- Re-enable result cache
SET enable_result_cache = TRUE;


-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║                              SUMMARY                                       ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝
--
-- WHAT YOU DEMONSTRATED:
--
-- 1. Created a gaming analytics schema with a high-volume fact table (playstats)
--
-- 2. Ran common analytical queries WITHOUT optimization (SLOW - full table scans)
--
-- 3. Created aggregating indexes that match query patterns
--
-- 4. Ran the SAME queries WITH indexes (FAST - 50-100X improvement)
--
-- 5. Proved the indexes are responsible by dropping and re-creating
--
-- KEY TAKEAWAYS:
--
-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │ Aggregating indexes are Firebolt's killer feature for analytics        │
-- │                                                                         │
-- │ • Pre-compute aggregations at write time                               │
-- │ • No query changes needed - same SQL, automatic optimization           │
-- │ • 50-100X faster queries on aggregation-heavy workloads                │
-- │ • 99%+ reduction in data scanned (cost savings!)                       │
-- └─────────────────────────────────────────────────────────────────────────┘
--
-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                         QUICK REFERENCE CARD                            │
-- ├─────────────────────────────────────────────────────────────────────────┤
-- │                                                                         │
-- │  CREATE AN AGGREGATING INDEX:                                          │
-- │    CREATE AGGREGATING INDEX idx_name ON table (                        │
-- │        group_col1, group_col2,                                         │
-- │        SUM(measure), AVG(measure), COUNT(*)                            │
-- │    );                                                                   │
-- │                                                                         │
-- │  DROP AN INDEX:                                                         │
-- │    DROP AGGREGATING INDEX IF EXISTS idx_name;                          │
-- │                                                                         │
-- │  SEE ALL INDEXES ON A TABLE:                                           │
-- │    SHOW INDEXES ON table_name;                                         │
-- │                                                                         │
-- │  CHECK IF INDEX IS BEING USED:                                         │
-- │    EXPLAIN ANALYZE SELECT ... (look for "AggregatingIndex")            │
-- │                                                                         │
-- │  DISABLE CACHING FOR BENCHMARKS:                                       │
-- │    SET enable_result_cache = FALSE;                                    │
-- │                                                                         │
-- └─────────────────────────────────────────────────────────────────────────┘
--
-- NEXT STEPS:
--
-- 1. Try adding more sample data and watch performance stay consistent
-- 2. Experiment with your own queries and create matching indexes
-- 3. Check out other Firebolt features: Late Materialization, Vector Search
--
-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │                        WANT TO LEARN MORE?                              │
-- ├─────────────────────────────────────────────────────────────────────────┤
-- │                                                                         │
-- │  Firebolt Documentation:                                                │
-- │    https://docs.firebolt.io/godocs/Guides/working-with-indexes/        │
-- │    using-aggregating-indexes.html                                      │
-- │                                                                         │
-- │  Other plg-ide Demos:                                                   │
-- │    • Late Materialization - reduce I/O on wide tables                  │
-- │    • Vector Search - semantic similarity with HNSW indexes             │
-- │    • High Concurrency - workload isolation for mixed use cases         │
-- │                                                                         │
-- │  Firebolt MCP Server (for AI-assisted queries):                        │
-- │    https://github.com/firebolt-db/mcp-server                           │
-- │                                                                         │
-- └─────────────────────────────────────────────────────────────────────────┘
--
-- =============================================================================
