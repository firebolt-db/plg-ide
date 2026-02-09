# plg-ide: Firebolt Developer Experience

> **⚠️ DRAFT - Early Development**
> 
> This repository is in early development. Structure, APIs, and demos are subject to change.
> See [ROADMAP.md](ROADMAP.md) for planned features and timeline.

Experience Firebolt's value through interactive, feature-by-feature demonstrations in your IDE.

## Quick Start

### 1. Add Firebolt MCP to Cursor (one click)

**Firebolt Core (local, no account):** Use the button below. You’ll need [Docker](https://docs.docker.com/get-docker/) and [Firebolt Core](https://docs.firebolt.io/core/) running (e.g. `docker run -d -p 3473:3473 ghcr.io/firebolt-db/firebolt-core:latest`).

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

### Features

Prove-the-value demonstrations:

| Feature | What It Does | Typical Improvement |
|---------|--------------|---------------------|
| [Aggregating Indexes](features/aggregating_indexes/) | Pre-computed aggregations | 50-100X faster queries |
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
│   └── financial/              # Transactions, risk, reporting
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

## License

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for the full text.
