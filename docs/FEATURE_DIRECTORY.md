# Feature directory: go straight to what you need

If you already know which capability you want to try, use one of the paths below. The full list of verticals and features is in [docs/app-manifest.json](app-manifest.json).

---

## In the IDE (Cursor)

Open this repo in Cursor, connect Firebolt (Quick Start in [README](../README.md)), then ask in natural language for the feature by name. The AI will skip vertical selection and take you straight to that demo.

**Examples:**

- *"I only want to see automated column statistics"* → Gaming demo for Automated Column Statistics
- *"Show me aggregating indexes"* → You’ll be asked which vertical (or say e.g. *"Gaming"*)
- *"I want to try partitioning"* → E-commerce Partitioning demo

**Feature names the IDE recognizes** (from the manifest): Aggregating Indexes, Automated Column Statistics, Partitioning, Late Materialization, Vector Search, High Concurrency, Text Search, Time Travel. For features with demos in only one vertical (e.g. Automated Column Statistics in Gaming), you don’t need to name the vertical.

---

## In the web app (when built with Loveable)

Use a **direct URL** so you land on that feature’s demo page. If you’re not connected yet, the app will run the Setup Wizard and then redirect you to this URL.

**URL pattern:** `https://<app-host>/demo/<vertical_id>/<feature_id>`

**Example deep links:**

| Feature | Example URL (one vertical) |
|--------|-----------------------------|
| Aggregating Indexes | `/demo/gaming/aggregating_indexes` |
| Automated Column Statistics | `/demo/gaming/automated_column_statistics` |
| Partitioning | `/demo/ecommerce/partitioning` |

**Optional:** Open the app with `?feature=<feature_id>` (and optionally `?vertical=<vertical_id>`). The app will redirect to `/demo/<vertical>/<feature>`; if you omit vertical, it picks the first vertical that has that feature.

**Feature IDs** (for URLs and query params): `aggregating_indexes`, `automated_column_statistics`, `partitioning`, `late_materialization`, `vector_search`, `high_concurrency`, `text_search`, `time_travel`.

---

## Directory table (feature → verticals with demo)

| Feature | Vertical(s) with demo | IDE prompt | App URL example |
|---------|------------------------|------------|------------------|
| Aggregating Indexes | All (gaming, ecommerce, adtech, observability, financial, cybertech) | "Show me aggregating indexes" (+ choose vertical) | `/demo/gaming/aggregating_indexes` |
| Automated Column Statistics | Gaming | "I only want to see automated column statistics" | `/demo/gaming/automated_column_statistics` |
| Partitioning | E-commerce | "Show me partitioning" or "E-commerce partitioning" | `/demo/ecommerce/partitioning` |
| Late Materialization | (coming_soon) | — | — |
| Vector Search, High Concurrency, Text Search, Time Travel | (coming_soon in one or more verticals) | — | — |

Source of truth for which verticals have which features (and `available` vs `coming_soon`): [docs/app-manifest.json](app-manifest.json).

**Version requirements:** Some features need a specific Firebolt Core or Cloud version. See [Firebolt version requirements](FIREBOLT_VERSIONS.md) for Core/Cloud compatibility.

---

## For contributors: file paths

Demo content lives under `verticals/<vertical_id>/features/<feature_id>/`:

- `01_baseline.sql` – query without the feature
- `02_*.sql` – enable the feature (e.g. `02_add_statistics.sql`, `02_create_indexes.sql`)
- `03_optimized.sql` – same query with the feature

Feature-level docs: `features/<feature_id>/README.md`.
