# Financial Services Vertical

Transaction analytics and risk calculations powered by Firebolt. This demo showcases how financial services companies like Primer achieve millisecond latency and Ezora achieve 30X faster queries.

## Use Case

Financial services platforms need to:
- Analyze billions of transactions in real-time
- Calculate risk scores and fraud detection patterns
- Generate regulatory reports with point-in-time accuracy
- Track portfolio performance and asset allocation
- Power trading dashboards with sub-second refresh rates

**The Challenge**: Billions of transactions, complex risk calculations, regulatory compliance, millisecond latency requirements.

**The Solution**: Firebolt's aggregating indexes for transaction analytics, time travel for point-in-time queries, and vector search for fraud pattern detection.

## Dataset

**Financial Services** - Custom dataset based on Primer/Ezora patterns

| Table | Description | Approximate Rows |
|-------|-------------|------------------|
| `customers` | Customer accounts | 10M |
| `accounts` | Bank accounts | 50M |
| `transactions` | Transaction events | 1B+ |
| `portfolios` | Investment portfolios | 1M |
| `securities` | Security definitions | 100K |

## Quick Start

```bash
# From repo root
cd verticals/financial

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
- **Transaction Analytics**: High-volume aggregations by account, merchant, category
- **Risk Scoring**: Complex calculations on transaction patterns
- **Regulatory Reporting**: Point-in-time queries with time travel

[Go to Demo](features/aggregating_indexes/)

### Time Travel (Coming Soon)

Demonstrates point-in-time queries:
- **Regulatory Reports**: Historical state at specific timestamps
- **Audit Trails**: Track changes over time
- **Compliance Queries**: Prove data state at reporting time

## Schema

```sql
-- Core dimension tables
customers (customer_id, name, risk_tier, kyc_status)
accounts (account_id, customer_id, account_type, balance)
securities (security_id, symbol, name, asset_class)

-- High-volume fact tables
transactions (
    transaction_id, account_id, timestamp, amount,
    merchant, category, risk_score, ...
)
portfolios (portfolio_id, customer_id, holdings JSON)
```

## Real-World References

- [Primer Case Study](https://www.firebolt.io/knowledge-center/case-studies) - Millisecond latency
- [Ezora Case Study](https://www.firebolt.io/knowledge-center/case-studies) - 30X faster queries

**Further reading (feature demos):**

- [Vector Search Indexes Technical Deep Dive](https://www.firebolt.io/blog/technical-deep-dive-efficient-and-acid-compliant-vector-search-indexes-in-firebolt) — fraud detection, pattern similarity
- [Late Materialization: Top-K 30x Faster](https://www.firebolt.io/blog/late-materialization-how-firebolt-makes-top-k-queries-30x-faster) — wide transaction tables
- [Firebolt docs: Vector indexes](https://docs.firebolt.io/sql-reference/vector-indexes)
