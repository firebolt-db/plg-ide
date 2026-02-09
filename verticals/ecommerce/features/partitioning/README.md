# Partitioning (E-commerce)

Partition pruning for date-range queries on `order_items` and `orders`.

## Demo files

- `01_baseline.sql` – Queries without partition pruning (full table scan)
- `03_optimized.sql` – Same queries with partition pruning (table partitioned by month on `created_at`)

## For the Loveable app

The **Feature Demo Runner** should load baseline SQL from `01_baseline.sql` and optimized SQL from `03_optimized.sql` so that E-Commerce > Partitioning shows both **Baseline** and **Optimized** inputs and Run buttons.

## Prerequisites

For the optimized run to show real pruning, `order_items` should be created with:

```sql
PARTITION BY DATE_TRUNC('month', created_at)
```

If the schema does not use partitioning yet, the optimized query will behave like the baseline; the demo still shows the same SQL and the intended design.
