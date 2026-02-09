-- AdTech Vertical Data Loading
-- Generates sample AdTech data for demos

-- =============================================================================
-- Generate sample data via SQL (works everywhere)
-- =============================================================================
-- Creates: 10K publishers, 1K advertisers, 100K campaigns, 10M impressions, 1M clicks
-- Approximate load time: 30-120 seconds depending on engine size

-- Insert sample publishers
INSERT INTO publishers (publisher_id, domain, category, country, monthly_impressions, revenue_share)
SELECT 
    seq AS publisher_id,
    'publisher' || seq::TEXT || '.com' AS domain,
    CASE seq % 5 
        WHEN 0 THEN 'news' WHEN 1 THEN 'social' WHEN 2 THEN 'entertainment' 
        WHEN 3 THEN 'shopping' ELSE 'tech' 
    END AS category,
    CASE seq % 10 
        WHEN 0 THEN 'USA' WHEN 1 THEN 'UK' WHEN 2 THEN 'Germany' 
        WHEN 3 THEN 'France' WHEN 4 THEN 'Canada' WHEN 5 THEN 'Australia'
        WHEN 6 THEN 'Japan' WHEN 7 THEN 'Brazil' WHEN 8 THEN 'India' 
        ELSE 'Spain' 
    END AS country,
    (1000000 + (seq % 10000000))::BIGINT AS monthly_impressions,
    (0.3 + (seq % 20) / 100.0)::DECIMAL(5,4) AS revenue_share
FROM generate_series(1, 10000) AS t(seq);

-- Insert sample advertisers
INSERT INTO advertisers (advertiser_id, advertiser_name, industry, monthly_budget, target_audience)
SELECT 
    seq AS advertiser_id,
    'Advertiser_' || seq::TEXT AS advertiser_name,
    CASE seq % 5 
        WHEN 0 THEN 'retail' WHEN 1 THEN 'finance' WHEN 2 THEN 'tech' 
        WHEN 3 THEN 'healthcare' ELSE 'automotive' 
    END AS industry,
    (10000 + (seq % 1000000))::DECIMAL(15,2) AS monthly_budget,
    ARRAY['audience_' || (seq % 10)::TEXT] AS target_audience
FROM generate_series(1, 1000) AS t(seq);

-- Insert sample campaigns
INSERT INTO campaigns (campaign_id, advertiser_id, campaign_name, start_date, end_date, budget, status)
SELECT 
    seq AS campaign_id,
    (seq % 1000) + 1 AS advertiser_id,
    'Campaign_' || seq::TEXT AS campaign_name,
    TIMESTAMP '2024-01-01 00:00:00' + INTERVAL '1 day' * (seq % 365) AS start_date,
    TIMESTAMP '2024-01-01 00:00:00' + INTERVAL '1 day' * (seq % 365) + INTERVAL '30 days' AS end_date,
    (1000 + (seq % 100000))::DECIMAL(15,2) AS budget,
    CASE seq % 3 
        WHEN 0 THEN 'active' WHEN 1 THEN 'paused' ELSE 'completed' 
    END AS status
FROM generate_series(1, 100000) AS t(seq);

-- Insert sample ad units
INSERT INTO ad_units (ad_unit_id, campaign_id, creative_type, size, ctr)
SELECT 
    seq AS ad_unit_id,
    (seq % 100000) + 1 AS campaign_id,
    CASE seq % 4 
        WHEN 0 THEN 'banner' WHEN 1 THEN 'video' WHEN 2 THEN 'native' 
        ELSE 'display' 
    END AS creative_type,
    CASE seq % 3 
        WHEN 0 THEN '300x250' WHEN 1 THEN '728x90' ELSE 'native' 
    END AS size,
    (0.01 + (seq % 50) / 1000.0)::DECIMAL(5,4) AS ctr
FROM generate_series(1, 200000) AS t(seq);

