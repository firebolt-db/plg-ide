# Aggregating Indexes Demo - E-commerce Vertical

This demo proves the value of Firebolt's aggregating indexes using e-commerce analytics queries.

## What You'll See

| Query | Without Index | With Index | Improvement |
|-------|---------------|------------|-------------|
| Product Sales by Category | ~2,000ms | ~25ms | **80X** |
| Daily Revenue Trends | ~1,500ms | ~17ms | **90X** |
| Top Products by Revenue | ~800ms | ~12ms | **70X** |
| Brand Performance | ~900ms | ~13ms | **70X** |

## Quick Start

```bash
# Run the full benchmark
python benchmark.py

# Or step by step:
python -m lib.firebolt run 01_baseline.sql
python -m lib.firebolt run 02_create_indexes.sql
python -m lib.firebolt run 03_optimized.sql
```

## The Queries

### 1. Product Sales by Category

Sales by category and brand for the last 30 days.

**Index**: Groups by `product_id`, `DATE_TRUNC('day', created_at)` with aggregations.

### 2. Daily Revenue Trends

Daily order count, revenue, and average order value for the last 90 days.

**Index**: Groups by `DATE_TRUNC('day', created_at)` with aggregations.

### 3. Top Products by Revenue

Top 20 products by revenue in the last 7 days.

**Index**: Uses `order_items_product_sales_agg`.

### 4. Brand Performance

Revenue and quantity sold by brand in the last 7 days.

**Index**: Uses `order_items_product_sales_agg` (product-level) with products join.

## Files

- `01_baseline.sql` - Queries WITHOUT aggregating indexes (slow)
- `02_create_indexes.sql` - Creates the aggregating indexes
- `03_optimized.sql` - Same queries, now fast with indexes
- `benchmark.py` - Automated comparison script
