#!/usr/bin/env bash
# Iceberg Read Experience - Setup and query your Iceberg data lake
# Run from repo root.
#
# Required: Firebolt Cloud credentials in the environment. Set these before running:
#   FIREBOLT_CLIENT_ID, FIREBOLT_CLIENT_SECRET, FIREBOLT_ENGINE, FIREBOLT_ACCOUNT (optional)
# You can copy config/cloud.env.template to .env and fill in values; lib/firebolt.py reads
# from the environment (use a tool like dotenv or 'set -a; source .env; set +a' to load .env).

set -e
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$REPO_ROOT"

# Optional: load .env from repo root if present (not committed)
if [ -f "$REPO_ROOT/.env" ]; then
  set -a
  source "$REPO_ROOT/.env"
  set +a
fi

if [ -z "${FIREBOLT_CLIENT_ID}" ] || [ -z "${FIREBOLT_CLIENT_SECRET}" ]; then
  echo "Error: FIREBOLT_CLIENT_ID and FIREBOLT_CLIENT_SECRET must be set (Firebolt Cloud credentials)."
  echo "See config/cloud.env.template for required variables. Copy to .env and fill in, or export them."
  exit 1
fi
if [ -z "${FIREBOLT_ENGINE}" ]; then
  echo "Error: FIREBOLT_ENGINE must be set (e.g. your Firebolt engine name)."
  exit 1
fi

# Step 1 needs an existing database to connect to (to run CREATE DATABASE). Use FIREBOLT_DATABASE if set.
if [ -z "${FIREBOLT_DATABASE}" ]; then
  echo "Error: Set FIREBOLT_DATABASE to an existing database for this run (the script will create iceberg_demo and then use it)."
  echo "Example: export FIREBOLT_DATABASE=my_default_db"
  exit 1
fi

echo "========================================================================"
echo "ICEBERG DEMO - Setup and query your Iceberg data lake"
echo "========================================================================"
echo ""

# Step 1: Ensure database iceberg_demo exists (connect via existing DB)
echo "[1/3] Ensuring database iceberg_demo exists (connecting via FIREBOLT_DATABASE=${FIREBOLT_DATABASE})..."
python3 -c "
import sys
sys.path.insert(0, '.')
from lib.firebolt import FireboltRunner
r = FireboltRunner()
r.execute('CREATE DATABASE IF NOT EXISTS iceberg_demo')
print('   Done.')
r.close()
"

# Step 2: Create LOCATIONs for TPCH tables (FILE_BASED Iceberg)
echo ""
echo "[2/3] Creating LOCATIONs for TPCH Iceberg tables..."
export FIREBOLT_DATABASE="iceberg_demo"
python3 -m lib.firebolt run features/iceberg/01_create_locations_tpch.sql

# Step 3: Create views from LOCATIONs (then 02_create_view.sql runs verification queries)
echo ""
echo "[3/3] Creating iceberg_* views and verifying..."
python3 -m lib.firebolt run features/iceberg/02_create_view.sql

echo ""
echo "Demo complete. You can now query iceberg_lineitem, iceberg_orders, etc."
echo "Example: SELECT * FROM iceberg_lineitem LIMIT 10;"
echo "Or run: FIREBOLT_DATABASE=iceberg_demo python3 -m lib.firebolt run features/iceberg/tpch_queries.sql"
echo "========================================================================"
