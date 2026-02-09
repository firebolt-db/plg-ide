# Building the plg-ide Web App with Loveable

> **Use this repo as context for Loveable to build the plg-ide web application.**  
> Read the files below in order. The app is a Product-Led Growth demo platform for Firebolt.

## 1. What to Read First (in order)

| Order | File | Why |
|-------|------|-----|
| 1 | **KNOWLEDGE.md** (repo root) | Product vision, design system (colors, typography, components), core features, technical constraints, UI guidelines |
| 2 | **docs/APP_SPEC.md** | Page structure (routes), layout of every page, component list, responsive breakpoints |
| 3 | **docs/DATA_CONTRACTS.md** | TypeScript interfaces for runtime, verticals, benchmarks, SQL playground, API requests/responses |
| 4 | **docs/USER_FLOWS.md** | Step-by-step user journeys (setup, run demo, load data, playground, errors) |
| 5 | **docs/app-manifest.json** | Data-driven list of verticals and features (use for navigation and demo selection) |

## 2. What You Are Building

- **Product:** plg-ide – a web app that lets users connect to Firebolt (Core or Cloud), pick an industry vertical (Gaming, E-commerce, AdTech, Observability, Financial), run feature demos (e.g. Aggregating Indexes), and see **before/after benchmark metrics** (query time, rows scanned, bytes read).
- **Users:** Sales engineers (demos), developers (evaluation), partners (training).
- **Principle:** Every demo shows measurable improvement (e.g. "50–100X faster with aggregating indexes").

## 3. Build Order (recommended)

1. **Phase 1 – Core demo runner**  
   Home page (runtime + vertical selection) → Connection setup wizard → Vertical overview → Feature demo runner with Before/After metric cards. Use **KNOWLEDGE.md** for design system (Firebolt Red #F72A30, Poppins/Inter, cards, buttons). Use **APP_SPEC.md** for layouts.

2. **Phase 2 – SQL Playground**  
   SQL editor (Monaco or CodeMirror), dark theme (#1A0404, Roboto Mono), results table, execution time, schema browser, query history (localStorage).

3. **Phase 3+**  
   Training mode, competitive benchmarks, partner portal (see ROADMAP.md "Loveable Build Phases").

## 4. Backend / Firebolt Connection

- The **frontend** needs an API that executes SQL and returns results + metrics (execution time, rows read, etc.).
- **Options:**  
  - **A)** You build a small backend (Node or Python) that uses the Firebolt SDK/REST API, and the app calls your backend.  
  - **B)** You use a serverless API (e.g. Vercel/Netlify function) that wraps Firebolt.  
- **Data contracts** for requests/responses: see **docs/DATA_CONTRACTS.md** (e.g. `ExecuteSQLRequest`, `ExecuteSQLResponse`, `QueryMetrics`).
- **Auth:** For Firebolt Cloud, credentials (client ID, secret, account, engine) are entered in the setup wizard and sent to your backend only; never store them in the frontend.

## 5. Verticals and Features (data-driven)

- Use **docs/app-manifest.json** for the list of verticals and their features.
- Each vertical has: `id`, `name`, `description`, `dataset`, `database`, `features[]`.
- Each feature has: `id`, `name`, `description`, `status` (`available` | `coming_soon`). This drives the vertical overview and feature demo list.

## 6. Design Rules (from KNOWLEDGE.md)

- **Flat colors only** – no gradients, no drop shadows.
- **Metrics are hero** – large numbers (Poppins 48px), improvement in green (#22C55E), percentages with ↑/↓.
- **Before/After** – side-by-side cards: Baseline (no feature) vs Optimized (with feature).
- **Accessibility** – keyboard navigation, ARIA labels, contrast (e.g. Firebolt Red focus).

## 7. Starter Prompts for Loveable

Copy-paste these to build incrementally:

1. "Using KNOWLEDGE.md and docs/APP_SPEC.md, create the home page with runtime selection (Core vs Cloud) and vertical selection grid. Use docs/app-manifest.json for the list of verticals. Apply Firebolt design system: #F72A30 primary, Poppins headings, Inter body."
2. "Add the connection setup wizard (multi-step). Steps: (1) Confirm runtime, (2) Connection details – Core: host/port, Cloud: client ID, secret, account, engine, (3) Test connection, (4) Database setup. Use docs/USER_FLOWS.md for flow."
3. "Build the Feature Demo Runner page: two cards (Baseline vs Optimized), each with Query Time, Rows Scanned, Bytes Read and improvement %. Add SQL viewer and Run Baseline / Run Optimized buttons. Use docs/DATA_CONTRACTS.md for BenchmarkResult and QueryMetrics."
4. "Add the SQL Playground page: editor (dark theme #1A0404, Roboto Mono), Run button, results table, execution time, schema browser. Use DATA_CONTRACTS for QueryResult and EditorState."

## 8. File Reference

```
plg-ide/
├── KNOWLEDGE.md              ← Primary context (vision, design, features)
├── README.md                  ← User-facing getting started
├── ROADMAP.md                 ← Loveable build phases (L1–L5), starter prompts
├── docs/
│   ├── LOVEABLE.md            ← This file (entry point for Loveable)
│   ├── APP_SPEC.md            ← Pages, layouts, components
│   ├── DATA_CONTRACTS.md      ← TypeScript interfaces
│   ├── USER_FLOWS.md          ← User journeys
│   └── app-manifest.json      ← Verticals + features (data for app)
└── verticals/                 ← SQL demos (schema, data, benchmarks)
    ├── gaming/
    ├── ecommerce/
    ├── adtech/
    ├── observability/
    └── financial/
```

---

**Summary:** The repo is well structured for Loveable. Give Loveable **KNOWLEDGE.md**, **docs/APP_SPEC.md**, **docs/DATA_CONTRACTS.md**, **docs/USER_FLOWS.md**, and **docs/app-manifest.json**, and point it to **docs/LOVEABLE.md** as the entry point. Use the build order and starter prompts above for incremental delivery.
