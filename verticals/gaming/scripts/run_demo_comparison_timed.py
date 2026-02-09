#!/usr/bin/env python3
"""Run demo_comparison.sql statement-by-statement and print time for each."""
from __future__ import annotations

import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent.parent.parent
sys.path.insert(0, str(REPO_ROOT))

from lib.firebolt import FireboltRunner


def split_statements(sql: str) -> list[tuple[str, str]]:
    """Split SQL into (label, statement) list. Label = first meaningful line."""
    out = []
    # Remove single-line -- comments for splitting; keep blocks
    blocks = re.split(r";\s*\n", sql)
    for raw in blocks:
        stmt = raw.strip()
        if not stmt or re.match(r"^\s*$", stmt):
            continue
        stmt = stmt + ";"
        # Label: first line that isn't only comment or blank
        lines = stmt.split("\n")
        label = ""
        for line in lines:
            s = line.strip()
            if s and not s.startswith("--"):
                label = s[:70] + ("..." if len(s) > 70 else "")
                break
            if s.startswith("--") and ("BEFORE" in s or "AFTER" in s or "SELECT" in s or "COMPARISON" in s):
                label = s.replace("--", "").strip()[:70]
                break
        if not label:
            label = lines[0][:70] if lines else "?"
        out.append((label, stmt))
    return out


def main():
    demo_path = REPO_ROOT / "verticals" / "gaming" / "demo_comparison.sql"
    if not demo_path.exists():
        print(f"Not found: {demo_path}")
        sys.exit(1)
    sql = demo_path.read_text()
    statements = split_statements(sql)
    runner = FireboltRunner(runtime="cloud")
    print("Running demo_comparison.sql on Firebolt Cloud (each statement timed):\n")
    times_ms: list[tuple[str, float]] = []
    for i, (label, stmt) in enumerate(statements):
        try:
            r = runner.execute(stmt, disable_cache=True)
            t = r.execution_time_ms
            times_ms.append((label, t))
            print(f"  [{i+1}] {t:>10,.0f} ms  {label}")
        except Exception as e:
            print(f"  [{i+1}]    ERROR  {label}")
            print(f"         {e}")
    runner.close()
    print("\n--- Summary (query times in ms) ---")
    for label, t in times_ms:
        print(f"  {t:>10,.0f}  {label[:60]}")


if __name__ == "__main__":
    main()
