# Aggregating Indexes Demo - Observability Vertical

Proves the value of Firebolt's aggregating indexes for log and metrics analytics.

## What You'll See

| Query | Without Index | With Index | Improvement |
|-------|---------------|------------|-------------|
| Log Count by Service/Day | ~2,000ms | ~25ms | **80X** |
| Error Rate by Service | ~1,500ms | ~20ms | **75X** |
| Request Volume by Endpoint | ~1,200ms | ~18ms | **65X** |

## Quick Start

```bash
cd verticals/observability
python -m lib.firebolt run schema/01_tables.sql
python -m lib.firebolt run data/load.sql
cd features/aggregating_indexes
python benchmark.py
```

## Files

- `01_baseline.sql` - Queries WITHOUT indexes
- `02_create_indexes.sql` - Create aggregating indexes on logs
- `03_optimized.sql` - Same queries with indexes
- `benchmark.py` - Automated comparison
