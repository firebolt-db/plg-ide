# Aggregating Indexes

Aggregating indexes are Firebolt's secret weapon for analytical queries. They pre-compute aggregations at write time, enabling sub-millisecond responses on queries that would otherwise scan billions of rows.

## How It Works

```
┌─────────────────────────────────────────────────────────────────┐
│                     Without Aggregating Index                    │
│                                                                  │
│  Query: SELECT game_id, SUM(score) FROM playstats GROUP BY 1    │
│                                                                  │
│  ┌─────────┐    ┌─────────────────────┐    ┌─────────┐          │
│  │ Query   │───>│ Scan 50M rows       │───>│ Result  │          │
│  │         │    │ Read 2.1 GB         │    │ 1,247ms │          │
│  └─────────┘    └─────────────────────┘    └─────────┘          │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                      With Aggregating Index                      │
│                                                                  │
│  Query: SELECT game_id, SUM(score) FROM playstats GROUP BY 1    │
│                                                                  │
│  ┌─────────┐    ┌─────────────────────┐    ┌─────────┐          │
│  │ Query   │───>│ Read pre-computed   │───>│ Result  │          │
│  │         │    │ aggregates (1.2 MB) │    │ 15ms    │          │
│  └─────────┘    └─────────────────────┘    └─────────┘          │
└─────────────────────────────────────────────────────────────────┘
```

## When to Use

Aggregating indexes shine when:

- Queries use `GROUP BY` with aggregation functions
- The same grouping patterns repeat frequently
- Response time is critical (dashboards, APIs)
- Data volume is large but grouping cardinality is low

## Syntax

```sql
CREATE AGGREGATING INDEX index_name ON table_name (
    -- Group by columns (dimensions)
    column1,
    column2,
    -- Aggregation functions
    SUM(measure1),
    COUNT(*),
    AVG(measure2),
    MAX(measure3),
    COUNT(DISTINCT dimension)
);
```

## Key Design Principles

1. **Match your queries**: The index GROUP BY must match your query GROUP BY exactly
2. **Include all aggregations**: Add every aggregation function your queries need
3. **Consider cardinality**: Lower cardinality = smaller index = faster queries
4. **Idempotent creation**: Use `IF NOT EXISTS` for safe re-runs

## Example: Leaderboard Query

```sql
-- Create the index
CREATE AGGREGATING INDEX IF NOT EXISTS leaderboard_agg ON playstats (
    tournament_id,
    game_id,
    player_id,
    AVG(current_score),
    SUM(current_play_time),
    MAX(current_level),
    COUNT(*)
);

-- This query now reads from the index, not the full table
SELECT 
    player_id,
    AVG(current_score) as avg_score,
    SUM(current_play_time) as total_time
FROM playstats
WHERE tournament_id = 123 AND game_id = 456
GROUP BY player_id
ORDER BY avg_score DESC
LIMIT 100;
```

## Typical Improvements

| Metric | Without | With | Improvement |
|--------|---------|------|-------------|
| Query Time | 1-2 seconds | 10-50 ms | 50-100X |
| Rows Scanned | Millions | Thousands | 99%+ |
| Bytes Read | GBs | MBs | 99%+ |
| Cost | High | Low | Proportional |

## Try It

See the [Gaming Vertical Demo](../../verticals/gaming/features/aggregating_indexes/) for a hands-on experience.
