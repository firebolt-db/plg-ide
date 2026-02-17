# CyberTech Vertical

Multi-cloud security analytics powered by Firebolt. This demo showcases anomaly detection across AWS CloudTrail, Azure Activity Logs, and GCP Audit Logs using aggregating indexes for 10-100X faster queries.

## Use Case

Security teams need to:
- Detect anomalous destructive behavior (e.g., spike in DeleteInstance events per user)
- Analyze audit logs across AWS, Azure, and GCP in a single view
- Build real-time dashboards for multi-cloud security posture

**The Challenge**: Millions of audit events across multiple clouds, sub-second anomaly detection requirements.

**The Solution**: Firebolt's aggregating indexes pre-compute hourly event counts per user by event type.

## Dataset

**Multi-Cloud Security Audit Logs** — Synthetic events for demo

| Table | Description | Approximate Rows |
|-------|-------------|-----------------|
| `events` | AWS CloudTrail events | 100K |
| `azure_events` | Azure Activity Log events | 100K |
| `gcp_events` | GCP Audit Log events | 100K |

## Quick Start

```bash
# From repo root
cd verticals/cybertech

# Load schema and data (Firebolt Core - uses sample_data.py)
FIREBOLT_DATABASE=cybertech python data/sample_data.py

# Or run load.sql (works on Core and Cloud)
python -m lib.firebolt run schema/01_tables.sql
python -m lib.firebolt run data/load.sql

# Run feature demos
cd features/aggregating_indexes
# Run 01_baseline.sql, 02_create_indexes.sql, 03_optimized.sql

# Or run the impact-first comparison demo
python -m lib.firebolt run ../demo_comparison.sql
```

## Feature Demos

### Aggregating Indexes

Demonstrates 10-100X query speedup for:

- **Anomaly detection**: Hourly delete events per user (AWS, Azure, GCP)
- **Cross-cloud summary**: Users with highest destructive activity
- **Time-bucketed analysis**: Event counts by hour and username

[Go to Demo](features/aggregating_indexes/)

## Schema

Multi-cloud audit log structure (aligned with cyber-demo-blog):

```sql
-- All three tables share the same structure
events | azure_events | gcp_events (
    event_time TEXT,
    event_name TEXT,
    event_source TEXT,
    username TEXT,
    source_ip TEXT,
    instance_id TEXT,
    current_state TEXT,
    previous_state TEXT,
    src TEXT
)
```

## Real-World References

- [cyber-demo-blog](https://github.com/firebolt-analytics/cyber-demo-blog) — Multi-cloud anomaly detection with Streamlit dashboard
- [Firebolt Aggregating Indexes](https://docs.firebolt.io/working-with-indexes/using-aggregating-indexes)

**Further reading (feature demos):**

- [Firebolt docs: Aggregating indexes](https://docs.firebolt.io/sql-reference/aggregating-indexes) — hourly deletes, cross-cloud aggregates
- [Vector Search Indexes Technical Deep Dive](https://www.firebolt.io/blog/technical-deep-dive-efficient-and-acid-compliant-vector-search-indexes-in-firebolt) — anomaly detection, event clustering (optional)
- [Firebolt docs: Vector indexes](https://docs.firebolt.io/sql-reference/vector-indexes)
