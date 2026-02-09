"""
Firebolt Runtime Abstraction Layer

Provides a unified interface for both Firebolt Cloud and Firebolt Core,
with benchmarking capabilities for feature demonstrations.
"""

from __future__ import annotations

import os
import time
import json
from dataclasses import dataclass, field
from typing import Literal, Optional, Any
from pathlib import Path

import httpx
from dotenv import load_dotenv
from tabulate import tabulate


@dataclass
class QueryResult:
    """Result from a single query execution."""
    data: list[dict]
    row_count: int
    columns: list[str]
    execution_time_ms: float
    rows_scanned: Optional[int] = None
    bytes_read: Optional[int] = None
    
    def __repr__(self):
        return f"QueryResult(rows={self.row_count}, time={self.execution_time_ms:.1f}ms)"


@dataclass
class BenchmarkResult:
    """Result from a benchmark comparison."""
    name: str
    baseline: QueryResult
    optimized: QueryResult
    
    @property
    def time_improvement(self) -> float:
        """Calculate time improvement factor."""
        if self.optimized.execution_time_ms == 0:
            return float('inf')
        return self.baseline.execution_time_ms / self.optimized.execution_time_ms
    
    @property
    def time_savings_pct(self) -> float:
        """Calculate time savings percentage."""
        if self.baseline.execution_time_ms == 0:
            return 0
        return (1 - self.optimized.execution_time_ms / self.baseline.execution_time_ms) * 100
    
    @property
    def rows_savings_pct(self) -> float:
        """Calculate rows scanned savings percentage."""
        if not self.baseline.rows_scanned or not self.optimized.rows_scanned:
            return 0
        return (1 - self.optimized.rows_scanned / self.baseline.rows_scanned) * 100
    
    @property
    def bytes_savings_pct(self) -> float:
        """Calculate bytes read savings percentage."""
        if not self.baseline.bytes_read or not self.optimized.bytes_read:
            return 0
        return (1 - self.optimized.bytes_read / self.baseline.bytes_read) * 100
    
    def print_comparison(self):
        """Print a formatted comparison table."""
        def format_bytes(b: Optional[int]) -> str:
            if b is None:
                return "N/A"
            if b >= 1_000_000_000:
                return f"{b / 1_000_000_000:.2f} GB"
            if b >= 1_000_000:
                return f"{b / 1_000_000:.2f} MB"
            if b >= 1_000:
                return f"{b / 1_000:.2f} KB"
            return f"{b} B"
        
        def format_rows(r: Optional[int]) -> str:
            if r is None:
                return "N/A"
            if r >= 1_000_000:
                return f"{r / 1_000_000:.1f}M"
            if r >= 1_000:
                return f"{r / 1_000:.1f}K"
            return str(r)
        
        print(f"\n{'='*60}")
        print(f"Feature Benchmark: {self.name}")
        print(f"{'='*60}\n")
        
        table_data = [
            ["Query Time", 
             f"{self.baseline.execution_time_ms:.0f} ms", 
             f"{self.optimized.execution_time_ms:.0f} ms",
             f"{self.time_savings_pct:.1f}%"],
            ["Rows Scanned", 
             format_rows(self.baseline.rows_scanned), 
             format_rows(self.optimized.rows_scanned),
             f"{self.rows_savings_pct:.1f}%"],
            ["Bytes Read", 
             format_bytes(self.baseline.bytes_read), 
             format_bytes(self.optimized.bytes_read),
             f"{self.bytes_savings_pct:.1f}%"],
        ]
        
        print(tabulate(
            table_data,
            headers=["Metric", "Without", "With", "Savings"],
            tablefmt="rounded_grid"
        ))
        
        print(f"\nImprovement: {self.time_improvement:.0f}X faster\n")