-- Insert sample impressions (the high-volume table - 10M rows)
INSERT INTO impressions (impression_id, campaign_id, publisher_id, ad_unit_id, user_id, timestamp, device_type, browser, os, geo_country, geo_city, bid_price, win_price)
SELECT 
    seq AS impression_id,
    (seq % 100000) + 1 AS campaign_id,
    (seq % 10000) + 1 AS publisher_id,
    (seq % 200000) + 1 AS ad_unit_id,
    (seq % 1000000) + 1 AS user_id,
    TIMESTAMP '2024-01-01 00:00:00' + INTERVAL '1 second' * seq AS timestamp,
    CASE seq % 3 
        WHEN 0 THEN 'desktop' WHEN 1 THEN 'mobile' ELSE 'tablet' 
    END AS device_type,
    CASE seq % 5 
        WHEN 0 THEN 'Chrome' WHEN 1 THEN 'Safari' WHEN 2 THEN 'Firefox' 
        WHEN 3 THEN 'Edge' ELSE 'Other' 
    END AS browser,
    CASE seq % 4 
        WHEN 0 THEN 'Windows' WHEN 1 THEN 'macOS' WHEN 2 THEN 'iOS' 
        ELSE 'Android' 
    END AS os,
    CASE seq % 10 
        WHEN 0 THEN 'USA' WHEN 1 THEN 'UK' WHEN 2 THEN 'Germany' 
        WHEN 3 THEN 'France' WHEN 4 THEN 'Canada' WHEN 5 THEN 'Australia'
        WHEN 6 THEN 'Japan' WHEN 7 THEN 'Brazil' WHEN 8 THEN 'India' 
        ELSE 'Spain' 
    END AS geo_country,
    'City_' || (seq % 100)::TEXT AS geo_city,
    (0.1 + (seq % 100) / 100.0)::DECIMAL(10,4) AS bid_price,
    (0.05 + (seq % 50) / 100.0)::DECIMAL(10,4) AS win_price
FROM generate_series(1, 10000000) AS t(seq);

-- Insert sample clicks (1M rows - ~10% CTR)
INSERT INTO clicks (click_id, impression_id, timestamp, user_id, device_type, geo_country)
SELECT 
    seq AS click_id,
    (seq * 10) + (seq % 100) AS impression_id,  -- ~10% of impressions
    TIMESTAMP '2024-01-01 00:00:00' + INTERVAL '1 second' * (seq * 10) AS timestamp,
    (seq % 1000000) + 1 AS user_id,
    CASE seq % 3 
        WHEN 0 THEN 'desktop' WHEN 1 THEN 'mobile' ELSE 'tablet' 
    END AS device_type,
    CASE seq % 10 
        WHEN 0 THEN 'USA' WHEN 1 THEN 'UK' WHEN 2 THEN 'Germany' 
        WHEN 3 THEN 'France' WHEN 4 THEN 'Canada' WHEN 5 THEN 'Australia'
        WHEN 6 THEN 'Japan' WHEN 7 THEN 'Brazil' WHEN 8 THEN 'India' 
        ELSE 'Spain' 
    END AS geo_country
FROM generate_series(1, 1000000) AS t(seq);

-- Insert sample conversions (100K rows - ~1% conversion rate)
INSERT INTO conversions (conversion_id, click_id, impression_id, campaign_id, timestamp, conversion_type, value, user_id)
SELECT 
    seq AS conversion_id,
    (seq * 10) + (seq % 100) AS click_id,
    (seq * 100) + (seq % 1000) AS impression_id,
    (seq % 100000) + 1 AS campaign_id,
    TIMESTAMP '2024-01-01 00:00:00' + INTERVAL '1 second' * (seq * 100) AS timestamp,
    CASE seq % 4 
        WHEN 0 THEN 'purchase' WHEN 1 THEN 'signup' WHEN 2 THEN 'download' 
        ELSE 'lead' 
    END AS conversion_type,
    (10 + (seq % 1000))::DECIMAL(12,2) AS value,
    (seq % 1000000) + 1 AS user_id
FROM generate_series(1, 100000) AS t(seq);

-- =============================================================================
-- VERIFICATION
-- =============================================================================

-- Check row counts
SELECT 'publishers' AS table_name, COUNT(*) AS row_count FROM publishers
UNION ALL
SELECT 'advertisers', COUNT(*) FROM advertisers
UNION ALL
SELECT 'campaigns', COUNT(*) FROM campaigns
UNION ALL
SELECT 'ad_units', COUNT(*) FROM ad_units
UNION ALL
SELECT 'impressions', COUNT(*) FROM impressions
UNION ALL
SELECT 'clicks', COUNT(*) FROM clicks
UNION ALL
SELECT 'conversions', COUNT(*) FROM conversions
ORDER BY table_name;

-- Check impressions date range and stats
SELECT 
    MIN(timestamp) AS earliest_impression,
    MAX(timestamp) AS latest_impression,
    COUNT(DISTINCT campaign_id) AS unique_campaigns,
    COUNT(DISTINCT publisher_id) AS unique_publishers,
    COUNT(DISTINCT user_id) AS unique_users,
    SUM(win_price) AS total_spend
FROM impressions;
