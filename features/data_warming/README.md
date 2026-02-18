# Data warming

Pre-load frequently accessed data into the engine cache so subsequent queries hit cache instead of cold storage, reducing latency.

## What it does

- Run a full scan (e.g. `SELECT CHECKSUM(*) FROM large_table`) to pull data into cache.
- Optionally warm a filtered subset (e.g. by date) or parallel segments (e.g. `WHERE MOD(id, 4) = 0`) for large tables.
- After warming, repeat queries typically show lower bytes read from storage and faster runtimes.

## When to use

- Before a demo or critical report on a cold engine.
- After loading new data that will be queried immediately.
- Reducing p99 latency for hot paths.

## Runtime

**Core + Cloud.** Demo runs on both Firebolt Core and Firebolt Cloud.

## Syntax

```sql
-- Warm entire table
SELECT CHECKSUM(*) FROM large_table;

-- Warm filtered subset
SELECT CHECKSUM(*) FROM large_table WHERE date >= '2024-01-01';

-- Warm in parallel segments (run multiple queries)
SELECT CHECKSUM(*) FROM large_table WHERE MOD(id, 4) = 0;
SELECT CHECKSUM(*) FROM large_table WHERE MOD(id, 4) = 1;
```

## Further reading

- [docs/DEEP_CONTROL.md](../../docs/DEEP_CONTROL.md) – Caching & data warming
- [Firebolt query performance](https://docs.firebolt.io/overview/queries/understand-query-performance-subresult) – result and subresult cache
