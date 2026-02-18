# Query optimizer controls

Control cost-based optimization and join ordering so you get predictable plans or full manual control when you know your data better than the optimizer.

## What it does

- **Optimizer mode** – `SET optimizer_mode = 'user_guided'` (or `WITH (optimizer_mode = 'user_guided')`) disables cost-based join reordering, aggregate push-down, subquery decorrelation, and common sub-plan discovery. Use when you want to enforce a specific join order or plan shape.
- **Join ordering hint** – `/*! no_join_ordering */` in a query disables only join reordering, leaving other optimizations on. Place smaller tables on the right (build side) of joins for optimal hash table construction.

## When to use

- Complex multi-way joins where the optimizer picks a slow order and you know a better one.
- Reproducible benchmarks (same plan every time).
- Debugging or validating a specific plan.

## Runtime

**Core + Cloud.** Demo runs on both Firebolt Core and Firebolt Cloud.

## Syntax

```sql
-- Session-level: full manual control
SET optimizer_mode = 'user_guided';
SELECT ... FROM large_tbl JOIN small_tbl ON ...;

-- Per-query
SELECT ... WITH (optimizer_mode = 'user_guided');

-- Hint: disable only join reordering
/*! no_join_ordering */
SELECT * FROM large_table
JOIN small_table1 ON ...
JOIN small_table2 ON ...;
```

## Further reading

- [docs/DEEP_CONTROL.md](../../docs/DEEP_CONTROL.md) – Query planning controls
- [Firebolt system settings](https://docs.firebolt.io/reference/system-settings) – optimizer_mode, query hints
