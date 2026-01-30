# PLG-IDE User Flows

> Step-by-step user journeys for the PLG-IDE web application

## Flow 1: First-Time Setup

**Goal:** Connect to Firebolt and prepare for demos

**Persona:** Any user (Developer, Sales Engineer, Partner)

```
┌─────────────────────────────────────────────────────────┐
│  1. Land on Home Page                                   │
│     └─ See welcome message and runtime options          │
│                                                         │
│  2. Select Runtime                                      │
│     ├─ Option A: Firebolt Core (Local)                 │
│     │   └─ Click "Firebolt Core" card                  │
│     └─ Option B: Firebolt Cloud                        │
│         └─ Click "Firebolt Cloud" card                 │
│                                                         │
│  3. Configure Connection                                │
│     ├─ Core: Enter host (default localhost:3473)       │
│     └─ Cloud: Enter Client ID, Secret, Account, Engine │
│                                                         │
│  4. Test Connection                                     │
│     ├─ Click "Test Connection" button                  │
│     ├─ See loading spinner                             │
│     └─ See success (green) or error (red) indicator    │
│                                                         │
│  5. Setup Database (if needed)                          │
│     ├─ Option: "Create demo database" checkbox         │
│     └─ Click "Continue"                                │
│                                                         │
│  6. Redirect to Vertical Selection                      │
│     └─ See grid of available verticals                 │
└─────────────────────────────────────────────────────────┘
```

**Success Criteria:**
- Connection established
- Database ready
- User sees vertical selection

**Error Handling:**
- Connection failed: Show error message with troubleshooting tips
- Invalid credentials: Highlight which field is wrong
- Timeout: Offer retry button

---

## Flow 2: Run a Feature Demo

**Goal:** Experience a Firebolt feature with measurable results

**Persona:** Developer evaluating Firebolt, Sales Engineer demoing to prospect

```
┌─────────────────────────────────────────────────────────┐
│  1. Select Vertical (from home or sidebar)              │
│     └─ Click "Gaming" card                             │
│                                                         │
│  2. View Vertical Overview                              │
│     ├─ See dataset info (tables, row counts)           │
│     └─ See available feature demos                     │
│                                                         │
│  3. Select Feature Demo                                 │
│     └─ Click "Aggregating Indexes" → "Run Demo"        │
│                                                         │
│  4. View Demo Page                                      │
│     ├─ See explanation of the feature                  │
│     ├─ See the SQL query that will be tested           │
│     └─ See two cards: Baseline | Optimized             │
│                                                         │
│  5. Run Baseline (without feature)                      │
│     ├─ Click "Run Baseline" button                     │
│     ├─ See loading spinner                             │
│     ├─ See results: query time, rows scanned, bytes    │
│     └─ Note: This is slow (e.g., 1,234ms)              │
│                                                         │
│  6. Enable Feature                                      │
│     ├─ Click "Create Index" or "Enable Feature"        │
│     ├─ See progress indicator                          │
│     └─ See confirmation: "Index created"               │
│                                                         │
│  7. Run Optimized (with feature)                        │
│     ├─ Click "Run Optimized" button                    │
│     ├─ See loading spinner                             │
│     ├─ See results: query time, rows scanned, bytes    │
│     └─ Note: This is fast (e.g., 45ms)                 │
│                                                         │
│  8. View Comparison                                     │
│     ├─ See improvement metrics (e.g., "27x faster")    │
│     ├─ See percentage reductions (97% less time)       │
│     └─ Option: View EXPLAIN ANALYZE output             │
│                                                         │
│  9. Next Steps                                          │
│     ├─ Option: Try another query                       │
│     ├─ Option: Go to SQL Playground                    │
│     └─ Option: Select another feature demo             │
└─────────────────────────────────────────────────────────┘
```

**Success Criteria:**
- User sees dramatic performance improvement
- Metrics are clear and impressive
- User understands why feature helps

**Talking Points (for Sales Engineers):**
- "Notice how the baseline scanned 500K rows but optimized only scanned 1,250"
- "The aggregating index pre-computes the aggregation, so Firebolt reads much less data"
- "This translates directly to cost savings in production"

---

## Flow 3: Load Demo Data

**Goal:** Populate tables with sample data for demos

**Persona:** New user, user with fresh Firebolt instance

```
┌─────────────────────────────────────────────────────────┐
│  1. Navigate to Vertical                                │
│     └─ Select "Gaming" from home or sidebar            │
│                                                         │
│  2. See "Data Not Loaded" Indicator                     │
│     └─ Tables are empty or don't exist                 │
│                                                         │
│  3. Click "Load Demo Data"                              │
│     └─ Opens data loading wizard                       │
│                                                         │
│  4. Choose Data Source                                  │
│     ├─ Option A: Load from Firebolt S3 (recommended)   │
│     │   └─ Uses COPY INTO from public bucket           │
│     └─ Option B: Generate sample data                  │
│         └─ Inserts smaller synthetic dataset           │
│                                                         │
│  5. Execute Loading                                     │
│     ├─ See progress: "Creating tables..."              │
│     ├─ See progress: "Loading players (100K rows)..."  │
│     ├─ See progress: "Loading playstats (400K rows)..."│
│     └─ See completion: "Data loaded successfully"      │
│                                                         │
│  6. Verify Data                                         │
│     ├─ See row counts for each table                   │
│     └─ Option: Preview sample rows                     │
│                                                         │
│  7. Return to Demo Selection                            │
│     └─ Feature demos now show as "Ready"               │
└─────────────────────────────────────────────────────────┘
```

