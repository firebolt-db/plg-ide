# plg-ide Roadmap

This document tracks the verticals and features to be developed, mapped to Firebolt's sample datasets and customer case studies.

## Overview

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                 plg-ide Matrix                                        │
├─────────────────┬───────────────────────────────────────────────────────────────────┤
│                 │                           FEATURES                                 │
│    VERTICALS    ├───────────┬─────────────┬────────────┬───────────┬───────┬────────┤
│                 │ Agg Index │ Late Mat    │ Vector     │ High      │ Event │ Stream │
│                 │           │             │ Search     │ Concur    │ Stream│ Ingest │
├─────────────────┼───────────┼─────────────┼────────────┼───────────┼───────┼────────┤
│ Gaming          │    ✓      │             │            │           │       │  (1)   │
│ E-commerce      │    ✓      │    (1)      │    (1)     │           │       │        │
│ AdTech          │    ✓      │             │            │    (1)    │  (1)  │        │
│ Observability   │    ✓      │    (1)      │    (1)     │           │       │  (1)   │
│ Financial       │    ✓      │             │    (1)     │           │       │        │
│ CyberTech       │    ✓      │             │            │           │       │        │
└─────────────────┴───────────┴─────────────┴────────────┴───────────┴───────┴────────┘
(1) = blog-driven demo priority per Firebolt Blog–Driven Feature Demos section
```

---

## Verticals

### ✅ Gaming (DONE)

**Dataset**: Ultra Fast Gaming (S3)  
**Case Studies**: Lurkit (10X historical, 40% cost savings)

| Use Case | Query Pattern | Best Feature |
|----------|---------------|--------------|
| Tournament Leaderboards | GROUP BY player, ORDER BY score | Aggregating Indexes |
| DAU/MAU Metrics | COUNT DISTINCT by day | Aggregating Indexes |
| Player Profiles | Historical stats per player | Aggregating Indexes |
| Session Analytics | Time-series analysis | Late Materialization |

**Status**: Schema, data loading, aggregating indexes demo complete.

---

### ✅ E-commerce (DONE)

**Dataset**: E-commerce (52GB, 412M rows)  
**Case Studies**: Vrio (query perf + cost reduction)

| Use Case | Query Pattern | Best Feature |
|----------|---------------|--------------|
| Product Analytics | Sales by category, brand | Aggregating Indexes |
| Customer 360 | Purchase history per user | Late Materialization |
| Inventory Queries | Stock levels, joins | Primary Indexes |
| Recommendation Engine | Similarity search | Vector Search |

**Status**: Schema, data loading, aggregating indexes demo, demo_full, demo_comparison complete.

---

### ✅ AdTech (DONE)

**Dataset**: Custom (based on Similarweb/Bigabid patterns)  
**Case Studies**: Similarweb (100 QPS, 1PB), Bigabid (400X faster, 77% storage savings). **Blog reference**: [Eliminating OLTP vs OLAP Trade-off](https://www.firebolt.io/blog/eliminating-the-oltp-vs-olap-trade-off) (MerchJar/Amazon ads).

| Use Case | Query Pattern | Best Feature |
|----------|---------------|--------------|
| Campaign Analytics | Aggregations by campaign | Aggregating Indexes |
| Real-time Bidding | High QPS lookups | High Concurrency |
| Attribution | Multi-touch joins | Late Materialization |
| Audience Segments | User behavior patterns | Vector Search |

**Status**: Schema, data loading, aggregating indexes demo, demo_full, demo_comparison complete.

---

### ✅ Observability / Logs (DONE)

**Dataset**: Custom (based on TLDCRM pattern)  
**Case Studies**: TLDCRM (replaced DataDog, 8M requests/day). **Blog reference**: [Where Do I Put My Logs?](https://www.firebolt.io/blog/where-do-i-put-my-logs) (TLDCRM).

| Use Case | Query Pattern | Best Feature |
|----------|---------------|--------------|
| Log Search | Full-text on messages | Text Search |
| Metrics Aggregation | Time-bucketed stats | Aggregating Indexes |
| Trace Analysis | Distributed tracing joins | Late Materialization |
| Anomaly Detection | Pattern matching | Vector Search |

**Status**: Schema, data loading, aggregating indexes demo, demo_full, demo_comparison complete.

---

### ✅ Financial Services (DONE)

**Dataset**: Custom or NYC datasets  
**Case Studies**: Primer (millisecond latency), Ezora (30X faster)

| Use Case | Query Pattern | Best Feature |
|----------|---------------|--------------|
| Transaction Analytics | High-volume aggregations | Aggregating Indexes |
| Risk Scoring | Complex calculations | Late Materialization |
| Fraud Detection | Pattern matching | Vector Search |
| Regulatory Reporting | Point-in-time queries | Time Travel |

**Status**: Schema, data loading, aggregating indexes demo, demo_full, demo_comparison complete.

---

### ✅ CyberTech (DONE)

**Dataset**: Multi-Cloud Audit Logs (AWS, Azure, GCP)  
**Scope**: Security analytics, threat detection, anomaly detection across clouds.

| Use Case | Query Pattern | Best Feature |
|----------|---------------|--------------|
| Anomaly Detection | Hourly delete events per user | Aggregating Indexes |
| Cross-Cloud Summary | Union of cloud-specific aggregates | Aggregating Indexes |
| Compliance | Audit trail analytics | Aggregating Indexes |

**Status**: Schema, data loading (load.sql, sample_data.py), aggregating indexes demo, demo_comparison complete.

---

### 🔲 Healthcare / Life Sciences

**Dataset**: Custom (based on IQVIA pattern)  
**Case Studies**: IQVIA (1B patient records, millisecond queries)

| Use Case | Query Pattern | Best Feature |
|----------|---------------|--------------|
| Patient Analytics | Cohort analysis | Aggregating Indexes |
| Clinical Trials | Complex filtering | Late Materialization |
| Drug Discovery | Similarity search | Vector Search |
| Compliance Queries | Audit trails | Time Travel |

**Priority**: LOW - Requires synthetic data due to HIPAA.

---

## Features

### ✅ Aggregating Indexes (DONE)

**What**: Pre-computed aggregations at write time  
**Value**: 50-100X faster queries, 99%+ less data scanned  
**Demo**: Gaming vertical - leaderboards, DAU, player profiles

**Applicable to all verticals** - this is the flagship feature.

---

### 🔲 Late Materialization (NEXT)

**What**: Read only columns needed, defer joins until filtered  
**Value**: Read 60-90% less data on wide tables (30X faster top-K on wide tables per blog)  
**Best Demo Verticals**: E-commerce (wide product tables), Observability (logs — "10 slowest API calls")

**Blog references**: [Late Materialization: Top-K 30x Faster](https://www.firebolt.io/blog/late-materialization-how-firebolt-makes-top-k-queries-30x-faster), [Pruning with Late Materialization](https://www.firebolt.io/blog/pruning-even-more-data-with-late-materialization)

| Demo Query | Without | With | Improvement |
|------------|---------|------|-------------|
| Product lookup | Read all columns | Read 3 columns | 80% less I/O |
| Customer history | Full join first | Filter then join | 10X faster |
| Logs: recent errors/slowest calls | Full scan | Sort column + row IDs then fetch | 30X faster |

---

### 🔲 Vector Search

**What**: HNSW indexes for semantic similarity (ACID-compliant per blog)  
**Value**: Enable AI/ML use cases, semantic search  
**Best Demo Verticals**: E-commerce (recommendations), Observability (log similarity / anomaly detection), Financial (fraud patterns)

**Blog references**: [Vector Search Indexes Technical Deep Dive](https://www.firebolt.io/blog/technical-deep-dive-efficient-and-acid-compliant-vector-search-indexes-in-firebolt), [Building RAG Chatbot with Firebolt](https://www.firebolt.io/blog/building-a-chatbot-with-firebolt-using-retrieval-augmented-generation)

| Demo Query | Description |
|------------|-------------|
| Similar products | Find products with similar embeddings |
| Log clustering | Group similar error messages |
| Semantic search | Natural language queries |
| Fraud detection | Transaction pattern similarity |

**Requires**: Embedding generation (Ollama or OpenAI).  
**Firebolt docs**: [Vector indexes](https://docs.firebolt.io/sql-reference/vector-indexes) — for HNSW and embedding column definition; RAG blog for end-to-end pipeline.

---

### 🔲 High Concurrency

**What**: Multiple engines, workload isolation  
**Value**: Handle 100+ QPS without degradation  
**Best Demo Vertical**: AdTech (real-time bidding)

**Blog references**: [Firebolt Unleashed](https://www.firebolt.io/blog/high-efficiency-and-low-cost-concurrency-in-action); case study [Eliminating OLTP vs OLAP Trade-off](https://www.firebolt.io/blog/eliminating-the-oltp-vs-olap-trade-off) (MerchJar/AdTech). FireScale benchmark (link TBD).  
**Firebolt docs**: [Engines and workload isolation](https://docs.firebolt.io/concepts/engine-concept) — for multi-engine setup and concurrency.

| Demo | Description |
|------|-------------|
| Multi-engine setup | Separate engines for ETL vs queries |
| Load test | Simulate concurrent dashboard users |
| Workload isolation | Heavy query doesn't block light queries |

---

### 🔲 Streaming Ingestion

**What**: Kafka/CDC integration for real-time data  
**Value**: Sub-minute data freshness  
**Best Demo Verticals**: Gaming (live events, leaderboards), Observability (real-time logs)

**Blog references**: [Firebolt Connector for Confluent](https://www.firebolt.io/blog/firebolt-connector-for-confluent---real-time-applications-powered-by-streaming-data). Local reference: Firex-gaming-demo data streamer.

| Demo | Description |
|------|-------------|
| Kafka connector | Stream events to Firebolt |
| CDC integration | Replicate from Postgres |
| Real-time dashboard | See data appear in seconds |

---

### 🔲 Event Streams (AdTech)

**What**: Aggregating indexes with array columns and lambdas for fact-to-fact patterns (e.g. conversions without impressions).  
**Value**: Unique demo for click-fraud / attribution; proves Firebolt beyond simple star schemas.  
**Best Demo Vertical**: AdTech only.

**Blog reference**: [Event Streams in Firebolt](https://www.firebolt.io/blog/event-streams-in-firebolt) (click fraud pattern).

| Demo | Description |
|------|-------------|
| Conversions without impressions | nest() + array aggregating index |
| Session-level event streams | Array columns, lambda aggregations |

**Requires**: AdTech schema extension (e.g. `session_events ARRAY`, nest/lambda in agg index).  
**Firebolt docs**: [Aggregating indexes](https://docs.firebolt.io/sql-reference/aggregating-indexes), [Working with arrays](https://docs.firebolt.io/sql-reference/data-types#array) — for nest() and array column syntax.

---

### 🔲 Data Lake / Iceberg (Future)

**What**: READ_ICEBERG, sub-second queries on Iceberg tables.  
**Value**: Data lake use case; 6B-row TPC-H style benchmarks.  
**Status**: Not yet a PLG IDE vertical; add if Iceberg is strategic.

**Blog references**: [Unlocking Faster Iceberg Queries](https://www.firebolt.io/blog/unlocking-faster-iceberg-queries-the-writer-optimizations-you-are-missing), [Querying Apache Iceberg Sub-Second](https://www.firebolt.io/blog/querying-apache-iceberg-with-sub-second-performance). Local: firebolt-iceberg-demo.

---

## Firebolt Blog–Driven Feature Demos

Evaluation of Firebolt engineering blogs (Feb 2024–Feb 2025) mapped to PLG IDE verticals and implementation order.

### Priority Matrix (Blog → Vertical → Effort)

| Feature | Best vertical(s) | Second | Effort |
|---------|------------------|--------|--------|
| Late Materialization | E-commerce, Observability | Financial | Medium (schema tweaks, demo_comparison) |
| Vector Search | E-commerce, Observability | AdTech, Financial | Medium–High (embeddings, Ollama/local) |
| Event Streams (arrays + agg index) | AdTech | — | Medium (array columns, nest/lambda) |
| Streaming Ingestion | Gaming, Observability | AdTech | High (Kafka/Confluent setup) |
| Iceberg | New Data Lake vertical | — | Medium (public S3 dataset) |
| Case studies (MerchJar, TLDCRM) | AdTech, Observability | — | Low (README/talking points) |

### Implementation order (blog-aligned)

1. **Late Materialization** — E-commerce and Observability first; align with firebolt-late-materialization-demo.
2. **Vector Search** — E-commerce (recommendations) and Observability (log similarity); use vector-search-index-demo and RAG blog patterns.
3. **Event Streams (AdTech)** — Port click-fraud pattern from Event Streams blog; extend AdTech schema with array columns and nest() aggregating index.
4. **Streaming Ingestion** — Start with Gaming; reference Firex-gaming-demo and Confluent connector blog.
5. **Iceberg** — Add as new vertical or global feature if strategic; use firebolt-iceberg-demo.
6. **Case studies** — Add MerchJar and TLDCRM as references in AdTech and Observability READMEs.

### Schema changes required (summary)

| Vertical | Late Mat | Vector Search | Event Streams |
|----------|----------|---------------|---------------|
| E-commerce | products wide TEXT/JSON | embedding or product_embeddings | — |
| Observability | debug_trace/wide column on logs | embedding or log_embeddings | — |
| AdTech | — | Optional | session_events ARRAY, nest() |
| Gaming | Optional wide columns | — | — |
| Financial | Optional transaction_details | Embeddings for fraud | — |

### Reference implementations (repos)

Use these for query patterns, schema, and runnable examples when building the next demos in plg-ide:

| Feature | Repo / reference | URL |
|---------|------------------|-----|
| Streaming (Gaming) | Firex-gaming-demo | [firebolt-analytics/gaming-demo](https://github.com/firebolt-analytics/gaming-demo) |
| Late Materialization | firebolt-late-materialization-demo | TBD (align with Product-Late-Materialisation demo pattern) |
| Vector Search | vector-search-index-demo | TBD |
| Iceberg | firebolt-iceberg-demo | TBD |

Add URLs above when repos are available. See also vertical READMEs (e.g. [verticals/gaming/README.md](verticals/gaming/README.md)) for vertical-specific references.

### Next demos: plg-ide paths

Create feature demos under these directories so the repo stays consistent with existing aggregating-index demos:

| Feature | First vertical(s) | Path(s) to add |
|---------|-------------------|-----------------|
| Late Materialization | E-commerce, Observability | `verticals/ecommerce/features/late_materialization/` (01_baseline, 02_create, 03_optimized, demo_comparison), same under `verticals/observability/` |
| Vector Search | E-commerce, Observability | `verticals/ecommerce/features/vector_search/`, `verticals/observability/features/vector_search/` |
| Event Streams | AdTech | `verticals/adtech/features/event_streams/` (schema change in `verticals/adtech/schema/` first) |
| Streaming Ingestion | Gaming, Observability | `verticals/gaming/features/streaming_ingestion/`, `verticals/observability/features/streaming_ingestion/` (or doc + link to Confluent connector) |
| Iceberg | New vertical | `verticals/datalake/` or global feature; schema + READ_ICEBERG load |

Follow the pattern in [Adding a New Feature](#adding-a-new-feature): baseline SQL, setup/index SQL, optimized SQL, and benchmark or demo_comparison where applicable.

---

## Sample Datasets (from Firebolt)

| Dataset | Size | Rows | Best For |
|---------|------|------|----------|
| Ultra Fast Gaming | ~1GB | 10M+ | Gaming vertical ✅ |
| E-commerce | 52GB | 412M | E-commerce vertical |
| NYC Parking | 4.5GB | 21M | Government, time-series |
| NYC Traffic | 3.71GB | 27M | IoT, geospatial |
| NYC Restaurants | 93MB | 209K | Quick demos, semi-structured |
| NYC Philharmonic | 31MB | 164K | JSON handling |

Source: https://www.firebolt.io/free-sample-datasets

---

## Competitive Comparison Demos (Firebolt vs ClickHouse)

**Goal**: Prove Firebolt is faster, simpler, or more cost-effective than ClickHouse on the same workloads.

Reference: https://clickhouse.com/demos (their demos = our benchmarks)

### Strategy

For each ClickHouse demo, we create a Firebolt equivalent that:
1. Uses the **same dataset** (apples-to-apples comparison)
2. Runs the **same queries** (fair benchmark)
3. Shows **Firebolt advantages**: faster queries, simpler setup, lower cost, better concurrency

### 🔲 SQL Playground Comparison

**ClickHouse**: SQL Playground (35+ datasets, 220+ queries)  
**Firebolt**: Same datasets, same queries, faster results

| Comparison Point | ClickHouse | Firebolt Advantage |
|------------------|------------|-------------------|
| Query latency | Good | Better with aggregating indexes |
| Setup complexity | Manual cluster config | Serverless, auto-scaling |
| Concurrent users | Requires tuning | Built-in workload isolation |

**Proof Point**: Run identical queries, show execution time difference.

---

### 🔲 GitHub Analytics Benchmark

**ClickHouse**: GitHub Team Activity Dashboard  
**Firebolt**: Same GitHub Archive data, faster aggregations

| Metric | Benchmark |
|--------|-----------|
| Dataset | GitHub Archive (7.5B+ events) |
| Query | "Top repos by stars this year" |
| Comparison | Query time, data scanned, cost |

**Firebolt Advantage**: Aggregating indexes pre-compute star counts → instant results vs full scan.

---

### 🔲 Package Analytics (PyPI) Benchmark

**ClickHouse**: ClickPy  
**Firebolt**: FirePy - same PyPI data, better performance

| Metric | Benchmark |
|--------|-----------|
| Dataset | PyPI downloads (1T+ rows) |
| Query | "Daily downloads for package X over 2 years" |
| Comparison | Time-series aggregation speed |

**Firebolt Advantage**: 
- Aggregating indexes on `package, date` = instant time-series
- Late materialization = read only needed columns

---

### 🔲 Real-Time Market Data Benchmark

**ClickHouse**: StockHouse  
**Firebolt**: Same market data, lower latency

| Metric | Benchmark |
|--------|-----------|
| Ingestion | Events per second |
| Query latency | P99 under load |
| Concurrent queries | Dashboard refresh rate |

**Firebolt Advantage**:
- Better concurrent query handling
- Consistent latency under mixed workloads

---

### 🔲 Blockchain Analytics Benchmark

**ClickHouse**: CryptoHouse  
**Firebolt**: Same chain data, simpler queries

| Metric | Benchmark |
|--------|-----------|
| Dataset | Ethereum/Solana transactions |
| Query | Wallet balance history, token transfers |
| Comparison | Query complexity, performance |

**Firebolt Advantage**:
- Simpler SQL (no complex ClickHouse-specific syntax)
- Standard PostgreSQL compatibility
- Better join performance

---

### 🔲 Flight Tracker Benchmark

**ClickHouse**: adsb.exposed  
**Firebolt**: Same ADS-B data, better geospatial

| Metric | Benchmark |
|--------|-----------|
| Dataset | 50B+ flight records |
| Query | "All flights in bounding box last hour" |
| Comparison | Geospatial query speed |

**Firebolt Advantage**: 
- Primary index on location = fast spatial filtering
- Aggregating indexes for airport statistics

---

### Benchmark Methodology

For each comparison demo:

1. **Same Data**: Load identical dataset into both systems
2. **Same Queries**: Run exact same SQL (adjusted for syntax only)
3. **Fair Config**: Use comparable instance sizes/costs
4. **Metrics Captured**:
   - Query execution time (P50, P95, P99)
   - Data scanned (bytes)
   - Concurrent query performance
   - Setup complexity (lines of config)
   - Cost per query

5. **Publish Results**: 
   - Side-by-side comparison tables
   - "Run it yourself" reproducible scripts
   - Video walkthroughs

---

### Key Firebolt Differentiators to Prove

| Differentiator | How to Prove |
|----------------|--------------|
| **Aggregating Indexes** | Same query, 50-100X faster on Firebolt |
| **Late Materialization** | Wide tables, 80% less data read |
| **Simpler SQL** | Standard Postgres vs ClickHouse syntax |
| **Better Concurrency** | 100 concurrent queries, consistent latency |
| **Serverless Simplicity** | Lines of config: Firebolt 5 vs ClickHouse 50 |
| **Cost Efficiency** | Same workload, lower cloud bill |

---

## Implementation Priority

### Phase 1: Foundation (Current) ✅
- [x] Repository structure
- [x] Runtime abstraction (Cloud + Core)
- [x] MCP integration
- [x] Gaming vertical
- [x] Aggregating indexes demo

### Phase 2: Expand Verticals
- [x] E-commerce vertical (schema, data, aggregating indexes demo)
- [x] AdTech vertical (schema, data, aggregating indexes demo)
- [x] Observability vertical (schema, data, aggregating indexes demo)
- [x] Financial vertical (schema, data, aggregating indexes demo)
- [ ] Late materialization demos

### Phase 3: Advanced Features (blog-driven order)
- [ ] Vector search demos (E-commerce, Observability; reference vector-search-index-demo)
- [ ] Event Streams demo (AdTech: click-fraud pattern, array agg index)
- [ ] High concurrency demos (AdTech)
- [ ] Streaming ingestion demos (Gaming, Observability; Confluent connector)
- [ ] Iceberg / Data Lake vertical (optional; firebolt-iceberg-demo)

### Phase 4: Competitive Benchmarks (Loveable App)
- [ ] SQL Playground with side-by-side ClickHouse comparison
- [ ] GitHub Analytics benchmark (same data, faster on Firebolt)
- [ ] Benchmark methodology + reproducible scripts
- [ ] "Run it yourself" comparison tools

### Phase 5: Head-to-Head Demos
- [ ] PyPI Analytics (ClickPy equivalent, prove aggregating index advantage)
- [ ] Market Data (StockHouse equivalent, prove concurrency advantage)
- [ ] Flight Tracker (prove geospatial + real-time advantage)
- [ ] Blockchain Analytics (prove simpler SQL advantage)

---

## Loveable App Development

The Loveable app provides a web-based UI for users not using an IDE directly. Built from this repo's documentation.

### Loveable Specification Files

| File | Purpose |
|------|---------|
| `KNOWLEDGE.md` | Primary AI context - product vision, design system, features |
| `docs/APP_SPEC.md` | Page structure, layouts, component specifications |
| `docs/DATA_CONTRACTS.md` | TypeScript interfaces for all data shapes |
| `docs/USER_FLOWS.md` | Step-by-step user journeys |

### Loveable Build Phases

#### Phase L1: Core Demo Runner
- [ ] Home page with runtime selection (Core vs Cloud)
- [ ] Connection setup wizard
- [ ] Vertical selection grid (Gaming first)
- [ ] Feature selection within vertical
- [ ] Before/After benchmark comparison view
- [ ] Metric display cards with improvement percentages

**Design System**: Use Firebolt brand colors (#F72A30 primary), Poppins headings, Inter body text

#### Phase L2: SQL Playground
- [ ] SQL editor with syntax highlighting (Monaco/CodeMirror)
- [ ] Dark theme code blocks (#1A0404 background, Roboto Mono)
- [ ] Query results table with pagination
- [ ] Execution metrics display
- [ ] Schema browser sidebar
- [ ] Query history (local storage)

#### Phase L3: Sales Training Mode
- [ ] Training module structure
- [ ] Progress tracking per user
- [ ] Quiz/verification at end of modules
- [ ] Talking points for each demo
- [ ] Exportable demo results (PDF/markdown)

#### Phase L4: Competitive Benchmarks
- [ ] Side-by-side comparison UI (Firebolt vs ClickHouse)
- [ ] Benchmark methodology display
- [ ] "Run it yourself" instructions
- [ ] Share/export results
- [ ] Key differentiator highlights

#### Phase L5: Partner Portal
- [ ] Multi-user authentication
- [ ] Team progress dashboards
- [ ] Certification path
- [ ] Custom branding for partners

### Loveable Starter Prompts

Use these prompts to build incrementally:

1. "Create a home page with runtime selection using Firebolt brand colors from KNOWLEDGE.md"
2. "Build a vertical selection grid with cards for Gaming, showing dataset info"
3. "Create a benchmark comparison page with before/after metric cards"
4. "Add a SQL editor with dark theme and Roboto Mono font"
5. "Build a connection wizard with step indicators"

---

## Adding a New Vertical

1. Create `verticals/{name}/README.md` with use case overview
2. Create `verticals/{name}/schema/01_tables.sql`
3. Create `verticals/{name}/data/load.sql` (S3 COPY or sample generator)
4. Add feature demos in `verticals/{name}/features/{feature}/`
5. **Update `docs/app-manifest.json`** – add the new vertical (id, name, description, dataset, database, tables, rowCount, furtherReading, features). The IDE and Loveable app use the manifest as the single source of truth; without this step they will not show the new vertical.
6. Update this roadmap (ROADMAP.md)

## Adding a New Feature

1. Create `features/{name}/README.md` with feature explanation
2. Identify best vertical to showcase the feature
3. Create demo in `verticals/{vertical}/features/{name}/`
4. Add baseline, setup, optimized SQL files (e.g. 01_baseline.sql, 02_create_indexes.sql, 03_optimized.sql)
5. Create benchmark.py for automated comparison (if applicable)
6. **Update `docs/app-manifest.json`** – add the feature to the relevant vertical's `features` array (id, name, description, status: `available` or `coming_soon`). Add to `features_global` if it is a cross-vertical feature. Without this step the IDE and Loveable app will not show the new feature.
7. Update this roadmap (ROADMAP.md)

---

## References

### Firebolt Resources
- [Firebolt Sample Datasets](https://www.firebolt.io/free-sample-datasets)
- [Firebolt Case Studies](https://www.firebolt.io/knowledge-center/case-studies)
- [Firebolt MCP Server](https://github.com/firebolt-db/mcp-server)
- [Firebolt Documentation](https://docs.firebolt.io/)
- [Firebolt Core (Docker)](https://github.com/firebolt-db/firebolt-core)

### Firebolt Engineering Blogs (Feature Demo Sources)
- [Late Materialization: Top-K 30x Faster](https://www.firebolt.io/blog/late-materialization-how-firebolt-makes-top-k-queries-30x-faster)
- [Pruning with Late Materialization](https://www.firebolt.io/blog/pruning-even-more-data-with-late-materialization)
- [Vector Search Indexes Technical Deep Dive](https://www.firebolt.io/blog/technical-deep-dive-efficient-and-acid-compliant-vector-search-indexes-in-firebolt)
- [Building RAG Chatbot with Firebolt](https://www.firebolt.io/blog/building-a-chatbot-with-firebolt-using-retrieval-augmented-generation)
- [Event Streams in Firebolt](https://www.firebolt.io/blog/event-streams-in-firebolt)
- [Firebolt Connector for Confluent](https://www.firebolt.io/blog/firebolt-connector-for-confluent---real-time-applications-powered-by-streaming-data)
- [Unlocking Faster Iceberg Queries](https://www.firebolt.io/blog/unlocking-faster-iceberg-queries-the-writer-optimizations-you-are-missing)
- [Querying Apache Iceberg Sub-Second](https://www.firebolt.io/blog/querying-apache-iceberg-with-sub-second-performance)
- [Eliminating OLTP vs OLAP Trade-off](https://www.firebolt.io/blog/eliminating-the-oltp-vs-olap-trade-off) (MerchJar)
- [Where Do I Put My Logs?](https://www.firebolt.io/blog/where-do-i-put-my-logs) (TLDCRM)

### Competitive Targets: ClickHouse Demos
These are the demos we will beat with Firebolt equivalents:

| Their Demo | Their URL | Our Advantage |
|------------|-----------|---------------|
| SQL Playground | [sql.clickhouse.com](https://sql.clickhouse.com/) | Faster with agg indexes |
| ClickPy | [clickpy.clickhouse.com](https://clickpy.clickhouse.com/) | Better time-series |
| GitHub Activity | [gh.clickhouse.tech](https://gh.clickhouse.tech/) | Pre-computed aggregates |
| adsb.exposed | [adsb.exposed](https://adsb.exposed/) | Geospatial + real-time |
| CryptoHouse | [crypto.clickhouse.com](https://crypto.clickhouse.com/) | Simpler SQL, better joins |

### ClickHouse GitHub Repos (Study for Benchmark Design)
- [clickhouse/github-explorer](https://github.com/ClickHouse/github-explorer) - Queries to replicate
- [clickhouse/clickpy](https://github.com/ClickHouse/clickpy) - Schema + queries to benchmark
- [clickhouse/adsb.exposed](https://github.com/ClickHouse/adsb.exposed) - Geospatial patterns
- [clickhouse/CryptoHouse](https://github.com/ClickHouse/CryptoHouse) - Blockchain queries

### Public Datasets
- [GitHub Archive](https://www.gharchive.org/) - GitHub events
- [PyPI Downloads](https://packaging.python.org/en/latest/guides/analyzing-pypi-package-downloads/) - Package stats
- [ADS-B Exchange](https://www.adsbexchange.com/) - Flight data
- [Goldsky](https://goldsky.com/) - Blockchain data
