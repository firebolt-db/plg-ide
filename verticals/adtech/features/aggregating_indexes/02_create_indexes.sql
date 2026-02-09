-- Aggregating Indexes Demo: Create Indexes (AdTech)
-- Pre-compute campaign and publisher aggregations

CREATE AGGREGATING INDEX IF NOT EXISTS impressions_campaign_daily_agg
ON impressions (
    campaign_id,
    DATE_TRUNC('day', timestamp),
    COUNT(*),
    COUNT(DISTINCT user_id),
    SUM(win_price),
    AVG(win_price)
);

CREATE AGGREGATING INDEX IF NOT EXISTS impressions_publisher_agg
ON impressions (
    publisher_id,
    DATE_TRUNC('day', timestamp),
    COUNT(*),
    SUM(win_price),
    COUNT(DISTINCT campaign_id),
    COUNT(DISTINCT user_id)
);

CREATE AGGREGATING INDEX IF NOT EXISTS impressions_device_agg
ON impressions (
    campaign_id,
    device_type,
    COUNT(*),
    SUM(win_price)
);

CREATE AGGREGATING INDEX IF NOT EXISTS impressions_geo_daily_agg
ON impressions (
    geo_country,
    DATE_TRUNC('day', timestamp),
    COUNT(*),
    SUM(win_price)
);

SHOW INDEXES ON impressions;
