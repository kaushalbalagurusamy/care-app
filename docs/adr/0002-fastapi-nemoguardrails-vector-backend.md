# ADR 0002: FastAPI + NeMo Guardrails + pgvector Backend Architecture

* **Status**: Accepted
* **Date**: 2026-08-11
* **Deciders**: Lead AI Systems Architect & Mobile/Backend Engineering Team

## Context

CARE App backend services require low-latency asynchronous API handling, safety and alignment guardrails for generative AI interaction, and vector similarity search for contextual retrieval.

## Decision

We standardize backend operations on Python 3.13+ using:
1. **FastAPI & Uvicorn**: High-speed ASGI server for REST and WebSocket endpoints.
2. **NeMo Guardrails**: Programmable safety flows and output verification for LLM prompts/responses.
3. **`pgvector` & `asyncpg`**: Postgres vector store integration for semantic embeddings and retrieval.
4. **`google-genai`**: Gemini 2.5/3.0 model SDK integration.
5. **`uv`**: Fast package resolution and environment management.

## Consequences

* **Pros**: Sub-millisecond ASGI request routing, native Python AI ecosystem compatibility, enterprise safety guardrails.
* **Cons**: Requires local Postgres 16 instance with `pgvector` extension for full vector search integration.
