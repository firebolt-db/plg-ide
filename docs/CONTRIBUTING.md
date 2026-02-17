# Contributing to plg-ide

When adding new verticals or features, follow the steps below so the IDE and Loveable app both see your changes. **Read `docs/PLAN_AND_GOVERNANCE.md` first** — it is the strict plan; new work must conform, not replace it.

---

## Adding a new vertical

1. Create `verticals/{name}/README.md` with use case overview.
2. Create `verticals/{name}/schema/01_tables.sql`.
3. Create `verticals/{name}/data/load.sql` (S3 COPY or sample generator) and/or `sample_data.py` for Core.
4. Add feature demos in `verticals/{name}/features/{feature_id}/` (e.g. 01_baseline.sql, 02_create_indexes.sql, 03_optimized.sql).
5. Create `verticals/{name}/demo_comparison.sql` following the pattern in PLAN_AND_GOVERNANCE §2.3 (impact first, per-step comments, demo_progress).
6. **Update `docs/app-manifest.json`** – add the new vertical with id, name, description, dataset, database, tables, rowCount, furtherReading, and features. The IDE and Loveable app use the manifest as the single source of truth.
7. Update `ROADMAP.md`.

**Checklist before merging:** Real Firebolt only? Confirm target before writes? Demo uses impact-first + comments + demo_progress? **app-manifest.json updated?**

---

## Adding a new feature (to an existing vertical)

1. Create or update `features/{name}/README.md` with feature explanation.
2. Create demo in `verticals/{vertical}/features/{name}/` with 01_baseline.sql, 02_*.sql, 03_optimized.sql (and benchmark.py if applicable).
3. If the feature has a before/after comparison, follow the demo script pattern in PLAN_AND_GOVERNANCE §2.3 (impact first, demo_progress).
4. **Update `docs/app-manifest.json`** – add the feature to the relevant vertical's `features` array (id, name, description, status: `available` or `coming_soon`). If it is cross-vertical, also add to `features_global`.
5. Update `ROADMAP.md`.

**Checklist before merging:** Same as above; **app-manifest.json updated** so IDE and Loveable both see the new feature.

---

## Single source of truth

- **Verticals and features list:** `docs/app-manifest.json` — IDE and Loveable both read this. Do not add a vertical or feature on disk without updating the manifest.
- **Demo behavior:** `docs/PLAN_AND_GOVERNANCE.md` — connectivity (no mock), confirm target before writes, impact-first demo pattern.

## Validate structure (optional)

From the repository root, run:

```bash
python3 scripts/validate_manifest_structure.py
```

This checks that every vertical in `docs/app-manifest.json` has the required files (`schema/01_tables.sql`, `demo_comparison.sql`) and that every feature with `status: "available"` has `01_baseline.sql` and `03_optimized.sql`. Exit code 1 if anything is missing. You can wire this into CI to keep the manifest and filesystem in sync.
