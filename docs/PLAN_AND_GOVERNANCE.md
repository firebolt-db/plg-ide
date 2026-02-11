# plg-ide: Plan and Governance

> **This plan is strict.** When adding new demo capabilities, verticals, or app flows, **adhere to this plan**. Do **not** overwrite or replace it with a different approach. Extend within these rules.

**Audience:** Cursor IDE sessions, Loveable builds, and anyone contributing to this repo. Read this file when adding or changing demos or app behavior.

---

## 1. Why This Document Exists

- **Consistency:** All demos and the app experience follow the same patterns so users get a predictable, safe experience.
- **Safety:** We never write to Firebolt without the user confirming the target (account, engine, database).
- **Clarity:** New capabilities (e.g. a new vertical or feature demo) must fit into the existing plan rather than introducing a new, conflicting pattern.

**Rule for contributors and AI sessions:** Before adding a new demo capability or changing setup/demo flow, read this document and the referenced specs. New work must **conform to** this plan; it must **not** replace it.

---

## 2. Non-Negotiable Plan (Do Not Override)

### 2.1 Connectivity (No Dummy/Mock)

- **All** SQL execution and demo metrics use a **real** connection to Firebolt (Core or Cloud). No stubs, mocks, or fake data for "try without connecting."
- The app must **guide** users to set up Firebolt Core (local) or Firebolt Cloud (credentials). Connection is required before any demo or playground run.
- **Reference:** docs/LOVEABLE.md (§ Connectivity Rules), docs/APP_SPEC.md (Setup Wizard).

### 2.2 Confirm Target Before Any Write

- **Never** create, overwrite, or load data into a database without the user having **seen and confirmed** the exact target: account (or host), engine, and database.
- The app must show a **confirmation step** that displays these values and require explicit user validation (e.g. "I confirm" / "Use this target") before any create database, create tables, or load data action. User must be able to go back and change engine/database before confirming.
- **Reference:** docs/USER_FLOWS.md (principle "Confirm Target Before Any Writes"), docs/APP_SPEC.md (Setup Wizard Step 4).

### 2.3 Demo Script Pattern (Impact First + Comments + Progress)

Every vertical's **comparison demo** (e.g. `demo_comparison.sql`) must:

1. **Impact first:** Show the fast query first (with index/feature), then EXPLAIN, then drop/disable and show the slow query, then restore. Do **not** lead with "slow then fast" unless the plan is explicitly updated.
2. **Per-step comments:** Each runnable step has a clear comment (what this step does and what the user will see). Comments are generic (suitable for IDE or Loveable); no UI-specific "RUN THIS" wording.
3. **Progress tracking:** A `demo_progress` table (session_id, step_id, completed_at) is created in Setup. Before each runnable step, insert a row (e.g. `INSERT INTO demo_progress ... VALUES (SESSION_USER(), '1', NOW());`). Step IDs are consistent (e.g. '1'–'5'). This supports IDE or app progress display.
4. **Setup:** Create `demo_progress`, ensure the index/feature exists so the first query is fast, disable result cache. **Cleanup:** Re-enable result cache; optional completion message.

**Reference:** Existing `verticals/*/demo_comparison.sql` (gaming, ecommerce, adtech, observability, financial) are the canonical examples. CyberTech is a placeholder vertical (data and capabilities TBD); when implemented, it must follow the same pattern. New verticals or new comparison demos must follow the same structure.

### 2.4 App Setup Wizard (Steps and Order)

The connection/setup flow must include, in order:

1. Confirm runtime (Core or Cloud).
2. Connection details (Core: host; Cloud: client ID, secret, account, engine).
3. Test connection (real call to Firebolt; no fake success).
4. **Confirm target** (show account/host, engine, database; user confirms or changes).
5. Database setup (create or select existing).

Do not skip or reorder these. Do not add a "continue without confirming" path.

**Reference:** docs/APP_SPEC.md (Setup Wizard), docs/USER_FLOWS.md (Flow 1, Flow 1b).

### 2.5 IDE (Cursor): Check MCP Server and Offer Local Install

