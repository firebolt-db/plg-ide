#!/usr/bin/env python3
"""
Validate the game-popularity-by-selected-car query against local Firebolt Core.

Creates database plg_validate, applies gaming schema, loads minimal data,
then runs the query to confirm it completes in reasonable time.

Usage:
  export FIREBOLT_RUNTIME=core FIREBOLT_DATABASE=plg_validate
  python3 verticals/gaming/scripts/validate_query_local.py

Requires: Firebolt Core running (e.g. http://localhost:3473).

Note: Firebolt Core does not support CREATE DIMENSION TABLE; this script
uses CREATE TABLE for all tables when applying the schema. On Cloud you
can use the full schema with dimension tables. If this query runs slowly
on Cloud with large playstats, consider an aggregating index on
(gameid, selectedcar) with the same aggregates (see features/aggregating_indexes).
"""

from __future__ import annotations

import os
import re
import sys
import time
from pathlib import Path

import httpx

# Repo root
REPO_ROOT = Path(__file__).resolve().parent.parent.parent.parent
CORE_HOST = os.getenv("FIREBOLT_CORE_HOST", "localhost")
CORE_PORT = os.getenv("FIREBOLT_CORE_PORT", "3473")
BASE_URL = f"http://{CORE_HOST}:{CORE_PORT}"
DB_NAME = "plg_validate"

# Small data sizes so the query finishes in seconds
NUM_PLAYERS = 500
NUM_GAMES = 20
NUM_TOURNAMENTS = 50
NUM_PLAYSTATS = 15_000

TARGET_QUERY = """
-- Game popularity by selected car (proxy for platform in Firebolt.io schema)
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


def execute_core(client: httpx.Client, sql: str, database: str | None = DB_NAME):
    """Execute one SQL statement on Firebolt Core. Returns (data, columns, time_ms)."""
    params = {"advanced_mode": "1"}
    if database:
        params["database"] = database
    start = time.perf_counter()
    r = client.post(
        BASE_URL,
        params=params,
        content=sql,
        headers={"Content-Type": "text/plain"},
    )
    r.raise_for_status()
    elapsed_ms = (time.perf_counter() - start) * 1000
    data = []
    columns = []
    if r.text.strip():
        lines = r.text.strip().split("\n")
        if lines:
            columns = lines[0].split("\t")
            # Firebolt Core may return a type line after header (e.g. "text null\tlong\t..."); skip it
            data_start = 1
            if len(lines) > 1:
                first_val = (lines[1].split("\t")[0].strip().lower() if lines[1].strip() else "") or ""
                if first_val in ("text", "int", "long", "double", "integer", "bigint", "real") or first_val.startswith("text "):
                    data_start = 2
            for line in lines[data_start:]:
                if line.strip():
                    values = line.split("\t")
                    data.append(dict(zip(columns, values)))
    return data, columns, elapsed_ms


def create_database_core():
    """Create database on Firebolt Core (one request, no database param)."""
    with httpx.Client(timeout=30.0) as client:
        r = client.post(
            BASE_URL,
            params={"advanced_mode": "1"},
            content="CREATE DATABASE IF NOT EXISTS " + DB_NAME,
            headers={"Content-Type": "text/plain"},
        )
        r.raise_for_status()
    print(f"Database '{DB_NAME}' ready.")


def split_sql_statements(sql: str):
    """Split SQL into single statements for Firebolt Core (one query per request)."""
    sql = re.sub(r"--[^\n]*", "", sql)
    statements = []
    for raw in re.split(r";\s*\n", sql):
        s = raw.strip()
        if s and not re.match(r"^\s*$", s):
            statements.append(s + ";")
    return statements


def run_schema(client: httpx.Client, schema_path: Path):
    """Apply schema by executing one statement at a time."""
    text = schema_path.read_text()
    # Firebolt Core does not support CREATE DIMENSION TABLE; use CREATE TABLE
    text = text.replace("CREATE DIMENSION TABLE", "CREATE TABLE")
    statements = split_sql_statements(text)
    for i, stmt in enumerate(statements):
        if stmt.strip().upper().startswith("SHOW TABLES"):
            continue
        try:
            execute_core(client, stmt)
        except httpx.HTTPStatusError as e:
            print(f"Schema statement #{i+1} failed: {e.response.text[:800]}")
            print("Statement (first 200 chars):", stmt[:200])
            raise
    print("Schema applied.")


def load_minimal_data(client: httpx.Client):
    """Insert minimal players, games, tournaments, playstats via generate_series."""
    print("Loading minimal data...")

    execute_core(client, f"""
