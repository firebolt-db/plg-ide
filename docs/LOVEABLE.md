# Building the plg-ide Web App with Loveable

> **Use this repo as context for Loveable to build the plg-ide web application.**  
> Read the files below in order. The app is a Product-Led Growth demo platform for Firebolt.

---

## ⚠️ Connectivity Rules (MANDATORY – read first)

**Do not implement dummy, mock, or fake Firebolt behavior.**  
All demos and SQL execution must use a **real** connection to Firebolt (Core or Cloud). The app must guide users to set up that connection; it must not offer a "try without connecting" or "demo with sample data" mode that bypasses Firebolt.

| Rule | Meaning |
|------|--------|
| **No dummy calls** | Do not stub or mock the Firebolt/SQL API. Every "Run" or "Execute" must call a real backend that talks to Firebolt. |
| **No fake metrics** | Query time, rows scanned, bytes read must come from real query execution. No hardcoded or random numbers. |
| **Connection required** | Before running any demo or playground query, the app must require a successful connection (Core or Cloud). If not connected, show the setup flow—do not fall back to fake data. |
| **Guide to setup** | The primary path is: **help the user connect** (Firebolt Core local or Firebolt Cloud). Use the Connection Setup Wizard (`/setup`) and clear copy for Core vs Cloud (e.g. "No account? Start with Firebolt Core (free, local)."). See **docs/USER_FLOWS.md** for Flow 1 and Flow 1b. |
| **Errors are real** | If connection or query fails, show the real error and recovery options (retry, fix credentials, switch to Core), not a generic "demo mode" result. |

**Summary for Loveable:** Build the app so that **every metric and every result** comes from a real Firebolt session. Guide users through **Firebolt Core** (localhost, no account) or **Firebolt Cloud** (credentials) until connection succeeds; only then allow demos and SQL execution.

**When starting a Loveable session with this repo:** Tell Loveable to read **docs/LOVEABLE.md** first (this file), then **KNOWLEDGE.md**, **docs/APP_SPEC.md**, **docs/DATA_CONTRACTS.md**, **docs/USER_FLOWS.md**, and **docs/app-manifest.json**. Emphasize: "Do not implement dummy or mock Firebolt—require real connectivity (Firebolt Core or Cloud) and guide the user through the connection setup before any demo or SQL execution."

---

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

## 4. Backend / Firebolt Connection (real connectivity only)

- The **frontend** must call a **real** backend that connects to Firebolt (Core or Cloud). No mock or dummy implementation of SQL execution.
- **Backend options:**  
  - **A)** Small backend (Node or Python) using the Firebolt SDK/REST API; app calls this backend for all SQL and connection tests.  
  - **B)** Serverless API (e.g. Vercel/Netlify function) that wraps Firebolt.  
- **Connection parameters:**  
  - **Firebolt Core (local):** host (e.g. `http://localhost:3473`), no client ID/secret.  
  - **Firebolt Cloud:** client ID, client secret, account name, engine/database (and optionally database name).  
- **Flow:** User completes Setup Wizard → Test Connection (real check against Firebolt) → only when successful, enable "Run Demo" / "Run Query". If Test Connection fails, show error and help (e.g. "Switch to Firebolt Core" or fix credentials); do not offer a fallback that skips connection.
- **Data contracts:** see **docs/DATA_CONTRACTS.md** (`ExecuteSQLRequest`, `ExecuteSQLResponse`, `QueryMetrics`). All metrics must come from actual execution.
- **Auth:** Cloud credentials are entered in the setup wizard and sent to the backend only; never store them in the frontend or in client-side code.

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

Copy-paste these to build incrementally. **Remember: no dummy/mock Firebolt—all execution and metrics must use a real connection (see Connectivity Rules above).**

1. "Using KNOWLEDGE.md and docs/APP_SPEC.md, create the home page with runtime selection (Core vs Cloud) and vertical selection grid. Use docs/app-manifest.json for the list of verticals. Apply Firebolt design system: #F72A30 primary, Poppins headings, Inter body. Do not add a 'try without connecting' or mock mode—users must choose Core or Cloud and complete setup."
2. "Add the connection setup wizard (multi-step). Steps: (1) Confirm runtime (Core or Cloud), (2) Connection details – Core: host URL (e.g. localhost:3473), Cloud: client ID, secret, account, engine, (3) Test connection (real call to Firebolt—no stub), (4) Database setup. Use docs/USER_FLOWS.md. If connection fails, show the error and offer 'Switch to Firebolt Core' or fix credentials; never fall back to fake data."
3. "Build the Feature Demo Runner page: two cards (Baseline vs Optimized), each with Query Time, Rows Scanned, Bytes Read and improvement %. Add SQL viewer and Run Baseline / Run Optimized buttons. Use docs/DATA_CONTRACTS.md for BenchmarkResult and QueryMetrics. Require an established Firebolt connection before allowing Run; metrics must come from real query execution, not mocks."
4. "Add the SQL Playground page: editor (dark theme #1A0404, Roboto Mono), Run button, results table, execution time, schema browser. Use DATA_CONTRACTS for QueryResult and EditorState. Run must call the real backend/Firebolt; disable Run or show 'Connect first' until connection is successful."

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