For users in Cursor (or other MCP-capable IDEs), the guided experience must:

1. **Check** whether the Firebolt MCP server is already running (e.g. configured in Cursor Settings → MCP).
2. **If not:** Ask and give the user the **option to install it locally** before runtime selection or demos. Offer:
   - **Docker (recommended):** image `ghcr.io/firebolt-db/mcp-server:0.6.0`; config provided after they choose runtime.
   - **Binary:** download from [Firebolt MCP Server Releases](https://github.com/firebolt-db/mcp-server/releases).
3. **Cursor:** Require `FIREBOLT_MCP_DISABLE_RESOURCES=true` in MCP server env (Cursor does not support MCP resources yet).

Do not assume MCP is already set up; check and offer install so users are not stuck.

**Reference:** [Firebolt MCP Server](https://github.com/firebolt-db/mcp-server), docs/USER_FLOWS.md (Flow 0), docs/MCP_SETUP.md, .cursor/rules/plg-ide.mdc.

---

## 3. Adding New Demo Capabilities

When you add a **new vertical**, **new feature demo**, or **new comparison script**:

| Requirement | Action |
|-------------|--------|
| New vertical | Add a `demo_comparison.sql` that follows §2.3 (impact first, comments, demo_progress). Reuse the same step IDs pattern (1–5) and Setup/Cleanup structure. |
| New feature (e.g. partitioning, late materialization) | If it has a before/after comparison, use the same pattern: impact first, per-step comments, demo_progress. Do not introduce a different flow (e.g. "slow first" or no progress table). |
| New app page or flow | Ensure it respects §2.1 (real connectivity) and §2.2 (confirm target before any write). Do not add a path that bypasses target confirmation. |
| Loveable / web app | Follow docs/LOVEABLE.md and docs/APP_SPEC.md. The plan in this file applies to the app as well; do not implement an alternative that drops connectivity rules or confirm-target. |

**Checklist before merging:** Does the new capability use real Firebolt only? Does it require user confirmation of account/engine/database before writes? If it's a comparison demo, does it use impact-first order, per-step comments, and demo_progress?

---

## 4. Where the Plan Is Defined (Single Source of Truth)

| Topic | Primary doc | Supporting |
|-------|------------|------------|
| Connectivity (no mock, guide to setup) | docs/LOVEABLE.md | docs/APP_SPEC.md |
| Confirm target before writes | docs/USER_FLOWS.md, docs/APP_SPEC.md | docs/LOVEABLE.md |
| Demo script pattern (impact first, comments, progress) | This file (§2.3), verticals/*/demo_comparison.sql | — |
| Setup wizard steps | docs/APP_SPEC.md, docs/USER_FLOWS.md | This file (§2.4) |

**Do not** create a second, conflicting specification (e.g. a new "Demo Standard" that says "slow first" or "no progress table"). Update this document and the referenced docs if the plan evolves; do not overwrite them with an unrelated design.

---

## 5. For Cursor IDE Sessions (Run by Anyone)

If you are an AI assistant in Cursor working in this repo:

1. **Read this file** when the user asks to add a new demo, new vertical, or change how demos or setup work.
2. **Apply §2 and §3.** New comparison demos must use impact first + per-step comments + demo_progress. New app/setup behavior must require real connectivity and confirm-target before writes.
3. **Do not suggest or implement** a flow that skips target confirmation, uses mock Firebolt, or changes the demo order to "slow first" without updating this plan first.
4. **If the user requests something that conflicts with this plan,** point them to this document and ask whether they want to (a) adapt the request to the plan, or (b) update the plan (this file and related docs) first, then implement.

---

## 6. For Loveable Builds

When building the plg-ide web app from this repo, use **docs/LOVEABLE.md** as the entry point. The rules in docs/LOVEABLE.md (connectivity, confirm target) and in **this file** are part of the product specification. The app must not implement dummy connectivity or skip target confirmation; new pages or flows must adhere to §2.1 and §2.2.

---

*Last updated: 2025. This plan is intended to be stable; changes should be explicit and documented here.*
