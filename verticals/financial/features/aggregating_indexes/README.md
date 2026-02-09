# Aggregating Indexes Demo - Financial Vertical

Proves the value of Firebolt's aggregating indexes for transaction and risk analytics.

## What You'll See

| Query | Without Index | With Index | Improvement |
|-------|---------------|------------|-------------|
| Transaction Volume by Day | ~2,000ms | ~25ms | **80X** |
| Merchant Performance | ~1,500ms | ~20ms | **75X** |
| Account Activity | ~1,800ms | ~22ms | **80X** |

## Quick Start

```bash
cd verticals/financial
python -m lib.firebolt run schema/01_tables.sql
python -m lib.firebolt run data/load.sql
cd features/aggregating_indexes
python benchmark.py
```

## Files

- `01_baseline.sql` - Queries WITHOUT indexes
- `02_create_indexes.sql` - Create aggregating indexes on transactions
- `03_optimized.sql` - Same queries with indexes
- `benchmark.py` - Automated comparison
