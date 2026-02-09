# plg-ide App Specification

> UI specification for the plg-ide web application (Loveable build target)
>
> **For Loveable:** Use `docs/app-manifest.json` for the list of verticals and their features (Gaming, E-commerce, AdTech, Observability, Financial). Use `docs/LOVEABLE.md` as the build entry point.

## Page Structure

```
/                           # Home - Runtime & Vertical Selection
/setup                      # Connection Setup Wizard
/demo/:vertical             # Vertical Overview
/demo/:vertical/:feature    # Feature Demo Runner
/playground                 # SQL Playground
/learn                      # Documentation & Learning
/learn/:feature             # Feature Deep Dive
```

## Pages

### 1. Home Page (`/`)

**Purpose:** Entry point - select runtime and vertical

**Layout:**
```
┌─────────────────────────────────────────────────────────┐
│  [Firebolt Logo]                    [Settings] [Help]   │
├─────────────────────────────────────────────────────────┤
│                                                         │
│     Welcome to Firebolt plg-ide                         │
│     Experience the value through interactive demos      │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │  Step 1: Select Your Runtime                     │   │
│  │  ┌──────────────┐  ┌──────────────┐             │   │
│  │  │ Firebolt Core│  │ Firebolt     │             │   │
│  │  │ (Local/Free) │  │ Cloud        │             │   │
│  │  │ [Docker]     │  │ [Credentials]│             │   │
│  │  └──────────────┘  └──────────────┘             │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │  Step 2: Choose Your Vertical                    │   │
│  │  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐   │
│  │  │ Gaming │ │E-comm  │ │ AdTech │ │Observe │ │Financial│   │
│  │  └────────┘ └────────┘ └────────┘ └────────┘ └────────┘   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**Components:**
- RuntimeSelector - Two cards (Core/Cloud) with radio selection
- VerticalGrid - Grid of cards with icons and descriptions
- StatusIndicator - Shows connection status

**States:**
- No runtime selected (initial)
- Runtime selected, not connected
- Runtime connected, ready

**New user without Cloud login:** Prefer Firebolt Core as the default or highlighted "try first" option (e.g. label or helper text: "No account? Start with Core (free, local)."). When the user selects Cloud and later fails connection due to missing/invalid credentials, show an escape path: e.g. "Don't have Cloud credentials? Use Firebolt Core to run demos locally" with a control to switch to Core or return to runtime selection. Never leave the user with no path forward.

### 2. Setup Wizard (`/setup`)

**Purpose:** Configure connection to Firebolt

**Flow:** Multi-step wizard

**Step 1: Runtime Confirmation**
- Show selected runtime (Core or Cloud)
- Option to change

**Step 2: Connection Details**
- Core: Host URL (default localhost:3473)
- Cloud: Client ID, Client Secret, Account Name, Engine Name

**Step 3: Test Connection**
- "Test Connection" button
- Success/failure indicator
- Error message display

**Step 4: Database Setup**
- Create demo database option
- Select existing database

**Components:**
- StepIndicator - Shows progress (1/4, 2/4, etc.)
- ConnectionForm - Input fields for credentials
- TestConnectionButton - With loading spinner
- SuccessMessage / ErrorMessage

### 3. Vertical Overview (`/demo/:vertical`)

**Purpose:** Overview of a vertical with feature selection

**Layout:**
```
┌─────────────────────────────────────────────────────────┐
│  [←] Gaming Vertical                    [SQL Playground]│
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Dataset: Ultra Fast Gaming                             │
│  Tables: players, games, tournaments, playstats         │
│  Rows: 500K+ events                                     │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │  Available Feature Demos                         │   │
│  │  ┌────────────────────────────────────────────┐ │   │
│  │  │ Aggregating Indexes                        │ │   │
│  │  │ Pre-compute aggregations for 10x faster   │ │   │
│  │  │ [Run Demo →]                              │ │   │
│  │  └────────────────────────────────────────────┘ │   │
│  │  ┌────────────────────────────────────────────┐ │   │
│  │  │ Late Materialization (Coming Soon)        │ │   │
│  │  │ Reduce I/O with deferred joins            │ │   │
│  │  └────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**Components:**
- DatasetInfo - Card showing dataset details
- FeatureList - List of feature demo cards
- FeatureCard - Name, description, status, action button

### 4. Feature Demo Runner (`/demo/:vertical/:feature`)

**Purpose:** Run before/after benchmark comparison

