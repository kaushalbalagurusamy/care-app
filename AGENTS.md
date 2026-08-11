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

## 4. Model Context Protocol (MCP) Servers ([`.mcp.json`](file:///.mcp.json))

This project is configured with active MCP servers for agentic build automation and simulator inspection:
* **`XcodeBuildMCP`**: Build, test, and manage Xcode projects natively via MCP.
* **`swift-mcp`**: Swift toolchain diagnostics, index queries, and code analysis.
* **`DesktopCommander`**: OS-level terminal execution and UI state monitoring.

---

## 5. Architectural Decision Records (ADRs)

Refer to the [`docs/adr/`](file:///docs/adr/) folder for all binding design choices:
* [`docs/adr/0001-monorepo-dual-stack-structure.md`](file:///docs/adr/0001-monorepo-dual-stack-structure.md) — Dual-stack iOS + Python monorepo design
* [`docs/adr/0002-fastapi-nemoguardrails-vector-backend.md`](file:///docs/adr/0002-fastapi-nemoguardrails-vector-backend.md) — Async FastAPI + NeMo Guardrails + pgvector architecture
* [`docs/adr/0003-native-swiftui-mobile-client.md`](file:///docs/adr/0003-native-swiftui-mobile-client.md) — Native SwiftUI mobile client architecture
* [`docs/adr/0004-mcp-integration-and-agentic-workflows.md`](file:///docs/adr/0004-mcp-integration-and-agentic-workflows.md) — Model Context Protocol toolchain integration

---

## 6. Guidelines for AI Agents

1. **Figma Porting Readiness**: `ios/CAREApp/ContentView.swift` is stripped of filler components and prepared to receive design system components from Figma specs.
2. **Preserve Monorepo Integrity**: Do not create auxiliary files outside `ios/`, `backend/`, `docs/`, or `.mcp.json`.
3. **Dependency Management**: Use `uv` for Python packages inside `backend/` and keep `requirements.txt` updated.
