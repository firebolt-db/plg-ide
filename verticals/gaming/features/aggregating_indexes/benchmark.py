"""
Aggregating Indexes Benchmark

Demonstrates the performance improvement from aggregating indexes
by running the same queries before and after index creation.
"""

import sys
from pathlib import Path

# Add lib to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent.parent.parent))

from lib.firebolt import FireboltRunner, BenchmarkResult


# Benchmark queries
QUERIES = {
    "Tournament Leaderboard": {
        "description": "Top players in a tournament by score",
        "sql": """
            SELECT 
                playerid,
                AVG(currentscore) as avg_score,
                SUM(currentplaytime) as total_time,
                MAX(currentlevel) as max_level,
                COUNT(*) as events
            FROM playstats
            WHERE tournamentid = 1 AND gameid = 1
            GROUP BY playerid
            ORDER BY avg_score DESC
            LIMIT 100
        """,
        "expected_improvement": "80X"
    },
    "Daily Active Users": {
        "description": "DAU metrics for the last 30 days",
        "sql": """
            SELECT 
                DATE_TRUNC('day', stattime) as day,
                gameid,
                COUNT(DISTINCT playerid) as dau,
                SUM(currentplaytime) as total_play_time,
                COUNT(*) as total_events
            FROM playstats
            WHERE stattime >= CURRENT_DATE - INTERVAL '30 days'
            GROUP BY 1, 2
            ORDER BY day DESC, dau DESC
            LIMIT 50
        """,
        "expected_improvement": "74X"
    },
    "Player Profile": {
        "description": "Player's performance across all games",
        "sql": """
            SELECT 
                gameid,
                AVG(currentscore) as avg_score,
                SUM(currentplaytime) as total_time,
                MAX(currentlevel) as max_level,
                COUNT(*) as total_sessions
            FROM playstats
            WHERE playerid = 42
            GROUP BY gameid
            ORDER BY total_time DESC
        """,
        "expected_improvement": "43X"
    },
    "Tournament Overview": {
        "description": "Aggregate stats per tournament",
        "sql": """
            SELECT 
                tournamentid,
                gameid,
                COUNT(DISTINCT playerid) as unique_players,
                AVG(currentscore) as avg_score,
                MAX(currentscore) as high_score,
                SUM(currentplaytime) as total_play_time,
                COUNT(*) as total_events
            FROM playstats
            GROUP BY tournamentid, gameid
            ORDER BY total_events DESC
            LIMIT 50
        """,
        "expected_improvement": "50X"
    }
}

# Index creation SQL
CREATE_INDEXES_SQL = """
-- Leaderboard index
CREATE AGGREGATING INDEX IF NOT EXISTS playstats_leaderboard_agg
ON playstats (
    tournamentid, gameid, playerid,
    AVG(currentscore), SUM(currentplaytime), MAX(currentlevel), COUNT(*)
);

-- Daily metrics index
CREATE AGGREGATING INDEX IF NOT EXISTS playstats_daily_agg
ON playstats (
    gameid, DATE_TRUNC('day', stattime),
    SUM(currentplaytime), AVG(currentscore), COUNT(DISTINCT playerid), COUNT(*)
);

-- Player stats index
CREATE AGGREGATING INDEX IF NOT EXISTS playstats_player_agg
ON playstats (
    playerid, gameid,
    AVG(currentscore), SUM(currentplaytime), MAX(currentlevel),
    MIN(stattime), MAX(stattime), COUNT(*)
);

-- Tournament overview index
CREATE AGGREGATING INDEX IF NOT EXISTS playstats_tournament_agg
ON playstats (
    tournamentid, gameid,
    AVG(currentscore), MAX(currentscore), SUM(currentplaytime),
    COUNT(DISTINCT playerid), COUNT(*)
);
"""

# Index cleanup SQL
DROP_INDEXES_SQL = """
DROP AGGREGATING INDEX IF EXISTS playstats_leaderboard_agg ON playstats;
DROP AGGREGATING INDEX IF EXISTS playstats_daily_agg ON playstats;
DROP AGGREGATING INDEX IF EXISTS playstats_player_agg ON playstats;
DROP AGGREGATING INDEX IF EXISTS playstats_tournament_agg ON playstats;
"""


