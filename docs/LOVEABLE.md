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
| **Confirm target before writes** | Get user feedback and validation of the **account, engine, and database** that the demo will write to (or create). Show a confirmation step that displays these values; do not create, overwrite, or load data until the user explicitly confirms. See **docs/USER_FLOWS.md** (principle "Confirm Target Before Any Writes") and **docs/APP_SPEC.md** (Setup Wizard Step 4). |

**Summary for Loveable:** Build the app so that **every metric and every result** comes from a real Firebolt session. Guide users through **Firebolt Core** (localhost, no account) or **Firebolt Cloud** (credentials) until connection succeeds; only then allow demos and SQL execution. **Before any write** (create database, load data, run demos that write): show account/engine/database and get explicit user confirmation—never change or overwrite anything without that validation.

**When starting a Loveable session with this repo:** Tell Loveable to read **docs/LOVEABLE.md** first (this file), then **docs/PLAN_AND_GOVERNANCE.md** (strict plan—adhere, do not overwrite), then **KNOWLEDGE.md**, **docs/APP_SPEC.md**, **docs/DATA_CONTRACTS.md**, **docs/USER_FLOWS.md**, and **docs/app-manifest.json**. Emphasize: "Do not implement dummy or mock Firebolt—require real connectivity and confirm target (account, engine, database) before any write. New capabilities must follow the plan in PLAN_AND_GOVERNANCE.md."

---

## 1. What to Read First (in order)

| Order | File | Why |
|-------|------|-----|
| 1 | **docs/PLAN_AND_GOVERNANCE.md** | Strict plan: connectivity, confirm target before writes, demo pattern (impact first, comments, progress). New capabilities must adhere; do not overwrite. |
| 2 | **KNOWLEDGE.md** (repo root) | Product vision, design system (colors, typography, components), core features, technical constraints, UI guidelines |
| 3 | **docs/APP_SPEC.md** | Page structure (routes), layout of every page, component list, responsive breakpoints |
| 4 | **docs/DATA_CONTRACTS.md** | TypeScript interfaces for runtime, verticals, benchmarks, SQL playground, API requests/responses |
| 5 | **docs/USER_FLOWS.md** | Step-by-step user journeys (setup, run demo, load data, playground, errors) |
| 6 | **docs/app-manifest.json** | Data-driven list of verticals and features (use for navigation and demo selection) |

## 2. What You Are Building

- **Product:** plg-ide – a web app that lets users connect to Firebolt (Core or Cloud), pick an industry vertical (Gaming, E-commerce, AdTech, Observability, Financial, CyberTech), run feature demos (e.g. Aggregating Indexes), and see **before/after benchmark metrics** (query time, rows scanned, bytes read).
- **Users:** Sales engineers (demos), developers (evaluation), partners (training).
- **Principle:** Every demo shows measurable improvement (e.g. "50–100X faster with aggregating indexes").

### Experience parity with the IDE

The Loveable app **must offer the same conceptual steps** as the IDE-guided experience, so users get a consistent exploratory flow in either channel:

1. **Connection** – Select runtime (Core or Cloud), enter connection details, test connection.
2. **Confirm target** – Show account (or host), engine, and database; get explicit user confirmation before any create or write.
3. **Vertical selection** – User chooses an industry vertical from the manifest (e.g. Gaming, E-commerce).
4. **Feature selection** – User chooses a feature demo for that vertical (e.g. Aggregating Indexes).
5. **Run SQL and show metrics** – Run baseline and optimized queries; display real metrics (query time, rows scanned, bytes read) and improvement.
6. **Explain** – Surface brief explanation of what the feature does and why it is differentiating (e.g. links to further reading from the manifest).

Do not add flows that skip target confirmation, use mock data, or reorder these steps in a way that diverges from the IDE experience.

**Shareable feature-first links:** The app supports deep links so users can land directly on one feature. Use the URL `/demo/<vertical_id>/<feature_id>` (e.g. `/demo/gaming/automated_column_statistics`). If the user is not yet connected, complete the Setup Wizard then redirect to this URL. Optionally support `?feature=<id>` and `?vertical=<id>` on the home page and redirect to the corresponding `/demo/:vertical/:feature`. See **docs/APP_SPEC.md** (§ Deep links) and **docs/USER_FLOWS.md** (Flow 2b).

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
- Each vertical has: `id`, `name`, `description`, `dataset`, `database`, `furtherReading[]`, `features[]`.
- Each vertical's **furtherReading** is an array of `{ "label": "...", "url": "..." }` — engineering blogs and Firebolt docs. **Display these alongside the demo** on the Vertical Overview page and on the Feature Demo Runner page so users can click through to "learn more" after running a demo. See **docs/APP_SPEC.md** (Further reading block).
- Each feature has: `id`, `name`, `description`, `status` (`available` | `coming_soon`). This drives the vertical overview and feature demo list.

