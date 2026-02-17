# Gaming Vertical

Real-time gaming analytics powered by Firebolt. This demo showcases how gaming companies like Lurkit achieve 10X larger historical queries while cutting costs by 40%.

## Use Case

Gaming platforms need to:
- Show real-time leaderboards during tournaments
- Track daily/monthly active users (DAU/MAU)
- Display player profiles with historical stats
- Analyze engagement across games and platforms

**The Challenge**: Billions of play events, sub-second query requirements, concurrent users.

**The Solution**: Firebolt's aggregating indexes pre-compute common aggregations.

## Dataset

**Ultra Fast Gaming** - Firebolt's public sample dataset

| Table | Description | Approximate Rows |
|-------|-------------|------------------|
| `players` | Player profiles | 100K |
| `games` | Game catalog | 1K |
| `tournaments` | Tournament metadata | 10K |
| `playstats` | Play event stream | 10M+ |

## Quick Start

```bash
# From repo root
cd verticals/gaming

# Load schema and data
python -m lib.firebolt run schema/01_tables.sql
python -m lib.firebolt run data/load.sql

# Run feature demos
cd features/aggregating_indexes
python benchmark.py
```

## Feature Demos

### Aggregating Indexes

Demonstrates 50-100X query speedup for:

| Index | Use Case | Query Pattern |
|-------|----------|---------------|
| `playstats_leaderboard_agg` | Tournament rankings | GROUP BY tournament, game, player |
| `playstats_daily_agg` | DAU/MAU, engagement trends | GROUP BY game, day |
| `playstats_player_agg` | Player profiles, history | GROUP BY player, game |
| `playstats_tournament_agg` | Tournament stats | GROUP BY tournament, game |

[Go to Demo](features/aggregating_indexes/)

For full-stack demo (REST API, data streamer, Kafka): see [firebolt-analytics/gaming-demo](https://github.com/firebolt-analytics/gaming-demo) (Firex-gaming-demo).

## Schema

Aligned with [Firebolt.io Ultra Fast Gaming](https://www.firebolt.io/free-sample-datasets/ultra-fast-gaming) dataset:

```sql
-- Core dimension tables
players (playerid, nickname, email, agecategory, platforms, registeredon, ...)
games (gameid, title, category, launchdate, ...)
tournaments (tournamentid, name, gameid, totalprizedollars, startdatetime, enddatetime, ...)

-- High-volume fact table
playstats (
    gameid, playerid, tournamentid, stattime,
    currentscore, currentlevel, currentplaytime, selectedcar, ...
)
```

## Real-World References

- [Lurkit Case Study](https://www.firebolt.io/blog/how-we-serve-data-from-millions-of-gaming-channels-to-50k-customers-using-firebolt) - 10X historical data, 40% cost reduction
- [Ultra Fast Gaming Dataset](https://www.firebolt.io/free-sample-datasets/ultra-fast-gaming)

**Further reading (feature demos):**

- [Firebolt docs: Aggregating indexes](https://docs.firebolt.io/sql-reference/aggregating-indexes) — leaderboards, DAU/MAU
- [Firebolt Connector for Confluent](https://www.firebolt.io/blog/firebolt-connector-for-confluent---real-time-applications-powered-by-streaming-data) — live events, streaming ingestion
- [firebolt-analytics/gaming-demo](https://github.com/firebolt-analytics/gaming-demo) — full-stack demo (REST API, data streamer, Kafka)
