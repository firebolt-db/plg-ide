#!/usr/bin/env python3
"""
Validate that the repository structure matches docs/app-manifest.json.

For each vertical in the manifest:
  - verticals/{id}/schema/01_tables.sql must exist
  - verticals/{id}/demo_comparison.sql must exist
  Exception: vertical "iceberg_demo" has no verticals/ folder; its demo lives under features/iceberg/.

For each feature with status "available" in that vertical:
  - verticals/{id}/features/{feature_id}/01_baseline.sql and 03_optimized.sql must exist
  Exception: feature "iceberg" under vertical "iceberg_demo" uses features/iceberg/01_create_locations_tpch.sql (and 02_create_view.sql); 03_optimized.sql is not required.

Features with status "coming_soon" are skipped.

Exit code: 0 if all checks pass, 1 if any required file is missing.
Run from repository root: python scripts/validate_manifest_structure.py
"""

import json
import sys
from pathlib import Path


def repo_root() -> Path:
    root = Path(__file__).resolve().parent.parent
    return root


def main() -> int:
    root = repo_root()
    manifest_path = root / "docs" / "app-manifest.json"

    if not manifest_path.exists():
        print(f"Error: {manifest_path} not found. Run from repository root.", file=sys.stderr)
        return 1

    with open(manifest_path, encoding="utf-8") as f:
        manifest = json.load(f)

    errors: list[str] = []

    for vertical in manifest.get("verticals", []):
        v_id = vertical["id"]
        v_path = root / "verticals" / v_id
        # Iceberg demo lives under features/iceberg/ (no verticals/iceberg_demo/schema)
        feature_base = root / "features" if v_id == "iceberg_demo" else v_path / "features"

        if v_id != "iceberg_demo":
            # Required for every vertical (except iceberg_demo)
            schema_sql = v_path / "schema" / "01_tables.sql"
            demo_comparison = v_path / "demo_comparison.sql"
            if not schema_sql.is_file():
                errors.append(f"Vertical '{v_id}': missing {schema_sql.relative_to(root)}")
            if not demo_comparison.is_file():
                errors.append(f"Vertical '{v_id}': missing {demo_comparison.relative_to(root)}")

        # For each feature with status "available"
        for feature in vertical.get("features", []):
            if feature.get("status") != "available":
                continue
            f_id = feature["id"]
            feat_path = feature_base / f_id
            baseline = feat_path / "01_baseline.sql"
            optimized = feat_path / "03_optimized.sql"
            # Iceberg uses 01_create_locations_*, 02_create_view.sql; allow either pattern
            if v_id == "iceberg_demo" and f_id == "iceberg":
                if not (feat_path / "01_create_locations_tpch.sql").is_file() and not baseline.is_file():
                    errors.append(f"Vertical '{v_id}', feature '{f_id}': missing features/iceberg/01_create_locations_tpch.sql or 01_baseline.sql")
            else:
                if not baseline.is_file():
                    errors.append(f"Vertical '{v_id}', feature '{f_id}': missing {baseline.relative_to(root)}")
                if not optimized.is_file():
                    errors.append(f"Vertical '{v_id}', feature '{f_id}': missing {optimized.relative_to(root)}")

    if errors:
        print("Structure validation failed. Missing required files:", file=sys.stderr)
        for e in errors:
            print(f"  - {e}", file=sys.stderr)
        return 1

    print("OK: Manifest structure matches repository (all required files present).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
