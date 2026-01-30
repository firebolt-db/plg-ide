# PLG-IDE Data Contracts

> TypeScript interfaces for all data shapes used in the PLG-IDE web application

## Runtime & Connection

```typescript
// Runtime type selection
type RuntimeType = 'core' | 'cloud';

// Connection configuration
interface CoreConnection {
  type: 'core';
  host: string;        // Default: 'localhost'
  port: number;        // Default: 3473
  database?: string;   // Optional, created if needed
}

interface CloudConnection {
  type: 'cloud';
  clientId: string;
  clientSecret: string;
  accountName: string;
  engineName: string;
  database?: string;
}

type FireboltConnection = CoreConnection | CloudConnection;

// Connection status
interface ConnectionStatus {
  connected: boolean;
  runtime: RuntimeType | null;
  database: string | null;
  error?: string;
  lastChecked: Date;
}
```

## Verticals & Features

```typescript
// Industry vertical
interface Vertical {
  id: string;                    // e.g., 'gaming', 'ecommerce'
  name: string;                  // e.g., 'Gaming'
  description: string;           // Short description
  icon: string;                  // Icon name or URL
  dataset: DatasetInfo;
  features: FeatureRef[];
  status: 'available' | 'coming_soon';
}

// Dataset information
interface DatasetInfo {
  name: string;                  // e.g., 'Ultra Fast Gaming'
  description: string;
  tables: TableInfo[];
  totalRows: string;             // e.g., '500K+'
  sizeOnDisk: string;            // e.g., '125 MB'
  source: 'firebolt_samples' | 'generated' | 'custom';
  s3Bucket?: string;             // For loading from S3
}

// Table metadata
interface TableInfo {
  name: string;
  description: string;
  columns: ColumnInfo[];
  rowCount?: number;
}

// Column metadata
interface ColumnInfo {
  name: string;
  type: string;                  // Firebolt type, e.g., 'INT', 'TEXT'
  nullable: boolean;
  description?: string;
}

// Feature reference within a vertical
interface FeatureRef {
  featureId: string;             // Links to Feature.id
  status: 'available' | 'coming_soon';
  customConfig?: Record<string, unknown>;
}

// Feature definition
interface Feature {
  id: string;                    // e.g., 'aggregating_indexes'
  name: string;                  // e.g., 'Aggregating Indexes'
  shortDescription: string;      // One-liner
  longDescription: string;       // Detailed explanation
  typicalImprovement: string;    // e.g., '10-100x faster'
  documentationUrl?: string;
  applicableVerticals: string[]; // Which verticals support this
}
```

## Benchmark & Demo

```typescript
// Query execution result
interface QueryResult {
  sql: string;
  success: boolean;
  data?: Record<string, unknown>[];
  rowCount: number;
  error?: string;
  metrics: QueryMetrics;
}

// Query performance metrics
interface QueryMetrics {
  executionTimeMs: number;
  rowsScanned: number;
  bytesRead: number;
  bytesReadFormatted: string;    // e.g., '125 MB'
  cacheHit: boolean;
}

// Benchmark comparison result
interface BenchmarkResult {
  name: string;                  // e.g., 'Leaderboard Query'
  description: string;
  sql: string;                   // The query being benchmarked
  baseline: BenchmarkRun;
  optimized: BenchmarkRun;
  improvement: ImprovementMetrics;
  runAt: Date;
}

// Single benchmark run
interface BenchmarkRun {
  label: string;                 // e.g., 'Without Index'
  metrics: QueryMetrics;
  explainOutput?: string;        // EXPLAIN ANALYZE result
  iterations: number;            // Number of runs averaged
}

// Calculated improvement
interface ImprovementMetrics {
  timeFactor: number;            // e.g., 27.4 (27.4x faster)
  timePercentReduction: number;  // e.g., 96.3 (96.3% faster)
  rowsSavedPercent: number;      // e.g., 99.7
  bytesSavedPercent: number;     // e.g., 99.8
}

// Demo step for guided walkthrough
interface DemoStep {
  id: string;
  title: string;
  description: string;
  action: DemoAction;
  expectedDuration?: number;     // Estimated seconds
}

type DemoAction =
  | { type: 'execute_sql'; sql: string }
  | { type: 'create_index'; indexDefinition: string }
  | { type: 'drop_index'; indexName: string }
  | { type: 'wait'; description: string }
  | { type: 'explain'; message: string };

// Full demo definition
interface Demo {
  id: string;
  verticalId: string;
  featureId: string;
  name: string;
  description: string;
  steps: DemoStep[];
  queries: BenchmarkQuery[];
}

// Query to benchmark
interface BenchmarkQuery {
  id: string;
  name: string;
  description: string;
  sql: string;
  expectedImprovement?: string;
}
```

