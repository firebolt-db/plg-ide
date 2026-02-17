# Observability Vertical

Log analytics and metrics aggregation powered by Firebolt. This demo showcases how observability platforms like TLDCRM replace DataDog with 8M requests/day and achieve millisecond query latency.

## Use Case

Observability platforms need to:
- Search and filter billions of log events in real-time
- Aggregate metrics by service, endpoint, and time bucket
- Analyze distributed traces across microservices
- Detect anomalies and patterns in log messages
- Power dashboards with sub-second refresh rates

**The Challenge**: Billions of log events per day, full-text search requirements, complex time-series aggregations, high query concurrency.

**The Solution**: Firebolt's aggregating indexes for metrics, text search capabilities, and high concurrency for dashboard workloads.

## Dataset

**Observability** - Custom dataset based on TLDCRM pattern

| Table | Description | Approximate Rows |
|-------|-------------|------------------|
| `services` | Microservice definitions | 1K |
| `endpoints` | API endpoints | 10K |
| `logs` | Log events | 1B+ |
| `metrics` | Time-series metrics | 100M |
| `traces` | Distributed trace spans | 500M |

## Quick Start

```bash
# From repo root
cd verticals/observability

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
- **Metrics Aggregation**: Time-bucketed stats by service/endpoint
- **Error Rate Analysis**: Error counts by service and time window
- **Latency Percentiles**: P50, P95, P99 latency calculations

[Go to Demo](features/aggregating_indexes/)

### Text Search (Coming Soon)

Demonstrates fast log search:
- **Full-text Search**: Search log messages by keyword
- **Pattern Matching**: Find error patterns across services
- **Log Clustering**: Group similar error messages

## Schema

```sql
-- Core dimension tables
services (service_id, service_name, team, environment)
endpoints (endpoint_id, service_id, path, method)

-- High-volume fact tables
logs (
    log_id, service_id, endpoint_id, timestamp,
    level, message, trace_id, ...
)
metrics (
    metric_id, service_id, timestamp, metric_name,
    value, tags JSON
)
traces (
    trace_id, span_id, service_id, parent_span_id,
    start_time, duration, operation_name, ...
)
```

## Real-World References

- [TLDCRM Case Study](https://www.firebolt.io/knowledge-center/case-studies) - Replaced DataDog, 8M requests/day
- [Where Do I Put My Logs?](https://www.firebolt.io/blog/where-do-i-put-my-logs) (TLDCRM) — observability at scale

**Further reading (feature demos):**

- [Late Materialization: Top-K 30x Faster](https://www.firebolt.io/blog/late-materialization-how-firebolt-makes-top-k-queries-30x-faster) — "10 slowest API calls", log analytics
- [Vector Search Indexes Technical Deep Dive](https://www.firebolt.io/blog/technical-deep-dive-efficient-and-acid-compliant-vector-search-indexes-in-firebolt) — log similarity, anomaly detection
- [Firebolt Connector for Confluent](https://www.firebolt.io/blog/firebolt-connector-for-confluent---real-time-applications-powered-by-streaming-data) — real-time logs
- [Firebolt docs: Vector indexes](https://docs.firebolt.io/sql-reference/vector-indexes)
