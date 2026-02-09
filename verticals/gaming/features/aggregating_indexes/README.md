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
    playerid,
    AVG(currentscore) as avg_score,
    SUM(currentplaytime) as total_time,
    MAX(currentlevel) as max_level
FROM playstats
WHERE tournamentid = ? AND gameid = ?
GROUP BY playerid
ORDER BY avg_score DESC
LIMIT 100;
```

**Index**: Groups by `tournamentid, gameid, playerid` with aggregations.

### 2. Daily Active Users (DAU)

Track daily player engagement trends.

```sql
SELECT 
    DATE_TRUNC('day', stattime) as day,
    gameid,
    COUNT(DISTINCT playerid) as dau,
    SUM(currentplaytime) as total_play_time
FROM playstats
WHERE stattime >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY 1, 2
ORDER BY day DESC, dau DESC;
```

**Index**: Groups by `gameid, DATE_TRUNC('day', stattime)` with aggregations.

### 3. Player Profile Stats

Show a player's historical performance across games.

```sql
SELECT 
    gameid,
    AVG(currentscore) as avg_score,
    SUM(currentplaytime) as total_time,
    MAX(currentlevel) as max_level,
    COUNT(*) as sessions
FROM playstats
WHERE playerid = ?
GROUP BY gameid
ORDER BY total_time DESC;
```

**Index**: Groups by `playerid, gameid` with aggregations.

## How It Works

```
┌─────────────────────────────────────────────────────────────────┐
│                   BEFORE: Full Table Scan                        │
│                                                                  │
│  SELECT gameid, AVG(currentscore) FROM playstats GROUP BY gameid     │
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
│  SELECT gameid, AVG(currentscore) FROM playstats GROUP BY gameid     │
│                                                                  │
│  Aggregating Index (100 rows - one per game)                    │
│  ┌──────────────────────────────────────────┐                   │
│  │ gameid │ SUM(currentscore) │ COUNT(*) │ ...    │                   │
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
