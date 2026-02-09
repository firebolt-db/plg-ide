"""
Aggregating Indexes Benchmark - AdTech Vertical
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[4]))
from lib.firebolt import FireboltRunner, BenchmarkResult

QUERIES = {
    "Campaign by Day": {
        "sql": """
            SELECT campaign_id, DATE_TRUNC('day', timestamp) AS day,
                   COUNT(*) AS impressions, SUM(win_price) AS spend
            FROM impressions
            WHERE timestamp >= CURRENT_DATE - INTERVAL '30 days'
            GROUP BY campaign_id, DATE_TRUNC('day', timestamp)
            ORDER BY day DESC, impressions DESC LIMIT 100
        """,
        "expected_improvement": "80X"
    },
    "Publisher Performance": {
        "sql": """
            SELECT publisher_id, COUNT(*) AS impressions, SUM(win_price) AS revenue,
                   COUNT(DISTINCT campaign_id) AS campaigns_served
            FROM impressions
            WHERE timestamp >= CURRENT_DATE - INTERVAL '7 days'
            GROUP BY publisher_id ORDER BY revenue DESC LIMIT 50
        """,
        "expected_improvement": "70X"
    },
}

CREATE_INDEXES_SQL = """
CREATE AGGREGATING INDEX IF NOT EXISTS impressions_campaign_daily_agg
ON impressions (campaign_id, DATE_TRUNC('day', timestamp), COUNT(*), COUNT(DISTINCT user_id), SUM(win_price), AVG(win_price));

CREATE AGGREGATING INDEX IF NOT EXISTS impressions_publisher_agg
ON impressions (publisher_id, DATE_TRUNC('day', timestamp), COUNT(*), SUM(win_price), COUNT(DISTINCT campaign_id), COUNT(DISTINCT user_id));
"""

DROP_INDEXES_SQL = """
DROP AGGREGATING INDEX IF EXISTS impressions_campaign_daily_agg ON impressions;
DROP AGGREGATING INDEX IF EXISTS impressions_publisher_agg ON impressions;
"""


def run_full_benchmark(runner, iterations=3):
    results = []
    print("=" * 70)
    print("AGGREGATING INDEXES BENCHMARK - ADTECH")
    print("=" * 70)
    for stmt in DROP_INDEXES_SQL.strip().split(";"):
        if stmt.strip():
            try:
                runner.execute(stmt.strip())
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
            for stmt in DROP_INDEXES_SQL.strip().split(";"):
                if stmt.strip():
                    try:
                        runner.execute(stmt.strip())
                    except Exception:
                        pass
    finally:
        runner.close()


if __name__ == "__main__":
    main()