## 6. Design Rules (from KNOWLEDGE.md)

- **Flat colors only** – no gradients, no drop shadows.
- **Metrics are hero** – large numbers (Poppins 48px), improvement in green (#22C55E), percentages with ↑/↓.
- **Before/After** – side-by-side cards: Baseline (no feature) vs Optimized (with feature).
- **Accessibility** – keyboard navigation, ARIA labels, contrast (e.g. Firebolt Red focus).

## 7. Starter Prompts for Loveable

Copy-paste these to build incrementally. **Remember: no dummy/mock Firebolt—all execution and metrics must use a real connection (see Connectivity Rules above).**

1. "Using KNOWLEDGE.md and docs/APP_SPEC.md, create the home page with runtime selection (Core vs Cloud) and vertical selection grid. Use docs/app-manifest.json for the list of verticals. Apply Firebolt design system: #F72A30 primary, Poppins headings, Inter body. Do not add a 'try without connecting' or mock mode—users must choose Core or Cloud and complete setup."
2. "Add the connection setup wizard (multi-step). Steps: (1) Confirm runtime (Core or Cloud), (2) Connection details – Core: host URL (e.g. localhost:3473), Cloud: client ID, secret, account, engine, (3) Test connection (real call to Firebolt—no stub), (4) **Confirm target** – show account (or host), engine, and database that demos will use; require user to confirm or change before any create/write; (5) Database setup (create or select). Use docs/USER_FLOWS.md and docs/APP_SPEC.md. Do not create or overwrite anything without user validation of the target."
3. "Build the Feature Demo Runner page: two cards (Baseline vs Optimized), each with Query Time, Rows Scanned, Bytes Read and improvement %. Add SQL viewer and Run Baseline / Run Optimized buttons. Use docs/DATA_CONTRACTS.md for BenchmarkResult and QueryMetrics. Require an established Firebolt connection before allowing Run; metrics must come from real query execution, not mocks."
4. "Add the SQL Playground page: editor (dark theme #1A0404, Roboto Mono), Run button, results table, execution time, schema browser. Use DATA_CONTRACTS for QueryResult and EditorState. Run must call the real backend/Firebolt; disable Run or show 'Connect first' until connection is successful."

## 8. File Reference

```
plg-ide/
├── KNOWLEDGE.md                  ← Primary context (vision, design, features)
├── README.md                     ← User-facing getting started
├── ROADMAP.md                    ← Loveable build phases (L1–L5), starter prompts
├── docs/
│   ├── LOVEABLE.md               ← This file (entry point for Loveable)
│   ├── PLAN_AND_GOVERNANCE.md     ← Strict plan: adhere when adding demos/app flows; do not overwrite
│   ├── APP_SPEC.md                ← Pages, layouts, components
│   ├── DATA_CONTRACTS.md          ← TypeScript interfaces
│   ├── USER_FLOWS.md              ← User journeys
│   └── app-manifest.json          ← Verticals + features (data for app)
└── verticals/                    ← SQL demos (schema, data, benchmarks)
    ├── gaming/
    ├── ecommerce/
    ├── adtech/
    ├── observability/
    ├── financial/
    └── cybertech/                ← placeholder (data and capabilities TBD)
```

---

**Summary:** The repo is well structured for Loveable. Give Loveable **docs/PLAN_AND_GOVERNANCE.md** first (strict plan), then **KNOWLEDGE.md**, **docs/APP_SPEC.md**, **docs/DATA_CONTRACTS.md**, **docs/USER_FLOWS.md**, and **docs/app-manifest.json**; use **docs/LOVEABLE.md** as the entry point. New capabilities must adhere to the plan—real connectivity, confirm target before writes, impact-first demo pattern—and must not overwrite it with a different approach. Use the build order and starter prompts above for incremental delivery.
