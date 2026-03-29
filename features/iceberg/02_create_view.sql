-- Iceberg Read Experience: Create demo views from LOCATIONs
-- Prerequisite: Run 01_create_locations_tpch.sql first (creates tpch_lineitem, etc.).
--
-- These views are used by the baseline, optimized, benchmark, and tpch_queries.sql.
-- All 8 TPC-H tables exposed as iceberg_* views with metadata caching (1 hour).

-- =============================================================================
-- DATABASE (already created by 01_create_locations_tpch.sql)
-- =============================================================================

USE iceberg_demo;

-- =============================================================================
-- CREATE VIEWs from LOCATIONs (all 8 TPC-H tables)
-- =============================================================================

DROP VIEW IF EXISTS iceberg_lineitem;
CREATE VIEW iceberg_lineitem AS
SELECT * FROM READ_ICEBERG(LOCATION => 'tpch_lineitem', MAX_STALENESS => INTERVAL '1' HOUR);

DROP VIEW IF EXISTS iceberg_orders;
CREATE VIEW iceberg_orders AS
SELECT * FROM READ_ICEBERG(LOCATION => 'tpch_orders', MAX_STALENESS => INTERVAL '1' HOUR);

DROP VIEW IF EXISTS iceberg_customer;
CREATE VIEW iceberg_customer AS
SELECT * FROM READ_ICEBERG(LOCATION => 'tpch_customer', MAX_STALENESS => INTERVAL '1' HOUR);

DROP VIEW IF EXISTS iceberg_part;
CREATE VIEW iceberg_part AS
SELECT * FROM READ_ICEBERG(LOCATION => 'tpch_part', MAX_STALENESS => INTERVAL '1' HOUR);

DROP VIEW IF EXISTS iceberg_partsupp;
CREATE VIEW iceberg_partsupp AS
SELECT * FROM READ_ICEBERG(LOCATION => 'tpch_partsupp', MAX_STALENESS => INTERVAL '1' HOUR);

DROP VIEW IF EXISTS iceberg_supplier;
CREATE VIEW iceberg_supplier AS
SELECT * FROM READ_ICEBERG(LOCATION => 'tpch_supplier', MAX_STALENESS => INTERVAL '1' HOUR);

DROP VIEW IF EXISTS iceberg_nation;
CREATE VIEW iceberg_nation AS
SELECT * FROM READ_ICEBERG(LOCATION => 'tpch_nation', MAX_STALENESS => INTERVAL '1' HOUR);

DROP VIEW IF EXISTS iceberg_region;
CREATE VIEW iceberg_region AS
SELECT * FROM READ_ICEBERG(LOCATION => 'tpch_region', MAX_STALENESS => INTERVAL '1' HOUR);

-- =============================================================================
-- VERIFICATION
-- =============================================================================

SELECT COUNT(*) AS total_rows FROM iceberg_lineitem;
SELECT COUNT(*) AS total_orders FROM iceberg_orders;
SELECT COUNT(*) AS total_customers FROM iceberg_customer;
SELECT COUNT(*) AS total_parts FROM iceberg_part;
SELECT COUNT(*) AS total_partsupp FROM iceberg_partsupp;
SELECT COUNT(*) AS total_suppliers FROM iceberg_supplier;
SELECT COUNT(*) AS total_nations FROM iceberg_nation;
SELECT COUNT(*) AS total_regions FROM iceberg_region;
