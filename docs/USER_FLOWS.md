# plg-ide User Flows

> Step-by-step user journeys for the plg-ide web application

## Principle: Confirm Target Before Any Writes

**Never create, overwrite, or write to a database without the user having seen and confirmed the exact target.** The app must:

1. **Show** the user the account (Cloud) or host (Core), engine, and database that demos will use or create.
2. **Get explicit validation** (e.g. "I confirm" or "Use this target") before any operation that creates databases, creates tables, or loads/overwrites data.
3. **Allow correction** — user can go back and change engine or database name before confirming.

This applies to: Setup Wizard (create/select database), Data Loading (load demo data), and any feature that writes to Firebolt.

---

## Flow 0: IDE (Cursor) – Check Firebolt MCP Server

**Goal:** Ensure the user can use Firebolt from the IDE before runtime selection or demos.

**Persona:** User in Cursor (or another MCP-capable IDE) with this repo.

**When:** At first interaction or when the user asks to get started in the IDE.

```
┌─────────────────────────────────────────────────────────┐
│  1. Check: "Do you have the Firebolt MCP server running?"│
│     └─ (e.g. already added to Cursor Settings → MCP)     │
│                                                         │
│  2a. If YES                                              │
│     └─ Verify with firebolt_connect (or equivalent)     │
│     └─ Continue to runtime selection (Flow 1)          │
│                                                         │
│  2b. If NO or UNSURE                                     │
│     └─ Offer to install it locally                     │
│     └─ Option A: Docker (recommended)                   │
│     │   └─ Use image ghcr.io/firebolt-db/mcp-server    │
│     │   └─ Config added in next step (after runtime)   │
│     └─ Option B: Binary                                 │
│     │   └─ Download from GitHub Releases for their OS  │
│     └─ Link: https://github.com/firebolt-db/mcp-server   │
│     └─ Cursor: must set FIREBOLT_MCP_DISABLE_RESOURCES  │
│         =true in MCP server env                          │
│     └─ After user confirms install → runtime selection  │
│                                                         │
│  3. Proceed to Flow 1 (runtime + connection + target)  │
└─────────────────────────────────────────────────────────┘
```

**Success Criteria:** User has MCP server available (running or instructed how to install). No demos or Firebolt operations until MCP is configured when using the IDE path.