## SQL Playground

```typescript
// Saved query
interface SavedQuery {
  id: string;
  name: string;
  sql: string;
  createdAt: Date;
  lastRun?: Date;
  tags?: string[];
}

// Query history item
interface QueryHistoryItem {
  id: string;
  sql: string;
  result: 'success' | 'error';
  executionTimeMs?: number;
  rowsReturned?: number;
  error?: string;
  runAt: Date;
}

// Editor state
interface EditorState {
  content: string;
  cursorPosition: { line: number; column: number };
  selectedDatabase?: string;
}
```

## UI State

```typescript
// App-level state
interface AppState {
  connection: ConnectionStatus;
  selectedVertical: string | null;
  selectedFeature: string | null;
  currentDemo: Demo | null;
  benchmarkResults: BenchmarkResult[];
  isLoading: boolean;
  error: string | null;
}

// Navigation breadcrumb
interface Breadcrumb {
  label: string;
  path: string;
  active: boolean;
}

// Toast notification
interface Toast {
  id: string;
  type: 'success' | 'error' | 'warning' | 'info';
  message: string;
  duration?: number;             // Auto-dismiss after ms
}
```

## API Request/Response

```typescript
// Execute SQL request
interface ExecuteSQLRequest {
  sql: string;
  database?: string;
  settings?: Record<string, string | number | boolean>;
}

// Execute SQL response
interface ExecuteSQLResponse {
  success: boolean;
  data?: Record<string, unknown>[];
  meta?: {
    columns: { name: string; type: string }[];
  };
  statistics?: {
    elapsed: number;
    rows_read: number;
    bytes_read: number;
  };
  error?: {
    code: string;
    message: string;
  };
}

// Schema introspection
interface GetSchemaRequest {
  database: string;
}

interface GetSchemaResponse {
  tables: TableInfo[];
}
```

## Configuration

```typescript
// Feature toggle for demos
interface FeatureConfig {
  featureId: string;
  enabled: boolean;
  settings?: Record<string, unknown>;
}

// App configuration
interface AppConfig {
  defaultRuntime: RuntimeType;
  defaultDatabase: string;
  benchmarkIterations: number;   // Default: 3
  queryTimeout: number;          // Default: 30000ms
  enableCache: boolean;          // Default: false for benchmarks
}
```

## Competitive Benchmark

```typescript
// Competitive comparison
interface CompetitiveBenchmark {
  id: string;
  competitor: 'clickhouse' | 'snowflake' | 'bigquery';
  name: string;
  description: string;
  fireboltResult: BenchmarkRun;
  competitorResult: BenchmarkRun;
  fireboltAdvantage: string;     // e.g., '3x faster with simpler syntax'
}
```

## Enums & Constants

```typescript
// Supported Firebolt SQL types
type FireboltType =
  | 'INT'
  | 'BIGINT'
  | 'FLOAT'
  | 'DOUBLE'
  | 'TEXT'
  | 'DATE'
  | 'TIMESTAMP'
  | 'TIMESTAMPTZ'
  | 'BOOLEAN'
  | 'ARRAY'
  | 'BYTEA';

// Index types
type IndexType = 'AGGREGATING' | 'PRIMARY' | 'SEARCH';

// Demo status
type DemoStatus = 'not_started' | 'in_progress' | 'completed' | 'error';
```
