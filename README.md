# CARE App — Relational Neuroscience & AI Architecture

CARE App is a dual-stack mobile and AI platform developed for **Dr. Amy Banks, MD** (author of *Wired to Connect* and pioneer of Relational-Cultural Theory relational neuroscience) and engineered for the **Relational-Cultural Theory (RCT) 50th Anniversary Conference** in October.

The platform integrates the **C.A.R.E.** neurological framework (**C**alm - Smart Vagus Nerve, **A**ccept - Dorsal Anterior Cingulate Cortex, **R**esonate - Mirror Neuron System, **E**nergize - Dopamine Reward Pathway) within a 100% native iOS/iPadOS SwiftUI application paired with an asynchronous Python FastAPI backend powered by Nvidia NeMo Guardrails, PostgreSQL `pgvector`, and Google Gemini.

---

## Repository Architecture

```
care-app/
├── ios/                      # Native Swift 5.10+ / SwiftUI Xcode Project (iOS 17+)
│   ├── CAREApp/              # Application source files (CAREApp.swift, ContentView.swift)
│   └── CAREApp.xcodeproj/    # Xcode project workspace configuration
├── backend/                  # Asynchronous Python FastAPI + NeMo Guardrails + pgvector
│   ├── main.py               # Core ASGI application entrypoint & health endpoints
│   ├── requirements.txt      # Python dependencies (fastapi, uvicorn, asyncpg, pgvector, etc.)
│   └── venv/                 # Python 3.13 virtual environment (managed by uv)
├── docs/                     # System architecture & decision records
│   ├── ARCHITECTURE.md       # High-level architecture overview & data flow
│   └── adr/                  # Architectural Decision Records (ADRs 0001 - 0008)
├── .mcp.json                 # Project-level Model Context Protocol (MCP) configuration
└── AGENTS.md                 # Single source of truth for AI agents operating in workspace
```

---

## Architecture & Data Flow

```
+-------------------------------------------------------------------------+
|                         Native Apple Client                             |
|              (Swift 5.10+ / SwiftUI / iOS 17+ & iPadOS 17+)             |
|                                                                         |
|  +------------------------+   +-------------------+  +---------------+  |
|  | Figma Design Components|   | URLSession Async  |  | VoiceOver A11y|  |
|  +------------------------+   +---------+---------+  +---------------+  |
+-----------------------------------------|-------------------------------+
                                          |
                                HTTP / REST / Async
                                          |
+-----------------------------------------v-------------------------------+
|                       FastAPI Asynchronous Backend                      |
|                     (Python 3.13 / Uvicorn ASGI Server)                 |
|                                                                         |
|  +-------------------------------------------------------------------+  |
|  |                     FastAPI API Router & Endpoints                |  |
|  +-----------------------------------+-------------------------------+  |
|                                      |                                  |
|            +-------------------------v--------------------------+       |
|            |      Nvidia NeMo Guardrails Safety & Alignment     |       |
|            +-------------------------+--------------------------+       |
|                                      |                                  |
|            +-------------------------+--------------------------+       |
|            |                 Google GenAI Gateway               |       |
|            |                 (Gemini Model SDK)                 |       |
|            +----------------------------------------------------+       |
+--------------------------------------|----------------------------------+
                                       |
                     +-----------------v-----------------+
                     |    PostgreSQL 16 + pgvector       |
                     |  (Relational Data & Embeddings)   |
                     +-----------------------------------+
```

---

## Tech Stack Overview

| Component | Framework / Tool | Description |
| :--- | :--- | :--- |
| **Mobile Client** | Swift 5.10+ / SwiftUI (iOS 17+) | 100% native iOS/iPadOS application optimized for fluid rendering, biometric security, and accessibility |
| **Backend API** | Python 3.13 / FastAPI / Uvicorn | High-speed ASGI asynchronous REST API server |
| **AI Safety** | Nvidia NeMo Guardrails | Programmable guardrails for LLM safety, alignment, and hallucination checks |
| **Vector DB** | PostgreSQL 16 + `pgvector` | Native vector similarity search for semantic embeddings and RAG context |
| **LLM Gateway** | Google GenAI SDK | Gemini model integration for intelligent agent workflows |
| **DevOps / Agentic** | MCP Servers & Workflows | Automated Xcode compilation, network proxying, and code quality audits |

---

## Getting Started

### Prerequisites

* **macOS** with **Xcode 16+**
* **Python 3.13+** (managed via `uv`)
* **Node.js v20+** / `npx`
* **PostgreSQL 16** with `pgvector` extension

### 1. Running the FastAPI Backend

```bash
cd backend
source venv/bin/activate
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

Health Check: `curl http://localhost:8000/health`

### 2. Building & Launching the Native iOS Client

```bash
# Build iOS Simulator target
xcodebuild -project ios/CAREApp.xcodeproj -scheme CAREApp -destination 'generic/platform=iOS Simulator' build

# Boot simulator and launch app
xcrun simctl boot "iPhone 16 Pro"
open -a Simulator
xcrun simctl launch booted com.careapp.CAREApp
```

---

## Technical Documentation & ADRs

All architectural choices are recorded in [`docs/adr/`](docs/adr/):

* [`docs/adr/0001-monorepo-dual-stack-structure.md`](docs/adr/0001-monorepo-dual-stack-structure.md) — Dual-stack iOS + Python monorepo design
* [`docs/adr/0002-fastapi-nemoguardrails-vector-backend.md`](docs/adr/0002-fastapi-nemoguardrails-vector-backend.md) — Async FastAPI + NeMo Guardrails + pgvector architecture
* [`docs/adr/0003-native-swiftui-mobile-client.md`](docs/adr/0003-native-swiftui-mobile-client.md) — Native SwiftUI mobile client architecture
* [`docs/adr/0004-mcp-integration-and-agentic-workflows.md`](docs/adr/0004-mcp-integration-and-agentic-workflows.md) — Model Context Protocol toolchain integration
* [`docs/adr/0005-figma-design-system-frontend-import.md`](docs/adr/0005-figma-design-system-frontend-import.md) — Figma design system to native SwiftUI import architecture
* [`docs/adr/0006-autonomous-observability-governance-and-tdd-loop.md`](docs/adr/0006-autonomous-observability-governance-and-tdd-loop.md) — Autonomous Execution Governance, Observability & TDD Loop
* [`docs/adr/0007-user-accounts-auth-and-cloud-persistence.md`](docs/adr/0007-user-accounts-auth-and-cloud-persistence.md) — User Accounts, Auth & Cloud Persistence
* [`docs/adr/0008-biometric-auth-and-app-lock.md`](docs/adr/0008-biometric-auth-and-app-lock.md) — Biometric Authentication & App Lock
* [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — System architecture diagram and end-to-end data flow

---

## License

Distributed under the MIT License. See [LICENSE](LICENSE) for details.
