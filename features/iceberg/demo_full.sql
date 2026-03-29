-- =============================================================================
-- FIREBOLT plg-ide: Iceberg Read Experience Demo
-- =============================================================================
-- 
-- This script demonstrates Firebolt's native Iceberg support through a
-- step-by-step walkthrough of querying TPCH lineitem data from S3.
-- Experience the dramatic performance improvements from partition pruning,
-- column pruning, and metadata caching.
--
-- TARGET: Firebolt Cloud (Iceberg requires Cloud, not Core)
-- EXPECTED DURATION: ~10-15 minutes
-- 
-- =============================================================================
--
-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │                         PREREQUISITES                                        │
-- ├─────────────────────────────────────────────────────────────────────────────┤
-- │                                                                             │
-- │  FIREBOLT CLOUD (Required):                                                 │
-- │    1. Sign up at https://go.firebolt.io/ (free trial available)            │
-- │    2. Create an ENGINE (start with 'S' size for demos)                     │
-- │       → In UI: Engines → Create Engine → Name it → Start it                │
-- │    3. Database will be created automatically (iceberg_demo)                  │
-- │       → The script creates it if it doesn't exist                           │
-- │    4. Connect your SQL client to the engine                                │
-- │       → Use service account credentials (Govern → Service Accounts)        │
-- │                                                                             │
-- │  NOTE: This demo uses Firebolt's public TPCH dataset - no AWS credentials   │
-- │        needed! The data is already in S3 and accessible.                    │
-- │                                                                             │
-- └─────────────────────────────────────────────────────────────────────────────┘
--
-- =============================================================================
--
-- ┌─────────────────────────────────────────────────────────────────────────────┐
-- │                    FOR PRESENTERS: KEY TALKING POINTS                       │
-- ├─────────────────────────────────────────────────────────────────────────────┤
-- │                                                                             │
-- │  OPENING (Stage 0-1):                                                       │
-- │  "We're querying Apache Iceberg tables directly from S3 - no data          │
-- │   migration needed. This is the TPCH lineitem dataset, a standard          │
-- │   benchmark table with millions of rows partitioned by ship date."         │
-- │                                                                             │
-- │  BASELINE (Stage 2):                                                        │
-- │  "Watch these queries - they're scanning entire partitions, reading all      │
-- │   columns. In production with terabytes of data, these would take          │
-- │   minutes or even timeout."                                                │
-- │                                                                             │
-- │  THE MAGIC (Stage 3):                                                       │
-- │  "Now we create an external table with metadata caching. Firebolt uses    │
-- │   Iceberg's manifest files to understand the table structure and          │
-- │   partition layout - no manual configuration needed."                     │
-- │                                                                             │
-- │  THE PAYOFF (Stage 4):                                                      │
-- │  "Same queries, but now with partition pruning. Look at the timing -       │
-- │   10-100X faster. Firebolt skips entire partitions that don't match        │
-- │   our filters, reading only what's needed."                                │
-- │                                                                             │
-- │  THE PROOF (Stage 5):                                                       │
-- │  "Column pruning - selecting only needed columns reduces I/O by 30-70%.     │
-- │   Combine partition pruning + column pruning, and you get sub-second       │
-- │   queries on terabyte-scale datasets."                                      │
-- │                                                                             │
-- │  BUSINESS VALUE:                                                           │
-- │  • "Query data lakes directly - no ETL, no data migration"                  │
-- │  • "Sub-second queries on TB-scale Iceberg tables"                         │
-- │  • "Open table format - no vendor lock-in"                                 │
-- │  • "Every partition skipped = money saved on compute"                      │
-- │                                                                             │
-- │  COMPETITIVE ANGLE:                                                        │
-- │  • "Snowflake requires external tables but slower metadata reads"          │
-- │  • "BigQuery supports Iceberg but with less efficient pruning"            │
-- │  • "Databricks requires Spark - Firebolt uses native SQL"                   │
-- │                                                                             │
-- └─────────────────────────────────────────────────────────────────────────────┘
--
-- =============================================================================


-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║                        STAGE 0: ENVIRONMENT SETUP                         ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝
-- Purpose: Verify connection and check Firebolt version
-- Run this first to ensure your environment is ready

-- Check Firebolt version (verifies your connection is working)
SELECT version() AS firebolt_version;

-- Verify we're on Cloud (Iceberg requires Cloud)
SELECT 
    CASE 
        WHEN version() LIKE '%Cloud%' THEN '✓ Firebolt Cloud detected'
        ELSE '⚠ Warning: Iceberg support requires Firebolt Cloud'
    END AS runtime_check;

-- Create database if it doesn't exist
CREATE DATABASE IF NOT EXISTS iceberg_demo;

-- Use the database
USE iceberg_demo;


-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║                    STAGE 1: SETUP (LOCATION + VIEW)                        ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝
-- Prerequisite: Run 01_create_locations_tpch.sql then 02_create_view.sql
-- to create LOCATION tpch_lineitem and view iceberg_lineitem.
-- This demo then queries iceberg_lineitem.

USE iceberg_demo;

-- Verify view (created by 02_create_view.sql)
DESCRIBE iceberg_lineitem;

-- Quick test query
SELECT COUNT(*) as total_rows FROM iceberg_lineitem LIMIT 1;

-- Check partition distribution
SELECT 
    DATE_TRUNC('month', l_shipdate) as ship_month,
    COUNT(*) as row_count
FROM iceberg_lineitem
GROUP BY 1
ORDER BY ship_month DESC
LIMIT 10;


