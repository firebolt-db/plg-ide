# Aggregating Indexes Demo - AdTech Vertical

Proves the value of Firebolt's aggregating indexes for campaign and publisher analytics.

## What You'll See

| Query | Without Index | With Index | Improvement |
|-------|---------------|------------|-------------|
| Campaign by Day | ~2,500ms | ~30ms | **80X** |
| Publisher Performance | ~1,800ms | ~25ms | **70X** |
| Device Breakdown | ~1,200ms | ~18ms | **65X** |
| Geo Performance | ~1,500ms | ~22ms | **68X** |

## Quick Start

```bash
# From repo root, ensure FIREBOLT_DATABASE=adtech (or run in adtech DB)
cd verticals/adtech
python -m lib.firebolt run schema/01_tables.sql
python -m lib.firebolt run data/load.sql

cd features/aggregating_indexes
python benchmark.py
```

## Files

- `01_baseline.sql` - Queries WITHOUT indexes
- `02_create_indexes.sql` - Create aggregating indexes on impressions
- `03_optimized.sql` - Same queries with indexes
- `benchmark.py` - Automated comparison
