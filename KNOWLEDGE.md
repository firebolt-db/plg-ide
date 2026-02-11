# plg-ide Knowledge

> This file provides context for AI-assisted development (Loveable, Cursor, etc.)
>
> **For Loveable:** Use this file as the primary context for product vision and design system. Build entry point: **docs/LOVEABLE.md**. Data for verticals/features: **docs/app-manifest.json**.
>
> **Strict plan for demos and app:** When adding or changing demo capabilities or app flows, **adhere to** **docs/PLAN_AND_GOVERNANCE.md**. New work must conform to that plan (real connectivity, confirm target before writes, impact-first demos with comments and progress); do not overwrite it with a different approach.

## Product Vision

plg-ide is a **Product-Led Growth platform for Firebolt** that demonstrates the value of Firebolt's data warehouse through interactive, measurable demos. It serves three purposes:

1. **IDE Getting Started** - Developers open this repo in Cursor and experience Firebolt's value firsthand
2. **Sales Training** - Sales Engineers and Partners learn Firebolt features through hands-on demos
3. **Competitive Proof** - Side-by-side comparisons showing Firebolt's advantages over alternatives

The core principle: **"Prove the value through building"** - every feature demo shows measurable before/after metrics.

## Target Users

### Sales Engineers
- Need to demonstrate Firebolt value to prospects in real-time
- Want reproducible demos with impressive metrics
- Require talking points explaining why results matter

### Partners (SI/MSP)
- Need training on Firebolt features and best practices
- Want to guide customers through setup and optimization
- Require certification-ready knowledge

### Developers
- Evaluating Firebolt for their use case
- Want to test with realistic data in their vertical
- Need to understand performance characteristics

## Design System

### Color Palette

#### Primary Colors
| Name | Hex | CSS Variable | Usage |
|------|-----|--------------|-------|
| Firebolt Red | #F72A30 | `--color-primary` | Primary CTAs, main interactive elements |
| Dark Mode Primary | #AC2422 | `--color-primary-dark` | Buttons/CTAs on dark surfaces |
| Primary Tint | #FF4848 | `--color-primary-hover` | Hover and selected states |
| Light Primary Tint | #FFF2F3 | `--color-primary-light` | Pale pink backgrounds |
| Light Surfaces | #F5EBEB | `--color-surface-light` | Table lines, hover backgrounds |
| Lightest Surfaces | #FFFCF9 | `--color-surface-lightest` | Section backgrounds |

#### Neutral Colors
| Name | Hex | CSS Variable | Usage |
|------|-----|--------------|-------|
| Darker Than Black | #0E0202 | `--color-black-deep` | Deepest dark |
| Firebolt Black | #1A0404 | `--color-black` | Sidebar bg, illustration outlines |
| Dark Surfaces | #332621 | `--color-surface-dark` | Tooltip backgrounds |
| Interaction Elements | #665555 | `--color-interactive` | Dropdown triangles |
| Icons | #998A85 | `--color-icon` | Icons, non-critical text |
| Field Lines | #CCC2C2 | `--color-border` | Input field borders |
| Dark Mode Text | #E5E1E1 | `--color-text-dark-mode` | Text on dark CTAs |
| Pure White | #FFFFFF | `--color-white` | Dominant background |

#### Semantic Colors
| Purpose | Light Mode | Dark Mode |
|---------|------------|-----------|
| Success/Improvement | #22C55E | #4ADE80 |
| Warning | #F59E0B | #FBBF24 |
| Error | #EF4444 | #F87171 |
| Info | #3B82F6 | #60A5FA |

### Typography

| Element | Font | Weight | Size | Line Height |
|---------|------|--------|------|-------------|
| H1 | Poppins | 600 (Semibold) | 32px | 1.2 |
| H2 | Poppins | 600 (Semibold) | 24px | 1.3 |
| H3 | Poppins | 600 (Semibold) | 20px | 1.4 |
| Body | Inter | 400 (Regular) | 16px | 1.5 |
| Body Small | Inter | 400 (Regular) | 14px | 1.5 |
| Label | Inter | 500 (Medium) | 14px | 1.4 |
| Code | Roboto Mono | 400 (Regular) | 14px | 1.6 |
| Metric Large | Poppins | 600 (Semibold) | 48px | 1.1 |

**Font Loading:**
```html
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@600&family=Inter:wght@400;500&family=Roboto+Mono&display=swap" rel="stylesheet">
```

### Design Principles

1. **Flat colors ONLY** - No gradients, no drop shadows, no organic textures, no 3D lighting effects
2. **Clean minimalism** - Technical authority through simplicity
3. **Data-forward** - Metrics and results are the hero content
4. **Before/After focus** - Every demo shows measurable improvement

### Component Patterns

#### Cards
- Background: `#FFFFFF`
- Border: 1px solid `#F5EBEB`
- Border radius: 8px
- Padding: 24px
- Hover: Border color changes to `#FF4848`

#### Buttons
- Primary: Background `#F72A30`, text `#FFFFFF`
- Primary Hover: Background `#FF4848`
- Secondary: Background `#FFFFFF`, border `#CCC2C2`, text `#1A0404`
- Border radius: 6px
- Padding: 12px 24px
- Font: Inter Medium 14px

