# CARE App — System Architecture & Data Flow

This document details the system architecture, component responsibilities, and data flow across the **CARE App** monorepo.

---

## 1. High-Level Architecture Diagram

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

## 2. Layer Responsibilities

### A. Mobile Client Layer (`ios/CAREApp`)
* **Declarative UI**: Built with pure SwiftUI views. Components directly consume Figma design system tokens.
* **State Management**: Uses Swift 6 `@Observable` macro and `@State` property wrappers for reactive state flow without memory leaks or unnecessary view re-renders.
* **Networking**: Encapsulated async networking services using native `URLSession` communicating with the FastAPI backend.

### B. Async Backend API Layer (`backend/main.py`)
* **FastAPI Router**: Asynchronous endpoints serving requests with sub-millisecond overhead.
* **NeMo Guardrails Safety Layer**: Intercepts input prompts and output responses to ensure factual compliance, user privacy, and domain-specific safety rules.
* **Vector Store & Database Integration**: Connects to PostgreSQL using `asyncpg` for non-blocking database queries and `pgvector` for similarity search on embedded context.
* **Generative AI Pipeline**: Interfaces with Gemini models using `google-genai` to generate contextual responses.

### C. Agentic DevOps Integration (`.mcp.json` & `~/.gemini/mcp.json`)
* **XcodeBuildMCP**: Enables programmatic compilation, test execution, and simulator management.
* **Proxyman MCP**: Intercepts and inspects live HTTP/HTTPS traffic between the iOS app and backend for instant API debugging.
* **TokRepo Skills**: Provides automated code reviews, HIG design auditing, and Swift 6 concurrency compliance checks.

---

## 3. Architectural Decision Records (ADRs)

Key architectural decisions are documented in [`docs/adr/`](file:///docs/adr/):
* **ADR 0001**: Monorepo Dual-Stack Structure (`native iOS` + `FastAPI backend`)
* **ADR 0002**: FastAPI + NeMo Guardrails + pgvector Backend Architecture
* **ADR 0003**: Native SwiftUI Mobile Client Architecture
* **ADR 0004**: MCP Integration & Agentic Workflows
* **ADR 0005**: Figma Design System to Native SwiftUI Import (Phases 1–5)
* **ADR 0006**: Autonomous Observability Governance & TDD Loop
* **ADR 0007**: Local-First Encrypted Storage, iCloud Sync & Notification Architecture
* **ADR 0008**: Biometric Authentication (Face ID / Touch ID) & App Lock Architecture