INSERT INTO players (playerid, nickname, email, agecategory, platforms, registeredon, issubscribedtonewsletter, internalprobabilitytowin)
SELECT 
    seq AS playerid,
    'player_' || seq::TEXT AS nickname,
    'player_' || seq::TEXT || '@gaming.com' AS email,
    CASE seq % 4 WHEN 0 THEN 'junior' WHEN 1 THEN 'adult' WHEN 2 THEN 'senior' ELSE 'all' END AS agecategory,
    CASE seq % 3 WHEN 0 THEN ARRAY['pc'] WHEN 1 THEN ARRAY['console'] ELSE ARRAY['mobile'] END AS platforms,
    DATE '2023-01-01' + (seq % 365) AS registeredon,
    (seq % 2) = 0 AS issubscribedtonewsletter,
    (seq % 100) / 100.0 AS internalprobabilitytowin
FROM generate_series(1, {NUM_PLAYERS}) AS t(seq);
""")

    execute_core(client, f"""
INSERT INTO games (gameid, title, category, launchdate)
SELECT 
    seq AS gameid,
    'Game_' || seq::TEXT AS title,
    CASE seq % 5 WHEN 0 THEN 'Action' WHEN 1 THEN 'RPG' WHEN 2 THEN 'Strategy' WHEN 3 THEN 'Sports' ELSE 'Puzzle' END AS category,
    DATE '2020-01-01' + (seq * 30) AS launchdate
FROM generate_series(1, {NUM_GAMES}) AS t(seq);
""")

    execute_core(client, f"""
INSERT INTO tournaments (tournamentid, name, gameid, totalprizedollars, startdatetime, enddatetime)
SELECT 
    seq AS tournamentid,
    'Tournament_' || seq::TEXT AS name,
    (seq % {NUM_GAMES}) + 1 AS gameid,
    seq * 1000 AS totalprizedollars,
    TIMESTAMP '2024-01-01 00:00:00' + INTERVAL '1 day' * seq AS startdatetime,
    TIMESTAMP '2024-01-01 00:00:00' + INTERVAL '1 day' * seq + INTERVAL '7 days' AS enddatetime
FROM generate_series(1, {NUM_TOURNAMENTS}) AS t(seq);
""")

    execute_core(client, f"""
INSERT INTO playstats (gameid, playerid, stattime, selectedcar, currentlevel, currentspeed, currentplaytime, currentscore, event, errorcode, tournamentid)
SELECT 
    (seq % {NUM_GAMES}) + 1 AS gameid,
    (seq % {NUM_PLAYERS}) + 1 AS playerid,
    TIMESTAMP '2024-01-01 00:00:00' + INTERVAL '1 second' * seq AS stattime,
    'car_' || (seq % 10)::TEXT AS selectedcar,
    (seq % 100) + 1 AS currentlevel,
    (seq % 200) / 10.0 AS currentspeed,
    (seq % 3600) + 60 AS currentplaytime,
    (seq % 10000) + 100 AS currentscore,
    'play' AS event,
    NULL AS errorcode,
    (seq % {NUM_TOURNAMENTS}) + 1 AS tournamentid
FROM generate_series(1, {NUM_PLAYSTATS}) AS t(seq);
""")
    print(f"  players={NUM_PLAYERS}, games={NUM_GAMES}, tournaments={NUM_TOURNAMENTS}, playstats={NUM_PLAYSTATS}")


def main():
    print("=" * 60)
    print("Validate game-popularity-by-selected-car query (local Firebolt Core)")
    print("=" * 60)

    # 1) Check Core is up and create database (no database param)
    try:
        create_database_core()
    except httpx.ConnectError as e:
        print(f"ERROR: Cannot reach Firebolt Core at {BASE_URL}. Is it running?")
        print(f"  {e}")
        sys.exit(1)
    except httpx.HTTPStatusError as e:
        print(f"ERROR: Create database failed: {e.response.text}")
        sys.exit(1)

    schema_path = REPO_ROOT / "verticals" / "gaming" / "schema" / "01_tables.sql"
    if not schema_path.exists():
        print(f"ERROR: Schema not found: {schema_path}")
        sys.exit(1)

    with httpx.Client(timeout=300.0) as client:
        # 2) Apply schema (one statement per request)
        run_schema(client, schema_path)

        # 3) Load minimal data
        load_minimal_data(client)

        # 4) Run target query
        print("\nRunning target query...")
        data, columns, elapsed_ms = execute_core(client, TARGET_QUERY.strip())
        print(f"Query completed in {elapsed_ms:.0f} ms")
        print(f"Rows returned: {len(data)}")
        if data:
            try:
                from tabulate import tabulate
                print(tabulate(data, headers="keys", tablefmt="rounded_grid"))
            except ImportError:
                for row in data:
                    print(row)
        else:
            print("(No rows)")
    print("\nValidation OK: query runs successfully on local Firebolt Core.")


if __name__ == "__main__":
    main()
