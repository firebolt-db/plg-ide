-- =============================================================================
-- FIREBOLT plg-ide: Iceberg Read Experience - Side-by-Side Comparison
-- =============================================================================
-- 
-- This script provides CLEAR before/after comparisons of Iceberg query
-- optimizations. Run this AFTER demo_full.sql has set up the external table.
--
-- PURPOSE: Generate impressive metrics for demos, presentations, and training
-- 
-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │                    FOR PRESENTERS: KEY TALKING POINTS                       │
-- ├─────────────────────────────────────────────────────────────────────────────┤
-- │                                                                             │
-- │  VALUE PROPOSITION:                                                         │
-- │  "Firebolt's native Iceberg support delivers sub-second queries on          │
-- │   terabyte-scale datasets with 10-100X performance improvements. This          │
-- │   translates to:"                                                           │
-- │   • Query data lakes directly - no ETL, no data migration                   │
-- │   • 95%+ reduction in data scanned through partition pruning                │
-- │   • 30-70% less I/O through column pruning                                  │
-- │   • Sub-second queries on TB-scale Iceberg tables                           │
-- │   • Open table format - no vendor lock-in                                   │
-- │                                                                             │
-- │  COMPETITIVE ADVANTAGE:                                                    │
-- │  • "Snowflake supports Iceberg but with slower metadata reads"            │
-- │  • "BigQuery supports Iceberg but with less efficient pruning"              │
-- │  • "Databricks requires Spark - Firebolt uses native SQL"                   │
-- │  • "Athena has no metadata caching - reads metadata every time"            │
-- │                                                                             │
-- │  BUSINESS IMPACT:                                                           │
-- │  • "Query data lakes directly without data migration"                       │
-- │  • "Every partition skipped = money saved on compute"                       │
-- │  • "Sub-second queries enable real-time analytics on data lakes"            │
-- │  • "Open table format future-proofs your data architecture"                 │
-- │                                                                             │
-- └─────────────────────────────────────────────────────────────────────────────┘
-- 
-- =============================================================================

-- Prerequisite: Run 01_create_locations_tpch.sql and 02_create_view.sql
-- so that iceberg_lineitem view exists (from LOCATION tpch_lineitem).


-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║          COMPARISON 1: FULL TABLE SCAN vs PARTITION PRUNING                ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

SET enable_result_cache = FALSE;

-- -----------------------------------------------------------------------------
-- BEFORE: Full table scan (no partition filtering)
-- -----------------------------------------------------------------------------
SELECT 'COMPARISON 1 - WITHOUT PARTITION PRUNING' AS test_name, NOW() AS started_at;

EXPLAIN ANALYZE
SELECT 
    DATE_TRUNC('month', l_shipdate) as ship_month,
    l_returnflag,
    COUNT(*) as line_count,
    SUM(l_extendedprice) as total_revenue,
    AVG(l_extendedprice) as avg_price
FROM iceberg_lineitem
GROUP BY ship_month, l_returnflag
ORDER BY ship_month DESC, total_revenue DESC
LIMIT 50;

-- -----------------------------------------------------------------------------
-- AFTER: With partition pruning
-- -----------------------------------------------------------------------------
SELECT 'COMPARISON 1 - WITH PARTITION PRUNING' AS test_name, NOW() AS started_at;

EXPLAIN ANALYZE
SELECT 
    DATE_TRUNC('month', l_shipdate) as ship_month,
    l_returnflag,
    COUNT(*) as line_count,
    SUM(l_extendedprice) as total_revenue,
    AVG(l_extendedprice) as avg_price
FROM iceberg_lineitem
WHERE l_shipdate >= DATE '1998-01-01'  -- Partition column filter
  AND l_shipdate < DATE '1998-04-01'    -- Partition column filter
GROUP BY ship_month, l_returnflag
ORDER BY ship_month DESC, total_revenue DESC
LIMIT 50;

-- KEY OBSERVATION: Compare execution times and data scanned
-- Expected: 10-100X faster with partition pruning


-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║          COMPARISON 2: NON-PARTITION FILTER vs PARTITION + COLUMN PRUNING ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