#### Tables
- Header: Background `#F5EBEB`, text `#1A0404`, font Inter Medium
- Row: Background alternating `#FFFFFF` / `#FFFCF9`
- Border: 1px solid `#F5EBEB`
- Cell padding: 12px 16px

#### Code Blocks
- Background: `#1A0404`
- Text: `#E5E1E1`
- Font: Roboto Mono 14px
- Padding: 16px
- Border radius: 8px
- Syntax highlighting: Use Firebolt Red for keywords

#### Metric Display
- Large number: Poppins Semibold 48px
- Label below: Inter Regular 14px, color `#998A85`
- Improvement indicator: `#22C55E` for positive, `#EF4444` for negative
- Use arrow icons (↑/↓) next to percentages

#### Progress Indicators
- Track: `#F5EBEB`
- Fill: `#F72A30`
- Height: 8px
- Border radius: 4px

## Core Features

### 1. Runtime Selection
Users choose between:
- **Firebolt Core** - Free, local Docker-based instance
- **Firebolt Cloud** - Managed cloud service with credentials

### 2. Vertical Selection
Industry-specific demos with realistic data:
- Gaming (leaderboards, player analytics)
- E-commerce (product analytics, funnel analysis)
- AdTech (impression tracking, campaign performance)
- Observability (log analytics, metrics aggregation)
- Financial (transaction analysis, risk calculations)
- CyberTech (security analytics, threat detection, compliance — placeholder)

### 3. Feature Demos
Each demo shows a Firebolt capability:
- **Aggregating Indexes** - Pre-computed aggregations for faster queries
- **Late Materialization** - Reduced I/O through deferred joins
- **Vector Search** - Semantic search capabilities
- **High Concurrency** - Handling many simultaneous queries

### 4. Benchmark Comparison
Every demo includes:
- Baseline query (feature OFF)
- Optimized query (feature ON)
- Metrics: Query time, rows scanned, bytes read
- Improvement percentage

### 5. SQL Playground
Interactive SQL editor for:
- Running custom queries
- Exploring demo data
- Testing optimizations

## Technical Constraints

### API Integration
- Connects to Firebolt via REST API or Python SDK
- Supports both Core (localhost:3473) and Cloud endpoints
- Must handle async query execution with loading states

### Data Requirements
- Demo datasets loaded from Firebolt public S3 bucket
- Sample data generator for Core environments
- Minimum data sizes for meaningful benchmarks

### Performance Considerations
- Disable result cache for accurate benchmarks: `SET enable_result_cache = FALSE`
- Run queries multiple times for average timing
- Show EXPLAIN ANALYZE output for technical users

## UI Guidelines

### Layout Structure
```
┌─────────────────────────────────────────────────────────┐
│  Header: Logo + Navigation                              │
├─────────────────────────────────────────────────────────┤
│  Sidebar          │  Main Content                       │
│  - Verticals      │  - Demo runner                      │
│  - Features       │  - Results display                  │
│  - Settings       │  - SQL viewer                       │
└─────────────────────────────────────────────────────────┘
```

### Navigation
- Card-based selection for verticals and features
- Breadcrumb trail: Home > Vertical > Feature
- Sidebar for quick navigation within a vertical

### Results Display
- Side-by-side cards for Before/After
- Large metric numbers with improvement arrows
- Collapsible SQL code blocks
- Expandable EXPLAIN output

### Mobile Considerations
- Stack cards vertically on mobile
- Full-width SQL editor
- Swipe between Before/After views

## Starter Prompts for Loveable

Use these prompts to build the app incrementally:

1. "Create a home page with runtime selection (Core vs Cloud) using Firebolt brand colors"
2. "Build a vertical selection grid with cards for Gaming, E-commerce, AdTech, Observability, Financial, CyberTech"
3. "Create a feature demo page with before/after comparison cards showing metrics"
4. "Add a SQL editor component with dark theme and Roboto Mono font"
5. "Build a benchmark results component with large metric numbers and improvement percentages"
6. "Create a connection setup wizard with step indicators"
7. "Add syntax highlighting for Firebolt SQL in code blocks"

## File Structure Reference

```
plg-ide/
├── KNOWLEDGE.md          # This file (vision, design, features)
├── README.md             # Getting started guide
├── ROADMAP.md            # Feature roadmap, Loveable build phases
├── config/               # MCP and environment configs
├── lib/                  # Python runtime abstraction
├── verticals/            # Industry-specific demos
│   ├── gaming/           # Leaderboards, player analytics
│   ├── ecommerce/        # Retail, revenue, product analytics
│   ├── adtech/           # Campaigns, impressions, publishers
│   ├── observability/    # Logs, metrics, tracing
│   ├── financial/       # Transactions, risk, reporting
│   └── cybertech/       # Security, threat detection (placeholder)
│       ├── schema/       # Table definitions (SQL)
│       ├── data/         # Data loading (SQL/Python)
│       ├── demo_full.sql # Full walkthrough + talking points
│       ├── demo_comparison.sql
│       └── features/     # Feature demos (e.g. aggregating_indexes)
├── features/             # Cross-vertical feature docs
└── docs/                 # Additional documentation
    ├── LOVEABLE.md       # Loveable build entry point
    ├── APP_SPEC.md       # UI specification
    ├── DATA_CONTRACTS.md # TypeScript interfaces
    ├── USER_FLOWS.md     # User journey maps
    └── app-manifest.json # Verticals + features (data for app)
```
