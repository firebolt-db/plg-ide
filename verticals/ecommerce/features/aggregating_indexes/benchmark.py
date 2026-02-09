"""
Aggregating Indexes Benchmark - E-commerce Vertical

Demonstrates the performance improvement from aggregating indexes
by running the same queries before and after index creation.
"""

import sys
from pathlib import Path

# Add repo root to path
sys.path.insert(0, str(Path(__file__).resolve().parents[4]))

from lib.firebolt import FireboltRunner, BenchmarkResult


QUERIES = {
    "Product Sales by Category": {
        "description": "Sales by category and brand, last 30 days",
        "sql": """
            SELECT 
                p.category_id,
                p.brand,
                SUM(oi.quantity) AS total_quantity_sold,
                SUM(oi.subtotal) AS total_revenue,
                COUNT(DISTINCT oi.order_id) AS order_count,
                AVG(oi.unit_price) AS avg_price
            FROM order_items oi
            JOIN products p ON oi.product_id = p.product_id
            WHERE oi.created_at >= CURRENT_DATE - INTERVAL '30 days'
            GROUP BY p.category_id, p.brand
            ORDER BY total_revenue DESC
            LIMIT 50
        """,
        "expected_improvement": "80X"
    },
    "Daily Revenue Trends": {
        "description": "Daily revenue for last 90 days",
        "sql": """
            SELECT 
                DATE_TRUNC('day', oi.created_at) AS day,
                COUNT(DISTINCT oi.order_id) AS order_count,
                SUM(oi.subtotal) AS total_revenue,
                AVG(oi.subtotal) AS avg_order_value
            FROM order_items oi
            WHERE oi.created_at >= CURRENT_DATE - INTERVAL '90 days'
            GROUP BY DATE_TRUNC('day', oi.created_at)
            ORDER BY day DESC
            LIMIT 90
        """,
        "expected_improvement": "90X"
    },
    "Top Products by Revenue": {
        "description": "Top 20 products by revenue, last 7 days",
        "sql": """
            SELECT 
                oi.product_id,
                SUM(oi.quantity) AS total_quantity_sold,
                SUM(oi.subtotal) AS total_revenue,
                COUNT(DISTINCT oi.order_id) AS order_count
            FROM order_items oi
            WHERE oi.created_at >= CURRENT_DATE - INTERVAL '7 days'
            GROUP BY oi.product_id
            ORDER BY total_revenue DESC
            LIMIT 20
        """,
        "expected_improvement": "70X"
    },
    "Brand Performance": {
        "description": "Revenue by brand, last 7 days",
        "sql": """
            SELECT 
                p.brand,
                COUNT(DISTINCT p.product_id) AS product_count,
                SUM(oi.quantity) AS total_quantity_sold,
                SUM(oi.subtotal) AS total_revenue
            FROM order_items oi
            JOIN products p ON oi.product_id = p.product_id
            WHERE oi.created_at >= CURRENT_DATE - INTERVAL '7 days'
            GROUP BY p.brand
            ORDER BY total_revenue DESC
            LIMIT 20
        """,
        "expected_improvement": "70X"
    }
}

CREATE_INDEXES_SQL = """
CREATE AGGREGATING INDEX IF NOT EXISTS order_items_product_sales_agg
ON order_items (
    product_id,
    DATE_TRUNC('day', created_at),
    SUM(quantity),
    SUM(subtotal),
    COUNT(DISTINCT order_id),
    AVG(unit_price),
    COUNT(*)
);

CREATE AGGREGATING INDEX IF NOT EXISTS order_items_daily_agg
ON order_items (
    DATE_TRUNC('day', created_at),
    SUM(subtotal),
    SUM(quantity),
    COUNT(DISTINCT order_id),
    COUNT(DISTINCT product_id),
    AVG(subtotal),
    COUNT(*)
);

CREATE AGGREGATING INDEX IF NOT EXISTS order_items_order_agg
ON order_items (
    order_id,
    SUM(subtotal),
    SUM(quantity),
    COUNT(DISTINCT product_id),
    COUNT(*)
);
"""

DROP_INDEXES_SQL = """
DROP AGGREGATING INDEX IF EXISTS order_items_product_sales_agg ON order_items;
DROP AGGREGATING INDEX IF EXISTS order_items_daily_agg ON order_items;
DROP AGGREGATING INDEX IF EXISTS order_items_order_agg ON order_items;
"""


def run_full_benchmark(runner: FireboltRunner, iterations: int = 3):
    """Run the complete benchmark suite."""
    results = []

    print("=" * 70)
    print("AGGREGATING INDEXES BENCHMARK - E-COMMERCE")
    print("Proving the value of pre-computed aggregations for retail analytics")
    print("=" * 70)

    print("\n[1/4] Preparing clean baseline (dropping any existing indexes)...")
    for stmt in DROP_INDEXES_SQL.strip().split(";"):
        stmt = stmt.strip()
        if stmt:
            try:
                runner.execute(stmt)
            except Exception:
                pass

    print("\n[2/4] Running BASELINE queries (without aggregating indexes)...")
    baselines = {}
    for name, query_info in QUERIES.items():
        print(f"  - {name}...")
        baselines[name] = runner.benchmark(query_info["sql"], iterations=iterations)

    print("\n[3/4] Creating aggregating indexes...")
    for stmt in CREATE_INDEXES_SQL.strip().split(";"):
        stmt = stmt.strip()
        if stmt:
            runner.execute(stmt)
    print("  Indexes created successfully")

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

    print("\n" + "=" * 70)
    print("RESULTS")
    print("=" * 70)

    for result in results:
        result.print_comparison()

    total_baseline_time = sum(r.baseline.execution_time_ms for r in results)
    total_optimized_time = sum(r.optimized.execution_time_ms for r in results)
    print("\n" + "=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print(f"\nTotal query time WITHOUT indexes: {total_baseline_time:.0f}ms")
    print(f"Total query time WITH indexes:    {total_optimized_time:.0f}ms")
    if total_optimized_time > 0:
        print(f"Overall improvement:              {total_baseline_time/total_optimized_time:.0f}X faster")
    print("\nKEY TAKEAWAYS: Real-time dashboards, 99% less data scanned, no code changes.")
    print("=" * 70)

    return results


def main():
    import argparse

    parser = argparse.ArgumentParser(description="E-commerce Aggregating Indexes Benchmark")
    parser.add_argument("--query", choices=list(QUERIES.keys()), help="Run single query only")
    parser.add_argument("--iterations", type=int, default=3, help="Iterations per query")
    parser.add_argument("--keep-indexes", action="store_true", help="Don't drop indexes after")
    args = parser.parse_args()

    runner = FireboltRunner()

    try:
        if args.query:
            query_info = QUERIES[args.query]
            print(f"\nDemo: {args.query}")
            print(f"Expected improvement: {query_info['expected_improvement']}\n")
            for stmt in DROP_INDEXES_SQL.strip().split(";"):
                if stmt.strip():
                    try:
                        runner.execute(stmt.strip())
                    except Exception:
                        pass
            baseline = runner.benchmark(query_info["sql"], iterations=args.iterations)
            for stmt in CREATE_INDEXES_SQL.strip().split(";"):
                if stmt.strip():
                    runner.execute(stmt.strip())
            optimized = runner.benchmark(query_info["sql"], iterations=args.iterations)
            BenchmarkResult(name=args.query, baseline=baseline, optimized=optimized).print_comparison()
        else:
            run_full_benchmark(runner, iterations=args.iterations)
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
