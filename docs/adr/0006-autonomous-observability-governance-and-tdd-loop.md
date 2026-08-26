# ADR 0006: Autonomous Execution Governance, Observability & TDD Loop

* **Status**: Accepted
* **Date**: 2026-08-26
* **Deciders**: Lead AI Systems Architect & Mobile Engineering Team

---

## 1. Architectural Context

Autonomous AI engineering agents operating on complex dual-stack monorepos (SwiftUI + FastAPI + pgvector) risk attempt exhaustion, patch compounding drift, failure mechanism blindness, and context/disk memory bloat when driven solely by unstructured raw terminal text scraping.

To ensure high-signal verification, memory efficiency, and deterministic progress across all Spec-Driven Development (SDD) phases, we establish an explicit architectural governance protocol and observability standard.

---

## 2. Decision & Governance Invariants

```
[ Phase Requirement / Test Spec ]
               │
               ▼
[ Invariant 1: Test-Ladder Constraint ] (Type Checks ➔ Unit Contracts ➔ Integration Mocks ➔ E2E UX)
               │ (Pass)
               ▼
[ Invariant 3: Atomic Git Checkpoint ] (Tag/Stash working tree prior to edits)
               │
               ├──────────────────────────────────────────────┐
               │ (Pass)                                       │ (Fail)
               ▼                                              ▼
[ Invariant 6: Green-State Log Pruning ]              [ Strike Counter: N ]
  • Tag green commit in Git                                   │
  • Purge ephemeral task logs & scratch traces                ├─────────────────────────────────┐
  • Run `xcodebuildmcp purge` for DerivedData                 │ (N < 2)                         │ (N >= 2)
  • Proceed to next phase with fresh context                  ▼                                 ▼
                                                    [ Minimal Diff Patch ]            [ Invariants 2, 4, 5 ]
                                                                                      • 2-Strike Diagnostic Gate
                                                                                      • Invariant 4: Save failure_trace.json
                                                                                      • Invariant 5: Subagent trace offload
                                                                                      • Invariant 3: Rollback (git reset --hard)
```

### Invariant 1: The Test-Ladder Constraint
Execution must strictly proceed bottom-up:
1. **Layer 1: Static Type & AST Diagnostics** (`swift-mcp` SourceKit-LSP & `swiftc`).
2. **Layer 2: Unit & Domain Model Invariants** (Isolated `#expect` / `@Test` assertions).
3. **Layer 3: Integration & Network Contract Mocks** (`URLProtocol` / FastAPI `TestClient`).
4. **Layer 4: Full Screen Snapshots & E2E UX Journeys** (`SnapshotTesting` & `XCUITest`).
* **Rule**: Agents must never attempt to fix an integration or E2E failure while a lower-level type or unit contract remains red.

---

### Invariant 2: The 2-Strike Diagnostic Gate
* If a targeted test assertion fails **twice consecutively** with the same error signature:
  1. **Halt all file edits immediately.**
  2. Synthesize and output a **Root-Cause Diagnostic Hypothesis** analyzing type signatures, memory lifecycle, and state propagation.
  3. Formulate and present a single, atomic, minimal diff before modifying any files.

---

### Invariant 3: The Rollback Mandate
* Before applying an experimental patch, the working tree must be checkpointed (`git stash` or atomic commit).
* If an edit fails to increase passing test counts or introduces regressions in previously passing tests, the agent must **immediately execute a hard rollback (`git reset --hard`)** to the last green checkpoint before testing an alternative hypothesis.

---

### Invariant 4: Persistent Failure Traces & Anti-Blindness Ledger
* **The Anti-Blindness Mandate**: An agent must never execute a rollback without first capturing the failure mechanism.
* Before executing `git reset --hard`, the agent writes an atomic `failure_trace.json` into the external persistent scratchpad directory (`<appDataDir>/brain/<conversation-id>/scratch/`), which is immune to Git resets:
  ```json
  {
    "phase": "Phase 2",
    "attempt_index": 2,
    "falsified_hypothesis": "Using @StateObject with @Observable macro",
    "failing_test_id": "TEST-NAV-01",
    "exact_assert_diff": "Expected count 1, received 0",
    "root_cause_delta": "@Observable requires @State or @Bindable; @StateObject creates observation conflict"
  }
  ```
