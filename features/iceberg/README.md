# Apache Iceberg Read Experience

Show how easy it is to set up and query your Iceberg data lake with Firebolt: create LOCATIONs, create views, then query with standard SQL. No data migration required.

## How It Works

1. **Create LOCATIONs** – Point Firebolt at your Iceberg tables in S3 (one LOCATION per table).
2. **Create views** – Define views using `READ_ICEBERG(LOCATION => '...')` so you can query like normal tables.
3. **Query** – Use standard SQL against the views; Firebolt reads from Iceberg in S3.

## Dataset

**TPCH** – Firebolt's public TPC-H dataset in Iceberg format (lineitem, orders, customer, part, partsupp, supplier, nation, region).

**S3 base path:** `s3://firebolt-publishing-public/help_center_assets/firebolt_sample_iceberg/tpch/iceberg/`

This is a public S3 bucket; AWS credentials are not required for the demo.

## Quick Start

**Prerequisites:** Firebolt Cloud account, an engine (can be stopped; allow a few minutes for start), and credentials in the environment.

**Required environment variables** (see [config/cloud.env.template](../../config/cloud.env.template) in the repo root):

| Variable | Description |
|----------|-------------|
| `FIREBOLT_CLIENT_ID` | Firebolt Cloud service account client ID |
| `FIREBOLT_CLIENT_SECRET` | Firebolt Cloud service account client secret |
| `FIREBOLT_ENGINE` | Your Firebolt engine name (e.g. `my_engine`) |
| `FIREBOLT_ACCOUNT` | (Optional) Account name; required if not default |
| `FIREBOLT_DATABASE` | Set by the script; use `iceberg_demo` after setup |

Copy `config/cloud.env.template` to `.env` in the repo root, fill in your values, then either export them in your shell or run the script after loading `.env` (e.g. `set -a; source .env; set +a; bash features/iceberg/run_demo.sh`). Do not commit `.env`.

### One-command demo (from repo root)

```bash
# Set credentials and an existing database (script will create iceberg_demo from it)
export FIREBOLT_CLIENT_ID="your_client_id"
export FIREBOLT_CLIENT_SECRET="your_client_secret"
export FIREBOLT_ENGINE="your_engine_name"
export FIREBOLT_DATABASE="your_existing_db"   # any DB that already exists

bash features/iceberg/run_demo.sh
```

This script: (1) creates `iceberg_demo` if missing, (2) creates LOCATIONs for all 8 TPC-H tables, (3) creates all 8 `iceberg_*` views. You can then query `iceberg_lineitem`, `iceberg_orders`, etc.

### Step-by-step

Ensure `FIREBOLT_CLIENT_ID`, `FIREBOLT_CLIENT_SECRET`, and `FIREBOLT_ENGINE` (and optionally `FIREBOLT_ACCOUNT`) are set. From repo root:

```bash
# 1. Create DB (connect with an existing database first, e.g. your default DB)
FIREBOLT_DATABASE=your_existing_db python3 -c "
from lib.firebolt import FireboltRunner
r = FireboltRunner()
r.execute('CREATE DATABASE IF NOT EXISTS iceberg_demo')
r.close()
"

# 2. Create LOCATIONs
FIREBOLT_DATABASE=iceberg_demo python3 -m lib.firebolt run features/iceberg/01_create_locations_tpch.sql

# 3. Create views
FIREBOLT_DATABASE=iceberg_demo python3 -m lib.firebolt run features/iceberg/02_create_view.sql

# 4. Query (e.g. in Firebolt UI or CLI)
# SELECT * FROM iceberg_lineitem LIMIT 10;
```

### Optional: Run TPC-H Q1–Q22

```bash
FIREBOLT_DATABASE=iceberg_demo python3 -m lib.firebolt run features/iceberg/tpch_queries.sql
```

## Files in this folder

| File | Purpose |
|------|---------|
| `01_create_locations_tpch.sql` | CREATE LOCATION for all 8 TPC-H tables (run first). |
| `02_create_view.sql` | CREATE VIEW iceberg_* from LOCATIONs (run second). |
| `tpch_queries.sql` | Official TPC-H Q1–Q22 using iceberg_* views. |
| `run_demo.sh` | One-command setup (DB + LOCATIONs + views). |
| `demo_full.sql` | Step-by-step walkthrough with talking points. |
| `demo_comparison.sql` | Side-by-side query examples. |
| `WALKTHROUGH.md` | Full step-by-step walkthrough. |
| `MCP_DEMO.md` | Run demo via Firebolt MCP tools. |
| `SQL_VERIFICATION.md` | Syntax verification notes. |
| `data/iceberg_sample.md` | Sample dataset setup (public TPCH + PyIceberg option). |

## Using READ_ICEBERG

```sql
-- Create a view from a LOCATION (run 01_create_locations_tpch.sql first)
CREATE VIEW iceberg_lineitem AS
SELECT * FROM READ_ICEBERG(
    LOCATION => 'tpch_lineitem',
    MAX_STALENESS => INTERVAL '1' HOUR
);

-- Query like a regular table
SELECT * FROM iceberg_lineitem LIMIT 10;
```

## References

- [Querying Apache Iceberg with Sub-Second Performance](https://www.firebolt.io/blog/querying-apache-iceberg-with-sub-second-performance)
- [Firebolt Iceberg Documentation](https://docs.firebolt.io/performance-and-observability/iceberg-and-external-data)
- [READ_ICEBERG Function Reference](https://docs.firebolt.io/reference-sql/functions-reference/table-valued/read_iceberg)
