# plg-ide: Firebolt Developer Experience

> **⚠️ DRAFT - Early Development**
> 
> This repository is in early development. Structure, APIs, and demos are subject to change.
> See [ROADMAP.md](ROADMAP.md) for planned features and timeline.
>
> **Adding new demos or changing app/setup flow?** Follow the strict plan in [docs/PLAN_AND_GOVERNANCE.md](docs/PLAN_AND_GOVERNANCE.md). New capabilities must adhere to it (real connectivity, confirm target before writes, impact-first demo pattern); do not replace it with a different approach.

Experience Firebolt's value through interactive, feature-by-feature demonstrations in your IDE.

## How to use this repo

- **Use in your IDE** — Follow the Quick Start below, open this repo in Cursor (or another MCP-capable IDE), and ask **"Help me get started with Firebolt"**. You’ll be guided through runtime setup, then to pick a vertical and feature and run demos with real SQL and metrics.
- **Build the web app (Loveable)** — Clone this repo and use it as context for [Loveable](https://loveable.dev) to build the plg-ide web application. Start with **[docs/LOVEABLE.md](docs/LOVEABLE.md)**; it defines the read order (PLAN_AND_GOVERNANCE, KNOWLEDGE, APP_SPEC, DATA_CONTRACTS, USER_FLOWS, app-manifest) and connectivity rules. The app will offer the same exploratory stepped experience as the IDE (connection → confirm target → vertical → feature → run SQL → show metrics and explain).
- **Add a vertical or capability** — Follow **[docs/PLAN_AND_GOVERNANCE.md](docs/PLAN_AND_GOVERNANCE.md)** and the "Adding a New Vertical" / "Adding a New Feature" sections in [ROADMAP.md](ROADMAP.md). You **must** update **[docs/app-manifest.json](docs/app-manifest.json)** when adding verticals or features so the IDE and Loveable app both see the new content. See **[docs/CONTRIBUTING.md](docs/CONTRIBUTING.md)** for a consolidated checklist. Run `python3 scripts/validate_manifest_structure.py` to verify the repo structure matches the manifest.
- **Deep control** — See **[docs/DEEP_CONTROL.md](docs/DEEP_CONTROL.md)** for all engine, query, and caching controls and which run on Core vs Cloud (including Cloud-only features like Engine Lifecycle and Cross-Region).

### Go straight to a feature (you already know what you need)

- **In the IDE:** After connecting (Quick Start below), ask for the feature by name, e.g. *"I only want to see automated column statistics"* or *"Show me aggregating indexes"*. The AI will take you straight to that demo (and, if needed, a vertical that has it).
- **In the web app:** Use a direct link to the feature’s demo page: `/demo/<vertical_id>/<feature_id>` (e.g. `/demo/gaming/automated_column_statistics`). If you’re not connected, the app runs setup then opens that page. You can also use `?feature=<feature_id>` on the home page to be redirected.
- **Directory:** For a full list of features and their direct paths (IDE prompts and app URLs), see **[docs/FEATURE_DIRECTORY.md](docs/FEATURE_DIRECTORY.md)**. Some features require a specific Firebolt Core or Cloud version—see **[docs/FIREBOLT_VERSIONS.md](docs/FIREBOLT_VERSIONS.md)**. Some capabilities (Engine Lifecycle, Cross-Region) are **Cloud-only**: on Core you see example SQL and a notice; run the demo on Firebolt Cloud. See **[docs/DEEP_CONTROL.md](docs/DEEP_CONTROL.md)** for all deep control settings and runtime labels.

## Quick Start

### 1. Add Firebolt MCP to Cursor (one click)

**Firebolt Core (local, no account):** Use the button below. You’ll need [Docker](https://docs.docker.com/get-docker/) and [Firebolt Core](https://docs.firebolt.io/core/) running (e.g. `docker run -d -p 3473:3473 ghcr.io/firebolt-db/firebolt-core:latest`). Some demos require a recent Core image—see [docs/FIREBOLT_VERSIONS.md](docs/FIREBOLT_VERSIONS.md).

[![Add to Cursor](https://cursor.com/deeplink/mcp-install-dark.svg)](https://cursor.com/en-US/install-mcp?name=Firebolt%20MCP%20%28Core%29&config=eyJjb21tYW5kIjoiZG9ja2VyIiwiYXJncyI6WyJydW4iLCItaSIsIi0tcm0iLCItLW5ldHdvcmsiLCJob3N0IiwiLWUiLCJGSVJFQk9MVF9NQ1BfQ09SRV9VUkwiLCItZSIsIkZJUkVCT0xUX01DUF9ESVNBQkxFX1JFU09VUkNFUz10cnVlIiwiZ2hjci5pby9maXJlYm9sdC1kYi9tY3Atc2VydmVyOjAuNi4wIl0sImVudiI6eyJGSVJFQk9MVF9NQ1BfQ09SRV9VUkwiOiJodHRwOi8vbG9jYWxob3N0OjM0NzMiLCJGSVJFQk9MVF9NQ1BfRElTQUJMRV9SRVNPVVJDRVMiOiJ0cnVlIn19)

**Firebolt Cloud:** Install via the button above, then in Cursor go to **Settings → Tools & MCP → New MCP Server** and add your `FIREBOLT_MCP_CLIENT_ID` and `FIREBOLT_MCP_CLIENT_SECRET` to the server’s env (or use the config in [config/mcp-cursor-cloud.json](config/mcp-cursor-cloud.json)).

### 2. Pull Docker images (optional, for MCP + Core)

```bash
./setup.sh
```

### 3. Open this repo in Cursor and ask

> "Help me get started with Firebolt"

You’ll be guided to pick a runtime (Core or Cloud), then run demos. Example prompts:

- "Create the gaming demo tables"
- "Show me how aggregating indexes improve query performance"
- "Run a leaderboard query and explain the results"

The AI uses the [Firebolt MCP Server](https://github.com/firebolt-db/mcp-server) to run queries and search docs in real time.

## What's Inside

### Verticals

Industry-specific demos with real datasets:

| Vertical | Dataset | Size | Description |
|----------|---------|------|-------------|
| [Gaming](verticals/gaming/) | Ultra Fast Gaming | ~1GB | Real-time leaderboards, player analytics |
| [E-commerce](verticals/ecommerce/) | E-commerce | 52GB | Retail analytics, customer behavior, product recommendations |
| [AdTech](verticals/adtech/) | AdTech | Custom | High QPS, campaign analytics, real-time bidding |
| [Observability](verticals/observability/) | Observability | Custom | Log analytics, metrics aggregation, distributed tracing |
| [Financial](verticals/financial/) | Financial Services | Custom | Transaction analytics, risk scoring, regulatory reporting |
| [CyberTech](verticals/cybertech/) | Multi-Cloud Audit Logs | ~300K events | Security analytics, threat detection, multi-cloud anomaly detection |

### Features

Prove-the-value demonstrations:

| Feature | What It Does | Typical Improvement |
|---------|--------------|---------------------|
| [Aggregating Indexes](features/aggregating_indexes/) | Pre-computed aggregations | 50-100X faster queries |
| [Automated Column Statistics](features/automated_column_statistics/) | Better join ordering from column stats | Up to 3x+ (no query changes) |
| Late Materialization | Coming Soon | Read less data |
| Vector Search | Coming Soon | Semantic search, AI |

## How Demos Work

Each feature demo follows the **prove-the-value** pattern:

1. **Baseline**: Run queries without the feature
2. **Enable**: Create/enable the feature
3. **Optimized**: Run same queries with feature
4. **Compare**: See before/after metrics

Example output:

```
Feature: Aggregating Indexes on playstats_leaderboard

┌─────────────────┬───────────┬───────────┬──────────┐
│ Metric          │ Without   │ With      │ Savings  │
├─────────────────┼───────────┼───────────┼──────────┤
│ Query Time      │ 1,247 ms  │ 15 ms     │ 98.8%    │
│ Rows Scanned    │ 50M       │ 12K       │ 99.97%   │
│ Bytes Read      │ 2.1 GB    │ 1.2 MB    │ 99.94%   │
└─────────────────┴───────────┴───────────┴──────────┘
```

## IDE Integration

The [Firebolt MCP Server](https://github.com/firebolt-db/mcp-server) gives your IDE direct access to Firebolt:

| Tool | Description |
|------|-------------|
| `firebolt_connect` | Connect to databases and engines |
| `firebolt_query` | Execute SQL |
| `firebolt_docs_search` | Search Firebolt docs |
| `firebolt_docs_overview` | Documentation overview |

### Setup by client

| Client | Setup |
|--------|--------|
| **Cursor** | Use the [Add to Cursor](#1-add-firebolt-mcp-to-cursor-one-click) button above (Core), or copy [config/mcp-cursor-core.json](config/mcp-cursor-core.json) / [config/mcp-cursor-cloud.json](config/mcp-cursor-cloud.json). Set env in **Settings → Tools & MCP**. |
| **Claude Desktop** | Copy [config/mcp-claude-desktop.json](config/mcp-claude-desktop.json) into your MCP config; set `FIREBOLT_MCP_CORE_URL` (and Cloud credentials if needed). |

Full step-by-step: [docs/MCP_SETUP.md](docs/MCP_SETUP.md).

## Repository Structure

```
plg-ide/
├── config/                      # Configuration files
│   ├── mcp-cursor-core.json     # MCP config for Cursor + Core
│   ├── mcp-cursor-cloud.json    # MCP config for Cursor + Cloud
│   ├── mcp-claude-desktop.json  # MCP config for Claude Desktop
│   ├── core.env.template        # Python env for Core
│   └── cloud.env.template       # Python env for Cloud
├── lib/                         # Python runtime abstraction
├── verticals/                   # Industry-specific demos (each has schema/, data/, demo_*.sql, features/)
│   ├── gaming/                  # Leaderboards, player analytics
│   ├── ecommerce/               # Retail, revenue, product analytics
│   ├── adtech/                  # Campaigns, impressions, publishers
│   ├── observability/           # Logs, metrics, tracing
│   ├── financial/               # Transactions, risk, reporting
│   └── cybertech/               # Security, threat detection (placeholder)
├── features/                    # Cross-vertical feature docs
├── docs/                        # App spec, Loveable entry, app-manifest.json
└── .cursor/rules/               # IDE integration rules
```

## Requirements

- **MCP (recommended):** Docker, Cursor or [another MCP client](https://modelcontextprotocol.io/clients)
- **Python benchmarks:** Python 3.9+, `pip install -r requirements.txt`, and Docker or a Firebolt Cloud account

## Roadmap

See [ROADMAP.md](ROADMAP.md) for planned verticals and features:

| Verticals | Features |
|-----------|----------|
| ✅ Gaming | ✅ Aggregating Indexes |
| ✅ E-commerce | 🔲 Late Materialization |
| ✅ AdTech | 🔲 Vector Search |
| ✅ Observability | 🔲 High Concurrency |
| ✅ Financial | 🔲 Streaming Ingestion |
| — | ✅ [Deep control](docs/DEEP_CONTROL.md) (Core + Cloud labels) |

## Further reading (after the demo)

Engineering blogs and Firebolt docs that back the demos — use these when presenting "learn more" to users:

- **Aggregating Indexes**: [Firebolt docs: Aggregating indexes](https://docs.firebolt.io/sql-reference/aggregating-indexes)
- **Late Materialization**: [Late Materialization: Top-K 30x Faster](https://www.firebolt.io/blog/late-materialization-how-firebolt-makes-top-k-queries-30x-faster), [Pruning with Late Materialization](https://www.firebolt.io/blog/pruning-even-more-data-with-late-materialization)
- **Vector Search**: [Vector Search Indexes Technical Deep Dive](https://www.firebolt.io/blog/technical-deep-dive-efficient-and-acid-compliant-vector-search-indexes-in-firebolt), [Building RAG Chatbot with Firebolt](https://www.firebolt.io/blog/building-a-chatbot-with-firebolt-using-retrieval-augmented-generation), [Firebolt docs: Vector indexes](https://docs.firebolt.io/sql-reference/vector-indexes)
- **Streaming**: [Firebolt Connector for Confluent](https://www.firebolt.io/blog/firebolt-connector-for-confluent---real-time-applications-powered-by-streaming-data)
- **Event Streams (AdTech)**: [Event Streams in Firebolt](https://www.firebolt.io/blog/event-streams-in-firebolt)
- **Full list**: [ROADMAP.md – References / Firebolt Engineering Blogs](ROADMAP.md#firebolt-engineering-blogs-feature-demo-sources)

## License

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for the full text.
