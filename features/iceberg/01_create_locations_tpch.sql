-- Iceberg Read Experience: CREATE LOCATION for each TPCH table
-- Base path: s3://firebolt-publishing-public/help_center_assets/firebolt_sample_iceberg/tpch/iceberg/
--
-- Each location points to one TPC-H Iceberg table. Use with READ_ICEBERG(LOCATION => 'tpch_<table>').
-- Standard TPC-H tables: lineitem, orders, customer, part, partsupp, supplier, nation, region
--
-- For the Firebolt public bucket, READ_ICEBERG(URL => 's3://...') works without credentials.
-- CREATE LOCATION requires CREDENTIALS in the syntax. For this public bucket we use empty strings;
-- if your engine rejects them, replace with valid AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
-- (or use READ_ICEBERG(URL => 's3://...') directly and skip locations).

-- =============================================================================
-- DATABASE SETUP
-- =============================================================================

CREATE DATABASE IF NOT EXISTS iceberg_demo;

USE iceberg_demo;

-- =============================================================================
-- CREATE LOCATION per TPCH table (FILE_BASED catalog)
-- =============================================================================

-- lineitem
CREATE LOCATION IF NOT EXISTS tpch_lineitem WITH
  SOURCE = ICEBERG
  CATALOG = FILE_BASED
  CATALOG_OPTIONS = (
    URL = 's3://firebolt-publishing-public/help_center_assets/firebolt_sample_iceberg/tpch/iceberg/lineitem'
  )
  CREDENTIALS = ( AWS_ACCESS_KEY_ID = '' AWS_SECRET_ACCESS_KEY = '' )
  DESCRIPTION = 'TPCH lineitem Iceberg table (public bucket)';

-- orders
CREATE LOCATION IF NOT EXISTS tpch_orders WITH
  SOURCE = ICEBERG
  CATALOG = FILE_BASED
  CATALOG_OPTIONS = (
    URL = 's3://firebolt-publishing-public/help_center_assets/firebolt_sample_iceberg/tpch/iceberg/orders'
  )
  CREDENTIALS = ( AWS_ACCESS_KEY_ID = '' AWS_SECRET_ACCESS_KEY = '' )
  DESCRIPTION = 'TPCH orders Iceberg table (public bucket)';

-- customer
CREATE LOCATION IF NOT EXISTS tpch_customer WITH
  SOURCE = ICEBERG
  CATALOG = FILE_BASED
  CATALOG_OPTIONS = (
    URL = 's3://firebolt-publishing-public/help_center_assets/firebolt_sample_iceberg/tpch/iceberg/customer'
  )
  CREDENTIALS = ( AWS_ACCESS_KEY_ID = '' AWS_SECRET_ACCESS_KEY = '' )
  DESCRIPTION = 'TPCH customer Iceberg table (public bucket)';

-- part
CREATE LOCATION IF NOT EXISTS tpch_part WITH
  SOURCE = ICEBERG
  CATALOG = FILE_BASED
  CATALOG_OPTIONS = (
    URL = 's3://firebolt-publishing-public/help_center_assets/firebolt_sample_iceberg/tpch/iceberg/part'
  )
  CREDENTIALS = ( AWS_ACCESS_KEY_ID = '' AWS_SECRET_ACCESS_KEY = '' )
  DESCRIPTION = 'TPCH part Iceberg table (public bucket)';

-- partsupp
CREATE LOCATION IF NOT EXISTS tpch_partsupp WITH
  SOURCE = ICEBERG
  CATALOG = FILE_BASED
  CATALOG_OPTIONS = (
    URL = 's3://firebolt-publishing-public/help_center_assets/firebolt_sample_iceberg/tpch/iceberg/partsupp'
  )
  CREDENTIALS = ( AWS_ACCESS_KEY_ID = '' AWS_SECRET_ACCESS_KEY = '' )
  DESCRIPTION = 'TPCH partsupp Iceberg table (public bucket)';

-- supplier
CREATE LOCATION IF NOT EXISTS tpch_supplier WITH
  SOURCE = ICEBERG
  CATALOG = FILE_BASED
  CATALOG_OPTIONS = (
    URL = 's3://firebolt-publishing-public/help_center_assets/firebolt_sample_iceberg/tpch/iceberg/supplier'
  )
  CREDENTIALS = ( AWS_ACCESS_KEY_ID = '' AWS_SECRET_ACCESS_KEY = '' )
  DESCRIPTION = 'TPCH supplier Iceberg table (public bucket)';

-- nation
CREATE LOCATION IF NOT EXISTS tpch_nation WITH
  SOURCE = ICEBERG
  CATALOG = FILE_BASED
  CATALOG_OPTIONS = (
    URL = 's3://firebolt-publishing-public/help_center_assets/firebolt_sample_iceberg/tpch/iceberg/nation'
  )
  CREDENTIALS = ( AWS_ACCESS_KEY_ID = '' AWS_SECRET_ACCESS_KEY = '' )
  DESCRIPTION = 'TPCH nation Iceberg table (public bucket)';

-- region
CREATE LOCATION IF NOT EXISTS tpch_region WITH
  SOURCE = ICEBERG
  CATALOG = FILE_BASED
  CATALOG_OPTIONS = (
    URL = 's3://firebolt-publishing-public/help_center_assets/firebolt_sample_iceberg/tpch/iceberg/region'
  )
  CREDENTIALS = ( AWS_ACCESS_KEY_ID = '' AWS_SECRET_ACCESS_KEY = '' )
  DESCRIPTION = 'TPCH region Iceberg table (public bucket)';

-- =============================================================================
-- USAGE (after locations exist)
-- =============================================================================
-- SELECT * FROM READ_ICEBERG(LOCATION => 'tpch_lineitem', MAX_STALENESS => INTERVAL '1' HOUR) LIMIT 10;
-- SELECT * FROM READ_ICEBERG(LOCATION => 'tpch_orders',   MAX_STALENESS => INTERVAL '1' HOUR) LIMIT 10;
-- SELECT * FROM READ_ICEBERG(LOCATION => 'tpch_customer', MAX_STALENESS => INTERVAL '1' HOUR) LIMIT 10;
-- SELECT * FROM READ_ICEBERG(LOCATION => 'tpch_part',     MAX_STALENESS => INTERVAL '1' HOUR) LIMIT 10;
-- SELECT * FROM READ_ICEBERG(LOCATION => 'tpch_partsupp', MAX_STALENESS => INTERVAL '1' HOUR) LIMIT 10;
-- SELECT * FROM READ_ICEBERG(LOCATION => 'tpch_supplier', MAX_STALENESS => INTERVAL '1' HOUR) LIMIT 10;
-- SELECT * FROM READ_ICEBERG(LOCATION => 'tpch_nation',   MAX_STALENESS => INTERVAL '1' HOUR) LIMIT 10;
-- SELECT * FROM READ_ICEBERG(LOCATION => 'tpch_region',   MAX_STALENESS => INTERVAL '1' HOUR) LIMIT 10;
