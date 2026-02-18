#!/usr/bin/env bash
# Iceberg Read Experience - Setup and query your Iceberg data lake
# Run from repo root. Requires: Firebolt Cloud credentials in env or ../bench-2-cost/firebolt/envvars.sh

set -e
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$REPO_ROOT"

# Load credentials if available
if [ -f "../bench-2-cost/firebolt/envvars.sh" ]; then
  source "../bench-2-cost/firebolt/envvars.sh"
fi
export FIREBOLT_ENGINE="${FIREBOLT_ENGINE:-bench2cost_l_co_3n}"

echo "========================================================================"
echo "ICEBERG DEMO - Setup and query your Iceberg data lake"
echo "========================================================================"
echo ""

# Step 1: Ensure database iceberg_demo exists (connect via existing DB)
echo "[1/3] Ensuring database iceberg_demo exists..."
export FIREBOLT_DATABASE="clickbench"
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
