#!/usr/bin/env python3
"""Run the game-popularity query once and print time + results."""
import os
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent.parent.parent))
import httpx

BASE = os.getenv("FIREBOLT_CORE_URL", "http://localhost:3473")
DB = os.getenv("FIREBOLT_DATABASE", "plg_validate")

SQL = """
SELECT 
    g.title,
    g.category,
    ps.selectedcar,
    COUNT(DISTINCT ps.playerid) AS unique_players,
    SUM(ps.currentplaytime) / 3600.0 AS total_hours,
    AVG(ps.currentscore) AS avg_score
FROM playstats ps
JOIN games g ON ps.gameid = g.gameid
GROUP BY g.gameid, g.title, g.category, ps.selectedcar
ORDER BY unique_players DESC
LIMIT 20;
"""

def main():
    start = time.perf_counter()
    r = httpx.post(
        BASE,
        params={"database": DB, "advanced_mode": "1"},
        content=SQL.strip(),
        headers={"Content-Type": "text/plain"},
        timeout=60.0,
    )
    elapsed_ms = (time.perf_counter() - start) * 1000
    r.raise_for_status()
    lines = r.text.strip().split("\n")
    if not lines:
        print("No output")
        return
    cols = lines[0].split("\t")
    data_start = 2 if len(lines) > 1 and lines[1].split("\t")[0].strip().lower().startswith("text") else 1
    rows = [lines[i].split("\t") for i in range(data_start, len(lines)) if lines[i].strip()]
    print(f"Time: {elapsed_ms:.0f} ms")
    print(f"Rows: {len(rows)}")
    print()
    try:
        from tabulate import tabulate
        data = [dict(zip(cols, r)) for r in rows]
        print(tabulate(data, headers="keys", tablefmt="rounded_grid"))
    except ImportError:
        print("\t".join(cols))
        for row in rows:
            print("\t".join(row))

if __name__ == "__main__":
    main()
