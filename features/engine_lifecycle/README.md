# Engine lifecycle controls

Configure engine behavior: background compaction (auto-vacuum), cluster scaling (min/max clusters), and idle timeout (auto-stop) to balance performance and cost.

## What it does

- **Auto vacuum** – `ALTER ENGINE ... SET AUTO_VACUUM = OFF/ON`. When ON, Firebolt runs background compaction for better read performance; when OFF, all resources go to queries.
- **Auto-scaling** – `CREATE ENGINE ... WITH MIN_CLUSTERS = 1, MAX_CLUSTERS = 5` (and `AUTO_START = true`) so the engine scales with concurrency.
- **Auto-stop** – Idle timeout (e.g. 20 minutes) is typically set in the Firebolt Cloud UI to stop the engine when idle and reduce cost.

## When to use

- Tuning read vs background workload (auto-vacuum).
- Variable concurrency (auto-scaling).
- Cost control (auto-stop).

## Runtime

**Cloud only.** These controls require Firebolt Cloud (engine management APIs/UI). When connected to **Firebolt Core**, the app shows the SQL and DDL as reference and a notice that the capability is available in Firebolt Cloud; Run is disabled.

## Syntax

```sql
-- Auto vacuum (Cloud)
ALTER ENGINE my_engine SET AUTO_VACUUM = OFF;

-- Auto-scaling (Cloud): create engine with min/max clusters
CREATE ENGINE my_engine WITH
  MIN_CLUSTERS = 1,
  MAX_CLUSTERS = 5,
  AUTO_START = true;

-- Auto-stop: configure idle timeout via Firebolt Cloud UI
```

## Further reading

- [docs/DEEP_CONTROL.md](../../docs/DEEP_CONTROL.md) – Engine-level controls (Cloud only)
- [Firebolt engines](https://docs.firebolt.io/concepts/engine-concept) – engine concept and scaling
