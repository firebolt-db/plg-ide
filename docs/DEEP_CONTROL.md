# Deep control settings and features

Firebolt provides extensive control mechanisms across multiple layers for knowledgeable users to optimize their workloads. This document lists the controls, their runtime availability, and how they map to plg-ide demos.

**Runtime:** Each control is labeled **Core + Cloud** (demoable on both) or **Cloud only** (demoable in a vertical when connected to Firebolt Cloud; when connected to Core, the app shows examples and a "Cloud only" notice). See [docs/APP_SPEC.md](APP_SPEC.md) (§ Runtime-specific features) and [docs/FIREBOLT_VERSIONS.md](FIREBOLT_VERSIONS.md).

---

## Query Planning & Optimization Controls

### 1. Optimizer Mode — **Core + Cloud**

Control cost-based optimization behavior:

```sql
-- Disable cost-based optimization for full manual control
SET optimizer_mode = 'user_guided';
SELECT ... FROM t1 JOIN t2 JOIN t3 ...;

-- Or per-query
SELECT ... WITH (optimizer_mode = 'user_guided');
```

**Impact:** Disables join reordering, aggregate push-down, subquery decorrelation, and common sub-plan discovery.

### 2. Join Ordering Hint — **Core + Cloud**

Granular control without disabling all optimizations:

```sql
/*! no_join_ordering */
SELECT * FROM large_table
JOIN small_table1 ON ...
JOIN small_table2 ON ...;
```

**Best Practice:** Place smaller tables on the right side (build side) of joins for optimal hash table construction.

### 3. Automated Column Statistics — **Core + Cloud**

Leverage aggregating indexes for better cardinality estimation:

```sql
SET enable_automated_column_statistics = true;
```

**Requires:** Pre-created aggregating indexes with `APPROX_COUNT_DISTINCT` on relevant columns. See feature [Automated Column Statistics](../features/automated_column_statistics/README.md).

---

## Parallelism & Resource Controls

### 4. Thread Limits — **Core + Cloud**

Control query parallelism per node:

```sql
-- Limit overall query parallelism
SET max_threads = 8;

-- Or per-query
SELECT ... WITH (max_threads = 8);
```

**Use Case:** Reduce memory pressure or prevent resource contention.

### 5. Insert Thread Limits — **Core + Cloud**

Control write parallelism during ingestion:

```sql
INSERT INTO table
SELECT ...
WITH (max_insert_threads = 1);
```

**Impact:** Reduces concurrent tablet buffers, lowering memory footprint during ingestion.

---

## Data Layout & Ingestion Controls

### 6. Tablet Sizing — **Core + Cloud**

Fine-tune data file sizes for read/write trade-offs:

```sql
SET tablet_min_size_bytes = 4294967296;  -- 4GB
SET tablet_max_size_bytes = 4294967296;

INSERT INTO table SELECT ...
WITH (
  tablet_min_size_bytes = 4294967296,
  tablet_max_size_bytes = 4294967296
);
```

**Trade-off:** Larger tablets = better read performance but slower ingestion.

### 7. Partition Limits — **Core + Cloud**

Control partition proliferation during ingestion:

```sql
SET max_table_partitions_on_insert = 1000;
```

**Use Case:** Prevent excessive partition creation that can degrade performance. Set to `0` to disable limits.

### 8. Cross-Region Data Access — **Cloud only**

Control S3 cross-region behavior (Firebolt Cloud; not available on Core):

```sql
COPY INTO table FROM 's3://bucket/'
WITH (
  TYPE = PARQUET,
  CROSS_REGION_REQUEST_MODE = 'auto'  -- or 'enforced'
);
```

**Modes:** `disabled` (default), `auto`, `enforced`. When connected to Core, this is shown as reference only; run on Cloud to demo.

---

## Schema-Level Optimizations

### 9. Table Type Selection — **Core + Cloud**

Choose between fact and dimension tables:

```sql
-- Sharded across nodes (for large tables)
CREATE FACT TABLE large_fact (...)
PARTITION BY EXTRACT(MONTH FROM date_col)
PRIMARY INDEX key_col;

-- Replicated to all nodes (for small lookup tables)
CREATE DIMENSION TABLE small_dim (...);
```

