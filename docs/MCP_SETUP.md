# Firebolt MCP Server Setup Guide

The [Firebolt MCP Server](https://github.com/firebolt-db/mcp-server) connects your AI-powered IDE directly to Firebolt, enabling natural language queries, documentation access, and interactive demos.

## Recommended: Let the IDE Guide You

When you open this repo in Cursor and ask "Help me get started", the AI will:

1. Ask which runtime you want (Core or Cloud)
2. Provide the exact MCP configuration for your choice
3. Walk you through setup step by step

This is the easiest way to get configured correctly.

## Why Use MCP?

| Without MCP | With MCP |
|-------------|----------|
| Copy SQL from files, paste into terminal | "Run the leaderboard query" |
| Read docs separately | "How do aggregating indexes work?" |
| Manual connection setup | Automatic connection management |
| Script-based benchmarks only | Interactive exploration |

## Manual Setup (if needed)

### Firebolt Core (Local)

1. Start Firebolt Core:
   ```bash
   docker run -d -p 3473:3473 ghcr.io/firebolt-db/firebolt-core:latest
   ```

2. Add to Cursor MCP settings:
   ```json
   {
     "mcpServers": {
       "firebolt": {
         "command": "docker",
         "args": [
           "run", "-i", "--rm", "--network", "host",
           "-e", "FIREBOLT_MCP_CORE_URL",
           "-e", "FIREBOLT_MCP_DISABLE_RESOURCES=true",
           "ghcr.io/firebolt-db/mcp-server:0.6.0"
         ],
         "env": {
           "FIREBOLT_MCP_CORE_URL": "http://localhost:3473"
         }
       }
     }
   }
   ```

### Firebolt Cloud

Add to Cursor MCP settings with your service account credentials:

```json
{
  "mcpServers": {
    "firebolt": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm", "--network", "host",
        "-e", "FIREBOLT_MCP_CLIENT_ID",
        "-e", "FIREBOLT_MCP_CLIENT_SECRET",
        "-e", "FIREBOLT_MCP_DISABLE_RESOURCES=true",
        "ghcr.io/firebolt-db/mcp-server:0.6.0"
      ],
      "env": {
        "FIREBOLT_MCP_CLIENT_ID": "your-client-id",
        "FIREBOLT_MCP_CLIENT_SECRET": "your-client-secret"
      }
    }
  }
}
```

> **Note**: Cursor requires `FIREBOLT_MCP_DISABLE_RESOURCES=true` as it doesn't support MCP resources yet.

#### Claude Desktop

1. Open Claude menu > Settings > Developer > Edit Config
2. Add this to `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "firebolt": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm", "--network", "host",
        "-e", "FIREBOLT_MCP_CORE_URL",
        "ghcr.io/firebolt-db/mcp-server:0.6.0"
      ],
      "env": {
        "FIREBOLT_MCP_CORE_URL": "http://localhost:3473"
      }
    }
  }
}
```

3. Restart Claude Desktop

#### VS Code with GitHub Copilot

See: [Extending Copilot Chat with MCP](https://code.visualstudio.com/docs/copilot/copilot-extensibility-overview)

### 3. Verify Connection

In your IDE, try:
- "Connect to Firebolt and show available databases"
- "Search Firebolt docs for aggregating indexes"

## Using Firebolt Cloud

Replace Core URL with service account credentials:

```json
{
  "mcpServers": {
    "firebolt": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm", "--network", "host",
        "-e", "FIREBOLT_MCP_CLIENT_ID",
        "-e", "FIREBOLT_MCP_CLIENT_SECRET",
        "-e", "FIREBOLT_MCP_DISABLE_RESOURCES=true",
        "ghcr.io/firebolt-db/mcp-server:0.6.0"
      ],
      "env": {
        "FIREBOLT_MCP_CLIENT_ID": "your-client-id",
        "FIREBOLT_MCP_CLIENT_SECRET": "your-client-secret"
      }
    }
  }
}
```

## Available MCP Tools

| Tool | Description | Example Usage |
|------|-------------|---------------|
| `firebolt_connect` | Connect to database/engine | "Connect to the plg_demo database" |
| `firebolt_query` | Execute SQL | "Run: SELECT COUNT(*) FROM playstats" |
| `firebolt_docs_search` | Search documentation | "How do I create an aggregating index?" |
| `firebolt_docs_overview` | Get docs overview | "Show me Firebolt documentation overview" |

## Running Demos with MCP

Instead of running Python scripts, you can run demos interactively:

### Example: Aggregating Indexes Demo

1. **"Create the gaming tables"**
   - AI reads `verticals/gaming/schema/01_tables.sql`
   - Uses `firebolt_query` to execute

2. **"Load sample gaming data"**
   - AI generates INSERT statements or uses COPY
   - Uses `firebolt_query` to execute

3. **"Show me the baseline performance for a leaderboard query"**
   - AI reads `verticals/gaming/features/aggregating_indexes/01_baseline.sql`
   - Executes and shows timing

4. **"Now create the aggregating indexes"**
   - AI reads `02_create_indexes.sql`
   - Executes index creation

5. **"Run the same query again and compare"**
   - Executes optimized query
   - Compares before/after timing

## Troubleshooting

### MCP Server Not Starting

```bash
# Check if Docker is running
docker ps

# Pull the latest MCP server image
docker pull ghcr.io/firebolt-db/mcp-server:0.6.0

# Test manually
docker run --rm --network host \
  -e FIREBOLT_MCP_CORE_URL=http://localhost:3473 \
  ghcr.io/firebolt-db/mcp-server:0.6.0 --help
```

### Connection Issues

```bash
# Check if Firebolt Core is running
curl http://localhost:3473/
```

### Cursor-Specific Issues

- Ensure `FIREBOLT_MCP_DISABLE_RESOURCES=true` is set
- Restart Cursor after config changes

## Resources

- [Firebolt MCP Server GitHub](https://github.com/firebolt-db/mcp-server)
- [Model Context Protocol Spec](https://modelcontextprotocol.io/)
- [Firebolt Documentation](https://docs.firebolt.io/)
