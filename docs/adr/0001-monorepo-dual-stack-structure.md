# ADR 0001: Monorepo Dual-Stack Architecture

* **Status**: Accepted
* **Date**: 2026-08-11
* **Deciders**: Lead AI Systems Architect & Mobile/Backend Engineering Team

## Context

The CARE App requires tight integration between a high-performance native iOS/iPadOS client and an AI-driven backend powered by FastAPI, NeMo Guardrails, vector search (`pgvector`), and Gemini model pipelines. Managing separate repositories introduces versioning drift, disjointed API contracts, and fragmented context for AI coding agents.

## Decision

We adopt a unified single-repository monorepo structure:
- `ios/`: Swift/SwiftUI application project code and assets.
- `backend/`: Python FastAPI application, virtual environment, and AI guardrails.
- `docs/`: Technical specifications, ADRs, and Figma design token handoffs.
- `.mcp.json`: Repository-root Model Context Protocol tools configuration.

## Consequences

* **Pros**: Single git history, synchronized frontend-backend PRs, zero-drift AI agent context.
* **Cons**: Larger repository checkout size (mitigated by proper `.gitignore` configuration for `venv/` and `DerivedData/`).
