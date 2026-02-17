# Automated Column Statistics

Firebolt can collect column statistics (e.g. distinct count) transparently and use them in the query optimizer for better join ordering and cardinality estimates—**without changing your query text**.

**Version requirements:** Requires a Firebolt release that supports automated column statistics. Use the latest Core image; for Cloud, see [Firebolt version requirements](../../docs/FIREBOLT_VERSIONS.md).

## What It Does

- You run `ALTER TABLE ... ADD STATISTICS (column) TYPE ndistinct` on columns that participate in joins or filters.
- Firebolt maintains these statistics (via system-managed aggregating indexes) and keeps them up to date incrementally.
- The optimizer uses the statistics to choose better join order (e.g. build the hash table from the smaller side) and to estimate cardinality after filters more accurately.
- Result: significant speedups (e.g. 3x in the blog example) with no query rewrites.

## How It Works

- Statistics are built on top of Firebolt’s [aggregating indexes](https://docs.firebolt.io/sql-reference/aggregating-indexes). When you add statistics, Firebolt creates a system-managed aggregating index (visible in `SHOW INDEXES` with `created_by=SYSTEM`).
- By default, distinct count is collected using approximate counting (e.g. counting HLL). You can specify `TYPE ndistinct` for distinct count.
- At planning time, the optimizer checks whether tables have automated column statistics; if so, it can infer cardinality and choose a better plan (e.g. swap join order). See `EXPLAIN(STATISTICS)` to see how estimates change.

## When to Use

- **Joins** where the optimizer might pick the wrong build/probe side (e.g. filter on a low-cardinality column yields many rows, but the optimizer assumes high selectivity).
- **Mixed workloads**: same query shape with different filter columns (e.g. filter by device_type vs by customer_id)—statistics help the optimizer adapt.
- **BI, dashboards, LLM-generated queries** where you cannot hand-tune every query.

## Syntax

```sql
ALTER TABLE table_name ADD STATISTICS (column_name) TYPE ndistinct;
-- Repeat for other columns as needed.
```

## Verticals with Demos

| Vertical | Description |
|----------|-------------|
| [Gaming](../../verticals/gaming/features/automated_column_statistics/) | Join playstats + games; filter by game (low cardinality) vs player (high)—better join order with stats. |

## Further Reading

- [Firebolt docs: Automated column statistics](https://docs.firebolt.io/performance-and-observability/query-planning/automated-column-statistics) — Get started, syntax, and behavior.
- Technical deep dive blog (when published) — How statistics are collected (counting HLL), how the optimizer uses them, and `EXPLAIN(STATISTICS)` examples.
