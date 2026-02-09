"""
Aggregating Indexes Benchmark - Financial Vertical
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[4]))
from lib.firebolt import FireboltRunner, BenchmarkResult

QUERIES = {
    "Transaction Volume by Day": {
        "sql": """
            SELECT DATE_TRUNC('day', timestamp) AS day, transaction_type,
                   COUNT(*) AS tx_count, SUM(amount) AS total_volume, AVG(amount) AS avg_amount
            FROM transactions
            WHERE timestamp >= CURRENT_DATE - INTERVAL '30 days'
            GROUP BY DATE_TRUNC('day', timestamp), transaction_type
            ORDER BY day DESC, total_volume DESC LIMIT 100
        """,
        "expected_improvement": "80X"
    },
    "Merchant Performance": {
        "sql": """
            SELECT merchant_id, category, COUNT(*) AS tx_count,
                   SUM(amount) AS volume, AVG(risk_score) AS avg_risk_score
            FROM transactions
            WHERE timestamp >= CURRENT_DATE - INTERVAL '7 days'
            GROUP BY merchant_id, category ORDER BY volume DESC LIMIT 50
        """,
        "expected_improvement": "75X"
    },
}

CREATE_INDEXES_SQL = """
CREATE AGGREGATING INDEX IF NOT EXISTS transactions_daily_agg
ON transactions (DATE_TRUNC('day', timestamp), transaction_type, COUNT(*), SUM(amount), AVG(amount));

CREATE AGGREGATING INDEX IF NOT EXISTS transactions_merchant_agg
ON transactions (merchant_id, category, DATE_TRUNC('day', timestamp), COUNT(*), SUM(amount), AVG(risk_score));
"""

DROP_INDEXES_SQL = """
DROP AGGREGATING INDEX IF EXISTS transactions_daily_agg ON transactions;
DROP AGGREGATING INDEX IF EXISTS transactions_merchant_agg ON transactions;
"""


def run_full_benchmark(runner, iterations=3):
    results = []
    print("=" * 70)
    print("AGGREGATING INDEXES BENCHMARK - FINANCIAL")
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