* **Falsified Hypothesis Ledger**: The agent maintains an append-only list of falsified hypotheses to mathematically guarantee non-repetitive exploration and prevent progression stalling.

---

### Invariant 5: Context Freshness via Subagent Diagnostic Delegation
* If a failure trace or compiler diagnostic exceeds 50 lines of output:
  1. The parent orchestrator must **not** ingest the raw terminal dump into active prompt context.
  2. The parent spawns an ephemeral `research` or `self` subagent via `invoke_subagent`.
  3. The subagent operates in an isolated, fresh 1M+ context window, inspects the on-disk task log (`.system_generated/tasks/task-*.log`), and returns a concise, structured **Diagnostic Report** ($< 200$ tokens) back to the parent.
  4. The parent agent's context window remains pristine and focused on verified diff application.

---

### Invariant 6: Green-State Log Pruning & Ephemeral Garbage Collection
* Once all test contracts for a phase pass (Green Milestone):
  1. **Archive**: Any non-obvious architecture lessons are captured in the project ADRs.
  2. **Scratchpad Pruning**: Delete transient attempt traces (`failure_trace.json`) and intermediate task output files (`.system_generated/tasks/task-*.log`) from that phase.
  3. **Build Storage Purge**: Execute `xcodebuildmcp purge` to clean obsolete intermediate build artifacts and prevent `DerivedData/` disk bloat.
  4. **State Transition**: The agent outputs a concise milestone summary, ensuring a clean, unpolluted memory state for the subsequent phase.

---

## 3. Observability & Telemetry Tooling Matrix

| Tooling Layer | Protocol / Server | Implementation & Scope |
| :--- | :--- | :--- |
| **AST & Type Diagnostics** | `swift-mcp` | Real-time SourceKit-LSP semantic queries, type completions, and syntax error localization. |
| **Build & Test Orchestration** | `XcodeBuildMCP` | Native `xcodebuild` target compilation and structured log error parsing. |
| **Version Control & Rollbacks** | `git` (`@cyanheads/git-mcp-server`) | Programmatic atomic commits, branching, tagging green builds, and hard rollbacks. |
| **Out-of-Band Memory & Traces** | AGY Brain Scratchpad (`<appDataDir>/brain/`) | Persistent `failure_trace.json` storage immune to `git reset --hard` for anti-blindness tracking. |
| **Context Isolation Engine** | AGY Subagent Runtime (`invoke_subagent`) | Fresh context offloading for deep stack trace parsing without parent context pollution. |
| **Network Telemetry** | `proxyman` | Native HTTP/HTTPS network traffic inspection and mock response verification. |
| **Design Extraction** | `figma` (`figma-developer-mcp`) | Direct extraction of layout variables, color tokens, and SVG assets. |

---

## 4. Context & Storage Budget Guidelines

1. **Targeted Test Execution**: Always run isolated test methods using `-only-testing:SuiteName/TestName` rather than dumping entire monolithic test suite logs into prompt memory.
2. **Ephemeral Diagnostic Logs**: Filter build logs for compiler errors (`error: ...`) and assertion failures (`Assertion failed: ...`), discarding verbose codesigning, compilation tool paths, and intermediary object linkage text.
3. **Periodic Workspace Purges**: Run `xcodebuildmcp purge` at the conclusion of each phase to prevent gigabyte-scale intermediate object buildup.

---

## Consequences

* **Pros**: Guarantees zero patch drift; mathematically bounds token and disk consumption; prevents recursive hallucinated bugfixes; ensures atomic rollback while eliminating failure mechanism blindness.
* **Cons**: Requires strict discipline to log failure traces before rollbacks and execute cleanup routines on green transitions.
