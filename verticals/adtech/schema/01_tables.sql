-- AdTech Vertical Schema
-- AdTech Dataset Tables

-- =============================================================================
-- DIMENSION TABLES
-- =============================================================================

-- Publishers table - publisher sites/apps
CREATE TABLE IF NOT EXISTS publishers (
    publisher_id INT,
    domain TEXT,
    category TEXT,          -- 'news', 'social', 'entertainment', 'shopping'
    country TEXT,
    monthly_impressions BIGINT,
    revenue_share DECIMAL(5, 4)
) PRIMARY INDEX publisher_id;

-- Advertisers table - advertiser accounts
CREATE TABLE IF NOT EXISTS advertisers (
    advertiser_id INT,
    advertiser_name TEXT,
    industry TEXT,          -- 'retail', 'finance', 'tech', 'healthcare'
    monthly_budget DECIMAL(15, 2),
    target_audience TEXT[]
) PRIMARY INDEX advertiser_id;

-- Campaigns table - campaign metadata
CREATE TABLE IF NOT EXISTS campaigns (
    campaign_id INT,
    advertiser_id INT,
    campaign_name TEXT,
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    budget DECIMAL(15, 2),
    status TEXT,            -- 'active', 'paused', 'completed'
    targeting_criteria JSON
) PRIMARY INDEX campaign_id;

-- Ad Units table - ad creative metadata
CREATE TABLE IF NOT EXISTS ad_units (
    ad_unit_id INT,
    campaign_id INT,
    creative_type TEXT,     -- 'banner', 'video', 'native', 'display'
    size TEXT,              -- '300x250', '728x90', 'native'
    ctr DECIMAL(5, 4)
) PRIMARY INDEX ad_unit_id;

-- =============================================================================
-- FACT TABLES (HIGH VOLUME)
-- =============================================================================

-- Impressions table - ad impression events (the star of the show)
-- This is where aggregating indexes provide massive value
CREATE TABLE IF NOT EXISTS impressions (
    impression_id BIGINT,
    campaign_id INT,
    publisher_id INT,
    ad_unit_id INT,
    user_id BIGINT,
    timestamp TIMESTAMP,
    device_type TEXT,       -- 'desktop', 'mobile', 'tablet'
    browser TEXT,
    os TEXT,
    geo_country TEXT,
    geo_city TEXT,
    ip_address TEXT,
    user_agent TEXT,
    page_url TEXT,
    bid_price DECIMAL(10, 4),
    win_price DECIMAL(10, 4)
) PRIMARY INDEX impression_id;

-- Clicks table - click events
CREATE TABLE IF NOT EXISTS clicks (
    click_id BIGINT,
    impression_id BIGINT,
    timestamp TIMESTAMP,
    user_id BIGINT,
    device_type TEXT,
    geo_country TEXT
) PRIMARY INDEX click_id;

-- Conversions table - conversion events
CREATE TABLE IF NOT EXISTS conversions (
    conversion_id BIGINT,
    click_id BIGINT,
    impression_id BIGINT,
    campaign_id INT,
    timestamp TIMESTAMP,
    conversion_type TEXT,   -- 'purchase', 'signup', 'download', 'lead'
    value DECIMAL(12, 2),
    user_id BIGINT
) PRIMARY INDEX conversion_id;

-- =============================================================================
-- VERIFICATION
-- =============================================================================

-- Show created tables
SHOW TABLES;
