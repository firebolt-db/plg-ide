# Iceberg Demo — Full Walkthrough (Step by Step)

This guide walks through setting up and querying your Iceberg data lake with Firebolt: create database, LOCATIONs, views, then run queries.

---

## Prerequisites

- **Firebolt Cloud** account (Iceberg requires Cloud, not Core).
- **Engine** attached to the database you use (can be stopped; Firebolt will start it on first query — allow a few minutes).
- **Credentials** in environment or in `../bench-2-cost/firebolt/envvars.sh`:
  - `FIREBOLT_USER` or `FIREBOLT_EMAIL`
  - `FIREBOLT_PASSWORD`
  - `FIREBOLT_ACCOUNT` (optional)
  - `FIREBOLT_ENGINE` (e.g. `bench2cost_l_co_3n`)

All commands below are from the **repository root** unless noted.

---

## Step 1 — Create the database (one-time)

The demo uses database `iceberg_demo`. Creation requires connecting with an existing database (e.g. `clickbench`), then creating `iceberg_demo`.

```bash
# Optional: load credentials
source ../bench-2-cost/firebolt/envvars.sh   # if you use it
export FIREBOLT_ENGINE="${FIREBOLT_ENGINE:-bench2cost_l_co_3n}"

# Create iceberg_demo (connects via clickbench, then creates DB)
export FIREBOLT_DATABASE="clickbench"
python3 -c "
import sys
sys.path.insert(0, '.')
from lib.firebolt import FireboltRunner
r = FireboltRunner()
r.execute('CREATE DATABASE IF NOT EXISTS iceberg_demo')
print('Done.')
r.close()
"
```

**What happens:** Firebolt connects to `clickbench`; if the engine was stopped, it may start here (wait a few minutes). Then it runs `CREATE DATABASE IF NOT EXISTS iceberg_demo`.

---

## Step 2 — Create LOCATIONs for TPC-H Iceberg tables

This step registers 8 **LOCATION**s (one per TPC-H table) pointing at Firebolt's public Iceberg data in S3. No data is copied; only metadata and paths are stored.

```bash
export FIREBOLT_DATABASE="iceberg_demo"
python3 -m lib.firebolt run features/iceberg/01_create_locations_tpch.sql
```

**What happens:**

- Uses database `iceberg_demo`.
- Runs `01_create_locations_tpch.sql`, which:
  - `USE iceberg_demo;`
  - `CREATE LOCATION IF NOT EXISTS tpch_lineitem` (FILE_BASED, S3 path for lineitem)
  - Same for `tpch_orders`, `tpch_customer`, `tpch_part`, `tpch_partsupp`, `tpch_supplier`, `tpch_nation`, `tpch_region`.

**Result:** Eight LOCATIONs you can reference in `READ_ICEBERG(LOCATION => 'tpch_<name>')`.

---

## Step 3 — Create views from LOCATIONs

This step defines 8 **views** that read from those LOCATIONs. Queries will use these views instead of calling `READ_ICEBERG` directly.

```bash
export FIREBOLT_DATABASE="iceberg_demo"
python3 -m lib.firebolt run features/iceberg/02_create_view.sql
```

**What happens:**

- Runs `02_create_view.sql`, which:
  - `DROP VIEW IF EXISTS iceberg_<table>; CREATE VIEW iceberg_<table> AS SELECT * FROM READ_ICEBERG(LOCATION => 'tpch_<table>', MAX_STALENESS => INTERVAL '1' HOUR);`
  - For: lineitem, orders, customer, part, partsupp, supplier, nation, region.
- Then runs verification `SELECT COUNT(*)` on each view.

**Result:** Views `iceberg_lineitem`, `iceberg_orders`, `iceberg_customer`, etc. You can now query them with standard SQL.

---

## Step 4 (optional) — Run TPC-H queries

After steps 1–3, you can run all 22 official TPC-H queries (Q1–Q22) against the Iceberg views.

```bash
export FIREBOLT_DATABASE="iceberg_demo"
python3 -m lib.firebolt run features/iceberg/tpch_queries.sql
```

Or run the file in your SQL client (Firebolt UI or IDE) after selecting `iceberg_demo`. The file lives at `features/iceberg/tpch_queries.sql`.

---

## One-command run (steps 1–3)

From repo root:

```bash
source ../bench-2-cost/firebolt/envvars.sh   # optional
export FIREBOLT_ENGINE="${FIREBOLT_ENGINE:-bench2cost_l_co_3n}"
bash features/iceberg/run_demo.sh
```

This does: create DB (via clickbench) → create LOCATIONs → create views. Run `tpch_queries.sql` manually if you want to execute Q1–Q22.

---

## Summary

| Step | Action | Main artifact |
|------|--------|---------------|
| 1 | Create DB | `iceberg_demo` |
| 2 | Create LOCATIONs | `tpch_lineitem`, `tpch_orders`, … (8 total) |
| 3 | Create views | `iceberg_lineitem`, `iceberg_orders`, … (8 total) |
| 4 (optional) | Run TPC-H | Execute Q1–Q22 from `tpch_queries.sql` |

---

## Troubleshooting

- **"Table/view not found"**  
  Run steps 2 and 3 in order; ensure `FIREBOLT_DATABASE=iceberg_demo` when running the SQL files.

- **Engine starting**  
  First query after engine stop can take several minutes; later queries are fast.

- **Permission / credentials**  
  The public S3 bucket often works with empty credentials in CREATE LOCATION; if your engine rejects that, set valid `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` in the LOCATION definition (see comments in `01_create_locations_tpch.sql`).