class FireboltRunner:
    """
    Unified interface for Firebolt Cloud and Firebolt Core.
    
    Auto-detects runtime based on environment configuration.
    """
    
    def __init__(self, runtime: Literal["cloud", "core", "auto"] = "auto"):
        """
        Initialize the Firebolt runner.
        
        Args:
            runtime: Which runtime to use. "auto" will detect based on env.
        """
        # Load environment variables
        load_dotenv()
        
        self.runtime = self._detect_runtime(runtime)
        self._connection = None
        self._core_client = None
        
        print(f"Firebolt Runner initialized: {self.runtime}")
    
    def _detect_runtime(self, requested: str) -> str:
        """Detect which runtime to use."""
        if requested != "auto":
            return requested
        
        env_runtime = os.getenv("FIREBOLT_RUNTIME", "").lower()
        if env_runtime in ("cloud", "core"):
            return env_runtime
        
        # Try to detect Core availability
        core_host = os.getenv("FIREBOLT_CORE_HOST", "localhost")
        core_port = os.getenv("FIREBOLT_CORE_PORT", "3473")
        
        try:
            response = httpx.get(
                f"http://{core_host}:{core_port}/",
                timeout=2.0
            )
            if response.status_code == 200:
                return "core"
        except:
            pass
        
        # Check for Cloud credentials
        if os.getenv("FIREBOLT_CLIENT_ID") and os.getenv("FIREBOLT_CLIENT_SECRET"):
            return "cloud"
        
        # Default to core
        return "core"
    
    def _get_core_client(self) -> httpx.Client:
        """Get or create Core HTTP client."""
        if self._core_client is None:
            host = os.getenv("FIREBOLT_CORE_HOST", "localhost")
            port = os.getenv("FIREBOLT_CORE_PORT", "3473")
            database = os.getenv("FIREBOLT_DATABASE", "plg_demo")
            
            # Build query parameters for advanced mode
            params = {
                "database": database,
                "advanced_mode": "1"
            }
            
            base_url = f"http://{host}:{port}"
            self._core_client = httpx.Client(base_url=base_url, timeout=300.0)
            self._core_params = params
        
        return self._core_client
    
    def _get_cloud_connection(self):
        """Get or create Cloud SDK connection."""
        if self._connection is None:
            try:
                from firebolt.db import connect
                from firebolt.client.auth import ClientCredentials
                
                client_id = os.getenv("FIREBOLT_CLIENT_ID")
                client_secret = os.getenv("FIREBOLT_CLIENT_SECRET")
                account = os.getenv("FIREBOLT_ACCOUNT")
                database = os.getenv("FIREBOLT_DATABASE", "plg_demo")
                engine = os.getenv("FIREBOLT_ENGINE")
                api_endpoint = os.getenv("FIREBOLT_API_ENDPOINT", "api.app.firebolt.io")
                
                self._connection = connect(
                    auth=ClientCredentials(client_id, client_secret),
                    account_name=account,
                    database=database,
                    engine_name=engine,
                    api_endpoint=api_endpoint
                )
            except ImportError:
                raise RuntimeError(
                    "firebolt-sdk not installed. Run: pip install firebolt-sdk"
                )
            except Exception as e:
                raise RuntimeError(f"Failed to connect to Firebolt Cloud: {e}")
        
        return self._connection
    
    def execute(self, sql: str, disable_cache: bool = False) -> QueryResult:
        """
        Execute a SQL statement.
        
        Args:
            sql: SQL statement to execute
            disable_cache: If True, disable result caching for accurate benchmarks
            
        Returns:
            QueryResult with data and metrics
        """
        if self.runtime == "core":
            return self._execute_core(sql, disable_cache)
        else:
            return self._execute_cloud(sql, disable_cache)
    
    def _execute_core(self, sql: str, disable_cache: bool = False) -> QueryResult:
        """Execute SQL on Firebolt Core."""
        client = self._get_core_client()
        
        # Optionally disable cache
        if disable_cache:
            sql = f"SET enable_result_cache = FALSE;\n{sql}"
        
        start_time = time.perf_counter()
        
        try:
            response = client.post(
                "/",
                params=self._core_params,
                content=sql,
                headers={"Content-Type": "text/plain"}
            )
            response.raise_for_status()
            
            execution_time_ms = (time.perf_counter() - start_time) * 1000
            
            # Parse response
            result_data = []
            columns = []
            rows_scanned = None
            bytes_read = None
            
            if response.text.strip():
                lines = response.text.strip().split('\n')
                if lines:
                    # First line is headers
                    columns = lines[0].split('\t')
                    # Remaining lines are data
                    for line in lines[1:]:
                        if line.strip():
                            values = line.split('\t')
                            result_data.append(dict(zip(columns, values)))
            
            return QueryResult(
                data=result_data,
                row_count=len(result_data),
                columns=columns,
                execution_time_ms=execution_time_ms,
                rows_scanned=rows_scanned,
                bytes_read=bytes_read
            )
            
        except httpx.HTTPStatusError as e:
            raise RuntimeError(f"Query failed: {e.response.text}")
        except Exception as e:
            raise RuntimeError(f"Query execution error: {e}")
    
    def _execute_cloud(self, sql: str, disable_cache: bool = False) -> QueryResult:
        """Execute SQL on Firebolt Cloud."""
        connection = self._get_cloud_connection()
        cursor = connection.cursor()
        
        # Optionally disable cache
        if disable_cache:
            cursor.execute("SET enable_result_cache = FALSE")
        
        start_time = time.perf_counter()
        cursor.execute(sql)
        execution_time_ms = (time.perf_counter() - start_time) * 1000
        
        # Fetch results
        columns = [desc[0] for desc in cursor.description] if cursor.description else []
        rows = cursor.fetchall()
        
        result_data = [dict(zip(columns, row)) for row in rows]
        
        return QueryResult(
            data=result_data,
            row_count=len(result_data),
            columns=columns,
            execution_time_ms=execution_time_ms,
            rows_scanned=None,  # Cloud SDK doesn't expose this easily
            bytes_read=None
        )
    
    def execute_file(self, filepath: str | Path) -> QueryResult:
        """Execute SQL from a file."""
        path = Path(filepath)
        if not path.exists():
            raise FileNotFoundError(f"SQL file not found: {filepath}")
        
        sql = path.read_text()
        return self.execute(sql)
    
    def benchmark(
        self, 
        sql: str, 
        iterations: int = 3,
        warmup: int = 1
    ) -> QueryResult:
        """
        Benchmark a query with multiple iterations.
        
        Args:
            sql: SQL query to benchmark
            iterations: Number of iterations to average
            warmup: Number of warmup runs (not counted)
            
        Returns:
            QueryResult with averaged execution time
        """
        # Warmup runs
        for _ in range(warmup):
            self.execute(sql, disable_cache=True)
        
        # Timed runs
        total_time = 0
        last_result = None
        
        for _ in range(iterations):
            result = self.execute(sql, disable_cache=True)
            total_time += result.execution_time_ms
            last_result = result
        
        # Return result with averaged time
        if last_result:
            last_result.execution_time_ms = total_time / iterations
        
        return last_result
    
    def run_benchmark_comparison(
        self,
        name: str,
        baseline_sql: str,
        optimized_sql: str,
        setup_sql: Optional[str] = None,
        teardown_sql: Optional[str] = None,
        iterations: int = 3
    ) -> BenchmarkResult:
        """
        Run a full benchmark comparison.
        
        Args:
            name: Name for this benchmark
            baseline_sql: Query to run without optimization
            optimized_sql: Query to run with optimization
            setup_sql: Optional SQL to run before optimized query (e.g., create index)
            teardown_sql: Optional SQL to run after (e.g., drop index)
            iterations: Number of iterations for timing
            
        Returns:
            BenchmarkResult with comparison
        """
        print(f"Running benchmark: {name}")
        
        # Run baseline
        print("  Running baseline query...")
        baseline_result = self.benchmark(baseline_sql, iterations=iterations)
        
        # Run setup if provided
        if setup_sql:
            print("  Running setup (e.g., creating index)...")
            self.execute(setup_sql)
        
        # Run optimized
        print("  Running optimized query...")
        optimized_result = self.benchmark(optimized_sql, iterations=iterations)
        
        # Run teardown if provided
        if teardown_sql:
            print("  Running teardown...")
            self.execute(teardown_sql)
        
        result = BenchmarkResult(
            name=name,
            baseline=baseline_result,
            optimized=optimized_result
        )
        
        result.print_comparison()
        return result
    
    def create_database_if_not_exists(self, database: str = None):
        """Create the demo database if it doesn't exist."""
        db_name = database or os.getenv("FIREBOLT_DATABASE", "plg_demo")
        self.execute(f"CREATE DATABASE IF NOT EXISTS {db_name}")
        print(f"Database '{db_name}' ready")
    
    def close(self):
        """Close connections."""
        if self._core_client:
            self._core_client.close()
        if self._connection:
            self._connection.close()


# CLI support
if __name__ == "__main__":
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: python -m lib.firebolt <command> [args]")
        print("Commands:")
        print("  run <file.sql>  - Execute a SQL file")
        print("  query <sql>     - Execute inline SQL")
        print("  status          - Check connection status")
        sys.exit(1)
    
    runner = FireboltRunner()
    command = sys.argv[1]
    
    if command == "run" and len(sys.argv) > 2:
        result = runner.execute_file(sys.argv[2])
        print(f"Executed: {result}")
        if result.data:
            print(tabulate(result.data[:10], headers="keys", tablefmt="rounded_grid"))
    
    elif command == "query" and len(sys.argv) > 2:
        result = runner.execute(" ".join(sys.argv[2:]))
        print(f"Result: {result}")
        if result.data:
            print(tabulate(result.data[:10], headers="keys", tablefmt="rounded_grid"))
    
    elif command == "status":
        print(f"Runtime: {runner.runtime}")
        try:
            result = runner.execute("SELECT 1 as test")
            print("Connection: OK")
        except Exception as e:
            print(f"Connection: FAILED - {e}")
    
    else:
        print(f"Unknown command: {command}")
        sys.exit(1)