def run_full_benchmark(runner: FireboltRunner, iterations: int = 3):
    """Run the complete benchmark suite."""
    results = []
    
    print("=" * 70)
    print("AGGREGATING INDEXES BENCHMARK")
    print("Proving the value of pre-computed aggregations")
    print("=" * 70)
    
    # Step 1: Ensure no indexes exist (clean baseline)
    print("\n[1/4] Preparing clean baseline (dropping any existing indexes)...")
    try:
        runner.execute(DROP_INDEXES_SQL)
    except:
        pass  # Indexes may not exist
    
    # Step 2: Run baseline queries
    print("\n[2/4] Running BASELINE queries (without aggregating indexes)...")
    baselines = {}
    for name, query_info in QUERIES.items():
        print(f"  - {name}...")
        baselines[name] = runner.benchmark(query_info["sql"], iterations=iterations)
    
    # Step 3: Create indexes
    print("\n[3/4] Creating aggregating indexes...")
    runner.execute(CREATE_INDEXES_SQL)
    print("  Indexes created successfully")
    
    # Step 4: Run optimized queries
    print("\n[4/4] Running OPTIMIZED queries (with aggregating indexes)...")
    for name, query_info in QUERIES.items():
        print(f"  - {name}...")
        optimized = runner.benchmark(query_info["sql"], iterations=iterations)
        
        result = BenchmarkResult(
            name=name,
            baseline=baselines[name],
            optimized=optimized
        )
        results.append(result)
    
    # Print results
    print("\n" + "=" * 70)
    print("RESULTS")
    print("=" * 70)
    
    for result in results:
        result.print_comparison()
    
    # Summary
    print("=" * 70)
    print("SUMMARY")
    print("=" * 70)
    
    total_baseline_time = sum(r.baseline.execution_time_ms for r in results)
    total_optimized_time = sum(r.optimized.execution_time_ms for r in results)
    
    print(f"\nTotal query time WITHOUT indexes: {total_baseline_time:.0f}ms")
    print(f"Total query time WITH indexes:    {total_optimized_time:.0f}ms")
    print(f"Overall improvement:              {total_baseline_time/total_optimized_time:.0f}X faster")
    
    print("\n" + "-" * 70)
    print("KEY TAKEAWAYS:")
    print("-" * 70)
    print("1. Aggregating indexes pre-compute aggregations at write time")
    print("2. Queries read small index instead of scanning full table")
    print("3. Ideal for dashboards, APIs, and repeated analytics patterns")
    print("4. Trade-off: Slightly slower writes for much faster reads")
    print("-" * 70)
    
    return results


def run_single_query_demo(runner: FireboltRunner, query_name: str):
    """Run a demo for a single query."""
    if query_name not in QUERIES:
        print(f"Unknown query: {query_name}")
        print(f"Available: {', '.join(QUERIES.keys())}")
        return
    
    query_info = QUERIES[query_name]
    
    print(f"\n{'='*60}")
    print(f"Demo: {query_name}")
    print(f"{'='*60}")
    print(f"\nDescription: {query_info['description']}")
    print(f"Expected improvement: {query_info['expected_improvement']}")
    
    # Run comparison
    result = runner.run_benchmark_comparison(
        name=query_name,
        baseline_sql=query_info["sql"],
        optimized_sql=query_info["sql"],  # Same query, index makes it fast
        setup_sql=CREATE_INDEXES_SQL,
        teardown_sql=DROP_INDEXES_SQL,
        iterations=3
    )
    
    return result


def main():
    """Main entry point."""
    import argparse
    
    parser = argparse.ArgumentParser(
        description="Aggregating Indexes Benchmark",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python benchmark.py                    # Run full benchmark
  python benchmark.py --query "Tournament Leaderboard"  # Single query
  python benchmark.py --iterations 5     # More iterations for accuracy
        """
    )
    parser.add_argument(
        "--query", 
        help="Run benchmark for a specific query only",
        choices=list(QUERIES.keys())
    )
    parser.add_argument(
        "--iterations",
        type=int,
        default=3,
        help="Number of iterations per query (default: 3)"
    )
    parser.add_argument(
        "--keep-indexes",
        action="store_true",
        help="Don't drop indexes after benchmark"
    )
    
    args = parser.parse_args()
    
    # Initialize runner
    runner = FireboltRunner()
    
    try:
        if args.query:
            run_single_query_demo(runner, args.query)
        else:
            run_full_benchmark(runner, iterations=args.iterations)
            
            if not args.keep_indexes:
                print("\nCleaning up (dropping indexes)...")
                print("Use --keep-indexes to preserve them")
                try:
                    runner.execute(DROP_INDEXES_SQL)
                except:
                    pass
    finally:
        runner.close()


if __name__ == "__main__":
    main()
