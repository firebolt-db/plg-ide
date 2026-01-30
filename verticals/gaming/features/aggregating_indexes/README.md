# Aggregating Indexes Demo - Gaming Vertical

This demo proves the value of Firebolt's aggregating indexes using real gaming analytics queries.

## What You'll See

| Query | Without Index | With Index | Improvement |
|-------|---------------|------------|-------------|
| Tournament Leaderboard | ~1,200ms | ~15ms | **80X** |
| Daily Active Users | ~890ms | ~12ms | **74X** |
| Player Profile Stats | ~340ms | ~8ms | **43X** |

## Quick Start

```bash
# Run the full benchmark
python benchmark.py

# Or step by step:
# 1. Run baseline queries (no indexes)
python -m lib.firebolt run 01_baseline.sql

# 2. Create aggregating indexes
python -m lib.firebolt run 02_create_indexes.sql

# 3. Run optimized queries
python -m lib.firebolt run 03_optimized.sql
```

## The Queries

### 1. Tournament Leaderboard

Show top players in a tournament, ranked by average score.

```sql
SELECT 
    player_id,
    AVG(current_score) as avg_score,
    SUM(current_play_time) as total_time,
    MAX(current_level) as max_level
FROM playstats
WHERE tournament_id = ? AND game_id = ?
GROUP BY player_id
ORDER BY avg_score DESC
LIMIT 100;
```

**Index**: Groups by `tournament_id, game_id, player_id` with aggregations.

### 2. Daily Active Users (DAU)

Track daily player engagement trends.

```sql
SELECT 
    DATE_TRUNC('day', stat_time) as day,
    game_id,
    COUNT(DISTINCT player_id) as dau,
    SUM(current_play_time) as total_play_time
FROM playstats
WHERE stat_time >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY 1, 2
ORDER BY day DESC, dau DESC;
```

**Index**: Groups by `game_id, DATE_TRUNC('day', stat_time)` with aggregations.

### 3. Player Profile Stats

Show a player's historical performance across games.

```sql
SELECT 
    game_id,
    AVG(current_score) as avg_score,
    SUM(current_play_time) as total_time,
    MAX(current_level) as max_level,
    COUNT(*) as sessions
FROM playstats
WHERE player_id = ?
GROUP BY game_id
ORDER BY total_time DESC;
```

**Index**: Groups by `player_id, game_id` with aggregations.

## How It Works

```
┌─────────────────────────────────────────────────────────────────┐
│                   BEFORE: Full Table Scan                        │
│                                                                  │
│  SELECT game_id, AVG(score) FROM playstats GROUP BY game_id     │
│                                                                  │
│  playstats (10M rows)                                            │
│  ┌────┬────┬────┬────┬────┬────┬────┬────┬────┬────┐            │
│  │ ■  │ ■  │ ■  │ ■  │ ■  │ ■  │ ■  │ ■  │ ■  │ ■  │ ... x10M   │
│  └────┴────┴────┴────┴────┴────┴────┴────┴────┴────┘            │
│                    ↓ Scan all rows                               │
│                    1,200ms                                       │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                   AFTER: Index Lookup                            │
│                                                                  │
│  SELECT game_id, AVG(score) FROM playstats GROUP BY game_id     │
│                                                                  │
│  Aggregating Index (100 rows - one per game)                    │
│  ┌──────────────────────────────────────────┐                   │
│  │ game_id │ SUM(score) │ COUNT(*) │ ...    │                   │
│  ├──────────────────────────────────────────┤                   │
│  │    1    │  5000000   │  100000  │        │                   │
│  │    2    │  4800000   │   95000  │        │                   │
│  │   ...   │    ...     │   ...    │        │                   │
│  └──────────────────────────────────────────┘                   │
│                    ↓ Read pre-computed                          │
│                    15ms                                          │
└─────────────────────────────────────────────────────────────────┘
```

## Files

- `01_baseline.sql` - Queries WITHOUT aggregating indexes (slow)
- `02_create_indexes.sql` - Creates the aggregating indexes
- `03_optimized.sql` - Same queries, now fast with indexes
- `benchmark.py` - Automated comparison script

## Run the Benchmark

```bash
python benchmark.py
```

Output:

```
============================================================
Feature Benchmark: Tournament Leaderboard
============================================================

╭─────────────────┬───────────┬───────────┬──────────╮
│ Metric          │ Without   │ With      │ Savings  │
├─────────────────┼───────────┼───────────┼──────────┤
│ Query Time      │ 1,247 ms  │ 15 ms     │ 98.8%    │
│ Rows Scanned    │ 10.0M     │ 10.0K     │ 99.9%    │
│ Bytes Read      │ 2.1 GB    │ 1.2 MB    │ 99.9%    │
╰─────────────────┴───────────┴───────────┴──────────╯

Improvement: 83X faster
```
