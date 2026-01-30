-- Gaming Vertical Schema
-- Ultra Fast Gaming Dataset Tables

-- =============================================================================
-- DIMENSION TABLES
-- =============================================================================

-- Players table - user accounts
CREATE TABLE IF NOT EXISTS players (
    player_id INT,
    username TEXT,
    email TEXT,
    registration_date DATE,
    subscription_type TEXT,  -- 'free', 'premium', 'pro'
    country TEXT,
    platform TEXT            -- 'pc', 'console', 'mobile'
) PRIMARY INDEX player_id;

-- Games table - game catalog
CREATE TABLE IF NOT EXISTS games (
    game_id INT,
    game_name TEXT,
    genre TEXT,
    publisher TEXT,
    release_date DATE,
    rating REAL
) PRIMARY INDEX game_id;

-- Tournaments table - competitive events
CREATE TABLE IF NOT EXISTS tournaments (
    tournament_id INT,
    game_id INT,
    tournament_name TEXT,
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    prize_pool DECIMAL(12, 2),
    status TEXT              -- 'upcoming', 'active', 'completed'
) PRIMARY INDEX tournament_id;

-- =============================================================================
-- FACT TABLE (HIGH VOLUME)
-- =============================================================================

-- PlayStats table - game play events (the star of the show)
-- This is where aggregating indexes provide massive value
CREATE TABLE IF NOT EXISTS playstats (
    stat_id BIGINT,
    player_id INT,
    game_id INT,
    tournament_id INT,
    stat_time TIMESTAMP,
    current_score INT,
    current_level INT,
    current_play_time INT,   -- seconds
    platform TEXT,
    session_id TEXT
) PRIMARY INDEX stat_id;

-- =============================================================================
-- VERIFICATION
-- =============================================================================

-- Show created tables
SHOW TABLES;
