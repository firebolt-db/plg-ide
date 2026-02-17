# AdTech Vertical

Real-time advertising analytics powered by Firebolt. This demo showcases how ad tech companies like Similarweb achieve 100+ QPS with 1PB of data, and Bigabid achieves 400X faster queries with 77% storage savings.

## Use Case

AdTech platforms need to:
- Track billions of ad impressions and clicks in real-time
- Analyze campaign performance by publisher, advertiser, and audience
- Power real-time bidding (RTB) systems with sub-100ms latency
- Build audience segments based on user behavior patterns
- Handle high concurrency from multiple dashboard users

**The Challenge**: Billions of events per day, sub-second query requirements, 100+ concurrent queries, real-time attribution.

**The Solution**: Firebolt's aggregating indexes for campaign analytics, high concurrency for RTB workloads, and late materialization for wide impression tables.

## Dataset

**AdTech** - Custom dataset based on Similarweb/Bigabid patterns

| Table | Description | Approximate Rows |
|-------|-------------|------------------|
| `publishers` | Publisher sites/apps | 100K |
| `advertisers` | Advertiser accounts | 10K |
| `campaigns` | Campaign metadata | 1M |
| `impressions` | Ad impression events | 1B+ |
| `clicks` | Click events | 100M |
| `conversions` | Conversion events | 10M |

## Quick Start

```bash
# From repo root
cd verticals/adtech

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
- **Campaign Analytics**: Performance by campaign, publisher, audience
- **Attribution**: Multi-touch attribution across channels
- **Audience Segments**: User behavior pattern analysis

[Go to Demo](features/aggregating_indexes/)

### High Concurrency (Coming Soon)

Demonstrates consistent performance under load:
- **Real-time Bidding**: Handle 100+ QPS without degradation
- **Dashboard Load**: Multiple users querying simultaneously
- **Workload Isolation**: Heavy queries don't block light queries

## Schema

```sql
-- Core dimension tables
publishers (publisher_id, domain, category, country)
advertisers (advertiser_id, name, industry, budget)
campaigns (campaign_id, advertiser_id, name, start_date, end_date, budget)

-- High-volume fact tables
impressions (
    impression_id, campaign_id, publisher_id, user_id,
    timestamp, ad_unit, device_type, geo, ...
)
clicks (click_id, impression_id, timestamp, ...)
conversions (conversion_id, click_id, value, timestamp, ...)
```

## Real-World References

- [Similarweb Case Study](https://www.firebolt.io/knowledge-center/case-studies) - 100 QPS, 1PB data
- [Bigabid Case Study](https://www.firebolt.io/knowledge-center/case-studies) - 400X faster, 77% storage savings

**Further reading (feature demos):**

- [Eliminating OLTP vs OLAP Trade-off](https://www.firebolt.io/blog/eliminating-the-oltp-vs-olap-trade-off) (MerchJar/Amazon ads) — high concurrency, AdTech
- [Event Streams in Firebolt](https://www.firebolt.io/blog/event-streams-in-firebolt) — click fraud, array aggregating indexes
- [Firebolt docs: Aggregating indexes](https://docs.firebolt.io/sql-reference/aggregating-indexes), [Working with arrays](https://docs.firebolt.io/sql-reference/data-types#array)