**Layout:**
```
┌─────────────────────────────────────────────────────────┐
│  [←] Gaming > Aggregating Indexes            [Settings] │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────────────┐ ┌──────────────────────┐     │
│  │  BASELINE            │ │  OPTIMIZED           │     │
│  │  (No Index)          │ │  (With Index)        │     │
│  │                      │ │                      │     │
│  │  Query Time          │ │  Query Time          │     │
│  │  ┌────────────────┐  │ │  ┌────────────────┐  │     │
│  │  │   1,234 ms     │  │ │  │    45 ms  ↓97% │  │     │
│  │  └────────────────┘  │ │  └────────────────┘  │     │
│  │                      │ │                      │     │
│  │  Rows Scanned        │ │  Rows Scanned        │     │
│  │  500,000             │ │  1,250      ↓99%     │     │
│  │                      │ │                      │     │
│  │  Bytes Read          │ │  Bytes Read          │     │
│  │  125 MB              │ │  312 KB     ↓99%     │     │
│  │                      │ │                      │     │
│  │  [Run Baseline]      │ │  [Run Optimized]     │     │
│  └──────────────────────┘ └──────────────────────┘     │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │  SQL Query                              [Copy]   │   │
│  │  ┌─────────────────────────────────────────────┐│   │
│  │  │ SELECT player_id, SUM(score) as total      ││   │
│  │  │ FROM playstats                             ││   │
│  │  │ GROUP BY player_id                         ││   │
│  │  │ ORDER BY total DESC LIMIT 10;              ││   │
│  │  └─────────────────────────────────────────────┘│   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │  [▼] EXPLAIN ANALYZE Output                      │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**Components:**
- BenchmarkCard - Shows metrics for one run
- MetricDisplay - Large number with label and improvement arrow
- SQLViewer - Code block with copy button
- ExplainOutput - Collapsible query plan
- RunButton - Executes benchmark with loading state

**States:**
- Initial (no results)
- Running baseline
- Baseline complete
- Running optimized
- Both complete (show comparison)

**Demo content source (for all features including Partitioning):**  
For each `vertical` and `feature` in the app manifest, the backend/API should serve baseline and optimized SQL from this repo at:
- Baseline: `verticals/{vertical}/features/{feature}/01_baseline.sql`
- Optimized: `verticals/{vertical}/features/{feature}/03_optimized.sql`  
The Feature Demo Runner must always show **both** Baseline and Optimized cards with SQL viewer and Run buttons, and load this content by vertical+feature (e.g. `ecommerce` + `partitioning`). If a feature has no demo files, show "Demo content coming soon" instead of empty inputs.

### 5. SQL Playground (`/playground`)

**Purpose:** Interactive SQL editor

**Layout:**
```
┌─────────────────────────────────────────────────────────┐
│  SQL Playground                          [Run] [Format] │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────┐   │
│  │ Editor (Monaco/CodeMirror)                       │   │
│  │                                                  │   │
│  │ SELECT * FROM playstats LIMIT 10;               │   │
│  │                                                  │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │ Results                        Query time: 45ms │   │
│  │ ┌─────────────────────────────────────────────┐ │   │
│  │ │ player_id │ game_id │ score │ timestamp     │ │   │
│  │ │ 12345     │ 789     │ 1500  │ 2024-01-15    │ │   │
│  │ │ ...       │ ...     │ ...   │ ...           │ │   │
│  │ └─────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  ┌───────────────────┐                                  │
│  │ Schema Browser    │                                  │
│  │ ├─ players        │                                  │
│  │ ├─ games          │                                  │
│  │ ├─ tournaments    │                                  │
│  │ └─ playstats      │                                  │
│  └───────────────────┘                                  │
└─────────────────────────────────────────────────────────┘
```

**Components:**
- SQLEditor - Monaco or CodeMirror with Firebolt syntax
- ResultsTable - Paginated data table
- QueryStats - Execution time, rows returned
- SchemaBrowser - Collapsible tree of tables/columns
- QueryHistory - Recent queries (local storage)

### 6. Learn Page (`/learn`)

**Purpose:** Documentation and feature explanations

**Components:**
- FeatureList - Cards linking to feature deep dives
- SearchBox - Search documentation
- ExternalLinks - Links to Firebolt docs

### 7. Feature Deep Dive (`/learn/:feature`)

**Purpose:** Detailed explanation of a Firebolt feature

**Content:**
- What it is
- How it works
- When to use it
- SQL syntax examples
- Performance characteristics
- Best practices

## Shared Components

### Header
- Logo (links to home)
- Connection status indicator (green/red dot)
- Navigation links: Demos, Playground, Learn
- Settings icon
- Help icon

### Sidebar (on demo pages)
- Vertical list
- Feature list (filtered by selected vertical)
- Quick links

### Footer
- Firebolt links
- GitHub repo link
- Version info

## Responsive Breakpoints

| Breakpoint | Width | Layout Changes |
|------------|-------|----------------|
| Desktop | 1200px+ | Full sidebar, side-by-side cards |
| Tablet | 768-1199px | Collapsible sidebar, stacked cards |
| Mobile | <768px | No sidebar, full-width cards, bottom nav |

## Accessibility

- All interactive elements keyboard accessible
- ARIA labels on icons and buttons
- Color contrast meets WCAG AA
- Focus indicators using Firebolt Red (#F72A30)
- Screen reader announcements for query results