**Reference:** [Firebolt MCP Server](https://github.com/firebolt-db/mcp-server) – install options, Docker/binary, Cursor requirements.

---

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
│  5. Confirm Target (required before any write)           │
│     ├─ Show summary: Account (or host), Engine, Database │
│     ├─ "Demos will run and may create/load data here"  │
│     ├─ User confirms or goes back to change engine/DB  │
│     └─ Only after confirm → enable database setup       │
│                                                         │
│  6. Setup Database (after target confirmed)             │
│     ├─ Option: Create demo database (name shown)       │
│     ├─ Option: Select existing database                │
│     └─ Click "Continue" (no create/overwrite yet if    │
│         "Create" chosen until user triggers Load Data)  │
│                                                         │
│  7. Redirect to Vertical Selection                      │
│     └─ See grid of available verticals                 │
└─────────────────────────────────────────────────────────┘
```

**Success Criteria:**
- Connection established
- User has confirmed the account, engine, and database target
- Database selected or created only after confirmation
- User sees vertical selection

**Error Handling:**
- Connection failed: Show error message with troubleshooting tips
- Invalid credentials: Highlight which field is wrong
- Timeout: Offer retry button

---

## Flow 1b: New User Without Cloud Login

**Goal:** Get a new user (no Firebolt Cloud account) into a working demo quickly

**Persona:** New user via the IDE experience; no Cloud credentials

**Scenario:** User lands on runtime selection and doesn’t have (or doesn’t want to use) Firebolt Cloud login.

```
┌─────────────────────────────────────────────────────────┐
│  1. Land on Home Page                                   │
│     └─ See "Step 1: Select Your Runtime"                │
│     └─ Two options: Firebolt Core | Firebolt Cloud     │
│                                                         │
│  2. Preferred path (no Cloud login)                     │
│     ├─ UI should make Core the obvious "try first" path │
│     │   (e.g. "No account? Start with Core (free)")    │
│     └─ User selects "Firebolt Core"                    │
│                                                         │
│  3. Setup Wizard (Core)                                 │
│     ├─ Step 1: Confirm runtime = Core                  │
│     ├─ Step 2: Host (default localhost:3473)            │
│     ├─ Step 3: Test connection                         │
│     │   └─ If Core not running: show "Start Core" help  │
│     ├─ Step 4: Confirm target (host, engine, database)  │
│     │   └─ User validates before any create/write      │
│     └─ Step 5: Database setup → Continue                │
│                                                         │
│  4. User reaches Vertical Selection and can run demos   │
└─────────────────────────────────────────────────────────┘
```

**If user selects Cloud but has no credentials:**
- On Setup Step 2 (Cloud credentials): show short copy e.g. "Don’t have Cloud credentials? Use Firebolt Core to try demos locally (free)."
- After "Test Connection" fails (invalid/missing credentials): error message should include a clear action: "Switch to Firebolt Core" (or link back to home to choose Core).
- Do not leave the user stuck with no path forward.

**Success Criteria:**
- New users can complete a demo without Cloud login by using Core.
- If they choose Cloud and fail, they are offered a path to Core (or to get credentials), not a dead end.

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

## Flow 2b: Land on a specific feature (deep link)

**Goal:** Let a user open a link that goes straight to one feature (e.g. Automated Column Statistics) and complete setup only if needed, without forcing Home → vertical → feature.

**Persona:** User who received a shareable link (e.g. campaign or support) or who wants to try one capability first.

**When:** User opens a URL of the form `/demo/:vertical/:feature` (e.g. `/demo/gaming/automated_column_statistics`) or lands on home with `?feature=automated_column_statistics` (and optionally `?vertical=gaming`).

```
┌─────────────────────────────────────────────────────────┐
│  1. User opens deep link                                 │
│     └─ e.g. /demo/gaming/automated_column_statistics   │
│     └─ or /?feature=automated_column_statistics        │
│                                                         │
│  2a. If NOT connected                                    │
│     └─ Show Setup Wizard (connection + confirm target)│
│     └─ After successful setup → redirect to            │
│         /demo/<vertical>/<feature>                      │
│     └─ Show that feature's Demo Runner page             │
│                                                         │
│  2b. If connected                                        │
│     └─ Render Feature Demo Runner for that vertical     │
│         and feature directly                             │
│     └─ Show "Back to vertical" / "Back to home"        │
│                                                         │
│  3. User runs baseline/optimized and sees results         │
│     └─ Same as Flow 2 from step 4 onward                │
│                                                         │
│  4. Invalid vertical/feature                             │
│     └─ Show 404 or "Feature not available"             │
│     └─ Offer link to home or vertical list              │
└─────────────────────────────────────────────────────────┘
```

**Success Criteria:** User can land on a single feature via URL, complete setup if needed, and run that demo without having to choose vertical or feature from the home grid.

**Reference:** docs/APP_SPEC.md (§ Deep links).

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
│  4. Confirm Target (if not already confirmed in setup)  │
│     ├─ Show: Account (or host), Engine, Database       │
│     └─ "Data will be created/loaded here." User confirms│
│                                                         │
│  5. Choose Data Source                                  │
│     ├─ Option A: Load from Firebolt S3 (recommended)   │
│     │   └─ Uses COPY INTO from public bucket           │
│     └─ Option B: Generate sample data                  │
│         └─ Inserts smaller synthetic dataset           │
│                                                         │
│  6. Execute Loading (only after target confirmed)       │
│     ├─ See progress: "Creating tables..."              │
│     ├─ See progress: "Loading players (100K rows)..."  │
│     ├─ See progress: "Loading playstats (400K rows)..."│
│     └─ See completion: "Data loaded successfully"      │
│                                                         │
│  7. Verify Data                                         │
│     ├─ See row counts for each table                   │
│     └─ Option: Preview sample rows                     │
│                                                         │
│  8. Return to Demo Selection                            │
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
