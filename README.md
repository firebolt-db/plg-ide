# PLG-IDE: Firebolt Developer Experience

> **⚠️ DRAFT - Early Development**
> 
> This repository is in early development. Structure, APIs, and demos are subject to change.
> See [ROADMAP.md](ROADMAP.md) for planned features and timeline.

Experience Firebolt's value through interactive, feature-by-feature demonstrations in your IDE.

## Quick Start

### 1. Install Prerequisites

```bash
./setup.sh
```

This pulls the required Docker images (Firebolt Core and MCP Server).

### 2. Open in Cursor

Open this repo in Cursor and ask:

> "Help me get started with Firebolt"

The AI will guide you through:

1. **Selecting your runtime** - Firebolt Core (local, free) or Firebolt Cloud
2. **Configuring MCP** - Connects Cursor directly to Firebolt
3. **Running demos** - Interactive proof-of-value demonstrations

### What Happens Next

Once configured, you can interact with Firebolt naturally:

- "Create the gaming demo tables"
- "Show me how aggregating indexes improve query performance"
- "Run a leaderboard query and explain the results"
- "How do I optimize this query?"

The AI uses the [Firebolt MCP Server](https://github.com/firebolt-db/mcp-server) to execute queries and search documentation in real-time.

## What's Inside

### Verticals

Industry-specific demos with real datasets:

| Vertical | Dataset | Size | Description |
|----------|---------|------|-------------|
| [Gaming](verticals/gaming/) | Ultra Fast Gaming | ~1GB | Real-time leaderboards, player analytics |
| E-commerce | Coming Soon | 52GB | Retail analytics, customer behavior |
| AdTech | Coming Soon | - | High QPS, auction analytics |

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

### Firebolt MCP Server

The [Firebolt MCP Server](https://github.com/firebolt-db/mcp-server) is the recommended way to interact with Firebolt from your IDE. It provides:

| Tool | Description |
|------|-------------|
| `firebolt_connect` | Connect to Firebolt databases and engines |
| `firebolt_query` | Execute SQL queries directly |
| `firebolt_docs_search` | Search Firebolt documentation |
| `firebolt_docs_overview` | Get documentation overview |

### Setup for Different IDEs

**Cursor** (copy from `config/mcp-cursor-core.json`):
```json
{
  "mcpServers": {
    "firebolt": {
      "command": "docker",
      "args": ["run", "-i", "--rm", "--network", "host",
               "-e", "FIREBOLT_MCP_CORE_URL",
               "-e", "FIREBOLT_MCP_DISABLE_RESOURCES=true",
               "ghcr.io/firebolt-db/mcp-server:0.6.0"],
      "env": { "FIREBOLT_MCP_CORE_URL": "http://localhost:3473" }
    }
  }
}
```

**Claude Desktop** (copy from `config/mcp-claude-desktop.json`):
```json
{
  "mcpServers": {
    "firebolt": {
      "command": "docker",
      "args": ["run", "-i", "--rm", "--network", "host",
               "-e", "FIREBOLT_MCP_CORE_URL",
               "ghcr.io/firebolt-db/mcp-server:0.6.0"],
      "env": { "FIREBOLT_MCP_CORE_URL": "http://localhost:3473" }
    }
  }
}
```

### Guided Experience

This repo includes Cursor rules that guide you through demos:

1. Open in Cursor with MCP configured
2. Ask: "Show me the gaming demo" or "How do aggregating indexes work?"
3. The AI will use MCP tools to connect, run queries, and explain results

## Repository Structure

```
PLG-IDE/
├── config/                      # Configuration files
│   ├── mcp-cursor-core.json     # MCP config for Cursor + Core
│   ├── mcp-cursor-cloud.json    # MCP config for Cursor + Cloud
│   ├── mcp-claude-desktop.json  # MCP config for Claude Desktop
│   ├── core.env.template        # Python env for Core
│   └── cloud.env.template       # Python env for Cloud
├── lib/                         # Python runtime abstraction
├── verticals/                   # Industry-specific demos
│   └── gaming/
│       ├── schema/              # Table definitions
│       ├── data/                # Data loading scripts
│       └── features/            # Feature demos
├── features/                    # Cross-vertical feature docs
└── .cursor/rules/               # IDE integration rules
```

## Requirements

**For MCP-based IDE experience (recommended):**
- Docker (for MCP server and Firebolt Core)
- Cursor, Claude Desktop, or other MCP-compatible IDE

**For Python benchmark scripts:**
- Python 3.9+
- Docker (for Firebolt Core) OR Firebolt Cloud account
- pip packages: `firebolt-sdk`, `tabulate`, `python-dotenv`

## Roadmap

See [ROADMAP.md](ROADMAP.md) for planned verticals and features:

| Verticals | Features |
|-----------|----------|
| ✅ Gaming | ✅ Aggregating Indexes |
| 🔲 E-commerce | 🔲 Late Materialization |
| 🔲 AdTech | 🔲 Vector Search |
| 🔲 Observability | 🔲 High Concurrency |
| 🔲 Financial | 🔲 Streaming Ingestion |

## License

MIT
