# Cross-region data access

Control whether Firebolt can read from S3 buckets in a different region than the engine (COPY INTO and external tables).

## What it does

- **CROSS_REGION_REQUEST_MODE** in COPY (or equivalent for external tables) – `disabled` (default) blocks cross-region; `auto` infers region; `enforced` uses aws-global pseudo-region.
- Enables ingestion from buckets in another region when required by architecture or data locality.

## When to use

- Ingesting from S3 in a different region than the Firebolt engine.
- Centralizing data from multiple regions into one warehouse.

## Runtime

**Cloud only.** Cross-region COPY behavior is available on Firebolt Cloud. When connected to **Firebolt Core**, the app shows the example SQL as reference and a notice that the capability is available in Firebolt Cloud; Run is disabled.

## Syntax

```sql
-- Cloud: allow cross-region COPY
COPY INTO table FROM 's3://bucket/'
WITH (
  TYPE = PARQUET,
  CROSS_REGION_REQUEST_MODE = 'auto'  -- or 'enforced'
);
```

**Modes:** `disabled` (default), `auto`, `enforced`.

## Further reading

- [docs/DEEP_CONTROL.md](../../docs/DEEP_CONTROL.md) – Cross-region data access (Cloud only)
- [Firebolt COPY FROM](https://docs.firebolt.io/reference-sql/commands/data-management/copy-from) – COPY options
