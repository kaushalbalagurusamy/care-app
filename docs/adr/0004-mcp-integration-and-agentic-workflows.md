# ADR 0004: Model Context Protocol (MCP) Integration

* **Status**: Accepted
* **Date**: 2026-08-11
* **Deciders**: Lead AI Systems Architect & Mobile/Backend Engineering Team

## Context

Autonomous AI developer agents require native programmatic interfaces to interact with Xcode builds, simulator runtimes, terminal commands, and workspace file trees without fragile GUI automation.

## Decision

We configure `.mcp.json` at the root of the repository with standardized SOTA MCP servers:
1. `XcodeBuildMCP` (`xcodebuildmcp@latest`): Xcode compilation, scheme listing, target building.
2. `swift-mcp`: Swift AST and language server index querying.
3. `DesktopCommander`: Process lifecycle control and terminal execution.

## Consequences

* **Pros**: Standardized JSON-RPC agent tool calls, reliable build feedback loops, cross-environment reproducibility.
* **Cons**: Requires `npx` / Node.js runtime on local development workstations.
