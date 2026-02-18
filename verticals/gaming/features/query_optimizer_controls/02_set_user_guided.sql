-- Query Optimizer Controls Demo: Enable user_guided mode
-- This disables join reordering, aggregate push-down, subquery decorrelation,
-- and common sub-plan discovery. The plan will follow the join order in the SQL.
-- Run 03_optimized.sql with this setting active to see the fixed order.

SET optimizer_mode = 'user_guided';

-- Optional: verify setting
-- SELECT current_setting('optimizer_mode');
