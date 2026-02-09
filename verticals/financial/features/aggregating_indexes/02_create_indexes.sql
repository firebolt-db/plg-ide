-- Aggregating Indexes Demo: Create Indexes (Financial)

CREATE AGGREGATING INDEX IF NOT EXISTS transactions_daily_agg
ON transactions (
    DATE_TRUNC('day', timestamp),
    transaction_type,
    COUNT(*),
    SUM(amount),
    AVG(amount)
);

CREATE AGGREGATING INDEX IF NOT EXISTS transactions_merchant_agg
ON transactions (
    merchant_id,
    category,
    DATE_TRUNC('day', timestamp),
    COUNT(*),
    SUM(amount),
    AVG(risk_score)
);

CREATE AGGREGATING INDEX IF NOT EXISTS transactions_account_daily_agg
ON transactions (
    account_id,
    DATE_TRUNC('day', timestamp),
    COUNT(*),
    SUM(amount)
);

SHOW INDEXES ON transactions;
