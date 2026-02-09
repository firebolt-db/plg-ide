# E-commerce Vertical

Retail analytics powered by Firebolt. This demo showcases how e-commerce companies like Vrio achieve faster query performance and significant cost reductions.

## Use Case

E-commerce platforms need to:
- Analyze product sales by category, brand, and region
- Build customer 360 views with purchase history
- Track inventory levels and stock movements
- Power recommendation engines with similarity search
- Monitor conversion funnels and A/B test results

**The Challenge**: Hundreds of millions of transactions, complex joins across wide tables, real-time inventory needs.

**The Solution**: Firebolt's aggregating indexes for sales analytics, late materialization for wide product tables, and vector search for recommendations.

## Dataset

**E-commerce** - Firebolt's public sample dataset (52GB, 412M rows)

| Table | Description | Approximate Rows |
|-------|-------------|------------------|
| `customers` | Customer profiles | 10M |
| `products` | Product catalog | 1M |
| `orders` | Order headers | 50M |
| `order_items` | Order line items | 412M |
| `inventory` | Stock levels | 5M |

## Quick Start

```bash
# From repo root
cd verticals/ecommerce

# Load schema and data
python -m lib.firebolt run schema/01_tables.sql
python -m lib.firebolt run data/load.sql

# Run feature demos
cd features/aggregating_indexes
python benchmark.py
```

## Feature Demos

### Aggregating Indexes

Demonstrates 50-100X query speedup for:
- **Product Analytics**: Sales by category, brand, region
- **Customer Lifetime Value**: Total spend per customer
- **Revenue Reporting**: Daily/weekly/monthly revenue trends

[Go to Demo](features/aggregating_indexes/)

### Late Materialization (Coming Soon)

Demonstrates 60-90% I/O reduction for:
- **Product Lookups**: Read only needed columns from wide product tables
- **Customer History**: Filter before joining large fact tables

## Schema

```sql
-- Core dimension tables
customers (customer_id, email, registration_date, country, tier)
products (product_id, name, category, brand, price, description, ...)
categories (category_id, name, parent_category_id)

-- High-volume fact tables
orders (order_id, customer_id, order_date, status, total_amount)
order_items (
    order_item_id, order_id, product_id,
    quantity, price, discount, subtotal
)
inventory (product_id, warehouse_id, quantity, last_updated)
```

## Real-World References

- [Vrio Case Study](https://www.firebolt.io/knowledge-center/case-studies) - Query performance + cost reduction
- [E-commerce Dataset](https://www.firebolt.io/free-sample-datasets/e-commerce) - 52GB, 412M rows
