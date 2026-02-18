# Firebolt version requirements

Some demos in this repo depend on **Firebolt features** that are only available in certain versions of **Firebolt Core** (local Docker) or **Firebolt Cloud**. Use this page to see when you need a specific version to run a feature.

## How we specify versions

- **Firebolt Core:** We use the Docker image tag (e.g. `ghcr.io/firebolt-db/firebolt-core:latest` or a specific tag). The repo’s Quick Start uses `:latest`; for a feature that needs a newer engine, we may call out a minimum tag or “use latest.”
- **Firebolt Cloud:** Feature availability follows [Firebolt Cloud release notes](https://docs.firebolt.io/reference/release-notes). When a demo requires a Cloud feature, we note it here and in the feature’s entry in [app-manifest.json](app-manifest.json) (optional `minCoreVersion` / `versionNote`).

## Feature → version requirements

| Feature | Firebolt Core | Firebolt Cloud |
|--------|----------------|----------------|
| **Aggregating Indexes** | Use `:latest` (or any recent image) | Generally available |
| **Automated Column Statistics** | Use `:latest`; requires a build that supports [Automated Column Statistics](https://docs.firebolt.io/performance-and-observability/query-planning/automated-column-statistics) | Available in current Cloud; see [release notes](https://docs.firebolt.io/reference/release-notes) if on an older engine |
| **Partitioning** | Use `:latest` | Generally available |
| **Query Optimizer Controls, Parallelism, Data Warming** | Use `:latest` (Core + Cloud) | Generally available |
| **Engine Lifecycle, Cross-Region Data Access** | **Cloud only** (examples shown on Core; run on Cloud) | Available on Firebolt Cloud |
| **Late Materialization, Vector Search, Text Search, Time Travel, High Concurrency** | Not yet documented (coming_soon) | See release notes when demos are added |

**Cloud-only features:** Some capabilities are available only on Firebolt Cloud (not on Core). In the app manifest these are marked with `cloudOnly: true` or `availableRuntimes: ["cloud"]`. When connected to Core, the app shows example SQL and a notice that the demo can be run on Cloud; Run is disabled. Examples: **Engine lifecycle** (auto-vacuum, auto-scaling, auto-stop), **Cross-region data access** (COPY WITH CROSS_REGION_REQUEST_MODE). See [docs/DEEP_CONTROL.md](DEEP_CONTROL.md) for the full list and runtime labels.

**If a demo fails with an “unknown feature” or syntax error:** pull the latest Core image (`docker pull ghcr.io/firebolt-db/firebolt-core:latest`) and restart the container, or check that your Cloud engine is on a recent release.

## Where version info appears in this repo

- **Manifest:** [docs/app-manifest.json](app-manifest.json) can include optional per-feature fields:
  - `minCoreVersion` – minimum Core version/tag (e.g. `"latest"` or a specific tag).
  - `versionNote` – short note (e.g. “Requires Firebolt with automated column statistics support”).
- **Feature READMEs:** `features/<feature_id>/README.md` may repeat or link to the version requirement.
- **This doc:** Single place to see all feature → Core/Cloud version requirements.

## Keeping this list updated

We use Firebolt’s official release notes as the source of truth for when features became available:

- **[Release notes (latest)](https://docs.firebolt.io/reference/release-notes)** – current version and recent changes
- **[Release notes archive](https://docs.firebolt.io/reference/release-notes/release-notes-archive)** – older versions (e.g. 4.29, 4.28, …)

**When to review:**

1. **When adding a new feature** – Before marking a feature “available,” check the release notes (and archive if needed) for the version that introduced it. If a minimum version is documented (e.g. “Introduced in 4.30”), add it to the table above and set `minCoreVersion` / `versionNote` in [app-manifest.json](app-manifest.json).
2. **When a new Firebolt version is released** – Skim the new release notes; if a capability we demo (or list as coming_soon) gets a documented version, update this table and any feature READMEs.
3. **When a user reports “feature not found” or syntax errors** – Confirm the table and manifest point to the correct minimum version; if the release notes show a different version, correct this doc.

We do not run automated checks against the release notes. Keeping the list accurate is a manual review step at feature-add time and when release notes are published.

## Contributors

When adding a feature that requires a specific Firebolt Core or Cloud version:

1. Check [release notes](https://docs.firebolt.io/reference/release-notes) and [release notes archive](https://docs.firebolt.io/reference/release-notes/release-notes-archive) for the version that introduced the capability.
2. Update the “Feature → version requirements” table above and, if needed, add `minCoreVersion` or `versionNote` to the feature in [app-manifest.json](app-manifest.json).
3. In the feature’s `features/<id>/README.md`, add a short “Version requirements” line and link here.