-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║                    STAGE 2: BASELINE QUERIES (SLOW)                      ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝
-- Purpose: Demonstrate unoptimized query patterns
-- These queries scan more data than necessary

SET enable_result_cache = FALSE;

-- Query 1: Full table scan without partition filtering
-- Problem: Scans ALL partitions, even though we only need recent data
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

-- Query 2: Filter on non-partition column
-- Problem: Can't skip partitions, must scan all then filter
EXPLAIN ANALYZE
SELECT 
    l_returnflag,
    l_linestatus,
    COUNT(*) as line_count,
    SUM(l_extendedprice) as total_revenue
FROM iceberg_lineitem
WHERE l_returnflag = 'R'  -- Not a partition column!
GROUP BY l_returnflag, l_linestatus
ORDER BY total_revenue DESC;

-- Query 3: SELECT * on wide table
-- Problem: Reads all columns even though we only need a few
EXPLAIN ANALYZE
SELECT *
FROM iceberg_lineitem
WHERE l_shipdate >= DATE '1998-01-01'
LIMIT 1000;

SET enable_result_cache = TRUE;

-- Note the execution times and data scanned in the EXPLAIN ANALYZE output
-- These are intentionally inefficient patterns


-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║                    STAGE 3: OPTIMIZED QUERIES (FAST)                     ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝
-- Purpose: Demonstrate optimized query patterns with partition pruning
-- Same queries, but now using best practices

SET enable_result_cache = FALSE;

-- Query 1: Partition pruning
-- Solution: Filter on partition column (l_shipdate) to skip irrelevant partitions
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

-- Query 2: Partition + column pruning
-- Solution: Filter on partition column AND select only needed columns
EXPLAIN ANALYZE
SELECT 
    l_returnflag,
    l_linestatus,
    COUNT(*) as line_count,
    SUM(l_extendedprice) as total_revenue
FROM iceberg_lineitem
WHERE l_shipdate >= DATE '1998-01-01'  -- Partition filter first
  AND l_shipdate < DATE '1998-07-01'    -- Partition filter
  AND l_returnflag = 'R'                -- Regular filter (applied after partition pruning)
GROUP BY l_returnflag, l_linestatus
ORDER BY total_revenue DESC;

-- Query 3: Column selection
-- Solution: Select only needed columns instead of SELECT *
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

SET enable_result_cache = TRUE;

-- Compare the execution times and data scanned
-- Notice the dramatic improvement from partition pruning and column selection


-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║                    STAGE 4: TIME-SERIES AGGREGATION                      ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝
-- Purpose: Demonstrate efficient time-range queries with partition pruning

SET enable_result_cache = FALSE;

-- Weekly revenue trends with partition pruning
EXPLAIN ANALYZE
SELECT 
    DATE_TRUNC('week', l_shipdate) as ship_week,
    l_returnflag,
    l_linestatus,
    COUNT(*) as line_count,
    SUM(l_extendedprice) as weekly_revenue,
    AVG(l_extendedprice) as avg_price,
    COUNT(DISTINCT l_orderkey) as unique_orders
FROM iceberg_lineitem
WHERE l_shipdate >= DATE '1998-01-01'  -- Partition filter
  AND l_shipdate < DATE '1998-12-31'   -- Partition filter
GROUP BY 1, 2, 3
HAVING COUNT(*) >= 100  -- Filter aggregated results
ORDER BY ship_week DESC, weekly_revenue DESC
LIMIT 100;

SET enable_result_cache = TRUE;


-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║                    STAGE 5: VERIFICATION                                  ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝
-- Purpose: Verify optimizations are working and show metadata usage

-- Check view metadata
SELECT table_name, table_type FROM information_schema.tables WHERE table_name = 'iceberg_lineitem';

-- Sample query to verify partition pruning is working
-- Look for "PartitionFilter" or "IcebergMetadataPruning" in EXPLAIN output
EXPLAIN ANALYZE
SELECT 
    COUNT(*) as row_count,
    SUM(l_extendedprice) as total_revenue
FROM iceberg_lineitem
WHERE l_shipdate >= DATE '1998-01-01'
  AND l_shipdate < DATE '1998-02-01';

-- Summary statistics
SELECT 
    MIN(l_shipdate) as earliest_ship_date,
    MAX(l_shipdate) as latest_ship_date,
    COUNT(*) as total_rows,
    COUNT(DISTINCT l_orderkey) as unique_orders
FROM iceberg_lineitem;


-- ╔═══════════════════════════════════════════════════════════════════════════╗
-- ║                    STAGE 6: KEY TAKEAWAYS                                ║
-- ╚═══════════════════════════════════════════════════════════════════════════╝
-- 
-- What you've learned:
-- 
-- 1. PARTITION PRUNING: Filter on partition columns (l_shipdate) to skip
--    entire partitions, reducing data scanned by 10-100X
-- 
-- 2. COLUMN PRUNING: Select only needed columns to reduce I/O by 30-70%
-- 
-- 3. METADATA CACHING: Use max_staleness to cache Iceberg metadata for
--    faster repeated queries (20-50% improvement)
-- 
-- 4. PREDICATE PUSHDOWN: Firebolt pushes filters to Iceberg layer for
--    early filtering before reading data files
-- 
-- 5. SUB-SECOND QUERIES: With proper optimization, achieve millisecond
--    query latency on terabyte-scale Iceberg datasets
-- 
-- Next steps:
-- - Run demo_comparison.sql for side-by-side metrics
-- - Try the benchmark.py script for automated comparisons
-- - Explore features/iceberg/README.md for more details
-- 
-- =============================================================================
