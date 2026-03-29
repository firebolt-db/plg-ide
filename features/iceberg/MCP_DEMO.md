# Run Iceberg Demo via MCP

Use the Firebolt MCP tools (`firebolt_connect`, `firebolt_query`) in Cursor to run the Iceberg demo. If the tools are not visible, restart Cursor and check **Settings → Tools & MCP** that the Firebolt server is configured and connected.

Demo sequence: create LOCATIONs for TPCH tables, then views from those LOCATIONs, then query your Iceberg data.

## 1. Connect (existing database first)

Connect using an existing database so we can create `iceberg_demo`:

- **Prompt:** "Connect to Firebolt Cloud with engine **your_engine_name** and database **your_existing_db**."
- Or use `firebolt_connect` with your engine name and an existing database name (e.g. your default DB).

## 2. Create the demo database

Run this SQL (via "Run this SQL" or `firebolt_query`):

```sql
CREATE DATABASE IF NOT EXISTS iceberg_demo;
```

## 3. Switch to iceberg_demo and create LOCATIONs

Connect to **iceberg_demo**, then run the contents of `features/iceberg/01_create_locations_tpch.sql` (CREATE LOCATION for each TPCH table: tpch_lineitem, tpch_orders, tpch_customer, tpch_part, tpch_partsupp, tpch_supplier, tpch_nation, tpch_region). Each points to `s3://firebolt-publishing-public/help_center_assets/firebolt_sample_iceberg/tpch/iceberg/<table>`.

If your engine rejects empty CREDENTIALS for the public bucket, add valid AWS keys or see the file comments.

## 4. Create the demo views from LOCATION

Run the contents of `features/iceberg/02_create_view.sql` (one statement at a time if needed), or run via CLI:

```bash
python3 -m lib.firebolt run features/iceberg/02_create_view.sql
```

(with `FIREBOLT_DATABASE=iceberg_demo`)

## 5. Query your Iceberg data

```sql
SELECT COUNT(*) AS total_rows FROM iceberg_lineitem;
SELECT * FROM iceberg_lineitem LIMIT 10;
```

---

**Reference:** `features/iceberg/01_create_locations_tpch.sql`, `features/iceberg/02_create_view.sql`
