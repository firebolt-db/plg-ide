# Sample Iceberg Dataset Setup

This guide explains how to set up the Apache Iceberg table referenced in the [Firebolt blog on querying Apache Iceberg with sub-second performance](https://www.firebolt.io/blog/querying-apache-iceberg-with-sub-second-performance).

## Overview

The demo uses the dataset from the blog post, which demonstrates:

- **Partition pruning**: Queries filter by partition columns to skip irrelevant partitions
- **Metadata optimization**: Large, compressed Parquet files for fast reads
- **Column pruning**: Select only needed columns to reduce I/O
- **Sub-second performance**: Achieve millisecond query latency on TB-scale datasets

## Option 1: Use Firebolt's Public TPCH Dataset (Recommended)

The demo uses Firebolt's public TPCH lineitem dataset:

**S3 Path**: `s3://firebolt-publishing-public/help_center_assets/firebolt_sample_iceberg/tpch/iceberg/lineitem`

This is a public S3 bucket. The demo uses CREATE LOCATION and a view: run `features/iceberg/01_create_locations_tpch.sql` then `02_create_view.sql`.

**Dataset Details:**
- **Table**: TPCH lineitem (standard TPC-H benchmark table)
- **Partitioning**: By `l_shipdate` (ship date)
- **Schema**: Standard TPCH lineitem columns (l_orderkey, l_partkey, l_suppkey, l_linenumber, l_quantity, l_extendedprice, l_discount, l_tax, l_returnflag, l_linestatus, l_shipdate, l_commitdate, l_receiptdate, l_shipinstruct, l_shipmode, l_comment)

**Requirements:**
- Iceberg table in AWS S3 (from blog or your own)
- AWS credentials (access key + secret, or IAM role)
- AWS region where the bucket is located

## Option 2: Create Sample Iceberg Table with PyIceberg

### Prerequisites

```bash
pip install pyiceberg[aws] pyarrow pandas
```

### Create Sample Dataset

```python
# create_iceberg_sample.py
from pyiceberg.catalog import load_catalog
from pyiceberg.schema import Schema
from pyiceberg.types import (
    NestedField, StringType, LongType, DoubleType, DateType
)
from pyiceberg.partitioning import PartitionSpec, PartitionField
from pyiceberg.transforms import IdentityTransform
import pandas as pd
from datetime import date, timedelta
import random

# Configure catalog (using AWS Glue or file-based)
catalog = load_catalog(
    name="demo",
    **{
        "type": "glue",
        "s3.region": "us-east-1",
        "s3.endpoint": "https://s3.us-east-1.amazonaws.com",
        "glue.id": "YOUR_AWS_ACCOUNT_ID",
        "glue.region": "us-east-1"
    }
)

# Define schema
schema = Schema(
    NestedField(1, "sale_id", LongType(), required=True),
    NestedField(2, "sale_date", DateType(), required=True),
    NestedField(3, "region", StringType(), required=True),
    NestedField(4, "product_id", LongType(), required=True),
    NestedField(5, "product_name", StringType(), required=True),
    NestedField(6, "amount", DoubleType(), required=True),
    NestedField(7, "quantity", LongType(), required=True),
    NestedField(8, "customer_id", LongType(), required=True),
)

# Define partitioning (by date and region)
partition_spec = PartitionSpec(
    PartitionField(2, 1000, "sale_date", IdentityTransform()),
    PartitionField(3, 1001, "region", IdentityTransform())
)

# Create table
catalog.create_table(
    identifier="demo.sales_iceberg",
    schema=schema,
    partition_spec=partition_spec,
    location="s3://your-bucket/iceberg-demo/sales/"
)

# Generate sample data
table = catalog.load_table("demo.sales_iceberg")

regions = ["us-east-1", "us-west-2", "eu-west-1", "ap-southeast-1"]
products = [
    ("Laptop", 999.99),
    ("Phone", 699.99),
    ("Tablet", 399.99),
    ("Monitor", 299.99),
    ("Keyboard", 79.99),
]

# Generate 1M rows across 30 days
start_date = date.today() - timedelta(days=30)
rows = []

for day_offset in range(30):
    sale_date = start_date + timedelta(days=day_offset)
    for _ in range(33333):  # ~33K rows per day
        region = random.choice(regions)
        product_name, base_price = random.choice(products)
        rows.append({
            "sale_id": random.randint(1, 1000000),
            "sale_date": sale_date,
            "region": region,
            "product_id": random.randint(1, 1000),
            "product_name": product_name,
            "amount": base_price * random.uniform(0.8, 1.2),
            "quantity": random.randint(1, 5),
            "customer_id": random.randint(1, 100000),
        })

# Write in batches (target 500MB-1GB per file)
df = pd.DataFrame(rows)
table.append(df)

print(f"Created Iceberg table at: s3://your-bucket/iceberg-demo/sales/")
print(f"Total rows: {len(df)}")
```

### Run the Script

```bash
# Set AWS credentials
export AWS_ACCESS_KEY_ID=your_key
export AWS_SECRET_ACCESS_KEY=your_secret
export AWS_DEFAULT_REGION=us-east-1

# Run script
python create_iceberg_sample.py
```

## Option 3: Use AWS Athena to Create Iceberg Table

If you prefer using AWS services:

```sql
-- In AWS Athena
CREATE TABLE sales_iceberg (
    sale_id BIGINT,
    sale_date DATE,
    region STRING,
    product_id BIGINT,
    product_name STRING,
    amount DOUBLE,
    quantity BIGINT,
    customer_id BIGINT
)
USING ICEBERG
PARTITIONED BY (sale_date, region)
LOCATION 's3://your-bucket/iceberg-demo/sales/'
TBLPROPERTIES (
    'write.target-file-size-bytes'='536870912',  -- 512MB
    'write.parquet.compression-codec'='snappy'
);

-- Insert sample data
INSERT INTO sales_iceberg
SELECT 
    sale_id,
    sale_date,
    region,
    product_id,
    product_name,
    amount,
    quantity,
    customer_id
FROM existing_sales_table
WHERE sale_date >= CURRENT_DATE - INTERVAL '30 days';
```

## Firebolt setup (LOCATION + view)

Once your Iceberg table exists in S3, create a LOCATION and a view (see `01_create_locations_tpch.sql` and `02_create_view.sql`):

```sql
-- 1. Create LOCATION (run 01_create_locations_tpch.sql for all TPCH tables)
CREATE LOCATION IF NOT EXISTS tpch_lineitem WITH
  SOURCE = ICEBERG
  CATALOG = FILE_BASED
  CATALOG_OPTIONS = ( URL = 's3://firebolt-publishing-public/.../tpch/iceberg/lineitem' )
  CREDENTIALS = ( AWS_ACCESS_KEY_ID = '' AWS_SECRET_ACCESS_KEY = '' );

-- 2. Create view from LOCATION
CREATE VIEW iceberg_lineitem AS
SELECT * FROM READ_ICEBERG( LOCATION => 'tpch_lineitem', MAX_STALENESS => INTERVAL '1' HOUR );

-- Verify
DESCRIBE iceberg_lineitem;
SELECT COUNT(*) FROM iceberg_lineitem;
```

## Sample Data Schema

The demo uses the TPCH lineitem table with the following schema:

| Column | Type | Description |
|--------|------|-------------|
| `l_orderkey` | BIGINT | Order identifier |
| `l_partkey` | BIGINT | Part identifier |
| `l_suppkey` | BIGINT | Supplier identifier |
| `l_linenumber` | BIGINT | Line number |
| `l_quantity` | DOUBLE | Quantity |
| `l_extendedprice` | DOUBLE | Extended price |
| `l_discount` | DOUBLE | Discount |
| `l_tax` | DOUBLE | Tax |
| `l_returnflag` | STRING | Return flag |
| `l_linestatus` | STRING | Line status |
| `l_shipdate` | DATE | Ship date (partition column) |
| `l_commitdate` | DATE | Commit date |
| `l_receiptdate` | DATE | Receipt date |
| `l_shipinstruct` | STRING | Ship instruction |
| `l_shipmode` | STRING | Ship mode |
| `l_comment` | STRING | Comment |

**Partitioning:**
- Primary: `l_shipdate` (date partitions)

**Dataset:**
- Standard TPCH lineitem table
- Partitioned by ship date
- Public S3 bucket (no credentials needed)

## AWS Credentials

For Firebolt Cloud, you can use:

1. **AWS Access Keys**: Provide `aws_access_key_id` and `aws_secret_access_key` in `READ_ICEBERG`
2. **IAM Role**: If your Firebolt account has IAM role configured, you can omit credentials
3. **Temporary Credentials**: Use AWS STS for temporary access

## Verification

After setup, verify the table is accessible:

```sql
-- Check row count
SELECT COUNT(*) as total_rows FROM iceberg_lineitem;

-- Check partition distribution
SELECT 
    DATE_TRUNC('month', l_shipdate) as ship_month,
    COUNT(*) as row_count,
    SUM(l_extendedprice) as total_revenue
FROM iceberg_lineitem
GROUP BY ship_month
ORDER BY ship_month DESC
LIMIT 20;

-- Test partition pruning
EXPLAIN ANALYZE
SELECT *
FROM iceberg_lineitem
WHERE l_shipdate >= DATE '1998-01-01'
  AND l_shipdate < DATE '1998-02-01';
```

Look for "PartitionFilter" or "IcebergMetadataPruning" in the EXPLAIN output to confirm partition pruning is working.

## Troubleshooting

### "Table not found" or "Invalid path"
- Verify the S3 path points to the Iceberg table root (where `metadata/` folder exists)
- Check AWS credentials have read access to the S3 bucket
- Ensure the AWS region matches the bucket region

### Slow queries
- Check file sizes: Use `SHOW FILES` or Iceberg metadata to see file sizes
- Verify partitioning: Ensure queries filter on partition columns
- Check metadata freshness: Use `max_staleness => INTERVAL '0' SECOND` for fresh metadata

### Permission errors
- Verify AWS credentials have `s3:GetObject` and `s3:ListBucket` permissions
- For Glue catalog: Ensure credentials have `glue:GetTable` and `glue:GetDatabase` permissions