**Success Criteria:**
- Tables created with correct schema
- Data loaded without errors
- Demo features enabled

---

## Flow 4: SQL Playground

**Goal:** Explore data with custom queries

**Persona:** Developer, technical Sales Engineer

```
┌─────────────────────────────────────────────────────────┐
│  1. Navigate to Playground                              │
│     └─ Click "SQL Playground" in header                │
│                                                         │
│  2. View Playground Interface                           │
│     ├─ SQL editor (top)                                │
│     ├─ Results panel (bottom)                          │
│     └─ Schema browser (sidebar)                        │
│                                                         │
│  3. Explore Schema                                      │
│     ├─ Expand table in sidebar                         │
│     └─ See columns and types                           │
│                                                         │
│  4. Write Query                                         │
│     ├─ Type SQL in editor                              │
│     ├─ Use autocomplete for table/column names         │
│     └─ Or click example query from sidebar             │
│                                                         │
│  5. Execute Query                                       │
│     ├─ Click "Run" button or press Cmd+Enter           │
│     ├─ See loading indicator                           │
│     └─ See results in table                            │
│                                                         │
│  6. View Results                                        │
│     ├─ See data in tabular format                      │
│     ├─ See execution time                              │
│     ├─ Paginate through results                        │
│     └─ Option: Export to CSV                           │
│                                                         │
│  7. View History                                        │
│     ├─ See recent queries in sidebar                   │
│     └─ Click to re-run a previous query                │
└─────────────────────────────────────────────────────────┘
```

**Success Criteria:**
- Query executes successfully
- Results display correctly
- Performance metrics visible

---

## Flow 5: Competitive Benchmark

**Goal:** Compare Firebolt performance against alternatives

**Persona:** Sales Engineer, technical buyer evaluating options

```
┌─────────────────────────────────────────────────────────┐
│  1. Navigate to Competitive Benchmarks                  │
│     └─ Click "Compare" or select from vertical         │
│                                                         │
│  2. Select Comparison                                   │
│     └─ Click "Firebolt vs ClickHouse"                  │
│                                                         │
│  3. View Benchmark Setup                                │
│     ├─ See benchmark description                       │
│     ├─ See query being tested                          │
│     └─ See dataset details                             │
│                                                         │
│  4. View Results                                        │
│     ├─ Side-by-side metrics                            │
│     │   ├─ Firebolt: 45ms                              │
│     │   └─ ClickHouse: 320ms (7x slower)               │
│     ├─ Key differentiators highlighted                 │
│     └─ Syntax comparison (simpler in Firebolt)         │
│                                                         │
│  5. Export Results                                      │
│     ├─ Option: Copy as markdown                        │
│     ├─ Option: Download as PDF                         │
│     └─ Option: Share link                              │
└─────────────────────────────────────────────────────────┘
```

**Success Criteria:**
- Clear Firebolt advantage demonstrated
- Results exportable for sharing
- Technical explanation available

---

## Flow 6: Partner Training Path

**Goal:** Complete training on Firebolt features

**Persona:** SI/MSP partner learning Firebolt

```
┌─────────────────────────────────────────────────────────┐
│  1. Start Training Module                               │
│     └─ Click "Learn" → "Partner Training"              │
│                                                         │
│  2. View Training Overview                              │
│     ├─ See modules: Core Concepts, Features, Best...   │
│     └─ See progress tracker                            │
│                                                         │
│  3. Complete Module                                     │
│     ├─ Read explanation                                │
│     ├─ Watch optional video                            │
│     ├─ Run hands-on demo                               │
│     └─ Answer quiz questions                           │
│                                                         │
│  4. Track Progress                                      │
│     ├─ See completed modules (green checkmarks)        │
│     └─ See overall completion percentage               │
│                                                         │
│  5. Earn Certificate (future)                           │
│     └─ Complete all modules → download certificate     │
└─────────────────────────────────────────────────────────┘
```

---

## Error States

### Connection Lost

```
User Action: Any action requiring database
System Response:
1. Show toast: "Connection lost. Reconnecting..."
2. Attempt automatic reconnection (3 retries)
3. If failed: Show modal with "Reconnect" button
4. User clicks reconnect → Go to setup wizard
```

### Query Error

```
User Action: Run SQL query
System Response:
1. Show error message in results panel
2. Highlight error position in editor (if syntax error)
3. Offer suggestions:
   - "Did you mean TABLE_NAME?"
   - "Column X doesn't exist in TABLE"
4. Link to relevant documentation
```

### Data Loading Failed

```
User Action: Load demo data
System Response:
1. Show which step failed
2. Show error message
3. Offer options:
   - Retry from failed step
   - Use alternative data source
   - Contact support
```

---

## Mobile-Specific Flows

### Mobile Demo Viewing

```
1. Vertical/Feature selection: Full-screen cards, swipe to navigate
2. Benchmark results: Stack Before/After vertically
3. SQL viewer: Full-screen with scroll
4. Results: Swipe between metrics and data table
```

### Mobile Playground (Limited)

```
1. Simplified interface: Editor + Results only
2. No schema browser (use dropdown)
3. Example queries prominent
4. Results in card format (one row per card)
```
