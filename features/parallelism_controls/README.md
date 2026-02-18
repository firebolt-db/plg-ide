# Parallelism and resource limits

Control query and insert parallelism so you can reduce memory pressure, avoid resource contention, or tune for predictable throughput.

## What it does

- **max_threads** – Limits how many threads per node are used for a query. Lower values reduce memory and CPU contention; higher values increase throughput for large scans.
- **max_insert_threads** – Limits write parallelism during ingestion. Lower values reduce concurrent tablet buffers and memory footprint during INSERT/SELECT or COPY.

## When to use

- Memory-constrained engines or shared workloads.
- Preventing a single query from dominating the engine.
- Tuning ingestion to avoid OOM or excessive concurrency.

## Runtime

**Core + Cloud.** Demo runs on both Firebolt Core and Firebolt Cloud.

## Syntax

```sql
-- Limit query parallelism (session or per-query)
SET max_threads = 8;
SELECT ... WITH (max_threads = 8);

-- Limit insert parallelism (per-query)
INSERT INTO table SELECT ... WITH (max_insert_threads = 1);
```

## Further reading

- [docs/DEEP_CONTROL.md](../../docs/DEEP_CONTROL.md) – Parallelism & resource controls
- [Firebolt system settings](https://docs.firebolt.io/reference/system-settings) – max_threads, max_insert_threads