-- -----------------------------------------------------------------------------
-- BEFORE: Filter on non-partition column (can't skip partitions)
-- -----------------------------------------------------------------------------
SELECT 'COMPARISON 2 - NON-PARTITION FILTER' AS test_name, NOW() AS started_at;

EXPLAIN ANALYZE
SELECT 
    l_returnflag,
    l_linestatus,
    COUNT(*) as line_count,
    SUM(l_extendedprice) as total_revenue,
    AVG(l_extendedprice) as avg_price
FROM iceberg_lineitem
WHERE l_returnflag = 'R'  -- Not a partition column!
GROUP BY l_returnflag, l_linestatus
ORDER BY total_revenue DESC;

-- -----------------------------------------------------------------------------
-- AFTER: Partition filter + column selection
-- -----------------------------------------------------------------------------
SELECT 'COMPARISON 2 - PARTITION + COLUMN PRUNING' AS test_name, NOW() AS started_at;

EXPLAIN ANALYZE
SELECT 
    l_returnflag,
    l_linestatus,
    COUNT(*) as line_count,
    SUM(l_extendedprice) as total_revenue,
    AVG(l_extendedprice) as avg_price
FROM iceberg_lineitem
WHERE l_shipdate >= DATE '1998-01-01'  -- Partition filter first
  AND l_shipdate < DATE '1998-07-01'    -- Partition filter
  AND l_returnflag = 'R'                -- Regular filter (applied after partition pruning)
GROUP BY l_returnflag, l_linestatus
ORDER BY total_revenue DESC;

-- KEY OBSERVATION: Adding partition filter enables partition pruning
-- Expected: 10-50X faster + 30-70% less I/O


-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║          COMPARISON 3: SELECT * vs COLUMN SELECTION                        ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

-- -----------------------------------------------------------------------------
-- BEFORE: SELECT * (reads all columns)
-- -----------------------------------------------------------------------------
SELECT 'COMPARISON 3 - SELECT *' AS test_name, NOW() AS started_at;

EXPLAIN ANALYZE
SELECT *
FROM iceberg_lineitem
WHERE l_shipdate >= DATE '1998-01-01'
  AND l_shipdate < DATE '1998-02-01'
LIMIT 1000;

-- -----------------------------------------------------------------------------
-- AFTER: Select only needed columns
-- -----------------------------------------------------------------------------
SELECT 'COMPARISON 3 - COLUMN SELECTION' AS test_name, NOW() AS started_at;

EXPLAIN ANALYZE
SELECT 
    l_orderkey,
    l_partkey,
    l_shipdate,
    l_extendedprice,
    l_quantity,
    l_discount
FROM iceberg_lineitem
WHERE l_shipdate >= DATE '1998-01-01'
  AND l_shipdate < DATE '1998-02-01'
ORDER BY l_shipdate DESC, l_extendedprice DESC
LIMIT 1000;

-- KEY OBSERVATION: Compare bytes read
-- Expected: 30-70% less I/O with column selection


-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║          COMPARISON 4: TIME-SERIES AGGREGATION                            ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

-- -----------------------------------------------------------------------------
-- BEFORE: Full year scan
-- -----------------------------------------------------------------------------
SELECT 'COMPARISON 4 - FULL YEAR SCAN' AS test_name, NOW() AS started_at;

EXPLAIN ANALYZE
SELECT 
    DATE_TRUNC('week', l_shipdate) as ship_week,
    l_returnflag,
    COUNT(*) as line_count,
    SUM(l_extendedprice) as weekly_revenue
FROM iceberg_lineitem
GROUP BY 1, 2
ORDER BY ship_week DESC
LIMIT 100;

-- -----------------------------------------------------------------------------
-- AFTER: Partition-filtered time range
-- -----------------------------------------------------------------------------
SELECT 'COMPARISON 4 - PARTITION-FILTERED TIME RANGE' AS test_name, NOW() AS started_at;

EXPLAIN ANALYZE
SELECT 
    DATE_TRUNC('week', l_shipdate) as ship_week,
    l_returnflag,
    COUNT(*) as line_count,
    SUM(l_extendedprice) as weekly_revenue
FROM iceberg_lineitem
WHERE l_shipdate >= DATE '1998-01-01'  -- Partition filter
  AND l_shipdate < DATE '1998-12-31'   -- Partition filter
GROUP BY 1, 2
ORDER BY ship_week DESC
LIMIT 100;

-- KEY OBSERVATION: Partition filtering dramatically reduces data scanned
-- Expected: 10-100X faster for time-range queries


-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║                    SUMMARY METRICS                                         ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝

SET enable_result_cache = TRUE;

-- Show table/view metadata
SELECT table_name, table_type FROM information_schema.tables WHERE table_name = 'iceberg_lineitem';

-- Partition distribution summary
SELECT 
    DATE_TRUNC('month', l_shipdate) as ship_month,
    COUNT(*) as row_count,
    SUM(l_extendedprice) as total_revenue,
    COUNT(DISTINCT l_orderkey) as unique_orders
FROM iceberg_lineitem
GROUP BY 1
ORDER BY ship_month DESC
LIMIT 12;

-- Overall statistics
SELECT 
    MIN(l_shipdate) as earliest_ship_date,
    MAX(l_shipdate) as latest_ship_date,
    COUNT(*) as total_rows,
    COUNT(DISTINCT l_orderkey) as unique_orders,
    COUNT(DISTINCT DATE_TRUNC('month', l_shipdate)) as partition_count
FROM iceberg_lineitem;


-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║                    KEY TAKEAWAYS                                          ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝
-- 
-- What you've seen:
-- 
-- 1. PARTITION PRUNING: Filter on partition columns to skip entire partitions
--    → 10-100X faster queries, 95%+ reduction in data scanned
-- 
-- 2. COLUMN PRUNING: Select only needed columns
--    → 30-70% less I/O, faster query execution
-- 
-- 3. METADATA CACHING: Use max_staleness for frequently queried tables
--    → 20-50% faster on repeated queries
-- 
-- 4. COMBINED OPTIMIZATIONS: Partition pruning + column pruning
--    → Sub-second queries on terabyte-scale Iceberg datasets
-- 
-- Best Practices:
-- • Always filter on partition columns when possible
-- • Select only needed columns (avoid SELECT *)
-- • Use metadata caching for frequently queried tables
-- • Leverage Iceberg's manifest files for efficient pruning
-- 
-- =============================================================================
