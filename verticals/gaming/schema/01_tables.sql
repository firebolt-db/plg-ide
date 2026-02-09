-- Gaming Vertical Schema
-- Aligned with Firebolt.io Ultra Fast Gaming dataset (firebolt.io UI)

-- =============================================================================
-- DIMENSION TABLES
-- =============================================================================

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

-- =============================================================================
-- FACT TABLE (HIGH VOLUME)
-- =============================================================================

-- PlayStats table - game play events (the star of the show)
-- This is where aggregating indexes provide massive value
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

-- =============================================================================
-- VERIFICATION
-- =============================================================================

-- Show created tables
SHOW TABLES;
