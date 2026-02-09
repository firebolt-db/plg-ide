"""
Aggregating Indexes Benchmark - Observability Vertical
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[4]))
from lib.firebolt import FireboltRunner, BenchmarkResult

QUERIES = {
    "Log Count by Service/Day": {
        "sql": """
            SELECT service_id, DATE_TRUNC('day', timestamp) AS day, level,
                   COUNT(*) AS log_count, AVG(duration_ms) AS avg_duration_ms
            FROM logs
            WHERE timestamp >= CURRENT_DATE - INTERVAL '30 days'
            GROUP BY service_id, DATE_TRUNC('day', timestamp), level
            ORDER BY day DESC, log_count DESC LIMIT 100
        """,
        "expected_improvement": "80X"
    },
    "Error Rate by Service": {
        "sql": """
            SELECT service_id,
                   COUNT(*) FILTER (WHERE level = 'ERROR') AS error_count,
                   COUNT(*) AS total_count
            FROM logs
            WHERE timestamp >= CURRENT_DATE - INTERVAL '7 days'
            GROUP BY service_id ORDER BY error_count DESC LIMIT 50
        """,
        "expected_improvement": "75X"
    },
}

CREATE_INDEXES_SQL = """
CREATE AGGREGATING INDEX IF NOT EXISTS logs_service_daily_agg
ON logs (service_id, DATE_TRUNC('day', timestamp), level, COUNT(*), COUNT(DISTINCT endpoint_id), AVG(duration_ms));
"""

DROP_INDEXES_SQL = """
DROP AGGREGATING INDEX IF EXISTS logs_service_daily_agg ON logs;
"""


def run_full_benchmark(runner, iterations=3):
    results = []
    print("=" * 70)
    print("AGGREGATING INDEXES BENCHMARK - OBSERVABILITY")
    print("=" * 70)
    try:
        runner.execute(DROP_INDEXES_SQL.strip())
    except Exception:
        pass
    baselines = {}
    for name, info in QUERIES.items():
        baselines[name] = runner.benchmark(info["sql"], iterations=iterations)
    for stmt in CREATE_INDEXES_SQL.strip().split(";"):
        if stmt.strip():
            runner.execute(stmt.strip())
    for name, info in QUERIES.items():
        opt = runner.benchmark(info["sql"], iterations=iterations)
        results.append(BenchmarkResult(name=name, baseline=baselines[name], optimized=opt))
    for r in results:
        r.print_comparison()
    return results


def main():
    import argparse
    p = argparse.ArgumentParser()
    p.add_argument("--iterations", type=int, default=3)
    p.add_argument("--keep-indexes", action="store_true")
    args = p.parse_args()
    runner = FireboltRunner()
    try:
        run_full_benchmark(runner, args.iterations)
        if not args.keep_indexes:
            try:
                runner.execute(DROP_INDEXES_SQL.strip())
            except Exception:
                pass
    finally:
        runner.close()


if __name__ == "__main__":
    main()
