# CARE App — AI Systems & Engineering Agent Specifications

Welcome to the **CARE App** dual-stack monorepo (`native iOS/iPadOS` + `Python FastAPI` backend). This document serves as the single source of truth for AI agents operating in this workspace.

---

## 1. Monorepo Architecture

```
care-app/
├── ios/                      # Native Swift & SwiftUI Xcode Project Space
│   ├── CAREApp/              # App source files (CAREApp.swift, ContentView.swift, Assets)
│   └── CAREApp.xcodeproj/    # iOS 17+ Xcode project configuration
├── backend/                  # Python FastAPI + NeMo Guardrails + pgvector
│   ├── main.py               # Core API application entrypoint & health endpoints
│   ├── requirements.txt      # Dependencies (fastapi, uvicorn, asyncpg, pgvector, google-genai, nemoguardrails)
│   └── venv/                 # Python 3.13 virtual environment (managed by `uv`)
├── docs/                     # System architecture & Figma design token handoffs
│   └── adr/                  # Architectural Decision Records (ADRs)
└── .mcp.json                 # Model Context Protocol (MCP) server integration config
```

---

## 2. Environment Toolchains

* **Xcode**: Xcode 26.6 (Build 17F113) at `/Applications/Xcode.app`
* **Python**: Python 3.13.12 (managed via `uv` virtualenv at `backend/venv`)
* **Database**: `postgresql@16` (Homebrew cellar) with `pgvector` support
* **Node.js**: v20.20.0 (used for npx MCP tools)

---

## 3. Local Development Commands

### Backend Server
```bash
cd backend
source venv/bin/activate
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```
Health Check: `curl http://localhost:8000/health`

### Native iOS App
```bash
# Build target for simulator
xcodebuild -project ios/CAREApp.xcodeproj -scheme CAREApp -destination 'generic/platform=iOS Simulator' build

# Boot simulator and launch app
xcrun simctl boot "iPhone 16 Pro"
open -a Simulator
xcrun simctl install booted <path-to-CAREApp.app>
xcrun simctl launch booted com.careapp.CAREApp
```

---

## 4. Model Context Protocol (MCP) Servers & Skills ([`.mcp.json`](file:///.mcp.json) & `~/.gemini/mcp.json`)

This project is configured with active MCP servers and staged skills for agentic build automation, testing, and code quality audits:
* **`XcodeBuildMCP`**: Build, test, and manage Xcode projects natively via MCP.
* **`swift-mcp`**: Swift toolchain diagnostics, index queries, and code analysis.
* **`DesktopCommander`**: OS-level terminal execution and UI state monitoring.
* **`tokrepo`**: Registry management and fetching of specialized iOS development skills.
* **`context7`**: Documentation indexing and real-time framework reference lookup.
* **`proxyman`**: Live HTTP/HTTPS network traffic inspection and mock response verification.
* **`mobile-mcp`**: Mobile client UI automation and device/simulator testing.
* **`github`**: GitHub API operations, PR management, and code review workflows.
* **`figma`**: Direct extraction of design tokens, layout variables, and component hierarchies for SwiftUI code generation.
* **`git`**: Programmatic version control, atomic checkpointing, and hard rollback execution.
* **iOS Skills Staged**: Guidelines and modules for SwiftUI, Swift 6 Concurrency, Swift Testing, HIG, and Accessibility staged at `~/.gemini/skills/ios-development/`.

---

## 5. Architectural Decision Records (ADRs)

Refer to the [`docs/adr/`](file:///docs/adr/) folder for all binding design choices:
* [`docs/adr/0001-monorepo-dual-stack-structure.md`](file:///docs/adr/0001-monorepo-dual-stack-structure.md) — Dual-stack iOS + Python monorepo design
* [`docs/adr/0002-fastapi-nemoguardrails-vector-backend.md`](file:///docs/adr/0002-fastapi-nemoguardrails-vector-backend.md) — Async FastAPI + NeMo Guardrails + pgvector architecture
* [`docs/adr/0003-native-swiftui-mobile-client.md`](file:///docs/adr/0003-native-swiftui-mobile-client.md) — Native SwiftUI mobile client architecture
* [`docs/adr/0004-mcp-integration-and-agentic-workflows.md`](file:///docs/adr/0004-mcp-integration-and-agentic-workflows.md) — Model Context Protocol toolchain integration
* [`docs/adr/0005-figma-design-system-frontend-import.md`](file:///docs/adr/0005-figma-design-system-frontend-import.md) — Figma design system to native SwiftUI import architecture
  * [`0005-phase-1-design-tokens-and-assets.md`](file:///docs/adr/0005-figma-frontend-import/0005-phase-1-design-tokens-and-assets.md) — Phase 1: Design Tokens & Asset Extraction
  * [`0005-phase-2-domain-models-and-navigation.md`](file:///docs/adr/0005-figma-frontend-import/0005-phase-2-domain-models-and-navigation.md) — Phase 2: Domain Data Models & Navigation State
  * [`0005-phase-3-reusable-atomic-components.md`](file:///docs/adr/0005-figma-frontend-import/0005-phase-3-reusable-atomic-components.md) — Phase 3: Reusable Atomic UI Components
  * [`0005-phase-4-screen-views-implementation.md`](file:///docs/adr/0005-figma-frontend-import/0005-phase-4-screen-views-implementation.md) — Phase 4: Screen Views Implementation (10 Frames)
  * [`0005-phase-5-navigation-wiring-and-audit.md`](file:///docs/adr/0005-figma-frontend-import/0005-phase-5-navigation-wiring-and-audit.md) — Phase 5: Navigation Wiring, Testing & A11y Audit
* [`docs/adr/0006-autonomous-observability-governance-and-tdd-loop.md`](file:///docs/adr/0006-autonomous-observability-governance-and-tdd-loop.md) — Autonomous Execution Governance, Observability & TDD Loop
* [`docs/adr/0007-user-accounts-auth-and-cloud-persistence.md`](file:///docs/adr/0007-user-accounts-auth-and-cloud-persistence.md) — Local-First Encrypted Storage, iCloud Sync & Notification Architecture

---

## 6. Guidelines for AI Agents

1. **Figma Porting Readiness**: `ios/CAREApp/ContentView.swift` is stripped of filler components and prepared to receive design system components from Figma specs.
2. **Preserve Monorepo Integrity**: Do not create auxiliary files outside `ios/`, `backend/`, `docs/`, or `.mcp.json`.
3. **Dependency Management**: Use `uv` for Python packages inside `backend/` and keep `requirements.txt` updated.