### 10. Partitioning Strategy — **Core + Cloud**

Control data pruning and file organization. See feature [Partitioning](../verticals/ecommerce/features/partitioning/README.md).

```sql
CREATE TABLE events (
  event_date DATE,
  user_id BIGINT,
  ...
)
PARTITION BY EXTRACT(MONTH FROM event_date)
PRIMARY INDEX user_id;
```

**Impact:** Enables partition pruning for faster queries on partitioned columns.

### 11. Primary Index Design — **Core + Cloud**

Define sort order within tablets:

```sql
PRIMARY INDEX col1, col2, col3
```

**Best Practice:** Order by cardinality (low to high) and query filter frequency.

### 12. Aggregating Indexes — **Core + Cloud**

Pre-compute expensive aggregations. See feature [Aggregating Indexes](../features/aggregating_indexes/README.md).

```sql
CREATE AGGREGATING INDEX player_stats_agg
ON playstats (
  playerid,
  gameid,
  AVG(currentscore),
  SUM(currentplaytime),
  MAX(currentlevel),
  COUNT(*)
);
```

**Maintenance:** Automatically updated by Firebolt on data changes.

---

## Engine-Level Controls — **Cloud only**

These controls require Firebolt Cloud (engine management APIs/UI). When connected to Core, the app shows SQL and DDL as reference and a "Cloud only" notice.

### 13. Auto Vacuum

Control background compaction:

```sql
ALTER ENGINE my_engine SET AUTO_VACUUM = OFF;
```

**Trade-off:** ON = better read performance but uses background resources; OFF = all resources for queries.

### 14. Auto-Scaling

Configure cluster scaling:

```sql
CREATE ENGINE my_engine WITH
  MIN_CLUSTERS = 1
  MAX_CLUSTERS = 5
  AUTO_START = true;
```

**Impact:** Adapts to workload concurrency automatically.

### 15. Auto-Stop

Configure idle timeout to control costs (typically via Cloud UI: set idle timeout, default 20 minutes). Prevents unnecessary compute consumption.

---

## Caching & Data Warming

### 16. Strategic Data Warming — **Core + Cloud**

Pre-load frequently accessed data into cache:

```sql
-- Warm entire table
SELECT CHECKSUM(*) FROM large_table;

-- Warm filtered subset
SELECT CHECKSUM(*) FROM large_table
WHERE date >= '2024-01-01';

-- Warm in parallel segments
SELECT CHECKSUM(*) FROM large_table WHERE MOD(id, 4) = 0;
SELECT CHECKSUM(*) FROM large_table WHERE MOD(id, 4) = 1;
-- etc.
```

---

## Summary Matrix

| Control Level   | Setting / area              | Runtime     | Primary Use Case                    |
|----------------|-----------------------------|------------|-------------------------------------|
| Query Planning | optimizer_mode, no_join_ordering | Core + Cloud | Complex joins, predictable plans    |
| Query Planning | Automated Column Statistics | Core + Cloud | Cardinality estimation, join order  |
| Parallelism    | max_threads, max_insert_threads | Core + Cloud | Memory management, concurrency     |
| Data Layout    | Tablet sizing, partition limits | Core + Cloud | Read/write optimization             |
| Data Layout    | Cross-region (COPY)         | **Cloud only** | S3 cross-region ingestion           |
| Schema         | FACT/DIMENSION, partitioning, primary index, aggregating indexes | Core + Cloud | Query acceleration                  |
| Engine         | Auto-vacuum, auto-scaling, auto-stop | **Cloud only** | Resource allocation, cost control  |
| Caching        | Data warming strategies     | Core + Cloud | Latency optimization                |

These controls allow you to optimize across the entire spectrum from physical data layout to query execution strategy. In plg-ide: **Cloud** users can run full demos for all of the above in a vertical; **Core** users can run demos for Core + Cloud items and see examples + "Cloud only" messaging for Cloud-only items.
